#! /usr/bin/python3
import asyncio
import os
import subprocess
import sys
from stat import ST_MODE
import boto3
import argparse
import json

from botocore.client import BaseClient
from botocore.exceptions import ClientError


async def check_for_keys():
    try:
        key_pair = ec2.describe_key_pairs(
            KeyNames=[
                keypair_name
            ]
        )

        private_key = ssm.get_parameter(Name=secret_location)["Parameter"]["Value"]

        if key_pair["KeyPairs"]["KeyFingerprint"]:
            if private_key:
                return True
            else:
                print("No private key exists for key with name %s, deleting abandoned key", keypair_name)
                response = ec2.delete_key_pair(KeyName=keypair_name)
                print(response)
                return False
        else:
            return False

    except ClientError:
        print(f"The key requested named:\t{keypair_name} does not exist!")
        return False


def get_private_key():
    response = ssm.get_parameter(secret_location)

    if response["Parameter"]["Value"]:
        return response["Parameter"]["Value"]
    else:
        return None


def get():
    loop = asyncio.get_event_loop()
    key_found = loop.run_until_complete(check_for_keys())
    loop.close()

    if key_found:
        print(f"Key Pair {keypair_name} found!")
        key = ec2.describe_key_pairs(KeyNames=[
            keypair_name
        ])

        key_fingerprint = key["KeyPairs"][0]["KeyFingerprint"]

        secret_response = ssm.get_parameter(Name=secret_location, WithDecryption=True)
        key_material = secret_response['Parameter']['Value']
        key_dict = dict(KeyMaterial=key_material, KeyName=keypair_name, KeyFingerprint=key_fingerprint)

        return json.dumps(key_dict)
    else:
        print(f"Key Pair {keypair_name} was not found, creating it")
        key = ec2.create_key_pair(KeyName=keypair_name)
        print(key)

        response = ssm.put_parameter(
            Name=secret_location,
            Type="SecureString",
            Value=key["KeyMaterial"]
        )
        print(response)

        return key


def delete():
    loop = asyncio.get_event_loop()
    key_found = loop.run_until_complete(check_for_keys())
    loop.close()

    if key_found:
        response = ec2.delete_key_pair(KeyName=keypair_name)
        print("Key Pair %s deleted", keypair_name)
        print(response)

    private_key = get_private_key()
    if private_key:
        response = ssm.delete_parameter(Name=secret_location)
        print("Private key for key pair %s deleted", keypair_name)
        print(response)

    return


def add_to_agent(key_location):
    subprocess.call("eval `ssh-agent -s`")
    subprocess.call("ssh-add", key_location)


def agent():
    loop = asyncio.get_event_loop()
    key_exists = loop.run_until_complete(check_for_keys())
    loop.close()

    if key_exists:
        key_location = f"{keypair_name}.pem"
        if os.path.exists(key_location):
            key_file_permissions = oct(os.stat(key_location)[ST_MODE])[-3:]

            if key_file_permissions == '400':
                add_to_agent(key_location)
            else:
                # Set Permissions to 400
                os.chmod(key_location, 400)
                add_to_agent(key_location)
        else:
            key_contents = ssm.get_parameter(Name=secret_location)
            key_file = open(key_location, "w+")
            key_file.write(key_contents)
            key_file.close()
            os.chmod(key_location, 400)
            add_to_agent(key_location)
    else:
        print("Key pair %s does not exist!", keypair_name)
        get()
        agent()

    return


parser = argparse.ArgumentParser()
parser.add_argument("action", help="The action that you'd like to perform (get, delete, agent)")
parser.add_argument("project_name", help="The project that this is running for")
parser.add_argument("keypair_name", help="The Key Pair to get or create in KMS")
parser.add_argument("environment_name", help="The environment which you're creating/searching the KMS key for")

args = parser.parse_args()

environment_name = args.environment_name
keypair_name = args.keypair_name
project_name = args.project_name

secret_location = "/{environment_name!s}/{project_name!s}/bastion/sshKey".format(**locals())

ec2: BaseClient = boto3.client("ec2")
ssm = boto3.client("ssm")

if args.action.lower() == "get":
    get()
elif args.action.lower() == "agent":
    agent()
elif args.action.lower() == "delete":
    delete()
else:
    sys.exit("Invalid action selected!")

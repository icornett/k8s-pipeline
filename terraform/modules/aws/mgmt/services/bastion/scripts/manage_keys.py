#! /usr/bin/python3
import asyncio
import os
import subprocess
import sys
from stat import ST_MODE
import boto3
import argparse
import json


async def check_for_keys():
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
        print("Key Pair %s found!", keypair_name)
        key = ec2.describe_key_pairs(KeyNames=[
            keypair_name
        ])
        key_fingerprint = key['KeyPairs']['KeyFingerprint']
        secret_response = ssm.get_parameter(Name=secret_location, WithDecryption=True)
        key_material = secret_response['Parameters']['Value']
        return json.dump({"KeyMaterial": key_material, "KeyName": keypair_name, "KeyFingerprint": key_fingerprint})
    else:
        print("Key Pair %s was not found, creating it", keypair_name)
        key = ec2.KeyPair.create_key_pair(KeyName=keypair_name)

        ssm.put_parameter(
            Name=secret_location,
            Type="SecureString",
            Value=key["KeyMaterial"]
        )

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
        key_location = "{keypair_name!s}.pem".format(keypair_name)
        if os.path.exists(key_location):
            key_file_permissions = oct(os.stat(key_location)[ST_MODE])[-3:]

            if key_file_permissions == '600':
                add_to_agent(key_location)
            else:
                # Set Permissions to 600
                os.chmod(key_location, 600)
                add_to_agent(key_location)
        else:
            key_contents = ssm.get_parameter(Name=secret_location)
            key_file = open(key_location, "w+")
            key_file.write(key_contents)
            key_file.close()
            os.chmod(key_location, 600)
            add_to_agent(key_location)
    else:
        print("Key pair %s does not exist!", keypair_name)
        get()
        agent()

    return


parser = argparse.ArgumentParser()
parser.add_argument("action", help="The action that you'd like to perform (get, delete, agent")
parser.add_argument("project_name", help="The project that this is running for")
parser.add_argument("keypair_name", help="The Key Pair to get or create in KMS")
parser.add_argument("environment_name", help="The environment which you're creating/searching the KMS key for")

args = parser.parse_args()

environment_name = args.environment_name
keypair_name = args.keypair_name
project_name = args.project_name

if args.action.lower() == "get":
    get()
elif args.action.lower() == "agent":
    agent()
elif args.action.lower() == "delete":
    delete()
else:
    sys.exit("Invalid action selected!")

secret_location = "/{environment_name!s}/{project_name!s}/bastion/sshKey".format(**locals())

ec2 = boto3.resource("ec2")
ssm = boto3.resource("ssm")

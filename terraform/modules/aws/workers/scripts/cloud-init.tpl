#cloud-config
yum_repos:
  docker-ce-stable:
      baseurl: https://download.docker.com/linux/centos/7/x86_64/stable
      name: Docker CE Stable
      enabled: true
      gpgkey: https://download.docker.com/linux/centos/gpg
      gpgcheck: true
  kubernetes:
      baseurl: https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
      name: Kubernetes
      enabled: true
      gpgcheck: true
      gpgkey: 
        - https://packages.cloud.google.com/yum/doc/yum-key.gpg
        - https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
      repo_gpgcheck: true
packages:
    - yum-utils
    - yum-config-manager
    - device-mapper-persistent-data
    - lvm2
    - docker-ce
package_update: true
package_upgrade: true
package_reboot_if_required: true
runcmd:
    - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 22, -j, ACCEPT]
    - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 10250, -j, ACCEPT]
    - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 10255, -j, ACCEPT]
    - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 30000:32767, -j, ACCEPT]
    - [iptables-save, /etc/sysconfig/iptables]
    - [systemctl, enable, docker]
    - [systemctl, start, docker]
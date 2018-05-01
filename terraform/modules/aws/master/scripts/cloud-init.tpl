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

package_update: true
package_upgrade: true
packages:
  - yum-utils
  - yum-config-manager
  - device-mapper-persistent-data
  - lvm2
  - docker-ce
  - kubelet
  - kubeadm
  - kubectl
package_reboot_if_required: true

runcmd:
  - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 22, -j, ACCEPT]
  - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 6443, -j, ACCEPT]
  - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 8080, -j, ACCEPT]
  - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 2379:2380, -j, ACCEPT]
  - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 10250, -j, ACCEPT]
  - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 10251, -j, ACCEPT]
  - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 10252, -j, ACCEPT]
  - [iptables, -A, INPUT, -i, eth0, -p, tcp, --dport, 10255, -j, ACCEPT]
  - [iptables-save, /etc/sysconfig/iptables]
  - [systemctl, enable, docker]
  - [systemctl, start, docker]
  - [setenforce, 0]
  - [systemctl, enable, kubelet]
  - [systemctl, start, kubelet]
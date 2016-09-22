#!/bin/bash

#########################################################
# Script Name: configure-ansible.sh
#     configures ssh keys
# Parameters :
#  1 - i: IP Pattern
#  2 - n: Number of nodes
#  3 - r: Configure RAID
#  4 - f: filesystem : ext4 or xfs
# Note :
# This script has only been tested on CentOS 6.5 and Ubuntu 12.04 LTS
#########################################################

#---BEGIN VARIABLES---
IP_ADDRESS_SPACE='10.0.2.20'
NUMBER_OF_NODES='1'
NODE_LIST_IPS=()
CONFIGURE_RAID='1'
FILE_SYSTEM='ext4'
USER_NAME=''
USER_PASSWORD=''
TEMPLATE_ROLE='ansible'
START_IP_INDEX=0
SSH_AZ_ACCOUNT_NAME=''
SSH_AZ_ACCOUNT_KEY=''
MOUNTPOINT='/datadrive'


#-- while getopts :i:n:r:f:a:k: optname; do


###


function check_OS()
{
    OS=`uname`
    KERNEL=`uname -r`
    MACH=`uname -m`


    if [ -f /etc/redhat-release ] ; then
            DistroBasedOn='RedHat'
            DIST=`cat /etc/redhat-release |sed s/\ release.*//`
            PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ -f /etc/SuSE-release ] ; then
            DistroBasedOn='SuSe'
            PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
            REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
    elif [ -f /etc/debian_version ] ; then
            DistroBasedOn='Debian'
            if [ -f /etc/lsb-release ] ; then
                 DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
                 PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
                 REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
            fi
    fi

            OS=$OS
            DistroBasedOn=$DistroBasedOn
            readonly OS
            readonly DIST
            readonly DistroBasedOn
            readonly PSUEDONAME
            readonly REV
            readonly KERNEL
            readonly MACH

            log "INFO: Detected OS : ${OS}  Distribution: ${DIST}-${DistroBasedOn}-${PSUEDONAME} Revision: ${REV} Kernel: ${KERNEL}-${MACH}"

}


function install_ansible_ubuntu()
{


    apt-get --yes --force-yes install software-properties-common
    apt-add-repository ppa:ansible/ansible
    apt-get --yes --force-yes update
    apt-get --yes --force-yes install ansible
    # install sshpass
    apt-get --yes --force-yes install sshpass
    # install Git
    apt-get --yes --force-yes install git
    # install python
    apt-get --yes --force-yes install python-pip

 }

 function install_ansible_centos()
 {

    # install EPEL Packages - sshdpass
    wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    rpm -ivh epel-release-6-8.noarch.rpm
    # install python
    yum -y install python-pip

    # install ansible
    yum -y install ansible
    yum install -y libselinux-python

    # needed to copy the keys to all the vms
    yum -y install sshpass
    # install Git
    yum -y install git



 }

 function get_sshkeys()
 {
    # log "INFO:Retrieving ssh keys from Azure Storage"
    # pip install azure-storage

    # Download both Private and Public Key
    python GetSSHFromPrivateStorageAccount.py ${SSH_AZ_ACCOUNT_NAME} ${SSH_AZ_ACCOUNT_KEY} eclipse-installer-1.3.0-RELEASE.jar
    # python GetSSHFromPrivateStorageAccount.py ${SSH_AZ_ACCOUNT_NAME} ${SSH_AZ_ACCOUNT_KEY} id_rsa.pub

}


function configure_ssh()
{

    # copy ssh private key
    mkdir -p ~/.ssh
    mv id_rsa ~/.ssh

    # set permissions
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_rsa


    # copy root ssh key
    cat id_rsa.pub  >> ~/.ssh/authorized_keys
    rm id_rsa.pub

    # set permissions
    chmod 600 ~/.ssh/authorized_keys

    if [[ "${DIST}" == "Ubuntu" ]]; then
        #restart sshd service - Ubuntu
        service ssh restart

    elif [[ "${DIST}" == "CentOS" ]] ; then
        # configure SELinux
        restorecon -Rv ~/.ssh

        #restart sshd service - CentOS
        service sshd restart
    fi

}


 function configure_ansible()
 {
    # Copy ansible hosts file
    ANSIBLE_HOST_FILE=/etc/ansible/hosts
    ANSIBLE_CONFIG_FILE=/etc/ansible/ansible.cfg

    mv ${ANSIBLE_HOST_FILE} ${ANSIBLE_HOST_FILE}.backup
    mv ${ANSIBLE_CONFIG_FILE} ${ANSIBLE_CONFIG_FILE}.backup

    # Accept ssh keys by default
    printf  "[defaults]\nhost_key_checking = False\n\n" >> "${ANSIBLE_CONFIG_FILE}"
    # Shorten the ControlPath to avoid errors with long host names , long user names or deeply nested home directories
    echo  $'[ssh_connection]\ncontrol_path = ~/.ssh/ansible-%%h-%%r' >> "${ANSIBLE_CONFIG_FILE}"
    echo "\nscp_if_ssh=True" >> "${ANSIBLE_CONFIG_FILE}"
    # Generate a new ansible host file
    # printf  "[master]\n${IP_ADDRESS_SPACE}.${NUMBER_OF_NODES}\n\n" >> "${ANSIBLE_HOST_FILE}"
    printf  "[${TEMPLATE_ROLE}]\n${IP_ADDRESS_SPACE}[0:$(($NUMBER_OF_NODES - 1))]" >> "${ANSIBLE_HOST_FILE}"

    # Validate ansible configuration
    ansible ${TEMPLATE_ROLE} -m ping -v


 }


 function configure_storage()
 {
    log "INFO: Configuring Storage "
    log "WARNING: This process is not incremental, don't use it if you don't want to lose your existing storage configuration"

    # Run ansible template to configure Storage : Create RAID and Configure Filesystem
    ansible-playbook InitStorage_RAID.yml  --extra-vars "target=${TEMPLATE_ROLE} file_system=${FILE_SYSTEM}"

 }

InitializeVMs()
{
    # check_OS

    if [[ "${DIST}" == "Ubuntu" ]];
    then
        log "INFO:Installing Ansible for Ubuntu"
        install_ansible_ubuntu
    elif [[ "${DIST}" == "CentOS" ]] ; then
        log "INFO:Installing Ansible for CentOS"
        install_ansible_centos
    else
       log "ERROR:Unsupported OS ${DIST}"
       exit 2
    fi

    get_sshkeys
    #configure_ssh

    #configure_ansible
    #configure_storage


}

# InitializeVMs
 get_sshkeys

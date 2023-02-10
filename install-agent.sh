#!/bin/bash

sudo apt-get updatefffdsfsdfsdfsdfsdfsdfsdfsdfsd

# install az-cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash 

az login --identity

# fetch kubectl & helm
az aks install-cli
az acr helm install-cli --yes

VMUserName=$1

cd /home/$VMUserName  # VMUserName is VMSS Admin which is different from root user, and can run the config

# define those variable in admin context
AzureDevOpsURL=$2
AzureDevOpsPAT=$3
AgentPoolName=$4

# Creates directory & download ADO agent install files
mkdir myagent && cd myagent

# download the zip for the agent configuration and extract it
wget https://vstsagentpackage.azureedge.net/agent/2.214.1/vsts-agent-linux-x64-2.214.1.tar.gz
tar zxf vsts-agent-linux-x64-2.214.1.tar.gz

chown -R $VMUserName:$VMUserName /home/$VMUserName/myagent

# must not run as root
su - $VMUserName -c "cd /home/$VMUserName/myagent && ./config.sh --unattended \
  --agent ${AZP_AGENT_NAME:-$(hostname)} \
  --url $AzureDevOpsURL \
  --auth PAT \
  --token $AzureDevOpsPAT \
  --pool $AgentPoolName \
  --replace \
  --acceptTeeEula"

cd /home/$VMUserName/myagent

# Install and start the agent service
sudo ./svc.sh install
sudo ./svc.sh start

# Project Overview

    Recently the AlphaFold Protein Structure Database was greatly expanded with  the most recent version of AlphaFold Monomer used to determine the structures of over 200 million protein sequences. This work encompasses virtually all known and publicly available protein sequences. Nevertheless this remarkable tool is relatively straightforward to run yourself and being able to generate the structures of a novel gene or variant could be useful for  many fields of study. In this project we will utilize Google Cloud services to run AlphaFold quickly and for little cost. We will also look at using BigQuery to pull custom sets of structures from the complete AlphaFold dataset. 

# Running AlphaFold on Google Cloud:

### 1. Signup with Google Cloud 

  > https://cloud.google.com/
  
### 2. Set up gcloud CLI tools 
  1. Follow gcloud CLI installation instructions for your operating system: https://cloud.google.com/sdk/docs/install
  2. > $ gcloud auth login 
  3. Follow link and login with google account 
### 3. Preparing project settings in gcloud dashboard 
  1. Create Service Account with appropriate permissions
     1. From gcloud dashboard:  > IAM & Admin \> Service Accounts \> Create Service Account \> Roles \> 
     2. Add the following:
        >> Service Account User
        >> Compute Admin 
        >> Storage Admin
  2. Actions \> Manage keys \> Add JSON Key
  3. > $ gcloud auth activate-service-account --key-file /path/to/key.json
  4. Set budget for spending warnings
    1. Budgets and Alerts 
  5. Increase quota for disk space 
    1. Search bar \> All Quotas \> Persistent Disk SSD (GB) 
    2. Request increase to 3000 GB 
### 4. Create a VM instance for installing the AlphaFold DBs 
  1. Set up environment variable 
    1. PROJECTID=your-project-ID found at: > Dashboard \> Project info \> Project ID
    2. INSTANCE=name of vm 
  2. Spin up VM instance
    > $ gcloud compute instances create $INSTANCE \
    > --zone=us-central1-a \ 
    > --machine-type=e2-standard-8 \
    > --boot-disk-size=100GB \
    > --create-disk=mode=rw,size=3000,type=projects/$PROJECTID/zones/us-central1-a/diskTypes/pd-balanced,name=alphafold-data,device-name=alphafold-data
### 5. Install Docker and AlphaFold
  1. > gcloud compute ssh {name of VM}
  2.  Mount and format disk onto VM (https://cloud.google.com/compute/docs/disks/add-persistent-disk#format_and_mount_linux)
  3. Install git 
    > sudo apt-get update 
    > sudo apt-get install git 
  4. Install docker 
      1.  > sudo apt-get install \
          > apt-transport-https \
          > ca-certificates \
          > curl \
          > gnupg \
          > lsb-release
      2. > curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
         > echo \
         > "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
         > $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      3. > sudo apt-get update 
      4. > sudo apt-get install docker-ce docker-ce cli containerd.io
      5. > sudo gpasswd -a $(whoami) docker

  5. Enable container registry (must be run outside of VM)
    1. > gcloud services enable containerregistry.googleapis.com
  6. Docker build and push 
      > git clone https://github.com/deepmind/alphafold.git
      > cd alphafold
      > docker build -f docker/Dockerfile -t alphafold .
      > docker tag alphafold gcr.io/$PROJECTID/alphafold
      > docker push gcr.io/$PROJECTID/alphafold
Troubleshooting docker push 
gcloud auth list 
Make sure the service account or your account with the Storage Admin role is active 

### 6. Install databases 
  1. > sudo apt-get install rsync
  2. > sudo apt-get install aria2
  3. > sudo apt-get install tmux
  4. Download will take a couple hours best to do it in a detached shell
    > tmux new -s afdb
  5. > cd scripts 
  6. > ./download_all_data.sh /path/to/3000gb/diskmnt
  7. > Press ctrl+b then d to detach tmux window 
  8. to check progress: > tmux attach -t afdb  
      https://tmuxcheatsheet.com/











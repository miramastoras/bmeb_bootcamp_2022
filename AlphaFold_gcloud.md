# Project Overview

    Recently the AlphaFold Protein Structure Database was greatly expanded with the most recent version of AlphaFold Monomer used to determine the
    structures of over 200 million protein sequences. This work encompasses virtually all known and publicly available protein sequences. Nevertheless this
    remarkable tool is relatively straightforward to run yourself and being able to generate the structures of a novel gene or variant could be useful for
    many fields of study. In this project we will utilize Google Cloud services to run AlphaFold quickly and for little cost. We will also look at using
    BigQuery to pull custom sets of structures from the complete AlphaFold dataset. 

# Running AlphaFold on Google Cloud:

### 0. Spike Protein Fasta 
  
  Get the vcf2fasta.py script from this github.
  Patched from this project.
  https://github.com/santiagosnchez/vcf2fasta
  
      
### 1. Signup with Google Cloud 

  https://cloud.google.com/
  
### 2. Set up gcloud CLI tools 
  1. Follow gcloud CLI installation instructions for your operating system: https://cloud.google.com/sdk/docs/install
  2. ```$ gcloud auth login``` 
  3. Follow link and login with google account 
### 3. Preparing project settings in gcloud dashboard 
  1. Create Service Account with appropriate permissions
     1. From gcloud dashboard:  > IAM & Admin \> Service Accounts \> Create Service Account \> Roles \> 
     2. Add the following:
        - Service Account User
        - Compute Admin 
        - Storage Admin
  2. Actions \> Manage keys \> Add JSON Key
  3. ```$ gcloud auth activate-service-account --key-file /path/to/key.json```
  4. Set budget for spending warnings in Budget and Alerts dashboard page
  5. Increase quota for disk space:  
    1. Search bar \> All Quotas \> Persistent Disk SSD (GB)   
    2. Request increase to 3000 GB 
### 4. Create a VM instance for installing the AlphaFold DBs 
  1. Set up environment variable:  
    1. PROJECTID=your-project-ID found at: > Dashboard \> Project info \> Project ID  
    2. INSTANCE=name-of-vm 
  2. Spin up VM instance:
      ``` 
       gcloud compute instances create $INSTANCE \  
         --zone=us-central1-a \   
         --machine-type=e2-standard-8 \  
         --boot-disk-size=100GB \  
         --create-disk=mode=rw,size=3000,type=projects/$PROJECTID/zones/us-central1-a/diskTypes/pd-balanced,name=alphafold-data,device-name=alphafold-data  
      ```
### 5. Install Docker and AlphaFold
  1. ```$ gcloud compute ssh {name of VM}```
  2. [Mount and format disk onto VM](https://cloud.google.com/compute/docs/disks/add-persistent-disk#format_and_mount_linux)
  3. Install git:  
     ```
     sudo apt-get update   
     sudo apt-get install git 
     ```
  4. Install docker:
     ```
       1. sudo apt-get install \
          apt-transport-https \
          ca-certificates \
          curl \
          gnupg \
          lsb-release
       2. curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
       3. echo \
             "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
           $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
       4. sudo apt-get update 
       5. sudo apt-get install docker-ce docker-ce-cli containerd.io
       6. sudo gpasswd -a $(whoami) docker
  5. Enable container registry (must be run outside of VM)
      ```
      gcloud services enable containerregistry.googleapis.com
      ```
  6. Docker build and push:
     ```
      git clone https://github.com/deepmind/alphafold.git  
      cd alphafold  
      sudo docker build -f docker/Dockerfile -t alphafold .  
      sudo docker tag alphafold gcr.io/$PROJECTID/alphafold  
      docker push gcr.io/$PROJECTID/alphafold 
      ```
  7. Troubleshooting docker push: 
      ```
      gcloud auth list   
      ```
      ***Make sure the service account or your account with the Storage Admin role is active***

### 6. Install databases 
  1. Installation commands:
        ```
         $ sudo apt-get install rsync
         $ sudo apt-get install aria2
         $ sudo apt-get install tmux
        ```
        
       *Download will take a couple hours best to do it in a detached shell*


        ```
         $ tmux new -s afdb
         $ tmux attach -t afdb 
         $ cd scripts 
         $ ./download_all_data.sh /path/to/3000gb/diskmnt
        ```
       
        > ctrl+b then d to detach tmux window
          [tmux command cheetsheet](https://tmuxcheatsheet.com/)
      
  2. Check all files are accounted for:
      ```
      $DOWNLOAD_DIR/                             # Total: ~ 2.2 TB (download: 438 GB)
        bfd/                                   # ~ 1.7 TB (download: 271.6 GB)
            # 6 files.
        mgnify/                                # ~ 64 GB (download: 32.9 GB)
            mgy_clusters_2018_12.fa
        params/                                # ~ 3.5 GB (download: 3.5 GB)
            # 5 CASP14 models,
            # 5 pTM models,
            # 5 AlphaFold-Multimer models,
            # LICENSE,
            # = 16 files.
        pdb70/                                 # ~ 56 GB (download: 19.5 GB)
            # 9 files.
        pdb_mmcif/                             # ~ 206 GB (download: 46 GB)
            mmcif_files/
                # About 180,000 .cif files.
            obsolete.dat
        pdb_seqres/                            # ~ 0.2 GB (download: 0.2 GB)
            pdb_seqres.txt
        small_bfd/                             # ~ 17 GB (download: 9.6 GB)
            bfd-first_non_consensus_sequences.fasta
        uniclust30/                            # ~ 86 GB (download: 24.9 GB)
            uniclust30_2018_08/
                # 13 files.
        uniprot/                               # ~ 98.3 GB (download: 49 GB)
            uniprot.fasta
        uniref90/                              # ~ 58 GB (download: 29.7 GB)
            uniref90.fasta
      ```
      
### 7. Create image of database disk 

1. Unmount database disk from within VM: 
   ```
   sudo umount /disk/mnt/point
   ```
2. Detatch disk from command line:
   ```
   gcloud compute instances detach-disk INSTANCE-NAME --disk=DISK-NAME
   ```
3. Delete instance:
   ```
   gcloud compute instances delete INSTANCE_NAME
   ```
### 8. Installing dsub 

1. Enable Cloud Life Sciences API
   ```
   gcloud services enable lifesciences.googleapis.com
   ```
2. Create virtual enviornment to install dsub into
   ```
   python3 -m venv dsub_env
   ```
3. Activate venv 
   ```
   source env/bin/activate
   ```
4. Install [dsub](https://github.com/DataBiosphere/dsub)
   ```
   pip install dsub
   ```
### 9. Running AlphaFold 

 1. Save alphafold.sh from this repository
 2. Create GCS bucket
    ```
    gsutil mb gs://<PROJECT_ID>-alphafold

    ```
 3. Copy FASTA to GCS 
    ```
    gsutil cp spike.fasta gs://<PROJECT_ID>-alphafold/input/
    ```
 4. Run with dsub 
    ```
    dsub --provider google-cls-v2 \
    --project <PROJECT_ID> \
    --zones <ZONE_NAME> \
    --logging gs://<PROJECT_ID>-alphafold/logs \
    --image=gcr.io/<PROJECT_ID>/alphafold:latest \
    --script=alphafold.sh \
    --input FASTA=gs://<PROJECT_ID>-alphafold/input/all0174.fasta \
    --mount DB="<IMAGE_URL> 3000" \
    --output-recursive OUT_PATH=gs://<PROJECT_ID>-alphafold/output \
    --machine-type n1-standard-8 \
    --boot-disk-size 100 \ 
    --accelerator-type nvidia-tesla-k80 \
    --accelerator-count 1 \
    --preemptible \
    ```
    - Preemptible instances are extremely cost effective with discounts up to 91%, but come with [limitations](https://cloud.google.com/compute/docs/instances/preemptible). 



    











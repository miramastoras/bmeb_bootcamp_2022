## Bootcamp 2022 Project Part 1: Assembly of a covid genome

https://compeau.cbd.cmu.edu/online-education/sars-cov-2-software-assignments/covid-19-genome-assembly-assignment/

### Step 0: Set up working directory

```
cd /public/home/miramastoras/
mkdir bootcamp
cd bootcamp
```

### Step 1: Download the covid sequencing data

https://trace.ncbi.nlm.nih.gov/Traces/index.html?view=run_browser&acc=SRR11528307&display=data-access

```
mkdir data
cd data
wget https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR11528307/ABS2-LN-R1_cleaned_paired.fastq.gz
wget https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR11528307/ABS2-LN-R2_cleaned_paired.fastq.gz
```

### Step 2: Run assembly using spades

https://github.com/ablab/spades#sec2

```
wget http://cab.spbu.ru/files/release3.15.5/SPAdes-3.15.5-Linux.tar.gz
tar -xzf SPAdes-3.15.5-Linux.tar.gz
cd SPAdes-3.15.5-Linux/bin/
```

Run spades:
```

```
### Step 3: Align assembly to covid reference genome and call variants

### Step 4: Use Usher to determine the strain

### Additional ideas for Part 2:

Some other starting ideas for part 2 we could suggest but not put time into setting up (maybe ideas for more advanced computational people):  

- CoronaSpades: HMM based assembler that makes a covid assembly from transcriptome data
 https://cab.spbu.ru/software/coronaspades/
 https://www.biorxiv.org/content/10.1101/2020.07.28.224584v2

## Bootcamp 2022 Project Part 1: Assembly of a covid genome

https://compeau.cbd.cmu.edu/online-education/sars-cov-2-software-assignments/covid-19-genome-assembly-assignment/

### Step 0: Set up working directory

```
cd /public/home/miramastoras/
mkdir bootcamp
cd bootcamp
```
`/public/home/miramastoras/bootcamp22`

For testing docker container
```
docker run -it -v /public/home/miramastoras/bootcamp22:/public/home/miramastoras/bootcamp22 ubuntu:18.04 /bin/bash
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

Papers assessing multiple covid assemblers:https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8083570/
https://www.liebertpub.com/doi/10.1089/omi.2022.0042

https://github.com/ablab/spades#sec2

```
wget http://cab.spbu.ru/files/release3.15.5/SPAdes-3.15.5-Linux.tar.gz
tar -xzf SPAdes-3.15.5-Linux.tar.gz
cd SPAdes-3.15.5-Linux/bin/
```

Run spades:
```
spades.py -1 /public/home/miramastoras/bootcamp22/data/ABS2-LN-R1_cleaned_paired.fastq.gz -2 /public/home/miramastoras/bootcamp22/data/ABS2-LN-R2_cleaned_paired.fastq.gz -o /public/home/miramastoras/bootcamp22/results/ABS2-LN -t 5
```
### Step 3: Assess quality of assembly

https://rrwick.github.io/Bandage/

http://quast.sourceforge.net/quast.html
https://github.com/ablab/quast

```
./quast.py test_data/contigs_1.fasta \
           test_data/contigs_2.fasta \
        -r test_data/reference.fasta.gz \
        -g test_data/genes.txt \
        -1 test_data/reads1.fastq.gz -2 test_data/reads2.fastq.gz \
        -o quast_test_output
```

### Step 4: Align assembly to covid reference genome and call variants

- produce vcf file to use in USHER part 5
-look in IGV?

### Step 5: Use Usher to determine the strain (Lily)

### Additional ideas for Part 2:

Some other starting ideas for part 2 we could suggest but not put time into setting up (maybe ideas for more advanced computational people):  

- CoronaSpades: HMM based assembler that makes a covid assembly from transcriptome data - they'd need to find their own data to use, install it, then assess the quality of the assembly. They could compare this assembly to the one we made in part 1 and see which has a higher quality
 https://cab.spbu.ru/software/coronaspades/
 https://www.biorxiv.org/content/10.1101/2020.07.28.224584v2

- covid pangenome: they could make multiple
- assembly graph: could do something with that, bandage
- Load variant calls and bamfile into IGV

## Bootcamp 2022 Project Part 1: Assembly of a covid genome

https://compeau.cbd.cmu.edu/online-education/sars-cov-2-software-assignments/covid-19-genome-assembly-assignment/

### Step 0: How I made the docker container

This section includes the steps I used to create the docker container used in this project, for those who are curious. Otherwise, skip to step 1

Google "dockerfile <program of interest>" to find othe
```

```

### Step 1: Set up working directory

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
Files are not actually gzipped, which is required by spades (might be a good error to leave in workflow, they have to figure this out based on error message that spades throws)
```
mv ABS2-LN-R1_cleaned_paired.fastq.gz ABS2-LN-R1_cleaned_paired.fastq
mv ABS2-LN-R2_cleaned_paired.fastq.gz ABS2-LN-R2_cleaned_paired.fastq
gzip *
```

Run spades:
```
time ./spades.py -1 /public/home/miramastoras/bootcamp22/data/ABS2-LN-R1_cleaned_paired.fastq.gz -2 /public/home/miramastoras/bootcamp22/data/ABS2-LN-R2_cleaned_paired.fastq.gz -o /public/home/miramastoras/bootcamp22/results/ABS2-LN -t 5
```
Output:
```
======= SPAdes pipeline finished WITH WARNINGS!

=== Error correction and assembling warnings:
 * 0:00:13.216     5M / 1518M WARN    General                 (kmer_coverage_model.cpp   : 327)   Valley value was estimated improperly, reset to 1
 * 0:00:16.642    26M / 2282M WARN    General                 (launcher.cpp              : 178)   Your data seems to have high uniform coverage depth. It is strongly recommended to use --isolate option.
======= Warnings saved to /public/home/miramastoras/bootcamp22/results/ABS2-LN/warnings.log

SPAdes log can be found here: /public/home/miramastoras/bootcamp22/results/ABS2-LN/spades.log

Thank you for using SPAdes!

real    2m11.608s
user    8m42.988s
sys     0m32.668s
```
### Step 3: Assess quality of assembly

https://rrwick.github.io/Bandage/

http://quast.sourceforge.net/quast.html
https://github.com/ablab/quast

Download covid reference genome
https://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/bigZips/
```
cd /public/home/miramastoras/bootcamp22/data
wget https://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/bigZips/wuhCor1.fa.gz
```
Run Quast
```
docker run -it -u `id -u`:`id -g` -v /public:/public -v /public/home/miramastoras/bootcamp22:/public/home/miramastoras/bootcamp22 tpesout/hpp_quast:latest /opt/quast/quast-5.0.2/quast.py /public/home/miramastoras/bootcamp22/results/ABS2-LN/contigs.fasta \
        -r /public/home/miramastoras/bootcamp22/data/wuhCor1.fa.gz \
        -1 /public/home/miramastoras/bootcamp22/data/ABS2-LN-R1_cleaned_paired.fastq.gz -2 /public/home/miramastoras/bootcamp22/data/ABS2-LN-R2_cleaned_paired.fastq.gz \
        -o /public/home/miramastoras/bootcamp22/results/quast_output
```
Look at summary results:
```
less report.txt
```
### Step 4: Align assembly to covid reference genome and call variants
https://github.com/lh3/minimap2/issues/109
https://github.com/lh3/minimap2/blob/master/misc/README.md
```
# Map assembly to covid reference
docker run -it \
    -u `id -u`:`id -g` -v /public:/public \
    -v /public/home/miramastoras/bootcamp22:/public/home/miramastoras/bootcamp22 \
    miramastoras/bmeb_bootcamp22:latest \
    minimap2 -axasm5 /public/home/miramastoras/bootcamp22/data/wuhCor1.fa.gz /public/home/miramastoras/bootcamp22/results/ABS2-LN/contigs.fasta -o /public/home/miramastoras/bootcamp22/results/ABS2-LN_wuhCor1_mm2.sam

# sort alignment (sam) file & convert to bam
docker run -it \
    -u `id -u`:`id -g` -v /public:/public \
    -v /public/home/miramastoras/bootcamp22:/public/home/miramastoras/bootcamp22 \
    miramastoras/bmeb_bootcamp22:latest \
    samtools sort /public/home/miramastoras/bootcamp22/results/ABS2-LN_wuhCor1_mm2.sam -o /public/home/miramastoras/bootcamp22/results/ABS2-LN_wuhCor1_mm2.srt.bam
d
docker run -it \
    -u `id -u`:`id -g` -v /public:/public \
    -v /public/home/miramastoras/bootcamp22:/public/home/miramastoras/bootcamp22 \
    miramastoras/bmeb_bootcamp22:latest \
    htsbox pileup -q5 -S10000 -vcf /public/home/miramastoras/bootcamp22/results/ABS2-LN/contigs.fasta /public/home/miramastoras/bootcamp22/results/ABS2-LN_wuhCor1_mm2.srt.bam > /public/home/miramastoras/bootcamp22/results/ABS2-LN_wuhCor1_mm2.vcf
```
- produce vcf file to use in USHER part 5
- look in IGV?
- compare variants called by vcf provided by paper

Align reads to reference genome and call variants
```

```

### Step 5: Use Usher to determine the strain (Lily)

### Additional ideas for Part 2:

Some other starting ideas for part 2 we could suggest but not put time into setting up (maybe ideas for more advanced computational people):  

- CoronaSpades: HMM based assembler that makes a covid assembly from transcriptome data - they'd need to find their own data to use, install it, then assess the quality of the assembly. They could compare this assembly to the one we made in part 1 and see which has a higher quality
 https://cab.spbu.ru/software/coronaspades/
 https://www.biorxiv.org/content/10.1101/2020.07.28.224584v2

- covid pangenome: they could make multiple
- assembly graph: could do something with that, bandage
- Load variant calls and bamfile into IGV
- compare different assemblers quality

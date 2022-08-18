## Bootcamp 2022 Project Part 1: Assembly and strain determination of a SARS-COV2 genome

For Part One of our bootcamp project, we took inspiration from this workshop developed by Phillip Compeau (Writer of your BME 205 textbook, btw). Please read this page for additional background and context!
https://compeau.cbd.cmu.edu/online-education/sars-cov-2-software-assignments/covid-19-genome-assembly-assignment/

Our task is to download illumina sequencing reads containing DNA sequences of a "mystery" covid-19 strain. We will assemble a genome from these reads, evaluate the quality of our assembly, then call variants between our assembly and the covid-19 reference genome (wuhCor1). We will then employ the tool USHER to determine the exact strain of our covid sample, and where it lives on the phylogenetic tree of covid.

#### Key:
```
code you need to run
```
**Mandatory discussion questions**

> optional challenges and questions if you have time or finish early
### Step 0: Set up working directory

Please replace "miramastoras" with your own username
```bash
cd /public/home/miramastoras/
mkdir bootcamp
cd bootcamp

# set variable WRKDIR to path to your working directory. You will need to do this every time you open a new session
WORKDIR=/public/home/miramastoras/bootcamp22
cd $WORKDIR
```

### Step 1: Download the covid sequencing data and assembly

Location of illumina reads:
https://trace.ncbi.nlm.nih.gov/Traces/index.html?view=run_browser&acc=SRR11528307&display=data-access

Location of assembly:
https://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/bigZips/

```bash
# make a subdirectory in your working folder to hold data
mkdir data
cd data

# download illumina reads
wget https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR11528307/ABS2-LN-R1_cleaned_paired.fastq.gz
wget https://sra-pub-sars-cov2.s3.amazonaws.com/sra-src/SRR11528307/ABS2-LN-R2_cleaned_paired.fastq.gz

# download assembly
wget https://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/bigZips/wuhCor1.fa.gz
```
### Step 2: Run assembly using spades

> Optional reading: papers assessing multiple covid assemblers:
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8083570/
https://www.liebertpub.com/doi/10.1089/omi.2022.0042

GitHub page for the spades assembler:
https://github.com/ablab/spades#sec2


If you open one of your sequencing files (`head ABS2-LN-R1_cleaned_paired.fastq.gz`), you might notice that although they carry the extension `.gz`, they are not in fact gzipped. Spades required gzipped fastq files, so this would cause an error.

```bash
# fix extension
mv ABS2-LN-R1_cleaned_paired.fastq.gz ABS2-LN-R1_cleaned_paired.fastq
mv ABS2-LN-R2_cleaned_paired.fastq.gz ABS2-LN-R2_cleaned_paired.fastq
# actually zip files
gzip *
```
Lets make another folder to keep our assembly results in
```bash
cd $WORKDIR
mkdir results
```

Run spades:
```bash
docker run -it \
    -u `id -u`:`id -g` -v /public:/public \
    -v "${WORKDIR}":"${WORKDIR}" \
    miramastoras/bmeb_bootcamp22:latest \
    time ./spades.py -1 "${WORKDIR}"/data/ABS2-LN-R1_cleaned_paired.fastq.gz -2 "${WORKDIR}"/data/ABS2-LN-R2_cleaned_paired.fastq.gz -o "${WORKDIR}"/results/ABS2-LN -t 5
```
The output should look something like this:
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

The tool we are going to use to assess the quality of our assembly, and discover meaningful statistics about it is called Quast. Here is the documentation about this tool:

http://quast.sourceforge.net/quast.html

https://github.com/ablab/quast

Make another subdirectory for quast results
```bash
cd "${WORKDIR}"/results
mkdir quast_output
```

Run QUAST on our assembly:
```bash
docker run -it \
    -u `id -u`:`id -g` -v /public:/public \
    -v "${WORKDIR}":"${WORKDIR}" \
    tpesout/hpp_quast:latest /opt/quast/quast-5.0.2/quast.py /public/home/miramastoras/bootcamp22/results/ABS2-LN/contigs.fasta \
    -r "${WORKDIR}"/data/wuhCor1.fa.gz \
    -1 "${WORKDIR}"/data/ABS2-LN-R1_cleaned_paired.fastq.gz \
    -2 "${WORKDIR}"/data/ABS2-LN-R2_cleaned_paired.fastq.gz \
    -o "${WORKDIR}"/results/quast_output
```
Look at summary statistics:
```bash
cd "${WORKDIR}"/results/quast_output
less report.txt
```

**Discussion Question**
In your groups, discuss the following metrics:
- NG50
- NGA50
- Number missassemblies
- BUSCO completeness score
- genome fraction
- mismatch and indel rate

What do these metrics tell us about the quality and completeness of our assembly? Please take time to research what these metrics mean and discuss in groups


quast contiguity:
NG50: 50% of reference length, g means ref length and not assembly
NGA50 count each of these alignable chunks as different
also report missasemblies. layout phase is where most missasemblies happen
BUSCO can also be gotten from quast

Genome fraction:  

quast correctness:
mismatch and indel rate

> Bonus Question 1: How does QUAST work? Read its documentation and the paper to try and understand the methods behind the tool.

> Bonus Question 2: https://rrwick.github.io/Bandage/


### Step 4: Align assembly to covid reference genome and call variants

Now that we have our assembly, we want to know how it differs from the reference genome for COVID-19. To do this we will align our assembly to the reference, then call variants.

Minimap2 documentation:
https://github.com/lh3/minimap2/blob/master/misc/README.md

Map assembly to covid reference with minimap2
```bash
docker run -it \
    -u `id -u`:`id -g` -v /public:/public \
    -v /public/home/miramastoras/bootcamp22:/public/home/miramastoras/bootcamp22 \
    miramastoras/bmeb_bootcamp22:latest \
    minimap2 -cx asm5 -t8 --cs /public/home/miramastoras/bootcamp22/data/wuhCor1.fa /public/home/miramastoras/bootcamp22/results/ABS2-LN/contigs.fasta -o /public/home/miramastoras/bootcamp22/results/ABS2-LN_wuhCor1_mm2.paf
```

Sort by reference start coordinate

**Trick Question: why is this step actually unnecessary for us?**
```bash
docker run -it \
    -u `id -u`:`id -g` -v /public:/public \
    -v /public/home/miramastoras/bootcamp22:/public/home/miramastoras/bootcamp22 \
    miramastoras/bmeb_bootcamp22:latest \
    sort -k6,6 -k8,8n /public/home/miramastoras/bootcamp22/results/ABS2-LN_wuhCor1_mm2.paf > /public/home/miramastoras/bootcamp22/results/ABS2-LN_wuhCor1_mm2.srt.paf  
```

Use paftools stat to examine alignments and variants
```bash
docker run -it \
    -u `id -u`:`id -g` -v /public:/public \
    -v /public/home/miramastoras/bootcamp22:/public/home/miramastoras/bootcamp22 \
    miramastoras/bmeb_bootcamp22:latest \
    paftools.js stat /public/home/miramastoras/bootcamp22/results/ABS2-LN_wuhCor1_mm2.srt.paf
```

Use paftools call to call variants and output in vcf format
```bash
docker run -it \
    -u `id -u`:`id -g` -v /public:/public \
    -v /public/home/miramastoras/bootcamp22:/public/home/miramastoras/bootcamp22 \
    miramastoras/bmeb_bootcamp22:latest \
    paftools.js call -L10000 -l5000 -f /public/home/miramastoras/bootcamp22/data/wuhCor1.fa /public/home/miramastoras/bootcamp22/results/ABS2-LN_wuhCor1_mm2.srt.paf > ABS2-LN_wuhCor1.paftools.out
```
Separate vcf file from paftools stats output
```bash
head -n 11 ABS2-LN_wuhCor1.paftools.out > ABS2-LN_wuhCor1.paftools.vcf
```

Look inside vcf file:
```bash
cat ABS2-LN_wuhCor1.paftools.vcf
```
**Discussion question:** Discuss the vcf format in your groups and make sure you understand what all the columns and lines are telling you. Does this match up with what `paftools stats` told us?

> Optional Challenge: Alternatively, we could also just map our raw illumina reads to the covid reference and call variants that way. Which tools might we use if we did this instead? If you have extra time, try to implement this approach yourself, and look for any differences in the resulting vcf.

> Optional Question: Is minimap+paftools really the best tool for assembly-to-reference alignment & variant calling in viral genomes? Can you find a better one?

### Step 5: Use Usher to determine the strain (Lily)

### Additional project ideas for Part 2:

Some other starting ideas for part 2 we could suggest but not put time into setting up (maybe ideas for more advanced computational people):  

- CoronaSpades: HMM based assembler that makes a covid assembly from transcriptome data - they'd need to find their own data to use, install it, then assess the quality of the assembly. They could compare this assembly to the one we made in part 1 and see which has a higher quality
 https://cab.spbu.ru/software/coronaspades/
 https://www.biorxiv.org/content/10.1101/2020.07.28.224584v2

- make a covid pangenome
- compare different assemblers quality

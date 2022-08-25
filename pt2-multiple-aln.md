## Bootcamp 2022 Project Part 2: Multiple Alignment of SARS-CoV-2 Genomes for Variant Surveillance

This option for part 2 of the bootcamp is also adapted from one of Phillip Compeau's SARS-CoV-2 software assignments.
You can read more about the project's background and data description here:
https://compeau.cbd.cmu.edu/online-education/sars-cov-2-software-assignments/sars-cov-2-evolutionary-tree-multiple-alignment-challenge/

In short, what we are now doing is expanding the scope of our analysis to looking at not just one single SARS-CoV-2 genome,
but thousands of such sequences simultaneously. By aligning a large number of viral genomes sequences against each other, 
it is easy to detect the emergence of new, interesting variants and see how those variants shift over time.


### Step 0: Set up working directory
```bash
cd /public/home/username
mkdir bootcamp-pt2
cd bootcamp-pt2

WORKDIR=/public/home/username/bootcamp-pt2
cd $WORKDIR
```


### Step 1: Retrieve viral sequence data from UK Covid patients
```bash
git clone https://github.com/miramastoras/bmeb_bootcamp_2022.git
mkdir data
mv bmeb_bootcamp_2022/UK-Genomes.zip ./data
cd data
unzip UK-Genomes
cd UK-Genomes
ls
```
The UK-Genomes directory contains random collections of 100 SARS-CoV-2 genomes taken from UK patient samples at 2-week intervals from
November 2020 to March 2022. The folder name reflects the sampling date, in the YYYY_MM_DD format. If you go through some of these folders,
you'll notice that most of them have two fasta files: one YYYY_MM_DD.fasta file that contains the 100 viral sequences sampled on this date,
and another YYYY_MM_DD_A.fasta file that is the output of the multiple-alignment process that has already been completed.

FASTA is a common format for storing nucleotide or amino acid sequences. You can read more about it here: https://en.wikipedia.org/wiki/FASTA_format

These alignment files are pre-processed and ready to be used in the next steps. This is because the multiple alignment procedure can take
a couple of hours on ONE subset of 100 sequences 30Kb in size. However, to give you a taste of the process, the alignment file in the last
folder (`2022_03_07`) has been intentionally removed so you can fill it in with a file that you generate!

Also note that the number of sequences in `2022_03_07.fasta` is less than 100, which should make the alignment quicker. 

> Question: Can you find out how many sequences there are in `2022_03_07.fasta`?


### Step 2: Use MUSCLE to perform multiple alignment
We go to this link to download ```MUSCLE```: https://drive5.com/muscle/downloads_v3.htm
```bash
cd $WORKDIR
wget https://drive5.com/muscle/downloads3.8.31/muscle3.8.31_i86linux64.tar.gz
tar -xzvf muscle3.8.31_i86linux64.tar.gz
rm muscle3.8.31_i86linux64.tar.gz
mv muscle3.8.31_i86linux64 muscle
```

Running ```MUSCLE``` on our sequences:
```bash
muscle -in "$WORKDIR"/data/UK-Genomes/2022_03_07/2022_03_07.fasta \
    -out "$WORKDIR"/data/UK-Genomes/2022_03_07/2022_03_07_A.muscle.fasta
```

It should take about 2 hours to run. Here's an example output:
```
MUSCLE v3.8.31 by Robert C. Edgar

http://www.drive5.com/muscle
This software is donated to the public domain.
Please cite: Edgar, R.C. Nucleic Acids Res 32(5), 1792-97.

2022_03_07 53 seqs, max length 29876, avg  length 29851
00:00:01    19 MB(-7%)  Iter   1  100.00%  K-mer dist pass 1
00:00:01    19 MB(-7%)  Iter   1  100.00%  K-mer dist pass 2
00:27:22  1890 MB(-711%)  Iter   1  100.00%  Align node
00:27:22  1891 MB(-712%)  Iter   1  100.00%  Root alignment
00:54:29  1891 MB(-712%)  Iter   2  100.00%  Refine tree
00:54:30  1891 MB(-712%)  Iter   2  100.00%  Root alignment
00:54:30  1891 MB(-712%)  Iter   2  100.00%  Root alignment
01:53:41  1891 MB(-712%)  Iter   3  100.00%  Refine biparts
```


### Step 2: Use Prank to perform multiple alignment
Now let's try performing the multiple alignment using another tool: ```prank```. This one should take a lot faster to run.
Go to this link to download: http://wasabiapp.org/download/prank/
```bash
cd $WORKDIR
wget http://wasabiapp.org/download/prank/prank.linux64.170427.tgz
tar -xzvf prank.linux64.170427.tgz
rm prank.linux64.170427.tgz
```

Running ```prank``` on our sequences:
```bash
prank/bin/prank "$WORKDIR"/data/UK-Genomes/2022_03_07/2022_03_07.fasta
```

Here's an example output (truncated):
```
-----------------
 PRANK v.170427:
-----------------

Input for the analysis
 - aligning sequences in '/home/rennguye/bin/clustalw-2.1/2022_03_07.fasta'
 - using inferred alignment guide tree
 - option '+F' is not used; it can be enabled with '+F'
 - external tools available:
    MAFFT for initial alignment
    Exonerate for alignment anchoring
    BppAncestor for ancestral state reconstruction

Correcting (arbitrarily) for multifurcating nodes.
Correcting (arbitrarily) for multifurcating nodes.

Generating multiple alignment: iteration 1.

......

Generating multiple alignment: iteration 5.

Alignment score: 26955


Writing
 - alignment to 'output.best.fas'

Analysis done. Total time 631s
```

Now let's move the output to the same UK-Genomes folder:
```bash
mv "$WORKDIR"/output.best.fas "$WORKDIR"/data/UK-Genomes/2022_03_07/2022_03_07_A.prank.fasta
```


### Step 3: Comparing our multiple alignment outputs with MetAl

Let's see how our two multiple alignments compare to one another. The program that we're going to use, ```MetAl```, does this by
utilizing four metrics to assess the differences between inferred alignments. You can read more about these metrics in the MetAl paper:
https://academic.oup.com/bioinformatics/article/28/4/495/212883.

Running ```MetAl``` on our two alignments:
```bash
/public/home/username/bootcamp-pt2/bmeb_bootcamp_2022/metal "$WORKDIR"/data/UK-Genomes/2022_03_07/2022_03_07_A.muscle.fasta \
   "$WORKDIR"/data/UK-Genomes/2022_03_07/2022_03_07_A.prank.fasta 
```

Our output should look something like this:
```
367536 / 164542664 = 2.2336820801685817e-3
```
This means that the alignments we generated from ```MUSCLE``` and ```prank``` are about 0.223% different from each other, which is
not a significant number and suggests that we can use either one in our downstream analyses.


### Step 4: Download the alignment files to your laptop

Now we will move on to exploring the evolution of viral variants using our multiple alignments. We need to copy some of the alignment files 
from the server to our laptop to visualize them with the NCBI MSA viewer.
```bash
scp username@servername.uscs.edu:/public/home/username/data/UK-Genomes/2020_11_16/2020_11_16_A.fasta localpathforfile
```
Replace ```localpathforfile``` with the actual path on your local computer where you want the files to be.
Repeat this command to get files from these dates: ```2020_12_14```, ```2021_11_15```, and ```2022_03_07```.
Note that we previously created two alignments for ```2022_03_07```, one with ```MUSCLE``` and one with ```prank```. For this exercise,
let's use the one generated using ```MUSCLE``` (```2022_03_07_A.muscle.fasta```).


### Step 5: View the genome alignments using the NCBI MSA Viewer

Go to this link: https://www.ncbi.nlm.nih.gov/projects/msaviewer/
Click on the ```Upload``` button, choose ```Data file``` from the sidebar menu, ```Browse``` your local filesystem to select the
alignment file from the earliest sampling date (```2020_11_16_A.fasta```), and click ```Upload```.

Once the data has finished uploading, click ```Close``` to view the alignment.

You will now see the alignment across the length of the whole sequence (~30Kbp). To look at a specific region in more detail, you
can use the zoom feature at the top of the panel, then click on the sequences and drag left or right to upstream/downstream. You
can also click on a position to know the base and other alignment information at that site.

> Question: What do the red vertical bars signify in the multiple alignment? What about the gray regions?
  (Hint: You may find IUPAC notation helpful.)

> Question: Are there any regions of the genome that you find particularly interesting in terms of studying viral variation? Justify your answer.

Now let's check out the virus's genomes after a few weeks. Follow the same steps as above to view the alignment file for ```2020_12_14```.

You'll see that there are more mutations than we have seen previously. However, the worrying trend is not that more mutations are occurring,
but that their frequency appears to be increasing at the same positions/columns. We would not expect this pattern if mutations are just happening
randomly across the genome, and it suggests that the virus's mutations are possibly generating variants beneficial for its fitness.

> Question: Look at the alignment files for ```2021_11_16``` and ```2022_03_07```, describe any changes to the SARS-CoV-2 mutational landscape
that you see. What regions seem to vary the most? Do they code for any gene or have any functional significance?

One of the more variable regions corresponds to the spike protein. In the ```2020_11_16``` alignment, this gene occurs starting at column 21,563
(there is an “ATG” at this position, which is a start codon). 


### Step 6: Profiling individual mutations in the alpha variant

In this section, we will give an overview of three mutations that researchers identified in the spike protein gene occurring together in many 
sampled viruses from November 2020. These mutations, taken together, are some of the mutations that defined the first main variant of SARS-CoV-2, 
called B.1.1.7 or the alpha variant.

The three mutations are called N501Y, ΔH69/V70, and P681H. To explain this shorthand, N501Y means that the 501st codon of the spike protein changed 
from encoding an N to encoding a Y, and P681H means that the 681st codon of the spike protein changed from encoding a P to encoding an H. As for 
ΔH69/V70, this shorthand indicates that the 69th and 70th codons of the spike protein are deleted.

#### N501Y (the ACE latcher)

This is a well-studied single-nucleotide mutation first discovered in April 2020; it allows the coronavirus to more tightly fit the ACE2 receptor on 
human cells (the receptor that facilitates the virus’s cell entry).

Because the spike protein begins at position 21563 of both the ```2020_11_16``` alignment and the ```2020_12_14``` alignment, this mutation occurs at 
position 23063 of the alignments.

> Question: At the level of nucleotides, what was the original mutation? How many of the ```2020_11_16``` genomes have the mutation, and how many of 
the ```2020_12_14``` genomes have the mutation?

#### ΔH69/V70 (the antibody butter)

This deletion is present in several coronavirus variants and is therefore referred to as a recurrent deletion region. Although studies have 
confirmed this mutation does make the coronavirus more infectious, scientists are not entirely sure why. They speculate it may prevent antibodies 
from binding as tightly.

This mutation removes the 69th and 70th amino acid of the spike protein, which corresponds to positions 21765 through 21770 (inclusively) of 
both the ```2020_11_16``` and ```2020_12_14``` alignments.

> Question: What is the nucleotide sequence that is deleted? How many of the ```2020_11_16``` genomes have the mutation, and how many of the 
```2020_12_14``` genomes have the mutation?

> Question: You know that just because we see gap symbols does not mean we can infer that a deletion occurred. It may be that these six nucleotides 
were inserted in an ancestral sequence. Use the ```2020_11_16``` alignment to argue why the mutation is most likely a deletion.

#### P681H (the enzyme booster)

This mutation is also present in many coronavirus lineages internationally. Scientists believe that this mutation makes it easier for human enzymes 
to prepare the spike protein for cell entry.
The mutation occurs on the 681st amino acid of the spike protein and at nucleotide position 23604 of our alignments.

> Question: What was the original nucleotide at this position? How many of the ```2020_11_16``` genomes had it? What was the mutation, and how 
many of the ```2020_12_14``` genomes had acquired the mutation?
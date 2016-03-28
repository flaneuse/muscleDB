---
layout: post
title: "Basic Searching"
date: 2016-03-27
---

# Basic Searches in MuscleDB

When you search the atlas, you can filter the database by:   
    1. gene symbol (like 'Per1')  
    2. gene ontology (like 'GTPase activity')  
    3. muscle tissue type  
    4. expression level  
    5. p-value (statistically significant difference between tissues (based on a two-way ANOVA))  
    6. change in expression, relative to another tissue type.   

Starting a basic search
=======================
All the search options are located in a menu at the far left side, in charcoal grey. To hide or show the options, click the three lines just to the right of the MuscleDB title at the very top of the page.

#### by gene symbol 
If you want to search by gene name, you'll need to know the NCBI Gene Symbol or the UCSC transcript name. 
For instance, for the gene period circadian clock 1, you can enter either [Per1](http://www.ncbi.nlm.nih.gov/gene/18626){:target="_blank"} or [uc007jpf.1](https://genome.ucsc.edu/cgi-bin/hgGene?hgg_gene=uc007jpf.1&db=mm10){:target="_blank"} into the 'select a gene' box.   

* Searches are case-insensitive (it doesn't matter if you type "Per" or "per" or even "PER").
* All searches will start with the gene symbol name. So when you enter "per", you will get [Per1](http://www.ncbi.nlm.nih.gov/gene/18626){:target="_blank"}, [Per2](http://www.ncbi.nlm.nih.gov/gene/18627){:target="_blank"}, [Perm1](http://www.ncbi.nlm.nih.gov/gene/74183){:target="_blank"}, ...
* To return an exact query, add a **$** to the end of your search. For instance, to select [FST](http://www.ncbi.nlm.nih.gov/gene/14313){:target="_blank"} and not [FSTL](http://www.ncbi.nlm.nih.gov/gene/14314){:target="_blank"}, type "FST$"
* To return a series of gene symbols that end in numbers, add **[0-9]** after the search term. For instance, to select Per1, Per2, and Per3 (but not Perm1), search "Per[0-9]".
* Nerdy detail: the search queries are built upon regular expression matching, so most [regex](http://regexr.com/){:target="_blank"} syntax should work, with some modifications for R.

#### by gene ontology
Let's say you wanted instead to search by gene ontology — in other words, by gene class. 
Select the 'search ontology' button, and enter your ontology term. In this example, we'll look for all genes with GTPase activity.   

* As you start typing 'GTPase activity', a dropdown menu will appear with all the possible gene classes.
* It may take a few seconds for the list of possiblities to pop up.
* You can only select one gene ontology term.
* You can combine searching both gene symbols and ontologies.   

#### selecting muscle tissues
You can also select which muscle tissues interest you. By default, all tissues are checked. For this example, we'll look at just expression in the atria and eye tissues. Deselect the other muscles in the toolbar at the left.   

Displaying the information
==========================
At the bottom of the plot options, just below 'advanced filtering', are the different ways to display the data. You can choose to show:   

* **plot** (default): a bar graph of the expression levels in the tissues (in FPKM, Fragments Per Kilobase per Million reads) for each transcript, and options to save the plots.   
* **table**: numeric table with the gene symbols, transcript names, expression levels in the tissues (in FPKM, Fragments Per Kilobase per Million reads), and the q-value (difference between tissues from a two-way ANOVA).  
* **volcano plot**: volcano plot comparing two muscles, showing the logarithm of q-value versus the logarithm of the fold-change in expression  
* **heat map**: a dynamic heat map comparing the expression level of each transcript for each tissue.
* **compare genes**: a series of scatter plots comparing the expression levels to a particular reference tissue.

---
layout: post
title: "Advanced Filtering"
date: 2016-03-27
---

# Advanced filtering the Muscle Transcriptome Atlas

Once you have basic searching down, you can further limit your search results by filtering by expression level, -value, and/or fold change.

* **expression level** allows you to select transcripts within a range of expression values (in FPKM)
* **q-value** allows you to select transcripts with q-values ≤ a value
* **fold change** allows you to select transcripts with a fold change in expression ≥ a value, relative to a reference tissue.

Filtering by expression level
=============================
To filter by expression level, tick the expression level box, located just below the search button. This will cause a dropdown menu to appear, where you can put in the minimum and maximum expression level values, in FPKM. For instance, you might want to filter out transcripts with very low expression levels (< 1 FPKM). The graphs and tables will automatically update.

* If **any** muscle tissue has expression within the range of values, the transcript will be included.
* The table will update, and the 1,462 transcripts we had is filtered down to 1,173


Filtering by q-value
====================
To sort by q-value, tick the q-value box, located just below the search button. This will cause a dropdown menu to appear, where you can select the maximum q-value. The graphs and tables will automatically update.

* q is the false discovery rate, calculated using the Benjamini & Hochberg (1995) method
* q-values can be entered either as a decimal or in scientific notation.
* q-values can only be filtered for the entire set of 10 muscles, each pairwise set, or each group of muscle types: cardiac (atria, left ventricle, right ventricle) or skeletal (diaphragm, eye, EDL, FDB, plantaris, soleus)




Filtering by fold change
========================
To sort by fold change, tick the fold change box, located just below the search button. This will cause a dropdown menu to appear, where you can select the reference tissue and the numeric threshold for the fold change. The graphs and tables will automatically update.

* Fold change for a transcript is calculated by dividing the expression of all the muscles relative to its expression in the reference tissue.
* Transcripts with fold changes ≥ to the threshold for **any** of the muscle tissues will be selected.
* As a result, the filtered transcripts will be ones where the expression is upregulated relative to the reference tissue.
* If the reference tissue isn't one of the muscles selected in the muscle filter, it will be added.
* Note that fold change filters are best used in conjunction with an expression filter. If the reference tissue has low expression (< 1 FPKM), any fold change will be large since you're dividing by a number less than zero.

# Tracking major changes to MuscleDB

## 23 April 2017 (to do)
*performance upgrades*
* reduce number of sign. figures on q-values
* integrate data.table filtering from dplyr

*functionality*
* add in filtering by transcript + gene name
* check that png download is available everywhere.

*bugs*
* fix GO break at terms

## 16 April 2017
*New ANOVAs calculated, ontology + SE updated*
* updated ANOVAs with log2-transformed expression values
* updated gene ontology classifications
* updated master list of gene ontology terms for selectize
* revised incorrect standard error calculations for QUAD, GAS, TA
* fixed filtering to show q-values for new tissues (needed to map tissue names to their codes in `filterExpr.R`)

### files updated
1. expr_2017-04-16.rds
2. allOntologyTerms.rds
3. global.R (to reference new files)
4. filterExpr.R (to add in Q's for new tissues)
5. calculation / prep files in /prep folder

## 4 April 2017
*bug fixes*
* switched default view to be for Myod1
* revised default expression plot 
  * barplot --> dotplot
  * added in SE
  * colored expr by tissue type (cardiac, smooth, skeletal)
  * add FPKM label to axis
  * adjusted y-axis label font size
* fixed zoom in PCA, volcano plots
* fixed volcano plot, comparison plot errors from ggplot2 update

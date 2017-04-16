# Instructions on updating the raw data that goes into Muscle DB.
Laura Hughes, laura.d.hughes@gmail.com
19 Feburary 2017

All files are within the ['prep' directory](https://github.com/flaneuse/muscleDB/tree/master/prep)

# Calculate new ANOVAs
## within `2017-02-19_ANOVAs.R`:
1. Add the additional muscle tissues to the declaration of muscle types (lines 18-22)
* Update `rawDataFile` to be the location of the new data. Use `read.csv` if a .csv or `readxl::read_excel` if an Excel file.
* Adjust `numRep` in the call to `ANOVAlookupTable`, if necessary.  By default, is 6.
* Re-run `2017-02-19_ANOVAs.R` to calculate new ANOVAs. Files will be saved locally, where you define in script. If you get errors, check:
  * there aren't extra rows / NA transcripts in the dataset
  * the selection within `calcANOVA.R` is unique; should regex for the exact transcript shorthand followed by a single digit.
* Double check results with previous runs.


# Cleanup 
## within `importMT.R`:
1. change the data import to the new file
* update the dplyr selection to include the new tissues for avg, SE
* if adding new genes, update the transcript crosswalk file to get the new gene ontology terms.
* import the newly calculated ANOVAs
* Change the re-factorization to include new muscle tissues.
* Copy .rds file into the `data` folder of the Shiny app.

# Change data source in Shiny app 
## within `global.R`:
1. update the call to data (`data = readRDS('data/expr_2017-02-19.rds')`)
* update `tissueList`, `allTissues`, `selTissues`
* run app to double check everything works.
## within `filterExpr.R`:
1.   update muscleSymbols = plyr::mapvalues(selMuscles, ...)

# Upload to server and restart Shiny server.
1. Copy the new .rds data file into the data directory
* replace the new `global.R` file
* deploy and restart the server.

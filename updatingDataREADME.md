# Instructions on updating the raw data that goes into Muscle DB.
Laura Hughes, laura.d.hughes@gmail.com
19 Feburary 2017


# Calculate new ANOVAs
## within `2017-02-19_ANOVAs.R`:
1. Add the additional muscle tissues to the declaration of muscle types (lines 18-22)
* Update `rawDataFile` to be the location of the new data. Use `read.csv` if a .csv or `readxl::read_excel` if an Excel file.
* Adjust `numRep` in the call to `ANOVAlookupTable`, if necessary.  By default, is 6.
* Re-run `2017-02-19_ANOVAs.R` to calculate new ANOVAs. Files will be saved locally, where you define in script.
* Double check results.
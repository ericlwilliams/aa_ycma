AA YMCA current data status
==============





Using: YMCA-DATA/'Original Data - Cleaned.txt'


```r
ydata <- read.delim('../YMCA-DATA/Original Data - Cleaned.txt', header=F, stringsAsFactors=F)
```




Convert to data.table


```r
ydata <- data.table(ydata); str(ydata)
```

```
## Classes 'data.table' and 'data.frame':	487686 obs. of  8 variables:
##  $ mem_number_hash: num  109738 109740 109742 109744 109754 ...
##  $ MIN_FAMILY     : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ CHI_DATE       : chr  "7/23/2002 0:00:00" "1/1/2000 0:00:00" "1/1/2000 0:00:00" "1/1/2000 0:00:00" ...
##  $ EXP_DATE       : chr  "12/31/99" "" "" "" ...
##  $ MTP_MTY_PERIOD : int  2003 NA NA NA NA 2003 2003 2003 NA NA ...
##  $ MTP_MTY_TYP    : chr  "Young Adult" "" "" "" ...
##  $ MTP_PPL_DESCRIP: chr  "Bank Draft" "" "" "" ...
##  $ MST_MEM_STATE  : chr  "Active" "New" "New" "New" ...
##  - attr(*, ".internal.selfref")=<externalptr>
```


<!-- Clean up dates -->




<!-- Define useful functions -->



<!-- Skim Data -->




Meaning of entry labels needs validation/clarification!

Best guesses:
- `mem_number_hash`: Member ID
- `CHI_DATE`: Date of data point entry into system 
	- First entry corresponds to beginning of membership?
- `EXP_DATE`: Date of expiration of membership
	- not always present
- `MTP_MTY_PERIOD`: Tax year of membership(?)
- `MST_MEM_STATE`: Status of membership at time of data point entry

Some summary plots before data cleaning:




![plot of chunk multiPlots_1](figure/multiPlots_1.pdf) 



	Require at least one `CHI_DATE` entry for each member ID.





![plot of chunk multiPlots_2](figure/multiPlots_2.pdf) 


	Require at least two `CHI_DATE` entries (ensure follow-up)





![plot of chunk multiPlots_3](figure/multiPlots_3.pdf) 



	Remove all Y2K entries (unknown source)





![plot of chunk multiPlots_4](figure/multiPlots_4.pdf) 



	Require *single* `New` and `Exp` entry for each member





![plot of chunk multiPlots_5](figure/multiPlots_5.pdf) 




	Restrict to `MTP_MTY_PERIOD` > 2004






![plot of chunk multiPlots_6](figure/multiPlots_6.pdf) 


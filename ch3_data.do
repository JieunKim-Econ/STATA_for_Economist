*Chapter 3. Data, Who are you?


********************************************************************************
*[1]Get to know your data: count, describe, summarize
********************************************************************************

*sysuse: load publicly provided data when installing STATA
sysuse auto.dta, clear

*count: the number of observation
count

*describe: display the format, type, lable of variabels
*variable format: numeric, string, date
**numeric: general, floating, integer

*'make' is 18 digit string, 'price' 8 digit integer with comma,
* and 'headroom' is 6 digit flating with 1 decimal point 
des

*It is "informative" to check "Mean": If Mean is empty, the variable has the string format
*If var's Obs < whole Obs, there are missing variables 
sum

*To get detailed info regarding distribution such as median and percentile, use "detail" option
*sum varlist, detail
sum price, detail

*We can see that Median < Mean: The distribution of price is right skewed. 

********************************************************************************
*[2]Visual check of distribution: 1)Histogram 2)Cross-tabulation 3)Scatter diagram
********************************************************************************

********************************************************************************
*[2]-1.Histogram (1 variable)
********************************************************************************
*To display "ONE" variable, graphical display of 'summarize, detail' 
*Why useful? To identify the existence of "outlier" and its amplitude 
hist price

*kernel density: continuous drawing of histogram
*We can adjust the type of kernel function and the bandwidth by option
kdensity price

*Overlap graphs
**ring: place the legend inside/outside the graph
**pos: clockwise location of the legened 
**col: no. of columns to present the legend
**///: command is yet to finish 
twoway (hist price) (kdensity price), legend(order(1 "Histogram" 2 "Kernel density") ///
ring(0) pos(1) col(1)) xtitle(Price)

********************************************************************************
*[2]-2.Scatter (+2 var)
********************************************************************************
*Correlation between 2 variables, Starting point before identifying causal relationship

*Whiel Histogram shows distrbituion of ONE variables, for economic analysis,
*our main interest is to identify the correlation of more than 2 vars and ultimately the causal relationship
*Thus, checking correlation between 2 variables via graph is a great starting point before looking into causal relationship.


*Correlation btw mileage(mpg) and price
scatter mpg price, by(foreign) ms(Oh)

*lfit: add trend line
twoway (scatter mpg price if foreign==0, ms(O))(lfit mpg price if foreign==0, clpat(solid))(scatter mpg price if foreign==1, ms(Oh))(lfit mpg price if foreign==1, clpat(dash)),
legend(order(1 "MPG":"Domestic" 2 "Fitted":"Domestic" 3 "MPG:Foreign" 4 "Fitted:Foreign"))

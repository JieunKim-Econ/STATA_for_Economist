********************************************************************************
* Load the data
********************************************************************************
use "C:\Users\jieun\Desktop\PublicStata\rscfp2016.dta", clear

********************************************************************************
* Keeping variables of interest (and Drop all other variables) 
********************************************************************************
keep YY1 Y1 wgt age wageinc income networth ssretinc transfothinc

********************************************************************************
* Dropping replicates (Remove duplicates) 
********************************************************************************
duplicates drop YY1, force

********************************************************************************
* Computing  Mean/median
********************************************************************************
tabstat wageinc [aweight=wgt] if age>=25 & age <=60, stats(mean median)
tabstat income networth [aweight=wgt], stats(mean median)

* You can let Stata compute the mean-median ratio:
tabstat wageinc [aweight=wgt] if age>=25 & age <=60, stats(mean median) save 
matrix results = r(StatTotal)
display results[1,1] /results[2,1]

* income and networth
tabstat income networth [aweight=wgt], stats(mean median) save
matrix results2 = r(StatTotal)
display results2[1,1] /results2[2,1]
display results2[1,2]/results2[2,2]

********************************************************************************
* Computing  Top 1% / lowest quintile 
********************************************************************************
xtile qwageinc = wageinc [aweight=wgt] if age>=25 & age <=60, nquantiles(100) 
*Top 1%: qwageinc>99
tabstat wageinc [aweight=wgt] if qwageinc>99 & age>=25 & age <=60, stats(sum) save  
*Lowest quintile=Bottom 20%
tabstat wageinc [aweight=wgt] if qwageinc>=1 & qwageinc<=20 & age>=25 & age <=60, stats(sum) save

xtile qincome = income  [aweight=wgt], nquantiles(100)
tabstat income  [aweight=wgt] if qincome>99, stats(sum)
tabstat income [aweight=wgt] if qincome>=1 & qincome<=20, stats(sum)

xtile qnetworth = networth  [aweight=wgt], nquantiles(100)
tabstat networth  [aweight=wgt] if qnetworth>99, stats(sum)
tabstat networth [aweight=wgt] if qnetworth>=1 & qnetworth<=20, stats(sum)

********************************************************************************
* Computing  95/50 percentile
********************************************************************************
tabstat wageinc [aweight=wgt] if age>=25 & age <=60, stats(median p95) save
matrix result3= r(StatTotal)
display result3[2,1]/result3[1,1]

tabstat income networth [aweight=wgt], stats(median p95) save
matrix result4= r(StatTotal)
display result4[2,1]/result4[1,1]
display result4[2,2]/result4[1,2]

********************************************************************************
* Computing  50/25 percentile
********************************************************************************
tabstat wageinc [aweight=wgt] if age>=25 & age <=60, stats(median p25)
tabstat income networth [aweight=wgt], stats(median p25)

********************************************************************************
* Gini index
********************************************************************************
ssc install ineqdeco /*Install the package if unavailable*/

ineqdeco wageinc [aweight=wgt] if age>=25 & age <=60
ineqdeco income [aweight=wgt]
ineqdeco networth [aweight=wgt]

********************************************************************************
* Market income: income before both tax and transfer 
* (original) income is income before tax and after transfer 
********************************************************************************
gen mincome = income - ssretinc - transfothinc

********************************************************************************
* Lorenz curve
********************************************************************************
ssc install glcurve /*Install the package if unavailable*/

* Lorenz curve market income (before both tax and transfer) 
glcurve mincome [aw=wgt] , lorenz sortvar(mincome)

* Lorenz curve before-tax and after-transfer income
glcurve income [aw=wgt] , lorenz sortvar(income) 

* Combining the two Lorenz curves 
glcurve income [aw=wgt],gl(g1) p(p1) nograph lorenz sortvar(income) 
glcurve mincome [aw=wgt],gl(g2) p(p2) nograph lorenz sortvar(mincome)
twoway (line g1 p1, sort) (line g2 p2, sort) (function y=x ,range(0 1)) , ///
legend(label(1 "income before taxes and after transfers") label(2 "market income") label(3 "45 degree"))

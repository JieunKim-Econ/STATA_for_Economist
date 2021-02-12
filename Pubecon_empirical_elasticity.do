**************************
* Part 1
**************************
use "C:\Users\jieun\Desktop\PublicStata\cepr_march_1980.dta", clear
append using "C:\Users\jieun\Desktop\PublicStata\cepr_march_1990.dta", force
append using "C:\Users\jieun\Desktop\PublicStata\cepr_march_2000.dta", force
append using "C:\Users\jieun\Desktop\PublicStata\cepr_march_2016.dta", force

* Restrict the sample to include only individuals of age 25-54
keep if age>=25 & age<=54

* Compute each individual's annual hours worked 
gen hrs =  uhours*weeks

* Compute summary statistics
tabstat hrs  if female ==1  [aw=wgt], stats(mean) by(year)
tabstat hrs  if female ==1  & married == 1 [aw=wgt], stats(mean) by(year)
tabstat hrs  if female ==1  & married == 0 [aw=wgt], stats(mean) by(year)

tabstat hrs  if female ==0  [aw=wgt], stats(mean) by(year)
tabstat hrs  if female ==0  & married == 1 [aw=wgt], stats(mean) by(year)
tabstat hrs  if female ==0  & married == 0 [aw=wgt], stats(mean) by(year)

save "cepr_march_all.dta", replace

**************************
* Part 2
**************************
use "cepr_march_all.dta", clear

* Restrict the sample to married couples only, "œ"= OR
* Hint: "labelbook hhrel2"
keep if hhrel2 == 1 | hhrel2 == 2 

* count the number of members in a household and drop singles or 
* married households whose spouse is not present in the data set

/* It turns out that some versions of Stata do not allow you to 
use command COUNT on a string variable (i.e. a variable that is 
a text as opposed to a number). In our case, hhseq is in fact a string variable. 
To overcome this issue, convert hhseq to a real number by running

generate hhseq2 = real(hhseq)

and proceed using hhseq2 instead of hhseq.

*/

sort year hhseq
egen count = count(hhseq), by(year hhseq)
keep if count==2
drop count

* Compute log of annual hours worked and log of real hourly wage for both husband and wife
gen lhrs = log(hrs)
gen lrhrwage = log(rhrwage)

* Append to each observation on a wife-her husband's real hourly wage.
sort year hhseq female
gen srlhrwage = lrhrwage[_n-1] if female == 1
drop if female == 0

* Run the regressions
bysort year: regress lhrs lrhrwage srlhrwage [aw=wgt]

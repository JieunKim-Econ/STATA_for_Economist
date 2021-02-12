*Chapter 4. Basic commands


*********************
* Data Management
*********************

* save & use
* It's always good to write the option 'clear' as STATA can use the only one data
save filename, replace
use filename, clear

* search & help
search regression
help regress

* encode: Turn string into numeric and vice versa 
encode gender, gen(gender_new)
tab gender_new, nolabel

**************************
* by, sort, and bysort
**************************
* sort: Arrange observations into "ascending order" based on the speicifc variables
* by: Repeat Stata command on "subsets of the data"
sysuse auto
keep make mpg weight

* Arrange observations into "ascending order" based on the values of mpg
sort mpg

* List the 5 cars with the LOWEST mpg
list make mpg in 1/5

**************************
* Exercise: by, sort, and bysort
**************************
sysuse auto
* For each category of foreign, display summary statistics for rep78
by foreign: summarize rep78

* Check if the data are sorted by foreign & make within foreign
by foreign (make) : summarize rep78
* Result: Not sorted

sort foreign make
by foreign (make): sum rep78

* For each category of rep78, display frequency counts of foreign
by rep78: tabulate foreign
* Result: Not sorted

sort rep78
by rep78: tab foreign

* Equivalent to above command using "bysort"
bysort rep78: tab foreign 
/*Exercise Complete*/

* drop & keep
drop x
drop if gender == 1

* If gender is dummy variable
drop if gender 

* drop the first 10 observations 
drop in 1/10

**************************
* generate & replace & egenerate
**************************
gen gender=v1

* Create dummy var by using "() function"
* Option 1
gen dummy_lowincome = (income <=1000)

* Option 2 by using "replace"
gen gender_new=1 if gender == "female"
replace gender_new=0 if gender == "male"

* Replace "missing values '.'" as 0
replace gender_new=0 if gender_new == .

* Take log
gen log_income = ln(income)

/*3 WAYS TO CREATE DUMMY VAR
1) inlist(z,a,b): 0,1 dummy if z==a l z==b
2) cond(z,a,b): 0,1 dummy if a<=z<=b
3) recode(z,a,b,c): a if z<=a, b if a<z<=b, c if b<z 
*/

* egen: extended version of gen. Make constant by using functions such as mean(), sum()
use C:\Users\jieun\Desktop\STATAforEcon\ch4\college.dta, clear
egen mean_year = mean(year)
bysort year: egen mean_year = mean(year)


**************************
* Make summary statistics for important/specific variables
**************************

/*collapse & tabstat & tabulate, sum()
The option ',by()' is very useful to obtain data under certain categories
e.g. by (year), by (region) etc
collaps makes a new dataset*/

collapse (mean) gpa hour (median) medgpa=gpa medhour=hour, by (year)
* check the result with list command
list

* tabstat: in between summarize and collapse comand, it doesn't make any new dataset
* Summary table for 2 variables gpa and hour
tabstat gpa hour, stat(mean sd min max) col(stat) by(year)

* tabulate, sum()
tab year, sum(gpa)

**************************
* Export results to an Excel file: putexcel
**************************

**************************
* Exercise 1: Export simple result
**************************
sysuse auto, clear
summarize mpg

* To check which info is saved
return list

* Put this info in Excel
putexcel A30=rscalars using results.xlsx, sheet("June 3") modify

* Replace specific results
putexcel A30=(r(min)) A31=(r(N)) using results, sheet("June 3", replace) modify

* We can use putexcel to create tables in Excel using Stata return results.
* To create a tabulate oneway table of the variable foreign in Excel format,
 tabulate foreign, matcell(cell) matrow(rows)
 
 putexcel A1=("Car type") B1=("Frequency") using results, sheet("tabulate oneway") replace
 putexcel A2=matrix(rows) B2=matrix(cell) using results, sheet("tabulate oneway") modify
 putexcel A4=("Total") B4=(r(N)) using results, sheet("tabulate oneway") modify

**************************
* Exercise 2: Export complex tables or numerous objects
**************************
sysuse auto, clear
regress price turn gear

putexcel set "results.xls", sheet("regress results")

putexcel F1=("Number of obs") G1=(e(N))
putexcel F2=("F")             G2=(e(F))
putexcel F3=("Prob > F")      G3=(Ftail(e(df_m), e(df_r), e(F)))
putexcel F4=("R-squared")     G4=(e(r2))
putexcel F5=("Adj R-squared") G5=(e(r2_a))
putexcel F6=("Root MSE")      G6=(e(rmse))
matrix a = r(table)'
matrix a = a[.,1..6]
putexcel A8=matrix(a, names)
/*Exercise Complete*/

* rename & label
rename original new 

**************************
* Exercise: label
**************************
webuse hbp4, clear
describe

* Label the dataset
label data "fictional blood pressure data"
* Describe the dataset
describe

* Label hbp "variable" as high blood pressure
label variable hbp "high blood pressure" 

* Define the value label "yesno"
label define yesno 0 "no" 1 "yes" 

* List the names and contents of all value labels
label list

* List the name and contents of ONLY the value label YESNO
label list yesno

* List names of value labels
label dir

* Make a copy of the value label yesno
label copy yesno yesnomaybe

* Add another value and label to the value label yesnomaybe
label define yesnomaybe 2 "maybe", add

* List the name and contents of value label yesnomaybe
label list yesnomaybe

* List the first 4 observations in the dataset
list in 1/4

* Attach the value lable yesnomaybe to the variable hbp
label values hbp yesnomaybe
list in 1/4
/*Exercise Complete*/

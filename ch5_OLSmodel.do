* Chapter 5. OLS model
* 5 Oct 2020

*********************
* OLS(Ordinary Least Square) model
*********************

/* Three main reasons for OLS 
1. To estimate "Causal Relation" between policy var(X) and performance var(Y) 
2. With other variables CONTROLLED, to estimate correlation between policy var(X) and dependent var(Y)
OR to estimate partial effect: Frisch-Waugh-Lovell THM: Pure effect of the variable of our interest on dependent var
3. We can get "consistent estimator" under the assumption which is not that strong/restrictive 
::Consistent and Efficient(The size of variance) */

/* The merit of taking log on dependent var
1. The large values of Y get smaller with log, show the similar distribution with normal distribution.
:: If Y has normal distribution, OLS estimate becomes the most efficient estimate(e.g. estimate with the smallest variance).
2. Elasticity: We can interpretate Beta as an elasticity with log-log model
:: With elasticity, the measurement unit of X and Y does not affect the estimate value.
*/

*********************
* 1.Example of OLS estimation
**1-A. Relationship between CEO's salary and ROE
*********************
*We can expect the positive correlation btw ROE(Return on equity)and CEO's salary
*The company with High ROE tends to have CEO with High salary 
use "C:\Users\jieun\Desktop\STATAforEcon\ch5\CEOSAL1", clear
list roe salary

*Visual check of roe and salary
scatter salary roe, scheme(sj)

*Add regression line(lfit): Slope of the line means the size of change in CEO's salary with 1 unit change of ROE 
*scheme(): sj for Stata Journal format, s1color and s2color for color, s1mono and s2mono for black and white 
twoway (scatter salary roe) (lfit salary roe), scheme(sj)

*Basic model regression: salary_i=B_0+B_1*roe_i+e_i
reg salary roe
/* Result:  
1. Coef. 18.50119: If roe increases by 1%p, salary goes up by $18,500 
2. R-squared 1.3%: Index for model validity  
::The proportion of the variance in the dependent variable which is predictable from the independent variable(s).
3. This model has a critical weakness: The estimate value depends on the unit measurement*/

*Take log for ELASTICITY: Relation btw sales and CEO salary
scatter lsalary lsales
reg lsalary lsales
/* Result: 
1. Coef. .25667: With 1% increase in sales, CEO salary increases by 0.25%
:: CEO's salary is inelastic in response to change in sales
2. t 7.44: The relationship is statstically significant as the value of t is larger than 2(in 95% confidence interval)*/

*********************
* 1.Example of OLS estimation: Multiple Regression Model
**1-B. Determinants of College GPA 
*********************
use "C:\Users\jieun\Desktop\STATAforEcon\ch5\GPA1", clear
describe

*Visual check1: relation btw Highschool GPA(hsgpa) and College GPA(colGPA)
scatter colGPA hsGPA, scheme(sj)

*Visual check2: relation btw Standardized national achievement testscore (ACT) and colGPA
scatter colGPA ACT, scheme(sj)

*(1)Regression WITHOUT control var
reg colGPA hsGPA
/* Result:
1. Coef. 0.4824346: With 1 point increase in hsGPA, ColGPA increases by 0.48 point
2. R-Squared 0.1719: 17% of variance in Y is predictable from variance in X */

*(2)Reg WITH control var
reg colGPA hsGPA ACT
/* Result:
1. Coef. 0.45
2. R-squared: 0.176 & Adjusted R-squared: 0.165
R-squared tend to increase with an addition of new variable. To complement this flaw, adjusted R-squared */ 

*Report result: outreg2
ssc install outreg2

*Save the result in outcome.txt file with MS Word format
outreg2 using outcome.txt, word

*********************
* 1.Example of OLS estimation: Multiple Regression Model
**1-C. Estimate return to education 
*********************
use "C:\Users\jieun\Desktop\STATAforEcon\ch5\labor_supply_female", clear
sum

/*Return to education: Proportion of change in wage per hour with additional 1 year of education 
Note that we focus on wage PER HOUR, not monthly wage or yearly wage. 
Why? Monthly wage = Hourly wage * Hour of labor. 
It indicates that people with longer labor hours can earn high income despite low hourly wage.
In this case, we're not sure whether this high income comes from high education level or long labor hour.
Thus, when we try to estimate return to education, it's appropriate to use wage per hour. */

*Visual check of distribution of one variable: Histogram
*Combine two graphs: graph combine
hist wage, saving(wage, replace)
hist wage_hourly, saving(wage_hourly, replace)
graph combine wage.gph wage_hourly.gph, col(1)
/* Result: The distributions of two var look similar and both are right-skewed */

*Log distribution
hist ln_wage, saving(ln_wage)
hist ln_wage_hourly, saving(ln_wage_hourly)
graph combine ln_wage.gph ln_wage_hourly.gph, col(1)
/* Result: The distributions of two var look like the normal distribution.
::OLS estimates become the most efficient estimates with the samllest variance. */

/*Mincer's earning function: a single-equation model that explains wage income as a function of age, schooling and experience
log(w_i)=Beta_0+Beta_1*age_i+Beta_2*(age_i)^2+Gamma*edu_i+Z'_i*Beta+e_i
Z:individual characteristics, e_i: unobservables */

reg wage age
/* Coef -18.82093: Getting 1 year older results in wage decrease by KRW 180,000
:: Contrary to the common sense */

*age square= c.age#c.age
reg wage age c.age#c.age
/* Result:
1. Age Coef 124.0989: Now getting 1 year older results in wage "increase" by KRW 1,240,000
2. Age^2 Coef -1.65: "MARGINAL" increase in wage of age increase is "DECREASING" 

/ * Create Dummy Variable and Interaction
Prefix a var with "i" for cateogrical var to specify indicators for each level(category) of the var.
Prefix a var with "c" for continuous var to interact CONTINUOUS var with FACTOR var 
Put # between 2 var to create an INTERACTION (indicators for each combination of the categories) 
Put ## to specify a full factorial of the variables(main effects for each variable and an interaction). */

*Categorical survey of education level: w2edu 
tab w2edu

*WAY1. Create new var(educ_year): Year of education
gen educ_year = .
replace educ_year=6 if w2edu=="초등학교"
replace educ_year=9 if w2edu=="중학교"
replace educ_year=12 if w2edu=="고등학교"
replace educ_year=14 if w2edu=="전문대학교"
replace educ_year=16 if w2edu=="대학교"
replace educ_year=18 if w2edu=="대학원 석사"
replace educ_year=20 if w2edu=="대학원 박사" 

*WAY2. 
tab w2edu, gen(edu)

*1. CONTROL "Education Level(Dummy)" (i.w2edu)
reg wage_hourly age c.age#c.age i.w2edu
/* Result: Be careful with INTERPRETATION
1. Elementary Coef. .0619913: "Compared to NO Schooling(e.g. w2edu=0)", wage of elementary school grads is higher by KRW 620.
2. Mid Coef. .1839501: "Compared to no schooling", wage of midschool grads is higher by KRW 1840 */
outreg2 using regression.txt, br replace

*2. CONTROL "Year of Education" (educ_year)
reg wage_hourly age c.age#c.age educ_year
* Coef. .1111097: Additional 1 year of education results in wage increase by KRW 1111.
outreg2 using regression.txt, br append

*3-1. Elasticity: i.w2edu
reg ln_wage_hourly age c.age#c.age i.w2edu
* Result: "Compared to No schooling", wage of elementary grads is higher by 14.2%, mid grad by 33.9%, high grad by 62%
outreg2 using regression.txt, br append

*3-2. Elasticity: educ_year
reg ln_wage_hourly age c.age#c.age educ_year
outreg2 using regression.txt, br append

*4. "Robust" Standard Error 
*vce(robust): Without homoskedasticity or in case we're not sure about the distribution of error term, 
*we can obtain "robust" standard error with the option ,vce(robust)*/
reg ln_wage_hourly age c.age#c.age educ_year, vce(robust)

*vce(cluster varlist): Allow correlation within cluster and indepednece across cluster.
*Within the same area, people can share the labor mkt info.
reg ln_wage_hourly age c.age#c.age educ_year, vce(cluster w2area)

*********************
* Report Result as .dta: regsave
*********************
sysuse census.dta, clear
levelsof region, local(levels)
local i = 1
foreach st of local levels {
	if 'i' == 1{
	local op = "replace"
	}
	else{
		local op = "append"
		}
	reg divorce marriage popurban if region == 'st'
	regsave using results, addlabel(region, 'st') 'op'
	local i = 'i' + 1
	}
	use results, clear
	gen low=coef-2*stderr
	gen high=coef+2*stderr
	two (line coef region if var=="marriage", sort) (rcap high low region if var=="marriage",sort)
	
* Chapter 8. Discrete Response Model
* 15 Oct 2020

*********************
* [1] Types of DRM
*********************
/* 
1.Binary Choice Model: LPM, logit, probit
:Dependent var has the set of 2 choices
e.g. whehter to work or not, whether to receive policy benefit or not etc

2. CM+Continuous Model: tobit, heckit
e.g. whether to smoke or not, how many cigarattes do you smoke? 

3.Multinomial Choice Model: mlogit, clogit, asclogit
e.g. which car brand to buy? BMW, Ford, Audi

4.Count Model: poisson, nbreg
:The number of events e.g. # of hospital visits, # of child 
*/

*********************
* [2] Binary Choice Model
*********************
/*
The basic idea of BCM is to solve the probability that individual chooses 1
1=choice of interest, 0=other choice
::Pr(y=1|x)
Depending on how we set assumptions, we can distinguish LPM, logit, probit model.
*/

*********************
* [2]-1: Linear Probability Model
*********************
/*
Pr(y=1|x)=E[y|x]=B_0+B_1*x
STATA command: regress
It's vital to include vce(robust) due to heteroskedasticity of LPM's variance 

(+): Estimation with regression analysis is possible. Interpretation and application are easy.
(-): Evne though LPM is probability, the probability can <0 or >1 depending on the value of x.
*/

*********************
* [2]-2: Logit or Probit Model
*********************
/*
Pr(y=1|x)=G(x'b)
0<G(u)<1

Logit and Probit Model complement the flaw of LPM which is the prob is not restricted between 0 and 1.
The most significant trait of those models is that they are Single Index Model
1)Logit model: G(') assume "Logistic function"
2)Probit model: G(') assume "Standard normal distribution function"

[Economic Context: Latent variable model]
With latent variable model, we can consider the optimization process of agent.
There is objective function(utility ftn or profit ftn) but its level is not observable, 
which is latent variable. The agent make a choice when this latent varialbe exceeds specific level.

y*= B_0 + x*B - e
y = 1{y*>=0}

Pr(y=1|x) = Pr(y*>=0|x)
          = Pr(B_0+x*B>= e*x)
		  = G(B_0+x*B)
		  
If e has type-1 extreme value distribution, we have logit model.
If e has standard normal distribution, probit model.
For estimation, we use maximum likelihood estimation.
*/

*Example estimation: The impact of education on female participation in labor market
*If w*(reserve wage)<= w(wage in labor market): Choose to work
*age, education, married, child determine wage 

use "C:\Users\jieun\Desktop\STATAforEcon\ch8\women_work", clear
tab participation

***(1)Linear Probability Model
reg participation age education married children, vce(robust)
outreg2 using discrete_1.txt, br replace

*Calculate the probability by "predict"
predict probit_lpm, xb
scatter probit_lpm age, sort ms(Oh) yline(0 1.0, lwidth(thick) lpattern(dash)) 
*The graph shows that we can observe the results below 0 or above 1 

***(2)Logit Model
/*
!Note the differecen in coefficient interpretation between LPM nad LM.
Coefficient of LPM is the marginal effect itself, while that of LM is not.
Thus, we should use "margins" command for LM. 
*/
logit participation age education married children
outreg2 using discrete_1.txt, br append
*Result: Coefficients are different from previous LPM result

margins, dydx(_all)
*Result: Now reults are similar with LPM result

*Graph for marginal effects of each variable
marginsplot

predict prob_logit
scatter prob_logit age, sort ms(Oh)  yline(0 1.0, lwidth(thick) lpattern(dash))
*Result: Now all points are within 0 and 1

***(3)Probit Model
probit participation age education married children
outreg2 using discrete_1.txt, br append

margins, dydx(_all)
marginsplot

predict prob_probit
scatter prob_probit age, sort xlab(,grid) ylab(0(0.3)1.2 1.0,grid ang(h)) ms(Oh)  yline(0 1.0, lwidth(thick) lpattern(dash))

*Combine 3 scatters
scatter  probit_lpm prob_logit prob_probit age, sort scheme(s1color) ms(Oh) yline(0 1.0)

*********************
* [3] Tobit Model
*********************
/*
When dependent var is continous as well as binary, Tobit Model is useful.
y*=B_0+x*B+u (y*: latent variable e.g. utility)
y=max{y*,0}  (If y*=<0, y=0. If y*>0, y=y*)
u|x ~ N(0,sigma^)
*/

use "C:\Users\jieun\Desktop\STATAforEcon\ch8\auto", clear
gen wgt=weight/1000

reg mpg wgt
outreg2 using tobit_1.txt, br replace
 
predict mpg_normal 
twoway (scatter mpg wgt, sort ms(Oh) msize(medium) xla(,grid)) (line mpg_normal wgt,sort lpattern(dash) lcolor(orange)), legend(ring(0) pos(1) col(1))

*Without bottom coding 
replace mpg = 17 if mpg<17
 
reg mpg wgt
outreg2 using tobit_1.txt, br append
 
predict mpg_censored
 
twoway (scatter mpg wgt, sort ms(Oh)  msize(medium) xla(,grid)) (line mpg_censored wgt,sort lpattern(solid) lcolor(orange)) (line mpg_normal wgt,sort lpattern(dash) lcolor(green)), 
legend(label(1 "Data") label(2 "Inconsistent fit") label(3 "True") ring(0) pos(1) col(1)) 

*Tobit with Bottom coding
*11: left-censoring limit, ul: right-censoring limit
tobit mpg wgt,  ll
outreg2 using tobit_1.txt, br append
 
predict mpg_tobit
 
twoway (scatter mpg wgt, sort ms(Oh) msize(medium) xla(,grid)) ///
(line mpg_tobit wgt,sort lpattern(solid) lwidth(thick) lcolor(blue)) ///
(line mpg_normal wgt,sort lpattern(dash)) ///
(line mpg_censored wgt,sort lpattern(longdash)), ///
legend(label(1 "Data") label(2 "Tobit fit") label(3 "True") label(4 "Inconsistent fit") ring(0) pos(1) col(1)) 
*Result: On the Tobit Fit line, the part without bottom coding is closer to the True line. 


*********************
* [4] Heckit Model
*********************
/* Tobit vs Heckit
1)Tobit model: truncated distribution where variables are observable 
2)Heckit model: censored distribution where only some parts of samples are observable with 
missing values.
*/

/* 
Example: Estimate the effect of wage on female labor supply
While wage of workers who participate in labor market is observable,
wage of housewives who don't participate in labor market is unobservable and
their labor hour is measured as 0.
*/

* Heckman's 2 steps estimation
use "C:\Users\jieun\Desktop\STATAforEcon\ch8\heckit", clear
tab participation
*Result: 67% of female participate in labor market.

*Normal regression
gen age_sq = age^2
reg ln_wage education age age_sq
*Result: Additional 1 year education leads to increase in wage by 3.8% 

predict ln_wage_normal
 
twoway (scatter ln_wage age if education == 16, sort ms(Oh)) ///
(line ln_wage_normal age  if education == 16, sort lpattern(solid) lcolor(orange) lwidth(thick)) , ///
legend(label(1 "Data") label(2 "Normal fit") ring(0) pos(5) col(1) )  xla(,grid)

*Heckman's 2-step
**1)Maximum Likelihood Estimation: MLE brings more efficient estimator than 2-step
heckman ln_wage educ age age_sq, select(participation = married children educ age) 
*Result: ROI of education is 4.3% and ROI of age is 0.9%
predict ln_wage_heckman_mle

twoway(scatter ln_wage age if education == 16, sort ms(Oh)) 
(line ln_wage_normal age if education == 16, sort lpattern(solid) lcolor(orange))
(line ln_wage_heckman_mle age if education == 16, sort lpattern(dash) lwidth(thick) lcolor(green)),
legend(label(1 "Data") label(2 "Normal fit") label(3 "Heckman fit(MLE)") ring(0) pos(5) col(1)) xla(,grid)
 
**2)Twostep 
heckman ln_wage educ age age_sq, select(participation = married children educ age) twostep
predict ln_wage_heckman
 
twoway (scatter ln_wage age if education == 16, sort ms(Oh)) ///
(line ln_wage_normal age  if education == 16, sort lpattern(solid) lcolor(orange)) ///
(line ln_wage_heckman age  if education == 16, sort lpattern(dash) lwidth(thick) lcolor(green)) , ///
legend(label(1 "Data") label(2 "Normal fit") label(3 "Heckman fit(2-step)")  ring(0) pos(5) col(1) )  xla(,grid)
 
*Combine OLS, Heckman 2step, Heckman MLE: MLE is closer to OLS line than 2step
twoway (scatter ln_wage age if education == 16, sort ms(Oh)) ///
(line ln_wage_normal age  if education == 16, sort lpattern(solid) lcolor(orange)) ///
(line ln_wage_heckman age  if education == 16, sort lpattern(dash)  lcolor(green)) ///
(line ln_wage_heckman_mle age  if education == 16, sort lpattern(dash) lwidth(thick) lcolor(yellow)) , ///
legend(label(1 "Data") label(2 "Normal fit") label(3 "Heckman fit(2-step)") label(4 "Heckman fit(MLE)")  ring(0) pos(5) col(1) size(small) )  xla(,grid)
 
* Chapter 7. Instrumental Variable
* 7 Oct 2020

*********************
* [1&2] Endogeneity and Instrumental Variable
*********************
/* Burden of proof
Researchers need to prove exogeneity of independent variables or covariates.
::Why endogeneity occurs? Which factor in error terms cause endogeneity? */

/* Exogeneity/Orthogonality/Identification condition
E[x*u]=0 where x: explanatory var, u: error term 
*/

/* Bias challenges arise from Endogeneity
1. Simultaneous equation system
2. Measurement error
3. Sample selection problem
4. Omitted variable problem
5. Reverse causality 
*/

/* Validity conditions for IV
1. Relevance: Corr(X,Z)=/=0. 
2. Exogeneity: Corr(U,Z)=0. Z can determine X exogeneously as good as random.
3. Exclusive Restriction: Z can affect Y only through X.
*/

*********************
* [3&4] TSLS and ivgress
*********************
/* Two stage least square model
*structural equation: it directly speaks the research question
*1st stage: Decompse X into the component that can be predicted by Z and problematic component
*2nd stage: Use the predicted value of X(X hat) to estimate its effect on Y   
*reduced form: Estimate the effect of Z on Y

Identification condition: The number of IV should be equal to or larger than that of explanatory var4
::sufficient condition, rank condition.
*/

use "C:\Users\jieun\Desktop\STATAforEcon\ch7\mroz", clear

keep if lfp
sum wage educ exper

gen lwage=ln(wage)
gen exper_sq=exper^2

reg lwage edu exper exper_sq
*Result: Additional 1 year education leads to 10% increase in wage

*Save the result 
estimates store ls

*However, there's a possibility that educ is endogenous var
*There might be omitted variables such as ability 
*[Solution]IV estimation: Use mother or father education as IV

*Correlation btw worker's educ and parents' educ
reg educ exper exper_sq mothereduc fathereduc
*Result: The more educated mother and father are, the longer education worker has

*2SLS Estimation: Use mothereduc and fathereduc as IV
ivregress 2sls lwage (educ = mothereduc fathereduc) exper exper_sq, vce(robust)
*Result: Additional 1 year education leads to 6.13% increase in wage, which is samller increment than OLS.
*:: As expected, OLS overestimates return of education.

*********************
* [5] Testing for endogeneity (Hausman-test)
*********************
/*Idea: If predictory varaible(regressor) is exogenous, OLS estimator should be consistent.
The test evaluates the "consistency" of an estimator when compared to an alternative,
which is less efficient estimator which is already known to be consistent.

Test results: If the p-value is small(less than 0.05), reject the null hypothesis.
The Hausman test can be used to differentiate between fixed effects model and random effects model in panel analysis. 
In this case, Random effects (RE) is preferred under the null hypothesis due to higher efficiency, 
while under the alternative Fixed effects (FE) is at least as consistent and thus preferred.

Essentially, the test looks to see if there is a correlation between the errors and regressors in the model.
The null hypothesis is that there is no correlation between the two.
---------------------------------------------------------
                   |        H_0 True      | H_1 is True
---------------------------------------------------------
Beta1(RE estimator)|Consistent&Efficient  | Inconsistent
---------------------------------------------------------
Beta0(FE estimator)|Consistent&Inefficient|  Consistent
---------------------------------------------------------- */

reg lwage edu exper exper_sq
estimates store ls

ivregress 2sls lwage (educ = mothereduc fathereduc) exper exper_sq
estimates store iv

hausman iv ls, constant sigmamore
*Result: The null hypothesis can be rejected around at 10% significance level.

*Test of over-identifying restriction(과도식별) 
estat overid
*Result: As p>0.05, we cannot reject the null hypothesis. Our IV is not over-identification.

* Chapter 6. Time series
* 6 Oct 2020

*********************
* 1.Time series data
*********************
/*Time series data
1. has tempora ordering
2. NO stochastic independence between observations
:: by using past data, present or future values are predictible.
*/

*********************
* 1-A.Example: Estimation of Philips curve 
*********************
*Philips curve indicates negative relationship between unemployment rate and price level.
*For low unemployment rate, the economy has to cost high price level and for low price level, vice versa.

*inf_t=Beta_0+Beta_1*unem_t+u_t
use "C:\Users\jieun\Desktop\STATAforEcon\ch6\phillips", clear
tsset year

*check variables
list
*unem_1, inf_1: unemployment rate and inflation rate "1 year ago"
*cunem, cinf: change rate (unem-unem_1 , inf-inf_1)

*check visual correlation 
scatter inf unem
twoway(scatter inf unem) (lfit inf unem)
*Unexpected result: The graph shows the "positive" correlation btw inf and unem

reg inf unem
*coef .5023: With 1%p increase in unemployment rate, inflation increases by 0.5%p.
/*Why unexpected result?
1. We need more CONTROL variables by using multiple regression 
2. Stagflation by oilshock in data after 1970s */

*********************
* 2. Finite distributed lag models
*********************
/* FDL explains the current and delayed effects of an independent{X_t} series on a dependent {Y_t} series.
Ex) The effect of policy variable z on y
    y_t=alpha_0+delta_0*z_t+delta_1*z_t-1+delta_2*z_t-2+u_t
    where z_t is contemporaneous var, z_t-1: after 1 period, z_t-2: after 2 period 
*Interpretation:
1. deltas: short effects called impact propensity or impact multiplier
2. SUM of dletas: long-run propensity or long-run multiplier
3. Elasticity with log-variable model
Ex) log(M_t)=alpha_0+delta_0*log(GDP_t)+delta_1*log(GDP_t-1)
:: 1% increase in GDP results in delta_0% change in monetary amount in the same period,
   as well as(delta_0+dleta_1)% long-run change.*/ 

*********************
* 2-A.Example: Effect of personal exemption on birth
*********************
*model: gfr_t=Beta_0+Beta_1*pe_t+Beta_2*pe_t-1+Beta_3*pe_t-2+Beta_4*ww2_t+Beta_5*pill_t+u_t

use "C:\Users\jieun\Desktop\STATAforEcon\ch6\fertil3", clear
*check data characteristics
sum

*Visual trend check
scatter gfr year, sort scheme(economist)
scatter pe year, sort scheme(s2mono)
*we checked there is similarity between the birth trend and the exemption benefit trend.

*[1] Basic regression and save the result
reg gfr pe
outreg2 using fertility, replace

*[2] Add control: ww2 and birth control 
reg gfr pe ww2 pill
outreg2 using fertility, word append


*[3] Add lagged variables : L.pe L2.pe
*tsset: Declare data to be time-series data
/*makes it easy to create various time-series variable
::L.* for 1st perid, L2.* for 2nd period*/
tsset year
reg gfr pe L.pe L2.pe ww2 pill
outreg2 using fertility, word append
/* Result: 
1.Statistically insignificat as t-values of lagged variables < 2
[Multicollinearity] This is because lagged variables are similar to each other.
As birth rate is explained by similar variables, explanation for marginal change is difficult.
2. However, they still have explanation power supported by the result of F-test
3. long-run propensity: 0.07-0.005+0.033=0.1 */

/* F-test
To test if coefficient is zero or not. Test statistic follow F-distribution.
To test linear combination: lincom, non-linear: nlcom */
test pe=0
test L1.pe=0, accumulate
test L2.pe=0, accumulate
*The result shows that pe-related lagged variables are still valid.

**//Long-run effect//**
*1. nlcom: Check statistical significance of estimated long-run propensity
nlcom _b[pe]+_b[L.pe]+_b[L2.pe]
*long-run propensity = 0.1007191 with t=3.38(>2)

/*2. re-parametrization
Let Detla=Beta_1+Beta_2+Beta_3
gfr_t=B_0+Delta_0*pe_t+B_2*(pe_t-1 - pe_t)+B_3*(pe_t-2 - pe_t)+B_4*ww2_t+B_5*pill_t+u_t*/
gen d_pe_1=L.pe-pe
gen d_pe_2=L1.pe-pe

*[4] Long-run effect after re-parametrization
reg gfr pe d_pe_1 d_pe_2 ww2 pill
outreg2 using fertility, word append
*Result: the size of long-rune effect is 0.1 as expected and also statistically significant(t=3.04)
*$10 increase in personal exemption leads to 1 child per 1,000 fertile women

*********************
* 2-2.Example: Effect of anti-dumping sue on import
*********************

use "C:\Users\jieun\Desktop\STATAforEcon\ch6\BARIUM", clear
list
sum
*main var: chnimp (import from China), befile6(6 months before file), affile6(6 months after file), afdec6(6 months after win)

*Graph time trend of chnimp 
*lpoly: local polynomial estimation. Bring more general estimation result than 'lfit' 
twoway(scatter chnimp t, sort) (lpoly chnimp t, sort), scheme(s2mono)

*Take log on var except dummies for ELASTICITY
reg lchnimp lchempi lgas lrtwex befile6 affile6 afdec6
/* Result
1. Coef. befile6( .0595739 ): "Compared to other periods", imports are higher by 5.96%
2. afdec6 -.565245: Compared to other periods, Imports decrease by 56.52% 6 months after winning. */

*********************
* 3.Trends
*********************
/* Two types of trends
1. Linear trend model: variable grows by constant "amount"  
2. Exponential trend model: variable with constant growth "rate" 
*/

/* Spurious regression problem
Even though there is no correlation between two variables, 
if both variables have time trend, there's a possibility that the estimation result shows
correlation between those two.
**[Solution] Add one of those time trend variables as explanatory variable. */

use "C:\Users\jieun\Desktop\STATAforEcon\ch6\trend", clear
scatter y1 x1, scheme(sj)
*Let's assume that r.v. x1 and r.v. y1 are independent. 
*The scatter graph shows no correlation btw two variables.

reg y1 x1
*As expected, x1 doesn't have impact on y1 (t=-0.91, p-value=0.364)

*Add "Time trend" 
gen x = x1 + t
gen y = y1 + t + t^2

scatter y x, scheme(sj)
*Result: Despite no actual correlation, the graph appears that two vars are correlated

reg y x
*New result is statistically significant. x has a significant impact on y. 
*This result doesn't come from the correlation btw x and y, but by "time trend" x and y share together.

*Add "t"(time trend var) as explanatory var
reg y x t
*No more statistical significance 

*Add t^2
reg y x t c.t#c.t
*The result is close to that of y1 and x1 regression analysis.
*[Conclusion] For time-series analysis, include time trend variable.





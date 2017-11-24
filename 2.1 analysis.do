
////////////////////PREPARE DATA: INCLUDE ONLY TWO WAVE RESPONDENTS

use "$data\indivwave", clear
keep if wave==1
tab format
drop  if format==2							//delete imany cases
drop if formats==12 |formats==32			//delete cases which will be assigned to I many in wave 2

tab format
tab formats, mis
//drop if a filter was not answered
drop if filter1==.|filter2==.|filter3==.|filter4==.|filter5==.|filter6==.| ///
	filter7==.|filter8==.|filter9==.|filter10==.|filter11==.|filter12==.|filter13==.
//get indicators for missing follow-ups
forvalues x=1/2 {
	forvalues y==1/13 {
		tab format if filter`y'==1&fu`y'_`x'==.
		gen drop`x'`y' =1 if filter`y'==1&fu`y'_`x'==.
	}
}
gen incom_w1=.
forvalues x=11/19 {
replace incom_w1 =1 if drop`x'==1
}
forvalues x=110/113 {
replace incom_w1 =1 if drop`x'==1
}
forvalues x=21/29 {
replace incom_w1 =1 if drop`x'==1
}
forvalues x=211/213 {
replace incom_w1 =1 if drop`x'==1
}
drop drop*
tab format					// Number of wave 1 respondents (irrespective of wave 2 response)
//minus one incomplete wave one follow_ups
tab formats, mis
tab waves
tab incom

tab waves
gen w1_only =1 if waves==1
replace w1_only=0 if waves==2
tempfile WAVE1
save `WAVE1', replace

use "$data\indivwave", clear
keep if wave==2
//drop imany cases
drop if formats==21 | formats==22| formats==23
drop if format==2

gen 		w2_only=1 if waves==3
recode 		w2_only (.=0)
label var w2_only "Wave 2 response only"
tab w2_only
//drop if a filter was not answered
drop if filter1==.|filter2==.|filter3==.|filter4==.|filter5==.|filter6==.| ///
	filter7==.|filter8==.|filter9==.|filter10==.|filter11==.|filter12==.|filter13==.

tab w2_only
forvalues x=1/2 {
	forvalues y==1/13 {
		tab format if filter`y'==1&fu`y'_`x'==.
		gen drop`x'`y' =1  if filter`y'==1&fu`y'_`x'==.
	}
}
//get indicators for missing follow-ups
gen incom_w2=.
forvalues x=11/19 {
replace incom_w2 =1 if drop`x'==1
}
forvalues x=110/113 {
replace incom_w2 =1 if drop`x'==1
}
forvalues x=21/29 {
replace incom_w2 =1 if drop`x'==1
}
forvalues x=211/213 {
replace incom_w2 =1 if drop`x'==1
}
drop drop*
tab formats		//two incompletes (1 w1 and 1 w2) will be dropped
append using `WAVE1'

bysort id: egen maxInc2 = max(incom_w2)
bysort id : replace incom_w2 =maxInc2
bysort id: egen maxInc1 = max(incom_w1)
bysort id : replace incom_w1 =maxInc1	
drop maxIn*
//drop if there were missing follow-ups	
drop if incom_w1==1 | incom_w2==1	

//differences in socio demographic information among w1 respondents
preserve
	keep if wave==1
	do "$code/2.3.1_2 previous answering behavior.do"
	//merge in information on response behavior in previous ten waves (comes from Jess work)
	merge m:1 id using "$data/previous_w_response", keep(match) nogen
	//nonresponse in wave one and sociodem.: No significant differences
	keep geslacht positie gebjaar leeftijd lftdcat lftdhhh aantalhh ///
	aantalki partner burgstat woonvorm woning sted belbezig brutoink 		///
	brutoink_f nettoink netinc nettoink_f brutocat nettocat brutohh_f ///
	nettohh_f oplzon oplmet OPLCAT resp_beh format
	reg format i.geslacht i.partner leeftijd aantalhh aantalki i.burgstat ///
	i.woonvorm i.woning i.sted i.OPLCAT resp_beh
restore	
preserve
//////////////////ATTRITION ANALYSIS
	gen attrition = 1 if w1_only==1
	recode attrition (.=0)
	do "$code/2.3.1_2 previous answering behavior.do"
	//merge in information on response behavior in previous ten waves (comes from Jess work)
	merge m:1 id using "$data/previous_w_response", keep(3) nogen
	drop if w2_only==1
	keep if wave==1
	//attrition unrelated to w1 format
	reg attrit i.format
	//attrition unrelated to number of filters triggered in w1
	egen t_filter=rowtotal(filter1 filter2 filter3 filter4 filter5 filter6 filter7 filter8 filter9 filter10 filter11 filter12 filter13)
	reg attrit t_filter
	reg attrit i.format t_filter
	//TABLE 3
	reg attrit i.format##c.t_filter
	//attrition and sociodem.: attriters are about 7.5 years younger, no other differences
	keep attrit geslacht positie gebjaar leeftijd lftdcat lftdhhh aantalhh ///
	aantalki partner burgstat woonvorm woning sted belbezig brutoink 		///
	brutoink_f nettoink netinc nettoink_f brutocat nettocat brutohh_f ///
	nettohh_f oplzon oplmet OPLCAT resp_beh format
	reg attrit i.geslacht i.partner leeftijd aantalhh aantalki i.burgstat ///
	i.woonvorm i.woning i.sted i.OPLCAT resp_beh i.format
	reg leeft attrit
	reg attrit leeft
restore	
	
drop if w1_only==1 | w2_only==1		//drop if wave one or wave two response only

tab format wave

	
///assignment to wave two format still random given our analysis sample?

preserve
	egen t_filter=rowtotal(filter1 filter2 filter3 filter4 filter5 filter6 filter7 filter8 filter9 filter10 filter11 filter12 filter13) if wave==1
	bysort id: egen t_w1_filter=max(t_filter)
	drop t_filter
	keep if wave==2
	tab format
	do "$code/2.3.1_2 previous answering behavior.do"
	//merge in information on response behavior in previous ten waves (comes from Jess work)
	merge m:1 id using "$data/previous_w_response"
	keep if _m==3
	drop _m

	reg format t_w1_filter i.geslacht i.partner leeftijd aantalhh aantalki i.burgstat ///
	i.woonvorm i.woning i.sted i.OPLCAT resp_beh 
restore

gen minutes=duur/60
sum minutes if wave==1, det
sum minutes if wave==2, det
reg minutes i.format
reg minutes i.wave

tab ptag
//save IDs and merge to itemlvl dataset to tag one obs per respondent (only those
//identified as two wave respondents above
keep if ptag==1
keep id

tempfile A
save `A', replace

use "$data\item_lvl", clear
merge m:1 id using `A', keep(3) nogen 
tab rtag
svyset id

save "$data\dat_condit_final", replace

********************************************************************************
*************************BEGIN OF ANALYSIS (PAPER)******************************
********************************************************************************

//Response rate significance calculations for Table 2
	//Table 2 - wave one
	clear
	set obs 1
	gen N1 = 1650		//brutto size of interleafed group
	gen N2 = 1650		//brutto size of grouped group

	gen n1 = 1303		//netto size of interleafed group
	gen n2 = 1337		//netto size of grouped group

	gen p1 = n1/N1		//response rate interleafed
	sum p1
	gen p2 = n2/N2		//response reate grouped
	sum p2
	di (n1+n2)/(N1+N2)	//overall response rate
	gen p = (p1*N1 + p2*N2)/(N1+N2)
	gen se = sqrt(	p*(1-p)	*	((1/N1)+(1/N2))		)
	gen z = (p1-p2)/se
	sum z
	gen pvalue=2*(1-normal(abs(z))) 
	sum pvalue	
	
	//Table 2 - wave two
	clear
	set obs 1
	gen N1 = 1320		//wave one response interleafed
	gen N2 = 1320		//wave one response grouped

	gen n1 = 1080		//wave two response conditional on w1 response
	gen n2 = 1082		//wave two response conditional on w1 response

	gen p1 = n1/N1
	gen p2 = n2/N2
	sum p1 p2
	di (n1+n2)/(N1+N2)	//overall response rate conditional on w1 response


	gen p = (p1*N1 + p2*N2)/(N1+N2)
	gen se = sqrt(	p*(1-p)	*	((1/N1)+(1/N2))		)
	gen z = (p1-p2)/se
	sum z
	gen pvalue=2*(1-normal(abs(z))) 
	sum pvalue

clear all
use "$data\dat_condit_final", replace
tab wave formats
///descriptives of filters
			keep if wave==1
			bysort id: egen t_filter1=total(filter)
			bysort id: keep if _n==1
			tab t_f
			keep t_f id
			hist t_f, scheme(s1mono) xtitle("Wave one") ytitle("Frequency") ///
			xlab(0(2)13) name(wave1) freq  d
			save "$data/person_lvl1", replace
use "$data\dat_condit_final", replace
			keep if wave==2
			bysort id: egen t_filter2=total(filter)
			bysort id: keep if _n==1
			tab t_f
			keep t_f id
			hist t_f, scheme(s1mono) xtitle("Wave two") ytitle("") ///
			xlab(0(2)13) name(wave2) freq d ylabel(none) aspect(1.6, placement(left))
			save "$data/person_lvl2", replace
			graph combine wave1 wave2, ycomm
			
			
use "$data\dat_condit_final", replace
tab wave formats
//TABLE 4 
	keep if wave==1
	svy: mean filter
	svy: reg filter i.format
	svy: mean filter, over(format)
	test _subpop_1=grouped
	preserve
		bysort id: gen X=1 if _n==1
		tab X format
	restore
	//position of filter - SC increases with the position of a filter 
	//RESULTS NOT SHOWN IN PAPER
	svy: reg filter ib2.third if format==1
	svy: reg filter ib2.third if format==3
	
	svy: reg filter i.format##i.third
	svy: reg filter i.format##i.third i.order
	
	svy: mean filter, over(format third)
//TABLE 5
use "$data\dat_condit_final", replace
//Number of observations
preserve
	bysort id: gen X=1 if _n==1
	tab X format
	bysort id: keep if _n==1
	tab wave formats
restore

//everything else of table 5	
svy: mean filter, over(formats wave)
test _subpop_1==_subpop_2
test _subpop_3==_subpop_4
test _subpop_5==_subpop_6
test _subpop_7==_subpop_8
//format change over (changed format panel conditioning) is
//is same as wave one survey conditioning effect
test _subpop_3-_subpop_4== _subpop_6-_subpop_5

//SAME RESULTS WITHOUT THOSE PEOPLE WHO DIDNT TRIGGER A SINGLE FU IN WAVE ONE?
merge m:1 id using "$data/person_lvl1", nogen
merge m:1 id using "$data/person_lvl2", nogen
keep if t_filter1!=0
svy: mean filter, over(formats wave)
test _subpop_1==_subpop_2
test _subpop_3==_subpop_4
test _subpop_5==_subpop_6
test _subpop_7==_subpop_8
//format change over (changed format panel conditioning) is
//is same as wave one survey conditioning effect
test _subpop_3-_subpop_4== _subpop_6-_subpop_5

//YES!

//subgroup analysis: age? education?

use "$data\indivwave", clear
bysort id: keep if _n==1
keep gebjaar OPLCAT id
merge 1:m id using "$data\dat_condit_final", keep(match) nogen

svyset id
svy: reg filter c.OPLCAT##i.wave
margins ,dydx(wave)

//No dependence of conditioning effect on education
svy: reg filter wave if OPLCAT==1
svy: reg filter wave if OPLCAT==2
svy: reg filter wave if OPLCAT==3
svy: reg filter wave if OPLCAT==4
svy: reg filter wave if OPLCAT==5
svy: reg filter wave if OPLCAT==6

keep if wave==1
svy: reg filter i.format if OPLCAT==1
svy: reg filter i.format if OPLCAT==2
svy: reg filter i.format if OPLCAT==3
svy: reg filter i.format if OPLCAT==4
svy: reg filter i.format if OPLCAT==5
svy: reg filter i.format if OPLCAT==6

keep if wave==1
svy: reg filter i.OPLCAT

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
***************************END OF PAPER*****************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*****

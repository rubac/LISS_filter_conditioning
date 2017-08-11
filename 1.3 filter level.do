* transform dataset to filter level
* separately by wave

************************************************
* wave 1

use "$data\indivwave", clear
keep if wave==1

keep filter? filter?? id format order wave formats w?format

reshape long filter, i(id) j(item)

gen qorder = item if order==1
replace qorder = 14-item if order==2
lab var qorder "order of filters presented to R"
lab var item "filter q number, 1 - 13"
lab var filter "indiv. filter YesNo"


save "$data\w1item", replace


************************************************
* wave 2

use "$data\indivwave", clear
keep if wave==2

keep filter? filter?? id format order wave formats w?format

reshape long filter, i(id) j(item)

gen qorder = item if order==1
replace qorder = 14-item if order==2
lab var qorder "order of filters are presented to R"
lab var item "filter q number, 1 - 13"
lab var filter "indiv. filter YesNo"

save "$data\w2item", replace



************************************************
* put together

use "$data\w2item", replace
append using "$data\w1item"

gen w1grouped = (w1format==3)
gen w2grouped = (w2format==3)
gen sameformat3 = (w1format==w2format)
//EDIT RUBEN: SET SAMEFORMAT TO MISSING if r didnt partic in both waves
recode sameformat3 (0=.) if w1format==. | w2format==.
gen sameformat2 = (w1grouped==w2grouped)
//EDIT RUBEN: SET SAMEFORMAT TO MISSING if r didnt partic in both waves
recode sameformat2 (0=.) if w1format==. | w2format==.

tab2 formats sameformat?, firstonly

lab var w1grouped "grouped format in w1"
lab var w2grouped "grouped format in w2"
lab var sameformat3 "exact same format in w1&w2"
lab var sameformat2 "same format in w1&w2_IvsG only"

* var showing whether q asked in 1st, 2nd or 3rd third of filters
gen third = 1 if qorder < 4
replace third = 3 if qorder > 9
replace third = 2 if mi(third)
lab var third "item asked in first, second, third third of filters"


lab def items 1 "coffee" 2 "beer or wine" 3 "tobacco" ///
	4 "children's clothes" 5 "own clothes" 6 "chocolate" ///
	7 "medication" 8 "flowers" 9 "pet supplies" 10 "DVD VHS" ///
	11 "Music" 12 "ticket" 13 "cleaning supplies"
	
lab def orders 13 "coffee" 12 "beer or wine" 11 "tobacco" ///
	10 "children's clothes" 9 "own clothes" 8 "chocolate" ///
	7 "medication" 6 "flowers" 5 "pet supplies" 4 "DVD VHS" ///
	3 "Music" 2 "ticket" 1 "cleaning supplies"

lab val item items
lab val qorder orders

egen rtag = tag(id)
lab var rtag "tag one obs per respondent"

sort id wave
svyset id
qui: compress
save "$data\item_lvl", replace


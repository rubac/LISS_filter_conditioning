clear all
*do "$code\1.1 read SPSS.do"

use "$data\w2", clear 
append using "$data\w1"

qui: do "$code\1.2 var cleanup.do"

codebook, problems

capture log close
*log using "$results\codebook_$date.smcl", replace
*codebook
capture log close

compress
save "$data\indivwave", replace

use "$data\indivwave", clear
keep id wave format

reshape wide format , i(id) j(wave)
rename format1 w1format
rename format2 w2format


* look at formats in each wave
gen formats = .
forv w1 = 1/3 {
	forv w2 = 1/3 {
		replace formats = `w1'`w2' if w1format==`w1' & w2format==`w2' & ///
			!mi(w1format) & !mi(w2format)
	}
}

tab formats
lab def FORMATS 11"I few - I few" 12"I few - I many" 13"I few - Group" 21"I many - I few" 22"I many - I many" 23"I many - Group" 31"Group - I few" 32"Group - I many" 33"Group - Group"
lab val formats FORMATS


lab var w1format "wave 1 format for this R, indiv level"
lab var w2format "wave 2 format for this R, indiv level"
lab var formats "formats in both waves, indiv level"

keep id formats w?format
sort id
tempfile f
save `f'

use "$data\indivwave", replace
capture drop _merge
sort id
merge id using `f'
capture drop _merge
save "$data\indivwave", replace

do "$code\1.3 filter level.do"

exit

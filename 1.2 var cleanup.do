*global missings .a "DK" .b "refused" .c "filter skip NO" ///
*	.d "filter skip MI" .e  "format"

*create easier ID at person level
*sort nomem nohouse wave
*egen id = group(nomem nohouse)

//There are two obs with hhID changes and above code does not account for that
//nomemencr is perfect id, no changes needed
egen id = group(nomem)

/*
preserve
		bysort id: gen Xid=_n
		bysort nomem: gen Xnomem=_n
		bysort nohouse: gen Xnohouse=_n
		gen IDmistake =1 if Xid==1&Xnomem==2
		keep if Xid==1
		keep nomem id
		save "$data\nomemXid", replace
restore
*/

* tag one obs per person
egen ptag = tag(id)
lab var ptag "for indiv level analysis in indiv-wave dataset"

* count waves per person
egen mw = mean(wave), by(id)
tab mw
tab mw if ptag

* 6231 uniq people
* 740 wave 1 only, 482 wave 2 only
* 5,009 in both waves

gen waves = 1 if mw==1
replace waves = 3 if mw==2
replace waves = 2 if mw==1.5
lab var waves "waves case particpated in"
lab def waves 1 "wave 1 only" 2 "both waves" 3 "wave 2 only"
lab val waves waves
lab var wave "responses in wave 1 or 2?"
lab var id "unique case id"
drop mw


lab def euros $missings
label define noyes 0 "no" 1 "yes" $missings
lab def fu2 1 "this week" 2 "1 week ago" 3 "2 weeks ago" ///
	4 "3 weeks ago" 5 "4 weeks ago" 6 "5 or more weeks ago" $missings
lab def fu45 1 "very satisfied" 5 "very unsatisfied" $missings
lab def fu6 1 "impulse purchase" 2 "planned purchase" $missings

* do these labels before renaming below
label variable Tijdintro "time intro"
label variable vinter_1__vfilt "In the past month, have you purchased coffee for consumption at home?"
label variable vinter_2__vfilt "In the past month, have you purchased beer or wine for consumption at home?"
label variable vinter_3__vfilt "In the past month, have you purchased tobacco?"
label variable vinter_4__vfilt "In the past month, have you purchased children's clothing or shoes?"
label variable vinter_5__vfilt "In the past month, have you purchased clothing or shoes for yourself?"
label variable vinter_6__vfilt "In the past month, have you purchased chocolate?"
label variable vinter_7__vfilt "In the past month, have you purchased medication?"
label variable vinter_8__vfilt "In the past month, have you purchased flowers?"
label variable vinter_9__vfilt "In the past month, have you purchased pet supplies?"
label variable vinter_10__vfilt "In the past month, have you purchased movies on DVD or VHS?"
label variable vinter_11__vfilt "In the past month, have you purchased music on CD or as MP3s (or other digital formats)?"
label variable vinter_12__vfilt "In the past month, have you purchased a ticket for a concert, theatre performance or a movie?"
label variable vinter_13__vfilt "In the past month, have you purchased any cleaning supplies for your home?"

rename Tijdgroup filter_group_time
rename arandom format
rename brandom order
rename maandnr month
rename nohouse_encr  hhid
rename nomem_encr personid

label variable personid "person id within HH"
label variable hhid "HH id"
label variable month "Year and month of fieldwork period"
label variable format "Filter question format"
label variable order "Order of filter questions"


forv i = 1/13 {
	label variable vinter_`i'__vfollow1 "Product costs in euros"
	label variable vinter_`i'__vfollow2 "How many weeks ago did you make this purchase?"
	label variable vinter_`i'__vfollow3 "Have you ever purchased such products online?"
	label variable vinter_`i'__vfollow4 "How satisfied are you with the quality of this product?"
	label variable vinter_`i'__vfollow5 "How satisfied are you today with the price you paid for this product?"
	label variable vinter_`i'__vfollow6 "Was this an impulse purchase or was it a planned purchase?" 
	label variable vinter_`i'__tijdvfilt "time filter question `i'"
	label variable vinter_`i'__tijdvfollow1 "time follow-up 1, filter `i'"
	label variable vinter_`i'__tijdvfollow2 "time follow-up 2, filter `i'"
	label variable vinter_`i'__tijdvfollow3 "time follow-up 3, filter `i'"
	label variable vinter_`i'__tijdvfollow4 "time follow-up 4, filter `i'"
	label variable vinter_`i'__tijdvfollow5 "time follow-up 5, filter `i'"
	label variable vinter_`i'__tijdvfollow6 "time follow-up 6, filter `i'"

	rename vinter_`i'__vfilt filter`i' 
	rename vinter_`i'__vfollow1 fu`i'_1
	rename vinter_`i'__vfollow2 fu`i'_2
	rename vinter_`i'__vfollow3 fu`i'_3
	rename vinter_`i'__vfollow4 fu`i'_4
	rename vinter_`i'__vfollow5 fu`i'_5
	rename vinter_`i'__vfollow6 fu`i'_6
	rename vinter_`i'__tijdvfilt filter`i'time
	rename vinter_`i'__tijdvfollow1 fu`i'_1t
	rename vinter_`i'__tijdvfollow2 fu`i'_2t
	rename vinter_`i'__tijdvfollow3 fu`i'_3t
	rename vinter_`i'__tijdvfollow4 fu`i'_4t
	rename vinter_`i'__tijdvfollow5 fu`i'_5t
	rename vinter_`i'__tijdvfollow6 fu`i'_6t	
	
	* move grouped filter responses to the same var as interleafed
	replace filter`i' = vgroupt`i' if format==3
	
	* move grouped follow up responses to the same var as interleafed
	replace fu`i'_1 = vgroup_`i'__vfollow1 if format==3
	replace fu`i'_2 = vgroup_`i'__vfollow2 if format==3
	replace fu`i'_1t = vgroup_`i'__tijdvfollow1 if format==3
	replace fu`i'_2t = vgroup_`i'__tijdvfollow2 if format==3

	
	recode filter`i' (2=0)
	label value filter`i' noyes
		
	* fill in missing values due to filter skips
	forv u = 1/6 {
		* .c means missing because filter was no
		replace fu`i'_`u' = .c if mi(fu`i'_`u') & filter`i'==0
		replace fu`i'_`u' = .d if mi(fu`i'_`u') & mi(filter`i')
	}
	forv u = 3/6 {
		* follow ups 3 - 6 not asked in these formats
		replace fu`i'_`u' = .e if inlist(format,1,3)
	}
	
	* recode yes no follow up
	recode fu`i'_3 (2=0)
		
	mvdecode fu`i'_2, mv(7=.a \ 8=.b)
	mvdecode fu`i'_3, mv(3=.a \ 4=.b)
	mvdecode fu`i'_4, mv(6=.a \ 7=.b)
	mvdecode fu`i'_5, mv(6=.a \ 7=.b)
	mvdecode fu`i'_6, mv(3=.a \ 4=.b)
	
	lab val fu`i'_1 euros
	lab val fu`i'_2 fu2
	lab val fu`i'_3 noyes
	lab val fu`i'_4 fu45
	lab val fu`i'_5 fu45
	lab val fu`i'_6 fu6
}

lab def order 1 "forwards order" 2 "backwards order"
lab val order order

mvdecode *ink netinc, mv(-13=.a \ -14=.b)
lab def income $missings
lab val *ink netinc income


* these vars all missing
drop evaopm EVAOP0 EVAOP1 EVAOP2 EVAOP3 EVAOP4 DatumB DatumE

* drop vars containing only grouped responses
capture drop vgroup_* vgroupt*

gen t_all_m = duur/60

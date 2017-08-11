preserve
			clear all

			use "$data\from JESS thesis\avars_201204_EN_2.0p.dta", clear
			* Dataset from: http://www.lissdata.nl/dataarchive/study_units/view/322

			gen _merge_april_wave=3 // indicator for took part in april 

			summarize // check descriptive statistics
			describe, short

			* Mergen Jul 2011
			merge 1:1 nomem_encr using "$data\from JESS thesis\avars_201107_EN_2.0p.dta", generate(_mergeJul)
			describe, short

			* Mergen Aug 
			merge 1:1 nomem_encr using "$data\from JESS thesis\avars_201108_EN_2.0p.dta", generate(_mergeAug)

			describe, short

			* Mergen Sept 
			merge 1:1 nomem_encr using "$data\from JESS thesis\avars_201109_EN_2.0p.dta", generate(_mergeSep)
			describe, short

			* Mergen Okt
			 merge 1:1 nomem_encr using "$data\from JESS thesis\avars_201110_EN_2.0p.dta", generate(_mergeOct)

			* Mergen Nov 
			merge 1:1 nomem_encr using "$data\from JESS thesis\avars_201111_EN_2.0p.dta", generate(_mergeNov)

			* Mergen Dez 
			merge 1:1 nomem_encr using "$data\from JESS thesis\avars_201112_EN_2.0p.dta", generate(_mergeDec)

			* Mergen Jan
			merge 1:1 nomem_encr using "$data\from JESS thesis\avars_201201_EN_2.0p.dta", generate(_mergeJan)

			* Mergen Februar 
			merge 1:1 nomem_encr using "$data\from JESS thesis\avars_201202_EN_2.0p.dta", generate(_mergeFeb)

			* Mergen März
			merge 1:1 nomem_encr using "$data\from JESS thesis\avars_201203_EN_2.0p.dta", generate(_mergeMar)

			** Counting response in the previous waves  

			egen resp_behavior = anycount(_merge*), values(3)
			tab resp_behavior 

			describe, short	 
			tab resp_behavior

			//merge in our ID
			merge 1:1 nomem_encr using "$data/nomemXid"

			//keep only variable containing previous response behavior
			keep id resp_* 
			keep if id!=.

			save "$data\previous_w_response.dta", replace

restore

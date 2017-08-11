set more off, perm
clear all
adopath + "Z:\bach\ado"

global date 20160121
global dir "Z:\bach\LISS conditioning\analysis\"
global missings .a "DK" .b "refused" .c "filter skip NO" ///
	.d "filter skip MI" .e  "format"
do "$dir\code\0 definitions.do"

do "$code\1 data prep.do"
do "$code\2.1 analysis.do"

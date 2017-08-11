set more off
clear all

usespss using "$data\L_FilterQ_wave1_7p.sav"
gen wave = 1
save "$data\w1", replace

usespss using "$data\L_FilterQ_wave2_7p.sav"
gen wave = 2
save "$data\w2", replace

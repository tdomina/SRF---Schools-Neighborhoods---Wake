set trace off
set more off
clear


use "C:\Users\JaysC\Dropbox\Documents\nodes_2000_2014.dta", clear

destring yr, gen(year)
destring nodeid, gen(node_num)

egen obs = group(nodeid)

local sch_elem "sch_basek1 sch_base01 sch_base02 sch_base03 sch_base04 sch_base05"
local sch_mid "sch_base06 sch_base07 sch_base08"
local sch_hs "sch_base09 sch_base10 sch_base11 sch_base12"

ds, has(varlabel base*)

local vars_base_schools = "`r(varlist)'"

di "`vars_base_schools'"

foreach var of local vars_base_schools	{
	di "`var'"
	destring `var', gen(sch_`var')
	}

di "`sch_elem'"
cap drop elem1 elem2
cap drop mid1 mid2
cap drop hs1 hs2

egen elem1 = rowmin(`sch_elem')
egen elem2 = rowmax(`sch_elem')

egen mid1 = rowmin(`sch_mid')
egen mid2 = rowmax(`sch_mid')

egen hs1 = rowmin(`sch_hs')
egen hs2 = rowmax(`sch_hs')

di "elem"
count if elem1 != elem2

di "mid"
count if mid1 != mid2

di "hs"
count if hs1 != hs2

gen diff_elem = 0
gen diff_mid  = 0
gen diff_hs   = 0

replace diff_elem = 1 if elem1 != elem2		//Do K and 5th graders in the same node attend the same base school 
replace diff_mid  = 1 if mid1 != mid2		//Do 6th and 8th graders " "
replace diff_hs   = 1 if hs1 != hs2			//Do 9th and 12th graders " "

gen elem = elem1
cap drop elem1 elem2
cap drop mid1 mid2
cap drop hs1 hs2

tab diff_elem	//Everyone is 0 - 
tab diff_mid	//212 
tab diff_hs		//690

//!!!!Probably should stick this in a log
tab diff_elem year
tab diff_mid year
tab diff_hs	year

//Elementary Schools
gsort nodeid year

//!!!!Working with only nodes that have labels for now
drop if nodeid == ""

xtset obs year

gen node_reassigned = 0
replace node_reassigned = 1 if (L.elem != elem) & (year != 2000) & (L.obs == obs)

tab node_reassigned 
tab node_reassigned year

//Initialize
set more off
set trace off
clear

//Macros
global longleaf "/proj/schleduc/"
global wake "${longleaf}wake/"
global logs "${wake}logs/"
global data "${wake}data/"
global fromwake "${data}original_transfer"

cap log close

cap log using "${logs}school_characteristics_09OCT18.txt", text replace

cd "${data}"

use "${fromwake}big_panel_2000_2010_DEID.dta", clear

capture postclose buffer

postfile buffer school year race grade students using School_Characteristics_2000_2010, replace

quietly levelsof cur_school_code

local schools = "`r(levels)'"

forvalues year = 2000/2010	{
	di "`year'"
	
	foreach school of local schools {
		forvalues race = 1/7 {
			forvalues grade = 1/8	{
				quietly count if cur_school_code == `sch' & year == `year' & race_ethnicity == `r' & grade_level == `g'
				local students = r(N)
				post buffer (`school') (`year') (`race') (`grade') (`students')
			}
		}
	}
}
capture postclose buffer

cap log close

use School_Characteristics_2000_2010, clear

gen pct_race = race/students
bys school year: egen total_students = sum(students)

save, replace

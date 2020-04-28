// oregon.do
// imports cases and clients from excel sheets

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/oregon"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

*local beginning_clock1 		= ym(2013,1) - 0.5
local beginning_clock1 			= ym(2012,12) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 		= ym(2016,1) - 0.5
local beginning_clock2			= ym(2015,12) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome					clients	
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2009,1)

***************************************************************
/*
// import 
import excel using "${dir_root}/COPIED_Oregon Self-Sufficiency Statewide Data Charts FY 10-11 - FY 17-18 (Partial).xlsx", firstrow case(lower) allstring clear
		
// keep only interesting SNAP vars for now
replace selfsufficiencyprogramcategor = trim(selfsufficiencyprogramcategor)
keep if inlist(selfsufficiencyprogramcategor,"Statewide Supplemental Nutrition Assistance Program Benefits","Statewide Supplemental Nutrition Assistance Program Households","Statewide Supplemental Nutrition Assistance Program Persons")
gen varname = ""
replace varname = "benefits" if strpos(selfsufficiencyprogramcategor,"Benefits")
replace varname = "households" if strpos(selfsufficiencyprogramcategor,"Households")
replace varname = "persons" if strpos(selfsufficiencyprogramcategor,"Persons")
drop selfsufficiencyprogramcategor

// destring vars 
foreach v of varlist _all {
	destring `v', replace
	rename `v' _`v'
}
rename _varname varname

// reshape 
reshape long _, i(varname) j(monYY) string
reshape wide _, i(monYY) j(varname) string
rename _benefits benefits
rename _households households
rename _persons persons
label var benefits "SNAP benefits"
label var households "SNAP households"
label var persons "SNAP persons"

// date 
gen month = substr(monYY,1,3)
replace month = "1" if month == "jan"
replace month = "2" if month == "feb"
replace month = "3" if month == "mar"
replace month = "4" if month == "apr"
replace month = "5" if month == "may"
replace month = "6" if month == "jun"
replace month = "7" if month == "jul"
replace month = "8" if month == "aug"
replace month = "9" if month == "sep"
replace month = "10" if month == "oct"
replace month = "11" if month == "nov"
replace month = "12" if month == "dec"
destring month, replace
gen year = substr(monYY,4,5)
destring year, replace
replace year = 2000 + year
gen ym = ym(year,month)
format ym %tm 
drop year month monYY

// order and sort
order ym benefits households persons
sort ym

// save 
save "${dir_root}/oregon_state", replace
*/
***********************************************************

use "${dir_root}/oregon_state", clear

foreach outcome in benefits households persons {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}

check

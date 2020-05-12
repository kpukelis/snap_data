// florida.do 
// Kelsey Pukelis

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/florida"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

********************************************************************

foreach outcome in clients households issuance {

	// create a string for the outcome
	local outcome_string = "`outcome'"

	// import data 
	import excel "${dir_data}/build/florida_county_level.xlsx", sheet("`outcome'_long") firstrow case(lower) clear
	
	// a bit of cleaning
	gen ym = ym(year, month)
	format ym %tm
	
	// manual fixes
	if "`outcome'" == "clients" {
		replace glades = . if glades == 3 & year == 1993
	}

	// reshape
	foreach var of varlist _all {
		rename `var' _`var'
	}
	rename _month month
	rename _year year 
	rename _ym ym 
	reshape	long _, i(ym) j(county) string
	rename _ `outcome_string'
	label var `outcome_string' "SNAP `outcome_string'"
	
	// save 
	save "${dir_data}/clean/`outcome'_county_level.dta", replace
	
	// collapse to total, for now
	collapse (sum) `outcome', by(ym)
	label var `outcome' "SNAP `outcome'"
	save "${dir_data}/clean/`outcome'_state_level.dta", replace

}

**********************************

// MERGE

local county_merge_vars "county ym"
local state_merge_vars "ym"

foreach level in county state {
	foreach outcome in clients households issuance {
		if "`outcome'" == "clients" {
			use "${dir_data}/clean/`outcome'_`level'_level.dta", replace
		}
		else {
			merge 1:1 ``level'_merge_vars' using "${dir_data}/clean/`outcome'_`level'_level.dta"
			if "`outcome'" == "issuance" {
				assert _m == 3 if ym >= ym(2002,1)
				drop _m
			}
			else {
				assert _m == 3
				drop _m
			}
		}
	}
	save "${dir_data}/clean/florida_`level'_level.dta", replace
}

// save with standard name
use "${dir_data}/clean/florida_county_level.dta", clear
save "${dir_data}/clean/florida.dta", replace 

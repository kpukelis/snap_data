// florida.do 
// Kelsey Pukelis

********************************************************************

foreach outcome in clients households issuance {

	// create a string for the outcome
	local outcome_string = "`outcome'"

	// import data 
	import excel "${dir_root}/data/state_data/florida/build/florida_county_level.xlsx", sheet("`outcome'_long") firstrow case(lower) clear
	
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
	drop year month
	
	// save 
	save "${dir_root}/data/state_data/florida/clean/`outcome'_county_level.dta", replace
	
	// collapse to total, for now
	collapse (sum) `outcome', by(ym)
	label var `outcome' "SNAP `outcome'"
	save "${dir_root}/data/state_data/florida/clean/`outcome'_state_level.dta", replace

}

**********************************

// MERGE

local county_merge_vars "county ym"
local state_merge_vars "ym"

foreach level in county state {
	foreach outcome in clients households issuance {
		if "`outcome'" == "clients" {
			use "${dir_root}/data/state_data/florida/clean/`outcome'_`level'_level.dta", replace
		}
		else {
			merge 1:1 ``level'_merge_vars' using "${dir_root}/data/state_data/florida/clean/`outcome'_`level'_level.dta"
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
	rename clients individuals
	save "${dir_root}/data/state_data/florida/clean/florida_`level'_level.dta", replace
}

// save with standard name
use "${dir_root}/data/state_data/florida/clean/florida_county_level.dta", clear
save "${dir_root}/data/state_data/florida/florida.dta", replace 

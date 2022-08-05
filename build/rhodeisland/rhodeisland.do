// rhodeisland.do 
// Kelsey Pukelis
// 2022-07-28

*******************************************************************************************

// APPS DATA 

// import 
import excel using "${dir_root}/data/state_data/rhodeisland/rhodeisland_apps.xlsx", case(lower) firstrow allstring clear

// drop comments
drop if apps_received == "Note: This chart represents the number of applications approved and denied for the months identified. It does not reflect the number of applications received in that month. Withdrawn applications where eligibility wasn’t run are not included."

// destring
foreach var in year month apps_received {
	destring `var', replace 
	confirm numeric variable `var'
}

// ym 
gen ym = ym(year,month)
format ym %tm 
drop year 
drop month 

// county
gen county = "total"

// order and sort 
order county ym 
sort county ym 

// save 
save "${dir_root}/data/state_data/rhodeisland/rhodeisland.dta", replace

*******************************************************************************************
*******************************************************************************************
*******************************************************************************************

check


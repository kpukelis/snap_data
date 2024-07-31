// connecticut.do
// Kelsey Pukelis
// 2024-07-30

********************************************************************************************
/*
// import data
import delimited using "${dir_root}/data/state_data/connecticut/Weekly_DSS_Application_Activity_Before_and_During_COVID-19_Emergency_20240630.csv", delimiter(",") varnames(nonames) stringcols(_all) clear 

// assert shape
dropmiss, force 
dropmiss, force obs 
describe, varlist
assert `r(k)' == 16

// rename
// Week ending date	
// Weekly applications received: All programs
// Weekly applications received: Cash assistance	
// Weekly applications received: Non-MAGI medical assistance	
// Weekly applications received: SNAP	
// Daily average applications received: All programs	
// Daily average applications received: Cash assistance	
// Daily average applications received: Non-MAGI medical assistance	
// Daily average applications received: SNAP	
// Percentage of weekly applications: Cash assistance	
// Percentage of weekly applications: Non-MAGI medical assistance	
// Percentage of weekly applications: SNAP	
// Weekly Percent Change Compared to Average Week before Mar 16 (baseline): All programs	
// Weekly Percent Change Compared to Average Week before Mar 16 (baseline): Cash assistance	
// Weekly Percent Change Compared to Average Week before Mar 16 (baseline): Medical assistance	
// Weekly Percent Change Compared to Average Week before Mar 16 (baseline): SNAP
rename v1 date
rename v2 apps_received_all
rename v3 apps_received_cash
rename v4 apps_received_ma
rename v5 apps_received_snap
rename v6 daily_avg_all
rename v7 daily_avg_cash
rename v8 daily_avg_ma
rename v9 daily_avg_snap
rename v10 perc_cash
rename v11 perc_ma
rename v12 perc_snap
rename v13 perc_change_all
rename v14 perc_change_cash
rename v15 perc_change_ma
rename v16 perc_change_snap
drop in 1 

// date 
split date, parse("/")
rename date1 month
rename date2 day 
rename date3 year 
foreach var in month day year {
	destring `var', replace 
	confirm numeric variable `var'
}
gen mdy_end = mdy(month,day,year)
format mdy_end %td 
drop date 
// drop month 
// drop day 
// drop year 

// destring 
#delimit ;
foreach var in 
	apps_received_all
	apps_received_cash
	apps_received_ma
	apps_received_snap
	daily_avg_all
	daily_avg_cash
	daily_avg_ma
	daily_avg_snap
	perc_cash
	perc_ma
	perc_snap
	perc_change_all
	perc_change_cash
	perc_change_ma
	perc_change_snap
{ ;
	destring `var', replace ;
	confirm numeric variable `var' ;
} ;
#delimit cr 

// start of the week 
gen mdy_start = mdy_end - 7 + 1 // inclusive 
format mdy_start %td

// week 
gen week = week(mdy_end)
gen yw = yw(year,week)
format yw %tw

// ym 
gen ym = ym(year(dofw(yw)),month(dofw(yw)))
format ym %tm 
order ym
drop year 
drop week 
drop month
drop day 

// generate "county"
gen county = "total"

// order and sort 
order county mdy_start mdy_end 
sort county mdy_start mdy_end 

// rename for snap 
rename apps_received_snap apps_received

// save
save "${dir_root}/data/state_data/connecticut/connecticut_apps.dta", replace

**********************************************************************


// MONTHLY

// create monthly version of data from weekly version - linearly interpolate for weeks that go across days 

// load data 
use "${dir_root}/data/state_data/connecticut/connecticut_apps.dta", clear 

// mark observations that go across more than one month 
gen repeat = 0
replace repeat = 1 if month(mdy_start) == month(mdy_end)
replace repeat = 2 if month(mdy_start) != month(mdy_end)
expand repeat 

// for observations that go across more than one month, make a copy 
bysort county yw: gen obsid = _n 
assert inlist(obsid,1,2)

// for second copy, replace month data 
replace ym = ym + 1 if obsid == 2

// generate weight 
gen weight = . 
replace weight = 1 if repeat == 1
replace weight = day(mdy_end) / 7 if repeat == 2 & obsid == 2
replace weight = (7 - day(mdy_end)) / 7 if repeat == 2 & obsid == 1

// collapse 
drop daily_avg_all
drop daily_avg_cash
drop daily_avg_ma
drop daily_avg_snap
drop perc_cash
drop perc_ma
drop perc_snap
drop perc_change_all
drop perc_change_cash
drop perc_change_ma
drop perc_change_snap
drop obsid
drop repeat 
drop yw 
drop mdy_start
drop mdy_end 
#delimit ;
collapse (sum) 
	apps_received_all
	apps_received_cash
	apps_received_ma
	apps_received
 		[pweight = weight], by(county ym)
;
#delimit cr 

// save 
save "${dir_root}/data/state_data/connecticut/connecticut_apps_ym.dta", replace 
*/

******************************************************************************************************************************************

// enrollment data at the town -year level

**KP: code not finished because this is not very useful
/*
// import data
import delimited using "${dir_root}/data/state_data/connecticut/Department_of_Social_Services_-_People_Served_by_Town_and_Type_of_Assistance__TOA___2015-2023_20240630.csv", delimiter(",") varnames(1) stringcols(_all) clear 

// assert shape
dropmiss, force 
dropmiss, force obs 
describe, varlist
assert `r(k)' == 4

// just keep SNAP data for now 
tab typeofassistancetoadescription
keep if typeofassistancetoadescription == "SNAP - Supplemental Nutritional Assistance Program - Federal"
drop typeofassistancetoadescription
drop typeofassistancetoacode 

// 
*/

******************************************************************************************************************************************

// combine data 
use "${dir_root}/data/state_data/connecticut/connecticut_apps_ym.dta", clear 

// save 
save "${dir_root}/data/state_data/connecticut/connecticut.dta", replace 



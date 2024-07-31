// colorado.do 
// Kelsey Pukelis

local ym_start_apps 			= ym(2015,1)
local ym_end_apps 				= ym(2020,5)
local year_start 				= 10
local year_end 					= 22
local year_start_apps 			= 2020
local year_end_apps 			= 2024
local monthlist_2022 			01 02 03 04 05 06 07 08 09 10 11 12 
local monthlist_2023 			01 02 03 04 05 06 07 08 09 10 11 12 
local monthlist_2024 			01 02 03 04 05
local year_start_enroll 		= 2020
local year_end_enroll 			= 2024 
local monthlist_enroll_2020		01 02 03 04 05 06 07 08 09 10 11 12 
local monthlist_enroll_2021		01 02 03 04 05 06 07 08 09 10 11 12 
local monthlist_enroll_2022		01 02 03 04 05 06 07 08 09 10 11 12 
local monthlist_enroll_2023		01 02 03 04 05 06 07 08 09 10 11 12 
local monthlist_enroll_2024		01 02 03 04 05


**************************************************************************
/*
//////////////////////
// APPLICATION DATA //
//////////////////////

forvalues year = `year_start_apps'(1)`year_end_apps' {

	// display
	display in red "`year'"

	// file suffix
	if `year' == `year_end_apps' {
		local suffix "YTD"
	}
	else {
		local suffix "CY"
	}

	if inrange(`year',2020,2022) {

		// load data 
		import excel using "${dir_root}/data/state_data/colorado/excel/SNAP application counts by county_`suffix'`year'.xlsx", firstrow case(lower) allstring clear
 	
		// initial clean up 
		dropmiss, force
		dropmiss, force obs 
		
		// manual drop obs 
		drop if strpos(county,"Cells with <30 counts have been suppressed per Department policy. Monthly averages not calculated for counties with suppressed data.")
		
		// rename 
		rename january _m1
		rename february _m2
		rename march _m3
		rename april _m4 
		rename may _m5
		rename june _m6
		rename july _m7
		rename august _m8
		rename september _m9
		rename october _m10
		rename november _m11
		rename december _m12
		drop monthlyaverage
	
		// clean up county 
		replace county = trim(county)
		replace county = stritrim(county)
		replace county = strlower(county)
	
		// reshape 
		reshape long _m, i(county) j(month)
		rename _m apps_received 
	
		// date 
		gen year = `year'
		gen ym = ym(year,month)
		format ym %tm 
		drop year 
		drop month
	
		// destring 
		destring apps_received, replace
		confirm numeric variable apps_received
	
		// order and sort 
		order county ym apps_received
		sort county ym 
	
		// save 
		tempfile _`year'
		save `_`year''
 	}
 	else {
 		local year_short = `year' - 2000
 		foreach m of local monthlist_`year' {
	
 			// display 
 			dis in red "`year'"
 			dis in red "`m'"

			// load data 
			import excel using "${dir_root}/data/state_data/colorado/excel/SNAP application counts by county_`suffix'`year'.xlsx", sheet("`m'`year_short'") firstrow case(lower) allstring clear
 		
			// initial clean up 
			dropmiss, force
			dropmiss, force obs 
			
			// manual drop obs 
			drop if strpos(county,"Cells with <30 counts have been suppressed per Department policy. Monthly averages not calculated for counties with suppressed data.")
		
			// rename 
			rename applicationscount apps_received 

			// clean up county 
			replace county = trim(county)
			replace county = stritrim(county)
			replace county = strlower(county)

			// date 
			gen year = `year'
			gen month = `m'
			gen ym = ym(year,month)
			format ym %tm 
			drop year 
			drop month 
		
			// destring 
			destring apps_received, replace
			confirm numeric variable apps_received
		
			// order and sort 
			order county ym apps_received
			sort county ym 
		
			// save 
			tempfile _`year'_`m'
			save `_`year'_`m''

 		}

 		// append months of data together 
 		foreach m of local monthlist_`year' {
 			if `m' == 01 {
 				use `_`year'_`m'', clear 
 			}
 			else {
 				append using `_`year'_`m''
 			}
 		}

 		// save 
 		tempfile _`year'
 		save `_`year''
 		 
 	}
}

// append all years of data 
forvalues year = `year_start_apps'(1)`year_end_apps' {
	if `year' == `year_start_apps' {
		use `_`year'', clear 
	}
	else {
		append using `_`year''
	}
}

// order and sort 
order county ym apps_received
sort county ym 

// save 
tempfile colorado_apps_new
save `colorado_apps_new'
save "${dir_root}/data/state_data/colorado/colorado_apps_new.dta", replace 


//////////////////////
// APPLICATION DATA //
//////////////////////

// load data 
import excel using "${dir_root}/data/state_data/colorado/Statewide timeliness data by application type.xlsx", allstring clear 

// initial clean up 
dropmiss, force
dropmiss, force obs 
qui describe, varlist 
rename (`r(varlist)') (v#), addnumber
assert `r(N)' == 15
assert `r(k)' == `ym_end_apps' - `ym_start_apps' + 1 + 1

// set varnames
replace v1 = strlower(v1)
replace v1 = ustrregexra(v1," ","") 
replace v1 = "apps_" + v1 if inrange(_n,1,5)
replace v1 = "apps_expedited" + v1 if inrange(_n,6,10)
replace v1 = "recert_" + v1 if inrange(_n,11,15)
*drop if strpos(v1,"newapplications")
drop if strpos(v1,"expeditedapplications")
drop if strpos(v1,"redeterminations")

// transpose
// sxpose, clear firstnames
// traspose data 
// rewriting this code because sxpose is no longer available...
gen id = _n 
ds id, not 
reshape long v, i(id) j(which) string 
reshape wide v, i(which) j(id) /*string*/
destring which, replace 
confirm numeric variable which 
sort which 
drop which 

// turn first row into variable names 
foreach var of varlist * {
	replace `var' = strlower(`var')
	replace `var' = ustrregexra(`var',"-","") if _n == 1
	replace `var' = ustrregexra(`var',"\.","") if _n == 1
	replace `var' = ustrregexra(`var'," ","") if _n == 1
	replace `var' = ustrregexra(`var',"/","") if _n == 1
	label variable `var' "`=`var'[1]'"
	rename `var' `=`var'[1]'
}
drop in 1
rename apps_newapplications monthyear 
replace monthyear = strlower(monthyear)

// rename 
rename apps_total apps_received
rename apps_timely apps_received_timely
rename apps_untimely apps_received_untimely
rename apps_pct apps_received_timely_perc
rename apps_expeditedtotal apps_expedited
rename apps_expeditedtimely apps_expedited_timely
rename apps_expediteduntimely apps_expedited_untimely
rename apps_expeditedpct apps_expedited_timely_perc
rename recert_total recert 
rename recert_pct recert_timely_perc
 
// month and year 
gen month = .
replace month = 1 if strpos(monthyear,"jan")
replace month = 2 if strpos(monthyear,"feb")
replace month = 3 if strpos(monthyear,"mar")
replace month = 4 if strpos(monthyear,"apr")
replace month = 5 if strpos(monthyear,"may")
replace month = 6 if strpos(monthyear,"jun")
replace month = 7 if strpos(monthyear,"jul")
replace month = 8 if strpos(monthyear,"aug")
replace month = 9 if strpos(monthyear,"sep")
replace month = 10 if strpos(monthyear,"oct")
replace month = 11 if strpos(monthyear,"nov")
replace month = 12 if strpos(monthyear,"dec")
assert !missing(month)
gen year = .
forvalues n = 15(1)20 {
	replace year = 2000 + `n' if strpos(monthyear,"-`n'")	
}
replace year = 2020 if strpos(monthyear,"2020")
assert !missing(year)
gen ym = ym(year,month)
format ym %tm 
drop year 
drop month 
drop monthyear
order ym 

// destring
foreach var in apps_received_timely apps_received_untimely apps_received apps_received_timely_perc apps_expedited_timely apps_expedited_untimely apps_expedited apps_expedited_timely_perc recert_timely recert_untimely recert recert_timely_perc {
	destring `var', replace 
	confirm numeric variable `var'
}

// county 
gen county = "total"

// order and sort 
order county ym apps_received apps_expedited recert apps_received_* apps_expedited_* recert_*
sort county ym 

// save 
tempfile colorado_apps
save `colorado_apps'
save "${dir_root}/data/state_data/colorado/colorado_apps.dta", replace 

**************************************************************************
**************************************************************************
**************************************************************************
**************************************************************************

/////////////////////
// ENROLLMENT DATA //
/////////////////////

forvalues year = `year_start_enroll'(1)`year_end_enroll' {

	// display  
	display in red "`year'"

	// short year 
	local year_short = `year' - 2000

	// file suffix
	if inlist(`year',2020,2024) {
		local suffix " YTD"
	}
	else {
		local suffix ""
	}

	// loop through months 
	foreach m of local monthlist_enroll_`year' {

		// display 
		display in red "`m'"

		// load data 
		import excel "${dir_root}/data/state_data/colorado/excel/Caseload by county_CY`year'`suffix'.xlsx", sheet("`m'`year_short'") allstring case(lower) firstrow clear 
	
		// drop empty variables
		dropmiss, force
		dropmiss, force obs  
		
		// rename variables 
		capture rename countyname					county 
		rename issuanceamount 						issuance 
		capture rename casecount 					households
		capture rename clientcount 					individuals
		capture rename countofcases 				households 
		capture rename countofclients 				individuals
		capture rename countofdistinctcases 		households 
		capture rename countofdistinctclients 		individuals
		capture rename countofnpacases 				households_npa
		capture rename countofnpaclients 			individuals_npa
		capture rename countofpacases 				households_pa 
		capture rename countofpaclients 			individuals_pa
		capture rename nonpublicassistancecases 	households_npa
		capture rename nonpublicassistanceclients 	individuals_npa
		capture rename publicassistancecases 		households_pa 
		capture rename publicassistanceclients 		individuals_pa
	
		// destring
		foreach v in households individuals issuance households_npa households_pa individuals_npa individuals_pa {
			destring `v', replace
			confirm numeric variable `v'
		}
		
		// lowercase county 
		replace county = strlower(county)
		
		// drop statewide average 
		drop if strpos(county,"statewide average")
		replace county = "state totals" if county == "statewide total"
	
		// ym 
		gen year = `year' 
		gen month = `m'
		gen ym = ym(year,month)
		format ym %tm
		drop year 
		drop month 
		
		// save 
		tempfile _`year'_`m'
		save `_`year'_`m''
		 
	}

	// append months together 
	foreach m of local monthlist_enroll_`year' {
		if `m' == 01 {
			use `_`year'_`m'', clear 
		}
		else {
			append using `_`year'_`m''
		}
	}

	// save 
	tempfile _`year'
	save `_`year''

}

// append years 
forvalues year = `year_start_enroll'(1)`year_end_enroll' {
	if `year' == `year_start_enroll' {
		use `_`year'', clear
	}
	else {
		append using `_`year''
	}
}
 
// totals
replace county = "total" if county == "state totals"

// drop missing vars 
dropmiss county /*ym*/ issuance households individuals households_npa individuals_npa households_pa individuals_pa, force obs 
assert !missing(county)

// order and sort 
order county ym issuance households individuals households_npa individuals_npa households_pa individuals_pa
sort county ym 

// save 
tempfile colorado_enrollment
save `colorado_enrollment'
save "${dir_root}/data/state_data/colorado/colorado_enrollment.dta", replace 
*/

**************************************************************************
**************************************************************************

// COMBINE 

use "${dir_root}/data/state_data/colorado/colorado_apps.dta", clear 
rename apps_received apps_received_old
*gen apps_received = apps_received_old + apps_expedited
save "${dir_root}/data/state_data/colorado/colorado_apps_TEMP.dta", replace 


// collapse new apps to state total
use "${dir_root}/data/state_data/colorado/colorado_apps_new.dta", clear 
collapse (sum) apps_received, by(ym)
gen county = "total"
gen source = "_county_data"

// append state data 
merge 1:1 county ym using "${dir_root}/data/state_data/colorado/colorado_apps_TEMP.dta", update replace
assert !inlist(_m,4,5)
drop _m 

// sort 
sort ym -source

// assert level of the data 
duplicates tag ym, gen(dup)
assert dup == 0
drop dup 

// merge in enrollment data
merge 1:1 county ym using "${dir_root}/data/state_data/colorado/colorado_enrollment.dta", update replace 
assert !inlist(_m,4,5)

// check merge 
*local ym_start_minus1 = `ym_start' - 1
*assert inrange(ym,`ym_start_apps',`ym_start_minus1') if _m == 1
*assert county != "total" if _m == 2
**assert _m == 3 if county == "total" & inrange(ym,max(`ym_start_apps',`ym_start'),min(`ym_end_apps',`ym_end'))
drop _m 

// merge in county apps data 
merge 1:1 county ym using "${dir_root}/data/state_data/colorado/colorado_apps_new.dta", update replace 
assert !inlist(_m,5)
drop _m 

// order and sort 
order county ym issuance households individuals households_npa individuals_npa households_pa individuals_pa apps_received apps_expedited recert apps_received_* apps_expedited_* recert_*
sort county ym 
 
// save 
save "${dir_root}/data/state_data/colorado/colorado.dta", replace 

**************************************************************************

clear
forvalues year = `year_start'(1)`year_end' {

	// display year 
	display in red "`year'"

	if inrange(`year',10,15) {
		// load data 
		import excel "${dir_root}/data/state_data/colorado/excel/Average caseload_CY_old.xlsx", sheet("CY`year'") allstring case(lower) firstrow cellrange(A1:H66) clear
	}
	else if inrange(`year',16,21) {
		// load data 
		import excel "${dir_root}/data/state_data/colorado/excel/Average caseload_CY.xlsx", sheet("CY`year'") allstring case(lower) firstrow cellrange(A1:H66) clear
	}
	// current year
	else if `year' == `year_end' {
		// load data 
		import excel "${dir_root}/data/state_data/colorado/excel/Caseload by county_CY20`year' YTD.xlsx", sheet("CY AVG") allstring case(lower) firstrow clear 
	}
	// drop empty variables
	dropmiss, force 
	
	// rename variables 
	capture rename countyname					county 
	rename issuanceamount 						issuance 
	capture rename casecount 					households
	capture rename clientcount 					individuals
	capture rename countofcases 				households 
	capture rename countofclients 				individuals
	capture rename countofdistinctcases 		households 
	capture rename countofdistinctclients 		individuals
	capture rename countofnpacases 				households_npa
	capture rename countofnpaclients 			individuals_npa
	capture rename countofpacases 				households_pa 
	capture rename countofpaclients 			individuals_pa
	capture rename nonpublicassistancecases 	households_npa
	capture rename nonpublicassistanceclients 	individuals_npa
	capture rename publicassistancecases 		households_pa 
	capture rename publicassistanceclients 		individuals_pa

	// destring
	foreach v in households individuals issuance households_npa households_pa individuals_npa individuals_pa {
		destring `v', replace
		confirm numeric variable `v'
	}
	
	// lowercase county 
	replace county = strlower(county)
	
	// drop statewide average 
	drop if strpos(county,"statewide average")
	drop if strpos(county,"state total")
	drop if strpos(county,"statewide total")

	// drop missing observations
	drop if missing(county)

	// year 
	gen year = 2000 + `year'
	
	// assert size 
	count 
	assert r(N) == 64

	// save 
	tempfile _`year'
	save `_`year''

}

// append years 
clear
forvalues year = `year_start'(1)`year_end' {
	if `year' == `year_start' {
		use `_`year'', clear
	}
	else {
		append using `_`year''
	}
}

// order and sort 
order county year issuance households individuals households_npa individuals_npa households_pa individuals_pa
sort county year 

// save 
save "${dir_root}/data/state_data/colorado/colorado_year.dta", replace 

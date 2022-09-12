// colorado.do 
// Kelsey Pukelis

local ym_start_apps 			= ym(2015,1)
local ym_end_apps 				= ym(2020,5)
local ym_start 					= ym(2020,1)
local ym_end 					= ym(2020,5) // could add 2022 data; 2021 needs to be asked for 
local year_start 				= 10
local year_end 					= 22

**************************************************************************

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
sxpose, clear firstnames
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

**************************************************************************
**************************************************************************
**************************************************************************
**************************************************************************

/////////////////////
// ENROLLMENT DATA //
/////////////////////

forvalues ym = `ym_start'(1)`ym_end' {

	// display ym 
	display in red "`ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, gen(monthname) 
	replace monthname = "0" + monthname if strlen(monthname) == 1
	gen year_short = year - 2000
	local month = month
	display in red "`month'"
	local monthname = monthname
	display in red "`monthname'"
	local year = year
	display in red "`year'"
	local year_short = year_short
	display in red "`year_short'"

	if inrange(`ym',ym(2020,1),ym(2020,12)) {
		// load data 
		import excel "${dir_root}/data/state_data/colorado/excel/Caseload by county_CY2020 YTD.xlsx", sheet("`monthname'`year_short'") allstring case(lower) firstrow clear 
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
	replace county = "state totals" if county == "statewide total"

	// ym 
	gen ym = ym(`year',`month')
	format ym %tm
	
	// save 
	tempfile _`ym'
	save `_`ym''

}

// append years 
forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
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

**************************************************************************
**************************************************************************

// combine datasets
use `colorado_apps', clear 
merge 1:1 county ym using `colorado_enrollment'

// check merge 
local ym_start_minus1 = `ym_start' - 1
assert inrange(ym,`ym_start_apps',`ym_start_minus1') if _m == 1
assert county != "total" if _m == 2
*assert _m == 3 if county == "total" & inrange(ym,max(`ym_start_apps',`ym_start'),min(`ym_end_apps',`ym_end'))
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

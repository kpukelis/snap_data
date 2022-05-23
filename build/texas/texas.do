// texas.do 
// Kelsey Pukelis 

local ym_start_state			= ym(2005,9)
local ym_end_state				= ym(2020,12)
local ym_start 					= ym(2014,1)
local ym_end 					= ym(2022,4)
local ym_start_apps				= ym(2014,1)
local ym_end_apps 				= ym(2022,3)
local prefix_2014 				"SNAP-Enrollment-"
local prefix_2015 				"SNAP-Enrollment-"
local prefix_2016 				"snap-enrollment-"
local prefix_2017 				"snap-enrollment-"
local prefix_2018 				"snap-case-recipients-county-"
local prefix_2019 				"snap-case-eligible-county-"
local prefix_2020 				"snap-case-eligible-county-"
local prefix_2021 				"snap-case-eligible-county-"
local prefix_2022 				"snap-case-eligible-county-"
local prefix_apps_2014 			"SNAP-"
local prefix_apps_2015			"SNAP-"
local prefix_apps_2016			"SNAP-"
local prefix_apps_2017			"timeliness-snap-"
local prefix_apps_2018			"timeliness-snap-"
local prefix_apps_2019			"timeliness-snap-"
local prefix_apps_2020			"timeliness-snap-"
local prefix_apps_2021			"timeliness-snap-"
local prefix_apps_2022			"timeliness-snap-"
local yearname_2014				"-2014"
local yearname_2015				"-2015"
local yearname_2016				"-2016"
local yearname_2017				"-2017"
local yearname_2018				"-2018"
local yearname_2019				"-2019"
local yearname_2020 			"-2020"
local yearname_2021 			"-2021"
local yearname_2022 			"-2022"


*********************************************************************

forvalues ym = `ym_start_apps'(1)`ym_end_apps' {

	display in red "year and month `ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace
	replace month = "0" + month if strlen(month) == 1
	local month = month
	local monthname = month 
	local year = year 
	display in red  "`year' `month'" 

	if inlist(`year',2014,2015,2016) {
		gen monthname = ""
		replace monthname = "January" 	if month == "01"
		replace monthname = "February" 	if month == "02"
		replace monthname = "March" 	if month == "03"
		replace monthname = "April" 	if month == "04"
		replace monthname = "May" 		if month == "05"
		replace monthname = "June" 		if month == "06"
		replace monthname = "July" 		if month == "07"
		replace monthname = "August" 	if month == "08"
		replace monthname = "September" if month == "09"
		replace monthname = "October" 	if month == "10"
		replace monthname = "November" 	if month == "11"
		replace monthname = "December" 	if month == "12"
		local monthname = monthname
	}
	else if inlist(`year',2017,2018,2019,2020,2021,2022) {
		gen monthname = ""
		replace monthname = "jan" 	if month == "01"
		replace monthname = "feb" 	if month == "02"
		replace monthname = "mar" 	if month == "03"
		replace monthname = "apr" 	if month == "04"
		replace monthname = "may" 	if month == "05"
		replace monthname = "jun" 	if month == "06"
		replace monthname = "jul" 	if month == "07"
		replace monthname = "aug" 	if month == "08"
		replace monthname = "sep" 	if month == "09"
		replace monthname = "oct" 	if month == "10"
		replace monthname = "nov" 	if month == "11"
		replace monthname = "dec" 	if month == "12"
		local monthname = monthname
	}
	else {
		stop 
	}
	if `ym' < ym(2021,7) {
		local filetype xls	
	}
	else {
		local filetype xlsx
	}
	

	if inrange(`ym',ym(2014,1),ym(2017,3)) | inrange(`ym',ym(2017,5),ym(2018,7)) {
		
		// import 
		import excel using "${dir_root}/data/state_data/texas/excel/application timeliness/`year'/`prefix_apps_`year''`monthname'`yearname_`year''.`filetype'", case(lower) allstring clear
	
		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
	
		// drop non-data rows
		drop if strpos(v1,"SNAP Food Benefits TIMELINESS")
		drop if strpos(v1,"SNAP Food Benefits APPLICATIONS")
		drop if v1 == "Region"
		drop if strpos(v1,"Data from CG-003")
		drop if strpos(v1,"Notes:")
		drop if strpos(v1,"Disposed - the number of applications worked to a decision (approved and/or denied) and provided a benefit if approved.")
		drop if strpos(v1,"Timely - the number of applications disposed within the established time frames for the program.")
		drop if strpos(v1,"SNAP Application Timeliness includes Expedited SNAP Applications.")
		drop if strpos(v1,"Redetermination - consideration of all eligibility criteria for a type program at the end of a certification period to determine ongoing benefits for a new certification period.")
		drop if strpos(v1,"These counts include disaster SNAP applications")
		drop if strpos(v1,"Redetermination - consideration of all eligibility criteria for a type program at the end of a certification period to determine ongoing benefits for")
		drop if strpos(v1,"a new certification period")
		drop if strpos(v1,"End of Worksheet")
		drop if strpos(v1,"SNAP Food Benefits REDETERMINATIONS")
		drop if strpos(v1,"*MONTH END SNAP FOOD BENEFITS CASES and ELIGIBLE INDIVIDUALS by COUNTY")
		drop if strpos(v1,"* HHSC changed the way it reports SNAP food benefits")
		drop if strpos(v1,"numbers previously reported.")
		drop if strpos(v1,"Data Source: dbo.b_DM_SNAP_CLIENT_MonthEnd and ")
		drop if strpos(v1,"Prepared by Human Services Programs // Center for ")
		drop if strpos(v1,"Filename: '_Template FS Cnty WEB data_DM_EOM_201907.xls'")
		drop if strpos(v1,"Case = designated group of people determined eligible to ")
		drop if strpos(v1,"Eligible Individual = individual determined eligible for ")
		drop if strpos(v1,"Average Payment / Case = average dollar benefit available ")
		dropmiss, force 
		dropmiss, obs force 
	
		gen v1_copy = v1
		drop v1
		rename v1_copy v1 
		order v1
	
		// rename
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		assert r(k) == 8
		assert r(N) == 17 | r(N) == 18
		rename v1 region1
		rename v2 apps_disposed
		rename v3 apps_timely
		rename v4 apps_perc_timely
		rename v5 region2
		rename v6 recerts_disposed
		rename v7 recerts_timely
		rename v8 recerts_perc_timely
	
		// fix region 
		replace region1 = trim(region1)
		replace region2 = trim(region2)
		assert region1 == region2
		drop region2 
		rename region1 region 
		replace region = strlower(region)
	
		// destring 
		foreach var in apps_disposed apps_timely apps_perc_timely recerts_disposed recerts_timely recerts_perc_timely {
			destring `var', replace 
			confirm numeric variable `var'
		}
	
		// date 
		gen ym = `ym'
		format ym %tm 
	
		// order and sort 
		order region ym 
		sort region ym 
	
		// save 
		tempfile _`ym'
		save `_`ym''
	}
	else if inrange(`ym',ym(2018,8),ym(2019,6)) | inrange(`ym',ym(2019,8),ym(2022,3)) {
		
		if inrange(`ym',ym(2020,1),ym(2020,3)) {
			local total = 38
		}
		else {
			local total = 36
		}
		local half_total = `total' / 2
		local half_total_plus1 = `half_total' + 1

		// import 
		import excel using "${dir_root}/data/state_data/texas/excel/application timeliness/`year'/`prefix_apps_`year''`monthname'`yearname_`year''.`filetype'", sheet("SNAP Food Benefits") case(lower) allstring clear
	
		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
	
		// drop non-data rows
		drop if strpos(v1,"SNAP Food Benefits TIMELINESS")
		drop if strpos(v1,"SNAP Food Benefits APPLICATIONS")
		drop if v1 == "Region"
		drop if strpos(v1,"Data from CG-003")
		drop if strpos(v1,"Notes:")
		drop if strpos(v1,"Disposed - the number of applications worked to a decision (approved and/or denied) and provided a benefit if approved.")
		drop if strpos(v1,"Timely - the number of applications disposed within the established time frames for the program.")
		drop if strpos(v1,"SNAP Application Timeliness includes Expedited SNAP Applications.")
		drop if strpos(v1,"Redetermination - consideration of all eligibility criteria for a type program at the end of a certification period to determine ongoing benefits for a new certification period.")
		drop if strpos(v1,"These counts include disaster SNAP applications")
		drop if strpos(v1,"Redetermination - consideration of all eligibility criteria for a type program at the end of a certification period to determine ongoing benefits for")
		drop if strpos(v1,"a new certification period")
		drop if strpos(v1,"End of Worksheet")
		drop if strpos(v1,"SNAP Food Benefits REDETERMINATIONS")
		drop if strpos(v1,"*MONTH END SNAP FOOD BENEFITS CASES and ELIGIBLE INDIVIDUALS by COUNTY")
		drop if strpos(v1,"* HHSC changed the way it reports SNAP food benefits")
		drop if strpos(v1,"numbers previously reported.")
		drop if strpos(v1,"Data Source: dbo.b_DM_SNAP_CLIENT_MonthEnd and ")
		drop if strpos(v1,"Prepared by Human Services Programs // Center for ")
		drop if strpos(v1,"Filename: '_Template FS Cnty WEB data_DM_EOM_201907.xls'")
		drop if strpos(v1,"Case = designated group of people determined eligible to ")
		drop if strpos(v1,"Eligible Individual = individual determined eligible for ")
		drop if strpos(v1,"Average Payment / Case = average dollar benefit available ")
		dropmiss, force 
		dropmiss, obs force 
	
		gen v1_copy = v1
		drop v1
		rename v1_copy v1 
		order v1
	
		// reshape
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		assert r(k) == 4
		assert r(N) == `total'
		rename v1 region
		rename v2 disposed
		rename v3 timely
		rename v4 perc_timely
		gen var = ""
		replace var = "apps_" if inrange(_n,1,`half_total')
		replace var = "recerts_" if inrange(_n,`half_total_plus1',`total')
		reshape wide @disposed @timely @perc_timely, i(region) j(var) string

		// fix region 
		replace region = trim(region)
		replace region = strlower(region)

		// destring 
		foreach var in apps_disposed apps_timely apps_perc_timely recerts_disposed recerts_timely recerts_perc_timely {
			destring `var', replace 
			confirm numeric variable `var'
		}
	
		// date 
		gen ym = `ym'
		format ym %tm 
	
		// order and sort 
		order region ym 
		sort region ym 
	
		// save 
		tempfile _`ym'
		save `_`ym''
	}
	else if inlist(`ym',ym(2017,4),ym(2019,7)) {
		// couldn't find 2017m4,2019m7 data to download; link was broken
		
		// create blank dataset 
		clear
		set obs 1
		gen ym = `ym'
		format ym %tm 

		// save 
		tempfile _`ym'
		save `_`ym''
	}
	else {
		STOP
	}


}

******************************************

forvalues ym = `ym_start_apps'(1)`ym_end_apps' {
	if `ym' == `ym_start_apps' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// assert no duplicates
duplicates tag region ym, gen(dup)
assert dup == 0
drop dup 

// order 
order region ym 
sort region ym 

// drop missing obs 
count if missing(region)
assert `r(N)' == 2
drop if missing(region) 

// drop all region level data for now 
keep if region == "total"

// rename region county to include with enrollment data 
// this is fine since I'm only keeping the state total right now 
rename region county 

// ensure we got all the months 
forvalues ym = `ym_start_apps'(1)`ym_end_apps' {
// recall data for these months is missing 
if !inlist(`ym',ym(2017,4),ym(2019,7)) {
	display in red `ym' %tm
	count if ym == `ym'
	assert `r(N)' == 1
}
}

// rename variable to remain consistent 
// "Disposed - the number of applications worked to a decision (approved and/or denied) and provided a benefit if approved."
rename apps_disposed apps_received 

// save
tempfile texas_applications
save `texas_applications'

************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************

// STATE DATA 

display in red `ym_end_state'
display in red `ym_start_state'

// import 
import excel using "${dir_root}/data/state_data/texas/excel/state/snap-cases-eligible-statewide.xlsx", case(lower) allstring clear

// initial cleanup
dropmiss, force 
dropmiss, obs force 
describe, varlist 
rename (`r(varlist)') (v#), addnumber

// manual drop 
drop if strpos(v1,"Benefit") & strpos(v1,"Month")
drop if strpos(v2,"Monthly SNAP Cases & Eligible Individuals Statewide")
drop if strpos(v2,"Data Source: dbo.b_DM_SNAP_CLIENT_MonthEnd and dbo.b_DM_SNAP_EDG_MonthEnd")
drop if strpos(v2,"Prepared by Human Services Programs")
drop if strpos(v2,"Case = designated group of people certified to receive the benefit (can be more than one person).")
drop if strpos(v2,"Average Payment / Case = average dollar benefit available to the case (shared by the recipients on that case)")
drop if v1 == "Average"
drop if v1 == "Year-To-Date"

// rename 
dropmiss, force 
dropmiss, obs force 
describe, varlist 
rename (`r(varlist)') (v#), addnumber
assert r(k) == 10
assert r(N) == `ym_end_state' - `ym_start_state' + 1
rename v1 monthyear 
rename v2 households
rename v3 individuals
rename v4 age_00_04
rename v5 age_05_17
rename v6 age_18_59
rename v7 age_60_64
rename v8 age_65
rename v9 issuance
rename v10 avg_payment_percase

// date 
split monthyear, parse("-")
rename monthyear1 monthname 
rename monthyear2 yearshort
gen month = ""
replace month = "1" if monthname == "Jan"
replace month = "2" if monthname == "Feb"
replace month = "3" if monthname == "Mar"
replace month = "4" if monthname == "Apr"
replace month = "5" if monthname == "May"
replace month = "6" if monthname == "Jun"
replace month = "7" if monthname == "Jul"
replace month = "8" if monthname == "Aug"
replace month = "9" if monthname == "Sep"
replace month = "10" if monthname == "Oct"
replace month = "11" if monthname == "Nov"
replace month = "12" if monthname == "Dec"
destring month, replace 
confirm numeric variable month 
drop monthname
destring yearshort, replace 
confirm numeric variable yearshort
gen year = 2000 + yearshort
gen ym = ym(year,month)
format ym %tm
drop monthyear yearshort year month 

// destring 
foreach var in households individuals issuance age_00_04 age_05_17 age_18_59 age_60_64 age_65 avg_payment_percase {
	destring `var', replace 
	confirm numeric variable `var'
}

// gen county 
gen county = "total"

// order and sort 
order ym households individuals issuance age_00_04 age_05_17 age_18_59 age_60_64 age_65 avg_payment_percase
sort ym 

// save 
tempfile statewide 
save `statewide'

*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************

forvalues ym = `ym_start'(1)`ym_end' {

	display in red "year and month `ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace
	replace month = "0" + month if strlen(month) == 1
	local month = month
	local monthname = month 
	local year = year 
	display in red  "`year' `month'" 

	if inlist(`year',2014,2015) {
		gen monthname = ""
		replace monthname = "January" 	if month == "01"
		replace monthname = "February" 	if month == "02"
		replace monthname = "March" 	if month == "03"
		replace monthname = "April" 	if month == "04"
		replace monthname = "May" 		if month == "05"
		replace monthname = "June" 		if month == "06"
		replace monthname = "July" 		if month == "07"
		replace monthname = "August" 	if month == "08"
		replace monthname = "September" if month == "09"
		replace monthname = "October" 	if month == "10"
		replace monthname = "November" 	if month == "11"
		replace monthname = "December" 	if month == "12"
		local monthname = monthname
	}
	else if inlist(`year',2016) {
		gen monthname = ""
		replace monthname = "january" 	if month == "01"
		replace monthname = "february" 	if month == "02"
		replace monthname = "march" 	if month == "03"
		replace monthname = "april" 	if month == "04"
		replace monthname = "may" 		if month == "05"
		replace monthname = "june" 		if month == "06"
		replace monthname = "july" 		if month == "07"
		replace monthname = "august" 	if month == "08"
		replace monthname = "september" if month == "09"
		replace monthname = "october" 	if month == "10"
		replace monthname = "november" 	if month == "11"
		replace monthname = "december" 	if month == "12"
		local monthname = monthname
	}
	else if inlist(`year',2017,2018,2019,2020,2021,2022) {
		gen monthname = ""
		replace monthname = "jan" 	if month == "01"
		replace monthname = "feb" 	if month == "02"
		replace monthname = "mar" 	if month == "03"
		replace monthname = "apr" 	if month == "04"
		replace monthname = "may" 	if month == "05"
		replace monthname = "jun" 	if month == "06"
		replace monthname = "jul" 	if month == "07"
		replace monthname = "aug" 	if month == "08"
		replace monthname = "sep" 	if month == "09"
		replace monthname = "oct" 	if month == "10"
		replace monthname = "nov" 	if month == "11"
		replace monthname = "dec" 	if month == "12"
		local monthname = monthname
	}
	if inlist(`ym',ym(2016,8),ym(2016,9),ym(2017,3),ym(2018,7),ym(2018,8),ym(2018,12)) {
		local filetype xlsx
	}
	else {
		local filetype xls
	}

	// import 
	import excel using "${dir_root}/data/state_data/texas/excel/enrollment/`year'/`prefix_`year''`monthname'`yearname_`year''.`filetype'", case(lower) allstring clear

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// drop non-data rows
	drop if strpos(v1,"County Name")
	drop if strpos(v1,"MONTHLY SNAP FOOD BENEFITS CASES and RECIPIENTS by COUNTY")
	drop if strpos(v1,"*MONTH END SNAP FOOD BENEFITS CASES and RECIPIENTS by COUNTY")
	drop if strpos(v1,"*MONTH END SNAP FOOD BENEFITS CASES and ELIGIBLE INDIVIDUALS by COUNTY")
	drop if strpos(v1,"Monthly SNAP Food Benefits client level cutoff file")
	drop if strpos(v1,"Prepared by Texas Works Reporting Team")
	drop if strpos(v1,"Prepared by Human Services Programs")
	drop if strpos(v1,"Filename:")
	drop if strpos(v1,"Case = designated group of people certified to receive the benefit (can be more than one person).")
	drop if strpos(v1,"Recipients = the individuals receiving the benefit.")
	drop if strpos(v1,"Average Payment / Case = average dollar benefit available to the case (shared by the recipients on that case).")
	drop if strpos(v1,"The SNAP Food Benefits cutoff file contains TIERS cases/recipients certified for benefits as of cutoff in the month preceding the Benefit Month.")
	drop if strpos(v1,"Cutoff files undercount recipients and cases with respect to end-of-month counts.")
	drop if strpos(v1,"Historically, active cases, cases on hold, & cases automatically denied because a ")
	drop if strpos(v1,"SNAP County Web Data has been taken from")
	drop if strpos(v1,"Data Source:")
	drop if strpos(v1,"End of Worksheet")
	drop if strpos(v1,"Revised: May 15, 2019")
	drop if strpos(v1,"Case = designated group of people determined eligible to receive the SNAP benefit (can be more than one person).  Counts include cases with $0 authorized benefits")
	drop if strpos(v1,"Eligible Individual = individual determined eligible for SNAP. Counts include all eligible individuals, regardless of receipt of benefit")
	drop if strpos(v1,"Average Payment / Case = average dollar benefit available to the case (shared by the eligible individuals on that case)")
	drop if strpos(v1,"* HHSC changed the way it reports SNAP food benefits enrollment by county in September 2014.")
	drop if strpos(v1," Enrollment totals beginning with September 2014 will differ from the numbers previously reported.")
	drop if strpos(v1,"numbers previously reported")
	drop if strpos(v1,"Revised 12/7/2020")
	drop if strpos(v1,"Prepared by: Human Services Programs")
	drop if strpos(v1,"Total SNAP Payments = sum of dollar benefits issued in the month for the month across cases. This figure does not include supplemental or retroactively issued benefits.")
	replace v9 = "" if v9 == "`"
	dropmiss, force 
	dropmiss, obs force 

	gen v1_copy = v1
	drop v1
	rename v1_copy v1 
	order v1

	// rename
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	assert r(k) == 10
	assert r(N) == 257
	rename v1 county
	rename v2 households
	rename v3 individuals
	rename v4 age_00_04
	rename v5 age_05_17
	rename v6 age_18_59
	rename v7 age_60_64
	rename v8 age_65
	rename v9 issuance
	rename v10 avg_payment_percase

	// destring 
	foreach var in households individuals age_00_04 age_05_17 age_18_59 age_60_64 age_65 issuance avg_payment_percase {
		destring `var', replace 
		confirm numeric variable `var'
	}

	// date 
	gen ym = `ym'
	format ym %tm 

	// order and sort 
	order county ym 
	sort county ym 

	// save 
	tempfile _`ym'
	save `_`ym''

}

******************************************

forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// replace county
replace county = "total" if county == "State Total"

// append statewide data 
append using `statewide'

// drop duplicates 
duplicates drop 
duplicates drop county ym households individuals age_00_04 age_05_17 age_18_59 age_60_64 age_65, force // needed since there was some rounding issue with avg_payment_percase and issuance

// assert no duplicates
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// gen children, adults 
gen adults = age_18_59
egen children = rowtotal(age_00_04 age_05_17)

// order 
order county ym households individuals issuance adults children age_00_04 age_05_17 age_18_59 age_60_64 age_65 avg_payment_percase
sort county ym 

// save
tempfile texas
save `texas'

************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************

// merge applications with enrollment data 

use `texas', clear 
merge 1:1 county ym using `texas_applications'

local ym_start_state_plus1 = `ym_start_state' + 1
local ym_end_state_plus1 = `ym_end_state' + 1
assert inrange(ym,`ym_start_state_plus1',`ym_start_apps') | inrange(ym,`ym_end_state_plus1',`ym_end_apps') if _m == 2
local ym_start_apps_minus1 = `ym_start_apps' - 1
assert !inlist(county,"total") | (county == "total" & inlist(ym,ym(2017,4),ym(2019,7),ym(2022,4))) | (county == "total" & inrange(ym,`ym_start_state',`ym_start_apps_minus1')) if _m == 1
drop _m 

// lowercase county 
replace county = strlower(county)

// order and sort 
order county ym 
sort county ym 

// save 
save "${dir_root}/data/state_data/texas/texas.dta", replace





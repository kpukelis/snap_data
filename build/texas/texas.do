global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/texas"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local ym_start 					= ym(2014,1)
local ym_end 					= ym(2020,4)
local prefix_2014 				"SNAP-Enrollment-"
local prefix_2015 				"SNAP-Enrollment-"
local prefix_2016 				"snap-enrollment-"
local prefix_2017 				"snap-enrollment-"
local prefix_2018 				"snap-case-recipients-county-"
local prefix_2019 				"snap-case-eligible-county-"
local prefix_2020 				"snap-case-eligible-county-"
local yearname_2014				"-2014"
local yearname_2015				"-2015"
local yearname_2016				"-2016"
local yearname_2017				"-2017"
local yearname_2018				"-2018"
local yearname_2019				"-2019"
local yearname_2020 			"-2020"

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
	else if inlist(`year',2017,2018,2019,2020) {
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
	import excel using "${dir_root}/excel/enrollment/`year'/`prefix_`year''`monthname'`yearname_`year''.`filetype'", case(lower) allstring clear

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
	rename v2 cases
	rename v3 recipients
	rename v4 age_00_04
	rename v5 age_05_17
	rename v6 age_18_59
	rename v7 age_60_64
	rename v8 age_65
	rename v9 issuance
	rename v10 avg_payment_percase

	// destring 
	foreach var in cases recipients age_00_04 age_05_17 age_18_59 age_60_64 age_65 issuance avg_payment_percase {
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

// assert no duplicates
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order 
order county ym cases recipients issuance age_00_04 age_05_17 age_18_59 age_60_64 age_65 avg_payment_percase
sort county ym 

// save
save "${dir_root}/texas.dta", replace

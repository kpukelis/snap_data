// tennessee.do 
// Kelsey Pukelis

local ym_start 					= ym(2011,1)
local ym_end 					= ym(2022,9)
local prefix_2011 				"FSPP"
local prefix_2012 				"FSPP"
local prefix_2013 				"FSPP"
local prefix_2014 				"FSPP"
local prefix_2015 				"FSPP"
local prefix_2016 				"SNAP_Participation_"
local prefix_2017 				"SNAP_Participation_"
local prefix_2018 				"SNAP_Participation_"
local prefix_2019 				""
local prefix_2020 				""
local prefix_2021 				""
local prefix_2022 				""
local middle_2011 				""
local middle_2012 				""
local middle_2013 				""
local middle_2014 				""
local middle_2015 				""
local middle_2016 				""
local middle_2017 				""
local middle_2018 				""
local middle_2019 				""
local middle_2020 				""
local middle_2021 				""
local middle_2022 				""
local suffix_2011 				"1"
local suffix_2012 				"1"
local suffix_2013 				"1"
local suffix_2014 				"1"
local suffix_2015 				"1"
local suffix_2016 				""
local suffix_2017 				""
local suffix_2018 				""
local suffix_2019 				" SNAP Participation Report"
local suffix_2020				" SNAP Participation Report"
local suffix_2021				" SNAP Participation Report"
local suffix_2022				" SNAP Participation Report"
local yearname_2011				"11"
local yearname_2012				"12"
local yearname_2013				"13"
local yearname_2014				"14"
local yearname_2015				"15"
local yearname_2016				"_2016"
local yearname_2017				"_2017"
local yearname_2018				"_2018"
local yearname_2019				"2019-"
local yearname_2020 			"2020-"
local yearname_2021 			"2021-"
local yearname_2022 			"2022-"

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

	if inlist(`year',2016,2017,2018) {
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

	// import 
	if inlist(`year',2011,2012,2013,2014,2015,2016,2017,2018) {
		import excel using "${dir_root}/data/state_data/tennessee/excel/`year'/`prefix_`year''`monthname'`yearname_`year''`suffix_`year''.xlsx", case(lower) allstring clear
	}
	else if inlist(`year',2019,2020,2021,2022) {
		import excel using "${dir_root}/data/state_data/tennessee/excel/`year'/`yearname_`year''`monthname'`suffix_`year''.xlsx", case(lower) allstring clear
	}

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// get to first observation
	while !strpos(v1,"Anderson") {
		drop in 1
	}

	if inrange(`ym',ym(2011,1),ym(2013,8)) | inrange(`ym',ym(2013,10),ym(2016,3)) {
		
		// rename 
		describe, varlist 
		assert r(k) == 8
		rename v1 county1 
		rename v2 individuals1
		rename v3 households1
		rename v4 issuance1
		rename v5 county2
		rename v6 individuals2
		rename v7 households2
		rename v8 issuance2
		gen obsnum = _n
	
		// reshape 
		reshape long county individuals households issuance, i(obsnum) j(number)
		drop obsnum number
		dropmiss, force 
		dropmiss, obs force 
		drop if strpos(county,"TOTAL") & missing(individuals) & missing(households) & missing(issuance)
		if inrange(`ym',ym(2014,7),ym(2014,12)) | inrange(`ym',ym(2015,1),ym(2015,12)) {
			// drop what appears to be an unnecessary column total ym(2014,7)
			drop if missing(county) & (inlist(individuals,"602701","597149","590984","592352","582641","586159","581209","566791","570601") | inlist(individuals,"562751","558887","558950","557200","551828","549258","541864"))
		}

		// assert shape 
		describe, varlist 
		assert r(k) == 4
		assert r(N) == 96

		// date 
		gen ym = `ym'
		format ym %tm 

	}
	if inrange(`ym',ym(2017,1),ym(2017,5)) {

		// drop title observations
		drop if strpos(v2,"January")
		drop if strpos(v2,"February")
		drop if strpos(v2,"March")
		drop if strpos(v2,"April")
		drop if strpos(v2,"May")
		drop if strpos(v2,"June")
		drop if strpos(v2,"July")
		drop if strpos(v2,"August")
		drop if strpos(v2,"September")
		drop if strpos(v2,"October")
		drop if strpos(v2,"November")
		drop if strpos(v2,"December")
		drop if v2 == "Individuals"
			
		// rename 
		describe, varlist 
		assert r(k) == 7
		rename v1 county 
		rename v2 individuals1
		rename v3 households1
		rename v4 issuance1
		rename v5 individuals2
		rename v6 households2
		rename v7 issuance2

		// reshape 
		reshape long individuals households issuance, i(county) j(number)
		dropmiss, force 
		dropmiss, obs force 

		// date 
		gen ym = .
		replace ym = `ym' if number == 2
		replace ym = `ym' - 1 if number == 1
		format ym %tm 
		drop number

	}
	if inlist(`ym',ym(2013,9)) | inrange(`ym',ym(2016,4),ym(2016,12)) | inrange(`ym',ym(2017,6),ym(2022,9)) {

		// drop title observations
		drop if strpos(v2,"January")
		drop if strpos(v2,"February")
		drop if strpos(v2,"March")
		drop if strpos(v2,"April")
		drop if strpos(v2,"May")
		drop if strpos(v2,"June")
		drop if strpos(v2,"July")
		drop if strpos(v2,"August")
		drop if strpos(v2,"September")
		drop if strpos(v2,"October")
		drop if strpos(v2,"November")
		drop if strpos(v2,"December")
		drop if v2 == "Individuals"

		// rename 
		describe, varlist 
		assert r(k) == 10
		rename v1 county 
		rename v2 individuals1
		rename v3 households1
		rename v4 issuance1
		rename v5 individuals2
		rename v6 households2
		rename v7 issuance2
		rename v8 individuals3
		rename v9 households3
		rename v10 issuance3

		// reshape 
		reshape long individuals households issuance, i(county) j(number)
		dropmiss, force 
		dropmiss, obs force 

		// date 
		gen ym = .
		replace ym = `ym' if number == 3
		replace ym = `ym' - 1 if number == 2
		replace ym = `ym' - 2 if number == 1
		format ym %tm 
		drop number
	
	}

	// destring 
	foreach var in individuals households issuance {
		replace `var' = ustrregexra(`var',"`","")
		destring `var', replace
		confirm numeric variable `var'
	}

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


// clean up county names 
replace county = lower(county)
replace county = "total" if strpos(county,"total")

// drop duplicates
duplicates drop

// manually drop duplicates
duplicates tag county ym, gen(dup)
drop if county == "knox" & issuance == 684790 & ym == ym(2016,4)
drop if county == "total" & issuance == 131918895 & ym == ym(2016,4)
drop dup 

// assert no more duplicates
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order 
order county ym 
sort county ym 

// save
save "${dir_root}/data/state_data/tennessee/tennessee_county.dta", replace

*******************************************************************************************
*******************************************************************************************
*******************************************************************************************

// APPS DATA 

// import 
import excel using "${dir_root}/data/state_data/tennessee/tennessee_apps.xlsx", case(lower) firstrow allstring clear
rename impute_flag imputed

// destring
foreach var in year month apps_received_snaptanf imputed {
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
save "${dir_root}/data/state_data/tennessee/tennessee_apps.dta", replace

*******************************************************************************************
*******************************************************************************************
*******************************************************************************************

// MERGE DATASETS 

// load data 
use "${dir_root}/data/state_data/tennessee/tennessee_county.dta", clear 

// merge 
merge 1:1 county ym using "${dir_root}/data/state_data/tennessee/tennessee_apps.dta"
assert inlist(_m,1,3)
drop _m 

// order and sort 
order county ym 
sort county ym 

// save
save "${dir_root}/data/state_data/tennessee/tennessee.dta", replace

check



// massachusetts.do
// imports households and persons from excel sheets

// NOTE: these are filenames, but date on the name of the file is 3 months ahead of the data represented in the file itself. 
// E.g. file with name March 2020 contains data for December 2019
local ym_start					= ym(2017,11)
local ym_end 					= ym(2024,5)
local ym_start_county			= ym(2021,7)
local ym_end_county				= ym(2024,5)
local ym_start_scorecard 		= ym(2005,1)
local ym_end_scorecard 			= ym(2024,5)

****************************************************************
/*
///////////////////////
// COUNTY LEVEL DATA //
///////////////////////

// import excel 
import excel using "${dir_root}/data/state_data/massachusetts/excel_county/massachusetts_county.xlsx", sheet("Sheet1") firstrow allstring clear 

// rename 
rename CASES households_
rename CLIENTS individuals_
rename County county

// clean county 
replace county = strlower(county)
replace county = "total" if county == "grand totals" | county == "grand total"

// date 
foreach var in year month {
	destring `var', replace
	confirm numeric variable `var'
}
gen ym = ym(year,month)
format ym %tm 
drop year 
drop month

// type 
replace type = strlower(type)

// destring 
foreach var in households_ individuals_ {
	destring `var', replace 
	confirm numeric variable `var'
}
	
// reshape wide 
reshape wide households_ individuals_, i(county ym) j(type) string 

// rename 
rename households_snap households
rename individuals_snap individuals

// order and sort 
order county ym households individuals households_eaedc individuals_eaedc households_tafdc individuals_tafdc
sort county ym 

// months of data
assert inrange(ym,`ym_start_county',`ym_end_county')

// save 
tempfile massachusetts_county
save `massachusetts_county'
save "${dir_root}/data/state_data/massachusetts/massachusetts_county.dta", replace

//////////////////////////////////
// SCORECARD DATA (STATE LEVEL) //
//////////////////////////////////

// import excel 
import excel using "${dir_root}/data/state_data/massachusetts/excel_gov_agencies/massachusetts_performance_scorecard.xlsx", sheet("data") firstrow allstring clear 

// preserve variable order 
describe, varlist 
local varlist_order `r(varlist)'

// label vars 
renamefrom using "${dir_root}/data/state_data/massachusetts/excel_gov_agencies/massachusetts_performance_scorecard.xlsx", sheet("variable definitions") filetype(excel) raw(variable_name) clean(variable_name) label(variable_description) keepx

// reorder after renamefrom 
order `varlist_order'

// drop miss 
dropmiss, force 
dropmiss, force obs 

// wait time 
split calls_avg_waittime, parse(":")
order calls_avg_waittime?, after(calls_avg_waittime)
rename calls_avg_waittime1 zero 
rename calls_avg_waittime2 calls_avg_waittime_min
rename calls_avg_waittime3 calls_avg_waittime_sec
drop calls_avg_waittime

// destring vars 
foreach var of varlist _all {
	destring `var', replace
	confirm numeric variable `var'
}

// drop vars 
assert inlist(zero,0,.)
drop zero 

// date 
gen ym = ym(year,month)
format ym %tm 
drop year 
drop month 

// city 
gen city = "total"
gen zipcode = "00000"

// order and sort 
order zipcode city ym 
sort zipcode ym 

// assert level of the data
duplicates tag zipcode ym, gen(dup)
assert dup == 0
drop dup 

// save 
tempfile massachusetts_scorecard
save `massachusetts_scorecard'
save "${dir_root}/data/state_data/massachusetts/massachusetts_scorecard.dta", replace
*/

////////////////////////////////
// ENROLLMENT - ZIPCODE LEVEL //
//////////////////////////////// 
/*
forvalues ym = `ym_start'(1)`ym_end' {

	dis in red `ym'

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	gen monthname = ""
	if inrange(`ym',ym(2017,11),ym(2018,12)) | inrange(`ym',ym(2022,1),ym(2024,5)) {
		replace monthname = "JAN" if month == 1
		replace monthname = "FEB" if month == 2
		replace monthname = "MAR" if month == 3
		replace monthname = "APR" if month == 4
		replace monthname = "MAY" if month == 5
		replace monthname = "JUN" if month == 6
		replace monthname = "JUL" if month == 7
		replace monthname = "AUG" if month == 8
		replace monthname = "SEP" if month == 9
		replace monthname = "OCT" if month == 10
		replace monthname = "NOV" if month == 11
		replace monthname = "DEC" if month == 12
	}
	else if inrange(`ym',ym(2019,1),ym(2021,12)) {
		replace monthname = "January" if month == 1
		replace monthname = "February" if month == 2
		replace monthname = "March" if month == 3
		replace monthname = "April" if month == 4
		replace monthname = "May" if month == 5
		replace monthname = "June" if month == 6
		replace monthname = "July" if month == 7
		replace monthname = "August" if month == 8
		replace monthname = "September" if month == 9
		replace monthname = "October" if month == 10
		replace monthname = "November" if month == 11
		replace monthname = "December" if month == 12
	}

	local month = month
	display in red "`month'"
	local year = year 
	display in red "`year'"
	local monthname = monthname
	display in red "`monthname'"

	// for sheet names
	if inlist(`ym',ym(2017,11)) {
		local sheets AU_SNAP SNAP_RECIPIENTS
		local first_sheet AU_SNAP
	}
	else if inrange(`ym',ym(2017,12),ym(2021,11)) {
		local sheets SNAP_AU's SNAP_RECIPIENTS
		local first_sheet SNAP_AU's
	}
	else if inrange(`ym',ym(2021,12),ym(2024,5)) {
		local sheets `"Cases"' /*COUNTY_TOTALS*/
		local first_sheet `"Cases"'
	}
	else {

	}

	// loop through sheets
	foreach sheet of local sheets {

		display in red "`sheet'"
		
		if inlist("`sheet'","AU_SNAP","SNAP_AU's") {
			local varname households 
		}
		else if inlist("`sheet'","SNAP_RECIPIENTS") {
			local varname individuals
		}
		else if inlist(`"`sheet'"',"Cases") {
			local varname households_individuals
		}
		*else if inlist("`sheet'","COUNTY_TOTALS") {
		*	local varname county_totals 
		*}

		// import 
		if `ym' <= ym(2021,11) {
			import excel "${dir_root}/data/state_data/massachusetts/excel/`year'/FINAL_ZIPCODE_`monthname'_`year'.xlsx", sheet("`sheet'") allstring clear 	
		}
		else if `ym' == ym(2021,12) {
			import excel "${dir_root}/data/state_data/massachusetts/excel/`year'/FINAL_ZIPCODE_`monthname'_`year'.xlsx", sheet("Cases & Clients by ZIP Code") allstring clear 	
		}
		else if inrange(`ym',ym(2022,1),ym(2023,7)) {
			import excel "${dir_root}/data/state_data/massachusetts/excel/`year'/DTA_ZIPCODE_Report_`monthname'_`year'.v1.xlsx", sheet(`"Cases & Clients by ZIP Code"') allstring clear 
		}
		else if inrange(`ym',ym(2023,8),ym(2024,5)) {
			import excel "${dir_root}/data/state_data/massachusetts/excel/`year'/DTA_ZIPCODE_Report_`monthname'_`year'.v1.xlsx", sheet(`"Reported Month Caseload Data "') allstring clear 
		}
		else {
			stop 
		}
		
		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber

		*if "`sheet'" == "COUNTY_TOTALS" {

		*	// month that this data represents 
		*	list if strpos(v1,"Data represents")
		*	count if strpos(v1,"Data represents")
		*	if `r(N)' == 1 {
		*		gen year = substr(v2,-4,.) if strpos(v1,"Data represents")
		*		gen monthname = substr(v2,-7,3) if strpos(v1,"Data represents")	
		*	}
		*	list if strpos(v3,"Data represents")
		*	count if strpos(v3,"Data represents")
		*	if `r(N)' == 1 {
		*		gen year = substr(v4,-4,.) if strpos(v3,"Data represents")
		*		gen monthname = substr(v4,-7,3) if strpos(v3,"Data represents")	
		*	}
		*	gen month = ""
		*	replace month = "1" if monthname == "jan" 
		*	replace month = "2" if monthname == "feb" 
		*	replace month = "3" if monthname == "mar" 
		*	replace month = "4" if monthname == "apr" 
		*	replace month = "5" if monthname == "may" 
		*	replace month = "6" if monthname == "jun" 
		*	replace month = "7" if monthname == "jul" 
		*	replace month = "8" if monthname == "aug" 
		*	replace month = "9" if monthname == "sep" 
		*	replace month = "10" if monthname == "oct" 
		*	replace month = "11" if monthname == "nov" 
		*	replace month = "12" if monthname == "dec" 
		*	destring year month, replace 
		*	confirm numeric variable month 
		*	confirm numeric variable year
		*	gen ym = ym(year,month)
*		*	gen ym = `ym' - 3 // simpler, but probably not fool proof
		*	format ym %tm 
		*	drop year month monthname
		*	// expand ym for all observations
		*	sum ym 
		*	assert r(N) == 1
		*	replace ym = r(mean) if missing(ym)
		*
		*	// clean up 
		*	replace v1 = strlower(v1)
		*	replace v2 = strlower(v2)
		*	replace v3 = strlower(v3)
		*	replace v4 = strlower(v4)
		*	replace v5 = strlower(v5)
		*	replace v6 = strlower(v6)
		*	replace v7 = strlower(v7)
		*	describe, varlist 
		*	assert `r(k)' == 8
		*
		*	// rename vars 
		*	rename v1 county 
		*	rename v2 households 
		*	rename v3 households_tafdc
		*	rename v4 households_eaedc 
		*	rename v5 individuals 
		*	rename v6 individuals_tafdc
		*	rename v7 individuals_eaedc 
		*	// rename ym 
		*
		*	// clean up 
		*	while !strpos(county,"county") & !strpos(households,"snap") {
		*		drop in 1
		*	} 
		*	*drop if strpos(county,"(blank)")
		*	drop if strpos(county,"county") & strpos(households,"snap")
		*
		*	// destring 
		*	foreach var in households households_tafdc households_eaedc individuals individuals_tafdc individuals_eaedc {
		*		destring `var', replace
		*		confirm numeric variable `var'
		*	}
		*
		*	// order and sort 
		*	order county ym 
		*	sort county ym 
		*	 
		*	// save 
		*	tempfile _`ym'_`varname'
		*	save `_`ym'_`varname''
		*
		*}
		if inrange(`ym',ym(2021,12),ym(2023,7)) {
		*if inlist("`sheet'",`"Cases & Clients by ZIP Code"') {

			// clean up 
			foreach v of varlist _all {
				replace `v' = strlower(`v')
			}
			while v1 != "zip_code" {
				drop in 1
			}
			drop in 1

			// assert shape of data 
			describe, varlist 
			assert `r(k)' == 9

			// rename vars 
			rename v1 zipcode 
			rename v2 households 
			rename v3 individuals 
			rename v4 households_tafdc
			rename v5 individuals_tafdc
			rename v6 households_eaedc
			rename v7 individuals_eaedc
			rename v8 households_total 
			rename v9 individuals_total

			// destring
			foreach v of varlist households* {
				destring `v', replace 
				confirm numeric variable `v'
			}
			foreach v of varlist individuals* {
				destring `v', replace 
				confirm numeric variable `v'
			}

			// move names around
			replace zipcode = "00000" if zipcode == "grand total"
			replace zipcode = "total" if zipcode == "grand total"

			// make sure zipcode is 5 digits 
			replace zipcode = "0" + zipcode if strlen(zipcode) == 4
			assert strlen(zipcode) == 5 | strlen(zipcode) == 0

			// ym 
			gen ym = `ym'
			format ym %tm 

			// order and sort 
			order zipcode ym 
			sort zipcode ym 

			// save 
			tempfile _`ym'_zip
			save `_`ym'_zip'
			 
		} // end if for ym(2021,12) data

		else if inrange(`ym',ym(2023,8),ym(2024,5)) {


			// turn first row into variable names 
			foreach var of varlist * {
				replace `var' = strlower(`var')
				replace `var' = "_" + `var' if _n == 1
				replace `var' = ustrregexra(`var',"-","") if _n == 1
				*replace `var' = ustrregexra(`var',".","") if _n == 1
				*replace `var' = ustrregexra(`var'," ","") if _n == 1
				label variable `var' "`=`var'[1]'"
				rename `var' `=`var'[1]'
			}
			drop in 1

			// rename 
			rename _cycle_month date 
			rename _au_pgm_cd program 
			rename _city city 
			rename _memb_stat_cd active 
			rename _zip_code zipcode 
			rename _county county 
			rename _cases households 
			rename _clients individuals 
			rename _local_office office 

			// manual drop 
			if `ym' >= ym(2024,1) {
				replace _ = trim(_)
				dropmiss, force
			}

			// assert shape of data 
			describe, varlist 
			assert `r(k)' == 9


			// clean up date 
			split date, parse("/")
			rename date1 month 
			rename date2 day 
			rename date3 year
			foreach var in month day year {
				destring `var', replace 
				confirm numeric variable `var'
			}
			assert day == 1 
			drop day 
			gen ym = ym(year,month)
			format ym %tm 
			sum ym 
			assert `r(max)' == `r(min)' 
			assert `r(mean)' == `ym' 
			drop year 
			drop month 
			drop date 

			// destring 
			foreach var in households individuals {
				destring `var', replace 
				confirm numeric variable `var'
			}

			// active vs closed
			tab active 
			assert inlist(active,"active","closed")

			// list of programs 
			tab program 
			assert inlist(program,"eaedc","tafdc","snap")

			// assert level of the data 
			duplicates tag zipcode program active, gen(dup)
			assert dup == 0 
			drop dup 

			// reshape  
			rename households households_ 
			rename individuals individuals_
			reshape wide households_ individuals_, i(zipcode active) j(program) string 

			// rename snap households, individuals
			rename households_snap households 
			rename individuals_snap individuals

			// keep only active cases for now 
			keep if active == "active"
			drop active 

			// assert level of the data 
			duplicates tag zipcode, gen(dup)
			assert dup == 0
			drop dup 

			// lowercase city 
			replace city = trim(city)
			replace city = strlower(city)
	
			// make sure zipcode is 5 digits 
			replace zipcode = "0" + zipcode if strlen(zipcode) == 4
			assert strlen(zipcode) == 5 | strlen(zipcode) == 0

			// order and sort 
			order zipcode city county office ym 
			sort zipcode ym 

			// save 
			tempfile _`ym'_zip
			save `_`ym'_zip'
		
		}


		if inlist("`sheet'","SNAP_AU's","SNAP_RECIPIENTS","AU_SNAP") {

			// month that this data represents 
			list if strpos(v1,"Data represents")
			count if strpos(v1,"Data represents")
			if `r(N)' == 1 {
				gen year = substr(v2,-4,.) if strpos(v1,"Data represents")
				gen monthname = substr(v2,-7,3) if strpos(v1,"Data represents")	
			}
			list if strpos(v3,"Data represents")
			count if strpos(v3,"Data represents")
			if `r(N)' == 1 {
				gen year = substr(v4,-4,.) if strpos(v3,"Data represents")
				gen monthname = substr(v4,-7,3) if strpos(v3,"Data represents")	
			}
			gen month = ""
			replace month = "1" if monthname == "jan" 
			replace month = "2" if monthname == "feb" 
			replace month = "3" if monthname == "mar" 
			replace month = "4" if monthname == "apr" 
			replace month = "5" if monthname == "may" 
			replace month = "6" if monthname == "jun" 
			replace month = "7" if monthname == "jul" 
			replace month = "8" if monthname == "aug" 
			replace month = "9" if monthname == "sep" 
			replace month = "10" if monthname == "oct" 
			replace month = "11" if monthname == "nov" 
			replace month = "12" if monthname == "dec" 
			destring year month, replace 
			confirm numeric variable month 
			confirm numeric variable year
			gen ym = ym(year,month)
*			gen ym = `ym' - 3 // simpler, but probably not fool proof
			format ym %tm 
			drop year month monthname
			// expand ym for all observations
			sum ym 
			assert r(N) == 1
			replace ym = r(mean) if missing(ym)
	
			// clean up
			replace v1 = strlower(v1)
			replace v2 = strlower(v2)
			replace v3 = strlower(v3)
			while !strpos(v1,"zip code") & !strpos(v2,"city") {
				drop in 1
			} 
			drop if strpos(v1,"(blank)")
			drop if strpos(v1,"zip code") & strpos(v2,"city")
	
			// rename vars 
			describe
			assert r(k) == 4
			rename v1 zipcode 
			rename v2 city 
			rename v3 `varname'
	
			// move names around
			replace zipcode = "total" if zipcode == "grand total"
			replace city = zipcode if zipcode == "total"
			replace zipcode = "" if zipcode == "total"
	
			// lowercase city 
			replace city = trim(city)
			replace city = strlower(city)
	
			// destring
			destring `varname', replace 
			confirm numeric variable `varname'

			// make sure zipcode is 5 digits 
			replace zipcode = "0" + zipcode if strlen(zipcode) == 4
			assert strlen(zipcode) == 5 | strlen(zipcode) == 0

			// drop wrong total 
			sum `varname' if city == "total"
			assert r(N) == 1 | r(N) == 2
			if r(N) == 2 {
				drop if city == "total" & `varname' == r(min)
			}

			// order and sort 
			order zipcode city ym 
			sort zipcode ym 

			// save 
			tempfile _`varname'
			save `_`varname''

		} // end if for data before ym(2021,12)

	} // end sheet loop

	if inrange(`ym',`ym_start',ym(2021,11)) {

		// merge across sheets
		foreach varname in households individuals {
			if "`varname'" == "households" {
				use `_`varname'', clear
			}
			else {
				merge 1:1 zipcode city using `_`varname''
				assert _m == 3 | _m == 2 // because of censoring, some zipcodes are only included in individuals but not households
				drop _m
			}
		}
	
		// save 
		tempfile _`ym'_zip
		save `_`ym'_zip'

	} // end if for data before ym(2021,12)

} // end loop through all ym's 

****************************************************************
/////////////
// ZIPCODE //
/////////////

// append across months 
forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'_zip', clear
	}
	else {
		append using `_`ym'_zip'
	}
}

// order and sort 
order zipcode city ym 
sort zipcode ym 

// save 
tempfile massachusetts_zipcode_first 
save `massachusetts_zipcode_first'
save "${dir_root}/data/state_data/massachusetts/massachusetts_zipcode_first.dta", replace

tab ym 
tab zipcode
*/

****************************************************************
****************************************************************
****************************************************************
****************************************************************

// COLLAPSE TO STATE TOTAL AND COMBINE WTIH SCORECARD DATA 

// collapse 
*use `massachusetts_zipcode_first', clear 
use "${dir_root}/data/state_data/massachusetts/massachusetts_zipcode_first.dta", clear
drop if city == "total" | city == "grand total" | zipcode == "00000"
collapse (sum) households individuals households_eaedc individuals_eaedc households_tafdc individuals_tafdc households_total individuals_total, by(ym)
gen city = "total"
gen zipcode = "00000"
tempfile massachusetts_zipcode_collapsed
save `massachusetts_zipcode_collapsed'
save "${dir_root}/data/state_data/massachusetts/massachusetts_zipcode_collapsed.dta", replace

gen county = "total"
drop city 
drop zipcode	
order county ym 
sort county ym 
save "${dir_root}/data/state_data/massachusetts/massachusetts_county_collapsed.dta", replace


/////////////////
// COUNTY DATA //
/////////////////

// load data 
*use `massachusetts_county', clear 
use "${dir_root}/data/state_data/massachusetts/massachusetts_county.dta", clear
*append using `massachusetts_zipcode_collapsed'
append using "${dir_root}/data/state_data/massachusetts/massachusetts_county_collapsed.dta"

// drop duplicate observations with less information 
duplicates tag county ym, gen(dup)
sort county ym households 
count if dup >= 1
assert `r(N)' == 68 // 40 // 36 // 28

// total sum of data, will catch missingness
egen temp_rowtotal = rowtotal(households individuals households_eaedc individuals_eaedc households_tafdc individuals_tafdc households_total individuals_total)
bysort county ym: egen temp_smallest_rowtotal = min(temp_rowtotal)
count if temp_rowtotal == temp_smallest_rowtotal & dup == 1
assert `r(N)' == 34 // 20 // 18 // 14
drop if temp_rowtotal == temp_smallest_rowtotal & dup == 1
drop temp_rowtotal
drop temp_smallest_rowtotal
drop dup 

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// MERGE IN SCORECARD DATA 
// prep scorecard data 
preserve
	use "${dir_root}/data/state_data/massachusetts/massachusetts_scorecard.dta", clear 
	assert !missing(city)
	assert city == "total"
	rename city county 
	drop zipcode
	tempfile massachusetts_scorecard
	save `massachusetts_scorecard'
restore

// merge
merge 1:1 county ym using `massachusetts_scorecard', update replace 

// check merge 
local ym_end_data = `ym_end' // - 3
local ym_end_data_plus1 = `ym_end_data' + 1
local ym_start_data = `ym_start' - 3
local ym_start_data_minus1 = `ym_start_data' - 1
*br if !inlist(_m,3,4,5) & inrange(ym,`ym_start',min(`ym_end_data',`ym_end_scorecard')) & zipcode == "00000"
// 2020m4, 2022m5, 2021m11 skipped in data reports; no data available
assert inlist(_m,3,4,5) if inrange(ym,`ym_start',min(`ym_end_data',`ym_end_scorecard')) & !inlist(ym,ym(2020,4),ym(2020,5),ym(2021,11)) & county == "total"
assert inrange(ym,ym(2005,1),ym(2017,7)) | inlist(ym,ym(2020,4),ym(2020,5),ym(2021,11)) if inlist(_m,2)
assert inlist(_m,1) if county != "total" // | ym == ym(2022,12)
drop _m 

// order and sort 
order county ym 
sort county ym 

// save
save "${dir_root}/data/state_data/massachusetts/massachusetts.dta", replace

//////////////////
// ZIPCODE DATA //
//////////////////

// combine zipcode level with collapsed data 
*use `massachusetts_zipcode_first', clear 
use "${dir_root}/data/state_data/massachusetts/massachusetts_zipcode_first.dta", clear 
gen source = "zipcode_level"
*drop if city == "total" | city == "grand total"
*drop if zipcode == "00000"
*append using `massachusetts_zipcode_collapsed'
append using "${dir_root}/data/state_data/massachusetts/massachusetts_zipcode_collapsed.dta"
replace source = "collapsed" if missing(source)

// decide with duplicates to keep 
duplicates tag zipcode ym, gen(dup)
tab dup 
assert inlist(dup,0,1)
sort zipcode ym
*br if dup == 1

// if there is a duplicate, keep collapsed source 
// for consistency (doesn't really matter)
count if dup == 1 & source == "zipcode_level"
assert `r(N)' == 20 // 16 // 14 // 10
drop if dup == 1 & source == "zipcode_level"
drop dup 

// assert level of data 
duplicates tag zipcode ym, gen(dup)
assert dup == 0
drop dup 

// merge in scorecard data 
*merge 1:1 zipcode ym using `massachusetts_scorecard', update replace 
merge 1:1 zipcode ym using "${dir_root}/data/state_data/massachusetts/massachusetts_scorecard.dta", update replace 

// check merge 
local ym_end_data = `ym_end' // - 3
local ym_end_data_plus1 = `ym_end_data' + 1
local ym_start_data = `ym_start' - 3
local ym_start_data_minus1 = `ym_start_data' - 1
*br if !inlist(_m,3,4,5) & inrange(ym,`ym_start',min(`ym_end_data',`ym_end_scorecard')) & zipcode == "00000"
// 2020m4, 2022m5, 2021m11 skipped in data reports; no data available
assert inlist(_m,3,4,5) if inrange(ym,`ym_start',min(`ym_end_data',`ym_end_scorecard')) & !inlist(ym,ym(2020,4),ym(2020,5),ym(2021,11)) & zipcode == "00000"
assert inlist(_m,2) if inrange(ym,`ym_start_scorecard',`ym_start_data_minus1') | inrange(ym,`ym_end_data_plus1',`ym_end_scorecard') | inlist(ym,ym(2020,4),ym(2020,5),ym(2021,11))
assert inlist(_m,1) if zipcode != "00000" // | ym == ym(2022,9)
drop _m 

// order and sort 
order zipcode city ym 
sort zipcode ym 

// save
save "${dir_root}/data/state_data/massachusetts/massachusetts_zipcode.dta", replace


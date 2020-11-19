// massachusetts.do
// imports households and persons from excel sheets

// NOTE: these are filenames, but date on the name of the file is 3 months ahead of the data represented in the file itself. 
// E.g. file with name March 2020 contains data for December 2019
local ym_start					= ym(2017,11)
local ym_end 					= ym(2020,4)

****************************************************************

forvalues ym = `ym_start'(1)`ym_end' {

	dis in red `ym'

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	gen monthname = ""
	if inrange(`ym',ym(2017,11),ym(2018,12)) {
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
	else if inrange(`ym',ym(2019,1),ym(2020,4)) {
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
	else if inrange(`ym',ym(2017,12),ym(2020,4)) {
		local sheets SNAP_AU's SNAP_RECIPIENTS
		local first_sheet SNAP_AU's
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
		// import 
		import excel "${dir_root}/state_data/massachusetts/excel/`year'/FINAL_ZIPCODE_`monthname'_`year'.xlsx", sheet("`sheet'") allstring clear 

		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber

		// month that this data represents 
		list if strpos(v1,"Data represents caseload")
		gen year = substr(v2,-4,.) if strpos(v1,"Data represents caseload")
		gen monthname = substr(v2,-7,3) if strpos(v1,"Data represents caseload")
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
*		gen ym = `ym' - 3 // simpler, but probably not fool proof
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
		replace city = zipcode if zipcode == "grand total"
		replace zipcode = "" if zipcode == "grand total"

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
		sum `varname' if city == "grand total"
		assert r(N) == 1 | r(N) == 2
		if r(N) == 2 {
			drop if city == "grand total" & `varname' == r(min)
		}

		// order and sort 
		order zipcode city ym 
		sort zipcode ym 

		// save 
		tempfile _`varname'
		save `_`varname''
		
	}

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
	tempfile _`ym'
	save `_`ym''
}

****************************************************************

// append across months 
forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// order and sort 
order zipcode city ym 
sort zipcode ym 

// save 
save "${dir_root}/state_data/massachusetts/massachusetts.dta", replace

tab ym 
tab zipcode

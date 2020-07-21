// ohio.do

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/ohio"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local ym_start	 				= ym(2002,6)
local ym_end 					= ym(2020,4)

************************************************************
forvalues ym = `ym_start'(1)`ym_end' {
if `ym' != ym(2018,9) {

	// display
	dis in red `ym'

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen year_short = year - 2000
	tostring year_short, replace 
	replace year_short = "0" + year_short if strlen(year_short) == 1
	gen month = month(dofm(`ym'))
	local month = month 
	display in red "`month'"
	gen monthname = ""
	if inrange(`ym',ym(2017,1),ym(2017,12)) | inrange(`ym',ym(2019,1),ym(2019,12)) | `ym' >= ym(2020,1) {
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
	else {
		tostring month, replace 
		replace monthname = month
		replace monthname = "0" + monthname if strlen(monthname) == 1
	}
	local monthname = monthname
	display in red "`monthname'"
	local year_short = year_short 
	display in red "`year_short'"
	local year = year 
	display in red "`year'"

	// import 
	if inrange(`ym',ym(2002,6),ym(2006,12)) {
		import excel using "${dir_root}/excel/`year'/binder/Document Cloud/`monthname'`year'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2007,1),ym(2016,12)) {
		import excel using "${dir_root}/excel/`year'/binder/Document Cloud/PAMS`year'-`monthname'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2017,1),ym(2017,12)) {
		import excel using "${dir_root}/excel/`year'/binder/Document Cloud/PAMS_`monthname'_`year'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2018,1),ym(2018,12)) {
		import excel using "${dir_root}/excel/`year'/binder/Document Cloud/Updated PAMS `year'_`monthname'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2019,1),ym(2019,12)) {
		import excel using "${dir_root}/excel/`year'/binder/Document Cloud/Case Load Summary Report `monthname' `year'.pdf_short.xlsx", case(lower) allstring clear
	}
	else {
		import excel using "${dir_root}/excel/`year'/binder/Document Cloud/Caseload Summary Report `monthname' `year'.pdf_short.xlsx", case(lower) allstring clear
	}
	
	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// trim all variables 
	foreach v of varlist _all {
		replace `v' = trim(`v')
		replace `v' = stritrim(`v')
		replace `v' = subinstr(`v', "`=char(9)'", " ", .)
		replace `v' = subinstr(`v', "`=char(13)'", " ", .)
		replace `v' = subinstr(`v', "`=char(14)'", " ", .)
	}

	// drop title rows 
	drop if strpos(v1,"TABLE 5")
	drop if strpos(v1,"Table 5")
	drop if strpos(v1,"Table 3")
	drop if strpos(v1,"OHIO COUNTY")
	drop if v1 == "COUNTY"
	drop if v2 == "Persons"
	drop if strpos(v1,"Program Detail: Supplemental Nutrition Assistance Program")
	drop if v1 == "SNAP"
	drop if strpos(v1,"Issuance") & strpos(v1,"County") 
	drop if strpos(v2,"PUBLIC") & strpos(v2,"ASSISTANCE")
	drop if strpos(v2,"Public") & strpos(v2,"Assistance")
	drop if strpos(v1,"Source: CRIS-E GRP304RA and GRP 304RC Reports from Management Information Services.")
	drop if strpos(v1,"Source: CRIS-E GRP304RA and GRP 304RC Reports from Office of Information Services.")
	drop if strpos(v1,"Source: CRIS‐E GRP304RA and GRP 304RC Reports from Office of Information Services.")
	drop if v1 == "Page 31"
	drop if v1 == "Page 32"
	drop if v1 == "Page 33"
	drop if strpos(v1,"Page 18")
	drop if strpos(v1,"Page 19")
	drop if strpos(v1,"Page 20")
	drop if strpos(v1,"Page 21")

	// dropmiss remaining
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// make all variables easier to browse
	foreach v of varlist _all {

		gen `v'_copy = `v'
		order `v'_copy, after(`v')
		drop `v'
		rename `v'_copy `v'
	}

	// dropmiss remaining
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	duplicates drop 

	// assert size of data 
	describe, varlist
	if `ym' <= ym(2013,3) {
		assert `r(N)' == 89
	}
	else if inrange(`ym',ym(2013,4),ym(2014,1)) {
		assert `r(N)' == 90
	}
	else if inrange(`ym',ym(2014,2),ym(2018,8)) {
		assert `r(N)' == 91	
	}
	else if inlist(`ym',ym(2020,2),ym(2020,4)) {
		assert `r(N)' == 87 
	}
	else {
		assert `r(N)' == 86		
	}
	if `ym' <= ym(2010,9) {
		assert `r(k)' == 10
		// rename vars 
		rename v1 county 
		rename v2 persons_pa
		rename v3 persons_npa 
		rename v4 persons
		rename v5 avg_issuance_persons
		rename v6 percchange_prevmonth_person
		rename v7 households_pa
		rename v8 households_npa
		rename v9 households
		rename v10 issuance
	}
	else if inrange(`ym',ym(2010,10),ym(2018,8)) {
		assert `r(k)' == 12
		// rename vars 
		rename v1 county 
		rename v2 persons_pa
		rename v3 persons_npa 
		rename v4 persons
		rename v5 avg_issuance_persons
		rename v6 percchange_prevmonth_person
		rename v7 households_pa
		rename v8 households_npa
		rename v9 households
		rename v10 avg_issuance_households
		rename v11 percchange_prevmonth_households
		rename v12 issuance
	}
	else {
		assert `r(k)' == 5
		// rename vars 
		rename v1 county 
		rename v2 households
		rename v3 persons
		rename v4 adults
		rename v5 children
	}

	// drop unnecessary vars 
	capture drop percchange_prevmonth_person
	capture drop percchange_prevmonth_households

	// destring 
	foreach var in persons_pa persons_npa persons households_pa households_npa households issuance avg_issuance_persons avg_issuance_households adults children {
 		capture confirm variable `var'
		if !_rc {
			replace `var' = ustrregexra(`var'," ","")
			replace `var' = ustrregexra(`var',",","")
			replace `var' = ustrregexra(`var',"N.A.","")
			replace `var' = ustrregexra(`var',"NA","")
			replace `var' = ustrregexra(`var',"#REF!","")
			destring `var', replace
			confirm numeric variable `var'
			replace `var' = . if `var' == 0
		}
	}

	// clean up county 
	replace county = strlower(county)
	replace county = trim(county)
	replace county = ustrregexra(county," ","")
	replace county = "statewide" if county == "ohio"

	// ym 
	gen ym = ym(`year',`month')
	format ym %tm

	// order and sort 
	order county ym households persons
	sort county ym 

	// save 
	tempfile _`ym'
	save `_`ym''
}
}

// append years 
forvalues ym = `ym_start'(1)`ym_end' {
if `ym' != ym(2018,9) {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}
}

// order and sort 
order county ym persons_pa persons_npa persons households_pa households_npa households issuance avg_issuance_persons avg_issuance_households adults children
sort county ym 

// save 
save "${dir_data}/ohio.dta", replace 

// check county
tab county

// assert everything adds up 
assert persons_pa + persons_npa == persons if !missing(persons_pa)
assert households_pa + households_npa == households if !missing(households_pa)


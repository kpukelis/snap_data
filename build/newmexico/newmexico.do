// newmexico.do 
// Kelsey Pukelis

local ym_start 					= ym(2013,1) 
local ym_end 					= ym(2020,11)

local ym_start_apps 			= ym(2019,1) // could get data earlier
local ym_end_apps 				= ym(2022,3)

local ym_start_race 			= ym(2019,1) // could get data earlier
local ym_end_race 				= ym(2022,3)

**************************************************************************

///////////////
// RACE DATA //
///////////////

forvalues ym = `ym_start_race'(1)`ym_end_race' {

	// display ym 
	display in red "`ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, gen(monthname) 
	tostring month, gen(monthname_var) 
	replace monthname = "January" if monthname == "1"
	replace monthname = "February" if monthname == "2"
	replace monthname = "March" if monthname == "3"
	replace monthname = "April" if monthname == "4"
	replace monthname = "May" if monthname == "5"
	replace monthname = "June" if monthname == "6"
	replace monthname = "July" if monthname == "7"
	replace monthname = "August" if monthname == "8"
	replace monthname = "September" if monthname == "9"
	replace monthname = "October" if monthname == "10"
	replace monthname = "November" if monthname == "11"
	replace monthname = "December" if monthname == "12"
	local month = month
	display in red "`month'"
	local monthname = monthname
	display in red "`monthname'"
	local monthname_var = monthname_var
	display in red "`monthname_var'"
	local year = year
	display in red "`year'"

	// load data 
	import excel "${dir_root}/data/state_data/newmexico/excel_race/`year'/MSR_`monthname'_`year'.xlsx", allstring case(lower) firstrow clear 

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// keep relevant cells 
	drop if strpos(v1,"Medicaid demographic data can be found here:")
	dropmiss, force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	assert `r(k)' == 6
	assert inlist(`r(N)',31,32)
	if `r(N)' == 31 {
		keep if _n >= 16	
	}
	else if `r(N)' == 32 {
		keep if _n >= 17
	}
	
	drop v3
	drop v4 
	drop v5 
	drop v6
	drop if strpos(v1,"Demographic Profile")
	drop if strpos(v1,"Gender of Recipients")
	drop if strpos(v1,"Ethnicity 10")
	drop if strpos(v1,"Race 10")
	drop in 1
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	assert `r(k)' == 2
	assert `r(N)' == 11
	rename v1 variable 
	rename v2 value 
	replace variable = ustrregexra(variable," ","")
	replace variable = ustrregexra(variable,"-","")
	replace variable = ustrregexra(variable,"/","")
	replace variable = strlower(variable)
	replace variable = substr(variable,1,25)
	*replace variable = "_" + variable
	destring value, replace
	confirm numeric variable value
	rename value _
	gen id = 1
	reshape wide _, i(id) j(variable) string 
	drop id 
	rename _africanamericanorblack 			race_africanamericanorblack
	rename _asian 							race_asian
	rename _female 							gender_female
	rename _hispanic 						ethnicity_hispanic
	rename _male 							gender_male
	rename _morethanonerace 				race_morethanonerace
	rename _nativeamericanoralaskanna	 	race_nativeamericanoralaskanna
	rename _nativehawaiianorpacificis		race_nativehawaiianorpacificis
	rename _nonhispanic 					ethnicity_nonhispanic
	rename _unknownnotdeclared 				race_unknownnotdeclared
	rename _white 							race_white

	// ym 
	gen ym = `ym'
	format ym %tm 
	order ym 

	// county 
	gen county = "total"

	// order 
	order county ym gender_* ethnicity_* race_*
	// save 

	tempfile _`ym'
	save `_`ym''
	
}

// append 
forvalues ym = `ym_start_race'(1)`ym_end_race' {
	if `ym' == `ym_start_race' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// save 
tempfile newmexico_race
save `newmexico_race'

//////////////
// APP DATA //
//////////////

forvalues ym = `ym_start_apps'(1)`ym_end_apps' {

	// display ym 
	display in red "`ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, gen(monthname) 
	tostring month, gen(monthname_var) 
	replace monthname = "January" if monthname == "1"
	replace monthname = "February" if monthname == "2"
	replace monthname = "March" if monthname == "3"
	replace monthname = "April" if monthname == "4"
	replace monthname = "May" if monthname == "5"
	replace monthname = "June" if monthname == "6"
	replace monthname = "July" if monthname == "7"
	replace monthname = "August" if monthname == "8"
	replace monthname = "September" if monthname == "9"
	replace monthname = "October" if monthname == "10"
	replace monthname = "November" if monthname == "11"
	replace monthname = "December" if monthname == "12"
	local month = month
	display in red "`month'"
	local monthname = monthname
	display in red "`monthname'"
	local monthname_var = monthname_var
	display in red "`monthname_var'"
	local year = year
	display in red "`year'"

	// load data 
	import excel "${dir_root}/data/state_data/newmexico/excel/`year'/MSR_`monthname'_`year'-3.xlsx", allstring case(lower) firstrow clear 

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// keep relevant cells 
	drop if strpos(v1,"SNAP, TANF and GA-Unrelated Child Program interview s are w aived. Recertification periods are automatically extended for households w ith an Interim Review  due in March and April for")
	drop if strpos(v1,"Note: December 2020 expenditures include the LIHEAP $300 supplement payments that were tied to prior months since May 2020. The additional expenditures are reflected in the total cases and recipients reported.")
	drop if strpos(v1,"The March 2021 SNAP expenditures include COVID-19 additional Emergency Allotment")
	drop if strpos(v1,"SNAP, TANF and GA-Unrelated Child Program interview")
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	assert `r(N)' == 25
	keep if _n <= 12
	describe, varlist 
	assert `r(k)' == 12
	keep v7 v10
	drop in 1
	drop in 1
	drop in 1
	describe, varlist 
	assert `r(k)' == 2
	rename v7 variable  
	rename v10 value 
	
	// clean up variable name 
	replace variable = trim(variable)
	replace variable = strlower(variable)
	replace variable = ustrregexra(variable," ","")
	replace variable = ustrregexra(variable,"4","")
	replace variable = ustrregexra(variable,"5","")
	replace variable = ustrregexra(variable,"6","")
	replace variable = ustrregexra(variable,"7","")
	replace variable = ustrregexra(variable,"/","per")
	assert inlist(variable,"expenditures","cases","expenditurespercase","recipients","adults","children","recipientspercase","casesprocessed","approvals")

	// destring
	destring value, replace
	confirm numeric variable value 

	// reshape
	gen id = 1
	rename value _
	reshape wide _, i(id) j(variable) string
	drop id 

	// rename some vars to be consistent 
	rename _expenditures issuance
	rename _cases households
	rename _expenditurespercase avg_issuance_households
	rename _recipients individuals
	rename _adults adults
	rename _children children
	rename _recipientspercase avg_issuance_individuals
	rename _casesprocessed apps_received
	rename _approvals apps_approved

	// ym 
	gen ym = `ym'
	format ym %tm 
	order ym 

	// county 
	gen county = "total"

	// order 
	order county ym 
	// save 
	tempfile _`ym'
	save `_`ym''
	
}

// append 
forvalues ym = `ym_start_apps'(1)`ym_end_apps' {
	if `ym' == `ym_start_apps' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// save 
tempfile newmexico_apps
save `newmexico_apps'


**************************************************************************************************************
**************************************************************************************************************
**************************************************************************************************************
**************************************************************************************************************

/////////////////////
// ENROLLMENT DATA //
/////////////////////

forvalues ym = `ym_start'(1)`ym_end' {
if !inrange(`ym',ym(2013,7),ym(2014,1)) & !inrange(`ym',ym(2014,4),ym(2014,6)) {

	// display ym 
	display in red "`ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, gen(monthname) 
	tostring month, gen(monthname_var) 
	if inrange(`ym',ym(2013,1),ym(2017,4)) {
		replace monthname = "0" + monthname if strlen(monthname) == 1
	}
	else if inrange(`ym',ym(2017,5),ym(2017,12)) | inrange(`ym',ym(2018,7),ym(2018,12)) | (`ym' >= ym(2019,1)) {
		replace monthname = "January" if monthname == "1"
		replace monthname = "February" if monthname == "2"
		replace monthname = "March" if monthname == "3"
		replace monthname = "April" if monthname == "4"
		replace monthname = "May" if monthname == "5"
		replace monthname = "June" if monthname == "6"
		replace monthname = "July" if monthname == "7"
		replace monthname = "August" if monthname == "8"
		replace monthname = "September" if monthname == "9"
		replace monthname = "October" if monthname == "10"
		replace monthname = "November" if monthname == "11"
		replace monthname = "December" if monthname == "12"
	}
	else if inrange(`ym',ym(2018,1),ym(2018,6)) {
		replace monthname = "Jan" if monthname == "1"
		replace monthname = "Feb" if monthname == "2"
		replace monthname = "Mar" if monthname == "3"
		replace monthname = "Apr" if monthname == "4"
		replace monthname = "May" if monthname == "5"
		replace monthname = "Jun" if monthname == "6"
		replace monthname = "Jul" if monthname == "7"
		replace monthname = "Aug" if monthname == "8"
		replace monthname = "Sep" if monthname == "9"
		replace monthname = "Oct" if monthname == "10"
		replace monthname = "Nov" if monthname == "11"
		replace monthname = "Dec" if monthname == "12"
	}
	replace monthname_var = "jan" if monthname_var == "1"
	replace monthname_var = "feb" if monthname_var == "2"
	replace monthname_var = "mar" if monthname_var == "3"
	replace monthname_var = "apr" if monthname_var == "4"
	replace monthname_var = "may" if monthname_var == "5"
	replace monthname_var = "jun" if monthname_var == "6"
	replace monthname_var = "jul" if monthname_var == "7"
	replace monthname_var = "aug" if monthname_var == "8"
	replace monthname_var = "sep" if monthname_var == "9"
	replace monthname_var = "oct" if monthname_var == "10"
	replace monthname_var = "nov" if monthname_var == "11"
	replace monthname_var = "dec" if monthname_var == "12"
	local month = month
	display in red "`month'"
	local monthname = monthname
	display in red "`monthname'"
	local monthname_var = monthname_var
	display in red "`monthname_var'"
	local year = year
	display in red "`year'"

	// load data 
	if inrange(`ym',ym(2013,1),ym(2014,12)) {
		import delimited "${dir_root}/data/state_data/newmexico/excel_og/`year'/tabula-MSR_`monthname'_`year'_data.pdf_short.csv", stringcols(_all) case(lower) varnames(1) clear 
	}
	else if inrange(`ym',ym(2015,1),ym(2017,3)) {
		import delimited "${dir_root}/data/state_data/newmexico/excel_og/`year'/tabula-MSR_`monthname'_`year'.pdf_short.csv", stringcols(_all) case(lower) varnames(1) clear 
	}
	else if inrange(`ym',ym(2017,4),ym(2017,4)) | (`ym' >= ym(2019,1)) {
		import excel "${dir_root}/data/state_data/newmexico/excel_og/`year'/MSR_`monthname'_`year'.pdf_short.xlsx", allstring case(lower) firstrow clear 
	}
	else if inrange(`ym',ym(2017,5),ym(2017,12)) {
		import excel "${dir_root}/data/state_data/newmexico/excel_og/`year'/`monthname'`year'_MSR.pdf_short.xlsx", allstring case(lower) firstrow clear 
	}
	else if inrange(`ym',ym(2018,7),ym(2018,12)) {
		import excel "${dir_root}/data/state_data/newmexico/excel_og/`year'/MSR_`monthname'`year'_Final.pdf_short.xlsx", allstring case(lower) firstrow clear 
	}
	else if inrange(`ym',ym(2018,1),ym(2018,6)) {
		import excel "${dir_root}/data/state_data/newmexico/excel_og/`year'/`monthname'`year'_MSR.pdf_short.xlsx", allstring case(lower) firstrow clear 
	}

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// drop top vars 
	if inrange(`ym',ym(2013,1),ym(2014,1)) {
		while !strpos(v1,"County") {
			drop in 1
		}
	}
	else if `ym' >= ym(2014,2) {
		while !strpos(v1,"Office") {
			drop in 1
		}
	}

	// rename variables
	if inrange(`ym',ym(2013,1),ym(2014,1)) {
		rename v1 county 
	}
	else if `ym' >= ym(2014,2) {
		rename v1 office 
	}
	rename v2 households_yearbefore
	rename v3 households_monthbefore
	rename v4 households_now 
	rename v5 households_percchangeyear
	rename v6 households_percchangemonth
	drop in 1

	// drop unnecessary variables 
	drop households_percchangeyear households_percchangemonth
	if inrange(`ym',ym(2016,1),ym(2016,4)) | inlist(`ym',ym(2014,7),ym(2016,7)) {
		capture drop v7
		capture drop v8
		capture drop v9
		capture drop v10
		capture drop v11
	}

	// assert number of variables 
	describe, varlist 
	assert r(k) == 4

	// cleaning involving the county var
	capture confirm variable county
	if !_rc {
		// county lowercase 
		replace county = strlower(county)
		*replace county = "statewide total" if county == "total"
		replace county = "total" if county == "statewide total"
		replace county = "centralized units" if county == "centralized units^"
		replace county = "mckinley" if county == "mckinley*"

		// reshape long 
		reshape long households, i(county) j(_time) string 
	}

	// cleaning involving the office var
	capture confirm variable office
	if !_rc {
		// drop bad observations
		drop if office == "10"
		drop if office == "12"
		drop if office == "14"
		drop if office == "16"
		drop if office == "18"
		drop if office == "19"
		drop if office == "20"
		drop if office == "21"
		drop if office == "22"
		drop if office == "23"
		drop if office == "24"
		drop if office == "25"
		drop if office == "26"

		// office lowercase 
		replace office = strlower(office)
		*replace office = "statewide total" if office == "total" | office == "1.0% total"
		replace office = "total" if office == "1.0% total" | office == "statewide total"

		// clean up office 
		replace office = "centralized units" if office == "centralized units^"
		replace office = "mckinley" if office == "mckinley*"
		replace office = ustrregexra(office," county isd","")
		replace office = "south dona ana" if office == "south dona ana isd"

		// generate associated county 
		gen county = office 
	
		// reshape long 
		reshape long households, i(office) j(_time) string 

	}

	// ym 
	gen ym = .
	replace ym = `ym' + 0  if _time == "_now"
	replace ym = `ym' - 12 if _time == "_yearbefore"
	replace ym = `ym' - 1  if _time == "_monthbefore"
	format ym %tm 
	drop _time

	// source of data 
	gen source_ym = `ym'
	format source_ym %tm

	// destring 
	foreach var in households {
		replace `var' = ustrregexra(`var',",","")
		replace `var' = ustrregexra(`var',"-","")
		destring `var', replace
		confirm numeric variable `var'
	}

	// end code 
	if inrange(`ym',ym(2013,1),ym(2014,1)) {
	
		// assert shape 
		count 
		assert `r(N)' == 102
		
		// order and sort 
		order county county ym households source_ym
		sort county ym source_ym

	}
	else if inrange(`ym',ym(2014,2),ym(2017,3)) {
	
		// assert shape 
		count 
		assert `r(N)' == 111
	
		// order and sort 
		order office county ym households source_ym
		sort office ym source_ym
	
	}
	else if `ym' >= ym(2017,4) {
	
		// assert shape 
		count 
		assert `r(N)' == 108
	
		// order and sort 
		order office county ym households source_ym
		sort office ym source_ym
	
	}


	// save 
	tempfile _`ym'
	save `_`ym''
	
}
}

// append 
forvalues ym = `ym_start'(1)`ym_end' {
if !inrange(`ym',ym(2013,7),ym(2014,1)) & !inrange(`ym',ym(2014,4),ym(2014,6)) {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}
}

// DUPLICATES 

// drop if households is missing 
drop if missing(households)

// drop exact duplicates
duplicates drop county ym households if  inrange(ym,ym(2013,1),ym(2014,1)), force 
duplicates drop office ym households if !inrange(ym,ym(2013,1),ym(2014,1)), force 

// dropping duplicates, keeping observations that comes from the source ym 
// duplicates office 
bysort office ym: gen numobs = _N
count if numobs == 2
assert `r(N)' == 90
drop if numobs == 2 & source_ym != ym 
count if numobs == 33
assert `r(N)' == 33
count if numobs == 34
assert `r(N)' == 408
drop numobs
bysort office ym: gen numobs_office = _N
// duplicates county 
bysort county ym: gen numobs = _N
tab numobs
drop if numobs == 2 & missing(office)
drop if numobs == 2 & !strpos(office," isd")
drop numobs
bysort county ym: gen numobs_county = _N

// assert level of the data
assert numobs_county == 1 | numobs_office == 1

// order and sort 
order office county ym households 
sort office county ym 

// save
tempfile newmexico_enrollment
save `newmexico_enrollment'

******************************************************************************************************************************************************

// merge 
use `newmexico_apps', clear
merge 1:1 county ym using `newmexico_race'
assert _m == 3 // this will not be the case if one of these datasets is updated 
drop _m 

// since households is in both, just use households from county 
drop households 
merge 1:1 county ym using `newmexico_enrollment', update 
assert _m !=5 
drop _m 

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// save 
save "${dir_root}/data/state_data/newmexico/newmexico.dta", replace



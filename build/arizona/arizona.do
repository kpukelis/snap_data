// arizona.do
// imports cases and clients from csvs
// Note: 2012m10 greenlee data missing from pdf

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/arizona"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local ym_start	 				= ym(2006,4)
local ym_end 					= ym(2020,3)

************************************************************

forvalues ym = `ym_start'(1)`ym_end' {

	dis in red `ym'

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace 
	replace month = "0" + month if strlen(month) == 1
	local month = month
	display in red "`month'"
	local year = year 
	display in red "`year'"

	// import 
	else if inrange(`ym',ym(2006,4),ym(2008,12)) {
		import delimited using "${dir_root}/csvs/tabula-dbme-statistical-bulletin-`month'-`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2009,1),ym(2014,12)) {
		import delimited using "${dir_root}/csvs/tabula-dbme_statistical_bulletin_`month'_`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2015,1),ym(2017,12)) {
		import delimited using "${dir_root}/csvs/tabula-dbme_statistical_bulletin_`month'_`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2018,1),ym(2018,12)) {
		import delimited using "${dir_root}/csvs/tabula-dbme-statistical-bulletin-`month'-`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else {
		import delimited using "${dir_root}/csvs/tabula-dbme-statistical_bulletin-`month'-`year'.csv", delimiters(",") case(lower) stringcols(_all) clear		
	}

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// drop headers
	while !strpos(v2,"HOUSEHOLDS") & !strpos(v2,"households") & !strpos(v2,"Households") {
		drop in 1
	}
	*drop if v6 == "Household" & v7 == "Person"
	dropmiss, force
	count if missing(v1)
	assert r(N) == 1 | r(N) == 2
	replace v1 = "county" if missing(v1)

	// split variables 
	if inrange(`ym',ym(2006,9),ym(2006,12)) | inlist(`ym',ym(2007,2)) | inrange(`ym',ym(2007,9),ym(2008,2)) {
		replace v4 = trim(v4)
		split v4, parse(" ")
		drop v4 
		rename v5 v6 
		rename v41 v4 
		rename v42 v5 
		order v1 v2 v3 v4 v5 v6 
	}
	if inlist(`ym',ym(2009,12)) {
		replace v2 = trim(v2)
		split v2, parse(" ")
		drop v2 
		order v1 v21 v22
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
	}
	if inlist(`ym',ym(2010,1),ym(2010,8),ym(2010,10),ym(2011,1),ym(2011,2),ym(2011,8),ym(2011,10),ym(2011,12),ym(2012,9)) | inrange(`ym',ym(2012,1),ym(2012,3)) | inrange(`ym',ym(2016,9),ym(2020,3)) {
		replace v5 = trim(v5)
		split v5, parse(" ")
		order v51 v52, after(v5)
		drop v5 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber		
	}
	if inlist(`ym',ym(2010,2),ym(2010,9),ym(2010,11),ym(2010,12),ym(2011,9),ym(2011,11)) {
		replace v4 = trim(v4)
		split v4, parse(" ")
		order v41 v42 v43, after(v4)
		drop v4 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber		
	}
	if inrange(`ym',ym(2016,9),ym(2020,3)) {
		drop v9
	}

	// turn first row into variable names 
	if inrange(`ym',ym(2006,4),ym(2009,11)) {
		describe, varlist
		assert r(k) == 6
		rename v1 county 
		rename v2 households
		rename v3 persons
		rename v4 totalissuance
		rename v5 issuancehousehold
		rename v6 issuanceperson
		drop in 1
		replace county = strlower(county)
	}
	else if inrange(`ym',ym(2009,12),ym(2020,3)) {
		describe, varlist 
		assert r(k) == 8
		rename v1 county 
		rename v2 households
		rename v3 persons
		rename v4 adults
		rename v5 children
		rename v6 totalissuance
		rename v7 issuancehousehold
		rename v8 issuanceperson
		drop in 1
		if inrange(`ym',ym(2012,10),ym(2020,3)) & !inlist(`ym',ym(2014,8)) {
			drop in 1
		}
		replace county = strlower(county)
	}
	else {
		foreach var of varlist * {
			replace `var' = "`=`var'[1]'" + " " + "`=`var'[2]'" if _n == 1
			replace `var' = strlower(`var')
			replace `var' = ustrregexra(`var',"-","") if _n == 1
			replace `var' = ustrregexra(`var',"/","") if _n == 1
			replace `var' = ustrregexra(`var'," ","") if _n == 1
			replace `var' = trim(`var')
			label variable `var' "`=`var'[1]'"
			rename `var' `=`var'[1]'
		}
		rename countycounty county 
		drop in 1
		drop in 1
	}

	// clean up county names
	drop if county == "total"
	replace county = "total" if inlist(county,"grand total","arizona")

	// number of variables 
	qui describe
	if inrange(`ym',ym(2009,12),ym(2020,3)) {
		assert r(k) == 7 | r(k) == 8
		if r(k) == 7 {
			split childrentotalissuance, parse("$")
			rename childrentotalissuance1 children
			rename childrentotalissuance2 totalissuance
			drop childrentotalissuance
		}
		qui describe 
		assert r(k) == 8
	}
	else if inrange(`ym',ym(2006,4),ym(2009,11)) {
		assert r(k) == 6 
	}

	// manual fixes 
	if inlist(`ym',ym(2012,9)) {
		replace issuanceperson = trim(issuanceperson)
		replace issuanceperson = "122.54" if strpos(issuanceperson,"122") & strpos(issuanceperson,"54")
		replace issuanceperson = "124.52" if strpos(issuanceperson,"124") & strpos(issuanceperson,"52")
		replace issuanceperson = "123.98" if strpos(issuanceperson,"123") & strpos(issuanceperson,"98")
		replace issuanceperson = "129.39" if strpos(issuanceperson,"129") & strpos(issuanceperson,"39")
		replace issuanceperson = "128.25" if strpos(issuanceperson,"128") & strpos(issuanceperson,"25")
		replace issuanceperson = "124.58" if strpos(issuanceperson,"124") & strpos(issuanceperson,"58")
		replace issuanceperson = "125.52" if strpos(issuanceperson,"125") & strpos(issuanceperson,"52")
		replace issuanceperson = "120.23" if strpos(issuanceperson,"120") & strpos(issuanceperson,"23")
	}

	// destring
	foreach v in households persons adults children totalissuance issuancehousehold issuanceperson {
		capture confirm variable `v'
		if !_rc {
			replace `v' = ustrregexra(`v',",","")
			replace `v' = ustrregexra(`v',"$","")
			destring `v', replace ignore("$")
			confirm numeric variable `v'
		}
		else {
			display "`v' does not exist"
		}
	}

	// ym 
	gen ym = `ym'
	format ym %tm 

	// save 
	tempfile _`ym'
	save `_`ym''

}

forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// clean up county names 
replace county = "gila" if county == "gil a"
replace county = "maricopa" if county == "maricop a"
replace county = "pima" if county == "pim a"
replace county = "yuma" if county == "yum a"
replace county = "apache" if county == "northern apache"
replace county = "gila" if county == "central gila"
replace county = "cochise" if county == "southern cochise"
replace county = "maricopa" if county == "region maricopa"
drop if county == "region"
drop if county == "nul nul" & inlist(ym,ym(2019,4),ym(2019,5))

// drop region totals 
drop if inlist(county,"central","southern","northern")

// drop district totals 
drop if inlist(county,"district i","district ii","district iii","district iv","district v","district vi")

// order and sort 
order county ym households persons adults children issuancehousehold issuanceperson totalissuance
sort county ym 

// save 
save "${dir_root}/arizona.dta", replace




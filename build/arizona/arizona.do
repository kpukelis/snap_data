// arizona.do
// imports cases and clients from csvs

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
	display "`month'"
	local year = year 
	display "`year'"

	// import 
	else if inrange(`ym',ym(2006,4),ym(2008,12)) {
		import delimited using "${dir_root}/csvs/tabula-dbme-statistical-bulletin-`month'-`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2009,1),ym(2009,12)) {
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
check
	// drop headers
	while !strpos(v2,"HOUSEHOLDS") {
		drop in 1
	}
	dropmiss, force
	count if missing(v1)
	assert r(N) == 1
	replace v1 = "county" if missing(v1)
check

	// turn first row into variable names 
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

	// clean up county names
	drop if county == "total"
	replace county = "total" if county == "grand total"
	replace county = ustrregexra(county,"region","")
	replace county = ustrregexra(county,"northern","")
	replace county = ustrregexra(county,"central","")
	replace county = ustrregexra(county,"southern","")
	replace county = ustrregexra(county," ","")
	drop if county == "nulnul"

	// number of variables 
	qui describe
	assert r(k) == 7 | r(k) == 8
*	if r(k) == 8 {
*	}
	if r(k) == 7 {
		split childrentotalissuance, parse(" ")
		rename childrentotalissuance1 children
		rename childrentotalissuance2 totalissuance
		drop childrentotalissuance
	}
	qui describe 
	assert r(k) == 8

	// destring
	foreach v in households persons adults children totalissuance issuancehousehold issuanceperson {
		replace `v' = ustrregexra(`v',",","")
		replace `v' = ustrregexra(`v',"$","")
		destring `v', replace ignore("$")
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

// order and sort 
order county ym households persons adults children issuancehousehold issuanceperson totalissuance
sort county ym 

// save 
save "${dir_root}/arizona.dta", replace




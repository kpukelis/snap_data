// arizona.do
// imports cases and clients from csvs

local ym_start	 				= ym(2006,4)
*local ym_start 					= ym(2008,1)
local ym_end 					= ym(2009,12)

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
	else if inrange(`ym',ym(2008,1),ym(2008,12)) {
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
	dropmiss, force
	egen nmcount = rownonmiss(_all), strok
	drop if nmcount == 0
	drop nmcount
	count if missing(v1)
	assert r(N) == 4 | r(N) == 3 
	if r(N) == 4 {
		drop in 1
		drop in 1
	}
	if r(N) == 3 {
		drop in 1
	}
	replace v1 = "county" if missing(v1)

	// turn first row into variable names 
	foreach var of varlist * {
		replace `var' = "`=`var'[1]'" + " " + "`=`var'[2]'" if _n == 1
		replace `var' = strlower(`var')
		replace `var' = ustrregexra(`var',"-","") if _n == 1
		replace `var' = ustrregexra(`var',"/","") if _n == 1
		replace `var' = ustrregexra(`var'," ","") if _n == 1
		replace `var' = ustrregexra(`var',"\.","") if _n == 1
		replace `var' = trim(`var')
		label variable `var' "`=`var'[1]'"
		rename `var' `=`var'[1]'
	}
	rename countycounty county 
	drop in 1
	drop in 1

	// clean up county names
	replace county = "total" if county == "arizona"
	drop if strpos(county,"district")

	// number of variables 
	qui describe
	assert r(k) == 5 | r(k) == 6 | r(k) == 7
	if r(k) == 5 {
		split couponallotissuancehousehold, parse(" ")
		rename couponallotissuancehousehold1 issuance
		rename couponallotissuancehousehold2 issuancehousehold
		drop couponallotissuancehousehold
	}
	if r(k) == 7 {
		split householdspersons, parse(" ")
		rename householdspersons1 households
		rename householdspersons2 individuals
		drop householdspersons
	}
	qui describe 
	assert r(k) == 6 | r(k) == 8
	capture rename allotperson issuanceperson
	capture rename couponissuance issuance
	capture rename allothousehold issuancehousehold
	capture rename household issuancehousehold
	capture rename person issuanceperson
	capture rename issuance issuance

	// destring
	foreach v in households individuals issuance issuancehousehold issuanceperson {
		replace `v' = ustrregexra(`v',",","")
		replace `v' = ustrregexra(`v',"$","")
		destring `v', replace ignore("$")
	}

	foreach v in adults children { 
		capture replace `v' = ustrregexra(`v',",","")
		capture replace `v' = ustrregexra(`v',"$","")
		capture destring `v', replace ignore("$")
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

save "${dir_root}/arizona_early.dta", replace




// arizona.do
// imports cases and clients from csvs
// Note: 2012m10 greenlee data missing from pdf

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
	if inrange(`ym',ym(2006,4),ym(2008,12)) {
		import delimited using "${dir_root}/data/state_data/arizona/csvs/tabula-dbme-statistical-bulletin-`month'-`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2009,1),ym(2009,12)) {
		import delimited using "${dir_root}/data/state_data/arizona/csvs/tabula-dbme_statistical_bulletin_`month'_`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2010,1),ym(2014,12)) {
		import delimited using "${dir_root}/data/state_data/arizona/csvs/tabula-dbme_statistical_bulletin_`month'_`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2015,1),ym(2017,12)) {
		import delimited using "${dir_root}/data/state_data/arizona/csvs/tabula-dbme_statistical_bulletin_`month'_`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2018,1),ym(2018,12)) {
		import delimited using "${dir_root}/data/state_data/arizona/csvs/tabula-dbme-statistical-bulletin-`month'-`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else {
		import delimited using "${dir_root}/data/state_data/arizona/csvs/tabula-dbme-statistical_bulletin-`month'-`year'.csv", delimiters(",") case(lower) stringcols(_all) clear		
	}
	dropmiss, force
	egen nmcount = rownonmiss(_all), strok
	drop if nmcount == 0
	drop nmcount
	count if missing(v1)
	assert r(N) == 4 | r(N) == 3 | r(N) == 2
	if r(N) == 4 {
		drop in 1
		drop in 1
	}
	if r(N) == 3 {
		drop in 1
	}
	if r(N) == 2 {
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
	replace county = "grand total" if county == "arizona"
	drop if strpos(county,"district")

	// number of variables 
	qui describe
	assert r(k) == 5 | r(k) == 6 | r(k) == 7 | r(k) == 8
	if r(k) == 5 {
		split couponallotissuancehousehold, parse(" ")
		rename couponallotissuancehousehold1 issuance
		rename couponallotissuancehousehold2 issuancehousehold
		drop couponallotissuancehousehold
	}
	if r(k) == 6 {
		capture rename paymentsadultschildrenissuance couponadultschildrenissuance
		capture confirm variable couponadultschildrenissuance
		if !_rc {
			dis "exists"
			split couponadultschildrenissuance, parse(" ")
			rename couponadultschildrenissuance1 adults
			rename couponadultschildrenissuance2 children
			rename couponadultschildrenissuance3 issuance
			drop couponadultschildrenissuance
		}	
	}
	if r(k) == 7 {
		capture confirm variable householdspersons
		if !_rc {
			dis "exists"
			split householdspersons, parse(" ")
			rename householdspersons1 households
			rename householdspersons2 individuals
			drop householdspersons
		}
		capture rename paymentschildrenissuance couponchildrenissuance
		capture rename childrentotalissuance couponchildrenissuance
		capture confirm variable couponchildrenissuance
		if !_rc {
			dis "exists"
			split couponchildrenissuance, parse(" ")
			rename couponchildrenissuance1 children
			rename couponchildrenissuance2 issuance
			drop couponchildrenissuance
		}
	}
	qui describe 
	assert r(k) == 6 | r(k) == 8
	capture rename allotperson issuanceperson
	capture rename couponissuance issuance
	capture rename allothousehold issuancehousehold
	if `ym' < ym(2010,8) {
		capture rename household issuancehousehold
		capture rename person issuanceperson
	}
	capture rename issuance issuance
	capture rename persons individuals
	capture rename paymthousehold issuancehousehold
	capture rename paymtperson issuanceperson
	capture rename paymentsissuance issuance
	capture rename totalpaymentsissuance issuance
	capture rename averagepaymenthousehold issuancehousehold
	capture rename averagepaymentperson issuanceperson
	capture rename paymenthousehold issuancehousehold
	capture rename paymentperson issuanceperson
	capture rename totalissuance issuance

	// destring
	foreach v in households individuals issuance issuancehousehold issuanceperson {
		replace `v' = trim(`v')
		replace `v' = ustrregexra(`v',",","")
		replace `v' = ustrregexra(`v',"$","")
		if `ym' == ym(2012,9) & "`v'" == "issuanceperson" {
			replace `v' = ustrregexra(`v'," ",".")
		}
		destring `v', replace ignore("$")
		confirm numeric variable `v'
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

// append 
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
drop if inlist(county,"total")

// drop district totals 
drop if inlist(county,"district i","district ii","district iii","district iv","district v","district vi")

// rename total 
replace county = "total" if county == "grand total"

// order and sort 
order county ym households individuals adults children issuancehousehold issuanceperson issuance
sort county ym 

// save 
save "${dir_root}/data/state_data/arizona/arizona.dta", replace




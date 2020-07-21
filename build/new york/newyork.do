// newyork.do

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/newyork"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local ym_start	 				= ym(2001,1)
local ym_end 					= ym(2020,4)

************************************************************
forvalues ym = `ym_start'(1)`ym_end' {

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
	if inrange(`ym',ym(2006,1),ym(2006,12)) {
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
	if inrange(`ym',ym(2001,1),ym(2004,12)) {
		import excel using "${dir_root}/excel/`year'/stats`monthname'`year_short'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2005,1),ym(2005,12)) {
		import excel using "${dir_root}/excel/`year'/STATS`monthname'`year_short'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2006,1),ym(2006,12)) {
		import excel using "${dir_root}/excel/`year'/STATS_`monthname'`year'.pdf_short.xlsx", case(lower) allstring clear
	}
	else {
		import excel using "${dir_root}/excel/`year'/`year'-`monthname'-stats.pdf_short.xlsx", case(lower) allstring clear
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

	// drop top rows
	while !strpos(v1,"New York State"){
		drop in 1
	}

	// drop bottom rows 
*	drop if strpos(v1,"")
	gen obsnum = _n 
	gsort -obsnum
	while !strpos(v1,"Yates") {
		drop in 1
	}
	sort obsnum
	drop obsnum

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

	// assert size of data 
	describe, varlist
	assert `r(N)' == 60
	assert `r(k)' == 10

	// rename vars 
	rename v1 county 
	rename v2 households
	rename v3 persons
	rename v4 issuance 
	rename v5 households_temp
	rename v6 persons_temp
	rename v7 issuance_temp
	rename v8 households_nontemp
	rename v9 persons_nontemp
	rename v10 issuance_nontemp
	
	// destring 
	foreach var in households persons issuance households_temp persons_temp issuance_temp households_nontemp persons_nontemp issuance_nontemp {
 		capture confirm variable `var'
		if !_rc {
			replace `var' = ustrregexra(`var'," ","")
			replace `var' = ustrregexra(`var',",","")
			destring `var', replace
			confirm numeric variable `var'
		}
	}

	// clean up county 
	replace county = strlower(county)
	replace county = trim(county)
	replace county = "new york city" if county == "new york city*"
	replace county = "st. lawrence" if county == "st.lawrence"

	// ym 
	gen ym = `ym'
	format ym %tm

	// assert everything adds up 
	assert households_temp + households_nontemp == households
	assert persons_temp + persons_nontemp == persons
	assert issuance_temp + issuance_nontemp == issuance

	// order and sort 
	order county ym households persons issuance households_temp persons_temp issuance_temp households_nontemp persons_nontemp issuance_nontemp
	sort county ym 

	// save 
	tempfile _`ym'
	save `_`ym''

}

// append years 
forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// order and sort 
order county ym households persons issuance households_temp persons_temp issuance_temp households_nontemp persons_nontemp issuance_nontemp
sort county ym 

// save 
save "${dir_data}/newyork.dta", replace 

tab county 

	assert households_temp + households_nontemp == households
	assert persons_temp + persons_nontemp == persons
	assert issuance_temp + issuance_nontemp == issuance



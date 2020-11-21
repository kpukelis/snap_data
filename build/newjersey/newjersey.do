// newjersey.do
// Kelsey Pukelis

local ym_start	 				= ym(2007,1)
local ym_end 					= ym(2020,3)

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
	replace monthname = "jan" if month == 1
	replace monthname = "feb" if month == 2
	replace monthname = "mar" if month == 3
	replace monthname = "apr" if month == 4
	replace monthname = "may" if month == 5
	replace monthname = "jun" if month == 6
	replace monthname = "jul" if month == 7
	replace monthname = "aug" if month == 8
	replace monthname = "sep" if month == 9
	replace monthname = "oct" if month == 10
	replace monthname = "nov" if month == 11
	replace monthname = "dec" if month == 12
	local monthname = monthname
	display in red "`monthname'"
	local year_short = year_short 
	display in red "`year_short'"
	local year = year 
	display in red "`year'"

	// import 
	import excel using "${dir_root}/state_data/newjersey/excel/`year'/cps_`monthname'`year_short'.pdf_short.xlsx", case(lower) allstring clear
	
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
*		replace `v' = subinstr(`v', "`=char(160)'", "", .)
		replace `v' = ustrregexra(`v',"\*","")
		replace `v' = ustrregexra(`v',"\∆","")
	}

	// drop top rows
	while !strpos(v1,"atlantic") & !strpos(v1,"Atlantic") & !strpos(v1,"ATLANTIC") {
		drop in 1
	}

	// drop bottom rows 
	drop if strpos(v1,"2020 by County")
	drop if strpos(v1,"2019 by County")
	drop if strpos(v1,". Total NJ SNAP Recipients AUGUST 2018 By County")
	drop if strpos(v1,"JANUARY 2012 By County")
	drop if strpos(v1,"∆=higher caseload % change *=lower caseload % change")
	drop if strpos(v1,"Data is derived from NJ MMIS Shared Data Warehouse.")
	gen obsnum = _n 
	gsort -obsnum
	while !((strpos(v1,"NJ") & strpos(v1,"total")) | (strpos(v1,"NJ") & strpos(v1,"Total")) | (strpos(v1,"NJ") & strpos(v1,"TOTAL"))) {
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
	assert `r(N)' == 22
	if ym(`year',`month') >= ym(2017,8) {
		assert `r(k)' == 11
		// rename vars 
		rename v1 county 
		rename v2 households_wfnj_tanf
		rename v3 households_otherlowinc
		rename v4 households 
		rename v5 households_percchange
		rename v6 adults 
		rename v7 children
		rename v8 individuals
		rename v9 individuals_percchange
		rename v10 age60plus
		rename v11 peoplewithadisability
	}
	else {
		assert `r(k)' == 9	
		// rename vars 
		rename v1 county 
		rename v2 households_wfnj_tanf
		rename v3 households_otherlowinc
		rename v4 households 
		rename v5 households_percchange
		rename v6 adults 
		rename v7 children
		rename v8 individuals
		rename v9 individuals_percchange	
	}

	// drop unnecessary vars 
	drop households_percchange
	drop individuals_percchange

	// destring 
	foreach var in households_wfnj_tanf households_otherlowinc households adults children individuals age60plus peoplewithadisability {
 		capture confirm variable `var'
		if !_rc {
			replace `var' = ustrregexra(`var'," ","")
			replace `var' = ustrregexra(`var',"B","8") // on scanned data, 8's get mistaken for capital B's
			replace `var' = ustrregexra(`var',",","")
			destring `var', replace
			confirm numeric variable `var'
		}
	}

	// clean up county 
	replace county = strlower(county)
	replace county = trim(county)
	replace county = ustrregexra(county," ","")
	replace county = ustrregexra(county,":","")
	replace county = ustrregexra(county,"!","")
	replace county = ustrregexra(county,"\.","")
	replace county = "middlesex" if county == "mlddlesex"
	replace county = "cumberland" if county == "cumberlan"

	// ym 
	gen ym = ym(`year',`month')
	format ym %tm

	// manual fixes
	capture noisily assert adults + children == individuals 
		// adults
		replace adults = 23252 if county == "passaic" & ym == ym(2007,12)
		replace adults = 10067 if county == "atlantic" & ym == ym(2007,2)
		replace adults = 10818 if county == "bergen" & ym == ym(2007,2)
		replace adults = 7465 if county == "cumberland" & ym == ym(2007,2)
		replace adults = 7801 if county == "monmouth" & ym == ym(2007,2)
		replace adults = 7112 if county == "ocean" & ym == ym(2007,2)
		replace adults = 22996 if county == "passaic" & ym == ym(2007,8)
		replace adults = 5491 if county == "gloucester" & ym == ym(2008,3)
		replace adults = 2261 if county == "salem" & ym == ym(2008,3)
		replace adults = 10512 if county == "middlesex" & ym == ym(2008,7)
		replace adults = 279691 if county == "njtotal" & ym == ym(2009,10)
		replace adults = 12087 if county == "mercer" & ym == ym(2009,12)
		replace adults = 253318 if county == "njtotal" & ym == ym(2009,6)
		replace adults = 1160 if county == "hunterdon" & ym == ym(2009,8)
		// children 
		replace children = 28484 if county == "passaic" & ym == ym(2007,12)
		replace children = 9357 if county == "atlantic" & ym == ym(2007,2)
		replace children = 5631 if county == "bergen" & ym == ym(2007,2)
		replace children = 9070 if county == "cumberland" & ym == ym(2007,2)
		replace children = 7226 if county == "monmouth" & ym == ym(2007,2)
		replace children = 9583 if county == "ocean" & ym == ym(2007,2)
		replace children = 27998 if county == "passaic" & ym == ym(2007,8)
		replace children = 5328 if county == "gloucester" & ym == ym(2008,3)
		replace children = 2424 if county == "salem" & ym == ym(2008,3)
		replace children = 9216 if county == "middlesex" & ym == ym(2008,7)
		replace children = 280347 if county == "njtotal" & ym == ym(2009,10)
		replace children = 11448 if county == "mercer" & ym == ym(2009,12)
		replace children = 253684 if county == "njtotal" & ym == ym(2009,6)
		replace children = 648 if county == "hunterdon" & ym == ym(2009,8)

		// individuals
		replace individuals = 51736 if county == "passaic" & ym == ym(2007,12)
		replace individuals = 19424 if county == "atlantic" & ym == ym(2007,2)
		replace individuals = 16449 if county == "bergen" & ym == ym(2007,2)
		replace individuals = 16535 if county == "cumberland" & ym == ym(2007,2)
		replace individuals = 15027 if county == "monmouth" & ym == ym(2007,2)
		replace individuals = 16695 if county == "ocean" & ym == ym(2007,2)
		replace individuals = 50994 if county == "passaic" & ym == ym(2007,8)
		replace individuals = 10819 if county == "gloucester" & ym == ym(2008,3)
		replace individuals = 4685 if county == "salem" & ym == ym(2008,3)
		replace individuals = 19728 if county == "middlesex" & ym == ym(2008,7)
		replace individuals = 560038 if county == "njtotal" & ym == ym(2009,10)
		replace individuals = 23535 if county == "mercer" & ym == ym(2009,12)
		replace individuals = 507002 if county == "njtotal" & ym == ym(2009,6)
		replace individuals = 1808 if county == "hunterdon" & ym == ym(2009,8)

		// assert everything adds up 
		assert adults + children == individuals

	// manual fixes 
	capture noisily assert households_wfnj_tanf + households_otherlowinc == households

		// households_wfnj_tanf
		replace households_wfnj_tanf = 2941 if county == "passaic" & ym == ym(2007,2)
		replace households_wfnj_tanf = 1558 if county == "atlantic" & ym == ym(2007,2)
		replace households_wfnj_tanf = 858 if county == "burlington" & ym == ym(2007,1)
		replace households_wfnj_tanf = 8239 if county == "essex" & ym == ym(2009,12)
		replace households_wfnj_tanf = 35452 if county == "njtotal" & ym == ym(2007,10)
		replace households_wfnj_tanf = 2946 if county == "passaic" & ym == ym(2008,2)
		replace households_wfnj_tanf = 685 if county == "ocean" & ym == ym(2008,1)
		replace households_wfnj_tanf = 1054 if county == "monmouth" & ym == ym(2007,2)
		replace households_wfnj_tanf = 3012 if county == "passaic" & ym == ym(2007,10)
		replace households_wfnj_tanf = 299 if county == "morris" & ym == ym(2009,10)
		replace households_wfnj_tanf = 702 if county == "ocean" & ym == ym(2007,10)
		replace households_wfnj_tanf = 284 if county == "morris" & ym == ym(2008,5)
		replace households_wfnj_tanf = 34584 if county == "njtotal" & ym == ym(2008,4)
		replace households_wfnj_tanf = 266 if county == "morris" & ym == ym(2007,10)
		replace households_wfnj_tanf = 444 if county == "salem" & ym == ym(2007,10)
		replace households_wfnj_tanf = 428 if county == "salem" & ym == ym(2007,12)
		replace households_wfnj_tanf = 331 if county == "somerset" & ym == ym(2007,10)
		replace households_wfnj_tanf = 312 if county == "somerset" & ym == ym(2008,3)
		replace households_wfnj_tanf = 417 if county == "somerset" & ym == ym(2009,12)
		replace households_wfnj_tanf = 156 if county == "sussex" & ym == ym(2007,10)
		replace households_wfnj_tanf = 205 if county == "sussex" & ym == ym(2009,9)
		replace households_wfnj_tanf = 1997 if county == "union" & ym == ym(2007,11)
		replace households_wfnj_tanf = 1750 if county == "union" & ym == ym(2009,4)
		replace households_wfnj_tanf = 1761 if county == "union" & ym == ym(2009,9)
		replace households_wfnj_tanf = 233 if county == "warren" & ym == ym(2007,2)

		// households_otherlowinc
		replace households_otherlowinc = 20470 if county == "passaic" & ym == ym(2007,2)
		replace households_otherlowinc = 8145 if county == "atlantic" & ym == ym(2007,2)
		replace households_otherlowinc = 4706 if county == "burlington" & ym == ym(2007,1)
		replace households_otherlowinc = 43256 if county == "essex" & ym == ym(2009,12)
		replace households_otherlowinc = 168146 if county == "njtotal" & ym == ym(2007,10)
		replace households_otherlowinc = 21422 if county == "passaic" & ym == ym(2008,2)
		replace households_otherlowinc = 7568 if county == "ocean" & ym == ym(2008,1)
		replace households_otherlowinc = 6427 if county == "monmouth" & ym == ym(2007,2)
		replace households_otherlowinc = 21466 if county == "passaic" & ym == ym(2007,10)
		replace households_otherlowinc = 5012 if county == "morris" & ym == ym(2009,10)
		replace households_otherlowinc = 7120 if county == "ocean" & ym == ym(2007,10)
		replace households_otherlowinc = 3600 if county == "morris" & ym == ym(2008,5)
		replace households_otherlowinc = 174733 if county == "njtotal" & ym == ym(2008,4)
		replace households_otherlowinc = 3302 if county == "morris" & ym == ym(2007,10)
		replace households_otherlowinc = 1710 if county == "salem" & ym == ym(2007,10)
		replace households_otherlowinc = 1717 if county == "salem" & ym == ym(2007,12)
		replace households_otherlowinc = 2333 if county == "somerset" & ym == ym(2007,10)
		replace households_otherlowinc = 2415 if county == "somerset" & ym == ym(2008,3)
		replace households_otherlowinc = 3545 if county == "somerset" & ym == ym(2009,12)
		replace households_otherlowinc = 1003 if county == "sussex" & ym == ym(2007,10)
		replace households_otherlowinc = 1421 if county == "sussex" & ym == ym(2009,9)
		replace households_otherlowinc = 8916 if county == "union" & ym == ym(2007,11)
		replace households_otherlowinc = 10683 if county == "union" & ym == ym(2009,4)
		replace households_otherlowinc = 11773 if county == "union" & ym == ym(2009,9)
		replace households_otherlowinc = 1465 if county == "warren" & ym == ym(2007,2)

		// households
		replace households = 23411 if county == "passaic" & ym == ym(2007,2)
		replace households = 9703 if county == "atlantic" & ym == ym(2007,2)
		replace households = 5564 if county == "burlington" & ym == ym(2007,1)
		replace households = 51495 if county == "essex" & ym == ym(2009,12)
		replace households = 203598 if county == "njtotal" & ym == ym(2007,10)
		replace households = 24368 if county == "passaic" & ym == ym(2008,2)
		replace households = 8253 if county == "ocean" & ym == ym(2008,1)
		replace households = 7481 if county == "monmouth" & ym == ym(2007,2)
		replace households = 24478 if county == "passaic" & ym == ym(2007,10)
		replace households = 5311 if county == "morris" & ym == ym(2009,10)
		replace households = 7822 if county == "ocean" & ym == ym(2007,10)
		replace households = 3884 if county == "morris" & ym == ym(2008,5)
		replace households = 209317 if county == "njtotal" & ym == ym(2008,4)
		replace households = 3568 if county == "morris" & ym == ym(2007,10)
		replace households = 2154 if county == "salem" & ym == ym(2007,10)
		replace households = 2145 if county == "salem" & ym == ym(2007,12)
		replace households = 2664 if county == "somerset" & ym == ym(2007,10)
		replace households = 2727 if county == "somerset" & ym == ym(2008,3)
		replace households = 3962 if county == "somerset" & ym == ym(2009,12)
		replace households = 1159 if county == "sussex" & ym == ym(2007,10)
		replace households = 1626 if county == "sussex" & ym == ym(2009,9)
		replace households = 10913 if county == "union" & ym == ym(2007,11)
		replace households = 12433 if county == "union" & ym == ym(2009,4)
		replace households = 13534 if county == "union" & ym == ym(2009,9)
		replace households = 1698 if county == "warren" & ym == ym(2007,2)

		// assert everything adds up 
		assert households_wfnj_tanf + households_otherlowinc == households

	// order and sort 
	order county ym households individuals adults children /*age60plus peoplewithadisability*/ households_wfnj_tanf households_otherlowinc
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
order county ym households individuals adults children age60plus peoplewithadisability households_wfnj_tanf households_otherlowinc
sort county ym 

// save 
save "${dir_root}/state_data/newjersey/newjersey.dta", replace 


// california.do 
// Kelsey Pukelis

local year_short_list			/*10 14*/ 16 17 18 19

**************************************************************************

foreach year_short of local year_short_list {

	// display ym 
	display in red "`year'"

	// for file names
	clear
	set obs 1
	gen year_short = `year_short'
	gen year_short_plus1 = `year_short' + 1
	gen year = 2000 + `year_short'
	local year_short = year_short
	display in red "`year_short'"
	local year_short_plus1 = year_short_plus1
	display in red "`year_short_plus1'"
	local year = year
	display in red "`year'"

	if inrange(`year_short',10,14) {
		// load data 
		import excel "${dir_data}/excel/CF 296 - CalFresh Monthly Caseload/DFA296FY`year_short'-`year_short_plus1'.xls", sheet("FinalData") allstring case(lower) firstrow clear 
	}
	else {
		// load data 
		import excel "${dir_data}/excel/CF 296 - CalFresh Monthly Caseload/CF296FY`year_short'-`year_short_plus1'.xlsx", sheet("FinalData") allstring case(lower) firstrow clear 		
	}
	// drop empty variables
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	drop in 1
*	drop in 1
*	drop in 1	
	
	// turn first row into variable names 
	replace v1 = "date" if _n == 1
	replace v2 = "Month" if _n == 1
	replace v3 = "Year" if _n == 1
	replace v4 = "County Name" if _n == 1
	replace v5 = "SFY" if _n == 1
	replace v6 = "FFY" if _n == 1
	foreach var of varlist * {
		replace `var' = "`=`var'[1]'" + " " + "`=`var'[2]'" if _n == 1
		replace `var' = strlower(`var')
		replace `var' = ustrregexra(`var',"-","") if _n == 1
		replace `var' = ustrregexra(`var',"\.","") if _n == 1
		replace `var' = ustrregexra(`var',"\(","") if _n == 1
		replace `var' = ustrregexra(`var',"\)","") if _n == 1
		replace `var' = ustrregexra(`var'," ","") if _n == 1
		replace `var' = ustrregexra(`var',"[0-9]+","") if _n == 1
		replace `var' = ustrregexra(`var',"applications","apps") if _n == 1
		replace `var' = ustrregexra(`var',"approved","apprv") if _n == 1
		replace `var' = ustrregexra(`var',"duringthemonth","") if _n == 1
		replace `var' = substr(`var',1,32)
		label variable `var' "`=`var'[1]'"
		rename `var' `=`var'[1]'
	}
	drop in 1
	check

		forvalues n = 1(1)123 {
			replace `var' = "v" + "`=`var'[1]'" if _n == 1 & `var' == "`n'"
check
		}


	capture rename countyname					county 
	rename issuanceamount 						issuance 
	capture rename casecount 					households
	capture rename clientcount 					individuals
	capture rename countofcases 				households 
	capture rename countofclients 				individuals
	capture rename countofdistinctcases 		households 
	capture rename countofdistinctclients 		individuals
	capture rename countofnpacases 				households_npa
	capture rename countofnpaclients 			individuals_npa
	capture rename countofpacases 				households_pa 
	capture rename countofpaclients 			individuals_pa
	capture rename nonpublicassistancecases 	households_npa
	capture rename nonpublicassistanceclients 	individuals_npa
	capture rename publicassistancecases 		households_pa 
	capture rename publicassistanceclients 		individuals_pa

	// destring
	foreach v in households individuals issuance households_npa households_pa individuals_npa individuals_pa {
		destring `v', replace
		confirm numeric variable `v'
	}
	
	// lowercase county 
	replace county = strlower(county)
	
	// drop statewide average 
	drop if strpos(county,"statewide average")
	replace county = "state totals" if county == "statewide total"

	// ym 
	gen ym = ym(`year',`month')
	format ym %tm
	
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
order county ym issuance households individuals households_npa individuals_npa households_pa individuals_pa
sort county ym 

// save 
save "${dir_data}/california.dta", replace 


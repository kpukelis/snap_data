// louisiana_state.do 

local year_start_part1			= 1987 
local year_end_part1			= 2006
local year_start_part2			= 2007 
local year_end_part2			= 2019

********************************************************************
// STATE TOTALS 1987-2006
// Part 1

// import
import excel "${dir_data}/excel/FS_SFY_Totals.xlsx", sheet("Table 1") allstring clear

// initial cleanup
dropmiss, force 
dropmiss, obs force 
describe, varlist 
rename (`r(varlist)') (v#), addnumber
gen obsnum = _n

// loop through years 
forvalues year = `year_start_part1'(1)`year_end_part1' {

	// preserve
	preserve
	
	// mark observation numbers for this year
	sum obsnum if strpos(v1,"`year'") & strpos(v1,"July")
	assert r(N) == 1
	local begin_year = r(mean)
	local end_year = r(mean) + 11

	// just keep data for that year
	keep if inrange(obsnum,`begin_year',`end_year')
	drop obsnum

	// clean up this data
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// assert the right number of variables and rename
	assert r(k) == 7
	rename v1 monthname
	rename v2 households
	rename v3 individuals 
	rename v4 avg_indiv_per_hh
	rename v5 issuance 
	rename v6 avg_payment 
	rename v7 hh_increase_decrease
	drop hh_increase_decrease

	// clean up date
	local year_plus1 = `year' + 1
	replace monthname = trim(monthname)
	replace monthname = ustrregexra(monthname,"`year'","")
	replace monthname = ustrregexra(monthname,"`year_plus1'","")
	replace monthname = trim(monthname)
	gen month = .
	replace month = 1 if monthname == "January"
	replace month = 2 if monthname == "February"
	replace month = 3 if monthname == "March"
	replace month = 4 if monthname == "April"
	replace month = 5 if monthname == "May"
	replace month = 6 if monthname == "June"
	replace month = 7 if monthname == "July"
	replace month = 8 if monthname == "August"
	replace month = 9 if monthname == "September"
	replace month = 10 if monthname == "October"
	replace month = 11 if monthname == "November"
	replace month = 12 if monthname == "December"
	assert !missing(month)
	drop monthname
	gen year = .
	replace year = `year' if inrange(month,7,12)
	replace year = `year_plus1' if inrange(month,1,6)
	gen ym = ym(year,month)
	format ym %tm 
	drop year month

	// destring variables 
	foreach var in households individuals avg_indiv_per_hh issuance avg_payment {
		destring `var', replace
	}

	// order and sort 
	order ym
	sort ym

	// save 
	tempfile _`year'
	save `_`year''

	// restore
	restore			

}


*******************************************
// Part 2 

// loop through years 
forvalues year = `year_start_part2'(1)`year_end_part2' {
	
	// for filenames
	local year_short = `year' - 2000
	local year_short_plus1 = `year_short' + 1
	if `year_short' < 10 {
		local year_short_name = "0" + "`year_short'"
	}
	else {
		local year_short_name = "`year_short'"
	}
	if `year_short_plus1' < 10 {
		local year_short_plus1_name = "0" + "`year_short_plus1'"
	}
	else {
		local year_short_plus1_name = "`year_short_plus1'"
	}
	local yearnames = "`year_short_name'" + "`year_short_plus1_name'"

	// import excel 
	import excel "${dir_data}/excel/001_Fiscal Year Totals/fy`yearnames'_FS_SFY_Totals.xlsx", sheet("Table 1") allstring clear

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// just keep months 
	drop if strpos(v1,"FOOD STAMP PROGRAM")
	drop if strpos(v1,"MONTH")
	drop if strpos(v1,"TOTALS")
	drop if strpos(v1,"AVERAGE")
	drop if strpos(v1,"NOTE:  1.  September and October benefits include Gustav/Ike Supplements")
	drop if strpos(v1,"2.  Average Payment for SFY excludes September and October Monthly Average Payments.")
	drop if strpos(v1,"3.  Recipient Benefits = Benefits minus the Reinstated/Reissued Benefits")
	drop if strpos(v1,"4.  Increase in FS benefits in April  and May  are due to the Economic Stimulus Package")
	drop if strpos(v1,"NOTE:  1.  Recipient Benefits = Benefits minus the Reinstated/Reissued Benefits")
	drop if strpos(v1,"State Fiscal Year")
	drop if strpos(v1,"SNAP")
	drop if strpos(v2,"TOTAL")

	// clean up this data
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// assert the right number of variables and rename
	assert r(k) == 9
	rename v1 monthname
	rename v2 households
	rename v3 individuals 
	rename v4 avg_indiv_per_hh
	rename v5 issuance 
	rename v6 avg_payment 
	rename v7 hh_increase_decrease
	rename v8 hh_with_earnedinc
	rename v9 avg_earnedinc_per_hh
	drop hh_increase_decrease

	// clean up date
	local year_plus1 = `year' + 1
	replace monthname = trim(monthname)
	replace monthname = ustrregexra(monthname,"`year'","")
	replace monthname = ustrregexra(monthname,"`year_plus1'","")
	replace monthname = trim(monthname)
	gen month = .
	replace month = 1 if monthname == "January"
	replace month = 2 if monthname == "February"
	replace month = 3 if monthname == "March"
	replace month = 4 if monthname == "April"
	replace month = 5 if monthname == "May"
	replace month = 6 if monthname == "June"
	replace month = 7 if monthname == "July"
	replace month = 8 if monthname == "August"
	replace month = 9 if monthname == "September"
	replace month = 10 if monthname == "October"
	replace month = 11 if monthname == "November"
	replace month = 12 if monthname == "December"
	assert !missing(month)
	drop monthname
	gen year = .
	replace year = `year' if inrange(month,7,12)
	replace year = `year_plus1' if inrange(month,1,6)
	gen ym = ym(year,month)
	format ym %tm 
	drop year month

	// destring variables 
	foreach var in households individuals avg_indiv_per_hh issuance avg_payment hh_with_earnedinc avg_earnedinc_per_hh {
		
		// destring
		replace `var' = ustrregexra(`var',"PENDING","")
		replace `var' = ustrregexra(`var',"%","")
		destring `var', replace ignore("%")

		// assert variable is numeric
		confirm numeric variable `var'
	}

	// order and sort 
	order ym
	sort ym

	// save 
	tempfile _`year'
	save `_`year''

}


******************************************
forvalues year = `year_start_part1'(1)`year_end_part2' {
	if `year' == `year_start_part1' {
		use `_`year'', clear
	} 
	else {
		append using `_`year''
	}
}
save "${dir_data}/louisiana_state.dta", replace 



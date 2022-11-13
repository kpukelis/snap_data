// missouri.do
// imports cases and clients from csvs

local ym_start	 				= ym(2008,10) 
local ym_end_expedited 			= ym(2021,9)
local ym_end 					= ym(2022,9)
local suffix_2008 				""
local suffix_2009 				""
local suffix_2010 				""
local suffix_2011 				""
local suffix_2012 				"-family-support-mohealthnet-report"
local suffix_2013 				"-family-support-mohealthnet-report"
local suffix_2014 				"-family-support-mohealthnet-report"
local suffix_2015 				"-family-support-mohealthnet-report"
local suffix_2016 				"-family-support-mohealthnet-report"
local suffix_2017 				"-family-support-mohealthnet-report"
local suffix_2018 				"-family-support-mohealthnet-report"
local suffix_2019 				"-family-support-mohealthnet-report"
local suffix_2020				"-family-support-mohealthnet-report"
local suffix_2021				"-family-support-mohealthnet-report"
local suffix_2022				"-family-support-mohealthnet-report"
local yearname_2008				"08"
local yearname_2009				"09"
local yearname_2010				"10"
local yearname_2011				"011"
local yearname_2012				"12"
local yearname_2013				"13"
local yearname_2014				"14"
local yearname_2015				"15"
local yearname_2016				"16"
local yearname_2017				"17"
local yearname_2018				"18"
local yearname_2019				"19"
local yearname_2020 			"20"
local yearname_2021 			"21"
local yearname_2022 			"22"

// ym(2019,7) that's when the page splitting gets weird, which caused me to comment out the strpos lines
// I think I resolved this though, I managed to get all the data 

************************************************************
/*
///////////////////////////////////////
// COUNTY EXPEDITED APPLICATION DATA // 
///////////////////////////////////////

forvalues ym = `ym_start'(1)`ym_end_expedited' {

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace
	replace month = "0" + month if strlen(month) == 1
	local month = month
	local year = year 
	display in red  "`year' `month'" 

	// import 
	if `year' >= 2011 & !inlist(`year',2020,2021,2022) {
		import excel using "${dir_root}/data/state_data/missouri/excel/`year'/`yearname_`year''`month'`suffix_`year''.xlsx", case(lower) allstring clear
	}
	else {
		import excel using "${dir_root}/data/state_data/missouri/excel/`year'/`month'`yearname_`year''`suffix_`year''.xlsx", case(lower) allstring clear
	}

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 

	// rename vars 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	replace v1 = trim(v1)
	replace v1 = stritrim(v1)

	// separate pages/batches
	gen obsnum = _n
	qui sum obsnum if strpos(v1,"APPLICATIONS RECEIVED")
	local batch_start_1 = `r(min)'
	*qui sum obsnum if strpos(v1,"NW REGION") & strpos(v2,"ANDREW")
	if inrange(`ym',ym(2008,10),ym(2009,2)) | inrange(`ym',ym(2010,10),ym(2012,2)) | inrange(`ym',ym(2012,4),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6)) | inrange(`ym',ym(2014,8),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2020,4)) | inrange(`ym',ym(2020,8),ym(2021,9)) {
		noisily sum obsnum if /*strpos(v5,"# APPS") &*/ strpos(v5,"RECEIVED")
	}
	else if inrange(`ym',ym(2009,3),ym(2010,9)) | inlist(`ym',ym(2014,5),ym(2014,7),ym(2020,7)) {
		noisily sum obsnum if /*strpos(v4,"# APPS") &*/ strpos(v4,"RECEIVED")
	}
	else if inlist(`ym',ym(2012,3),ym(2013,12)) | inrange(`ym',ym(2020,5),ym(2020,6)) {
		noisily sum obsnum if /*strpos(v6,"# APPS") &*/ strpos(v6,"RECEIVED")
	}
	else if inlist(`ym',ym(2018,5)) {
		noisily sum obsnum if /*strpos(v7,"# APPS") &*/ strpos(v7,"RECEIVED")	
	}
	else if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		noisily sum obsnum if /*strpos(v2,"") &*/ strpos(v2,"RECEIVED")		
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		noisily sum obsnum if /*strpos(v3,"") &*/ strpos(v3,"RECEIVED")		
	}
	else {
		display	 in red "RECEIVED: include this ym in list of values in code"
		stop 
	}
	assert r(N) == 2
	local batch_start_2 = `r(min)'

*	qui sum obsnum if strpos(v1,"SE REGION") & strpos(v2,"IRON")
*	assert r(N) == 1
*	local batch_start_3 = `r(min)'
	local batch_start_3 = `r(max)'
*	qui sum obsnum if strpos(v1,"NW REGION") & strpos(v3,"ANDREW")
	if inlist(`ym',ym(2021,5)) {
		noisily sum obsnum if /*strpos(v5,"EXPEDITED") &*/ strpos(v5,"APPLICATIONS")
	}
	else if inrange(`ym',ym(2008,10),ym(2010,9)) | inrange(`ym',ym(2011,9),ym(2012,2)) | inrange(`ym',ym(2012,4),ym(2012,8)) | inlist(`ym',ym(2014,5)) | inrange(`ym',ym(2014,7),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2020,4)) | inlist(`ym',ym(2020,7)) | inrange(`ym',ym(2021,6),ym(2021,9)) {
		noisily sum obsnum if /*strpos(v6,"EXPEDITED") &*/ strpos(v6,"APPLICATIONS")
	}
	else if inrange(`ym',ym(2010,10),ym(2011,8)) | inlist(`ym',ym(2012,3),ym(2012,9)) | inrange(`ym',ym(2012,10),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6),ym(2018,5)) | inlist(`ym',ym(2020,5),ym(2020,6)) | inrange(`ym',ym(2020,8),ym(2021,4)) {
		noisily sum obsnum if /*strpos(v7,"EXPEDITED") &*/ strpos(v7,"APPLICATIONS")
	}
	else if inlist(`ym',ym(2013,12)) {
		noisily sum obsnum if /*strpos(v8,"EXPEDITED") &*/ strpos(v8,"APPLICATIONS")	
	}
	else if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		noisily sum obsnum if strpos(v3,"HOUSEHOLDS")		
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		noisily sum obsnum if strpos(v2,"HOUSEHOLDS")		
	}
	else {
		display	 in red "APPLICATIONS: include this ym in list of values in code "
		stop
	}
	assert r(N) == 2
	local batch_start_4 = `r(min)'
*	qui sum obsnum if strpos(v1,"SE REGION") & strpos(v3,"IRON")
*	assert r(N) == 1
*	local batch_start_5 = `r(min)'
	local batch_start_5 = `r(max)'
	if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		qui sum obsnum if strpos(v3,"CHILDREN") 
		local total_households_var v3
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		qui sum obsnum if strpos(v2,"CHILDREN") 
		local total_households_var v2
	}

	if inrange(`ym',ym(2021,10),ym(2022,9)) {
		assert r(N) == 2
		local batch_start_6 = `r(min)'
		local batch_start_7 = `r(max)'
		sum obsnum
		local batch_start_8 = `r(max)'
		local num_pages = 7

	}
	else if `ym' <= ym(2021,9) {
		sum obsnum if v1 == "COUNTY" 
		assert r(N) == 2
		local batch_start_6 = `r(min)'
*		qui sum obsnum if strpos(v1,"NW REGION") & strpos(v2,"ANDREW")
*		assert r(N) == 1
*		local batch_start_7 = `r(min)'
		local batch_start_7 = `r(max)'
*		qui sum obsnum if strpos(v1,"SE REGION") & strpos(v2,"IRON")
		if inlist(`ym',ym(2021,6)) {
			qui sum obsnum if strpos(v4,"HOUSEHOLDS") /*strpos(v4,"TOTAL HOUSEHOLDS") */
			local total_households_var v4
		}
		else if inrange(`ym',ym(2008,10),ym(2012,2)) | inlist(`ym',ym(2013,12)) | inrange(`ym',ym(2014,8),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2018,9)) | inlist(`ym',ym(2020,7),ym(2021,5)) {
			qui sum obsnum if strpos(v5,"HOUSEHOLDS") /*strpos(v5,"TOTAL HOUSEHOLDS") */
			local total_households_var v5
		}
		else if inrange(`ym',ym(2012,3),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6),ym(2018,5)) | inlist(`ym',ym(2020,5),ym(2020,6)) | inrange(`ym',ym(2020,8),ym(2021,4)) | inrange(`ym',ym(2021,7),ym(2021,9)) {
			qui sum obsnum if strpos(v6,"HOUSEHOLDS") /*strpos(v6,"TOTAL HOUSEHOLDS") */
			local total_households_var v6
		}
		else if inlist(`ym',ym(2014,5),ym(2014,7)) | inrange(`ym',ym(2018,10),ym(2020,4)) {
			qui sum obsnum if strpos(v4,"HOUSEHOLDS") /*strpos(v4,"TOTAL HOUSEHOLDS") */	
			local total_households_var v4
		}

		if `ym' < ym(2014,8) | inrange(`ym',ym(2018,10),ym(2020,4)) | inrange(`ym',ym(2021,5),ym(2021,9)) {
			assert r(N) == 2
			local batch_start_8 = `r(min)'
			local batch_start_9 = `r(max)'
			sum obsnum
			local batch_start_10 = `r(max)'
			local num_pages = 9
		}
		else {
			assert r(N) == 4
			local batch_start_8 = `r(min)'
			local batch_start_11 = `r(max)'
			sum obsnum if strpos(`total_households_var',"TOTAL HOUSEHOLDS") & !inlist(obsnum,`batch_start_8',`batch_start_11')
			assert r(N) == 2
			local batch_start_9 = `r(min)'
			local batch_start_10 = `r(max)'
			sum obsnum
			local batch_start_12 = `r(max)'
			local num_pages = 11
		}
	} // end of else 
	else {
		display	 in red "HOUSEHOLDS: include this ym in list of values in code "
		stop 
	}

	// manual drop 
	drop if v1 == "DSS MONTHLY MANAGEMENT REPORT / PAGE 153"
	drop if v1 == "DSS MONTHLY MANAGEMENT REPORT / PAGE 159"
	drop if v1 == "TABLE 26" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "FOOD STAMP APPLICATIONS" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "JULY 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "AUGUST 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "SEPTEMBER 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "OCTOBER 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "DSS FSD/MHD Monthly Management Report Page 151"
	drop if strpos(v1,"TABLE 25") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"TABLE 26") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MAY 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JUNE 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JULY 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"AUGUST 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"SEPTEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"OCTOBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"NOVEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DECEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DSS FSD/MHD MONTHLY MANAGEMENT REPORT")
	drop if strpos(v1,"OCTOBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"NOVEMBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DECEMBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JANUARY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FEBRUARY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MARCH 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"APRIL 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MAY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JUNE 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JULY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"AUGUST 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"SEPTEMBER 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FOOD STAMP PROGRAM PARTICIPATION") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DSS FSD/MHD Monthly Management Report")
	drop if strpos(v1,"OCTOBER 2008") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FOOD STAMP APPLICATIONS") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"TABLE 27") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FOOD STAMP EXPEDITED APPLICATIONS") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	
	// keep page of data that has county data 
	*forvalues n = 1(1)`num_pages' {
	* local n = 2 // county level applications
	*local n = 3 // county level applications continued
	* local n = 4 // county level expedited apps 
	*local n = 5 // county level expedited apps continued
	*local n = 6 // county level enrollment, broken down by npa/pa
	*local n = 7 // county level enrollment, broken down by npa/pa continued
	*local n = 8 // county level enrollment, NOT broken down by npa/pa
	*local n = 9 // county level enrollment, NOT broken down by npa/pa continued
	if inrange(`ym',ym(2008,10),ym(2021,9)) {
		local page_list 4 5
	}
	else if inrange(`ym',ym(2021,10),ym(2022,9)) {
		local page_list // NO EXPEDITED DATA FOR THESE MONTHS
	}

	foreach n in `page_list' {

		if inlist(`n',4) {
			local i = 1
		}
		else if inlist(`n',5) {
			local i = 2
		}

		local nplus1 = `n' + 1

		display in red  "`year' `month'" 
		display in red "page `n' of `num_pages'"

		// preserve 
		preserve

		// keep this page/batch of data 
		keep if obsnum >= `batch_start_`n'' & obsnum < `batch_start_`nplus1''
		drop obsnum 

		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		*br

		// manual drop obs 
		if inrange(`ym',ym(2019,7),ym(2019,10)) {
			drop if v3 == "EXPEDITED" & v4 == "APPLICATIONS" & missing(v1) & missing(v2)
			drop if v5 == "TABLE 28" & missing(v1) & missing(v2)
			dropmiss, force 
			dropmiss, obs force 
			describe, varlist 
			rename (`r(varlist)') (v#), addnumber
		}

		// assert size 
		describe, varlist
		if `n' == 4 {
			assert `r(N)' == 62 // includes variable titles	
		}
		else if `n' == 5 {
			assert `r(N)' == 62 // includes variable titles	
		}
		assert `r(k)' == 6

		// rename vars 
		if `r(k)' == 6 {
			rename v1 region 
			rename v2 county 
			rename v3 apps_expedited
			rename v4 apps_timely
			rename v5 apps_nottimely
			rename v6 apps_timely_perc
		}

		// drop top rows 
		drop in 1	

		// clean up county
		capture replace region = trim(region)
		capture replace region = strlower(region)
		replace county = trim(county)
		replace county = strlower(county)
		replace county = "total" if county == "state total" | county == "statewide"
		capture replace region = "total" if region == "state total" | region == "statewide"
		capture replace county = region if inlist(region,"unknown","total") & missing(county)
		replace county = "total" if county == "state total" | county == "statewide"
		assert !strpos(county,"state")
		assert !missing(county)

		// drop region 
		capture drop region 

		// destring
		foreach var in apps_expedited apps_timely apps_nottimely apps_timely_perc {
			capture confirm variable `var' 
			if !_rc {
				destring `var', replace 
				confirm numeric variable `var'
			}
		}

		// ym 
		gen ym = `ym'
		format ym %tm 

		// order and sort 
		order county ym 
		sort county ym 

		// save 
		tempfile _`ym'_i`i'
		save `_`ym'_i`i''

		// restore 
		restore 

	} // ends n pages loop 

	// append across pages / i's 
	use `_`ym'_i1', clear 
	append using `_`ym'_i2'
	tempfile _`ym'_county_apps_exp 
	save `_`ym'_county_apps_exp'

} // ends ym loop 

// append all ym's 
forvalues ym = `ym_start'(1)`ym_end_expedited' {
	if `ym' == `ym_start' {
		use `_`ym'_county_apps_exp', clear
	}
	else {
		append using `_`ym'_county_apps_exp'
	}
}
	
// save 
save "${dir_root}/data/state_data/missouri/missouri_county_apps_exp.dta", replace

tab ym 
tab county 
*/

***************************************************************
/*
/////////////////////////////
// COUNTY APPLICATION DATA // 
/////////////////////////////

forvalues ym = `ym_start'(1)`ym_end' {

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace
	replace month = "0" + month if strlen(month) == 1
	local month = month
	local year = year 
	display in red  "`year' `month'" 

	// import 
	if `year' >= 2011 & !inlist(`year',2020,2021,2022) {
		import excel using "${dir_root}/data/state_data/missouri/excel/`year'/`yearname_`year''`month'`suffix_`year''.xlsx", case(lower) allstring clear
	}
	else {
		import excel using "${dir_root}/data/state_data/missouri/excel/`year'/`month'`yearname_`year''`suffix_`year''.xlsx", case(lower) allstring clear
	}

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 

	// rename vars 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	replace v1 = trim(v1)
	replace v1 = stritrim(v1)

	// separate pages/batches
	gen obsnum = _n
	qui sum obsnum if strpos(v1,"APPLICATIONS RECEIVED")
	local batch_start_1 = `r(min)'
	*qui sum obsnum if strpos(v1,"NW REGION") & strpos(v2,"ANDREW")
	if inrange(`ym',ym(2008,10),ym(2009,2)) | inrange(`ym',ym(2010,10),ym(2012,2)) | inrange(`ym',ym(2012,4),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6)) | inrange(`ym',ym(2014,8),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2020,4)) | inrange(`ym',ym(2020,8),ym(2021,9)) {
		noisily sum obsnum if /*strpos(v5,"# APPS") &*/ strpos(v5,"RECEIVED")
	}
	else if inrange(`ym',ym(2009,3),ym(2010,9)) | inlist(`ym',ym(2014,5),ym(2014,7),ym(2020,7)) {
		noisily sum obsnum if /*strpos(v4,"# APPS") &*/ strpos(v4,"RECEIVED")
	}
	else if inlist(`ym',ym(2012,3),ym(2013,12)) | inrange(`ym',ym(2020,5),ym(2020,6)) {
		noisily sum obsnum if /*strpos(v6,"# APPS") &*/ strpos(v6,"RECEIVED")
	}
	else if inlist(`ym',ym(2018,5)) {
		noisily sum obsnum if /*strpos(v7,"# APPS") &*/ strpos(v7,"RECEIVED")	
	}
	else if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		noisily sum obsnum if /*strpos(v2,"") &*/ strpos(v2,"RECEIVED")		
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		noisily sum obsnum if /*strpos(v3,"") &*/ strpos(v3,"RECEIVED")		
	}
	else {
		display	 in red "RECEIVED: include this ym in list of values in code"
		stop 
	}
	assert r(N) == 2
	local batch_start_2 = `r(min)'

*	qui sum obsnum if strpos(v1,"SE REGION") & strpos(v2,"IRON")
*	assert r(N) == 1
*	local batch_start_3 = `r(min)'
	local batch_start_3 = `r(max)'
*	qui sum obsnum if strpos(v1,"NW REGION") & strpos(v3,"ANDREW")
	if inlist(`ym',ym(2021,5)) {
		noisily sum obsnum if /*strpos(v5,"EXPEDITED") &*/ strpos(v5,"APPLICATIONS")
	}
	else if inrange(`ym',ym(2008,10),ym(2010,9)) | inrange(`ym',ym(2011,9),ym(2012,2)) | inrange(`ym',ym(2012,4),ym(2012,8)) | inlist(`ym',ym(2014,5)) | inrange(`ym',ym(2014,7),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2020,4)) | inlist(`ym',ym(2020,7)) | inrange(`ym',ym(2021,6),ym(2021,9)) {
		noisily sum obsnum if /*strpos(v6,"EXPEDITED") &*/ strpos(v6,"APPLICATIONS")
	}
	else if inrange(`ym',ym(2010,10),ym(2011,8)) | inlist(`ym',ym(2012,3),ym(2012,9)) | inrange(`ym',ym(2012,10),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6),ym(2018,5)) | inlist(`ym',ym(2020,5),ym(2020,6)) | inrange(`ym',ym(2020,8),ym(2021,4)) {
		noisily sum obsnum if /*strpos(v7,"EXPEDITED") &*/ strpos(v7,"APPLICATIONS")
	}
	else if inlist(`ym',ym(2013,12)) {
		noisily sum obsnum if /*strpos(v8,"EXPEDITED") &*/ strpos(v8,"APPLICATIONS")	
	}
	else if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		noisily sum obsnum if strpos(v3,"HOUSEHOLDS")		
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		noisily sum obsnum if strpos(v2,"HOUSEHOLDS")		
	}
	else {
		display	 in red "APPLICATIONS: include this ym in list of values in code "
		stop
	}
	assert r(N) == 2
	local batch_start_4 = `r(min)'
*	qui sum obsnum if strpos(v1,"SE REGION") & strpos(v3,"IRON")
*	assert r(N) == 1
*	local batch_start_5 = `r(min)'
	local batch_start_5 = `r(max)'
	if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		qui sum obsnum if strpos(v3,"CHILDREN") 
		local total_households_var v3
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		qui sum obsnum if strpos(v2,"CHILDREN") 
		local total_households_var v2
	}

	if inrange(`ym',ym(2021,10),ym(2022,9)) {
		assert r(N) == 2
		local batch_start_6 = `r(min)'
		local batch_start_7 = `r(max)'
		sum obsnum
		local batch_start_8 = `r(max)'
		local num_pages = 7

	}
	else if `ym' <= ym(2021,9) {
		sum obsnum if v1 == "COUNTY" 
		assert r(N) == 2
		local batch_start_6 = `r(min)'
*		qui sum obsnum if strpos(v1,"NW REGION") & strpos(v2,"ANDREW")
*		assert r(N) == 1
*		local batch_start_7 = `r(min)'
		local batch_start_7 = `r(max)'
*		qui sum obsnum if strpos(v1,"SE REGION") & strpos(v2,"IRON")
		if inlist(`ym',ym(2021,6)) {
			qui sum obsnum if strpos(v4,"HOUSEHOLDS") /*strpos(v4,"TOTAL HOUSEHOLDS") */
			local total_households_var v4
		}
		else if inrange(`ym',ym(2008,10),ym(2012,2)) | inlist(`ym',ym(2013,12)) | inrange(`ym',ym(2014,8),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2018,9)) | inlist(`ym',ym(2020,7),ym(2021,5)) {
			qui sum obsnum if strpos(v5,"HOUSEHOLDS") /*strpos(v5,"TOTAL HOUSEHOLDS") */
			local total_households_var v5
		}
		else if inrange(`ym',ym(2012,3),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6),ym(2018,5)) | inlist(`ym',ym(2020,5),ym(2020,6)) | inrange(`ym',ym(2020,8),ym(2021,4)) | inrange(`ym',ym(2021,7),ym(2021,9)) {
			qui sum obsnum if strpos(v6,"HOUSEHOLDS") /*strpos(v6,"TOTAL HOUSEHOLDS") */
			local total_households_var v6
		}
		else if inlist(`ym',ym(2014,5),ym(2014,7)) | inrange(`ym',ym(2018,10),ym(2020,4)) {
			qui sum obsnum if strpos(v4,"HOUSEHOLDS") /*strpos(v4,"TOTAL HOUSEHOLDS") */	
			local total_households_var v4
		}

		if `ym' < ym(2014,8) | inrange(`ym',ym(2018,10),ym(2020,4)) | inrange(`ym',ym(2021,5),ym(2021,9)) {
			assert r(N) == 2
			local batch_start_8 = `r(min)'
			local batch_start_9 = `r(max)'
			sum obsnum
			local batch_start_10 = `r(max)'
			local num_pages = 9
		}
		else {
			assert r(N) == 4
			local batch_start_8 = `r(min)'
			local batch_start_11 = `r(max)'
			sum obsnum if strpos(`total_households_var',"TOTAL HOUSEHOLDS") & !inlist(obsnum,`batch_start_8',`batch_start_11')
			assert r(N) == 2
			local batch_start_9 = `r(min)'
			local batch_start_10 = `r(max)'
			sum obsnum
			local batch_start_12 = `r(max)'
			local num_pages = 11
		}
	} // end of else 
	else {
		display	 in red "HOUSEHOLDS: include this ym in list of values in code "
		stop 
	}

	// manual drop 
	drop if v1 == "DSS MONTHLY MANAGEMENT REPORT / PAGE 153"
	drop if v1 == "DSS MONTHLY MANAGEMENT REPORT / PAGE 159"
	drop if v1 == "TABLE 26" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "FOOD STAMP APPLICATIONS" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "JULY 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "AUGUST 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "SEPTEMBER 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "OCTOBER 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "DSS FSD/MHD Monthly Management Report Page 151"
	drop if strpos(v1,"TABLE 25") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"TABLE 26") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MAY 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JUNE 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JULY 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"AUGUST 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"SEPTEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"OCTOBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"NOVEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DECEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DSS FSD/MHD MONTHLY MANAGEMENT REPORT")
	drop if strpos(v1,"OCTOBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"NOVEMBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DECEMBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JANUARY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FEBRUARY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MARCH 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"APRIL 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MAY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JUNE 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JULY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"AUGUST 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"SEPTEMBER 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FOOD STAMP PROGRAM PARTICIPATION") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DSS FSD/MHD Monthly Management Report")
	drop if strpos(v1,"OCTOBER 2008") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FOOD STAMP APPLICATIONS") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"TABLE 27") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FOOD STAMP EXPEDITED APPLICATIONS") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	
	// keep page of data that has county data 
	*forvalues n = 1(1)`num_pages' {
	* local n = 2 // county level applications
	*local n = 3 // county level applications continued
	* local n = 4 // county level expedited apps 
	*local n = 5 // county level expedited apps continued
	*local n = 6 // county level enrollment, broken down by npa/pa
	*local n = 7 // county level enrollment, broken down by npa/pa continued
	*local n = 8 // county level enrollment, NOT broken down by npa/pa
	*local n = 9 // county level enrollment, NOT broken down by npa/pa continued

	local page_list 2 3 
	foreach n in `page_list' {

		if inlist(`n',2) {
			local i = 1
		}
		else if inlist(`n',3) {
			local i = 2
		}

		local nplus1 = `n' + 1

		display in red  "`year' `month'" 
		display in red "page `n' of `num_pages'"

		// preserve 
		preserve

		// keep this page/batch of data 
		keep if obsnum >= `batch_start_`n'' & obsnum < `batch_start_`nplus1''
		drop obsnum 

		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		*br

		// manual drop obs 
		if inrange(`ym',ym(2019,7),ym(2019,10)) {
			drop if v3 == "# APPS" & v4 == "TOTAL" & missing(v1) & missing(v2)
			drop if v4 == "EXPEDITED" & v6 == "APPLICATIONS" & missing(v1) & missing(v2)
			dropmiss, force 
			dropmiss, obs force 
			describe, varlist 
			rename (`r(varlist)') (v#), addnumber
		}

		// assert size 
		describe, varlist
		if `n' == 2 {
			assert `r(N)' == 62 | `r(N)' == 61 // includes variable titles	
		}
		else if `n' == 3 {
			assert `r(N)' == 62 | `r(N)' == 63 | `r(N)' == 58 // includes variable titles	
		}
		assert `r(k)' == 11 | `r(k)' == 6

		// rename vars 
		if `r(k)' == 11 {
			rename v1 region 
			rename v2 county 
			rename v3 apps_received
			rename v4 apps_processed
			rename v5 apps_approved
			rename v6 apps_approved_perc
			rename v7 apps_denied 
			rename v8 apps_denied_perc 
			rename v9 apps_delinquent
			rename v10 apps_current_perc 
			rename v11 avg_days_process
		}
		if `r(k)' == 6 {
			rename v1 county
			rename v2 apps_received
			rename v3 apps_approved
			rename v4 apps_denied 
			rename v5 apps_processed
			rename v6 apps_expedited
		}

		// drop top rows 
		drop in 1	


		// clean up county
		capture replace region = trim(region)
		capture replace region = strlower(region)
		replace county = trim(county)
		replace county = strlower(county)
		replace county = "total" if county == "state total" | county == "statewide"
		capture replace region = "total" if region == "state total" | region == "statewide"
		capture replace county = region if inlist(region,"unknown","total") & missing(county)
		replace county = "total" if county == "state total" | county == "statewide"
		assert !strpos(county,"state")
		assert !missing(county)

		// drop region 
		capture drop region 

		// destring
		foreach var in apps_received apps_processed apps_approved apps_approved_perc apps_denied apps_denied_perc apps_delinquent apps_current_perc avg_days_process apps_expedited {
			capture confirm variable `var' 
			if !_rc {
				destring `var', replace 
				confirm numeric variable `var'
			}
		}

		// ym 
		gen ym = `ym'
		format ym %tm 

		// order and sort 
		order county ym 
		sort county ym 

		// save 
		tempfile _`ym'_i`i'
		save `_`ym'_i`i''

		// restore 
		restore 

	} // ends n pages loop 

	// append across pages / i's 
	use `_`ym'_i1', clear 
	append using `_`ym'_i2'
	tempfile _`ym'_county_apps 
	save `_`ym'_county_apps'

} // ends ym loop 

// append all ym's 
forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'_county_apps', clear
	}
	else {
		append using `_`ym'_county_apps'
	}
}
	
// save 
save "${dir_root}/data/state_data/missouri/missouri_county_application.dta", replace

tab ym 
tab county 
*/
*******************************************************************************************************
*******************************************************************************************************
/*
//////////////////////////////////
// COUNTY LEVEL ENROLLMENT DATA //
//////////////////////////////////

forvalues ym = `ym_start'(1)`ym_end' {

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace
	replace month = "0" + month if strlen(month) == 1
	local month = month
	local year = year 
	display in red  "`year' `month'" 

	// import 
	if `year' >= 2011 & !inlist(`year',2020,2021,2022) {
		import excel using "${dir_root}/data/state_data/missouri/excel/`year'/`yearname_`year''`month'`suffix_`year''.xlsx", case(lower) allstring clear
	}
	else {
		import excel using "${dir_root}/data/state_data/missouri/excel/`year'/`month'`yearname_`year''`suffix_`year''.xlsx", case(lower) allstring clear
	}

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 

	// rename vars 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	replace v1 = trim(v1)
	replace v1 = stritrim(v1)

	// separate pages/batches
	gen obsnum = _n
	qui sum obsnum if strpos(v1,"APPLICATIONS RECEIVED")
	local batch_start_1 = `r(min)'
	*qui sum obsnum if strpos(v1,"NW REGION") & strpos(v2,"ANDREW")
	if inrange(`ym',ym(2008,10),ym(2009,2)) | inrange(`ym',ym(2010,10),ym(2012,2)) | inrange(`ym',ym(2012,4),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6)) | inrange(`ym',ym(2014,8),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2020,4)) | inrange(`ym',ym(2020,8),ym(2021,9)) {
		noisily sum obsnum if /*strpos(v5,"# APPS") &*/ strpos(v5,"RECEIVED")
	}
	else if inrange(`ym',ym(2009,3),ym(2010,9)) | inlist(`ym',ym(2014,5),ym(2014,7),ym(2020,7)) {
		noisily sum obsnum if /*strpos(v4,"# APPS") &*/ strpos(v4,"RECEIVED")
	}
	else if inlist(`ym',ym(2012,3),ym(2013,12)) | inrange(`ym',ym(2020,5),ym(2020,6)) {
		noisily sum obsnum if /*strpos(v6,"# APPS") &*/ strpos(v6,"RECEIVED")
	}
	else if inlist(`ym',ym(2018,5)) {
		noisily sum obsnum if /*strpos(v7,"# APPS") &*/ strpos(v7,"RECEIVED")	
	}
	else if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		noisily sum obsnum if /*strpos(v2,"") &*/ strpos(v2,"RECEIVED")		
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		noisily sum obsnum if /*strpos(v3,"") &*/ strpos(v3,"RECEIVED")		
	}
	else {
		display	 in red "RECEIVED: include this ym in list of values in code"
		stop 
	}
	assert r(N) == 2
	local batch_start_2 = `r(min)'

*	qui sum obsnum if strpos(v1,"SE REGION") & strpos(v2,"IRON")
*	assert r(N) == 1
*	local batch_start_3 = `r(min)'
	local batch_start_3 = `r(max)'
*	qui sum obsnum if strpos(v1,"NW REGION") & strpos(v3,"ANDREW")
	if inlist(`ym',ym(2021,5)) {
		noisily sum obsnum if /*strpos(v5,"EXPEDITED") &*/ strpos(v5,"APPLICATIONS")
	}
	else if inrange(`ym',ym(2008,10),ym(2010,9)) | inrange(`ym',ym(2011,9),ym(2012,2)) | inrange(`ym',ym(2012,4),ym(2012,8)) | inlist(`ym',ym(2014,5)) | inrange(`ym',ym(2014,7),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2020,4)) | inlist(`ym',ym(2020,7)) | inrange(`ym',ym(2021,6),ym(2021,9)) {
		noisily sum obsnum if /*strpos(v6,"EXPEDITED") &*/ strpos(v6,"APPLICATIONS")
	}
	else if inrange(`ym',ym(2010,10),ym(2011,8)) | inlist(`ym',ym(2012,3),ym(2012,9)) | inrange(`ym',ym(2012,10),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6),ym(2018,5)) | inlist(`ym',ym(2020,5),ym(2020,6)) | inrange(`ym',ym(2020,8),ym(2021,4)) {
		noisily sum obsnum if /*strpos(v7,"EXPEDITED") &*/ strpos(v7,"APPLICATIONS")
	}
	else if inlist(`ym',ym(2013,12)) {
		noisily sum obsnum if /*strpos(v8,"EXPEDITED") &*/ strpos(v8,"APPLICATIONS")	
	}
	else if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		noisily sum obsnum if strpos(v3,"HOUSEHOLDS")		
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		noisily sum obsnum if strpos(v2,"HOUSEHOLDS")		
	}
	else {
		display	 in red "APPLICATIONS: include this ym in list of values in code "
		stop
	}
	assert r(N) == 2
	local batch_start_4 = `r(min)'
*	qui sum obsnum if strpos(v1,"SE REGION") & strpos(v3,"IRON")
*	assert r(N) == 1
*	local batch_start_5 = `r(min)'
	local batch_start_5 = `r(max)'
	if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		qui sum obsnum if strpos(v3,"CHILDREN") 
		local total_households_var v3
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		qui sum obsnum if strpos(v2,"CHILDREN") 
		local total_households_var v2
	}

	if inrange(`ym',ym(2021,10),ym(2022,9)) {
		assert r(N) == 2
		local batch_start_6 = `r(min)'
		local batch_start_7 = `r(max)'
		sum obsnum
		local batch_start_8 = `r(max)'
		local num_pages = 7

	}
	else if `ym' <= ym(2021,9) {
		sum obsnum if v1 == "COUNTY" 
		assert r(N) == 2
		local batch_start_6 = `r(min)'
*		qui sum obsnum if strpos(v1,"NW REGION") & strpos(v2,"ANDREW")
*		assert r(N) == 1
*		local batch_start_7 = `r(min)'
		local batch_start_7 = `r(max)'
*		qui sum obsnum if strpos(v1,"SE REGION") & strpos(v2,"IRON")
		if inlist(`ym',ym(2021,6)) {
			qui sum obsnum if strpos(v4,"HOUSEHOLDS") /*strpos(v4,"TOTAL HOUSEHOLDS") */
			local total_households_var v4
		}
		else if inrange(`ym',ym(2008,10),ym(2012,2)) | inlist(`ym',ym(2013,12)) | inrange(`ym',ym(2014,8),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2018,9)) | inlist(`ym',ym(2020,7),ym(2021,5)) {
			qui sum obsnum if strpos(v5,"HOUSEHOLDS") /*strpos(v5,"TOTAL HOUSEHOLDS") */
			local total_households_var v5
		}
		else if inrange(`ym',ym(2012,3),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6),ym(2018,5)) | inlist(`ym',ym(2020,5),ym(2020,6)) | inrange(`ym',ym(2020,8),ym(2021,4)) | inrange(`ym',ym(2021,7),ym(2021,9)) {
			qui sum obsnum if strpos(v6,"HOUSEHOLDS") /*strpos(v6,"TOTAL HOUSEHOLDS") */
			local total_households_var v6
		}
		else if inlist(`ym',ym(2014,5),ym(2014,7)) | inrange(`ym',ym(2018,10),ym(2020,4)) {
			qui sum obsnum if strpos(v4,"HOUSEHOLDS") /*strpos(v4,"TOTAL HOUSEHOLDS") */	
			local total_households_var v4
		}

		if `ym' < ym(2014,8) | inrange(`ym',ym(2018,10),ym(2020,4)) | inrange(`ym',ym(2021,5),ym(2021,9)) {
			assert r(N) == 2
			local batch_start_8 = `r(min)'
			local batch_start_9 = `r(max)'
			sum obsnum
			local batch_start_10 = `r(max)'
			local num_pages = 9
		}
		else {
			assert r(N) == 4
			local batch_start_8 = `r(min)'
			local batch_start_11 = `r(max)'
			sum obsnum if strpos(`total_households_var',"TOTAL HOUSEHOLDS") & !inlist(obsnum,`batch_start_8',`batch_start_11')
			assert r(N) == 2
			local batch_start_9 = `r(min)'
			local batch_start_10 = `r(max)'
			sum obsnum
			local batch_start_12 = `r(max)'
			local num_pages = 11
		}
	} // end of else 
	else {
		display	 in red "HOUSEHOLDS: include this ym in list of values in code "
		stop 
	}

	// manual drop 
	drop if v1 == "DSS MONTHLY MANAGEMENT REPORT / PAGE 153"
	drop if v1 == "DSS MONTHLY MANAGEMENT REPORT / PAGE 159"
	drop if v1 == "TABLE 26" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "FOOD STAMP APPLICATIONS" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "JULY 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "AUGUST 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "SEPTEMBER 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "OCTOBER 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "DSS FSD/MHD Monthly Management Report Page 151"
	drop if strpos(v1,"TABLE 25") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"TABLE 26") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MAY 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JUNE 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JULY 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"AUGUST 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"SEPTEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"OCTOBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"NOVEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DECEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DSS FSD/MHD MONTHLY MANAGEMENT REPORT")
	drop if strpos(v1,"OCTOBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"NOVEMBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DECEMBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JANUARY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FEBRUARY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MARCH 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"APRIL 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MAY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JUNE 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JULY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"AUGUST 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"SEPTEMBER 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FOOD STAMP PROGRAM PARTICIPATION") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"Page 156 DSS FSD/MHD Monthly Management Report")

	// keep page of data that has county data 
	*forvalues n = 1(1)`num_pages' {
	* local n = 2 // county level applications
	*local n = 3 // county level applications continued
	* local n = 4 // county level expedited apps 
	*local n = 5 // county level expedited apps continued
	*local n = 6 // county level enrollment, broken down by npa/pa
	*local n = 7 // county level enrollment, broken down by npa/pa continued
	*local n = 8 // county level enrollment, NOT broken down by npa/pa
	*local n = 9 // county level enrollment, NOT broken down by npa/pa continued
	
	if inrange(`ym',ym(2008,10),ym(2021,9)) {
		local page_list 8 9
	}
	else if inrange(`ym',ym(2021,10),ym(2022,9)) {
		local page_list 4 5
	}
	foreach n in `page_list' {

		if inlist(`n',8,4) {
			local i = 1
		}
		else if inlist(`n',9,5) {
			local i = 2
		}

		local nplus1 = `n' + 1

		display in red  "`year' `month'" 
		display in red "page `n' of `num_pages'"

		// preserve 
		preserve

		// keep this page/batch of data 
		keep if obsnum >= `batch_start_`n'' & obsnum < `batch_start_`nplus1''
		drop obsnum 

		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		*br

		// manual drop obs 
		if inrange(`ym',ym(2019,7),ym(2019,10)) {
			drop if strpos(v5,"TABLE 28") 
			drop if v2 == "TOTAL" & v3 == "TOTAL"
			drop if v9 == "AVERAGE" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
			drop if v9 == "VALUE OF" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
			drop if v9 == "BENEFITS" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
		}
		if (inrange(`ym',ym(2010,10),ym(2012,3))  | inlist(`ym',ym(2013,12),ym(2014,5),ym(2014,7))) & `n' == 9 {
			drop if _n >= 60
			dropmiss, force 
			dropmiss, obs force 
			describe, varlist 
			rename (`r(varlist)') (v#), addnumber
		}
		if (inrange(`ym',ym(2018,10),ym(2020,4)) | inlist(`ym',ym(2021,5),ym(2021,6))) & `n' == 9 {
			drop if _n >= 61
			dropmiss, force 
			dropmiss, obs force 
			describe, varlist 
			rename (`r(varlist)') (v#), addnumber
		}
		
		// assert size 
		describe, varlist
		if `n' == 8 {
			assert `r(N)' == 62 | `r(N)' == 59 // includes variable titles	
		}
		else if `n' == 9 {
			assert `r(N)' == 61 | `r(N)' == 59 | `r(N)' == 60 | `r(N)' == 62 // includes variable titles	
		}
		else if `n' == 6 {
			assert `r(N)' == 61 // includes variable titles		
		}
		assert `r(k)' == 7 | `r(k)' == 9 | `r(k)' == 6

		// rename vars 
		if `r(k)' == 7 {
			rename v1 region 
			rename v2 county 
			rename v3 households 
			rename v4 individuals 
			rename v5 issuance
			rename v6 avg_benefits_perhousehold
			rename v7 avg_benefits_perperson		
		}
		else if `r(k)' == 9 {
			rename v1 county 
			rename v2 individuals 
			rename v3 households 
			rename v4 individuals_pa
			rename v5 households_pa
			rename v6 individuals_npa
			rename v7 households_npa	
			rename v8 issuance 
			rename v9 avg_benefits_perperson
		}
		else if `r(k)' == 6 {
			rename v1 county 
			rename v2 households 
			rename v3 individuals 
			rename v4 issuance
			rename v5 avg_benefits_perhousehold
			rename v6 avg_benefits_perperson		
		}		
		// drop top rows 
		while !inlist(county,"COUNTY") & !inlist(households,"TOTAL HOUSEHOLDS") & !inlist(households,"HOUSEHOLDS") {
			drop in 1		
		}
		drop in 1	

		// clean up county
		capture replace region = trim(region)
		capture replace region = strlower(region)
		replace county = trim(county)
		replace county = strlower(county)
		replace county = "total" if county == "state total" | county == "statewide"
		capture replace region = "total" if region == "state total" | region == "statewide"
		capture replace county = region if inlist(region,"unknown","total") & missing(county)
		replace county = "total" if county == "state total" | county == "statewide"
		assert !strpos(county,"state")
		assert !missing(county)

		// drop region 
		capture drop region 

		// destring
		foreach var in households individuals issuance avg_benefits_perhousehold avg_benefits_perperson households_npa households_pa individuals_npa individuals_pa {
			capture confirm variable `var' 
			if !_rc {
				destring `var', replace 
				confirm numeric variable `var'
			}
		}

		// ym 
		gen ym = `ym'
		format ym %tm 

		// order and sort 
		order county ym 
		sort county ym 

		// save 
		tempfile _`ym'_i`i'
		save `_`ym'_i`i''

		// restore 
		restore 

	} // ends n pages loop 

	// append across pages / i's 
	use `_`ym'_i1', clear 
	append using `_`ym'_i2'
	tempfile _`ym'_county 
	save `_`ym'_county'

} // ends ym loop 

// append all ym's 
forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'_county', clear
	}
	else {
		append using `_`ym'_county'
	}
}
	
// save 
save "${dir_root}/data/state_data/missouri/missouri_county_enrollment.dta", replace

tab ym 
tab county 

*/
*******************************************************************************		
*******************************************************************************
/*
////////////////
// STATE DATA //
////////////////

forvalues ym = `ym_start'(1)`ym_end' {

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace
	replace month = "0" + month if strlen(month) == 1
	local month = month
	local year = year 
	display in red  "`year' `month'" 

	// import 
	if `year' >= 2011 & !inlist(`year',2020,2021,2022) {
		import excel using "${dir_root}/data/state_data/missouri/excel/`year'/`yearname_`year''`month'`suffix_`year''.xlsx", case(lower) allstring clear
	}
	else {
		import excel using "${dir_root}/data/state_data/missouri/excel/`year'/`month'`yearname_`year''`suffix_`year''.xlsx", case(lower) allstring clear
	}

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 

	// rename vars 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	replace v1 = trim(v1)
	replace v1 = stritrim(v1)

	// separate pages/batches
	gen obsnum = _n
	qui sum obsnum if strpos(v1,"APPLICATIONS RECEIVED")
	local batch_start_1 = `r(min)'
	*qui sum obsnum if strpos(v1,"NW REGION") & strpos(v2,"ANDREW")
	if inrange(`ym',ym(2008,10),ym(2009,2)) | inrange(`ym',ym(2010,10),ym(2012,2)) | inrange(`ym',ym(2012,4),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6)) | inrange(`ym',ym(2014,8),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2020,4)) | inrange(`ym',ym(2020,8),ym(2021,9)) {
		noisily sum obsnum if /*strpos(v5,"# APPS") &*/ strpos(v5,"RECEIVED")
	}
	else if inrange(`ym',ym(2009,3),ym(2010,9)) | inlist(`ym',ym(2014,5),ym(2014,7),ym(2020,7)) {
		noisily sum obsnum if /*strpos(v4,"# APPS") &*/ strpos(v4,"RECEIVED")
	}
	else if inlist(`ym',ym(2012,3),ym(2013,12)) | inrange(`ym',ym(2020,5),ym(2020,6)) {
		noisily sum obsnum if /*strpos(v6,"# APPS") &*/ strpos(v6,"RECEIVED")
	}
	else if inlist(`ym',ym(2018,5)) {
		noisily sum obsnum if /*strpos(v7,"# APPS") &*/ strpos(v7,"RECEIVED")	
	}
	else if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		noisily sum obsnum if /*strpos(v2,"") &*/ strpos(v2,"RECEIVED")		
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		noisily sum obsnum if /*strpos(v3,"") &*/ strpos(v3,"RECEIVED")		
	}
	else {
		display	 in red "RECEIVED: include this ym in list of values in code"
		stop 
	}
	assert r(N) == 2
	local batch_start_2 = `r(min)'

*	qui sum obsnum if strpos(v1,"SE REGION") & strpos(v2,"IRON")
*	assert r(N) == 1
*	local batch_start_3 = `r(min)'
	local batch_start_3 = `r(max)'
*	qui sum obsnum if strpos(v1,"NW REGION") & strpos(v3,"ANDREW")
	if inlist(`ym',ym(2021,5)) {
		noisily sum obsnum if /*strpos(v5,"EXPEDITED") &*/ strpos(v5,"APPLICATIONS")
	}
	else if inrange(`ym',ym(2008,10),ym(2010,9)) | inrange(`ym',ym(2011,9),ym(2012,2)) | inrange(`ym',ym(2012,4),ym(2012,8)) | inlist(`ym',ym(2014,5)) | inrange(`ym',ym(2014,7),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2020,4)) | inlist(`ym',ym(2020,7)) | inrange(`ym',ym(2021,6),ym(2021,9)) {
		noisily sum obsnum if /*strpos(v6,"EXPEDITED") &*/ strpos(v6,"APPLICATIONS")
	}
	else if inrange(`ym',ym(2010,10),ym(2011,8)) | inlist(`ym',ym(2012,3),ym(2012,9)) | inrange(`ym',ym(2012,10),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6),ym(2018,5)) | inlist(`ym',ym(2020,5),ym(2020,6)) | inrange(`ym',ym(2020,8),ym(2021,4)) {
		noisily sum obsnum if /*strpos(v7,"EXPEDITED") &*/ strpos(v7,"APPLICATIONS")
	}
	else if inlist(`ym',ym(2013,12)) {
		noisily sum obsnum if /*strpos(v8,"EXPEDITED") &*/ strpos(v8,"APPLICATIONS")	
	}
	else if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		noisily sum obsnum if strpos(v3,"HOUSEHOLDS")		
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		noisily sum obsnum if strpos(v2,"HOUSEHOLDS")		
	}
	else {
		display	 in red "APPLICATIONS: include this ym in list of values in code "
		stop
	}
	assert r(N) == 2
	local batch_start_4 = `r(min)'
*	qui sum obsnum if strpos(v1,"SE REGION") & strpos(v3,"IRON")
*	assert r(N) == 1
*	local batch_start_5 = `r(min)'
	local batch_start_5 = `r(max)'
	if inrange(`ym',ym(2021,10),ym(2022,3)) | inlist(`ym',ym(2022,5),ym(2022,7),ym(2022,8),ym(2022,9)) {
		qui sum obsnum if strpos(v3,"CHILDREN") 
		local total_households_var v3
	}
	else if inlist(`ym',ym(2022,4),ym(2022,6)) {
		qui sum obsnum if strpos(v2,"CHILDREN") 
		local total_households_var v2
	}

	if inrange(`ym',ym(2021,10),ym(2022,9)) {
		assert r(N) == 2
		local batch_start_6 = `r(min)'
		local batch_start_7 = `r(max)'
		sum obsnum
		local batch_start_8 = `r(max)'
		local num_pages = 7

	}
	else if `ym' <= ym(2021,9) {
		sum obsnum if v1 == "COUNTY" 
		assert r(N) == 2
		local batch_start_6 = `r(min)'
*		qui sum obsnum if strpos(v1,"NW REGION") & strpos(v2,"ANDREW")
*		assert r(N) == 1
*		local batch_start_7 = `r(min)'
		local batch_start_7 = `r(max)'
*		qui sum obsnum if strpos(v1,"SE REGION") & strpos(v2,"IRON")
		if inlist(`ym',ym(2021,6)) {
			qui sum obsnum if strpos(v4,"HOUSEHOLDS") /*strpos(v4,"TOTAL HOUSEHOLDS") */
			local total_households_var v4
		}
		else if inrange(`ym',ym(2008,10),ym(2012,2)) | inlist(`ym',ym(2013,12)) | inrange(`ym',ym(2014,8),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2018,9)) | inlist(`ym',ym(2020,7),ym(2021,5)) {
			qui sum obsnum if strpos(v5,"HOUSEHOLDS") /*strpos(v5,"TOTAL HOUSEHOLDS") */
			local total_households_var v5
		}
		else if inrange(`ym',ym(2012,3),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6),ym(2018,5)) | inlist(`ym',ym(2020,5),ym(2020,6)) | inrange(`ym',ym(2020,8),ym(2021,4)) | inrange(`ym',ym(2021,7),ym(2021,9)) {
			qui sum obsnum if strpos(v6,"HOUSEHOLDS") /*strpos(v6,"TOTAL HOUSEHOLDS") */
			local total_households_var v6
		}
		else if inlist(`ym',ym(2014,5),ym(2014,7)) | inrange(`ym',ym(2018,10),ym(2020,4)) {
			qui sum obsnum if strpos(v4,"HOUSEHOLDS") /*strpos(v4,"TOTAL HOUSEHOLDS") */	
			local total_households_var v4
		}

		if `ym' < ym(2014,8) | inrange(`ym',ym(2018,10),ym(2020,4)) | inrange(`ym',ym(2021,5),ym(2021,9)) {
			assert r(N) == 2
			local batch_start_8 = `r(min)'
			local batch_start_9 = `r(max)'
			sum obsnum
			local batch_start_10 = `r(max)'
			local num_pages = 9
		}
		else {
			assert r(N) == 4
			local batch_start_8 = `r(min)'
			local batch_start_11 = `r(max)'
			sum obsnum if strpos(`total_households_var',"TOTAL HOUSEHOLDS") & !inlist(obsnum,`batch_start_8',`batch_start_11')
			assert r(N) == 2
			local batch_start_9 = `r(min)'
			local batch_start_10 = `r(max)'
			sum obsnum
			local batch_start_12 = `r(max)'
			local num_pages = 11
		}
	} // end of else 
	else {
		display	 in red "HOUSEHOLDS: include this ym in list of values in code "
		stop 
	}

	// manual drop 
	drop if v1 == "DSS MONTHLY MANAGEMENT REPORT / PAGE 153"
	drop if v1 == "DSS MONTHLY MANAGEMENT REPORT / PAGE 159"
	drop if v1 == "TABLE 26" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "FOOD STAMP APPLICATIONS" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "JULY 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "AUGUST 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "SEPTEMBER 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "OCTOBER 2019" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if v1 == "DSS FSD/MHD Monthly Management Report Page 151"
	drop if strpos(v1,"TABLE 25") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"TABLE 26") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MAY 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JUNE 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JULY 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"AUGUST 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"SEPTEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"OCTOBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"NOVEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DECEMBER 2020") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DSS FSD/MHD MONTHLY MANAGEMENT REPORT")
	drop if strpos(v1,"OCTOBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"NOVEMBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DECEMBER 2021") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JANUARY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FEBRUARY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MARCH 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"APRIL 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"MAY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JUNE 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"JULY 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"AUGUST 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"SEPTEMBER 2022") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FOOD STAMP PROGRAM PARTICIPATION") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"DSS FSD/MHD Monthly Management Report")
	drop if strpos(v1,"OCTOBER 2008") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FOOD STAMP APPLICATIONS") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"TABLE 27") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	drop if strpos(v1,"FOOD STAMP EXPEDITED APPLICATIONS") & missing(v2) & missing(v3) & missing(v4) & missing(v5)
	
	// keep page of data that has county data 
	*forvalues n = 1(1)`num_pages' {
	* local n = 2 // county level applications
	*local n = 3 // county level applications continued
	* local n = 4 // county level expedited apps 
	*local n = 5 // county level expedited apps continued
	*local n = 6 // county level enrollment, broken down by npa/pa
	*local n = 7 // county level enrollment, broken down by npa/pa continued
	*local n = 8 // county level enrollment, NOT broken down by npa/pa
	*local n = 9 // county level enrollment, NOT broken down by npa/pa continued

*	local page_list 1 
*	foreach n in `page_list' {
	// keep a particular page of data
	// only using page 1 for now 
	local n = 1

		local nplus1 = `n' + 1

		display in red "page `n' of `num_pages'"

		// preserve 
		// preserve

		// keep this page/batch of data 
		keep if obsnum >= `batch_start_`n'' & obsnum < `batch_start_`nplus1''
		drop obsnum 

		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber

		// assert shape 
		if `n' == 1 {

			if inlist(`ym',ym(2015,4),ym(2015,5),ym(2017,11),ym(2017,12)) | inrange(`ym',ym(2019,7),ym(2019,10)) | inrange(`ym',ym(2021,10),ym(2022,9)) {

				drop if v1 == "TOTAL BENEFITS ISSUED" & missing(v2) & missing(v3) & missing(v4) & missing(v5)
				replace v1 = "TOTAL BENEFITS ISSUED" if missing(v1) & !missing(v2) & !missing(v3) & !missing(v5) & !missing(v6) & !missing(v7) & !missing(v8) //strpos(v2,"104276166")
				drop if v1 == "AVERAGE VALUE OF BENEFITS"
				capture drop if strpos(v4,"TOTAL") & v15 == "AVERAGE"
				
				dropmiss, force 
				dropmiss, obs force 
				describe, varlist 
				rename (`r(varlist)') (v#), addnumber
				assert r(k) == 8
				assert r(N) == 13
	
				// transpose data, including new variable names first 
				gen varname = ""
				replace varname = "apps_received" 				if strpos(v1,"APPLICATIONS RECEIVED")
				replace varname = "apps_approved" 				if strpos(v1,"APPLICATIONS APPROVED")
				replace varname = "apps_denied" 				if strpos(v1,"APPLICATIONS REJECTED")
				replace varname = "apps_expedited" 				if strpos(v1,"APPLICATIONS EXPEDITED")
				replace varname = "households" 					if strpos(v1,"HOUSEHOLDS RECEIVING")
				replace varname = "households_pa" 				if strpos(v1,"PUBLIC ASSISTANCE") & _n == 6
				replace varname = "households_npa" 				if strpos(v1,"NON-PUBLIC ASSISTANCE") & _n == 7
				replace varname = "individuals" 					if strpos(v1,"PERSONS RECEIVING")
				replace varname = "individuals_pa" 					if strpos(v1,"PUBLIC ASSISTANCE") & _n == 9
				replace varname = "individuals_npa" 				if strpos(v1,"NON-PUBLIC ASSISTANCE") & _n == 10
				replace varname = "issuance" 					if strpos(v1,"TOTAL BENEFITS ISSUED")
				replace varname = "avg_benefits_perhousehold" 	if strpos(v1,"PER HOUSEHOLD") // strpos(v1,"AVERAGE VALUE OF BENEFITS")
				replace varname = "avg_benefits_perperson" 		if strpos(v1,"PER PERSON") // strpos(v1,"AVERAGE VALUE OF BENEFITS")
				replace varname = "avg_days_process" 			if strpos(v1,"AVERAGE DAYS TO PROCESS") 
				replace varname = "children" 					if strpos(v1,"CHILDREN") 
				replace varname = "disabled" 					if strpos(v1,"DISABLED") 
				replace varname = "age_18_59" 					if strpos(v1,"ADULTS AGES 18-59")
				replace varname = "age_60" 						if strpos(v1,"ADULTS AGE 60+")
				order varname
		
				drop v1 
				sxpose, clear firstnames
	
				if inrange(`ym',ym(2021,10),ym(2022,9))  {
					split avg_benefits_perperson, parse("$")
					rename avg_benefits_perperson  avg_benefits_perpersonOG
					rename avg_benefits_perperson1 percs
					rename avg_benefits_perperson2 avg_benefits_perhousehold
					rename avg_benefits_perperson3 avg_benefits_perperson
					drop avg_benefits_perpersonOG
					drop percs 
				}


				// continue to reshape, trim 
				describe, varlist 
				if inrange(`ym',ym(2021,10),ym(2022,9)) {
					assert r(k) == 14
				}
				else {
					assert r(k) == 13	
				}
				assert r(N) == 7
			
				keep if _n <= 4 // other numbers are percentage changes
				gen ym = .
				replace ym = `ym'      if _n == 1
				replace ym = `ym' - 1  if _n == 2
				replace ym = `ym' - 2  if _n == 3
				replace ym = `ym' - 12 if _n == 4
				format ym %tm 

				if inrange(`ym',ym(2021,10),ym(2022,9)) {
					// destring 
					foreach var in apps_received apps_approved apps_denied apps_expedited avg_days_process households individuals children disabled age_18_59 age_60 issuance avg_benefits_perhousehold avg_benefits_perperson {
						destring `var', replace 
						confirm numeric variable `var'
					}

				}
				else {
					// destring 
					foreach var in apps_received apps_approved apps_denied apps_expedited households households_pa households_npa individuals individuals_pa individuals_npa issuance avg_benefits_perhousehold avg_benefits_perperson {
						destring `var', replace 
						confirm numeric variable `var'
					}
				}	
			}
			
			else if `ym' <= ym(2021,9) & !inlist(`ym',ym(2015,4),ym(2015,5),ym(2017,11),ym(2017,12)) & !inrange(`ym',ym(2019,7),ym(2019,10)) {
				assert r(k) == 8
				assert r(N) == 12
	
				// transpose data, including new variable names first 
				gen varname = ""
				replace varname = "apps_received" 		if strpos(v1,"APPLICATIONS RECEIVED")
				replace varname = "apps_approved" 		if strpos(v1,"APPLICATIONS APPROVED")
				replace varname = "apps_denied" 		if strpos(v1,"APPLICATIONS REJECTED")
				replace varname = "apps_expedited" 		if strpos(v1,"APPLICATIONS EXPEDITED")
				replace varname = "households" 			if strpos(v1,"HOUSEHOLDS RECEIVING")
				replace varname = "households_pa" 		if strpos(v1,"PUBLIC ASSISTANCE") & _n == 6
				replace varname = "households_npa" 		if strpos(v1,"NON-PUBLIC ASSISTANCE") & _n == 7
				replace varname = "individuals" 			if strpos(v1,"PERSONS RECEIVING")
				replace varname = "individuals_pa" 			if strpos(v1,"PUBLIC ASSISTANCE") & _n == 9
				replace varname = "individuals_npa" 		if strpos(v1,"NON-PUBLIC ASSISTANCE") & _n == 10
				replace varname = "issuance" 			if strpos(v1,"TOTAL BENEFITS ISSUED")
				replace varname = "avg_benefits" 		if strpos(v1,"AVERAGE VALUE OF BENEFITS")
				order varname
				drop v1 
				sxpose, clear firstnames
	
				// continue to reshape, trim 
				describe, varlist 
				assert r(k) == 12
				assert r(N) == 7
				keep if _n <= 4 // other numbers are percentage changes
				gen ym = .
				replace ym = `ym'      if _n == 1
				replace ym = `ym' - 1  if _n == 2
				replace ym = `ym' - 2  if _n == 3
				replace ym = `ym' - 12 if _n == 4
				format ym %tm 
	
				// split one more variable 
				split avg_benefits, parse("$")
				drop avg_benefits1 
				rename avg_benefits2 avg_benefits_perhousehold
				rename avg_benefits3 avg_benefits_perperson
				drop avg_benefits

				// destring 
				foreach var in apps_received apps_approved apps_denied apps_expedited households households_pa households_npa individuals individuals_pa individuals_npa issuance avg_benefits_perhousehold avg_benefits_perperson {
					destring `var', replace 
					confirm numeric variable `var'
				}
	
			}
			
			// sort and order 
			order ym 
			sort ym 

			// save 
			tempfile _`ym'_page1
			save `_`ym'_page1'
			

		} // end of page n = 1

	*} // end of pages loop

} // end of ym loop


***************************************************
forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'_page1', clear
	}
	else {
		*append using `_`ym'_page`n''
		duplicates tag ym, gen(dup)
		assert dup == 0
		drop dup 
		merge 1:1 ym using `_`ym'_page1', update nogen
	}	
}

// drop duplicates
duplicates drop
duplicates tag ym, gen(dup)
br if dup == 1
bysort ym (individuals): gen dup2 = _n 

*twoway connected individuals ym, xline(585) xline(596)
// NOTE: individuals started to be counted differently in 2008m10. The retrospective observations in 2007 through 2009m9 are not comparable to other data, as seen in the graph.
// these data should be dropped 
replace individuals 				= . if inrange(ym,ym(2007,10),ym(2008,9)) | (inrange(ym,ym(2008,10),ym(2009,9)) & dup2 == 2)
capture confirm variable individuals_npa
if !_rc {
    di in red "individuals_npa exists"
	replace individuals_npa 			= . if inrange(ym,ym(2007,10),ym(2008,9)) | (inrange(ym,ym(2008,10),ym(2009,9)) & dup2 == 2)
}
else {
	di in red "individuals_npa does not exist"
}

capture confirm variable individuals_pa
if !_rc {
    di in red "individuals_pa exists"
	replace individuals_pa 				= . if inrange(ym,ym(2007,10),ym(2008,9)) | (inrange(ym,ym(2008,10),ym(2009,9)) & dup2 == 2)
}
else {
	di in red "individuals_pa does not exist"
}
replace avg_benefits_perperson 	= . if inrange(ym,ym(2007,10),ym(2008,9)) | (inrange(ym,ym(2008,10),ym(2009,9)) & dup2 == 2)
drop dup dup2
duplicates tag ym, gen(dup)
drop if dup == 1 & missing(individuals) // drop duplicate months data 
drop dup 

// manually fix some duplicates
drop if ym == ym(2019,2) & households == 21323 // this household count is completely off
drop if ym == ym(2012,11) & apps_denied == 15401 // one number off
drop if ym == ym(2010,1) & apps_approved == 57281 // one number off

// check again
duplicates tag ym, gen(dup)
assert dup == 0
drop dup
 
// county: is total, statewide
gen county = "total"

// save this data 
save "${dir_root}/data/state_data/missouri/missouri_state.dta", replace
*/

*****************************************************************************
//////////////////////
// APPEND AND MERGE //
////////////////////// 

// county level data first 
foreach dataset in missouri_county_enrollment missouri_county_application missouri_county_apps_exp {
	
	// display 
	display in red "`dataset'"

	// load data 
	use "${dir_root}/data/state_data/missouri/`dataset'.dta", clear 
	
	// copy county var so it is easier to browse 
	gen county_copy = county 
	drop county 
	rename county_copy county 
	order county
	
	// check list of counties 
	tab county 
	
	// drop regional totals
	drop if county == "nw total"
	drop if county == "ne total"
	drop if county == "se total"
	drop if county == "sw total"
	drop if county == "kc total"
	drop if county == "stl total"
	
	// drop state totals (they are in the state level data)
	drop if county == "total" | county == "statewide"
	
	// standardize names 
	replace county = "unknown" if county == "not available"

	// assert no totals are left 
	assert !strpos(county,"total")
	
	// assert level of the data 
	duplicates tag county ym, gen(dup)
	assert dup == 0
	drop dup 
	
	// save
	tempfile `dataset'
	save ``dataset''

}

// prep statewide data 
use "${dir_root}/data/state_data/missouri/missouri_state.dta", clear

// assert state level data only 
assert county == "total"

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 
	
// save
tempfile missouri_state
save `missouri_state'

// merge all county data 
use `missouri_county_enrollment', clear
merge 1:1 county ym using `missouri_county_application', update 
assert inlist(_m,1,3)
assert ym == ym(2018,2) if _m == 1 // no unknown data for application 
drop _m 

merge 1:1 county ym using `missouri_county_apps_exp', update
assert inlist(_m,1,4)
assert inrange(ym,ym(2021,10),`ym_end') | county == "unknown" if _m == 1 // no expedited apps detailed data for these months 
drop _m 

// append state data 
append using `missouri_state'

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// expand to full set of dates 
encode county, gen(county_num)
tsset county_num ym 
tsfill, full 
gsort county_num -ym 
by county_num: carryforward county, replace 
gsort county_num ym 
by county_num: carryforward county, replace 
drop county_num

// order and sort 
order county ym 
sort county ym 

// save 
save "${dir_root}/data/state_data/missouri/missouri.dta", replace

tab county 
tab ym 



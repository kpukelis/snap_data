// missouri.do
// imports cases and clients from csvs

local ym_start	 				= ym(2008,10) 
local ym_end 					= ym(2020,12)
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

*KEEP GOING CLEANING PAGE BY PAGE (1 THROUGH 9)page 1 is done
// ym(2019,7) that's when the page splitting gets weird, which caused me to comment out the strpos lines
************************************************************

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
	if `year' >= 2011 & !inlist(`year',2020) {
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
	if inrange(`ym',ym(2008,10),ym(2009,2)) | inrange(`ym',ym(2010,10),ym(2012,2)) | inrange(`ym',ym(2012,4),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6)) | inrange(`ym',ym(2014,8),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2020,4)) | inrange(`ym',ym(2020,8),ym(2020,12)) {
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
	if inrange(`ym',ym(2008,10),ym(2010,9)) | inrange(`ym',ym(2011,9),ym(2012,2)) | inrange(`ym',ym(2012,4),ym(2012,8)) | inlist(`ym',ym(2014,5)) | inrange(`ym',ym(2014,7),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2020,4)) | inlist(`ym',ym(2020,7)) {
		qui sum obsnum if /*strpos(v6,"EXPEDITED") &*/ strpos(v6,"APPLICATIONS")
	}
	else if inrange(`ym',ym(2010,10),ym(2011,8)) | inlist(`ym',ym(2012,3),ym(2012,9)) | inrange(`ym',ym(2012,10),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6),ym(2018,5)) | inlist(`ym',ym(2020,5),ym(2020,6)) | inrange(`ym',ym(2020,8),ym(2020,12)) {
		qui sum obsnum if /*strpos(v7,"EXPEDITED") &*/ strpos(v7,"APPLICATIONS")
	}
	else if inlist(`ym',ym(2013,12)) {
		qui sum obsnum if /*strpos(v8,"EXPEDITED") &*/ strpos(v8,"APPLICATIONS")	
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
	sum obsnum if v1 == "COUNTY"
	assert r(N) == 2
	local batch_start_6 = `r(min)'
*	qui sum obsnum if strpos(v1,"NW REGION") & strpos(v2,"ANDREW")
*	assert r(N) == 1
*	local batch_start_7 = `r(min)'
	local batch_start_7 = `r(max)'
*	qui sum obsnum if strpos(v1,"SE REGION") & strpos(v2,"IRON")
	if inrange(`ym',ym(2008,10),ym(2012,2)) | inlist(`ym',ym(2013,12)) | inrange(`ym',ym(2014,8),ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2018,9)) | inlist(`ym',ym(2020,7)) {
		qui sum obsnum if strpos(v5,"HOUSEHOLDS") /*strpos(v5,"TOTAL HOUSEHOLDS") */
		local total_households_var v5
	}
	else if inrange(`ym',ym(2012,3),ym(2013,11)) | inrange(`ym',ym(2014,1),ym(2014,4)) | inlist(`ym',ym(2014,6),ym(2018,5)) | inlist(`ym',ym(2020,5),ym(2020,6)) | inrange(`ym',ym(2020,8),ym(2020,12)) {
		qui sum obsnum if strpos(v6,"HOUSEHOLDS") /*strpos(v6,"TOTAL HOUSEHOLDS") */
		local total_households_var v6
	}
	else if inlist(`ym',ym(2014,5),ym(2014,7)) | inrange(`ym',ym(2018,10),ym(2020,4)) {
		qui sum obsnum if strpos(v4,"HOUSEHOLDS") /*strpos(v4,"TOTAL HOUSEHOLDS") */	
		local total_households_var v4
	}
	else {
		display	 in red "HOUSEHOLDS: include this ym in list of values in code "
		stop 
	}

	if `ym' < ym(2014,8) | inrange(`ym',ym(2018,10),ym(2020,4)) {
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

	// keep a particular page of data
*	forvalues n = 1(1)`num_pages' {
local n = 1
		local nplus1 = `n' + 1

		// preserve 
*		preserve

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

			if inlist(`ym',ym(2015,4),ym(2015,5),ym(2017,11),ym(2017,12)) | inrange(`ym',ym(2019,7),ym(2019,10)) {

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
				replace varname = "apps_rejected" 				if strpos(v1,"APPLICATIONS REJECTED")
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
				order varname
				drop v1 
				sxpose, clear firstnames
	
				// continue to reshape, trim 
				describe, varlist 
				assert r(k) == 13
				assert r(N) == 7
			
				keep if _n <= 4 // other numbers are percentage changes
				gen ym = .
				replace ym = `ym'      if _n == 1
				replace ym = `ym' - 1  if _n == 2
				replace ym = `ym' - 2  if _n == 3
				replace ym = `ym' - 12 if _n == 4
				format ym %tm 
		
			}
			
			else {
				assert r(k) == 8
				assert r(N) == 12
	
				// transpose data, including new variable names first 
				gen varname = ""
				replace varname = "apps_received" 		if strpos(v1,"APPLICATIONS RECEIVED")
				replace varname = "apps_approved" 		if strpos(v1,"APPLICATIONS APPROVED")
				replace varname = "apps_rejected" 		if strpos(v1,"APPLICATIONS REJECTED")
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
	
			}
			
			// destring 
			foreach var in apps_received apps_approved apps_rejected apps_expedited households households_pa households_npa individuals individuals_pa individuals_npa issuance avg_benefits_perhousehold avg_benefits_perperson {
				destring `var', replace 
				confirm numeric variable `var'
			}

			// sort and order 
			order ym 
			sort ym 

			// save 
			tempfile _`ym'_page`n'
			save `_`ym'_page`n''
			

*		}

	}

}


***************************************************
forvalues ym = `ym_start'(1)`ym_end' {
	*forvalues n = 1(1)`num_pages' {
		if `ym' == `ym_start' {
			use `_`ym'_page`n'', clear
		}
		else {
			append using `_`ym'_page`n''
		}	
	*}
}

**TEMPORARY; later, save all pages together
save "${dir_root}/data/state_data/missouri/missouri_page`n'.dta", replace


*/
******************
***************
************
local n = 1
use "${dir_root}/data/state_data/missouri/missouri_page`n'.dta", clear

// drop duplicates
duplicates drop
duplicates tag ym, gen(dup)
br if dup == 1
bysort ym (individuals): gen dup2 = _n 

*twoway connected individuals ym, xline(585) xline(596)
// NOTE: individuals started to be counted differently in 2008m10. The retrospective observations in 2007 through 2009m9 are not comparable to other data, as seen in the graph.
// these data should be dropped 
replace individuals 				= . if inrange(ym,ym(2007,10),ym(2008,9)) | (inrange(ym,ym(2008,10),ym(2009,9)) & dup2 == 2)
replace individuals_npa 			= . if inrange(ym,ym(2007,10),ym(2008,9)) | (inrange(ym,ym(2008,10),ym(2009,9)) & dup2 == 2)
replace individuals_pa 				= . if inrange(ym,ym(2007,10),ym(2008,9)) | (inrange(ym,ym(2008,10),ym(2009,9)) & dup2 == 2)
replace avg_benefits_perperson 	= . if inrange(ym,ym(2007,10),ym(2008,9)) | (inrange(ym,ym(2008,10),ym(2009,9)) & dup2 == 2)
drop dup dup2
duplicates tag ym, gen(dup)
drop if dup == 1 & missing(individuals) // drop duplicate months data 
drop dup 

// manually fix some duplicates
drop if ym == ym(2019,2) & households == 21323 // this household count is completely off
drop if ym == ym(2012,11) & apps_rejected == 15401 // one number off
drop if ym == ym(2010,1) & apps_approved == 57281 // one number off

// check again
duplicates tag ym, gen(dup)
assert dup == 0
drop dup

**TEMPORARY
save "${dir_root}/data/state_data/missouri/missouri_page`n'.dta", replace


// save just state level data for now 
use "${dir_root}/data/state_data/missouri/missouri_page1.dta", clear
save "${dir_root}/data/state_data/missouri/missouri.dta", replace


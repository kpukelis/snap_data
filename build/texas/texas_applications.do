global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/texas"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local ym_start 					= ym(2014,1)
local ym_end 					= ym(2020,4)
local prefix_2014 				"SNAP-"
local prefix_2015 				"SNAP-"
local prefix_2016 				"SNAP-"
local prefix_2017 				"timeliness-snap-"
local prefix_2018 				"timeliness-snap-"
local prefix_2019 				"timeliness-snap-"
local prefix_2020 				"timeliness-snap-"
local yearname_2014				"-2014"
local yearname_2015				"-2015"
local yearname_2016				"-2016"
local yearname_2017				"-2017"
local yearname_2018				"-2018"
local yearname_2019				"-2019"
local yearname_2020 			"-2020"

*********************************************************************

forvalues ym = `ym_start'(1)`ym_end' {

	display in red "year and month `ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace
	replace month = "0" + month if strlen(month) == 1
	local month = month
	local monthname = month 
	local year = year 
	display in red  "`year' `month'" 

	if inlist(`year',2014,2015,2016) {
		gen monthname = ""
		replace monthname = "January" 	if month == "01"
		replace monthname = "February" 	if month == "02"
		replace monthname = "March" 	if month == "03"
		replace monthname = "April" 	if month == "04"
		replace monthname = "May" 		if month == "05"
		replace monthname = "June" 		if month == "06"
		replace monthname = "July" 		if month == "07"
		replace monthname = "August" 	if month == "08"
		replace monthname = "September" if month == "09"
		replace monthname = "October" 	if month == "10"
		replace monthname = "November" 	if month == "11"
		replace monthname = "December" 	if month == "12"
		local monthname = monthname
	}
	else if inlist(`year',2017,2018,2019,2020) {
		gen monthname = ""
		replace monthname = "jan" 	if month == "01"
		replace monthname = "feb" 	if month == "02"
		replace monthname = "mar" 	if month == "03"
		replace monthname = "apr" 	if month == "04"
		replace monthname = "may" 	if month == "05"
		replace monthname = "jun" 	if month == "06"
		replace monthname = "jul" 	if month == "07"
		replace monthname = "aug" 	if month == "08"
		replace monthname = "sep" 	if month == "09"
		replace monthname = "oct" 	if month == "10"
		replace monthname = "nov" 	if month == "11"
		replace monthname = "dec" 	if month == "12"
		local monthname = monthname
	}
	local filetype xls

	if inrange(`ym',ym(2014,1),ym(2017,3)) | inrange(`ym',ym(2017,5),ym(2018,7)) {
		
		// import 
		import excel using "${dir_root}/excel/application timeliness/`year'/`prefix_`year''`monthname'`yearname_`year''.`filetype'", case(lower) allstring clear
	
		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
	
		// drop non-data rows
		drop if strpos(v1,"SNAP Food Benefits TIMELINESS")
		drop if strpos(v1,"SNAP Food Benefits APPLICATIONS")
		drop if v1 == "Region"
		drop if strpos(v1,"Data from CG-003")
		drop if strpos(v1,"Notes:")
		drop if strpos(v1,"Disposed - the number of applications worked to a decision (approved and/or denied) and provided a benefit if approved.")
		drop if strpos(v1,"Timely - the number of applications disposed within the established time frames for the program.")
		drop if strpos(v1,"SNAP Application Timeliness includes Expedited SNAP Applications.")
		drop if strpos(v1,"Redetermination - consideration of all eligibility criteria for a type program at the end of a certification period to determine ongoing benefits for a new certification period.")
		drop if strpos(v1,"These counts include disaster SNAP applications")
		drop if strpos(v1,"Redetermination - consideration of all eligibility criteria for a type program at the end of a certification period to determine ongoing benefits for")
		drop if strpos(v1,"a new certification period")
		drop if strpos(v1,"End of Worksheet")
		drop if strpos(v1,"SNAP Food Benefits REDETERMINATIONS")
		dropmiss, force 
		dropmiss, obs force 
	
		gen v1_copy = v1
		drop v1
		rename v1_copy v1 
		order v1
	
		// rename
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		assert r(k) == 8
		assert r(N) == 17 | r(N) == 18
		rename v1 region1
		rename v2 apps_disposed
		rename v3 apps_timely
		rename v4 apps_perc_timely
		rename v5 region2
		rename v6 recerts_disposed
		rename v7 recerts_timely
		rename v8 recerts_perc_timely
	
		// fix region 
		replace region1 = trim(region1)
		replace region2 = trim(region2)
		assert region1 == region2
		drop region2 
		rename region1 region 
	
		// destring 
		foreach var in apps_disposed apps_timely apps_perc_timely recerts_disposed recerts_timely recerts_perc_timely {
			destring `var', replace 
			confirm numeric variable `var'
		}
	
		// date 
		gen ym = `ym'
		format ym %tm 
	
		// order and sort 
		order region ym 
		sort region ym 
	
		// save 
		tempfile _`ym'
		save `_`ym''
	}
	else if inrange(`ym',ym(2018,8),ym(2019,6)) | inrange(`ym',ym(2019,8),ym(2020,4)) {
		
		if inrange(`ym',ym(2020,1),ym(2020,3)) {
			local total = 38
		}
		else {
			local total = 36
		}
		local half_total = `total' / 2
		local half_total_plus1 = `half_total' + 1

		// import 
		import excel using "${dir_root}/excel/application timeliness/`year'/`prefix_`year''`monthname'`yearname_`year''.`filetype'", case(lower) allstring clear
	
		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
	
		// drop non-data rows
		drop if strpos(v1,"SNAP Food Benefits TIMELINESS")
		drop if strpos(v1,"SNAP Food Benefits APPLICATIONS")
		drop if v1 == "Region"
		drop if strpos(v1,"Data from CG-003")
		drop if strpos(v1,"Notes:")
		drop if strpos(v1,"Disposed - the number of applications worked to a decision (approved and/or denied) and provided a benefit if approved.")
		drop if strpos(v1,"Timely - the number of applications disposed within the established time frames for the program.")
		drop if strpos(v1,"SNAP Application Timeliness includes Expedited SNAP Applications.")
		drop if strpos(v1,"Redetermination - consideration of all eligibility criteria for a type program at the end of a certification period to determine ongoing benefits for a new certification period.")
		drop if strpos(v1,"These counts include disaster SNAP applications")
		drop if strpos(v1,"Redetermination - consideration of all eligibility criteria for a type program at the end of a certification period to determine ongoing benefits for")
		drop if strpos(v1,"a new certification period")
		drop if strpos(v1,"End of Worksheet")
		drop if strpos(v1,"SNAP Food Benefits REDETERMINATIONS")
		dropmiss, force 
		dropmiss, obs force 
	
		gen v1_copy = v1
		drop v1
		rename v1_copy v1 
		order v1
	
		// reshape
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		assert r(k) == 4
		assert r(N) == `total'
		rename v1 region
		rename v2 disposed
		rename v3 timely
		rename v4 perc_timely
		gen var = ""
		replace var = "apps_" if inrange(_n,1,`half_total')
		replace var = "recerts_" if inrange(_n,`half_total_plus1',`total')
		reshape wide @disposed @timely @perc_timely, i(region) j(var) string

		// fix region 
		replace region = trim(region)

		// destring 
		foreach var in apps_disposed apps_timely apps_perc_timely recerts_disposed recerts_timely recerts_perc_timely {
			destring `var', replace 
			confirm numeric variable `var'
		}
	
		// date 
		gen ym = `ym'
		format ym %tm 
	
		// order and sort 
		order region ym 
		sort region ym 
	
		// save 
		tempfile _`ym'
		save `_`ym''
	}
	else if inlist(`ym',ym(2017,4),ym(2019,7)) {
		// couldn't find 2017m4,2019m7 data to download; link was broken
		
		// create blank dataset 
		clear
		set obs 1
		gen ym = `ym'
		format ym %tm 

		// save 
		tempfile _`ym'
		save `_`ym''
	}


}

******************************************

forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// assert no duplicates
duplicates tag region ym, gen(dup)
assert dup == 0
drop dup 

// order 
order region ym 
sort region ym 

// save
save "${dir_root}/texas_applications.dta", replace



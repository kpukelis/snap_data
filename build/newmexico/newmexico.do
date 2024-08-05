// newmexico.do 
// Kelsey Pukelis

local ym_start 					= ym(2013,1) 
local ym_end 	 				= ym(2024,4)


// This section to get adults and children
local ym_start_apps 			= ym(2019,1) // could get data earlier
local ym_end_apps 				= ym(2024,4)

local ym_start_apps_plus		= ym(2013,1)
local ym_end_apps_plus			= ym(2024,4) 


// early data: 2014m2-2017m3, hand entered. Rest of the data format starts 2017m4
// local ym_start_race 			= ym(2014,2) 
local ym_start_race 			= ym(2017,4) 
local ym_end_race 				= ym(2024,4)

**************************************************************************
/*
//////////////
// APP DATA //
//////////////

forvalues ym = `ym_start_apps'(1)`ym_end_apps' {

	// display ym 
	display in red "`ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, gen(monthname) 
	tostring month, gen(monthname_var) 
	replace monthname = "January" if monthname == "1"
	replace monthname = "February" if monthname == "2"
	replace monthname = "March" if monthname == "3"
	replace monthname = "April" if monthname == "4"
	replace monthname = "May" if monthname == "5"
	replace monthname = "June" if monthname == "6"
	replace monthname = "July" if monthname == "7"
	replace monthname = "August" if monthname == "8"
	replace monthname = "September" if monthname == "9"
	replace monthname = "October" if monthname == "10"
	replace monthname = "November" if monthname == "11"
	replace monthname = "December" if monthname == "12"
	local month = month
	display in red "`month'"
	local monthname = monthname
	display in red "`monthname'"
	local monthname_var = monthname_var
	display in red "`monthname_var'"
	local year = year
	display in red "`year'"

	// load data 
	import excel "${dir_root}/data/state_data/newmexico/excel/`year'/MSR_`monthname'_`year'-3.xlsx", allstring case(lower) firstrow clear 

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// keep relevant cells 
	drop if strpos(v1,"SNAP, TANF and GA-Unrelated Child Program interview s are w aived. Recertification periods are automatically extended for households w ith an Interim Review  due in March and April for")
	drop if strpos(v1,"Note: December 2020 expenditures include the LIHEAP $300 supplement payments that were tied to prior months since May 2020. The additional expenditures are reflected in the total cases and recipients reported.")
	drop if strpos(v1,"The March 2021 SNAP expenditures include COVID-19 additional Emergency Allotment")
	drop if strpos(v1,"SNAP, TANF and GA-Unrelated Child Program interview")
	drop if strpos(v1,"Medicaid Caseload count unavailable for 08.2022")
	drop if strpos(v1,"expected expenditures during those months due to COVID-19 extensions")
	drop if strpos(v7,"The number of SNAP cases during June, July, August, September, October, and November may not align with")
	drop if strpos(v7,"The number of SNAP cases during June, July, August, September, October, and November may not align")

	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	assert `r(N)' == 25
	keep if _n <= 12
	describe, varlist 
	assert `r(k)' == 12
	keep v7 v10
	drop in 1
	drop in 1
	drop in 1
	describe, varlist 
	assert `r(k)' == 2
	rename v7 variable  
	rename v10 value 
	
	// clean up variable name 
	replace variable = trim(variable)
	replace variable = strlower(variable)
	replace variable = ustrregexra(variable," ","")
	replace variable = ustrregexra(variable,"4","")
	replace variable = ustrregexra(variable,"5","")
	replace variable = ustrregexra(variable,"6","")
	replace variable = ustrregexra(variable,"7","")
	replace variable = ustrregexra(variable,"/","per")
	assert inlist(variable,"expenditures","cases","expenditurespercase","recipients","adults","children","recipientspercase","casesprocessed","approvals")

	// destring
	destring value, replace
	confirm numeric variable value 

	// reshape
	gen id = 1
	rename value _
	reshape wide _, i(id) j(variable) string
	drop id 

	// rename some vars to be consistent 
	rename _expenditures issuance
	rename _cases households
	rename _expenditurespercase avg_issuance_households
	rename _recipients individuals
	rename _adults adults
	rename _children children
	rename _recipientspercase avg_issuance_individuals
	rename _casesprocessed apps_received
	rename _approvals apps_approved

	// ym 
	gen ym = `ym'
	format ym %tm 
	order ym 

	// county 
	gen county = "total"

	// order 
	order county ym 
	
	// save 
	tempfile _`ym'
	save `_`ym''
	
}

// append 
forvalues ym = `ym_start_apps'(1)`ym_end_apps' {
	if `ym' == `ym_start_apps' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// fix countyname to be uniform with other files
replace county = ustrregexra(county,"n ","north ")
replace county = ustrregexra(county,"sanorth ","san ") // undo 
replace county = ustrregexra(county,"s ","south ")
replace county = ustrregexra(county,"losouth ","los ") // undo
replace county = ustrregexra(county,"ne ","northeast ")
replace county = ustrregexra(county,"nw ","northwest ")
replace county = ustrregexra(county,"se ","southeast ")
replace county = ustrregexra(county,"sw ","southwest ")
replace county = "eddy artesia" if county == "eddy/artesia"

// save 
tempfile newmexico_apps
save `newmexico_apps'
save "${dir_root}/data/state_data/newmexico/newmexico_apps.dta", replace

*/ 
********************************************************************************************************************
********************************************************************************************************************
********************************************************************************************************************
********************************************************************************************************************
********************************************************************************************************************
********************************************************************************************************************
/*
///////////////
// RACE DATA //
///////////////

// early data: 2014m2-2017m3

// load data 
import excel "${dir_root}/data/state_data/newmexico/excel_race/newmexico_race_early.xlsx", firstrow clear 

// ym 
gen ym = ym(year,month)
format ym %tm 
drop year
drop month 
order ym 

// drop rows that don't have data 
assert missing(gender_female) & missing(gender_male) if inrange(ym,ym(2014,4),ym(2014,6))
drop if inrange(ym,ym(2014,4),ym(2014,6))

// county 
gen county = "total"

// order and sort 
order county ym 
sort county ym 

// save 
tempfile newmexico_race_early
save `newmexico_race_early'

***************************************************

// later data: 2017m4 onwards 
forvalues ym = `ym_start_race'(1)`ym_end_race' {

	// display ym 
	display in red "`ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, gen(monthname) 
	tostring month, gen(monthname_var) 
	if inrange(`ym',ym(2017,4),ym(2099,12)) {
		replace monthname = "January" if monthname == "1"
		replace monthname = "February" if monthname == "2"
		replace monthname = "March" if monthname == "3"
		replace monthname = "April" if monthname == "4"
		replace monthname = "May" if monthname == "5"
		replace monthname = "June" if monthname == "6"
		replace monthname = "July" if monthname == "7"
		replace monthname = "August" if monthname == "8"
		replace monthname = "September" if monthname == "9"
		replace monthname = "October" if monthname == "10"
		replace monthname = "November" if monthname == "11"
		replace monthname = "December" if monthname == "12"
	}
	else if inrange(`ym',ym(2013,1),ym(2017,3)) {
		replace monthname = "0" + monthname if inrange(month,1,9)
	}
	else {
		stop 
	}
	local month = month
	display in red "`month'"
	local monthname = monthname
	display in red "`monthname'"
	local monthname_var = monthname_var
	display in red "`monthname_var'"
	local year = year
	display in red "`year'"

	// load data 
	import excel "${dir_root}/data/state_data/newmexico/excel_race/`year'/MSR_`monthname'_`year'.xlsx", allstring case(lower) firstrow clear 

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// keep relevant cells 
	drop if strpos(v1,"Medicaid demographic data can be found here:")
	dropmiss, force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	assert inlist(`r(k)',6,7)
	assert inlist(`r(N)',31,32)
	if `r(N)' == 31 {
		keep if _n >= 16	
	}
	else if `r(N)' == 32 {
		keep if _n >= 17
	}
	drop v3
	drop v4 
	drop v5 
	drop v6
	drop if strpos(v1,"Demographic Profile")
	drop if strpos(v1,"Gender of Recipients")
	drop if strpos(v1,"Ethnicity 10")
	drop if strpos(v1,"Race 10")
	drop if strpos(v1,"Ethnicity")
	drop if strpos(v1,"Race") & !strpos(v1,"More than One")
	drop if v1 == "5"
	drop in 1
	dropmiss, force 
	dropmiss, force obs 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	capture drop v3 
	dropmiss, force 
	dropmiss, force obs 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	assert `r(k)' == 2
	assert `r(N)' == 11
	rename v1 variable 
	rename v2 value 
	replace variable = ustrregexra(variable," ","")
	replace variable = ustrregexra(variable,"-","")
	replace variable = ustrregexra(variable,"/","")
	replace variable = strlower(variable)
	replace variable = substr(variable,1,25)
	*replace variable = "_" + variable
	destring value, replace
	confirm numeric variable value
	rename value _
	gen id = 1
	reshape wide _, i(id) j(variable) string 
	drop id 
	rename _africanamericanorblack 			race_africanamericanorblack
	rename _asian 							race_asian
	rename _female 							gender_female
	rename _hispanic 						ethnicity_hispanic
	rename _male 							gender_male
	rename _morethanonerace 				race_morethanonerace
	rename _nativeamericanoralaskanna	 	race_nativeamericanoralaskanna
	rename _nativehawaiianorpacificis		race_nativehawaiianorpacificis
	rename _nonhispanic 					ethnicity_nonhispanic
	rename _unknownnotdeclared 				race_unknownnotdeclared
	rename _white 							race_white

	// ym 
	gen ym = `ym'
	format ym %tm 
	order ym 

	// county 
	gen county = "total"

	// order 
	order county ym gender_* ethnicity_* race_*
	
	// save 
	tempfile _`ym'
	save `_`ym''
	
}

// append 
forvalues ym = `ym_start_race'(1)`ym_end_race' {
	if `ym' == `ym_start_race' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}
append using `newmexico_race_early'

// fix countyname to be uniform with other files
replace county = ustrregexra(county,"n ","north ")
replace county = ustrregexra(county,"sanorth ","san ") // undo 
replace county = ustrregexra(county,"s ","south ")
replace county = ustrregexra(county,"losouth ","los ") // undo
replace county = ustrregexra(county,"ne ","northeast ")
replace county = ustrregexra(county,"nw ","northwest ")
replace county = ustrregexra(county,"se ","southeast ")
replace county = ustrregexra(county,"sw ","southwest ")
replace county = "eddy artesia" if county == "eddy/artesia"

// order and sort 
order county ym gender_* ethnicity_* race_*
sort county ym 

// save 
tempfile newmexico_race
save `newmexico_race'
save "${dir_root}/data/state_data/newmexico/newmexico_race.dta", replace
*/


******************************************************************************************************************
******************************************************************************************************************
******************************************************************************************************************
******************************************************************************************************************
******************************************************************************************************************
/*
////////////////////
// APPS_PLUS DATA // 
////////////////////

*local ym = ym(2017,9)
forvalues ym = `ym_start_apps_plus'(1)`ym_end_apps_plus' {
if !inrange(`ym',ym(2013,7),ym(2013,12)) & !inlist(`ym',ym(2014,1)) & !inrange(`ym',ym(2014,4),ym(2014,6)) {
 
	// display ym 
	display in red "`ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, gen(monthname) 
	replace monthname = "0" + monthname if strlen(monthname) == 1
	tostring month, gen(monthname_var) 
	if inrange(`ym',ym(2018,1),ym(2099,12)) {
		replace monthname = "January" if monthname == "01" | monthname == "1"
		replace monthname = "February" if monthname == "02" | monthname == "2"
		replace monthname = "March" if monthname == "03" | monthname == "3"
		replace monthname = "April" if monthname == "04" | monthname == "4"
		replace monthname = "May" if monthname == "05" | monthname == "5"
		replace monthname = "June" if monthname == "06" | monthname == "6"
		replace monthname = "July" if monthname == "07" | monthname == "7"
		replace monthname = "August" if monthname == "08" | monthname == "8"
		replace monthname = "September" if monthname == "09" | monthname == "9"
		replace monthname = "October" if monthname == "10"
		replace monthname = "November" if monthname == "11"
		replace monthname = "December" if monthname == "12"
	}
	else {

	}
	local month = month
	display in red "`month'"
	local monthname = monthname
	display in red "`monthname'"
	local monthname_var = monthname_var
	display in red "`monthname_var'"
	local year = year
	display in red "`year'"


	// load data 
	if inrange(`ym',ym(2018,1),ym(2099,12)) {
		import excel "${dir_root}/data/state_data/newmexico/excel_apps/`year'/MSR_`monthname'_`year'_apps.xlsx", allstring case(lower) firstrow clear 
	}
	else {
		import excel "${dir_root}/data/state_data/newmexico/excel_apps/`year'/MSR_`monthname'_`year'_apps.xlsx", allstring case(lower) firstrow clear 
	}

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// number of pages
	if inrange(`ym',ym(2017,11),ym(2024,4)) {
		local num_pages = 5
	}
	else if inrange(`ym',ym(2013,1),ym(2017,3)) {
		local num_pages = 1
	}
	else if inrange(`ym',ym(2017,4),ym(2017,7)) {
		local num_pages = 2
	}
	else if inlist(`ym',ym(2017,8)) {
		local num_pages = 3
	}
	else if inrange(`ym',ym(2017,9),ym(2017,10)) {
		local num_pages = 4
	}
	else {
		stop 
	}

	// one page at a time 
	forvalues p = 1(1)`num_pages' {
*	local p = 5

		// preserve 
		preserve

		// display 
		display in red "page: `p'"

		// keep the right rows
		gen obsnum = _n
		if inrange(`ym',ym(2017,11),ym(2024,4))  {
			noisily sum obsnum if (strpos(v1,"Statewide") & strpos(v1,"Total")), detail	
			assert `r(N)' == `num_pages' 
			if `p' == 1 {
				local first_obsnum = 1
				local last_obsnum = `r(min)'
			}
			else if `p' == 2 {
				local first_obsnum = `r(min)' + 1
				local last_obsnum = `r(p25)'
			}
			else if `p' == 3 {
				local first_obsnum = `r(p25)' + 1
				local last_obsnum = `r(p50)'
			}
			else if `p' == 4 {
				local first_obsnum = `r(p50)' + 1
				local last_obsnum = `r(p75)'	
			}
			else if `p' == 5 {			
				local first_obsnum = `r(p75)' + 1
				local last_obsnum = `r(max)'
			}
		}
		else if inrange(`ym',ym(2013,1),ym(2017,3)) {
			noisily sum obsnum if strpos(v1,"SNAP Applications") | strpos(v3,"Roosevelt") //| strpos(v10,"TOTAL")
			assert `r(N)' == `num_pages'
			if `p' == 1 {
				local first_obsnum = 1
				local last_obsnum = `r(min)'
			}
		}
		else if inrange(`ym',ym(2017,4),ym(2017,7)) {
			noisily sum obsnum if strpos(v1,"Total"), detail 
			assert `r(N)' == `num_pages'
			if `p' == 1 {
				local first_obsnum = 1
				local last_obsnum = `r(min)'
			}
			else if `p' == 2 {
				local first_obsnum = `r(min)' + 1
				local last_obsnum = `r(max)'
			}
		}
		else if inrange(`ym',ym(2017,8),ym(2017,8)) {
			noisily sum obsnum if strpos(v1,"Total"), detail 
			assert `r(N)' == `num_pages'
			if `p' == 1 {
				local first_obsnum = 1
				local last_obsnum = `r(min)'
			}
			else if `p' == 2 {
				local first_obsnum = `r(min)' + 1
				local last_obsnum = `r(p50)'
			}
			else if `p' == 3 {
				local first_obsnum = `r(p50)' + 1
				local last_obsnum = `r(max)'
			}
		}
		else if inrange(`ym',ym(2017,9),ym(2017,10)) {
			noisily sum obsnum if strpos(v1,"Total"), detail 
			assert `r(N)' == `num_pages'
			if `p' == 1 {
				local first_obsnum = 1
				local last_obsnum = `r(min)'
			}
			else if `p' == 2 {
				local first_obsnum = `r(min)' + 1
				local last_obsnum = 75 // manual
			}
			else if `p' == 3 {
				local first_obsnum = 75 + 1 // manual
				local last_obsnum = 110 // manual
			}
			else if `p' == 4 {
				local first_obsnum = 110 + 1 // manual
				local last_obsnum = `r(max)'
			}

		}

		else {
			stop
		}
		keep if inrange(obsnum,`first_obsnum',`last_obsnum')
		drop obsnum

		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
 
		// drop bad obs 
		drop if strpos(v1,"SNAP Initial Disposition Rates by Field Office")
		drop if strpos(v1,"SNAP Expedite Timeliness by Field Office")
		drop if strpos(v1,"SNAP Renewals Processed by Field Office") | (strpos(v1,"SNAP Renew") & strpos(v1,"als Processed by Field Office")) 
		drop if strpos(v1,"SNAP Renewal Disposition Rates by Field Office") | (strpos(v1,"SNAP Renew") & strpos(v1,"al Disposition Rates by Field Office"))
		drop if strpos(v1,"Note: Renewal dispositions based on COVID-19 extensions for periodic reviews are not included")
		drop if strpos(v1,"CAP cases are reflected in the appro")
		drop if strpos(v1,"priate administrative office.")
		drop if strpos(v1,"SNAP Applications")
		drop if strpos(v1,"SNAP Initial Applications by Field Office")

		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber

		// make firstrow varnames 
		foreach var of varlist * {
			replace `var' = strlower(`var')
			replace `var' = subinstr(`var', "`=char(9)'", " ", .) if _n == 1
			replace `var' = subinstr(`var', "`=char(10)'", " ", .) if _n == 1
			replace `var' = subinstr(`var', "`=char(13)'", " ", .) if _n == 1
			replace `var' = subinstr(`var', "`=char(14)'", " ", .) if _n == 1
			replace `var' = ustrregexra(`var',"\-","") if _n == 1
			replace `var' = ustrregexra(`var',"\(","") if _n == 1
			replace `var' = ustrregexra(`var',"\)","") if _n == 1
			replace `var' = ustrregexra(`var',"\#","num") if _n == 1
			replace `var' = ustrregexra(`var',"/","") if _n == 1
			replace `var' = ustrregexra(`var'," ","") if _n == 1
			if inrange(`ym',ym(2013,1),ym(2017,3)) {
				describe, varlist 
				assert `r(k)' == 12 | `r(k)' == 10 
				if `r(k)' == 12	{
					if inlist("`var'","v1","v2","v3","v4","v5","v6") {
						replace `var' = `var' + "1" if _n == 1 	
					}
					if inlist("`var'","v7","v8","v9","v10","v11","v12") {
						replace `var' = `var' + "2" if _n == 1 	
					}
				}
				else if `r(k)' == 10 {
					if inlist("`var'","v1","v2","v3","v4","v5") {
						replace `var' = `var' + "1" if _n == 1 	
					}
					if inlist("`var'","v6","v7","v8","v9","v10") {
						replace `var' = `var' + "2" if _n == 1 	
					}
				}

			}
			replace `var' = substr(`var',1,32) if _n == 1
			label variable `var' "`=`var'[1]'"
			rename `var' `=`var'[1]'
		}
		drop in 1

		// reshape 
		if inrange(`ym',ym(2013,1),ym(2017,3)) {
			gen _id = _n
			reshape long officenum office approved denied withdrawn total, i(_id) j(temp_num)
			drop temp_num 
			drop _id
			sort officenum
			drop officenum 
		}

		// rename vars 
		if `p' == 1 {
			describe, varlist 
			assert `r(k)' == 5
			rename office 					county 
			rename approved 				apps_approved
			rename denied 					apps_denied
			rename withdrawn 				apps_withdrawn
			cap rename totalcasesprocessed 	apps_received
			cap rename total 				apps_received

		}
		else if `p' == 2 & !inrange(`ym',ym(2017,4),ym(2017,7)) {
			describe, varlist 
			assert `r(k)' == 5
			rename office 					county 
			rename approvalrate 			apps_approved_rate
			rename denialrate				apps_denied_rate
			rename needbaseddenialrate		apps_denied_needbased_rate
			rename proceduraldenialrate		apps_denied_procedural_rate
		}
		else if `p' == 3 | (`p' == 2 & inrange(`ym',ym(2017,4),ym(2017,7))) {
			describe, varlist 
			assert `r(k)' == 5
			rename office 					county 
			rename totalexpeditedapprovals	apps_expedited
			rename numtimely				apps_expedited_timely
			rename numuntimely 				apps_expedited_untimely
			rename percentagetimely			apps_expedited_timely_perc
		}
		else if `p' == 4 & !inlist(`ym',ym(2017,9),ym(2017,10),ym(2022,11)) {
			describe, varlist 
			assert `r(k)' == 5
			rename office 					county
			rename approvals 				recert_approved
			rename closures 				recert_denied
			rename needbasedclosures		recert_denied_needbased
			rename proceduralclosures 		recert_denied_procedural
		}
		else if `p' == 5 | (`p' == 4 & inlist(`ym',ym(2017,9),ym(2017,10),ym(2022,11))) {
			describe, varlist 
			assert `r(k)' == 5
			rename office 					county
			rename approvalrate 			recert_approved_rate
			capture rename closurerate 				recert_denied_rate
			capture rename denialrate 				recert_denied_rate // inlist(`ym',ym(2017,9),ym(2017,10))
			capture rename needbasedclosurerate 	recert_denied_needbased_rate
			capture rename needbaseddenialrate 		recert_denied_needbased_rate // inlist(`ym',ym(2017,9),ym(2017,10))
			capture rename proceduralclosurerate	recert_denied_procedural_rate		
			capture rename proceduraldenialrate		recert_denied_procedural_rate // inlist(`ym',ym(2017,9),ym(2017,10))	 	
		}
		else {
			stop 
		}

		// clean up county 
		replace county = strlower(county)
		replace county = ustrregexra(county,"county isd","")
		replace county = ustrregexra(county," isd","")
		replace county = trim(county)
		replace county = stritrim(county)
		replace county = "total" if county == "statewide total"
			// fix countyname to be uniform with other files
			replace county = ustrregexra(county,"n ","north ")
			replace county = ustrregexra(county,"sanorth ","san ") // undo 
			replace county = ustrregexra(county,"s ","south ")
			replace county = ustrregexra(county,"losouth ","los ") // undo
			replace county = ustrregexra(county,"ne ","northeast ")
			replace county = ustrregexra(county,"nw ","northwest ")
			replace county = ustrregexra(county,"se ","southeast ")
			replace county = ustrregexra(county,"sw ","southwest ")
			replace county = "eddy artesia" if county == "eddy/artesia"

		// destring
		if `p' == 1 {
			local destring_vars apps_approved apps_denied apps_withdrawn apps_received
		}
		else if `p' == 2 & !inrange(`ym',ym(2017,4),ym(2017,7)) {
			local destring_vars apps_approved_rate apps_denied_rate apps_denied_needbased_rate apps_denied_procedural_rate
		}
		else if `p' == 3 | (`p' == 2 & inrange(`ym',ym(2017,4),ym(2017,7))) {
			local destring_vars apps_expedited apps_expedited_timely apps_expedited_untimely apps_expedited_timely_perc
		}
		else if `p' == 4 & !inlist(`ym',ym(2017,9),ym(2017,10),ym(2022,11)) {
			local destring_vars recert_approved recert_denied recert_denied_needbased recert_denied_procedural
		}
		else if `p' == 5 | (`p' == 4 & inlist(`ym',ym(2017,9),ym(2017,10),ym(2022,11))) {
			local destring_vars recert_approved_rate recert_denied_rate recert_denied_needbased_rate recert_denied_procedural_rate
		}
		else {
			stop 
		}
		foreach var in `destring_vars' {
			replace `var' = "" if strpos(`var',"N/A") | strpos(`var',"n/a")
			destring `var', replace ignore("-")
			confirm numeric variable `var'
		}

		// ym 
		gen ym = `ym'
		format ym %tm 

		// order and sort 
		order county ym `destring_vars'
		sort county ym 

		// save 
		tempfile _`ym'_page`p'
		save `_`ym'_page`p''

		// restore 
		restore
	}

	// merge all pages 
	forvalues p = 1(1)`num_pages' {
		if `p' == 1 {
			use `_`ym'_page`p'', clear
		}
		else {
			merge 1:1 county ym using `_`ym'_page`p''
			assert inlist(_m,1,3)
			drop _m 
		}
	}
	tempfile _`ym'
	save `_`ym''

}
}


// append 
forvalues ym = `ym_start_apps_plus'(1)`ym_end_apps_plus' {
if !inrange(`ym',ym(2013,7),ym(2013,12)) & !inlist(`ym',ym(2014,1)) & !inrange(`ym',ym(2014,4),ym(2014,6)) {
	if `ym' == `ym_start_apps_plus' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}
}

// prep: collapse counties with multiple offices into a single county  
rename county county_og 
gen county = county_og
	// bernalillo = northeast bernalillo + northwest bernalillo
	replace county = "bernalillo" if strpos(county,"bernalillo") & (strpos(county,"northeast") | strpos(county,"northwest") | strpos(county,"southeast") | strpos(county,"southwest")) 
	// valencia = valencia north + valencia south 	
	replace county = "valencia" if strpos(county,"valencia") & (strpos(county,"north") | strpos(county,"south"))
	// dona ana = south dona ana + east dona ana + west dona ana 
	replace county = "dona ana" if strpos(county,"dona ana") & (strpos(county,"east") | strpos(county,"south") | strpos(county,"west")) 
	// eddy = eddy + eddy artesia + eddy carlsbad
	replace county = "eddy" if county == "eddy artesia" | county == "eddy carlsbad"

**KP: okay at this point
 
// drop vars which I could always just recalculate 
// this vars would also be hard to work with the collapse 
*drop recert_approved_rate
*drop recert_denied_rate
*drop recert_denied_needbased_rate
*drop recert_denied_procedural_rate
drop apps_expedited_timely_perc
*drop apps_approved_rate
*drop apps_denied_rate

// calculate total recerts 
egen recert_calc = rowtotal(recert_approved recert_denied)

// generate counts where there are rates 
// this is to make the data collapse-friendly
foreach type in approved denied denied_needbased denied_procedural {
	gen apps_`type'_calc = apps_received * apps_`type'_rate
	drop apps_`type'_rate
	gen recert_`type'_calc = recert_calc * recert_`type'_rate 
	drop recert_`type'_rate
}

// for variables where there is a recorded version, make sure they are "close", for validity (< X% error rate)
foreach type in approved denied {
	// 
	gen perc_error_apps_`type'_rate = abs(apps_`type'_calc - apps_`type') / apps_`type' * 100
	sum perc_error_apps_`type'_rate, detail 
	*order *apps_`type'*
	*assert perc_error_apps_`type'_rate < 5 if !missing(apps_approved_rate)
	drop perc_error_apps_`type'_rate
	// 
	gen perc_error_recert_`type'_rate = abs(recert_`type'_calc - recert_`type') / recert_`type' * 100
	sum perc_error_recert_`type'_rate, detail 
	*order *recert_`type'*
	*assert perc_error_recert_`type'_rate < 5 if !missing(recert_approved_rate)
	drop perc_error_recert_`type'_rate
	
}

// collapse counties with multiple offices into a single county  
drop county_og
#delimit ;
collapse (sum) 
	apps_approved apps_denied apps_withdrawn apps_received 
	apps_expedited apps_expedited_timely apps_expedited_untimely
	recert_approved recert_denied recert_denied_needbased recert_denied_procedural
	apps_approved_calc apps_denied_calc
	apps_denied_needbased_calc apps_denied_procedural_calc
	recert_approved_calc recert_denied_calc
	recert_denied_needbased_calc recert_denied_procedural_calc
	(count)
	n_apps_approved = apps_approved
	n_apps_denied = apps_denied
	n_apps_withdrawn = apps_withdrawn
	n_apps_received = apps_received
	n_apps_expedited = apps_expedited
	n_apps_expedited_timely = apps_expedited_timely
	n_apps_expedited_untimely = apps_expedited_untimely
	n_recert_approved = recert_approved
	n_recert_denied = recert_denied
	n_recert_denied_needbased = recert_denied_needbased
	n_recert_denied_procedural = recert_denied_procedural
	n_apps_approved_calc = apps_approved_calc
	n_apps_denied_calc = apps_denied_calc
	n_apps_denied_needbased_calc = apps_denied_needbased_calc
	n_apps_denied_procedural_calc = apps_denied_procedural_calc
	n_recert_approved_calc = recert_approved_calc
	n_recert_denied_calc = recert_denied_calc
	n_recert_denied_needbased_calc = recert_denied_needbased_calc
	n_recert_denied_procedural_calc = recert_denied_procedural_calc
	, by(county ym)
;
#delimit cr 

// replace zeros with missings 
#delimit ;
foreach var in apps_approved apps_denied apps_withdrawn apps_received 
	apps_expedited apps_expedited_timely apps_expedited_untimely
	recert_approved recert_denied recert_denied_needbased recert_denied_procedural
	apps_approved_calc apps_denied_calc
	apps_denied_needbased_calc apps_denied_procedural_cal
	recert_approved_calc recert_denied_calc
	recert_denied_needbased_calc recert_denied_procedural_cal
	{ ;
		replace `var' = . if n_`var' == 0 ;
		drop n_`var' ;
	} ;
#delimit cr 

// assert denied sums are close 
// original version 
gen perc_error_apps_denied 		= abs(apps_denied - apps_denied_needbased_calc - apps_denied_procedural_calc) / apps_denied * 100
sum perc_error_apps_denied, detail
drop perc_error_apps_denied
// calculated version
gen perc_error_apps_denied_calc = abs(apps_denied_calc - apps_denied_needbased_calc - apps_denied_procedural_calc) / apps_denied_calc * 100
sum perc_error_apps_denied_calc, detail
drop perc_error_apps_denied_calc
 
// order and sort 
order county ym 
sort county ym 

// save 
tempfile newmexico_apps_plus
save `newmexico_apps_plus'
save "${dir_root}/data/state_data/newmexico/newmexico_apps_plus.dta", replace
check 
*/
**************************************************************************************************************
**************************************************************************************************************
**************************************************************************************************************
**************************************************************************************************************
/*
/////////////////////
// ENROLLMENT DATA //
/////////////////////

forvalues ym = `ym_start'(1)`ym_end' {
if !inrange(`ym',ym(2013,7),ym(2014,1)) & !inrange(`ym',ym(2014,4),ym(2014,6)) {

	// display ym 
	display in red "`ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, gen(monthname) 
	tostring month, gen(monthname_var) 
	if inrange(`ym',ym(2013,1),ym(2017,4)) {
		replace monthname = "0" + monthname if strlen(monthname) == 1
	}
	else if inrange(`ym',ym(2017,5),ym(2017,12)) | inrange(`ym',ym(2018,7),ym(2018,12)) | (`ym' >= ym(2019,1)) {
		replace monthname = "January" if monthname == "1"
		replace monthname = "February" if monthname == "2"
		replace monthname = "March" if monthname == "3"
		replace monthname = "April" if monthname == "4"
		replace monthname = "May" if monthname == "5"
		replace monthname = "June" if monthname == "6"
		replace monthname = "July" if monthname == "7"
		replace monthname = "August" if monthname == "8"
		replace monthname = "September" if monthname == "9"
		replace monthname = "October" if monthname == "10"
		replace monthname = "November" if monthname == "11"
		replace monthname = "December" if monthname == "12"
	}
	else if inrange(`ym',ym(2018,1),ym(2018,6)) {
		replace monthname = "Jan" if monthname == "1"
		replace monthname = "Feb" if monthname == "2"
		replace monthname = "Mar" if monthname == "3"
		replace monthname = "Apr" if monthname == "4"
		replace monthname = "May" if monthname == "5"
		replace monthname = "Jun" if monthname == "6"
		replace monthname = "Jul" if monthname == "7"
		replace monthname = "Aug" if monthname == "8"
		replace monthname = "Sep" if monthname == "9"
		replace monthname = "Oct" if monthname == "10"
		replace monthname = "Nov" if monthname == "11"
		replace monthname = "Dec" if monthname == "12"
	}
	replace monthname_var = "jan" if monthname_var == "1"
	replace monthname_var = "feb" if monthname_var == "2"
	replace monthname_var = "mar" if monthname_var == "3"
	replace monthname_var = "apr" if monthname_var == "4"
	replace monthname_var = "may" if monthname_var == "5"
	replace monthname_var = "jun" if monthname_var == "6"
	replace monthname_var = "jul" if monthname_var == "7"
	replace monthname_var = "aug" if monthname_var == "8"
	replace monthname_var = "sep" if monthname_var == "9"
	replace monthname_var = "oct" if monthname_var == "10"
	replace monthname_var = "nov" if monthname_var == "11"
	replace monthname_var = "dec" if monthname_var == "12"
	local month = month
	display in red "`month'"
	local monthname = monthname
	display in red "`monthname'"
	local monthname_var = monthname_var
	display in red "`monthname_var'"
	local year = year
	display in red "`year'"

	// load data 
	if inrange(`ym',ym(2013,1),ym(2014,12)) {
		import delimited "${dir_root}/data/state_data/newmexico/excel_og/`year'/tabula-MSR_`monthname'_`year'_data.pdf_short.csv", stringcols(_all) case(lower) varnames(1) clear 
	}
	else if inrange(`ym',ym(2015,1),ym(2017,3)) {
		import delimited "${dir_root}/data/state_data/newmexico/excel_og/`year'/tabula-MSR_`monthname'_`year'.pdf_short.csv", stringcols(_all) case(lower) varnames(1) clear 
	}
	else if inrange(`ym',ym(2017,4),ym(2017,4)) | (`ym' >= ym(2019,1)) {
		import excel "${dir_root}/data/state_data/newmexico/excel_og/`year'/MSR_`monthname'_`year'.pdf_short.xlsx", allstring case(lower) firstrow clear 
	}
	else if inrange(`ym',ym(2017,5),ym(2017,12)) {
		import excel "${dir_root}/data/state_data/newmexico/excel_og/`year'/`monthname'`year'_MSR.pdf_short.xlsx", allstring case(lower) firstrow clear 
	}
	else if inrange(`ym',ym(2018,7),ym(2018,12)) {
		import excel "${dir_root}/data/state_data/newmexico/excel_og/`year'/MSR_`monthname'`year'_Final.pdf_short.xlsx", allstring case(lower) firstrow clear 
	}
	else if inrange(`ym',ym(2018,1),ym(2018,6)) {
		import excel "${dir_root}/data/state_data/newmexico/excel_og/`year'/`monthname'`year'_MSR.pdf_short.xlsx", allstring case(lower) firstrow clear 
	}

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// drop top vars 
	if inrange(`ym',ym(2013,1),ym(2014,1)) {
		while !strpos(v1,"County") {
			drop in 1
		}
	}
	else if `ym' >= ym(2014,2) {
		while !strpos(v1,"Office") & !strpos(v1,"office") {
			drop in 1
		}
	}

	// rename variables
	if inrange(`ym',ym(2013,1),ym(2014,1)) {
		rename v1 county 
	}
	else if `ym' >= ym(2014,2) {
		rename v1 office 
	}
	rename v2 households_yearbefore
	rename v3 households_monthbefore
	rename v4 households_now 
	rename v5 households_percchangeyear
	rename v6 households_percchangemonth
	drop in 1

	// drop unnecessary variables 
	drop households_percchangeyear households_percchangemonth
	if inrange(`ym',ym(2016,1),ym(2016,4)) | inlist(`ym',ym(2014,7),ym(2016,7)) {
		capture drop v7
		capture drop v8
		capture drop v9
		capture drop v10
		capture drop v11
	}

	// assert number of variables 
	describe, varlist 
	assert r(k) == 4

	// cleaning involving the county var
	capture confirm variable county
	if !_rc {
		// county lowercase 
		replace county = strlower(county)
		*replace county = "statewide total" if county == "total"
		replace county = "total" if county == "statewide total"
		replace county = "centralized units" if county == "centralized units^"
		replace county = "mckinley" if county == "mckinley*"

		// reshape long 
		reshape long households, i(county) j(_time) string 
	}

	// cleaning involving the office var
	capture confirm variable office
	if !_rc {
		// drop bad observations
		drop if office == "10"
		drop if office == "12"
		drop if office == "14"
		drop if office == "16"
		drop if office == "18"
		drop if office == "19"
		drop if office == "20"
		drop if office == "21"
		drop if office == "22"
		drop if office == "23"
		drop if office == "24"
		drop if office == "25"
		drop if office == "26"

		// office lowercase 
		replace office = strlower(office)
		*replace office = "statewide total" if office == "total" | office == "1.0% total"
		replace office = "total" if office == "1.0% total" | office == "statewide total"

		// clean up office 
		replace office = "centralized units" if office == "centralized units^"
		replace office = "mckinley" if office == "mckinley*"
		replace office = ustrregexra(office," county isd","")
		replace office = "south dona ana" if office == "south dona ana isd"

		// generate associated county 
		gen county = office 
	
		// reshape long 
		reshape long households, i(office) j(_time) string 

		// drop obs 
		drop if office == "office" & county == "office"
		drop if missing(office) & missing(county) & missing(households)

	}

	// ym 
	gen ym = .
	replace ym = `ym' + 0  if _time == "_now"
	replace ym = `ym' - 12 if _time == "_yearbefore"
	replace ym = `ym' - 1  if _time == "_monthbefore"
	format ym %tm 
	drop _time

	// source of data 
	gen source_ym = `ym'
	format source_ym %tm

	// destring 
	foreach var in households {
		replace `var' = ustrregexra(`var',",","")
		replace `var' = ustrregexra(`var',"-","")
		destring `var', replace
		confirm numeric variable `var'
	}

	// end code 
	if inrange(`ym',ym(2013,1),ym(2014,1)) {
	
		// assert shape 
		count 
		assert `r(N)' == 102
		
		// order and sort 
		order county county ym households source_ym
		sort county ym source_ym

	}
	else if inrange(`ym',ym(2014,2),ym(2017,3)) {
	
		// assert shape 
		count 
		assert `r(N)' == 111
	
		// order and sort 
		order office county ym households source_ym
		sort office ym source_ym
	
	}
	else if `ym' >= ym(2017,4) {
	
		// assert shape 
		count 
		assert `r(N)' == 108
	
		// order and sort 
		order office county ym households source_ym
		sort office ym source_ym
	
	}


	// save 
	tempfile _`ym'
	save `_`ym''
	
}
}

// append 
forvalues ym = `ym_start'(1)`ym_end' {
if !inrange(`ym',ym(2013,7),ym(2014,1)) & !inrange(`ym',ym(2014,4),ym(2014,6)) {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}
}


// replace office if only county level data 
// actually, don't do this so that it's obvious the county level data 
*replace office = county if !missing(county) & missing(office) & inrange(ym,ym(2012,1),ym(2014,1))

// DUPLICATES 

// drop if households is missing 
drop if missing(households)

// drop exact duplicates
duplicates drop county ym households if  inrange(ym,ym(2013,1),ym(2014,1)), force 
duplicates drop office ym households if !inrange(ym,ym(2013,1),ym(2014,1)), force 

// dropping duplicates, keeping observations that comes from the source ym 
// duplicates office 
bysort office ym: gen numobs = _N
assert inlist(numobs,1,2,33,34)
count if numobs == 2
assert `r(N)' == 198
drop if numobs == 2 & source_ym != ym 
count if numobs == 33
assert `r(N)' == 33
count if numobs == 34
assert `r(N)' == 408
drop numobs
bysort office ym: gen numobs_office = _N
// duplicates county 
bysort county ym: gen numobs = _N
tab numobs
drop if numobs == 2 & missing(office)
drop if numobs == 2 & !strpos(office," isd")
drop numobs
bysort county ym: gen numobs_county = _N

// assert level of the data
assert numobs_county == 1 | numobs_office == 1

// fix countyname to be uniform with other files
replace county = ustrregexra(county,"n ","north ")
replace county = ustrregexra(county,"sanorth ","san ") // undo 
replace county = ustrregexra(county,"s ","south ")
replace county = ustrregexra(county,"losouth ","los ") // undo 
replace county = ustrregexra(county,"ne ","northeast ")
replace county = ustrregexra(county,"nw ","northwest ")
replace county = ustrregexra(county,"se ","southeast ")
replace county = ustrregexra(county,"sw ","southwest ")
replace county = "eddy artesia" if county == "eddy/artesia"

// prep: collapse counties with multiple offices into a single county  
rename county county_og 
gen county = county_og
	// bernalillo = northeast bernalillo + northwest bernalillo
	replace county = "bernalillo" if strpos(county,"bernalillo") & (strpos(county,"northeast") | strpos(county,"northwest") | strpos(county,"southeast") | strpos(county,"southwest")) 
	// valencia = valencia north + valencia south 	
	replace county = "valencia" if strpos(county,"valencia") & (strpos(county,"north") | strpos(county,"south"))
	// dona ana = south dona ana + east dona ana + west dona ana 
	replace county = "dona ana" if strpos(county,"dona ana") & (strpos(county,"east") | strpos(county,"south") | strpos(county,"west")) 
	// eddy = eddy + eddy artesia + eddy carlsbad
	replace county = "eddy" if county == "eddy artesia" | county == "eddy carlsbad"

// collapse counties with multiple offices into a single county  
drop county_og
drop office 
drop numobs_office
drop numobs_county
drop source_ym
collapse (sum) households, by(county ym)

// order and sort 
order /*office*/ county ym households 
sort /*office*/ county ym 

// save
tempfile newmexico_enrollment
save `newmexico_enrollment'
save "${dir_root}/data/state_data/newmexico/newmexico_enrollment.dta", replace
check 
*/
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************


// merge 
*use `newmexico_apps_plus', clear
use "${dir_root}/data/state_data/newmexico/newmexico_apps_plus.dta", clear 
*merge 1:1 county ym using `newmexico_apps'
merge 1:1 county ym using "${dir_root}/data/state_data/newmexico/newmexico_apps.dta"
assert inlist(_m,1,3)
assert inlist(county,"total") if _m == 3
assert !inlist(county,"total") | ym < `ym_start_apps' if _m == 1
drop _m 
*merge 1:1 county ym using `newmexico_race'
merge 1:1 county ym using "${dir_root}/data/state_data/newmexico/newmexico_race.dta"
assert inlist(_m,3,1) // this may not be the case if one of these datasets is updated 
drop _m 
*merge 1:1 county ym using `newmexico_enrollment', update 
merge 1:1 county ym using "${dir_root}/data/state_data/newmexico/newmexico_enrollment.dta", update  
count if _m == 5
assert `r(N)' < 10 // limited number of conflicts is okay
drop _m 

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// drop all missing obs 
dropmiss county gender_* ethnicity_* race_* apps_* recert_* households, force obs

// save 
save "${dir_root}/data/state_data/newmexico/newmexico.dta", replace

// review county 
tab county
tab ym if inlist(county,"catron","de baca","harding","los alamos","mora")
	// 2012m1-2013m6
tab ym if inlist(county,"union")
	// 2012m1-2017m3
check
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************


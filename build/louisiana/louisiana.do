// louisiana.do 
// Kelsey Pukelis

// statewide part: 001_Fiscal Year Totals
local year_start_part1			= 1987 
local year_end_part1			= 2006
local year_start_part2			= 2007
local year_end_part2			= 2023

// cases part: 002_Cases by Parish & Region 
local year_start_cases			= 2000
local year_end_cases			= 2023
local month_1 					July
local month_2 					August
local month_3 					September
local month_4 					October
local month_5 					November
local month_6 					December
local month_7 					January
local month_8 					February
local month_9 					March
local month_10 					April
local month_11 					May
local month_12					June

// age part: 014_SNAP Recipients by Age 
local year_start_age			= 2011
local year_end_age				= 2023
local month_1 					July
local month_2 					August
local month_3 					September
local month_4 					October
local month_5 					November
local month_6 					December
local month_7 					January
local month_8 					February
local month_9 					March
local month_10 					April
local month_11 					May
local month_12					June

// apps part - state level: 007_Applications Processed by Month
local year_start_apps			= 2004 
local year_end_apps				= 2023

// cases closed: 011_Cases Closed by Reason
local year_start_closed 		= 2002 
local year_end_closed 			= 2023

// apps part - county level: 005_Applications Processed
// not done with 2008, 2009, 2010, 2011, 2012, 2014, 2015 - would need to copy and paste cells that didn't separate 
*local year_start_apps_county	= 2004 
*local year_start_apps_county	= 2008 

local year_start_apps_county 	= 2016
local year_end_apps_county		= 2023 

*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
/*
////////////////////////////////
// 011_Cases Closed by Reason //
//////////////////////////////// 

// gotothis
*local year = 2014
forvalues year = `year_start_closed'(1)`year_end_closed' {
if inlist(`year',2022,2023) {
	display in red "`year'"

	// for filenames
	local year_plus1 = `year' + 1
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

	// import - month by month
	local monthlist_2022 7 8 9 10 11 12 1 2 3 4 5 6
	local monthlist_2023 7 8 9 10 11 12 1 2 3 4 5 
	foreach m of local monthlist_`year' {

		dis in red "`m'"

		// import 
		import excel "${dir_root}/data/state_data/louisiana/excel/011_Cases Closed by Reason/fy`yearnames'_FS_Closures.xlsx", sheet("`m'") allstring clear

		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		qui describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		foreach var of varlist * {
			replace `var' = strlower(`var')	
		}
		
		// assert shape of the data 
		describe, varlist 
		assert `r(N)' <= 37
		assert `r(k)' == 3
		rename v1 closure_reason 
		rename v2 total 
		rename v3 perc
		drop in 1 

		// mark month 
		gen month = `m'

		// mark year
		local yearplus1 = `year' + 1 
		gen year = .
		replace year = `year_plus1' if inrange(month,1,6)
		replace year = `year' if inrange(month,7,12)

		// ym 
		gen ym = ym(year,month)
		format ym %tm 
		drop year 
		drop month 

		// destring
		foreach var in total perc {
			destring `var', replace ignore(",")
			confirm numeric variable `var'
		}

		// county 
		gen county = "total"

		// clean up the closure_reason variable 
		replace closure_reason = trim(closure_reason)
		
		// manual drop 
		drop if strpos(closure_reason,"percentage") & strpos(closure_reason,"reason") & strpos(closure_reason,"of total")

		// categorize the closure_reasons into groups based on how fine they are 
			// overall group: total 
			gen group_total = 0
			replace group_total = 1 if closure_reason == "state total"
			// headings group
			gen group_heading = 0
			// standardize fine categories
				// code from xwalk excel file
				gen closure_reason_og = closure_reason
				// one alternative
				replace closure_reason = `"voluntary withdrawal"' if closure_reason == `"application withdrawal"'
		
			#delimit ;
			replace group_heading = 1 
				if inlist(	closure_reason,
							"earned income total",
							"unearned income total",
							"other eligibility total",
							"procedural reasons total",
							"sanction reasons total",
							"voluntary withdrawal",
							"other reasons total"
							)
			;
			#delimit cr 
			// finest group 
			gen group_finecategory = 0
			#delimit ;
			replace group_finecategory = 1
				if 			closure_reason == `"gross inc. eligibility net exceeds limit"' |
							closure_reason == `"increase in wages or new employment"' |
							closure_reason == `"gross income ineligible"' |
							closure_reason == `"increase in contributions"' |
							closure_reason == `"increase in child support"' |
							closure_reason == `"increase in social security or ssi"' |
							closure_reason == `"increase in other federal benefits"' |
							closure_reason == `"increase in other state benefits"' |
							closure_reason == `"does not receive ssi"' |
							closure_reason == `"resources over limit"' |
							closure_reason == `"transferred resources"' |
							closure_reason == `"decrease need or expenses"' |
							closure_reason == `"unable to locate"' |
							closure_reason == `"residence requirement not met"' |
							closure_reason == `"residence out of parish"' |
							closure_reason == `"moved out of state"' |
							closure_reason == `"head of hh (payee) left home"' |
							closure_reason == `"institutionalization/incarceration"' |
							closure_reason == `"voluntary quit without good cause"' |
							closure_reason == `"no eligible child/member in the home"' |
							closure_reason == `"death of applicant/head of household"' |
							closure_reason == `"citizenship not met"' |
							closure_reason == `"change in state law or policy"' |
							closure_reason == `"expired redetermination"' |
							closure_reason == `"questionable information not provided"' |
							closure_reason == `"household member disqualified"' |
							closure_reason == `"does not purchase prepare meals separately"' |
							closure_reason == `"convicted of ipv"' |
							closure_reason == `"drug conviction"' |
							closure_reason == `"no longer in living arrangement code "a""' |
							strpos(closure_reason,`"selected regular fs because of excess shelter or medic"') |
							closure_reason == `"other (disaster closures included)"' |
							closure_reason == `"living with spouse (lacap only)"' |
							closure_reason == `"age requirement not met"' |
							closure_reason == `"included in another certification"' |
							closure_reason == `"failed/refused to provide verification"' |
							closure_reason == `"failed to timely reapply"' |
							closure_reason == `"failed to keep appointment"' |
							strpos(closure_reason,`"failed to provide complete semi-annual rpt by due dat"') |
							closure_reason == `"refused to comply with qc"' |
							closure_reason == `"refused to comply with eligibility requirement"' |
							closure_reason == `"failed to comply with lajet"' |
							closure_reason == `"originally ineligible"' | 
							//
							closure_reason == `"does not meet abawd work requirement"' |
							closure_reason == `"living with child under age 22 (lacap only)"' |
							closure_reason == `"failed to comply with lwc"' |
							closure_reason == `"other"' |
							closure_reason == `"failed to register for work - hire"' |
							//////
							closure_reason == `"failed net income test"' |
							//
							closure_reason == `"failed gross income test"' |
							closure_reason == `"individual is not receiving ssi"' |
							//
							closure_reason == `"failed resource test"' |
							closure_reason == `"failed due to resource transfer"' |
							closure_reason == `"failure due to voluntary withdrawal"' |
							closure_reason == `"failed residency requirement"' |
							closure_reason == `"individual is out of home"' |
							closure_reason == `"failed due to incarcerated applicant"' |
							closure_reason == `"no eligible children"' |
							closure_reason == `"case name deceased"' |
							closure_reason == `"failed citizenship requirement"' |
							closure_reason == `"individual does not purchase and prepare meals together"' |
							closure_reason == `"disqualified due to an ipv"' |
							closure_reason == `"individual does not meet program requirement"' |
							closure_reason == `"individual does not meet age requirement"' |
							closure_reason == `"individual is receiving benefits in another case"' |
							closure_reason == `"abawd individual failed to meet requirements to work 20 hrs/week"' |
							closure_reason == `"not a one person household ineligible for lacap"' |
							//
							closure_reason == `"failed to provide required information within specific timeframe"' |
							closure_reason == `"failure to complete redet"' |
							closure_reason == `"failed to complete interview"' |
							closure_reason == `"failure to complete sr"' |
							//
							closure_reason == `"failure due to e&t sanction"' |
							closure_reason == `"failure due to non cooperation with quality control"' |
							closure_reason == `"fail to register for work - hire"' |
							//
							closure_reason == `"client request"' |
							//
							strpos(closure_reason,`"abawd individual failed to meet requirements to work 20 hrs/w"') |
							strpos(closure_reason,`"fail to register for work ‐ hire"') |
							// 
							closure_reason == `"failed to provide complete semi‐annual rpt by due date"' |
							//
							closure_reason == `"refused to comply with pres"' |
							// 
							strpos(closure_reason,`"does not purchase prepare meals separ"') | 
 							strpos(closure_reason,`"selected regular fs because of excess s"') | 
 							strpos(closure_reason,`"failed to provide complete semi-annual"') | 
 							strpos(closure_reason,`"refused to comply with eligibility require"') |
 							strpos(closure_reason,`"no longer in living arrangement code"') |
 							//
 							strpos(closure_reason,`"refused to comply with quality control"')
							// closure_reason == `""' |
							// gotothis
			;
			#delimit cr 

		// make sure all reasons are accounted for 
		gen has_a_category = (group_total == 1 | group_heading == 1 | group_finecategory == 1)  
		list closure_reason /*obsnum*/ if has_a_category == 0
		assert has_a_category == 1
		drop has_a_category

		// standardize fine categories
		// code from xwalk excel file
		*	gen closure_reason_og = closure_reason
			// one alternative
			replace closure_reason = `"death of applicant/head of household"' if closure_reason == `"case name deceased"'
			replace closure_reason = `"convicted of ipv"' if closure_reason == `"disqualified due to an ipv"'
			replace closure_reason = `"citizenship not met"' if closure_reason == `"failed citizenship requirement"'
			replace closure_reason = `"institutionalization/incarceration"' if closure_reason == `"failed due to incarcerated applicant"'
			replace closure_reason = `"transferred resources"' if closure_reason == `"failed due to resource transfer"'
			replace closure_reason = `"gross income ineligible"' if closure_reason == `"failed gross income test"'
			replace closure_reason = `"residence requirement not met"' if closure_reason == `"failed residency requirement"'
			replace closure_reason = `"resources over limit"' if closure_reason == `"failed resource test"'
			replace closure_reason = `"failed to keep appointment"' if closure_reason == `"failed to complete interview"'
			replace closure_reason = `"failed/refused to provide verification"' if closure_reason == `"failed to provide required information within specific timeframe"'
			replace closure_reason = `"failed to timely reapply"' if closure_reason == `"failure to complete redet"'
			replace closure_reason = `"does not receive ssi"' if closure_reason == `"individual is not receiving ssi"'
			replace closure_reason = `"head of hh (payee) left home"' if closure_reason == `"individual is out of home"'
			replace closure_reason = `"included in another certification"' if closure_reason == `"individual is receiving benefits in another case"'
			replace closure_reason = `"no eligible child/member in the home"' if closure_reason == `"no eligible children"'
			replace closure_reason = `"no longer in living arrangement code "a""' if strpos(closure_reason,`"no longer in living arrangement code"')
			replace closure_reason = `"refused to comply with eligibility requirement"' if strpos(closure_reason,`"refused to comply with eligibility require"')
			replace closure_reason = `"selected regular fs because of excess shelter or medical expenses"' if strpos(closure_reason,`"selected regular fs because of excess s"')
			replace closure_reason = `"individual does not meet age requirement"' if closure_reason == `"age requirement not met"'
			replace closure_reason = `"other (disaster closures included)"' if closure_reason == `"other"'
			// two alternatives
			replace closure_reason = `"abawd individual failed to meet requirements to work 20 hrs/week"' if strpos(closure_reason,`"abawd individual failed to meet requirements to work 20 hrs/w"') | closure_reason == `"does not meet abawd work requirement"'
			replace closure_reason = `"does not purchase prepare meals separately"' if strpos(closure_reason,`"does not purchase prepare meals separ"') | closure_reason == `"individual does not purchase and prepare meals together"'
			replace closure_reason = `"failed to register for work - hire"' if strpos(closure_reason,`"fail to register for work ‐ hire"') | closure_reason == `"fail to register for work - hire"'
			replace closure_reason = `"failed to provide complete semi‐annual rpt by due date"' if strpos(closure_reason,`"failed to provide complete semi-annual"') | closure_reason == `"failure to complete sr"'
			// three alternatives
			replace closure_reason = `"refused to comply with quality control"' if strpos(closure_reason,`"refused to comply with quality control"') | closure_reason == `"refused to comply with qc"' | closure_reason == `"failure due to non cooperation with quality control"'

		// assert that all the closure_reasons are in my list 
		#delimit ;
		 list closure_reason if !(
			inlist(closure_reason,
			`"state total"') | 
			inlist(closure_reason,
			`"earned income total"',
			`"unearned income total"',
			`"other eligibility total"',
			`"procedural reasons total"',
			`"sanction reasons total"',
			`"voluntary withdrawal"',
			`"other reasons total"') |
			inlist(closure_reason,
			`"gross inc. eligibility net exceeds limit"',
			`"increase in wages or new employment"',
			`"gross income ineligible"',
			`"increase in contributions"',
			`"increase in child support"') |
			inlist(closure_reason,
			`"increase in social security or ssi"',
			`"increase in other federal benefits"',
			`"increase in other state benefits"',
			`"does not receive ssi"',
			`"resources over limit"') |
			inlist(closure_reason,
			`"transferred resources"',
			`"decrease need or expenses"',
			`"unable to locate"',
			`"residence requirement not met"',
			`"residence out of parish"') |
			inlist(closure_reason,
			`"moved out of state"',
			`"head of hh (payee) left home"',
			`"institutionalization/incarceration"',
			`"voluntary quit without good cause"',
			`"no eligible child/member in the home"') |
			inlist(closure_reason,
			`"death of applicant/head of household"',
			`"citizenship not met"',
			`"change in state law or policy"',
			`"expired redetermination"',
			`"questionable information not provided"') |
			inlist(closure_reason,
			`"household member disqualified"',
			`"does not purchase prepare meals separately"',
			`"convicted of ipv"',
			`"drug conviction"',
			`"no longer in living arrangement code "a""') |
			inlist(closure_reason,
			`"selected regular fs because of excess shelter or medical expenses"'
			`"other (disaster closures included)"',
			`"living with spouse (lacap only)"',
			`"living with child under age 22 (lacap only)"',
			`"not a one person household ineligible for lacap"') |
			inlist(closure_reason,
			`"other"',
			`"included in another certification"',
			`"failed/refused to provide verification"',
			`"failed to timely reapply"',
			`"failed to keep appointment"') |
			inlist(closure_reason,
			`"failed to provide complete semi‐annual rpt by due date"',
			`"refused to comply with quality control"',
			`"refused to comply with eligibility requirement"',
			`"failed to comply with lajet"',
			`"failed to comply with lwc"') |
			inlist(closure_reason,
			`"refused to comply with pres"',
			`"originally ineligible"',
			`"abawd individual failed to meet requirements to work 20 hrs/week"',
			`"failed to register for work - hire"',
			`"failure due to e&t sanction"') |
			inlist(closure_reason,
			`"individual does not meet program requirement"',
			`"failure due to voluntary withdrawal"',
			`"failed net income test"',
			`"client request"',
			`"individual does not meet age requirement"',
			`"other (disaster closures included)"') // )
			)
		;
		#delimit cr 

		// assert that all the closure_reasons are in my list 
		#delimit ;
		assert  
			inlist(closure_reason,
			`"state total"') | 
			inlist(closure_reason,
			`"earned income total"',
			`"unearned income total"',
			`"other eligibility total"',
			`"procedural reasons total"',
			`"sanction reasons total"',
			`"voluntary withdrawal"',
			`"other reasons total"') |
			inlist(closure_reason,
			`"gross inc. eligibility net exceeds limit"',
			`"increase in wages or new employment"',
			`"gross income ineligible"',
			`"increase in contributions"',
			`"increase in child support"') |
			inlist(closure_reason,
			`"increase in social security or ssi"',
			`"increase in other federal benefits"',
			`"increase in other state benefits"',
			`"does not receive ssi"',
			`"resources over limit"') |
			inlist(closure_reason,
			`"transferred resources"',
			`"decrease need or expenses"',
			`"unable to locate"',
			`"residence requirement not met"',
			`"residence out of parish"') |
			inlist(closure_reason,
			`"moved out of state"',
			`"head of hh (payee) left home"',
			`"institutionalization/incarceration"',
			`"voluntary quit without good cause"',
			`"no eligible child/member in the home"') |
			inlist(closure_reason,
			`"death of applicant/head of household"',
			`"citizenship not met"',
			`"change in state law or policy"',
			`"expired redetermination"',
			`"questionable information not provided"') |
			inlist(closure_reason,
			`"household member disqualified"',
			`"does not purchase prepare meals separately"',
			`"convicted of ipv"',
			`"drug conviction"',
			`"no longer in living arrangement code "a""') |
			inlist(closure_reason,
			`"selected regular fs because of excess shelter or medical expenses"'
			`"other (disaster closures included)"',
			`"living with spouse (lacap only)"',
			`"living with child under age 22 (lacap only)"',
			`"not a one person household ineligible for lacap"') |
			inlist(closure_reason,
			`"other"',
			`"included in another certification"',
			`"failed/refused to provide verification"',
			`"failed to timely reapply"',
			`"failed to keep appointment"') |
			inlist(closure_reason,
			`"failed to provide complete semi‐annual rpt by due date"',
			`"refused to comply with quality control"',
			`"refused to comply with eligibility requirement"',
			`"failed to comply with lajet"',
			`"failed to comply with lwc"') |
			inlist(closure_reason,
			`"refused to comply with pres"',
			`"originally ineligible"',
			`"abawd individual failed to meet requirements to work 20 hrs/week"',
			`"failed to register for work - hire"',
			`"failure due to e&t sanction"') |
			inlist(closure_reason,
			`"individual does not meet program requirement"',
			`"failure due to voluntary withdrawal"',
			`"failed net income test"',
			`"client request"',
			`"individual does not meet age requirement"',
			`"other (disaster closures included)"') 
		;
		#delimit cr 

		// copy closure_reason to shorten variable 
		rename closure_reason closure_reason_copy
		gen closure_reason = closure_reason_copy
		order closure_reason, before(closure_reason_copy)
		drop closure_reason_copy

		// assert the level of data 
		duplicates tag county ym closure_reason, gen(dup)
		assert dup == 0
		drop dup 

		// order and sort 
		order county ym closure_reason total perc 
		gsort county ym // -total 

		// save 
		tempfile _`year'_closure_page`m' 
		save `_`year'_closure_page`m''

	}

	// append pages (months) together
	// forvalues p = 1(1)12 {
	foreach p of local monthlist_`year' {
		// if `p' == 1 {
		if `p' == 7 {
			use `_`year'_closure_page`p'', clear 
		}
		else {
			append using `_`year'_closure_page`p''
		}
	}

	// order and sort 
	order county ym closure_reason total perc 
	gsort county ym // closure_reason

	// save 
	tempfile _`year'_closure
	save `_`year'_closure'

}	

else if !inlist(`year',2022,2023) {
	
	display in red "`year'"

	if `year' == 2023 {
		local month_num_end = 11 // change when more data is added
	}
	else {
		local month_num_end = 12
	}

	// for filenames
	local year_plus1 = `year' + 1
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

	// import
	import excel "${dir_root}/data/state_data/louisiana/excel/011_Cases Closed by Reason/fy`yearnames'_FS_Closures.xlsx", sheet("Table 1") allstring clear
	
	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	qui describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	foreach var of varlist * {
		replace `var' = strlower(`var')	
	}
	gen obsnum = _n

	// see approx how many observations per month 
	preserve 
		keep if strpos(v1,"closures effective")
		*br
		gen diff = obsnum[_n] - obsnum[_n-1]
		list v1 diff 
	restore

	// drop partial variable name 
	capture confirm variable v6 
	if !_rc {
		drop if v6 == "percentage" & missing(v1) & missing(v2)	
	}
	capture confirm variable v5 
	if !_rc {
		drop if v5 == "percentage" & missing(v1) & missing(v2)	
	}
	capture confirm variable v4 
	if !_rc {
		drop if v4 == "percentage" & missing(v1) & missing(v2)	
	}
	capture confirm variable v3
	if !_rc {
		drop if v3 == "percentage" & missing(v1) & missing(v2)		
	}
	capture confirm variable v10
	if !_rc {
		drop if v10 == "percentage" & missing(v1) & missing(v2)		
	}
	capture confirm variable v7
	if !_rc {
		drop if v7 == "percentage" & missing(v1) & missing(v2)		
	}
	capture confirm variable v8
	if !_rc {
		drop if v8 == "percentage" & missing(v1) & missing(v2)		
	}

	// drop bad obs 
	drop if strpos(v1,"snap - cases closed by reason")

	// separate months of data 
	qui count 
	count 
	local total_count = `r(N)'
	assert !missing(v1)
	qui sum if strpos(v1,"closures effective"), detail
	assert `r(N)' == `month_num_end'
*	
	// page by page, month by month 
	forvalues p = 1(1)`month_num_end' {
*	local p = 7
	// gotothis
		// display page number 
		display in red "`year'"
		display in red "page: `p' of `month_num_end'"

		// preserve
		preserve
		// gotothis

		// about X observations per month - differs by year 
		if inlist(`year',2002) {
			local obs_perpage_approx = 43
		}
		else if inlist(`year',2003) {
			local obs_perpage_approx = 43
		}
		else if inlist(`year',2004) & inrange(`p',1,6) {
			local obs_perpage_approx = 42
		}
		else if inlist(`year',2004) & inrange(`p',7,9) {
			local obs_perpage_approx = 38
		}
		else if inlist(`year',2004) & inrange(`p',10,12) {
			local obs_perpage_approx = 42
		}
		else if inlist(`year',2005) & inrange(`p',1,2) {
			local obs_perpage_approx = 32
		}
		else if inlist(`year',2005) & inrange(`p',3,4) {
			local obs_perpage_approx = 34
		}
		else if inlist(`year',2005) & inrange(`p',5,6) {
			local obs_perpage_approx = 36 
		}
		else if inlist(`year',2005) & inrange(`p',7,11) {
			local obs_perpage_approx = 32
		}		
		else if inlist(`year',2005) & inrange(`p',12,12) {
			local obs_perpage_approx = 37
		}		
		else if inlist(`year',2006) & inrange(`p',1,4) {
			local obs_perpage_approx = 43
		}
		else if inlist(`year',2006) & inrange(`p',5,5) {
			local obs_perpage_approx = 31
		}
		else if inlist(`year',2006) & inrange(`p',6,6) {
			local obs_perpage_approx = 42 
		}
		else if inlist(`year',2006) & inrange(`p',7,12) {
			local obs_perpage_approx = 49
		}
		else if inlist(`year',2007) & inrange(`p',1,5) {
			local obs_perpage_approx = 50
		}
		else if inlist(`year',2007) & inrange(`p',6,12) {
			local obs_perpage_approx = 52
		}
		else if inlist(`year',2008,2009,2010) {
			local obs_perpage_approx = 53
		}
		else if inlist(`year',2011) & inrange(`p',1,2) {
			local obs_perpage_approx = 41
		}
		else if inlist(`year',2011) & inrange(`p',3,6) {
			local obs_perpage_approx = 52
		}
		else if inlist(`year',2011) & inrange(`p',7,8) {
			local obs_perpage_approx = 41 
		}
		else if inlist(`year',2011) & inrange(`p',9,11) {
			local obs_perpage_approx = 44
		}
		else if inlist(`year',2011) & inrange(`p',12,12) {
			local obs_perpage_approx = 41
		}
		else if inlist(`year',2012) & inrange(`p',1,3) {
			local obs_perpage_approx = 41
		}
		else if inlist(`year',2012) & inrange(`p',4,10) {
			local obs_perpage_approx = 50
		}
		else if inlist(`year',2012) & inrange(`p',11,12) {
			local obs_perpage_approx = 43 
		}
		else if inlist(`year',2013,2014) {
			local obs_perpage_approx = 53
		}
		else if inlist(`year',2015) {
			local obs_perpage_approx = 55
		}
		else if inlist(`year',2016,2017,2018) {
			local obs_perpage_approx = 56
		}
		else if inlist(`year',2019) & inrange(`p',1,4) {
			local obs_perpage_approx = 58	
		}
		else if inlist(`year',2019) & inrange(`p',5,12) {
			local obs_perpage_approx = 40
		}
		else if inlist(`year',2020) & inrange(`p',1,2) {
			local obs_perpage_approx = 37
		}
		else if inlist(`year',2020) & inrange(`p',3,6) {
			local obs_perpage_approx = 35 
		}
		else if inlist(`year',2020) & inrange(`p',7,8) {
			local obs_perpage_approx = 37 
		}
		else if inlist(`year',2020) & inrange(`p',9,12) {
			local obs_perpage_approx = 35
		}
		else if inlist(`year',2021) {
			local obs_perpage_approx = 36
		}
		else if inlist(`year',2022) {
			local obs_perpage_approx = 26 // 32
		}
		else {
			stop 
		}
		
		// this phrase marks the beginning of a month 
		if inlist(`year',2022) & inrange(`p',3,4) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 3)*`obs_perpage_approx' + 26*2, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 2)*`obs_perpage_approx' + 26*2, detail
		}
		else if inlist(`year',2022) & inrange(`p',5,6) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 5)*`obs_perpage_approx' + 26*2 + 37*2, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 4)*`obs_perpage_approx' + 26*2 + 37*2, detail
		}
		else if inlist(`year',2022) & inrange(`p',7,7) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 7)*`obs_perpage_approx' + 26*2 + 37*2 + 35*2, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 6)*`obs_perpage_approx' + 26*2 + 37*2 + 35*2, detail
		}
		else if inlist(`year',2019) & inrange(`p',5,12) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 5)*`obs_perpage_approx' + 58*4, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 4)*`obs_perpage_approx' + 58*4, detail
		}
		else if inlist(`year',2020) & inrange(`p',3,6) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 3)*`obs_perpage_approx' + 37*2, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 2)*`obs_perpage_approx' + 37*2, detail
		}
		else if inlist(`year',2020) & inrange(`p',7,8) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 7)*`obs_perpage_approx' + 37*2 + 35*4, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 6)*`obs_perpage_approx' + 37*2 + 35*4, detail
		}
		else if inlist(`year',2020) & inrange(`p',9,12) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 9)*`obs_perpage_approx' + 37*2 + 35*4 + 37*2, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 8)*`obs_perpage_approx' + 37*2 + 35*4 + 37*2, detail
		}
		else if inlist(`year',2012) & inrange(`p',4,10) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 4)*`obs_perpage_approx' + 41*3, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 3)*`obs_perpage_approx' + 41*3, detail
		}
		else if inlist(`year',2012) & inrange(`p',11,12) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 11)*`obs_perpage_approx' + 41*3 + 50*7, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 10)*`obs_perpage_approx' + 41*3 + 50*7, detail
		}
		else if inlist(`year',2011) & inrange(`p',3,6) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 3)*`obs_perpage_approx' + 41*2, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 2)*`obs_perpage_approx' + 41*2, detail
		}
		else if inlist(`year',2011) & inrange(`p',7,8) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 7)*`obs_perpage_approx' + 41*2 + 52*4, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 6)*`obs_perpage_approx' + 41*2 + 52*4, detail
		}
		else if inlist(`year',2011) & inrange(`p',9,11) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 9)*`obs_perpage_approx' + 41*2 + 52*4 + 41*2, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 8)*`obs_perpage_approx' + 41*2 + 52*4 + 41*2, detail
		}
		else if inlist(`year',2011) & inrange(`p',12,12) {
			*qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 12)*`obs_perpage_approx' + 41*2 + 52*4 + 41*2 + 44*2, detail
			local first_obsnum = 505
			*qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 11)*`obs_perpage_approx' + 41*2 + 52*4 + 41*2 + 44*2, detail
		}
		else if inlist(`year',2007) & inrange(`p',6,12) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 6)*`obs_perpage_approx' + 50*5, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 5)*`obs_perpage_approx' + 50*5, detail
		}
		else if inlist(`year',2006) & inrange(`p',5,5) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 5)*`obs_perpage_approx' + 43*4, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 4)*`obs_perpage_approx' + 43*4, detail
		}
		else if inlist(`year',2006) & inrange(`p',6,6) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 6)*`obs_perpage_approx' + 43*4 + 31*1, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 5)*`obs_perpage_approx' + 43*4 + 31*1, detail
		}
		else if inlist(`year',2006) & inrange(`p',7,12) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 7)*`obs_perpage_approx' + 43*4 + 31*1 + 42*1, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 6)*`obs_perpage_approx' + 43*4 + 31*1 + 42*1, detail
		}
		else if inlist(`year',2005) & inrange(`p',3,4) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 3)*`obs_perpage_approx' + 32*2, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 2)*`obs_perpage_approx' + 32*2, detail
		}
		else if inlist(`year',2005) & inrange(`p',5,6) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 5)*`obs_perpage_approx' + 32*2 + 34*2, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 4)*`obs_perpage_approx' + 32*2 + 34*2, detail
		}
		else if inlist(`year',2005) & inrange(`p',7,11) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 7)*`obs_perpage_approx' + 32*2 + 34*2 + 36*2, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 6)*`obs_perpage_approx' + 32*2 + 34*2 + 36*2, detail
		}
		else if inlist(`year',2005) & inrange(`p',12,12) {
			*qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 12)*`obs_perpage_approx' + 32*2 + 34*2 + 36*2 + 32*4, detail
			local first_obsnum = 370
			*qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 11)*`obs_perpage_approx' + 32*2 + 34*2 + 36*2 + 32*4, detail
		}
		else if inlist(`year',2004) & inrange(`p',7,9) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 7)*`obs_perpage_approx' + 42*6, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 6)*`obs_perpage_approx' + 42*6, detail
		}
		else if inlist(`year',2004) & inrange(`p',10,12) {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 10)*`obs_perpage_approx' + 42*6 + 38*3, detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 9)*`obs_perpage_approx' + 42*6 + 38*3, detail
		}
		else {
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 1)*`obs_perpage_approx', detail
			local first_obsnum = `r(min)'
			qui sum if strpos(v1,"closures effective") & obsnum >= (`p' - 0)*`obs_perpage_approx', detail
		}

		if `p' < `month_num_end' {
			local last_obsnum = `r(min)' - 1	
		}
		else if `p' == `month_num_end' {
			qui sum obsnum
			local very_last_obsnum = `r(max)'
			qui sum obsnum if strpos(v1,"state fiscal year") & strpos(v1,"year to date totals")
			assert inlist(`r(N)',0,1)
			if `r(N)' == 1 {
				local cutoff_obsnum = `r(mean)'	- 1
			}
			else {
				local cutoff_obsnum = 1000000000000
			}
			local last_obsnum = min(`very_last_obsnum',`cutoff_obsnum')
		}
		else {
			stop 
		}

		// keep observations for this month only 
		gen keep = 0
		replace keep = 1 if inrange(obsnum,`first_obsnum',`last_obsnum')
		*tab keep check
		keep if keep == 1
		drop keep 

		// initial cleanup
		order obsnum 
		dropmiss, force 
		dropmiss, obs force 
		qui describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		rename v1 obsnum 

		// mark month 
		// "april report - closures effective may 2022" - treated as april, for example 
		gen month = .
		qui replace month = 1 if ustrregexm(v2,"january") == 1 & ustrregexm(v2,"february") == 1
		qui replace month = 2 if ustrregexm(v2,"february") == 1 & ustrregexm(v2,"march") == 1
		qui replace month = 3 if ustrregexm(v2,"march") == 1 & ustrregexm(v2,"april") == 1
		qui replace month = 4 if ustrregexm(v2,"april") == 1 & ustrregexm(v2,"may") == 1 
		qui replace month = 5 if ustrregexm(v2,"may") == 1 & ustrregexm(v2,"june") == 1
		qui replace month = 6 if ustrregexm(v2,"june") == 1 & ustrregexm(v2,"july") == 1
		qui replace month = 7 if ustrregexm(v2,"july") == 1 & ustrregexm(v2,"august") == 1
		qui replace month = 8 if ustrregexm(v2,"august") == 1 & ustrregexm(v2,"september") == 1
		qui replace month = 9 if ustrregexm(v2,"september") == 1 & ustrregexm(v2,"october") == 1
		qui replace month = 10 if ustrregexm(v2,"october") == 1 & ustrregexm(v2,"november") == 1
		qui replace month = 11 if ustrregexm(v2,"november") == 1 & ustrregexm(v2,"december") == 1
		qui replace month = 12 if ustrregexm(v2,"december") == 1 & ustrregexm(v2,"january") == 1
		gsort -obsnum
		qui carryforward month, replace
		sort obsnum 
		qui carryforward month, replace 
		assert !missing(month)

		// mark year 
		// Note: this corresponds with the choice above: 
		// "april report - closures effective may 2022" - treated as april, for example
		assert inrange(`p',1,12)
		gen year = .
		if inlist(`year',2020,2021) {
			// these pages are in reverse order 
			replace year = `year' + 1 if inrange(`p',1,6)
			replace year = `year' if inrange(`p',7,12)
		}
		else if inlist(`year',2022) {
			// these pages are in reverse order 
			replace year = `year' + 1 if inrange(`p',1,1)
			replace year = `year' if inrange(`p',2,7)			
		}
		else {
			replace year = `year' if inrange(`p',1,6)
			replace year = `year' + 1 if inrange(`p',7,12)
		}
		assert !missing(year)
		// "april report - closures effective may 2022"
		gen year2 = .
		local year_end_closed_plus1 = `year_end_closed' + 1
		forvalues y = `year_start_closed'(1)`year_end_closed_plus1' {
			*if inlist(`year',2020,2021) {
			*	qui replace year2 = `y' if ustrregexm(v2,"`y'") == 1
			*	qui replace year2 = `y' - 1 if ustrregexm(v2,"`y'") == 1 & month == 12 // relies on december / january being treated as december (month 12)
			*}
			*else {
				qui replace year2 = `y' if ustrregexm(v2,"`y'") == 1
				qui replace year2 = `y' - 1 if ustrregexm(v2,"`y'") == 1 & month == 12 // relies on december / january being treated as december (month 12)
			*}
		}
		gsort -obsnum
		qui carryforward year2, replace
		sort obsnum 
		qui carryforward year2, replace 
		*assert !missing(year2)
		// fix special cases where there was a mistake in the data 
		if `year' == 2016 & `p' == 12 {
			replace year2 = 2017
		}
		if `year' == 2019 & `p' == 6 {
			replace year2 = 2019
		}
		if `year' == 2020 & `p' == 7 {
			replace year2 = 2020
		}
		if `year' == 2022 & `p' == 1 {
			replace year2 = 2023
		}		
		// corroborate years 
		assert year == year2 if !missing(year) & !missing(year2)
		replace year = year2 if missing(year) & !missing(year2)
		drop year2 
		
		// ym 
		gen ym = ym(year,month)
		format ym %tm 
		drop year 
		drop month 
		
		// drop year obs 
		drop if strpos(v2,"closures effective")

		// initial cleanup
		order obsnum ym 
		dropmiss, force 
		dropmiss, obs force 
		qui describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		rename v1 obsnum
		rename v2 ym 

		// move observations over if an extra column 
		qui describe, varlist 
		assert inlist(`r(k)',4,5,6) // supposed to be 5
		if `r(k)' == 6 {
			// possible case 1
			replace v4 = v5 if missing(v4) & !missing(v5)
			replace v5 = "" if v4 == v5 & !missing(v5)
			// possible case 2
			replace v5 = v6 if missing(v5) & !missing(v6)
			replace v6 = "" if v5 == v6 & !missing(v6)
			dropmiss, force 
			qui describe, varlist 
			rename (`r(varlist)') (v#), addnumber
			rename v1 obsnum
			rename v2 ym 
		}
		// split reason name from number, if needed
		else if `r(k)' == 4 { // & inlist(`year',2012) & inlist(`p',2) {
			gen number = ustrregexra(v3," ","")
			replace number = ustrregexra(v3,`"[A-Za-z()/"]"',`""')
			replace number = trim(number)
			replace number = ustrregexra(number,",","")
			// manual
			*replace number = "550" if number == ".                                                     550"
			replace number = ustrregexra(number,"\.                                                    ","")
			replace number = ustrregexra(number,"‐                    ","")
			// go to this 
			replace number = trim(number)
			order number, after(v3)
			gen new= ustrregexra(v3,`"[0-9,]"',`""')
			replace new = trim(new)
			order new, after(v3)
			drop v3 
			rename new v3 
			qui describe, varlist 
			rename (`r(varlist)') (v#), addnumber
			rename v1 obsnum
			rename v2 ym 
		}

		// rename vars 
		qui describe, varlist 
		assert `r(k)' == 5
		rename v3 closure_reason 
		rename v4 total 
		rename v5 perc
		drop in 1 

		// destring
		foreach var in total perc {
			destring `var', replace ignore(",")
			confirm numeric variable `var'
		}

		// county 
		gen county = "total"

		// clean up the closure_reason variable 
		
		// manual drop 
		drop if strpos(closure_reason,"percentage") & strpos(closure_reason,"reason") & strpos(closure_reason,"of total")

		// categorize the closure_reasons into groups based on how fine they are 
			// overall group: total 
			gen group_total = 0
			replace group_total = 1 if closure_reason == "state total"
			// headings group
			gen group_heading = 0
			// standardize fine categories
				// code from xwalk excel file
				gen closure_reason_og = closure_reason
				// one alternative
				replace closure_reason = `"voluntary withdrawal"' if closure_reason == `"application withdrawal"'
		
			#delimit ;
			replace group_heading = 1 
				if inlist(	closure_reason,
							"earned income total",
							"unearned income total",
							"other eligibility total",
							"procedural reasons total",
							"sanction reasons total",
							"voluntary withdrawal",
							"other reasons total"
							)
			;
			#delimit cr 
			// finest group 
			gen group_finecategory = 0
			#delimit ;
			replace group_finecategory = 1
				if 			closure_reason == `"gross inc. eligibility net exceeds limit"' |
							closure_reason == `"increase in wages or new employment"' |
							closure_reason == `"gross income ineligible"' |
							closure_reason == `"increase in contributions"' |
							closure_reason == `"increase in child support"' |
							closure_reason == `"increase in social security or ssi"' |
							closure_reason == `"increase in other federal benefits"' |
							closure_reason == `"increase in other state benefits"' |
							closure_reason == `"does not receive ssi"' |
							closure_reason == `"resources over limit"' |
							closure_reason == `"transferred resources"' |
							closure_reason == `"decrease need or expenses"' |
							closure_reason == `"unable to locate"' |
							closure_reason == `"residence requirement not met"' |
							closure_reason == `"residence out of parish"' |
							closure_reason == `"moved out of state"' |
							closure_reason == `"head of hh (payee) left home"' |
							closure_reason == `"institutionalization/incarceration"' |
							closure_reason == `"voluntary quit without good cause"' |
							closure_reason == `"no eligible child/member in the home"' |
							closure_reason == `"death of applicant/head of household"' |
							closure_reason == `"citizenship not met"' |
							closure_reason == `"change in state law or policy"' |
							closure_reason == `"expired redetermination"' |
							closure_reason == `"questionable information not provided"' |
							closure_reason == `"household member disqualified"' |
							closure_reason == `"does not purchase prepare meals separately"' |
							closure_reason == `"convicted of ipv"' |
							closure_reason == `"drug conviction"' |
							closure_reason == `"no longer in living arrangement code "a""' |
							strpos(closure_reason,`"selected regular fs because of excess shelter or medic"') |
							closure_reason == `"other (disaster closures included)"' |
							closure_reason == `"living with spouse (lacap only)"' |
							closure_reason == `"age requirement not met"' |
							closure_reason == `"included in another certification"' |
							closure_reason == `"failed/refused to provide verification"' |
							closure_reason == `"failed to timely reapply"' |
							closure_reason == `"failed to keep appointment"' |
							strpos(closure_reason,`"failed to provide complete semi-annual rpt by due dat"') |
							closure_reason == `"refused to comply with qc"' |
							closure_reason == `"refused to comply with eligibility requirement"' |
							closure_reason == `"failed to comply with lajet"' |
							closure_reason == `"originally ineligible"' | 
							//
							closure_reason == `"does not meet abawd work requirement"' |
							closure_reason == `"living with child under age 22 (lacap only)"' |
							closure_reason == `"failed to comply with lwc"' |
							closure_reason == `"other"' |
							closure_reason == `"failed to register for work - hire"' |
							//////
							closure_reason == `"failed net income test"' |
							//
							closure_reason == `"failed gross income test"' |
							closure_reason == `"individual is not receiving ssi"' |
							//
							closure_reason == `"failed resource test"' |
							closure_reason == `"failed due to resource transfer"' |
							closure_reason == `"failure due to voluntary withdrawal"' |
							closure_reason == `"failed residency requirement"' |
							closure_reason == `"individual is out of home"' |
							closure_reason == `"failed due to incarcerated applicant"' |
							closure_reason == `"no eligible children"' |
							closure_reason == `"case name deceased"' |
							closure_reason == `"failed citizenship requirement"' |
							closure_reason == `"individual does not purchase and prepare meals together"' |
							closure_reason == `"disqualified due to an ipv"' |
							closure_reason == `"individual does not meet program requirement"' |
							closure_reason == `"individual does not meet age requirement"' |
							closure_reason == `"individual is receiving benefits in another case"' |
							closure_reason == `"abawd individual failed to meet requirements to work 20 hrs/week"' |
							closure_reason == `"not a one person household ineligible for lacap"' |
							//
							closure_reason == `"failed to provide required information within specific timeframe"' |
							closure_reason == `"failure to complete redet"' |
							closure_reason == `"failed to complete interview"' |
							closure_reason == `"failure to complete sr"' |
							//
							closure_reason == `"failure due to e&t sanction"' |
							closure_reason == `"failure due to non cooperation with quality control"' |
							closure_reason == `"fail to register for work - hire"' |
							//
							closure_reason == `"client request"' |
							//
							strpos(closure_reason,`"abawd individual failed to meet requirements to work 20 hrs/w"') |
							strpos(closure_reason,`"fail to register for work ‐ hire"') |
							// 
							closure_reason == `"failed to provide complete semi‐annual rpt by due date"' |
							//
							closure_reason == `"refused to comply with pres"' |
							// 
							strpos(closure_reason,`"does not purchase prepare meals separ"') | 
 							strpos(closure_reason,`"selected regular fs because of excess s"') | 
 							strpos(closure_reason,`"failed to provide complete semi-annual"') | 
 							strpos(closure_reason,`"refused to comply with eligibility require"') |
 							strpos(closure_reason,`"no longer in living arrangement code"') |
 							//
 							strpos(closure_reason,`"refused to comply with quality control"')
							// closure_reason == `""' |
							// gotothis
			;
			#delimit cr 

		// make sure all reasons are accounted for 
		gen has_a_category = (group_total == 1 | group_heading == 1 | group_finecategory == 1)  
		list closure_reason obsnum if has_a_category == 0
		assert has_a_category == 1
		drop has_a_category

		// standardize fine categories
		// code from xwalk excel file
		*	gen closure_reason_og = closure_reason
			// one alternative
			replace closure_reason = `"death of applicant/head of household"' if closure_reason == `"case name deceased"'
			replace closure_reason = `"convicted of ipv"' if closure_reason == `"disqualified due to an ipv"'
			replace closure_reason = `"citizenship not met"' if closure_reason == `"failed citizenship requirement"'
			replace closure_reason = `"institutionalization/incarceration"' if closure_reason == `"failed due to incarcerated applicant"'
			replace closure_reason = `"transferred resources"' if closure_reason == `"failed due to resource transfer"'
			replace closure_reason = `"gross income ineligible"' if closure_reason == `"failed gross income test"'
			replace closure_reason = `"residence requirement not met"' if closure_reason == `"failed residency requirement"'
			replace closure_reason = `"resources over limit"' if closure_reason == `"failed resource test"'
			replace closure_reason = `"failed to keep appointment"' if closure_reason == `"failed to complete interview"'
			replace closure_reason = `"failed/refused to provide verification"' if closure_reason == `"failed to provide required information within specific timeframe"'
			replace closure_reason = `"failed to timely reapply"' if closure_reason == `"failure to complete redet"'
			replace closure_reason = `"does not receive ssi"' if closure_reason == `"individual is not receiving ssi"'
			replace closure_reason = `"head of hh (payee) left home"' if closure_reason == `"individual is out of home"'
			replace closure_reason = `"included in another certification"' if closure_reason == `"individual is receiving benefits in another case"'
			replace closure_reason = `"no eligible child/member in the home"' if closure_reason == `"no eligible children"'
			replace closure_reason = `"no longer in living arrangement code "a""' if strpos(closure_reason,`"no longer in living arrangement code"')
			replace closure_reason = `"refused to comply with eligibility requirement"' if strpos(closure_reason,`"refused to comply with eligibility require"')
			replace closure_reason = `"selected regular fs because of excess shelter or medical expenses"' if strpos(closure_reason,`"selected regular fs because of excess s"')
			replace closure_reason = `"individual does not meet age requirement"' if closure_reason == `"age requirement not met"'
			replace closure_reason = `"other (disaster closures included)"' if closure_reason == `"other"'
			// two alternatives
			replace closure_reason = `"abawd individual failed to meet requirements to work 20 hrs/week"' if strpos(closure_reason,`"abawd individual failed to meet requirements to work 20 hrs/w"') | closure_reason == `"does not meet abawd work requirement"'
			replace closure_reason = `"does not purchase prepare meals separately"' if strpos(closure_reason,`"does not purchase prepare meals separ"') | closure_reason == `"individual does not purchase and prepare meals together"'
			replace closure_reason = `"failed to register for work - hire"' if strpos(closure_reason,`"fail to register for work ‐ hire"') | closure_reason == `"fail to register for work - hire"'
			replace closure_reason = `"failed to provide complete semi‐annual rpt by due date"' if strpos(closure_reason,`"failed to provide complete semi-annual"') | closure_reason == `"failure to complete sr"'
			// three alternatives
			replace closure_reason = `"refused to comply with quality control"' if strpos(closure_reason,`"refused to comply with quality control"') | closure_reason == `"refused to comply with qc"' | closure_reason == `"failure due to non cooperation with quality control"'

		// assert that all the closure_reasons are in my list 
		#delimit ;
		 list closure_reason if !(
			inlist(closure_reason,
			`"state total"') | 
			inlist(closure_reason,
			`"earned income total"',
			`"unearned income total"',
			`"other eligibility total"',
			`"procedural reasons total"',
			`"sanction reasons total"',
			`"voluntary withdrawal"',
			`"other reasons total"') |
			inlist(closure_reason,
			`"gross inc. eligibility net exceeds limit"',
			`"increase in wages or new employment"',
			`"gross income ineligible"',
			`"increase in contributions"',
			`"increase in child support"') |
			inlist(closure_reason,
			`"increase in social security or ssi"',
			`"increase in other federal benefits"',
			`"increase in other state benefits"',
			`"does not receive ssi"',
			`"resources over limit"') |
			inlist(closure_reason,
			`"transferred resources"',
			`"decrease need or expenses"',
			`"unable to locate"',
			`"residence requirement not met"',
			`"residence out of parish"') |
			inlist(closure_reason,
			`"moved out of state"',
			`"head of hh (payee) left home"',
			`"institutionalization/incarceration"',
			`"voluntary quit without good cause"',
			`"no eligible child/member in the home"') |
			inlist(closure_reason,
			`"death of applicant/head of household"',
			`"citizenship not met"',
			`"change in state law or policy"',
			`"expired redetermination"',
			`"questionable information not provided"') |
			inlist(closure_reason,
			`"household member disqualified"',
			`"does not purchase prepare meals separately"',
			`"convicted of ipv"',
			`"drug conviction"',
			`"no longer in living arrangement code "a""') |
			inlist(closure_reason,
			`"selected regular fs because of excess shelter or medical expenses"'
			`"other (disaster closures included)"',
			`"living with spouse (lacap only)"',
			`"living with child under age 22 (lacap only)"',
			`"not a one person household ineligible for lacap"') |
			inlist(closure_reason,
			`"other"',
			`"included in another certification"',
			`"failed/refused to provide verification"',
			`"failed to timely reapply"',
			`"failed to keep appointment"') |
			inlist(closure_reason,
			`"failed to provide complete semi‐annual rpt by due date"',
			`"refused to comply with quality control"',
			`"refused to comply with eligibility requirement"',
			`"failed to comply with lajet"',
			`"failed to comply with lwc"') |
			inlist(closure_reason,
			`"refused to comply with pres"',
			`"originally ineligible"',
			`"abawd individual failed to meet requirements to work 20 hrs/week"',
			`"failed to register for work - hire"',
			`"failure due to e&t sanction"') |
			inlist(closure_reason,
			`"individual does not meet program requirement"',
			`"failure due to voluntary withdrawal"',
			`"failed net income test"',
			`"client request"',
			`"individual does not meet age requirement"',
			`"other (disaster closures included)"') // )
			)
		;
		#delimit cr 

		// assert that all the closure_reasons are in my list 
		#delimit ;
		assert  
			inlist(closure_reason,
			`"state total"') | 
			inlist(closure_reason,
			`"earned income total"',
			`"unearned income total"',
			`"other eligibility total"',
			`"procedural reasons total"',
			`"sanction reasons total"',
			`"voluntary withdrawal"',
			`"other reasons total"') |
			inlist(closure_reason,
			`"gross inc. eligibility net exceeds limit"',
			`"increase in wages or new employment"',
			`"gross income ineligible"',
			`"increase in contributions"',
			`"increase in child support"') |
			inlist(closure_reason,
			`"increase in social security or ssi"',
			`"increase in other federal benefits"',
			`"increase in other state benefits"',
			`"does not receive ssi"',
			`"resources over limit"') |
			inlist(closure_reason,
			`"transferred resources"',
			`"decrease need or expenses"',
			`"unable to locate"',
			`"residence requirement not met"',
			`"residence out of parish"') |
			inlist(closure_reason,
			`"moved out of state"',
			`"head of hh (payee) left home"',
			`"institutionalization/incarceration"',
			`"voluntary quit without good cause"',
			`"no eligible child/member in the home"') |
			inlist(closure_reason,
			`"death of applicant/head of household"',
			`"citizenship not met"',
			`"change in state law or policy"',
			`"expired redetermination"',
			`"questionable information not provided"') |
			inlist(closure_reason,
			`"household member disqualified"',
			`"does not purchase prepare meals separately"',
			`"convicted of ipv"',
			`"drug conviction"',
			`"no longer in living arrangement code "a""') |
			inlist(closure_reason,
			`"selected regular fs because of excess shelter or medical expenses"'
			`"other (disaster closures included)"',
			`"living with spouse (lacap only)"',
			`"living with child under age 22 (lacap only)"',
			`"not a one person household ineligible for lacap"') |
			inlist(closure_reason,
			`"other"',
			`"included in another certification"',
			`"failed/refused to provide verification"',
			`"failed to timely reapply"',
			`"failed to keep appointment"') |
			inlist(closure_reason,
			`"failed to provide complete semi‐annual rpt by due date"',
			`"refused to comply with quality control"',
			`"refused to comply with eligibility requirement"',
			`"failed to comply with lajet"',
			`"failed to comply with lwc"') |
			inlist(closure_reason,
			`"refused to comply with pres"',
			`"originally ineligible"',
			`"abawd individual failed to meet requirements to work 20 hrs/week"',
			`"failed to register for work - hire"',
			`"failure due to e&t sanction"') |
			inlist(closure_reason,
			`"individual does not meet program requirement"',
			`"failure due to voluntary withdrawal"',
			`"failed net income test"',
			`"client request"',
			`"individual does not meet age requirement"',
			`"other (disaster closures included)"') 
		;
		#delimit cr 

		// copy closure_reason to shorten variable 
		rename closure_reason closure_reason_copy
		gen closure_reason = closure_reason_copy
		order closure_reason, before(closure_reason_copy)
		drop closure_reason_copy

		// assert the level of data 
		duplicates tag county ym closure_reason, gen(dup)
		assert dup == 0
		drop dup 

		// order and sort 
		order county ym closure_reason total perc 
		gsort county ym // -total 

		// drop 
		drop obsnum 

		// save 
		tempfile _`year'_closure_page`p' 
		save `_`year'_closure_page`p''

		// restore 
		restore
	}

	// append pages (months) together
	forvalues p = 1(1)`month_num_end' {
		if `p' == 1 {
			use `_`year'_closure_page`p'', clear 
		}
		else {
			append using `_`year'_closure_page`p''
		}
	}

	// order and sort 
	order county ym closure_reason total perc 
	gsort county ym // closure_reason

	// save 
	tempfile _`year'_closure
	save `_`year'_closure'

}
}
// then append years together
forvalues year = `year_start_closed'(1)`year_end_closed' {
	if `year' == `year_start_closed' {
		use `_`year'_closure'
	}
	else {
		append using `_`year'_closure'
	}
}

// assert the level of data / check for duplicates
duplicates drop 
duplicates tag county ym closure_reason, gen(dup)
assert dup == 0
drop dup 

// order and sort 
order county ym group_total group_heading group_finecategory closure_reason total perc closure_reason_og
gsort county ym -group_total -group_heading -group_finecategory closure_reason

// save 
save "${dir_root}/data/state_data/louisiana/louisiana_closure.dta", replace 
 
****************************************************************************************************
****************************************************************************************************

// create a county ym level version of the closure data
// by each level separately  
use "${dir_root}/data/state_data/louisiana/louisiana_closure.dta", clear 
keep if group_total == 1 
drop group_*
drop perc 
drop closure_reason_og
replace closure_reason = ustrregexra(closure_reason," ","")
replace closure_reason = substr(closure_reason,1,28)
rename total c_1_
reshape wide c_1_, i(county ym) j(closure_reason) string
tempfile louisiana_closure_group_total 
save `louisiana_closure_group_total'
save "${dir_root}/data/state_data/louisiana/louisiana_closure_group_total.dta", replace 


use "${dir_root}/data/state_data/louisiana/louisiana_closure.dta", clear 
keep if group_heading == 1 
drop group_*
drop perc 
drop closure_reason_og
replace closure_reason = ustrregexra(closure_reason," ","")
replace closure_reason = substr(closure_reason,1,28)
rename total c_2_
reshape wide c_2_, i(county ym) j(closure_reason) string
tempfile louisiana_closure_group_heading 
save `louisiana_closure_group_heading'
save "${dir_root}/data/state_data/louisiana/louisiana_closure_group_heading.dta", replace 


use "${dir_root}/data/state_data/louisiana/louisiana_closure.dta", clear 
keep if group_finecategory == 1 
drop group_*
drop perc 
drop closure_reason_og
replace closure_reason = ustrregexra(closure_reason," ","")
replace closure_reason = ustrregexra(closure_reason,"/","")
replace closure_reason = ustrregexra(closure_reason,"\(","")
replace closure_reason = ustrregexra(closure_reason,"\)","")
replace closure_reason = ustrregexra(closure_reason,"\-","")
replace closure_reason = ustrregexra(closure_reason,"\&","and")
replace closure_reason = ustrregexra(closure_reason,"\.","")
replace closure_reason = substr(closure_reason,1,27)
rename total c_3_
reshape wide c_3_, i(county ym) j(closure_reason) string
tempfile louisiana_closure_group_fine 
save `louisiana_closure_group_fine'
save "${dir_root}/data/state_data/louisiana/louisiana_closure_group_fine.dta", replace 
*/

********************************************************************
********************************************************************
********************************************************************
********************************************************************
********************************************************************
********************************************************************
/*
// STATE TOTALS 1987-2006
// Part 1

// loop through years 
forvalues year = `year_start_part1'(1)`year_end_part1' {

	// display 
	display in red "`year'"

	// import
	import excel "${dir_root}/data/state_data/louisiana/excel/FS_SFY_Totals.xlsx", sheet("Table 1") allstring clear
	
	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	gen obsnum = _n

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
	describe, varlist
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

}

*******************************************
// Part 2 

// loop through years 
forvalues year = `year_start_part2'(1)`year_end_part2' {
	
	// display 
	display in red "`year'"

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
	import excel "${dir_root}/data/state_data/louisiana/excel/001_Fiscal Year Totals/fy`yearnames'_FS_SFY_Totals.xlsx", sheet("Table 1") allstring clear

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
	drop if strpos(v1,"information has been revised based on actual benefits issued")

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
		replace `var' = ustrregexra(`var',"Pending","")
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
gen county = "total"
tempfile louisiana_state
save `louisiana_state'
save "${dir_root}/data/state_data/louisiana/louisiana_state.dta", replace 
check 
*/
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
/*
forvalues year = `year_start_cases'(1)`year_end_cases' {
	
	display in red "`year'"

	if `year' == 2023 {
		local month_num_end = 11 // change when more data is added
	}
	else {
		local month_num_end = 12
	}

	// for filenames
	local year_plus1 = `year' + 1
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

	// import
	import excel "${dir_root}/data/state_data/louisiana/excel/002_Cases by Parish & Region/fy`yearnames'_FS_Cases.xlsx", sheet("Table 1") allstring clear
	
	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	gen obsnum = _n
 
	replace v1 = strlower(v1)
	replace v2 = strlower(v2)
	
	// mark observation numbers for this month
	drop if v1 == "as of june 1, 2009, the family assistance program policy section, in partnership with neighborhood place, has converted sabine parish into two districts"
	drop if strpos(v1,"snap cases by parish & region")
	sum obsnum if strpos(v1,"parish"), detail // strpos(v1,"parish")
	if inlist(`year',2004) | inrange(`year',2007,2012) {
		local num_pages = 4
		assert r(N) == `num_pages'
		local begin_month1 = r(min) 
		sum obsnum if strpos(v1,"parish") & obsnum != r(min), detail // strpos(v1,"parish")
		assert r(N) == 3
		local end_month1 = r(min) - 1
		local begin_month2 = r(min)
		local end_month2 = r(p50) - 1
		local begin_month3 = r(p50)
		local end_month3 = r(max) - 1
		local begin_month4 = r(max)
		sum obsnum
		local end_month4 = r(max)

	}
	else if inlist(`year',2005,2006) {
		local num_pages = 5
		assert r(N) == `num_pages'
		local begin_month1 = r(min) 
	*	local end_month1 = 
	*	local begin_month2 = 
		local end_month2 = r(p50) - 1
		local begin_month3 = r(p50)
	*	local end_month3 = 
	*	local begin_month4 = 
		local end_month4 = r(max) - 1
		local begin_month5 = r(max)
*		local end_month5 = 
		sum obsnum if strpos(v1,"parish") & obsnum != r(min) & obsnum != r(p50) & obsnum != r(max), detail // strpos(v1,"parish")
		assert r(N) == 2
		local end_month1 = r(min) - 1
		local begin_month2 = r(min) 
		local end_month3 = r(max) - 1
		local begin_month4 = r(max)
		sum obsnum
		local end_month5 = r(max)
	}
	else if inrange(`year',2013,`year_end_cases') {
		local num_pages = 2
		assert r(N) == `num_pages'
		local begin_month1 = r(min)
		local end_month1 = r(max) - 1
		local begin_month2 = r(max)
		sum obsnum
		local end_month2 = r(max)
	}
	else {
		local num_pages = 3
		assert r(N) == `num_pages'
		local begin_month1 = r(min) 
		local end_month1 = r(p50) - 1
		local begin_month2 = r(p50)
		local end_month2 = r(max) - 1
		local begin_month3 = r(max)
		sum obsnum
		local end_month3 = r(max)
	}


	forvalues page = 1(1)`num_pages' {

		// display
		display in red `page'

		// preserve 
		preserve 

		// keep observations
		keep if inrange(obsnum,`begin_month`page'',`end_month`page'')
		drop obsnum

		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		drop if v1 == "parish"
		drop if v1 == "region i - southeast"
		drop if v1 == "region ii - baton rouge"
		drop if v1 == "region iii - thibodaux"
		drop if v1 == "region iv - orleans"
		drop if v1 == "region v - acadiana"
		drop if v1 == "region vi - alexandria"
		drop if v1 == "region vii - shreveport"
		drop if v1 == "region viii - monroe"
		drop if strpos(v1,"region 1") & strpos(v1,"orleans")
		drop if strpos(v1,"region 2") & strpos(v1,"baton rouge")
		drop if strpos(v1,"region 3") & strpos(v1,"covington")
		drop if strpos(v1,"region 4") & strpos(v1,"thibodaux")
		drop if strpos(v1,"region 5") & strpos(v1,"lafayette")
		drop if strpos(v1,"region 6") & strpos(v1,"lake charles")
		drop if strpos(v1,"region 7") & strpos(v1,"alexandria")
		drop if strpos(v1,"region 8") & strpos(v1,"shreveport")
		drop if strpos(v1,"region 9") & strpos(v1,"monroe")
		drop if v1 == "as of june 1, 2009, the family assistance program policy section, in partnership with neighborhood place, has converted sabine parish into two districts"
		drop if strpos(v1,"july") & strpos(v1,"parish")
		drop if v2 == "july"
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber

		// move numbers 
		describe, varlist 
		if r(k) == 24 {
			replace v5 = v6 if missing(v5) & !missing(v6)
			replace v6 = "" if v5 == v6 
			replace v7 = v8 if missing(v7) & !missing(v8)
			replace v8 = "" if v7 == v8 
			replace v13 = v14 if missing(v13) & !missing(v14)
			replace v14 = "" if v13 == v14 
			replace v15 = v16 if missing(v15) & !missing(v16)
			replace v16 = "" if v15 == v16 
			replace v17 = v18 if missing(v17) & !missing(v18)
			replace v18 = "" if v17 == v18 
			replace v19 = v20 if missing(v19) & !missing(v20)
			replace v20 = "" if v19 == v20 		
			dropmiss, force 
			dropmiss, obs force 
			describe, varlist 
			rename (`r(varlist)') (v#), addnumber
		}

		// rename variables
		describe, varlist
		if `year' < 2005 {
			
			assert r(k) == 18
			rename v1 countycode
			rename v2 county 
			rename v3 m7
			rename v4 m8 
			rename v5 m9 
			rename v6 m10 
			rename v7 m11 
			rename v8 m12 
			rename v9 m1 
			rename v10 m2 
			rename v11 m3 
			rename v12 m4 
			rename v13 m5 
			rename v14 m6  
			rename v15 month_case_change 
			rename v16 month_percent_change 
			rename v17 year_case_change 
			rename v18 year_percent_change
	
			// move region names to county 
			gen county_marker = 1
			replace county_marker = 0 if strpos(countycode,"region") & strpos(countycode,"total") 
			replace county_marker = 0 if strpos(countycode,"state") & strpos(countycode,"total") 
			
			replace county = countycode if county_marker == 0
			replace countycode = "" if county_marker == 0

		}
		else if `year' == `year_end_cases' {
			assert r(k) == 16
			rename v1 county 
			rename v2 m7
			rename v3 m8 
			rename v4 m9 
			rename v5 m10 
			rename v6 m11 
			rename v7 m12 
			rename v8 m1 
			rename v9 m2 
			rename v10 m3 
			rename v11 m4 
			rename v12 m5 
			gen m6 = ""
			rename v13 month_case_change 
			rename v14 month_percent_change 
			rename v15 year_case_change 
			rename v16 year_percent_change
			
			// split county number and name 
			*split county, parse(" ")
			gen county_marker = 1
			replace county_marker = 0 if strpos(county,"region") // & strpos(county,"total") 
			replace county_marker = 0 if strpos(county,"state") & strpos(county,"total") 
			replace county_marker = 0 if strpos(county,"other") & strpos(county,"total")
			*gen countycode = county1 if county_marker == 1
			*destring countycode, replace
			*gen county_new = ""
			*capture noisily replace county_new = county3 + " " + county4 if county_marker == 1
			*capture noisily replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 if county_marker == 0
			*capture noisily replace county_new = county3 + " " + county4 + " " + county5 if county_marker == 1
			*capture noisily replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 if county_marker == 0
			*capture noisily replace county_new = county3 + " " + county4 + " " + county5 + " " + county6 if county_marker == 1
			*capture noisily replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 + " " + county6 if county_marker == 0
			*replace county_new = trim(county_new)
			*order county_marker county_new county countycode
			*drop county county1 county2 county3 county4 
			*capture drop county5 
			*capture drop county6
			*rename county_new county

		}
		else {

			assert r(k) == 17
			rename v1 county 
			rename v2 m7
			rename v3 m8 
			rename v4 m9 
			rename v5 m10 
			rename v6 m11 
			rename v7 m12 
			rename v8 m1 
			rename v9 m2 
			rename v10 m3 
			rename v11 m4 
			rename v12 m5 
			rename v13 m6  
			rename v14 month_case_change 
			rename v15 month_percent_change 
			rename v16 year_case_change 
			rename v17 year_percent_change

			// split county number and name 
			split county, parse(" ")
			gen county_marker = 1
			replace county_marker = 0 if strpos(county,"region") // & strpos(county,"total") 
			replace county_marker = 0 if strpos(county,"state") & strpos(county,"total") 
			replace county_marker = 0 if strpos(county,"other") & strpos(county,"total")
			if `year' < 2022 {
				gen countycode = county1 if county_marker == 1
				destring countycode, replace	
				gen county_new = ""
				capture noisily replace county_new = county3 + " " + county4 if county_marker == 1
				capture noisily replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 if county_marker == 0
				capture noisily replace county_new = county3 + " " + county4 + " " + county5 if county_marker == 1
				capture noisily replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 if county_marker == 0
				capture noisily replace county_new = county3 + " " + county4 + " " + county5 + " " + county6 if county_marker == 1
				capture noisily replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 + " " + county6 if county_marker == 0
				replace county_new = trim(county_new)
				order county_marker county_new county countycode
				drop county county1 county2 county3 county4 
				capture drop county5 
				capture drop county6
				rename county_new county
			}
			else if inlist(`year',2022) {
				gen county_new = county 
				replace county_new = trim(county_new)
				order county_marker county_new county
				drop county county1 county2 county3 county4 
				capture drop county5
				capture drop county6
				rename county_new county 
			}

			// clean up one var 
			replace month_percent_change = "" if month_percent_change == "-"

		}

		// drop vars I don't need 
		drop month_case_change month_percent_change year_case_change year_percent_change 

		// destring 
		foreach var in countycode m7 m8 m9 m10 m11 m12 m1 m2 m3 m4 m5 m6 {
			
			capture confirm variable `var'
			if !_rc {

				// destring 
				capture replace `var' = ustrregexra(`var',"%","")
				destring `var', replace ignore("#")
			
				// assert variable is numeric
				confirm numeric variable `var'
			}
			else {
				display "variable `var' does not exist"
			}
		}

		// reshape 
		if inlist(`year',2022,2023) {
			reshape long m, i(county county_marker)
		}
		else {
			reshape long m, i(countycode county county_marker)
		}
		rename m households 
		rename _j month 

		// date 
		gen year = .
		replace year = `year' if inrange(month,7,12)
		replace year = `year_plus1' if inrange(month,1,6)
		gen ym = ym(year,month)
		format ym %tm 
		drop year month 
	
		// order and sort 
		order county county_marker ym households 
		capture order countycode
		sort county ym 		

		// save 
		tempfile _`year'_`page'_
		save `_`year'_`page'_'
 
		// restore
		restore

	}

	// append pages of data 
	display in red `num_pages'

	forvalues page = 1(1)`num_pages' { 
		if `page' == 1 { 
			use `_`year'_`page'_', clear 
		} 
		else { 
			append using `_`year'_`page'_' 			
		} 
	} 

	// order and sort 
	order county county_marker ym households 
	capture order countycode
	sort county ym 	

	// save 
	tempfile _`year' 
	save `_`year''

}

******************************************
forvalues year = `year_start_cases'(1)`year_end_cases' {
	if `year' == `year_start_cases' {
		use `_`year'', clear
	} 
	else {
		append using `_`year''
	}
}

// clean up
dropmiss, force 
dropmiss, obs force 

// clean up county manually 
replace county = "alexandria region totals" if strpos(county,"alexandria region")
replace county = "baton rouge region totals" if strpos(county,"baton rouge region")
replace county = "covington region totals" if strpos(county,"covington region")
replace county = "east baton rouge north" if strpos(county,"east baton rouge n") | strpos(county,"east baton rouge-n")
replace county = "east baton rouge south" if strpos(county,"east baton rouge s") | strpos(county,"east baton rouge-s")
replace county = "lafayette region totals" if strpos(county,"lafayette region")
replace county = "lake charles region totals" if strpos(county,"lake charles region")
replace county = "shreveport region totals" if strpos(county,"shreveport region")
replace county = "thibodaux region totals" if strpos(county,"thibodaux region")
replace county = "state totals" if county == "state total"
replace county = "sabine - many" if strpos(county,"sabine") & strpos(county,"many")
replace county = "sabine - zwolle" if strpos(county,"sabine") & strpos(county,"zwolle")
replace county = "orleans uptown" if county == "uptown"
replace county = "orleans gentilly" if county == "gentilly"
replace county = "orleans algiers" if county == "algiers"
replace county = "orleans midtown" if county == "midtown"
replace	county = "jefferson eastbank" if county == "east jefferson"
replace	county = "jefferson westbank" if county == "west jefferson"
// jefferson eastbank and jefferson westbank seemed to join into jefferson in 2015m7
// east baton rouge north and east baton rouge south seemed to join into east baton rouge in 2015m7
// sabine split into sabine many and sabine zwolle

// drop region totals 
drop if strpos(county,"region") | strpos(county,"totals")

// drop all missing obs 
dropmiss county countycode households, force obs 
assert !missing(county)

// sort and order 
order county ym 
sort county ym 

// save
tempfile louisiana_cases
save `louisiana_cases'
save "${dir_root}/data/state_data/louisiana/louisiana_cases.dta", replace 
check 
*/

****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
/*
forvalues year = `year_start_age'(1)`year_end_age' {
	
	display in red "`year'"

	if `year' == `year_end_age' {
		local month_num_end = 11 // change when more data is added
	}
	else {
		local month_num_end = 12
	}

	// for filenames
	local year_plus1 = `year' + 1
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

	// import
	import excel "${dir_root}/data/state_data/louisiana/excel/014_SNAP Recipients by Age/fy`yearnames'_FS_Age.xlsx", sheet("Table 1") allstring clear
	
	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	gen obsnum = _n

	if inlist(`year',2011,2012) {
	
		// rename variables 
		describe, varlist 
		assert r(k) == 5
		rename v1 county 
		rename v2 children
		rename v3 adults
		rename v4 individuals 
	
		// drop non data 
		replace county = trim(county)
		replace county = strlower(county)
		drop if county == "region 1 ‐ orleans"
 		drop if county == "region 2 ‐ baton rouge"
    	drop if county == "region 3 ‐ covington"
    	drop if county == "region 4 ‐ thibodaux"
    	drop if county == "region 5 ‐ lafayette"
		drop if county == "region 6 ‐ lake charles"
  		drop if county == "region 7 ‐ alexandria"
  		drop if county == "region 8 ‐ shreveport"
    	drop if county == "region 9 ‐ monroe"
	
    	// mark where data is a parish or not (there are also state totals and region totals)
    	gen county_marker = 1
    	replace county_marker = 0 if strpos(county,"region totals") | strpos(county,"state totals")
	
    	// 12 months of data, named correctly
    	bysort county (obsnum): assert _N == 12
		bysort county (obsnum): gen withincounty_obsnum = _n
		gen month = withincounty_obsnum
		recode month (1 = 7) (2 = 8) (3 = 9) (4 = 10) (5 = 11) (6 = 12) (7 = 1) (8 = 2) (9 = 3) (10 = 4) (11 = 5) (12 = 6)
		gen year = .
		replace year = `year' if inrange(month,7,12)
		replace year = `year_plus1' if inrange(month,1,6)
		gen ym = ym(year,month)
		format ym %tm 
		drop year month withincounty_obsnum obsnum
	
		// destring 
		foreach var in children adults individuals {
	
			// destring
			destring `var', replace
	
			// assert variable is numeric
			confirm numeric variable `var'
		}
	
		// sort and order 
		order county ym 
		sort county ym 
	
		// save 
		tempfile _`year'
		save `_`year''
	}
	else if inrange(`year',2020,`year_end_age') {
		
		drop if v1 == "PARISH"
		// drop non data 
		replace v1 = trim(v1)
		*forvalues numbers = 1(1)12 {
    	*	drop if strpos(v1,"`month_`numbers''")
    	*}
		replace v1 = strlower(v1)
		drop if strpos(v1,"region 1") // orleans
 		drop if strpos(v1,"region 2") // baton rouge
    	drop if strpos(v1,"region 3") // covington
    	drop if strpos(v1,"region 4") // thibodaux
    	drop if strpos(v1,"region 5") // lafayette
		drop if strpos(v1,"region 6") // lake charles
  		drop if strpos(v1,"region 7") // alexandria
  		drop if strpos(v1,"region 8") // shreveport
    	drop if strpos(v1,"region 9") // monroe
    	*drop if strpos(v1,"snap recipients by children and adults")
    	drop if strpos(v1,"parish")
    	*drop if v1 == "by children and adults"

		count
		*local target_obsnum = 84*`month_num_end'
		if inlist(`year',2020,2021) {
			local target_obsnum = 75*`month_num_end'
		}
		else if inlist(`year',2022) {
			local target_obsnum = 79*`month_num_end'
		}
		else if inlist(`year',2023) {
			local target_obsnum = 83*`month_num_end'
		}
		else {
			stop 
		}
		display in red "actual obsnum: " `r(N)'
		display in red "target obsnum: " `target_obsnum' 
		assert `r(N)' == `target_obsnum'

		forvalues month_num = 1(1)`month_num_end' {

			display in red "month_num `month_num'"

			// preserve 
			preserve 
	
			assert !missing(v1)
			rename v1 county 

			// months are listed in reverse order 
			bysort county (obsnum): gen tempmonth = _n 
			gen month = tempmonth
			if `month_num_end' == 12 {
				recode month (1=6) (2=5) (3=4) (4=3) (5=2) (6=1) (7=12) (8=11) (9=10) (10=9) (11=8) (12=7)	
			}
			else if `month_num_end' == 11 {
				recode month (1=5) (2=4) (3=3) (4=2) (5=1) (6=12) (7=11) (8=10) (9=9) (10=8) (11=7)
			}
			else if `month_num_end' == 10 {
				recode month (1=4) (2=3) (3=2) (4=1) (5=12) (6=11) (7=10) (8=9) (9=8) (10=7)
			}
			else if `month_num_end' == 7 {
				recode month (1=1) (2=12) (3=11) (4=10) (5=9) (6=8) (7=7) 
			}
			else {
				stop 
			}
			
			gen year = .
			replace year = `year' + 1 if inrange(month,1,6)
			replace year = `year'     if inrange(month,7,12)
			gen ym = ym(year,month)
			format ym %tm 
			drop year 
			drop month 

			// just keep data for that month
			keep if tempmonth == `month_num'
			drop tempmonth
			drop obsnum

			// clean up this data
			dropmiss, force 
			dropmiss, obs force 
			order ym 
				describe, varlist 
				rename (`r(varlist)') (v#), addnumber
			rename v1 ym 

			// rename variables 
			describe, varlist 
			assert r(k) == 5
			rename v2 county 
			rename v3 children
			rename v4 adults
			rename v5 individuals 

			// drop non data 
			*replace county = trim(county)
			*forvalues numbers = 1(1)12 {
    		*	drop if strpos(county,"`month_`numbers''")
    		*}
			*replace county = strlower(county)
			*drop if strpos(county,"region 1") // orleans
 			*drop if strpos(county,"region 2") // baton rouge
    		*drop if strpos(county,"region 3") // covington
    		*drop if strpos(county,"region 4") // thibodaux
    		*drop if strpos(county,"region 5") // lafayette
			*drop if strpos(county,"region 6") // lake charles
  			*drop if strpos(county,"region 7") // alexandria
  			*drop if strpos(county,"region 8") // shreveport
    		*drop if strpos(county,"region 9") // monroe
    		*drop if strpos(county,"snap recipients by children and adults")
    		*drop if strpos(county,"parish")
    		*drop if county == "by children and adults"

    		// mark where data is a parish or not (there are also state totals and region totals)
    		gen county_marker = 1
    		replace county_marker = 0 if strpos(county,"region totals") | strpos(county,"state totals") | strpos(county,"others totals")
				
			// destring 
			foreach var in children adults individuals {
		
				// destring
				destring `var', replace
		
				// assert variable is numeric
				confirm numeric variable `var'
			}
		
			// sort and order 
			order county ym 
			sort county ym 

			// save 
			tempfile _`year'_`month_num'
			save `_`year'_`month_num''

			// restore 
			restore 

		} // ends month loop
		
		// appends months within year
		forvalues month_num = 1(1)`month_num_end' {
			if `month_num' == 1 {
				use `_`year'_`month_num'', clear
			} 
			else {
				append using `_`year'_`month_num''
			}
		}

		// save year data 
		tempfile _`year'
		save `_`year''

	} // ends if else for years 2020, 2021, etc.

	else {

		forvalues month_num = 1(1)`month_num_end' {
			
			display in red "month_num `month_num'"

			// preserve 
			preserve 
	
			local month_num_plus1 = `month_num' + 1
		
			// mark observation numbers for this month
			sum obsnum if strpos(v1,"`month_`month_num''")
			assert r(N) == 2 // appears twice
			local begin_month = r(min) // use the first one
			if `month_num' == `month_num_end' {
				sum obsnum
				local end_month = r(max)
			}
			else {
				sum obsnum if strpos(v1,"`month_`month_num_plus1''")
				assert r(N) == 2 // appears twice
				local end_month = r(min) - 1 // use the first one
			}

			// just keep data for that month
			display in red "begin month obs `begin_month'"
			display in red "end month obs `end_month'"
			keep if inrange(obsnum,`begin_month',`end_month')
			drop obsnum

			// clean up this data
			dropmiss, force 
			dropmiss, obs force 
			describe, varlist 
			rename (`r(varlist)') (v#), addnumber
	
			// variable off by one slot
			replace v2 = v3 if missing(v2) & !missing(v3)
			replace v3 = "" if v2 == v3
			if r(k) > 4 {
				replace v4 = v5 if missing(v4) & !missing(v5)
				replace v5 = "" if v4 == v5
			}
			dropmiss, force 
			dropmiss, obs force 
			describe, varlist 
			rename (`r(varlist)') (v#), addnumber

			// rename variables 
			describe, varlist 
			assert r(k) == 4
			rename v1 county 
			rename v2 children
			rename v3 adults
			rename v4 individuals 

			// drop non data 
			replace county = trim(county)
			forvalues numbers = 1(1)12 {
    			drop if strpos(county,"`month_`numbers''")
    		}
			replace county = strlower(county)
			drop if strpos(county,"region 1") // orleans
 			drop if strpos(county,"region 2") // baton rouge
    		drop if strpos(county,"region 3") // covington
    		drop if strpos(county,"region 4") // thibodaux
    		drop if strpos(county,"region 5") // lafayette
			drop if strpos(county,"region 6") // lake charles
  			drop if strpos(county,"region 7") // alexandria
  			drop if strpos(county,"region 8") // shreveport
    		drop if strpos(county,"region 9") // monroe
    		drop if strpos(county,"snap recipients by children and adults")
    		drop if strpos(county,"parish")
    		drop if county == "by children and adults"

    		// mark where data is a parish or not (there are also state totals and region totals)
    		gen county_marker = 1
    		replace county_marker = 0 if strpos(county,"region totals") | strpos(county,"state totals") | strpos(county,"others totals")
	
    		// date 
    		display in red "`month_num'"
    		gen month = `month_num'
			recode month (1 = 7) (2 = 8) (3 = 9) (4 = 10) (5 = 11) (6 = 12) (7 = 1) (8 = 2) (9 = 3) (10 = 4) (11 = 5) (12 = 6)
			gen year = .
			replace year = `year' if inrange(month,7,12)
			replace year = `year_plus1' if inrange(month,1,6)
			gen ym = ym(year,month)
			format ym %tm 
			sum month
			assert r(min) == r(max)
			local month = r(mean)
			drop year month 
	
			// destring 
			foreach var in children adults individuals {
		
				// destring
				destring `var', replace
		
				// assert variable is numeric
				confirm numeric variable `var'
			}
		
			// sort and order 
			order county ym 
			sort county ym 

			// save 
			tempfile _`year'_`month_num'
			save `_`year'_`month_num''

			// restore 
			restore 

		} // ends month loop
	
		// appends months within year
		forvalues month_num = 1(1)`month_num_end' {
			if `month_num' == 1 {
				use `_`year'_`month_num'', clear
			} 
			else {
				append using `_`year'_`month_num''
			}
		}

		// save year data 
		tempfile _`year'
		save `_`year''

	} // ends else loop

} // ends year loop

******************************************
forvalues year = `year_start_age'(1)`year_end_age' {
	if `year' == `year_start_age' {
		use `_`year'', clear
	} 
	else {
		append using `_`year''
	}
}

// standardize county names 
gen county_new = ""
split county, parse(" ")
gen countycode = county1 if county_marker == 1 & !inrange(ym,ym(2022,7),ym(2024,5))
destring countycode, replace
confirm numeric variable countycode
replace county_new = county3 + " " + county4 + " " + county5 + " " + county6 if county_marker == 1 & !inrange(ym,ym(2022,7),ym(2024,5))
replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 + " " + county6 if county_marker == 0 & !inrange(ym,ym(2022,7),ym(2024,5))
replace county_new = county if inrange(ym,ym(2022,7),ym(2024,5))
replace county_new = trim(county_new)
order county_marker county_new county countycode
drop county county1 county2 county3 county4 county5 county6
rename county_new county

// manually clean up some county names 
replace county = "sabine - many" if strpos(county,"sabine") & strpos(county,"many")
replace county = "sabine - zwolle" if strpos(county,"sabine") & strpos(county,"zwolle")

// drop regions 
drop if inlist(county,"alexandria region totals","baton rouge region totals","covington region totals","lafayette region totals") | ///
		inlist(county,"lake charles region totals","monroe region totals","orleans region totals","others totals") | ///
		inlist(county,"shreveport region totals","thibodaux region totals")

// drop non observations
drop if strpos(county,"by children and adults")
drop if strpos(county,"march 202")
drop if strpos(county,"april 202")
drop if strpos(county,"may 202")
drop if strpos(county,"june 202")
drop if strpos(county,"july 202")
drop if strpos(county,"august 202")
drop if strpos(county,"september 202")
drop if strpos(county,"october 202")
drop if strpos(county,"november 202")
drop if strpos(county,"december 202")
drop if strpos(county,"january 202")
drop if strpos(county,"february 202")

// rename state total 
replace county = "total" if county == "state totals"

// sort and order 
order county ym 
sort county ym 

// save 
tempfile louisiana_age
save `louisiana_age'
save "${dir_root}/data/state_data/louisiana/louisiana_age.dta", replace 
*/
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
/*
// APPLICATIONS - state total 
forvalues year = `year_start_apps'(1)`year_end_apps' {
	
	display in red "`year'"

	if `year' == `year_end_apps' {
		local month_num_end = 11 // change when more data is added
	}
	else {
		local month_num_end = 12
	}

	// for filenames
	local year_plus1 = `year' + 1
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

	// import
	import excel "${dir_root}/data/state_data/louisiana/excel/007_Applications Processed by Month/fy`yearnames'_FS_Apps_Mon.xlsx", allstring clear
	
	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	qui describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	*gen obsnum = _n

	// drop titles 
	drop if strpos(v1,"STATE FISCAL YEAR")
	drop if strpos(v1,"Applications Received")
	drop if strpos(v1,"Applications Certified")
	drop if strpos(v1,"Applications Rejected")
	if `year' != 2022 {
		drop if strpos(v14,"Applications Received")	
	}
	dropmiss, force 
	dropmiss, obs force 
	qui describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// assert shape 
	qui describe, varlist 
	*local flex_target = (`month_num_end' + 3)*3
	*local flex_target = 30
	local flex_target = 14
	assert `r(N)' == 15 | `r(N)' == 45 | `r(N)' == `flex_target' 

	if `r(N)' == 15 {
		assert `r(k)' == 35 | `r(k)' == 27 | `r(k)' == 25 | `r(k)' == 24

		// drop average
		drop if _n == 15 | strpos(v1,"AVERAGE")
	
		// transpose data 
		// gen varname = ""
		// replace varname = "variable" if _n == 1
		// replace varname = "m7" if _n == 2
		// replace varname = "m8" if _n == 3
		// replace varname = "m9" if _n == 4
		// replace varname = "m10" if _n == 5
		// replace varname = "m11" if _n == 6
		// replace varname = "m12" if _n == 7
		// replace varname = "m1" if _n == 8
		// replace varname = "m2" if _n == 9
		// replace varname = "m3" if _n == 10
		// replace varname = "m4" if _n == 11
		// replace varname = "m5" if _n == 12
		// replace varname = "m6" if _n == 13
		// replace varname = "total" if _n == 14
		// order varname
		// sxpose, clear firstnames
		// drop total 
		
 
		// traspose data 
		// rewriting this code because sxpose is no longer available...
		gen id = _n 
		ds id, not 
 		reshape long v, i(id) j(which) string 
		reshape wide v, i(which) j(id) /*string*/
		destring which, replace 
		confirm numeric variable which 
		sort which 
		rename v1 variable 
		rename v2 m7 
		rename v3 m8 
		rename v4 m9
		rename v5 m10 
		rename v6 m11
		rename v7 m12
		rename v8 m1
		rename v9 m2 
		rename v10 m3
		rename v11 m4 
		rename v12 m5 
		rename v13 m6
		rename v14 total 
		drop total 
		drop which 

		// drop months rows
		drop if variable == "MONTH" | strpos(variable,"MONTH")
	
		// drop rows with percentage
		drop if strpos(variable,"% Cert")
		drop if strpos(variable,"% Rejected") | (strpos(variable,"Rej") & strpos(variable,"%"))
	
		// drop rows with percent increase / decrease
		drop if strpos(variable,"Inc") & strpos(variable,"Dec")
	
		// drop rows with lacap, snap  
		drop if strpos(variable,"LACAP")
		drop if strpos(variable,"SNAP")	
		drop if strpos(variable,"NP")
		drop if strpos(variable,"PA")
		drop if strpos(variable,"LCAP")

		// assert shape 
		qui describe, varlist 
		assert `r(N)' == 3
	
		// variable names 
		replace variable = strlower(variable)
		replace variable = "_received_" + variable if _n == 1
		replace variable = "_approved_" + variable if _n == 2
		replace variable = "_denied_" + variable if _n == 3
		replace variable = ustrregexra(variable,"_total","")
	
		// reshape long by months 
		reshape long m, i(variable) j(month)
		rename m value 
	
		// reshape wide by variables 
		rename value apps 
		reshape wide apps, i(month) j(variable) string
	
		// year
		gen year = .
		replace year = `year' if inrange(month,7,12)
		replace year = `year' + 1 if inrange(month,1,6)
	
		// ym 
		gen ym = ym(year,month)
		format ym %tm 
		drop year 
		drop month 
	
		// destring 
		foreach var in apps_approved apps_received apps_denied {
			destring `var', replace 
			confirm numeric variable `var' 
		}
	
		// county 
		gen county = "total"

	}
	else if `r(N)' == 45 {

		local page1_range "inrange(_n,1,15)"
		local page2_range "inrange(_n,16,30)"
		local page3_range "inrange(_n,31,45)"

		forvalues page = 1(1)3 {
	*	local page = 2
			display in red "page `page' of 3"

			// preserve
			preserve
			
			// keep observations 
			keep if `page`page'_range'

			// drop average
			drop if _n == 15 | strpos(v1,"AVERAGE")
			
			// drop total 
			drop if _n == 14 | strpos(v1,"TOTALS")

			// clean up 
			dropmiss, force 
			dropmiss, force obs 
			qui describe, varlist
			rename (`r(varlist)') (v#), addnumber

			// assert shape again 
			assert `r(N)' == 13
			assert inlist(`r(k)',7,9,10,13)
			if `r(k)' == 7 {
				local keepvar v6
			}
			else if inlist(`r(k)',9,10) {
				local keepvar v8 
			}
			else if inlist(`r(k)',13) {
				local keepvar v11
			}

			// gen month 
			gen month = .
			replace month = 7 if _n == 2
			replace month = 8 if _n == 3
			replace month = 9 if _n == 4
			replace month = 10 if _n == 5
			replace month = 11 if _n == 6
			replace month = 12 if _n == 7
			replace month = 1 if _n == 8
			replace month = 2 if _n == 9
			replace month = 3 if _n == 10
			replace month = 4 if _n == 11
			replace month = 5 if _n == 12
			replace month = 6 if _n == 13

			// year 
			gen year = .
			replace year = `year' if inrange(month,7,12)
			replace year = `year' + 1 if inrange(month,1,6)

			// ym 
			gen ym = ym(year,month)
			format ym %tm 
			drop year 
			drop month 

			// destring 
			drop in 1 
			foreach var in `keepvar' {
				destring `var', replace 
				confirm numeric variable `var' 
			}

			// keep variable I want 
			**assert `keepvar' = "TOTAL" if _n == 1
			keep ym `keepvar'
			if `page' == 1 {
				rename `keepvar' apps_received 	
			}
			else if `page' == 2 {
				rename `keepvar' apps_approved
			}
			else if `page' == 3 {
				rename `keepvar' apps_denied
			}
			
			// county 
			gen county = "total"

			// save 
			tempfile _`year'_page`page'
			save `_`year'_page`page''

			// restore 
			restore 

		}

		forvalues page = 1(1)3 {
			if `page' == 1 {
				use `_`year'_page`page'', clear
			}
			else {
				merge 1:1 county ym using `_`year'_page`page''
				assert _m == 3
				drop _m 
			}
		}
	}

	// year 2023, based on limited number of months 
	else if `r(N)' == `flex_target' {

		assert `flex_target' == 14
		
		// traspose data 
		// rewriting this code because sxpose is no longer available...
		gen id = _n 
		ds id, not 
 		reshape long v, i(id) j(which) string 
		reshape wide v, i(which) j(id) /*string*/
		destring which, replace 
		confirm numeric variable which 
		sort which 
		rename v1 variable 
		rename v2 m7 
		rename v3 m8 
		rename v4 m9
		rename v5 m10 
		rename v6 m11
		rename v7 m12
		rename v8 m1
		rename v9 m2 
		rename v10 m3
		rename v11 m4 
		rename v12 m5 
		rename v13 total 
		rename v14 average 
		drop total 
		drop average 
		drop which 
 
		// drop months rows
		drop if variable == "MONTH" | strpos(variable,"MONTH")
	
		// drop rows with percentage
		drop if strpos(variable,"% Cert")
		drop if strpos(variable,"% Rejected") | (strpos(variable,"Rej") & strpos(variable,"%"))
	
		// drop rows with percent increase / decrease
		drop if strpos(variable,"Inc") & strpos(variable,"Dec")
	
		// drop rows with lacap, snap  
		drop if strpos(variable,"LACAP")
		drop if strpos(variable,"SNAP")	
		drop if strpos(variable,"NP")
		drop if strpos(variable,"PA")
		drop if strpos(variable,"LCAP")

		// assert shape 
		qui describe, varlist 
		assert `r(N)' == 3
	
		// variable names 
		replace variable = strlower(variable)
		replace variable = "_received_" + variable if _n == 1
		replace variable = "_approved_" + variable if _n == 2
		replace variable = "_denied_" + variable if _n == 3
		replace variable = ustrregexra(variable,"_total","")
	
		// reshape long by months 
		reshape long m, i(variable) j(month)
		rename m value 
	
		// reshape wide by variables 
		rename value apps 
		reshape wide apps, i(month) j(variable) string
	
		// year
		gen year = .
		replace year = `year' if inrange(month,7,12)
		replace year = `year' + 1 if inrange(month,1,6)
	
		// ym 
		gen ym = ym(year,month)
		format ym %tm 
		drop year 
		drop month 
	
		// destring 
		foreach var in apps_approved apps_received apps_denied {
			destring `var', replace 
			confirm numeric variable `var' 
		}
	
		// county 
		gen county = "total"

	}

	// year 2022, based on limited number of months 
	else if `r(N)' == `flex_target' {

		assert `flex_target' == 30
		local page1_range "inrange(_n,1,10)"
		local page2_range "inrange(_n,11,20)"
		local page3_range "inrange(_n,21,30)"

		forvalues page = 1(1)3 {
	*	local page = 2
			display in red "page `page' of 3"

			// preserve
			preserve
			
			// keep observations 
			keep if `page`page'_range'

			// drop average
			drop if /*_n == 15 |*/ strpos(v1,"AVERAGE")
			
			// drop total 
			drop if /*_n == 14 |*/ strpos(v1,"TOTALS")

			// clean up 
			dropmiss, force 
			dropmiss, force obs 
			qui describe, varlist
			rename (`r(varlist)') (v#), addnumber

			// assert shape again 
			local N_target = `month_num_end' + 1
			*assert `r(N)' == 13
			assert `r(N)' == `N_target'
			assert inlist(`r(k)',7,9,10,13)
			if `r(k)' == 7 {
				local keepvar v6
			}
			else if inlist(`r(k)',9,10) {
				local keepvar v8 
			}
			else if inlist(`r(k)',13) {
				local keepvar v11
			}

			// gen month 
			gen month = .
			replace month = 7 if _n == 2
			replace month = 8 if _n == 3
			replace month = 9 if _n == 4
			replace month = 10 if _n == 5
			replace month = 11 if _n == 6
			replace month = 12 if _n == 7
			replace month = 1 if _n == 8
			replace month = 2 if _n == 9
			replace month = 3 if _n == 10
			replace month = 4 if _n == 11
			replace month = 5 if _n == 12
			replace month = 6 if _n == 13

			// year 
			gen year = .
			replace year = `year' if inrange(month,7,12)
			replace year = `year' + 1 if inrange(month,1,6)

			// ym 
			gen ym = ym(year,month)
			format ym %tm 
			drop year 
			drop month 

			// destring 
			drop in 1 
			foreach var in `keepvar' {
				destring `var', replace 
				confirm numeric variable `var' 
			}

			// keep variable I want 
			**assert `keepvar' = "TOTAL" if _n == 1
			keep ym `keepvar'
			if `page' == 1 {
				rename `keepvar' apps_received 	
			}
			else if `page' == 2 {
				rename `keepvar' apps_approved
			}
			else if `page' == 3 {
				rename `keepvar' apps_denied
			}
			
			// county 
			gen county = "total"

			// save 
			tempfile _`year'_page`page'
			save `_`year'_page`page''

			// restore 
			restore 

		}

		forvalues page = 1(1)3 {
			if `page' == 1 {
				use `_`year'_page`page'', clear
			}
			else {
				merge 1:1 county ym using `_`year'_page`page''
				assert _m == 3
				drop _m 
			}
		}
	}

	// order and sort 
	order county ym apps_received* apps_approved* apps_denied*
	sort county ym 

	// save 
	tempfile _`year'_apps
	save `_`year'_apps'

}
******************************************
forvalues year = `year_start_apps'(1)`year_end_apps' {
	if `year' == `year_start_apps' {
		use `_`year'_apps', clear
	} 
	else {
		append using `_`year'_apps'
	}
}

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// sort and order 
order county ym 
sort county ym 

// save 
tempfile louisiana_apps
save `louisiana_apps'
save "${dir_root}/data/state_data/louisiana/louisiana_apps.dta", replace 
check 
*/

****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
/*
// APPLICATIONS 
forvalues year = `year_start_apps_county'(1)`year_end_apps_county' {
	
	display in red "`year'"

	if `year' == `year_end_apps_county' {
		local month_num_end = 11 // change when more data is added
	}
	else {
		local month_num_end = 12
	}

	// list of months 
	if `month_num_end' == 12 {
		local monthlist 7 8 9 10 11 12 1 2 3 4 5 6
	}
	else if `month_num_end' == 11 {
		local monthlist 7 8 9 10 11 12 1 2 3 4 5
	}
	else {
		stop 
	}

	// local approx obs per month 
	if `year' == 2004 {
		local obs_perpage_approx = 87	
	}
	else if `year' == 2005 {
		local obs_perpage_approx = 88
	}
	else if inrange(`year',2006,2012) {
		local obs_perpage_approx = 86
	}
	else if inrange(`year',2013,2015) {
		local obs_perpage_approx = 87
	}
	else if inrange(`year',2016,2018) {
		local obs_perpage_approx = 83
	}
	else if inrange(`year',2019,2022) {
		local obs_perpage_approx = 84
	}
	else if `year' == 2023 {
		local obs_perpage_approx = 88
	}
	else {
		stop 
	}
	
	// for filenames
	local year_plus1 = `year' + 1
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

	// split by months 
	forvalues month = 1(1)`month_num_end' {
*local month = 5

		// display
		display in red "year `year'"
		display in red "month `month'"

		// import
		import excel "${dir_root}/data/state_data/louisiana/excel/005_Applications Processed/fy`yearnames'_FS_Apps.xlsx", sheet("Table 1") firstrow case(lower) allstring clear
		dropmiss, force
		dropmiss, force obs 
		qui describe, varlist
		rename (`r(varlist)') (v#), addnumber

		// clean when columns aren't broken apart 
*		preserve
		*keep if strpos(v1,"East Baton Rouge North") & strpos(v1,"East Feliciana")
		*dropmiss, force 
		*dropmiss, force obs 
		*rename v1 vA
		*rename v2 vB
		*split vA, parse("`char(10)'")
		**split vB, parse("`char(13)'")
		**split vA, parse("`char(13)'")
		*split vB, parse("\254d")
		*restore

		// drop before adding obsnum 
		drop if v1 == "PARISH"
		drop if v5 == "NP"
		drop if v4 == "NP" & missing(v1) // 2007
		drop if v3 == "NP" & missing(v1) // 2007
		drop if v2 == "NP" & missing(v1) // 2008
		drop if v6 == "NP" & missing(v1) // 2008
		drop if v7 == "NP" & missing(v1) // 2008
		drop if strpos(v1,"Applications Received") // 2005-
		drop if strpos(v12,"Applications Received") // 2006-
		drop if strpos(v1,"PARISH") & strpos(v1,"LaCAP")
		drop if strpos(v4,"Applications Received") // 2007-
		drop if strpos(v5,"Applications Received") // 2007-
		drop if strpos(v6,"Applications Received") // 2007-
		drop if strpos(v1," 2013") // 2013
		drop if strpos(v1," 2014") // 2013
		drop if strpos(v1," 2015") // 2015
		drop if strpos(v1," 2016") // 201
		drop if strpos(v1," 2017") // 201
		drop if strpos(v1," 2018") // 201
		drop if strpos(v1," 2019") // 201
		drop if strpos(v1," 2020") // 201
		drop if strpos(v1," 2021") // 201
		drop if strpos(v1," 2022") // 201
		drop if strpos(v1," 2023")
		drop if strpos(v1," 2024")
		drop if v1 == "SNAP APPLICATIONS PROCESSED"
		drop if strpos(v9,"SNAP APPLICATIONS PROCESSED") // 2014
		drop if strpos(v10,"SNAP APPLICATIONS PROCESSED") // 2014
		capture confirm variable v13 
		if !_rc {
			drop if strpos(v13,"SNAP APPLICATIONS PROCESSED") // 2014	
		}
		drop if strpos(v6,"SNAP APPLICATIONS PROCESSED") // 2015
		drop if strpos(v7,"SNAP APPLICATIONS PROCESSED") // 2015
		drop if missing(v1) & v4 == "0" & v9 == "0" // 2019
		drop if v4 == "SNAP" & v9 == "SNAP" // 2019
		drop if v2 == "SNAP" & v5 == "SNAP" // 2020
		list if missing(v1)
		assert !missing(v1)
		gen obsnum = _n

		// determine shape 
		local target_obsnum = `month_num_end'*`obs_perpage_approx'
		count 
		display in red "actual obs: " `r(N)'
		display in red "target obs: " `target_obsnum'
		assert `r(N)' == `target_obsnum'
	
		// county
		replace v1 = trim(v1)
		replace v1 = strlower(v1)

   		// mark where data is a parish or not (there are also state totals and region totals)
   		gen county_marker = 1
		replace county_marker = 0 if strpos(v1,"region") & strpos(v1,"total") 
		replace county_marker = 0 if strpos(v1,"state") & strpos(v1,"total") 
		replace county_marker = 0 if strpos(v1,"other") & strpos(v1,"total")
		replace county_marker = 0 if strpos(v1,"region i ")
		replace county_marker = 0 if strpos(v1,"region ii ")
		replace county_marker = 0 if strpos(v1,"region iii ")
		replace county_marker = 0 if strpos(v1,"region iv ")
		replace county_marker = 0 if strpos(v1,"region v ")
		replace county_marker = 0 if strpos(v1,"region vi ")
		replace county_marker = 0 if strpos(v1,"region vii ")
		replace county_marker = 0 if strpos(v1,"region viii ")
		replace county_marker = 0 if strpos(v1,"region iv ")
		replace county_marker = 0 if strpos(v1,"region 1 ")
		replace county_marker = 0 if strpos(v1,"region 2 ")
		replace county_marker = 0 if strpos(v1,"region 3 ")
		replace county_marker = 0 if strpos(v1,"region 4 ")
		replace county_marker = 0 if strpos(v1,"region 5 ")
		replace county_marker = 0 if strpos(v1,"region 6 ")
		replace county_marker = 0 if strpos(v1,"region 7 ")
		replace county_marker = 0 if strpos(v1,"region 8 ")
		replace county_marker = 0 if strpos(v1,"region 9 ")

	
		// mark where to start looking for data 
		local start_data_obsnum = (`month' - 1)*`obs_perpage_approx'
		drop if obsnum <= `start_data_obsnum'
		local end_data_obsnum = (`month' - 0)*`obs_perpage_approx'
		drop if obsnum >  `end_data_obsnum'

		// mark beginning and ends of pages  
		if `year' == 2004 {
			local num_pages = 4
			sum obsnum if strpos(v1,"region i") & strpos(v1,"southeast")
			assert `r(N)' == 1
			local page1_begin = `r(min)'
			sum obsnum if strpos(v1,"region ii total")
			assert `r(N)' == 1
			local page1_end = `r(min)'
			sum obsnum if strpos(v1,"region iii") & strpos(v1,"thibodaux")
			assert `r(N)' == 1
			local page2_begin = `r(min)'
			sum obsnum if strpos(v1,"region iv total") 
			assert `r(N)' == 1
			local page2_end = `r(min)'
			sum obsnum if strpos(v1,"region v") & strpos(v1,"acadiana")
			assert `r(N)' == 1
			local page3_begin = `r(min)'
			sum obsnum if strpos(v1,"region vi total") 
			assert `r(N)' == 1
			local page3_end = `r(min)'
			sum obsnum if strpos(v1,"region vii") & strpos(v1,"shreveport")
			assert `r(N)' == 1
			local page4_begin = `r(min)'
			sum obsnum if strpos(v1,"state total") 
			assert `r(N)' == 1
			local page4_end = `r(min)'		
		}
		else if `year' >= 2005 {
			local num_pages = 5
			sum obsnum if strpos(v1,"region 1") & strpos(v1,"orleans")
			assert `r(N)' == 1
			local page1_begin = `r(min)'
			sum obsnum if strpos(v1,"baton rouge region totals")
			assert `r(N)' == 1
			local page1_end = `r(min)'
			sum obsnum if strpos(v1,"region 3") & strpos(v1,"covington")
			assert `r(N)' == 1
			local page2_begin = `r(min)'
			sum obsnum if strpos(v1,"thibodaux region totals") 
			assert `r(N)' == 1
			local page2_end = `r(min)'
			sum obsnum if strpos(v1,"region 5") & strpos(v1,"lafayette")
			assert `r(N)' == 1
			local page3_begin = `r(min)'
			sum obsnum if strpos(v1,"lake charles region totals") 
			assert `r(N)' == 1
			local page3_end = `r(min)'
			sum obsnum if strpos(v1,"region 7") & strpos(v1,"alexandria")
			assert `r(N)' == 1
			local page4_begin = `r(min)'
			sum obsnum if strpos(v1,"shreveport region totals") 
			assert `r(N)' == 1
			local page4_end = `r(min)'	
			sum obsnum if strpos(v1,"region 9") & strpos(v1,"monroe")
			assert `r(N)' == 1
			local page5_begin = `r(min)'
			sum obsnum if strpos(v1,"state totals") 
			assert `r(N)' == 1
			local page5_end = `r(min)'	
		}


		// split into pages 
		forvalues p = 1(1)`num_pages' {
*local p = 5
			// display
			display in red "year `year'"
			display in red "month `month'"
			display in red "page `p' of `num_pages'"

			// preserve 
			preserve

			// keep just this page 
			keep if inrange(obsnum,`page`p'_begin',`page`p'_end')
			
			// clean up 
			dropmiss, force 
			dropmiss, force obs 
			qui describe, varlist
			rename (`r(varlist)') (v#), addnumber
			
			// assert size 
			if `year' == 2004 & `p' == 1 {
				assert `r(N)' == 19		
				assert `r(k)' == 15 | `r(k)' == 14
			}
			else if `year' == 2004 & `p' == 2 {
				assert `r(N)' == 18
				assert `r(k)' == 15 | `r(k)' == 14
			}
			else if `year' == 2004 & `p' == 3 {
				assert `r(N)' == 26
				assert `r(k)' == 15 | `r(k)' == 14
			}
			else if `year' == 2004 & `p' == 4 {
				assert `r(N)' == 24
				assert `r(k)' == 15 | `r(k)' == 14
			}	
			if (`year' == 2005 | (`year' == 2006 & inrange(`month',1,5))) {
				assert `r(k)' == 15 | `r(k)' == 14
			}
			else if (`year' == 2006 & inrange(`month',6,12)) | (inrange(`year',2007,2018)) {
				assert `r(k)' == 17
			}
			else if (inrange(`year',2019,2023)) {
				assert `r(k)' == 20 | `r(k)' == 14
			}
			else {
				stop 
			}

			if `r(k)' == 15 {
				// rename vars 
				rename v1 countycode 
				rename v2 county 
				rename v3 apps_received_npa
				rename v4 apps_received_pa
				rename v5 apps_received 
				rename v6 apps_approved_npa
				rename v7 apps_approved_pa
				rename v8 apps_approved
				rename v9 apps_denied_npa
				rename v10 apps_denied_pa
				rename v11 apps_denied
				rename v12 apps_approved_perc
				rename v13 apps_denied_perc
				rename v14 obsnum
				rename v15 county_marker 	
			}
			else if `r(k)' == 14 & `year' < 2019 {
				// rename vars 
				rename v1 county 
				rename v2 apps_received_npa
				rename v3 apps_received_pa
				rename v4 apps_received 
				rename v5 apps_approved_npa
				rename v6 apps_approved_pa
				rename v7 apps_approved
				rename v8 apps_denied_npa
				rename v9 apps_denied_pa
				rename v10 apps_denied
				rename v11 apps_approved_perc
				rename v12 apps_denied_perc
				rename v13 obsnum
				rename v14 county_marker 

				// split v1 into county and county code 
				gen county_new = ""
				split county, parse(" ")
				gen countycode = county1 if county_marker == 1
				destring countycode, replace
				confirm numeric variable countycode
				capture gen county5 = ""
				replace county_new = county3 + " " + county4 + " " + county5 if county_marker == 1
				replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 if county_marker == 0
				replace county_new = trim(county_new)
				order county_marker county_new county countycode
				drop county county1 county2 county3 county4 county5
				rename county_new county
			
			}
			else if `r(k)' == 17 {
				// rename vars 
				rename v1 county 
				rename v2 apps_received_npa
				rename v3 apps_received_pa
				rename v4 apps_received_lacap 
				rename v5 apps_received
				rename v6 apps_approved_npa
				rename v7 apps_approved_pa
				rename v8 apps_approved_lacap
				rename v9 apps_approved
				rename v10 apps_denied_npa
				rename v11 apps_denied_pa
				rename v12 apps_denied_lacap
				rename v13 apps_denied
				rename v14 apps_approved_perc
				rename v15 apps_denied_perc
				rename v16 obsnum
				rename v17 county_marker

				// split v1 into county and county code 
				gen county_new = ""
				split county, parse(" ")
				gen countycode = county1 if county_marker == 1
				destring countycode, replace
				confirm numeric variable countycode
				capture gen county5 = ""
				replace county_new = county3 + " " + county4 + " " + county5 if county_marker == 1
				replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 if county_marker == 0
				replace county_new = trim(county_new)
				order county_marker county_new county countycode
				drop county county1 county2 county3 county4 county5
				rename county_new county
			
			}	

			else if `r(k)' == 20 {
				// rename vars 
				rename v1 county 
				rename v2 apps_received_npa
				rename v3 apps_received_pa
				rename v4 apps_received_snap 
				rename v5 apps_received_lacap
				rename v6 apps_received
				rename v7 apps_approved_npa
				rename v8 apps_approved_pa
				rename v9 apps_approved_snap
				rename v10 apps_approved_lacap
				rename v11 apps_approved
				rename v12 apps_denied_npa
				rename v13 apps_denied_pa
				rename v14 apps_denied_snap
				rename v15 apps_denied_lacap
				rename v16 apps_denied
				rename v17 apps_approved_perc
				rename v18 apps_denied_perc
				rename v19 obsnum 
				rename v20 county_marker

				// split v1 into county and county code 
				gen county_new = ""
				split county, parse(" ")
				gen countycode = county1 if county_marker == 1
				destring countycode, replace
				confirm numeric variable countycode
				capture gen county5 = ""
				replace county_new = county3 + " " + county4 + " " + county5 if county_marker == 1
				replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 if county_marker == 0
				replace county_new = trim(county_new)
				order county_marker county_new county countycode
				drop county county1 county2 county3 county4 county5
				rename county_new county
			
			}	
			else if `r(k)' == 14 & inrange(`year',2019,2021) {
				// rename vars 
				rename v1 county 
				rename v2 apps_received_snap
				rename v3 apps_received_lacap
				rename v4 apps_received 
				rename v5 apps_approved_snap
				rename v6 apps_approved_lacap
				rename v7 apps_approved
				rename v8 apps_denied_snap
				rename v9 apps_denied_lacap
				rename v10 apps_denied
				rename v11 apps_approved_perc
				rename v12 apps_denied_perc
				rename v13 obsnum
				rename v14 county_marker 

				// split v1 into county and county code 
				gen county_new = ""
				split county, parse(" ")
				gen countycode = county1 if county_marker == 1
				destring countycode, replace
				confirm numeric variable countycode
				capture gen county5 = ""
				replace county_new = county3 + " " + county4 + " " + county5 if county_marker == 1
				replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 if county_marker == 0
				replace county_new = trim(county_new)
				order county_marker county_new county countycode
				drop county county1 county2 county3 county4 county5
				rename county_new county
			
			}
			else if `r(k)' == 14 & inlist(`year',2022,2023) {
				// rename vars 
				rename v1 county 
				rename v2 apps_received_snap
				rename v3 apps_received_lacap
				rename v4 apps_received 
				rename v5 apps_approved_snap
				rename v6 apps_approved_lacap
				rename v7 apps_approved
				rename v8 apps_denied_snap
				rename v9 apps_denied_lacap
				rename v10 apps_denied
				rename v11 apps_approved_perc
				rename v12 apps_denied_perc
				rename v13 obsnum
				rename v14 county_marker 
		
			}
			// drop non data 
			drop if county == "parish"
			drop if strpos(county,"region i") & strpos(county,"southeast")
			drop if strpos(county,"region ii") & strpos(county,"baton rouge")
			drop if strpos(county,"region iii") & strpos(county,"thibodaux")
			drop if strpos(county,"region iv") & strpos(county,"new orleans")
			drop if strpos(county,"region v") & strpos(county,"acadiana")
			drop if strpos(county,"region vi") & strpos(county,"alexandria")
			drop if strpos(county,"region vii") & strpos(county,"shreveport")
			drop if strpos(county,"region viii") & strpos(county,"monroe")
			drop if strpos(county,"region i") & strpos(county,"total")
			drop if strpos(county,"region ii") & strpos(county,"total")
			drop if strpos(county,"region iii") & strpos(county,"total")
			drop if strpos(county,"region iv") & strpos(county,"total")
			drop if strpos(county,"region v") & strpos(county,"total")
			drop if strpos(county,"region vi") & strpos(county,"total")
			drop if strpos(county,"region vii") & strpos(county,"total")
			drop if strpos(county,"region viii") & strpos(county,"total")
			drop if strpos(county,"region 1") & strpos(county,"totals")
			drop if strpos(county,"region 2") & strpos(county,"totals")
			drop if strpos(county,"region 3") & strpos(county,"totals")
			drop if strpos(county,"region 4") & strpos(county,"totals")
			drop if strpos(county,"region 5") & strpos(county,"totals")
			drop if strpos(county,"region 6") & strpos(county,"totals")
			drop if strpos(county,"region 7") & strpos(county,"totals")
			drop if strpos(county,"region 8") & strpos(county,"totals")
			drop if strpos(county,"region 1") & strpos(county,"orleans")
			drop if strpos(county,"region 2") & strpos(county,"baton rouge")
			drop if strpos(county,"region 3") & strpos(county,"covington")
			drop if strpos(county,"region 4") & strpos(county,"thibodaux")
			drop if strpos(county,"region 5") & strpos(county,"lafayette")
			drop if strpos(county,"region 6") & strpos(county,"lake charles")
			drop if strpos(county,"region 7") & strpos(county,"alexandria")
			drop if strpos(county,"region 8") & strpos(county,"shreveport")
			drop if strpos(county,"region 9") & strpos(county,"monroe")

		
			// clean up county 
			replace county = trim(county)
			replace county = strlower(county)
	
			// destring 
			foreach var in apps_received_npa apps_received_pa apps_received apps_approved_npa apps_approved_pa apps_approved apps_denied_npa apps_denied_pa apps_denied apps_approved_perc apps_denied_perc apps_approved_snap apps_denied_snap apps_received_snap apps_approved_lacap apps_denied_lacap apps_received_lacap {
				capture confirm variable `var' 
				if !_rc {
					replace `var' = ustrregexra(`var',"\-","")
					replace `var' = ustrregexra(`var',"#DIV/0!","")
					replace `var' = ustrregexra(`var',"NA","")
					destring `var', replace 
					confirm numeric variable `var'			
				}
			}

			// date 
			gen month = `month'
			recode month (1 = 7) (2 = 8) (3 = 9) (4 = 10) (5 = 11) (6 = 12) (7 = 1) (8 = 2) (9 = 3) (10 = 4) (11 = 5) (12 = 6)
			gen year = .
			replace year = `year' if inrange(month,7,12)
			replace year = `year_plus1' if inrange(month,1,6)
			gen ym = ym(year,month)
			format ym %tm 
			drop year month obsnum

			// order and sort 
			order county ym
			capture order countycode 
			sort county ym 

			// save 
			tempfile _`year'_`month'_`p'
			save `_`year'_`month'_`p''

			// restore 
			restore

		} // end of page loop 

		// append across pages 
		forvalues p = 1(1)`num_pages' {
			if `p' == 1 {
				use `_`year'_`month'_`p'', clear 
			}
			else {
				append using `_`year'_`month'_`p''
			}
		}

		// save 
		tempfile _`year'_`month'
		save `_`year'_`month''

	} // end of month loop 

	// append across months 
	forvalues month = 1(1)`month_num_end' {
		if `month' == 1 {
			use `_`year'_`month'', clear 
		}
		else {
			append using `_`year'_`month''
		}
	}

	// save 
	tempfile _`year'
	save `_`year''

} // end of year loop 

*********************************************************

// append all years 
forvalues year = `year_start_apps_county'(1)`year_end_apps_county' {
	if `year' == `year_start_apps_county' {
		use `_`year'', clear
	} 
	else {
		append using `_`year''
	}
}

// manually clean up some county names 
*replace county = "sabine - many" if strpos(county,"sabine") & strpos(county,"many")
*replace county = "sabine - zwolle" if strpos(county,"sabine") & strpos(county,"zwolle")

// drop regions 
drop if inlist(county,"alexandria region totals","baton rouge region totals","covington region totals","lafayette region totals") | ///
		inlist(county,"lake charles region totals","monroe region totals","orleans region totals","others totals") | ///
		inlist(county,"shreveport region totals","thibodaux region totals")

// rename state total 
replace county = "total" if county == "state totals"

// sort and order 
order county ym 
sort county ym 

// save 
tempfile louisiana_apps_county
save `louisiana_apps_county'
save "${dir_root}/data/state_data/louisiana/louisiana_apps_county.dta", replace 
check
*/
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************


// append statewide data to county data 
use "${dir_root}/data/state_data/louisiana/louisiana_cases.dta", clear 
append using "${dir_root}/data/state_data/louisiana/louisiana_state.dta"
merge 1:1 county ym using "${dir_root}/data/state_data/louisiana/louisiana_age.dta"
drop _m 
merge 1:1 county ym using "${dir_root}/data/state_data/louisiana/louisiana_apps.dta"
drop _m
merge 1:1 county ym using "${dir_root}/data/state_data/louisiana/louisiana_apps_county.dta", update 
drop _m
merge 1:1 county ym using "${dir_root}/data/state_data/louisiana/louisiana_closure_group_total.dta"
drop _m
merge 1:1 county ym using "${dir_root}/data/state_data/louisiana/louisiana_closure_group_heading.dta"
drop _m
merge 1:1 county ym using "${dir_root}/data/state_data/louisiana/louisiana_closure_group_fine.dta"
drop _m

// drop missing observations
#delimit ;
dropmiss county countycode households individuals avg_indiv_per_hh issuance avg_payment hh_with_earnedinc avg_earnedinc_per_hh children adults
apps_received
apps_approved
apps_denied
, force obs
;
#delimit cr 
assert !missing(county)

// order and sort
order county ym 
sort county ym 

// save 
save "${dir_root}/data/state_data/louisiana/louisiana.dta", replace 
check

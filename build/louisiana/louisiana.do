// louisiana.do 
// Kelsey Pukelis

// statewide part 
local year_start_part1			= 1987 
local year_end_part1			= 2006
local year_start_part2			= 2007 
local year_end_part2			= 2019

// cases part 
local year_start_cases			= 2000 
local year_end_cases			= 2019
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

// age part.do 
local year_start_age			= 2011
local year_end_age				= 2021
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

// apps part 
local year_start_apps			= 2018 // 2004
local year_end_apps				= 2021 


********************************************************************
// STATE TOTALS 1987-2006
// Part 1

// import
import excel "${dir_root}/data/state_data/louisiana/excel/FS_SFY_Totals.xlsx", sheet("Table 1") allstring clear

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
gen county = "total"
tempfile louisiana_state
save `louisiana_state'

*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************


********************************************************************

forvalues year = `year_start_cases'(1)`year_end_cases' {
	
	display in red "`year'"

	if `year' == 2019 {
		local month_num_end = 9 // change when more data is added
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
	else if inrange(`year',2013,2019) {
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
		else if `year' == 2019 {
			assert r(k) == 14
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
			gen m4 = ""
			gen m5 = ""
			gen m6 = ""
			rename v11 month_case_change 
			rename v12 month_percent_change 
			rename v13 year_case_change 
			rename v14 year_percent_change
			
			// split county number and name 
			split county, parse(" ")
			gen county_marker = 1
			replace county_marker = 0 if strpos(county,"region") // & strpos(county,"total") 
			replace county_marker = 0 if strpos(county,"state") & strpos(county,"total") 
			replace county_marker = 0 if strpos(county,"other") & strpos(county,"total")
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

			// clean up one var 
			replace month_percent_change = "" if month_percent_change == "-"

		}

		// drop vars I don't need 
		drop month_case_change month_percent_change year_case_change year_percent_change 

		// destring 
		foreach var in countycode m7 m8 m9 m10 m11 m12 m1 m2 m3 m4 m5 m6 {
			
			// destring 
			capture replace `var' = ustrregexra(`var',"%","")
			destring `var', replace ignore("#")
			
			// assert variable is numeric
			confirm numeric variable `var'
		}

		// reshape 
		reshape long m, i(countycode county county_marker)
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
		order countycode county county_marker ym households 
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
	order countycode county county_marker ym households 
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

// sort and order 
order county ym 
sort county ym 

// save
tempfile louisiana_cases
save `louisiana_cases'

****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************

forvalues year = `year_start_age'(1)`year_end_age' {
	
	display in red "`year'"

	if `year' == 2021 {
		local month_num_end = 10 // change when more data is added
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
	else if inlist(`year',2020,2021) {
		
		drop if v1 == "PARISH"
		count
		local target_obsnum = 84*`month_num_end'
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
			else {
				recode month (1=4) (2=3) (3=2) (4=1) (5=12) (6=11) (7=10) (8=9) (9=8) (10=7)
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
gen countycode = county1 if county_marker == 1
destring countycode, replace
confirm numeric variable countycode
replace county_new = county3 + " " + county4 + " " + county5 + " " + county6 if county_marker == 1
replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 + " " + county6 if county_marker == 0
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

// rename state total 
replace county = "total" if county == "state totals"

// sort and order 
order county ym 
sort county ym 

// save 
tempfile louisiana_age
save `louisiana_age'

****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************

// APPLICATIONS 

forvalues year = `year_start_apps'(1)`year_end_apps' {
	
	display in red "`year'"

	if `year' == 2021 {
		local month_num_end = 10 // change when more data is added
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




	// just get state total for now
	if `year' <= 2018 {

		// import
		import excel "${dir_root}/data/state_data/louisiana/excel/005_Applications Processed/fy`yearnames'_FS_Apps.xlsx", sheet("stateonly") firstrow case(lower) allstring clear
		dropmiss, force
		
		// county
		replace county = trim(county)
		replace county = strlower(county)
		
	   	// mark where data is a parish or not (there are also state totals and region totals)
	   	gen county_marker = 1
	   	replace county_marker = 0 if strpos(county,"region totals") | strpos(county,"state totals")

		// ym 
		destring year, replace
		destring month, replace 
		confirm numeric variable year 
		confirm numeric variable month 
		gen ym = ym(year,month)
		format ym %tm 
		drop year month
		order ym, after(county)

		// destring 
		foreach var of varlist apps_* {

			// destring
			destring `var', replace

			// assert variable is numeric
			confirm numeric variable `var'
		}

	}
	else {
		
		// import
		import excel "${dir_root}/data/state_data/louisiana/excel/005_Applications Processed/fy`yearnames'_FS_Apps.xlsx", allstring clear

		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		gen obsnum = _n

		// rename vars 
		if inlist(`year',2019) {
			describe, varlist
			assert `r(k)' == 19
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
		}
		else {
			describe, varlist
			assert `r(k)' == 13
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
		}


		// drop non data 
		replace county = trim(county)
		replace county = strlower(county)
		drop if county == "parish"
		drop if county == ""
		drop if county == "region 1 ‐ orleans"
	 	drop if county == "region 2 ‐ baton rouge"
	    drop if county == "region 3 ‐ covington"
	    drop if county == "region 4 ‐ thibodaux"
	    drop if county == "region 5 ‐ lafayette"
		drop if county == "region 6 ‐ lake charles"
	  	drop if county == "region 7 ‐ alexandria"
	  	drop if county == "region 8 ‐ shreveport"
	    drop if county == "region 9 ‐ monroe"
	    drop if county == "others totals"
		drop if strpos(county,"region 1") & strpos(county,"orleans")
		drop if strpos(county,"region 2") & strpos(county,"baton rouge")
		drop if strpos(county,"region 3") & strpos(county,"covington")
		drop if strpos(county,"region 4") & strpos(county,"thibodaux")
		drop if strpos(county,"region 5") & strpos(county,"lafayette")
		drop if strpos(county,"region 6") & strpos(county,"lake charles")
		drop if strpos(county,"region 7") & strpos(county,"alexandria")
		drop if strpos(county,"region 8") & strpos(county,"shreveport")
		drop if strpos(county,"region 9") & strpos(county,"monroe")

	   	// mark where data is a parish or not (there are also state totals and region totals)
	   	gen county_marker = 1
	   	replace county_marker = 0 if strpos(county,"region totals") | strpos(county,"state totals")
		
	    // 12 months of data, named correctly
	    if `year' != 2021 {
	    	bysort county (obsnum): assert _N == 12	
	    }
	    else {
	    	bysort county (obsnum): assert _N == `month_num_end'
	    }
		bysort county (obsnum): gen withincounty_obsnum = _n
		gen month = withincounty_obsnum
		recode month (1 = 7) (2 = 8) (3 = 9) (4 = 10) (5 = 11) (6 = 12) (7 = 1) (8 = 2) (9 = 3) (10 = 4) (11 = 5) (12 = 6)
		gen year = .
		replace year = `year' if inrange(month,7,12)
		replace year = `year_plus1' if inrange(month,1,6)
		gen ym = ym(year,month)
		format ym %tm 
		drop year month withincounty_obsnum obsnum

		// pre destring 
		foreach var in apps_approved_perc apps_denied_perc {
			replace `var' = "" if `var' == "NA"	
		}
		
		// destring 
		foreach var of varlist apps_* {

			// destring
			destring `var', replace

			// assert variable is numeric
			confirm numeric variable `var'
		} // end of destring 
	} // end of else bracket 
	
	// sort and order 
	order county ym 
	sort county ym 

	// save 
	tempfile _`year'
	save `_`year''
	
} // ends year loop

******************************************
forvalues year = `year_start_apps'(1)`year_end_apps' {
	if `year' == `year_start_apps' {
		use `_`year'', clear
	} 
	else {
		append using `_`year''
	}
}

// standardize county names 
gen county_new = ""
split county, parse(" ")
gen countycode = county1 if county_marker == 1
destring countycode, replace
confirm numeric variable countycode
replace county_new = county3 + " " + county4 + " " + county5 if county_marker == 1
replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 if county_marker == 0
replace county_new = trim(county_new)
order county_marker county_new county countycode
drop county county1 county2 county3 county4 county5
rename county_new county

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
tempfile louisiana_apps
save `louisiana_apps'



****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************


// append statewide data to county data 
use `louisiana_cases', clear 
append using `louisiana_state'
merge 1:1 county ym using `louisiana_age'
drop _m 
merge 1:1 county ym using `louisiana_apps'
drop _m

// drop missing observations
#delimit ;
dropmiss county countycode households individuals avg_indiv_per_hh issuance avg_payment hh_with_earnedinc avg_earnedinc_per_hh children adults
apps_received_npa
apps_received_pa
apps_received_snap
apps_received_lacap
apps_received
apps_approved_npa
apps_approved_pa
apps_approved_snap
apps_approved_lacap
apps_approved
apps_denied_npa
apps_denied_pa
apps_denied_snap
apps_denied_lacap
apps_denied
apps_approved_perc 
apps_denied_perc
, force obs
;
#delimit cr 
assert !missing(county)

// order and sort
order county ym 
sort county ym 

// save 
save "${dir_root}/data/state_data/louisiana/louisiana.dta", replace 




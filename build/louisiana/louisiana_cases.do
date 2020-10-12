// louisiana_cases.do 

local year_start				= 2000 
local year_end					= 2019
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

********************************************************************

forvalues year = `year_start'(1)`year_end' {
	
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
	import excel "${dir_data}/excel/002_Cases by Parish & Region/fy`yearnames'_FS_Cases.xlsx", sheet("Table 1") allstring clear
	
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
forvalues year = `year_start'(1)`year_end' {
	if `year' == `year_start' {
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

// sort and order 
order county ym 
sort county ym 

// save
save "${dir_data}/louisiana_cases.dta", replace 



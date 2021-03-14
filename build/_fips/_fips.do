// fips.do 
// Kelsey Pukelis 

*local year_min 2011 
local year_min 2014
local year_max 2019

*************************************************************

forvalues year = `year_min'(1)`year_max' {
	
	// display 
	display in red "`year'"

	// import 
	if inrange(`year',2011,2014) {
		import excel using "${dir_root}/data/state_data/_fips/all-geocodes-v`year'.xls", case(lower) firstrow allstring clear
	}
	else if inrange(`year',2015,2019) {
		import excel using "${dir_root}/data/state_data/_fips/all-geocodes-v`year'.xlsx", case(lower) firstrow allstring clear
	}

	// drop initial obs
	drop in 1
	drop in 1
	drop in 1
	if `year' < 2014 {
		drop in 1
	}
	
	// turn first row into variable names 
	replace estimatesgeographyfilevintag = "summarylevel" if _n == 1
	foreach var of varlist * {
		replace `var' = strlower(`var')
		replace `var' = subinstr(`var', "`=char(9)'", " ", .) if _n == 1
		replace `var' = subinstr(`var', "`=char(10)'", " ", .) if _n == 1
		replace `var' = subinstr(`var', "`=char(13)'", " ", .) if _n == 1
		replace `var' = subinstr(`var', "`=char(14)'", " ", .) if _n == 1
		replace `var' = ustrregexra(`var',"\-","") if _n == 1
		replace `var' = ustrregexra(`var',"\(","") if _n == 1
		replace `var' = ustrregexra(`var',"\)","") if _n == 1
		replace `var' = ustrregexra(`var',"/","") if _n == 1
		replace `var' = ustrregexra(`var'," ","") if _n == 1
		replace `var' = substr(`var',1,32) if _n == 1
		label variable `var' "`=`var'[1]'"
		rename `var' `=`var'[1]'
	}
	drop in 1

	// rename to simplify 
	rename statecodefips statefips 
	rename countycodefips countyfips
	rename areaname areaname

	//////////////////////
	// STATE LEVEL DATA //
	//////////////////////

	// preserve
	preserve 

	// drop vars I don't need
	capture rename consolidtatedcitycodefips consolidatedcitycodefips
	drop countysubdivisioncodefips
	drop placecodefips
	drop consolidatedcity

	// keep if state level 
	keep if summarylevel == "040"
	drop summarylevel
	drop countyfips
	rename areaname state

	// remove space from Name 
	replace state = subinstr(state," ", "", .)

	// destring fips 
	destring statefips, replace 
	confirm numeric variable statefips

	// year 
	gen year = `year'

	// order and sort 
	order year state statefips 
	sort year statefips

	// save 
	tempfile statefips_`year'
	save `statefips_`year''
	save "${dir_root}/data/state_data/_fips/statefips_`year'.dta", replace 

	// restore
	restore 

	///////////////////////
	// COUNTY LEVEL DATA //
	///////////////////////

	// preserve
	preserve 

	// drop vars I don't need
	capture rename consolidtatedcitycodefips consolidatedcitycodefips
	drop countysubdivisioncodefips
	drop placecodefips
	drop consolidatedcity

	// keep if county level 
	keep if inlist(summarylevel,"050","50")
	drop summarylevel
	rename areaname county 

	// remove space from Name 
	gen county_og = county
	gen county_type = ""
	replace county_type = "city and borough" if strpos(county_og," city and borough")
	replace county = subinstr(county," city and borough", "", .)	
	replace county_type = "county" if strpos(county_og," county")
	replace county = subinstr(county," county", "", .)	
	replace county_type = "borough" if strpos(county_og," borough")
	replace county = subinstr(county," borough", "", .)	
	replace county_type = "census area" if strpos(county_og," census area")
	replace county = subinstr(county," census area", "", .)	
	replace county_type = "parish" if strpos(county_og," parish")
	replace county = subinstr(county," parish", "", .)	
	replace county_type = "city" if strpos(county_og," city")
	replace county = subinstr(county," city", "", .)	
	replace county_type = "municipality" if strpos(county_og," municipality")
	replace county = subinstr(county," municipality", "", .)	

	// make sure names are unique 
	duplicates tag statefips county, gen(dup)
	replace county = county_og if dup == 1
	drop dup 
	duplicates tag statefips county, gen(dup)
	assert dup == 0 
	drop dup 

	// finish cleaning county 
	replace county = stritrim(county)
	replace county = trim(county)
	replace county = subinstr(county, "`=char(9)'", "", .)
	replace county = subinstr(county, "`=char(10)'", "", .)
	replace county = subinstr(county, "`=char(13)'", "", .)
	replace county = subinstr(county, "`=char(14)'", "", .)
	replace county = subinstr(county, `"`=char(34)'"', "", .) // single quotation '
	replace county = ustrregexra(county," ","")
	replace county = ustrregexra(county,"-","")
	replace county = ustrregexra(county,"\'","")
	replace county = ustrregexra(county,"\.","")


	// destring fips 
	foreach var in statefips countyfips {
		destring `var', replace 
		confirm numeric variable `var'
	}

	// year 
	gen year = `year'

	// order and sort 
	order year county county_type county_og statefips countyfips
	sort year statefips countyfips

	// save 
	tempfile countyfips_`year'
	save `countyfips_`year''
	save "${dir_root}/data/state_data/_fips/countyfips_`year'.dta", replace 

	// restore
	restore 

	/////////////////////////////////////
	// TOWN LEVEL DATA (MASSACHUSETTS) //
	/////////////////////////////////////

	// preserve 
	preserve 

	// keep massachusetts only 
	keep if statefips == "25"
	drop if areaname == "massachusetts"
	keep if inlist(summarylevel,"61","061")

	// separate out type 
	gen town = (strpos(areaname,"town") >= 1)
	gen city = (strpos(areaname,"city") >= 1)

	// manual fix 
	replace areaname = "freetown" if areaname == "free" & town == 1
	
	// remove "city", "town" from area name 
	replace areaname = subinstr(areaname," city","",.)
	replace areaname = subinstr(areaname," town","",.)
	replace areaname = trim(areaname)

	// destring vars 
	foreach var in countyfips countysubdivisioncodefips placecodefips {
		destring `var', replace 
		confirm numeric variable `var'
	}

	// assert level of the data 
	duplicates tag areaname city town, gen(dup)
	assert dup == 0
	drop dup 

	// drop vars I don't need
	drop summarylevel
	capture rename consolidtatedcitycodefips consolidatedcitycodefips
	drop statefips
	drop consolidatedcity
	drop placecodefips

	// year 
	gen year = `year'

	// order, sort 
	order year areaname city town countysubdivisioncodefips countyfips
	sort year areaname

	// save 
	tempfile macitytowns_`year'
	save `macitytowns_`year''
	save "${dir_root}/data/state_data/_fips/macitytowns_`year'.dta", replace 

	// restore 
	restore 

}	

*****************************************************

// combine data across years 
foreach type in statefips countyfips macitytowns {
	forvalues year = `year_min'(1)`year_max' {
		if `year' == `year_min' {
			use ``type'_`year'', clear
		}
		else {
			append using ``type'_`year''
		}
	}
	save "${dir_root}/data/state_data/_fips/`type'.dta", replace 
}

*****************************************************


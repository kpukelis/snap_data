// illinois.do
// imports households and persons from excel sheets

local year_start				2010
local year_end 					2022
local sheets 					persons households

***************************************************************

forvalues year = `year_start'(1)`year_end' {
	foreach sheet of local sheets {
	if `year' < 2018 {

		// year 
		display in red `"`sheet'"' `year'

		// import 
		import excel using "${dir_root}/data/state_data/illinois/excel/snap`year'.xlsx", sheet("`sheet'") firstrow case(lower) allstring clear
		
		// drop observations, then variables with all missing values
		dropmiss, obs force
		dropmiss, force

		// clean up county 
		replace county = strlower(county)
		replace county = trim(county)
		drop if county == "cntl all kid"
		if inlist(`year',2013) {
			drop if strpos(county,"notice:")
		}
		capture confirm variable office 
		if !_rc {
			stop 	
		}

		// reshape
		rename january _1 
		rename february _2 
		rename march _3
		rename april _4 
		rename may _5
		rename june _6 
		rename july _7
		rename august _8
		rename september _9
		rename october _10 
		rename november _11
		rename december _12
		reshape long _, i(county) j(month)
		rename _ `sheet'

		// clean up main variable
		replace `sheet' = ustrregexra(`sheet',",","")
		replace `sheet' = ustrregexra(`sheet',"-","")
		replace `sheet' = ustrregexra(`sheet'," ","")
		gen consolidated_note = ""
		replace consolidated_note = `sheet' if strpos(`sheet',"consolidated")
		replace consolidated_note = `sheet' if inlist(`sheet',"Closed","closed")
		replace consolidated_note = county if strpos(county,"consolidated")
		replace `sheet' = "" if strpos(`sheet',"consolidated")
		replace `sheet' = "" if  inlist(`sheet',"Closed","closed")
		if !inrange(`year',2014,2017) {
			replace county = ustrregexra(county," ","")
		}
		gen county_temp = county 
		split county_temp, parse(" ")
		foreach v of varlist county_temp? {
			replace `v' = trim(`v') 
			replace `v' = ustrregexra(`v'," ","")
		}
		capture confirm variable county_temp2
		if !_rc {
			capture noisily assert inlist(county_temp2,"county","")
			replace county = county_temp1 if inlist(county_temp2,"county","")
			capture confirm variable county_temp3
			if !_rc {
				capture noisily assert inlist(county_temp2,"county","") | inlist(county_temp3,"county","")
				replace county = county_temp1 + " " + county_temp2 if inlist(county_temp3,"county","")
				capture confirm variable county_temp4
				if !_rc {
					noisily assert inlist(county_temp2,"county","") | inlist(county_temp3,"county","","illinois)")
					replace county = county_temp1 + " " + county_temp2 + " " + county_temp3 if inlist(county_temp3,"illinois)")
				}
			}
		}
		else {

		}
		
		drop county_temp*
		replace county = ustrregexra(county," ","")
		replace county = subinstr(county," ","",.)
		replace county = subinstr(county, "`=char(9)'", " ", .)
		replace county = subinstr(county, "`=char(10)'", " ", .)
		replace county = subinstr(county, "`=char(13)'", " ", .)
		replace county = subinstr(county, "`=char(14)'", " ", .)
		if `year' == 2013 {
			replace county = "clinton" if county == "clintonclintoncountyofficeclosedandconsolidatedwithmarioncountyoffice."
			replace county = "mercer" if county == "mercer mercercountyofficeclosed,consolidatedwithwarrencountyoffice."
		}

		replace county = "jodaviess" if strpos(county,"jo") & strpos(county,"daviess")
		replace county = "rockisland" if strpos(county,"rock") & strpos(county,"island")
		replace county = "stclair" if county == "st.clair"
		replace county = "boone" if strpos(county,"boone")
		replace county = "coles" if county == "coles(midillinois)"
		replace county = "total" if county == "totalstate"
		drop if county == "maconltc"

		replace `sheet' = ustrregexra(`sheet'," ","")
		destring `sheet', replace
        confirm numeric variable `sheet'

		// date 
		gen year = `year'
		gen ym = ym(year,month)
		format ym %tm 
		drop year month 

		// order and sort 
		order county ym `sheet'
		sort county ym

		// manually fix duplicates
		if `year' == 2014 {
			drop if county == "bond" & ym == ym(2014,1) & consolidated_note == "bond county office closed and consolidated with madison county office, effective 2/2014."
			drop if county == "bond" & inrange(ym,ym(2014,2),ym(2014,12)) & consolidated_note != "bond county office closed and consolidated with madison county office, effective 2/2014."
		}
		if `year' == 2015 {
			drop if county == "hancock" & ym == ym(2015,1) & consolidated_note == "hancock county office closed and consolidated with adams county office."
			drop if county == "hancock" & inrange(ym,ym(2015,2),ym(2015,12)) & consolidated_note != "hancock county office closed and consolidated with adams county office."
			drop if county == "schuyler" & inrange(ym,ym(2015,1),ym(2015,6)) & consolidated_note == "schuyler county office closed and consolidated with cass county office."
			drop if county == "schuyler" & inrange(ym,ym(2015,7),ym(2015,12)) & consolidated_note != "schuyler county office closed and consolidated with cass county office."
		}

		// assert no duplicates by county ym 
		duplicates tag county ym, gen(dup)
		assert dup == 0
		drop dup
		
		// save 
		*tempfile `year'_`sheet'
		*save ``year'_`sheet''
		save "${dir_root}/data/state_data/illinois/temp/`year'_`sheet'.dta", replace

	}

	*********************************************************************************************************************

	else if `year' >= 2018 {

		// year 
		display in red `"`sheet'"' `year'

		// import 
		import excel using "${dir_root}/data/state_data/illinois/excel/snap`year'.xlsx", sheet("`sheet'") firstrow case(lower) allstring clear
		
		// drop observations, then variables with all missing values
		dropmiss, obs force
		dropmiss, force

		// clean up county 
		replace office = officenumber if inlist(officenumber,"DOWNSTATE","COOK COUNTY","TOTAL STATE")
		replace officenumber = "" if inlist(officenumber,"DOWNSTATE","COOK COUNTY","TOTAL STATE")
		destring officenumber, replace
		confirm numeric variable officenumber
		rename office county 
		replace county = strlower(county)
		replace county = trim(county)
		drop if county == "cntl all kid"
		if inlist(`year',2013) {
			drop if strpos(county,"notice:")
		}
		replace county = "total" if county == "totalstate"
		replace county = "cook" if county == "cookcounty"
		replace county = "stclair" if county == "st.clair-e.st.louis"
		drop if county == "downstate"

		/* OLD
		// clean up office 
		replace office = officenumber if inlist(officenumber,"DOWNSTATE","COOK COUNTY","TOTAL STATE")
		replace officenumber = "" if inlist(officenumber,"DOWNSTATE","COOK COUNTY","TOTAL STATE")
		destring officenumber, replace
		confirm numeric variable officenumber
		replace office = strlower(office)
		replace office = trim(office)
		drop if office == "cntl all kid"
		*/
	
		// reshape
		rename january _1 
		rename february _2 
		rename march _3
		rename april _4 
		rename may _5
		rename june _6 
		rename july _7
		rename august _8
		if `year' != 2022 {
			rename september _9
			rename october _10 
			rename november _11
			rename december _12
		}
		reshape long _, i(county) j(month)
		rename _ `sheet'

		// clean up main variable
		replace `sheet' = ustrregexra(`sheet',",","")
		replace `sheet' = ustrregexra(`sheet',"-","")
		replace `sheet' = ustrregexra(`sheet'," ","")
		gen consolidated_note = ""
		replace consolidated_note = `sheet' if strpos(`sheet',"consolidated")
		replace consolidated_note = `sheet' if inlist(`sheet',"Closed","closed")
		replace consolidated_note = county if strpos(county,"consolidated")
		replace `sheet' = "" if strpos(`sheet',"consolidated")
		replace `sheet' = "" if  inlist(`sheet',"Closed","closed")
		if !inrange(`year',2014,2017) {
			replace county = ustrregexra(county," ","")
		}
		gen county_temp = county 
		split county_temp, parse(" ")
		foreach v of varlist county_temp? {
			replace `v' = trim(`v') 
			replace `v' = ustrregexra(`v'," ","")
		}
		capture confirm variable county_temp2
		if !_rc {
			capture noisily assert inlist(county_temp2,"county","")
			replace county = county_temp1 if inlist(county_temp2,"county","")
			capture confirm variable county_temp3
			if !_rc {
				capture noisily assert inlist(county_temp2,"county","") | inlist(county_temp3,"county","")
				replace county = county_temp1 + " " + county_temp2 if inlist(county_temp3,"county","")
				capture confirm variable county_temp4
				if !_rc {
					noisily assert inlist(county_temp2,"county","") | inlist(county_temp3,"county","","illinois)")
					replace county = county_temp1 + " " + county_temp2 + " " + county_temp3 if inlist(county_temp3,"illinois)")
				}
			}
		}
		else {

		}
		
		drop county_temp*
		replace county = ustrregexra(county," ","")		
		replace `sheet' = ustrregexra(`sheet'," ","")
		destring `sheet', replace
        confirm numeric variable `sheet'

		// date 
		gen year = `year'
		gen ym = ym(year,month)
		format ym %tm 
		drop year month 

		// need to collapse kane-aurora, kane-elgin 
		// need to collapse madison-e.alton madison-g.city
		replace county = "kane" if inlist(county,"kane-aurora","kane-elgin")
		replace county = "madison" if inlist(county,"madison-e.alton","madison-g.city")
		rename `sheet' `sheet'_OLD
		bysort county ym: egen `sheet' = total(`sheet'_OLD)
		drop `sheet'_OLD
		drop officenumber
		duplicates drop 
		duplicates tag county ym, gen(dup)
		assert dup == 0
		drop dup 

		// clean up counties again 
		replace county = "total" if county == "totalstate"
		replace county = "cook" if county == "cookcounty"
		replace county = "stclair" if county == "st.clair-e.st.louis"
		drop if county == "downstate"

		// order and sort 
		order county ym `sheet'
		sort county ym

		// assert no duplicates by county ym 
		duplicates tag county ym, gen(dup)
		assert dup == 0
		drop dup


		// save 
		*tempfile `year'_`sheet'
		*save ``year'_`sheet''
		save "${dir_root}/data/state_data/illinois/temp/`year'_`sheet'.dta", replace

	}
	}

}

***************************************************************

forvalues year = `year_start'(1)`year_end' {

	local level county 
	display in red "`year'"
	foreach sheet of local sheets {
		display in red "`year' `sheet'"
		display in red "`sheet'"
		if "`sheet'" == "persons" {
			*use ``year'_`sheet'', clear
			use "${dir_root}/data/state_data/illinois/temp/`year'_`sheet'.dta", clear 
		}
		else {
			*merge 1:1 `level' ym using ``year'_`sheet''
			merge 1:1 `level' ym using "${dir_root}/data/state_data/illinois/temp/`year'_`sheet'.dta"
			assert _m == 3
			drop _m
		}
	}
	save "${dir_root}/data/state_data/illinois/illinois_`year'_TEMP.dta", replace 
}


// Note only merging 2017 for now; going to get to the office level and then append with 2018-2020 data
forvalues year = `year_start'(1)`year_end' {
	if `year' == `year_start' {
		use "${dir_root}/data/state_data/illinois/illinois_`year'_TEMP.dta", clear
	}
	else {
		append using "${dir_root}/data/state_data/illinois/illinois_`year'_TEMP.dta"
	}
}

// order and sort 
order county ym 
sort county ym

// rename 
rename persons individuals

// drop consolidation notes 
drop consolidated_note

// drop nonobservations 
drop if missing(individuals) & missing(households)

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// save
save "${dir_root}/data/state_data/illinois/illinois_office.dta", replace 
*/
******************************************************************************

use "${dir_root}/data/state_data/illinois/illinois_office.dta", clear

// population
preserve
	use "${dir_root}/data/state_data/illinois/illinois_county_pop.dta", clear 
	duplicates tag county year, gen(dup)
	assert dup == 0
	drop dup 	
	// population: make 2022 data same as 2021 data, for now 
	expand 2 if year == 2021
	bysort county year: gen obsnum_within = _n 
	sum obsnum_within
	assert `r(max)' == 2
	replace year = 2022 if obsnum_within == 2
	drop obsnum_within
	tempfile illinois_county_pop
	save `illinois_county_pop'
restore 

// crosswalk for combinations of offices 
preserve
	import excel using "${dir_root}/data/state_data/illinois/office_crosswalk/office_county_crosswalk.xlsx", sheet("Sheet1") clear 
	
	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	
	// turn first row into variable names 
	foreach var of varlist * {
		replace `var' = strlower(`var')
		replace `var' = "_" + `var' if _n == 1
		replace `var' = ustrregexra(`var',"-","") if _n == 1
		*replace `var' = ustrregexra(`var',".","") if _n == 1
		*replace `var' = ustrregexra(`var'," ","") if _n == 1
		label variable `var' "`=`var'[1]'"
		rename `var' `=`var'[1]'
	}
	drop in 1
	
	// drop office totals
	drop in 1
	
	// reshape long
	rename _time county 
	reshape long _, i(county) j(_yyyy_mm) string 
	rename _ newcounty
	
	// ym 
	gen year = substr(_yyyy_mm,1,4)
	gen month = substr(_yyyy_mm,6,2)
	foreach v in year month {
		destring `v', replace 
		confirm numeric variable `v'
	}
	gen ym = ym(year,month)
	format ym %tm
	drop year month
	drop _yyyy_mm
	
	// make sure level of the data is really originalcounty ym level
	duplicates tag county ym, gen(dup)
	assert dup == 0
	drop dup 

	// save 
	tempfile crosswalk 
	save `crosswalk'

restore

// merge in original county names
// master data is at the office level 
// merging in county names, such that 1 office can potentially match to more than one county 
rename county newcounty
merge 1:m newcounty ym using `crosswalk', keepusing(county)
assert _m == 3
drop _m 
rename newcounty office_county_group

// make sure level of the data is really originalcounty ym level
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// number of counties in the county group 
sort office_county_group ym county
by office_county_group ym: gen num_counties = _N
assert num_counties >= 1 & !missing(num_counties)

// will alter for office_county_group with more than one counties
gen individuals_total = individuals
gen households_total = households
replace individuals = . if county != "total"
replace households = . if county != "total"

// merge in population data
gen year = year(dofm(ym))
merge m:1 county year using `illinois_county_pop', keepusing(pop)
assert inlist(_m,2,3) | (_m == 1 & county == "total")
drop if _m == 2
drop _m 

// make fraction: numerator is pop in county, denom is total pop in office_county_group
bysort office_county_group ym: egen pop_total = total(pop)
gen pop_frac = pop / pop_total

// replace individuals, households with fraction of total 
replace individuals = individuals_total * pop_frac if county != "total"
replace households = households_total * pop_frac if county != "total"	

// assert level of data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order and sort 
drop year 
order office_county_group ym county individuals households pop pop_frac  num_counties pop_total individuals_total households_total 
sort office_county_group ym county

// save 
save "${dir_root}/data/state_data/illinois/illinois.dta", replace 




global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/louisiana"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local year_start				= 2011
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
		local month_num_end = 9 // **KP: change when more data is added
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
	import excel "${dir_data}/excel/014_SNAP Recipients by Age/fy`yearnames'_FS_Age.xlsx", sheet("Table 1") allstring clear
	
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
		rename v4 recipients 
	
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
		foreach var in children adults recipients {
	
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
			rename v4 recipients 

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
			foreach var in children adults recipients {
		
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
forvalues year = `year_start'(1)`year_end' {
	if `year' == `year_start' {
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
replace county_new = county3 + " " + county4 + " " + county5 + " " + county6 if county_marker == 1
replace county_new = county1 + " " + county2 + " " + county3 + " " + county4 + " " + county5 + " " + county6 if county_marker == 0
replace county_new = trim(county_new)
order county_marker county_new county countycode
drop county county1 county2 county3 county4 county5 county6
rename county_new county

// sort and order 
order county ym 
sort county ym 

// save
save "${dir_data}/louisiana_age.dta", replace 


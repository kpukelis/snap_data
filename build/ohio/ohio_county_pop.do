// ohio_county_pop. do 
// Kelsey Pukelis

// import population data 
import excel "${dir_root}/data/state_data/ohio/_population/co-est2019-annres-39.xlsx", case(lower) firstrow allstring clear 

// drop headers
drop in 1
drop in 1
drop in 1

// rename 
describe, varlist
rename (`r(varlist)') (v#), addnumber
rename v1 placename
rename v2 y2010census
rename v3 yestimatesbase
rename v4 y2010
rename v5 y2011
rename v6 y2012
rename v7 y2013
rename v8 y2014
rename v9 y2015
rename v10 y2016
rename v11 y2017
rename v12 y2018
rename v13 y2019

// reshape 
reshape long y, i(placename) j(var) string 
rename y pop 
drop if inlist(var,"2010census","estimatesbase")
rename var year 
foreach var in year pop {
	destring `var', replace 
	confirm numeric variable `var' 
}

// keep if county level 
drop if placename == "Annual Estimates of the Resident Population for Counties in Virginia: April 1, 2010 to July 1, 2019 (CO-EST2019-ANNRES-51)"
drop if placename == "Note: The estimates are based on the 2010 Census and reflect changes to the April 1, 2010 population due to the Count Question Resolution program and geographic program revisions. All geographic boundaries for the 2019 population estimates are as of January 1, 2019. For population estimates methodology statements, see http://www.census.gov/programs-surveys/popest/technical-documentation/methodology.html."
drop if placename == "Release Date: March 2020"
drop if placename == "Source: U.S. Census Bureau, Population Division"
drop if placename == "Suggested Citation:"
drop if placename == "Annual Estimates of the Resident Population for Counties in Ohio: April 1, 2010 to July 1, 2019 (CO-EST2019-ANNRES-39)"
drop if placename == "Ohio"
rename placename county 
	
// remove space from Name 
gen county_og = county
replace county = ustrregexra(county,", Ohio","")
replace county = ustrregexra(county,"\.","")
replace county = strlower(county)
rename county county_copy
gen county = county_copy
order county, before(county_copy)
drop county_copy

gen county_type = ""
replace county_type = "county" if strpos(county_og," County")
replace county = subinstr(county," county", "", .)	
replace county_type = "city" if strpos(county_og," city")
replace county = subinstr(county," city", "", .)	

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

// make sure names are unique 
duplicates tag county year, gen(dup)
replace county = county_og if dup == 1
drop dup 
duplicates tag county year, gen(dup)
assert dup == 0 
drop dup 

// save 
save "${dir_root}/data/state_data/ohio/ohio_county_pop.dta", replace


*********************************************************************


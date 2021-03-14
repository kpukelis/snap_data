// _zip.do 
// Kelsey Pukelis
// crosswalks Massachuestts towns to zipcodes 


foreach Mon_yyyy in Feb_2013 Jul_2015 Aug_2017 Apr_2018 Sep_2018 Mar_2020 {
	
	// import 
	import excel "${dir_root}/data/policy_data/state_exempt_counties/massachusetts/new england town to zip crosswalk/New England city and town areas (NECTAs), NECTA divisions, and combined NECTAs/list3_`Mon_yyyy'.xls", clear
	drop in 1
	drop in 1
	dropmiss, force 

	// turn first row into variable names 
	foreach var of varlist * {
		replace `var' = strlower(`var')
		replace `var' = ustrregexra(`var',"-","") if _n == 1
		replace `var' = ustrregexra(`var',"\.","") if _n == 1
		replace `var' = ustrregexra(`var'," ","") if _n == 1
		replace `var' = ustrregexra(`var',"/","") if _n == 1
		label variable `var' "`=`var'[1]'"
		rename `var' `=`var'[1]'
	}
	drop in 1

	// drop notes 
	drop if strpos(nectacode,"note:  nineteen cities and one borough in connecticut are coextensive with towns of the same name.")
	drop if strpos(nectacode,"these places are identified above with the term "city and town" or "borough and town" following the name.")
	drop if strpos(nectacode,"this file provides the 5-digit minor civil division (mcd) code for each of the 20 towns; use of that code")
	drop if strpos(nectacode,"will facilitate integration of information in this file with other files providing data for mcds in new england.")
	drop if strpos(nectacode,"source: u.s. census bureau, population division; office of management and budget, february 2013 delineations")
	drop if strpos(nectacode,"internet release date: march 2013")
	drop if strpos(nectacode,"source: file prepared by u.s. census bureau, population division, based on office of management and budget, july 2015 delineations <https://www.whitehouse.gov/sites/default/files/omb/bulletins/2015/15-01.pdf>.")
	drop if strpos(nectacode,"internet release date")
	drop if strpos(nectacode,"source: file prepared by u.s. census bureau")

	// rename 
	rename cityortownname citytownname 
	rename fipsstatecode statefips 
	rename fipscountycode countyfips
	capture rename fipsmcdcode countysubdivisioncodefips
	capture rename fipscountysubdivisioncode countysubdivisioncodefips

	// destring 
	foreach var in nectacode nectadivisioncode combinednectacode statefips countyfips countysubdivisioncodefips {
		destring `var', replace 
		confirm numeric variable `var'
	}

	// separate out type 
	gen town = (strpos(citytownname,"town") >= 1)
	gen city = (strpos(citytownname,"city") >= 1)

	// manual fix 
	replace citytownname = "freetown" if citytownname == "free" & town == 1
	
	// remove "city", "town" from area name 
	replace citytownname = subinstr(citytownname," city","",.)
	replace citytownname = subinstr(citytownname," town","",.)
	replace citytownname = trim(citytownname)

	// keep only massachusetts
	keep if statefips == 25

	// year 
	gen year = .
	if "`Mon_yyyy'" == "Feb_2013" {
		replace year = 2013 
	}
	else if "`Mon_yyyy'" == "Jul_2015" {
		replace year = 2015
	}
	else if "`Mon_yyyy'" == "Aug_2017" {
		replace year = 2017
	}
	else if inlist("`Mon_yyyy'","Apr_2018","Sep_2018") {
		replace year = 2018
	}
	else if inlist("`Mon_yyyy'","Mar_2020") {
		replace year = 2020
	}

	// drop vars I don't need right now 
	drop nectadivisioncode
	drop combinednectacode
	drop metropolitanmicropolitannecta
	drop nectadivisiontitle
	drop combinednectatitle

	// order 
	order countysubdivisioncodefips citytownname town city nectacode nectatitle countyfips statefips year 
	sort citytownname

	// assert level of the data 
	duplicates tag countysubdivisioncodefips, gen(dup)
	assert dup == 0
	drop dup 

	// save 
	tempfile `Mon_yyyy'
	save ``Mon_yyyy''

}
*/

// import 
import delimited using "${dir_root}/data/policy_data/state_exempt_counties/massachusetts/new england town to zip crosswalk/zcta_necta_rel_10.csv", delimiter(",") varnames(1) clear 
keep zcta5 necta zpop

// rename 
rename necta nectacode

// tag duplicates 
duplicates tag zcta5, gen(dup_zcta5)
*duplicates tag nectacode, gen(dup_nectacode)

// just keep one necta for now 
bysort zcta5: gen obsnum = _n
assert inlist(obsnum,1,2)
count if obsnum == 2
assert r(N) == 39 
drop if obsnum == 2
drop obsnum

// assert level of data 
drop dup_zcta5
duplicates tag zcta5, gen(dup)
assert dup == 0
drop dup 

// merge in other crosswalk
merge 1:1 nectacode using `Mar_2020'
check

KEEP GOING HERE 2021-03-13



check


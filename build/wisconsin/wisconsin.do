// wisconsin.do 
// Kelsey Pukelis 

local files 					assistance benefits recipients
local file_first 				assistance
local year_start 				= 2011
local year_end 					= 2022
local year_end_unduplicated 	= 2019
local numvars_assistance 		= 14
local numvars_benefits 			= 15
local numvars_recipients 		= 14
local ym_start_oldformat 		= ym(2010,1)
local ym_end_oldformat 			= ym(2017,3)
local ym_start_newformat 		= ym(2017,4)
local ym_end_newformat 			= ym(2022,5)

*********************************************************************

// unduplicated-assistance

// import 
import excel using "${dir_root}/data/state_data/wisconsin/excel/fs-unduplicated-assistance.xls", allstring clear

// initial cleanup
dropmiss, force 
dropmiss, obs force 
describe, varlist 
rename (`r(varlist)') (v#), addnumber

// trim
foreach v of varlist _all {
	replace `v' = trim(`v')
}

// clean up
while !strpos(v1,"UNDUPLICATED STATE TOTAL") {
	drop in 1
}

// manual drop 
drop if v1 == "AGENCY"
drop if strpos(v1,"* County counts do no sum to State total because clients/cases served in two counties are counted in each, but are counted only once in state total. This difference is substantial in 2011 because  many cases were served both by their county of residence as well as the Enrollment Services Center")

// shorten county name 
gen v1_copy = v1 
drop v1 
rename v1_copy v1 
order v1 

// rename and reshape 
describe, varlist 
assert r(k) == 26
assert r(N) == 81
rename v1 county
rename v2 _1995
rename v3 _1996
rename v4 _1997 
rename v5 _1998
rename v6 _1999
rename v7 _2000
rename v8 _2001
rename v9 _2002
rename v10 _2003
rename v11 _2004
rename v12 _2005
rename v13 _2006
rename v14 _2007
rename v15 _2008
rename v16 _2009
rename v17 _2010
rename v18 _2011
rename v19 _2012
rename v20 _2013
rename v21 _2014
rename v22 _2015
rename v23 _2016
rename v24 _2017
rename v25 _2018
rename v26 _2019
reshape long _, i(county) j(year)
rename _ cases1 

// destring 
foreach var in cases1 {
	replace `var' = ustrregexra(`var',"NA","")
	destring `var', replace 
	confirm numeric variable `var'
}

// standardize county names 
replace county = lower(county)
replace county = "unduplicated state total" if strpos(county,"unduplicated state total")
replace county = "lacrosse county" if county == "la crosse county"
replace county = "menominee county/tribe" if strpos(county,"menominee")
replace county = "powtawatomi tribe" if county == "potawatomi tribe"
replace county = "oneida tribe" if county == "oneida tribal council"
replace county = "lac courte oreilles tribe" if county == "lac courtes oreilles tribe"

// order and sort 
order county year
sort county year

// save 
save "${dir_root}/data/state_data/wisconsin/wisconsin_unduplicated-assistance.dta", replace 

*********************************************************************
// unduplicated-recipients

forvalues year = `year_start'(1)`year_end_unduplicated' {

	display in red "`year'"
	local year_short = `year' - 2000
	
	// import 
	import excel using "${dir_root}/data/state_data/wisconsin/excel/fs-unduplicated-recipients-cy`year_short'.xls", allstring clear
	
	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	
	// trim
	foreach v of varlist _all {
		replace `v' = trim(`v')
	}
	
	// clean up
	while !strpos(v1,"UNDUPLICATED STATE TOTAL") {
		drop in 1
	}
	
	// manual drop 
	drop if v1 == "AGENCY" | v1 == "AGENCY***"
	drop if strpos(v1,"County counts do no sum to State total because clients/cases served in two counties are counted in both counties but only once in state total. The difference is substantial in 2011 because many cases were serve by the residence county as well as the Enrollment Services Center.")
	drop if strpos(v1,"Adults and Children do not sum to Recipient total because children becoming adults during year counted in both columns")
	drop if strpos(v1,"County counts do no sum to State total because clients/cases served in two counties are counted in both counties but only once in state total")
	drop if strpos(v1,"Adults and Children do not sum to Recipient Total because children becoming adults during year are counted in both columns")
	drop if strpos(v1,"Because of the elimination of the ESC (Economic Service Center), cases counted in the ESC in the previous year have reverted to their county of residence. This may result in an appearance of a statistal increase in some counties counts beyond normal growth.")
	drop if strpos(v1,"Tribal members are counted in the county that administers services regardless of their county of residence")

	// shorten county name 
	gen v1_copy = v1 
	drop v1 
	rename v1_copy v1 
	order v1 

	// rename and reshape 
	describe, varlist 
	assert r(k) == 5
	assert r(N) == 81 | r(N) == 80
	rename v1 county
	rename v2 recipients
	rename v3 adults
	rename v4 children 
	rename v5 cases2

	// destring 
	foreach var in recipients adults children cases2 {
		destring `var', replace 
		confirm numeric variable `var'
	}

	// date 
	gen year = `year'

	// order and sort 
	order county year
	sort county year

	// save 
	tempfile _`year'
	save `_`year''
}

// append all years 
forvalues year = `year_start'(1)`year_end_unduplicated' {
	if `year' == `year_start' {
		use `_`year'', clear
	}
	else {
		append using `_`year''
	}
}

// standardize county names 
replace county = lower(county)
replace county = "unduplicated state total" if strpos(county,"unduplicated state total")
replace county = "eau claire county" if county == "eau_claire county"
replace county = "lacrosse county" if county == "la crosse county"
replace county = "lac courte oreilles tribe" if county == "lac courtes oreilles tribe"
replace county = "oneida tribe" if county == "oneida tribal council"
replace county = "powtawatomi tribe" if county == "potawatomi tribe"
replace county = "menominee county/tribe" if strpos(county,"menominee")

// order and sort 
order county year
sort county year

// save 
save "${dir_root}/data/state_data/wisconsin/wisconsin_unduplicated-recipients.dta", replace
*/
*********************************************************************
// other files 

foreach file of local files {
	forvalues year = `year_start'(1)`year_end' {

		display in red "`file'"
		display in red "`year'"

		local year_short = `year' - 2000

		// import 
		import excel using "${dir_root}/data/state_data/wisconsin/excel/fs-`file'-cy`year_short'.xls", allstring clear

		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber

		// trim
		foreach v of varlist _all {
			replace `v' = trim(`v')
		}

		// clean up
		while !strpos(v1,"Adams") {
			drop in 1
		}

		// manual drop 
		drop if strpos(v2,"FoodShare Cases and Individuals eligible for the BadgerCare Core Plan are administerd through the Enrollement Services Center")
		drop if strpos(v1,"Note: February 2019 benefits were issued on January 20, 2019 for a majority of assistance groups due to the federal government shutdown")
        drop if strpos(v1,"Note: January 2019 includes January benefit issuance and a majority of February's benefit issuance due to the federal government shutdown.")
		drop if strpos(v1,"Note: February 2019 benefits were issued on January 20, 2019 for a majority of recipients due to the federal government shutdown")
		drop if strpos(v1,"* Beginning in July 2021, the State Total is an unduplicated count of assistance groups. Assistance groups that move within the month may be counted as receiving benefits in more than one county or tribe, but are only counted once statewide. Because of this, the sum of all counties and tribes may be greater than the State Total.")
		drop if strpos(v1,"* Beginning in July 2021, the State Total is an unduplicated count of recipients. Recipients that move within the month may be counted as receiving benefits in more than one county or tribe, but are only counted once statewide. Because of this, the sum of all counties and tribes may be greater than the State Total.")
		drop if strpos(v1,"During the COVID-19 Public Health Emergency, emergency FoodShare allotments have been issued. These emergency allotments take FoodShare households to their maximum allowable amount, and can increase the statewide monthly issuance of FoodShare benefits by more than 50%.")

		// shorten county name 
		gen v1_copy = v1 
		drop v1 
		rename v1_copy v1 
		order v1 

		// rename and reshape 
		describe, varlist 
		assert r(k) == `numvars_`file''
		assert r(N) == 81
		rename v1 county
		rename v2 _1
		rename v3 _2
		rename v4 _3
		rename v5 _4
		rename v6 _5
		rename v7 _6
		rename v8 _7
		rename v9 _8
		rename v10 _9
		rename v11 _10
		rename v12 _11
		rename v13 _12
		rename v14 _avg
		capture rename v15 _total
		drop _avg 
		capture drop _total
		reshape long _, i(county) j(month)
		rename _ `file'

		// destring 
		destring `file', replace 
		confirm numeric variable `file'

		// date 
		gen year = `year'
		gen ym = ym(year,month)
		format ym %tm 
		drop year month 

		// order and sort 
		order county ym 
		sort county ym 

		// save 
		tempfile _`year'
		save `_`year''

	}

	// append all years 
	forvalues year = `year_start'(1)`year_end' {
		if `year' == `year_start' {
			use `_`year'', clear
		}
		else {
			append using `_`year''
		}
	}

	// standardize county names 
	replace county = "Milwaukee" if county == "Milwaukee Total"
	replace county = "State Total" if county == "State Total*"

	// order and sort 
	order county ym 
	sort county ym 

	// save 
	save "${dir_root}/data/state_data/wisconsin/wisconsin_`file'.dta", replace
}
 
*************************************************************************
// ataglance - old format

// import 
import excel using "${dir_root}/data/state_data/wisconsin/excel_ataglance/wisconsin_ataglance.xlsx", sheet("old_format") allstring firstrow clear
capture	drop MONTHYEAR

// destring
#delimit ;
foreach var in 
	year
	month
	households
	individuals
	female_children_perc
	female_adults_perc
	male_children_perc
	male_adults_perc
	households_withminors_perc
	households_withminor_0parent_per
	households_withminor_1parent_per
	households_withminor_2parent_per
	firsttimehouseholds
	ebd_perc
	households_withebd_perc
	avg_alottment_hh_ebd
	avg_alottment_hh 
	{ ;
		destring `var', replace ;
		confirm numeric variable `var' ;
} ;
#delimit cr 

// ym
gen ym = ym(year,month)
format ym %tm 
drop year
drop month 

// check data 
assert inrange(ym,`ym_start_oldformat',`ym_end_oldformat')

// county 
gen county = "total"

// order and sort 
order county ym 
sort county ym 

// save 
save "${dir_root}/data/state_data/wisconsin/wisconsin_ataglance_oldformat.dta", replace

*************************************************************************
// ataglance - new format

// import 
import excel using "${dir_root}/data/state_data/wisconsin/excel_ataglance/wisconsin_ataglance.xlsx", sheet("new_format") allstring firstrow clear

// destring
#delimit ;
foreach var in 
	year
	month
	households
	firsttimehouseholds
	individuals
	households_withminors_perc
	households_withebd_perc
	female_00_05
	male_00_05
	female_06_17
	male_06_17
	female_18_34
	male_18_34
	female_35_49
	male_35_49
	female_50_64
	male_50_64
	female_65plus
	male_65plus
	households_withminor_2parent
	households_withminor_1parent
	households_withminor_0parent
	households_ebd_issuance_00_20
	households_ebd_issuance_21_40
	households_ebd_issuance_41_60
	households_ebd_issuance_61_80
	households_ebd_issuance_81_100
	households_ebd_issuance_100plus
	avg_alottment_hh
	avg_alottment_hh_ebd
	{ ;
		destring `var', replace ignore("X") ;
		confirm numeric variable `var' ;
} ;
#delimit cr 

// ym
gen ym = ym(year,month)
format ym %tm 
drop year
drop month 

// check data 
assert inrange(ym,`ym_start_newformat',`ym_end_newformat')

// county 
gen county = "total"

// order and sort 
order county ym 
sort county ym 

// save 
save "${dir_root}/data/state_data/wisconsin/wisconsin_ataglance_newformat.dta", replace

*************************************************************************

// merge across data sets 

///////////////////////
// YEARLY DATA FILES //
///////////////////////

// merge
use "${dir_root}/data/state_data/wisconsin/wisconsin_unduplicated-assistance.dta", clear 
merge 1:1 county year using "${dir_root}/data/state_data/wisconsin/wisconsin_unduplicated-recipients.dta"
drop _m 

// combine same variable 
assert cases1 == cases2 if !missing(cases1) & !missing(cases2)
drop cases2
rename cases1 cases

// order and sort 
order county year 
sort county year

// save 
save "${dir_root}/data/state_data/wisconsin/wisconsin_year.dta", replace 

////////////////////////
// MONTHLY DATA FILES //
////////////////////////

// monthly data files 
foreach file of local files {
	if "`file'" == "`file_first'" {
		use "${dir_root}/data/state_data/wisconsin/wisconsin_`file'.dta", clear
	}
	else {
		merge 1:1 county ym using "${dir_root}/data/state_data/wisconsin/wisconsin_`file'.dta"
		assert _m == 3
		drop _m 
	}
}

// replace 
replace county = "total" if county == "State Total"

// rename 
rename assistance households
rename benefits issuance 
rename recipients individuals

// merge in new and old formats 
// note: this order matters, after replacing the county name and renaming the variables
merge 1:1 county ym using "${dir_root}/data/state_data/wisconsin/wisconsin_ataglance_oldformat.dta", update // want update only, not update replace 
drop _m 
merge 1:1 county ym using "${dir_root}/data/state_data/wisconsin/wisconsin_ataglance_newformat.dta", update // want update only, not update replace
drop _m 

// order and sort 
order county ym 
sort county ym

// save 
save "${dir_root}/data/state_data/wisconsin/wisconsin.dta", replace 

/*
keep if county == "total"
local statewide_nowaiver = ym(2015,4)
twoway connected households ym, xline(`statewide_nowaiver')
twoway connected individuals ym, xline(`statewide_nowaiver')
*/


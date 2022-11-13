// ohio.do
// Kelsey Pukelis

local ym_start	 				= ym(2002,6)
local ym_end 					= ym(2022,8)

************************************************************

forvalues ym = `ym_start'(1)`ym_end' {
if `ym' != ym(2018,9) {

	// display
	dis in red `ym'

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen year_short = year - 2000
	tostring year_short, replace 
	replace year_short = "0" + year_short if strlen(year_short) == 1
	gen month = month(dofm(`ym'))
	local month = month 
	display in red "`month'"
	gen monthname = ""
	if inrange(`ym',ym(2017,1),ym(2017,12)) | inrange(`ym',ym(2019,1),ym(2019,12)) | `ym' >= ym(2020,1) {
		replace monthname = "January" if month == 1
		replace monthname = "February" if month == 2
		replace monthname = "March" if month == 3
		replace monthname = "April" if month == 4
		replace monthname = "May" if month == 5
		replace monthname = "June" if month == 6
		replace monthname = "July" if month == 7
		replace monthname = "August" if month == 8
		replace monthname = "September" if month == 9
		replace monthname = "October" if month == 10
		replace monthname = "November" if month == 11
		replace monthname = "December" if month == 12	
	}
	else {
		tostring month, replace 
		replace monthname = month
		replace monthname = "0" + monthname if strlen(monthname) == 1
	}
	local monthname = monthname
	display in red "`monthname'"
	local year_short = year_short 
	display in red "`year_short'"
	local year = year 
	display in red "`year'"

	// import 
	if inrange(`ym',ym(2002,6),ym(2006,12)) {
		import excel using "${dir_root}/data/state_data/ohio/excel/`year'/binder/Document Cloud/`monthname'`year'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2007,1),ym(2016,12)) {
		import excel using "${dir_root}/data/state_data/ohio/excel/`year'/binder/Document Cloud/PAMS`year'-`monthname'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2017,1),ym(2017,12)) {
		import excel using "${dir_root}/data/state_data/ohio/excel/`year'/binder/Document Cloud/PAMS_`monthname'_`year'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2018,1),ym(2018,12)) {
		import excel using "${dir_root}/data/state_data/ohio/excel/`year'/binder/Document Cloud/Updated PAMS `year'_`monthname'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2019,1),ym(2019,12)) {
		import excel using "${dir_root}/data/state_data/ohio/excel/`year'/binder/Document Cloud/Case Load Summary Report `monthname' `year'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2020,1),ym(2022,12)) {
		import excel using "${dir_root}/data/state_data/ohio/excel/`year'/binder/Document Cloud/Caseload Summary Report `monthname' `year'.xlsx", case(lower) allstring clear
	}
	else {
		import excel using "${dir_root}/data/state_data/ohio/excel/`year'/binder/Document Cloud/Caseload Summary Report `monthname' `year'.pdf_short.xlsx", case(lower) allstring clear
	}
	
	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// trim all variables 
	foreach v of varlist _all {
		replace `v' = trim(`v')
		replace `v' = stritrim(`v')
		replace `v' = subinstr(`v', "`=char(9)'", " ", .)
		replace `v' = subinstr(`v', "`=char(13)'", " ", .)
		replace `v' = subinstr(`v', "`=char(14)'", " ", .)
	}

	// drop title rows 
	drop if strpos(v1,"TABLE 5")
	drop if strpos(v1,"Table 5")
	drop if strpos(v1,"Table 3")
	drop if strpos(v1,"OHIO COUNTY")
	drop if v1 == "COUNTY"
	drop if v2 == "Persons"
	drop if strpos(v1,"Program Detail: Supplemental Nutrition Assistance Program")
	drop if v1 == "SNAP"
	drop if strpos(v1,"Issuance") & strpos(v1,"County") 
	drop if strpos(v2,"PUBLIC") & strpos(v2,"ASSISTANCE")
	drop if strpos(v2,"Public") & strpos(v2,"Assistance")
	drop if strpos(v1,"Source: CRIS-E GRP304RA and GRP 304RC Reports from Management Information Services.")
	drop if strpos(v1,"Source: CRIS-E GRP304RA and GRP 304RC Reports from Office of Information Services.")
	drop if strpos(v1,"Source: CRIS‐E GRP304RA and GRP 304RC Reports from Office of Information Services.")
	drop if v1 == "Page 31"
	drop if v1 == "Page 32"
	drop if v1 == "Page 33"
	drop if strpos(v1,"Page 18")
	drop if strpos(v1,"Page 19")
	drop if strpos(v1,"Page 20")
	drop if strpos(v1,"Page 21")
	if `ym' == ym(2021,10) {
		drop if strpos(v1,"Program Detail: Publicly Funded Child Care") 	
	}
	

	// dropmiss remaining
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// make all variables easier to browse
	foreach v of varlist _all {

		gen `v'_copy = `v'
		order `v'_copy, after(`v')
		drop `v'
		rename `v'_copy `v'
	}

	// dropmiss remaining
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	duplicates drop 

	// assert size of data 
	describe, varlist
	if `ym' <= ym(2013,3) {
		assert `r(N)' == 89
	}
	else if inrange(`ym',ym(2013,4),ym(2014,1)) {
		assert `r(N)' == 90
	}
	else if inrange(`ym',ym(2014,2),ym(2018,8)) {
		assert `r(N)' == 91	
	}
	else if inlist(`ym',ym(2020,2)) | inrange(`ym',ym(2020,4),ym(2022,3)) | inrange(`ym',ym(2022,5),ym(2022,9)) {
		assert `r(N)' == 87 
	}
	else if inlist(`ym',ym(2022,4)) {
		assert `r(N)' == 88
	}
	else {
		assert `r(N)' == 86		
	}
	if `ym' <= ym(2010,9) {
		assert `r(k)' == 10
		// rename vars 
		rename v1 county 
		rename v2 individuals_pa
		rename v3 individuals_npa 
		rename v4 individuals
		rename v5 avg_issuance_individuals
		rename v6 percchange_prevmonth_person
		rename v7 households_pa
		rename v8 households_npa
		rename v9 households
		rename v10 issuance
	}
	else if inrange(`ym',ym(2010,10),ym(2018,8)) {
		assert `r(k)' == 12
		// rename vars 
		rename v1 county 
		rename v2 individuals_pa
		rename v3 individuals_npa 
		rename v4 individuals
		rename v5 avg_issuance_individuals
		rename v6 percchange_prevmonth_person
		rename v7 households_pa
		rename v8 households_npa
		rename v9 households
		rename v10 avg_issuance_households
		rename v11 percchange_prevmonth_households
		rename v12 issuance
	}
	else {
		assert `r(k)' == 5
		// rename vars 
		rename v1 county 
		rename v2 households
		rename v3 individuals
		rename v4 adults
		rename v5 children
	}

	// drop unnecessary vars 
	capture drop percchange_prevmonth_person
	capture drop percchange_prevmonth_households

	// destring 
	foreach var in individuals_pa individuals_npa individuals households_pa households_npa households issuance avg_issuance_individuals avg_issuance_households adults children {
 		capture confirm variable `var'
		if !_rc {
			replace `var' = ustrregexra(`var'," ","")
			replace `var' = ustrregexra(`var',",","")
			replace `var' = ustrregexra(`var',"N.A.","")
			replace `var' = ustrregexra(`var',"NA","")
			replace `var' = ustrregexra(`var',"#REF!","")
			destring `var', replace
			confirm numeric variable `var'
			replace `var' = . if `var' == 0
		}
	}

	// clean up county 
	replace county = strlower(county)
	replace county = trim(county)
	replace county = ustrregexra(county," ","")
	replace county = "statewide" if county == "ohio"

	// ym 
	gen ym = ym(`year',`month')
	format ym %tm

	// order and sort 
	order county ym households individuals
	sort county ym 

	// save 
	tempfile _`ym'
	save `_`ym''
}
}

// append years 
forvalues ym = `ym_start'(1)`ym_end' {
if `ym' != ym(2018,9) {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}
}

// replace county 
replace county = "total" if county == "statewide"
replace county = ustrregexra(county,"/","")
replace county = "defpaulding" if county == "defpaudling"

**TEMPORARY
*save "${dir_root}/data/state_data/ohio/ohio_TEMP.dta", replace 

////////////////////////////////////
// DEFIANCE PAULDING COUNTY SPLIT //
////////////////////////////////////

**TEMPORARY
*use "${dir_root}/data/state_data/ohio/ohio_TEMP.dta", clear 

// split numbers into two counties, based on history of when the proportions were listed separately
// only case (so far) is ohio's defiance and paulding counties

// preserve
preserve

keep if strpos(county,"def") | strpos(county,"paulding")
dropmiss, force 

// gen def paulding total 
foreach var of varlist _all {
if !inlist("`var'","state","statefips","county","ym","office","zipcode","city") {
	
	// total between defiance and paulding counties
	gen temp = `var' if inlist(county,"defiance","paulding")
	if inlist("`var'","avg_issuance_households","avg_issuance_individuals","avg_individuals_households","participation_rate","percpop_snap") {
		bysort ym: egen T`var' = mean(temp)
	}
	else {
		bysort ym: egen T`var' = total(temp)
	}
	drop temp 

	// proportions of each
	gen P`var' = `var' / T`var'

}
}

// graph of proportions overtime 
*twoway 	(connected Pindividuals ym if county == "defiance", mcolor(red) lcolor(red)) ///
*		(connected Pindividuals ym if county == "paulding", mcolor(blue) lcolor(blue)) ///
*		(connected Phouseholds ym if county == "defiance", mcolor(red) lcolor(red)) ///
*		(connected Phouseholds ym if county == "paulding", mcolor(blue) lcolor(blue)) ///
*		(connected Pissuance ym if county == "defiance", mcolor(red) lcolor(red)) ///
*		(connected Pissuance ym if county == "paulding", mcolor(blue) lcolor(blue) xline(645))

// average of proportions on or before 2013m10
sum Pindividuals if ym <= ym(2013,10) & county == "defiance"

// proportions, using population
*preserve 
*	use "${dir_root}/data/state_data/ohio/ohio_county_pop.dta", clear
*	keep if inlist(county,"defiance","paulding")
*	bysort year: egen Tpop = total(pop)
*	gen Ppop = pop / Tpop
*	twoway 	(connected Ppop year if county == "defiance", mcolor(red) lcolor(red)) ///
*			(connected Ppop year if county == "paulding", mcolor(blue) lcolor(blue))
*	// both methods give the same answer. This is encouraging! 
*restore

// use the average of the proportion from individuals, for simplicity
qui sum Pindividuals if ym <= ym(2013,10) & county == "defiance"
local prop_defiance = `r(mean)'
qui sum Pindividuals if ym <= ym(2013,10) & county == "paulding"
local prop_paulding = `r(mean)'
drop P* 
drop T*

local ym_replace_start = ym(2014,2)
local ym_replace_end = `ym_end' // **KP: should be ym_end from the state 

// expand where observations don't exist 
expand 3 if county == "defpaulding" & inrange(ym,ym(2018,9),`ym_replace_end')
bysort county ym: gen obsnum = _n
replace county = "defiance" if obsnum == 2
replace county = "paulding" if obsnum == 3
drop obsnum

sort ym county
foreach var of varlist _all {
if !inlist("`var'","state","statefips","county","ym","office","zipcode","city") {
	display in red "`var'"
	forvalues ym = `ym_replace_start'(1)`ym_replace_end' {
		display in red "`ym'"
		qui replace `var' = . if inlist(county,"defiance","paulding") & ym == `ym'
		qui sum `var' if county == "defpaulding" & ym == `ym'
		#delimit ;
		if !((`ym' == ym(2018,9)) | 
		     (inlist("`var'","adults","children") 
		     	& `ym' < ym(2018,10)) | 
			 (inlist("`var'","issuance","avg_individuals_households","avg_issuance_individuals","avg_issuance_households","households_npa","individuals_npa","households_pa","individuals_pa") 
			 	& `ym' > ym(2018,8))
			) {
		;
		#delimit cr 
			assert `r(N)' == 1
			local value = `r(mean)'
			qui replace `var' = `value'*`prop_defiance' if county == "defiance" & ym == `ym'
			qui replace `var' = `value'*`prop_paulding' if county == "paulding" & ym == `ym'
		}
	}
}
}

// drop combo observation 
drop if county == "defpaulding"

// save 
tempfile defpaulding_data 
save `defpaulding_data'

// restore
restore

// drop existing defpaulding data, and append new data 
drop if inlist(county,"defiance","paulding","defpaulding")
append using `defpaulding_data'

// order and sort 
order county ym individuals_pa individuals_npa individuals households_pa households_npa households issuance avg_issuance_individuals avg_issuance_households adults children
sort county ym 

// save 
save "${dir_root}/data/state_data/ohio/ohio.dta", replace 

// check county
tab county

// assert everything adds up 
assert abs((individuals_pa + individuals_npa) - individuals) < 0.01 if !missing(individuals_pa)
assert abs((households_pa + households_npa) - households) < 0.01 if !missing(households_pa)



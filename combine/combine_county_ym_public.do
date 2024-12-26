// combine_county_ym_public.do
// Kelsey Pukelis
// 2024-12-20
// create public version of county-level data

// built off of dofile from SNAP COVID project:
// build_applications_county.do 
// Kelsey Pukelis
// 2022-05-17

// keep varlist -- copied from combine_state_ym.do
#delimit ;
    local keep_varlist_abridged
    households
    individuals
    issuance
    adults
    children
    infants
    elderly
    disabled
    /**/
    apps_received
    apps_approved
    apps_processed
    apps_denied
    apps_denied_needbased
    apps_denied_procedural
    /*don't include; California only*/
    /*
    apps_denied_untimely
    apps_denied_untimely_f
    */
    /*don't include; New Mexico only*/
    /*
    apps_withdrawn
    */
    /*apps_delinquent*/
    apps_expedited
    apps_expedited_elig
    apps_expedited_notelig
    /**/
    apps_timely 
    apps_untimely
    /*don't include; can calculate*/
    /*
    apps_timely_perc
    */
    apps_expedited_timely
    apps_expedited_untimely
    /*don't include; North Carolina only*/
    /*
    apps_notexpedited_timely
    apps_notexpedited_untimely
    */
    /**/
    /*don't include; California only*/
    /*
    households_carryover_start
    households_new 
    households_new_apps
    households_new_change_pacfnacf
    households_new_change_county
    households_new_reinstated
    households_new_other
    */
    /**/
    recerts
    recerts_approved
    recerts_denied
    recerts_denied_proc
    recerts_denied_need
    recerts_disposed
    recerts_elig 
    /*recerts_inelig*/
    recerts_overdue
    /**/
    medicaid_households
    medicaid_apps_received
    medicaid_apps_approved
    tanf_households
    tanf_individuals
    tanf_issuance
    tanf_children
    tanf_adults
    tanf_apps_received
    tanf_apps_approved
    tanf_apps_denied
    tanf_cases_closed
    /*
    childcare_children
    childcare_households
    eaedc_individuals
    eaedc_households
    */
    ;
    #delimit cr

// load data
use "${dir_root}/data/state_data/county_ym.dta", clear

// keep only vars I want 
keep state statefips county countyfips ym `keep_varlist_abridged'
// individuals households issuance adults children apps_received apps_approved apps_denied infants elderly disabled gender_* ethnicity_* race_*

// drop observations that don't have info 
dropmiss `keep_varlist_abridged', force obs 
// adults children apps_received apps_approved apps_denied infants elderly disabled gender_* ethnicity_* race_*, force obs 

// rename to shorten 
rename recerts_denied_procedural recerts_denied_proc
rename recerts_denied_needbased recerts_denied_need 

// replace state with proper capitalization
replace state = "new hampshire" if state == "newhampshire"
replace state = "new jersey" if state == "newjersey"
replace state = "new mexico" if state == "newmexico"
replace state = "new york" if state == "newyork"
replace state = "north carolina" if state == "northcarolina"
replace state = "north dakota" if state == "northdakota"
replace state = "rhode island" if state == "rhodeisland"
replace state = "south carolina" if state == "southcarolina"
replace state = "south dakota" if state == "southdakota"
replace state = "west virginia" if state == "westvirginia"
replace state = proper(state)

// statecountyfips
gen statecountyfips = statefips*1000 + countyfips 

// drop observations that are not at the county level 
drop if state == "Louisiana" & inlist(county,"virtual1","virtual2","virtual3","othervirtualtotals","other")

// assert level of the data 
duplicates tag statecountyfips ym, gen(dup)
assert dup == 0
drop dup 

// generate year and month vars 
gen year = year(dofm(ym))
gen month = month(dofm(ym))

// make sure variables are not missing
assert !missing(state)
assert !missing(statefips)
assert !missing(county)
assert !missing(countyfips)
assert !missing(ym)
assert !missing(year)
assert !missing(month)

// order and sort 
order state statefips county countyfips statecountyfips ym year month `keep_varlist_abridged'
sort statecountyfips ym 

// label vars
label var state "State name"
label var statefips "State FIPS code"
label var county "County name"
label var countyfips "County FIPS code"
label var statecountyfips "State and county FIPS code"
label var ym "Year and month"
label var year "Year"
label var month "Month"
label var individuals "Individuals enrolled in SNAP"
label var households "Households enrolled in SNAP"
label var issuance "Total SNAP benefits issued"
label var adults "Adults enrolled in SNAP"
label var children "Children enrolled in SNAP"
label var apps_received "SNAP applications received"
label var apps_approved "SNAP applications approved"
label var apps_denied "SNAP applications denied"
label var apps_denied_needbased "SNAP applications denied for a need-based/eligibility reason"
label var apps_denied_procedural "SNAP applications denied for a procedural reason"
label var apps_expedited "SNAP applications, expedited service"
label var apps_processed "SNAP applications processed this month"
label var apps_timely "SNAP applications processed within timely manner"
label var apps_untimely "SNAP applications processed within untimely manner"
// label var apps_timely_perc "SNAP applications processed within timely manner, as share of SNAP apps processed"
// label var apps_withdrawn "SNAP applications withdrawn"
label var apps_expedited_timely "SNAP expedited applications processed within timely manner"
label var apps_expedited_untimely "SNAP expedited applications processed within untimely manner"
// label var apps_notexpedited_timely "SNAP non-expedited applications processed within timely manner"
// label var apps_notexpedited_untimely "SNAP non-expedited applications processed within untimely manner"
label var apps_expedited_elig "SNAP expedited applications - found eligible for expedited service" 
label var apps_expedited_notelig "SNAP expedited applications - found not eligible for expedited service" 
// label var apps_denied_untimely "" 
// label var apps_denied_untimely_f "" 
label var recerts "SNAP recertifications"
label var recerts_approved "SNAP recertifications approved"
label var recerts_denied "SNAP recertifications denied"
label var recerts_denied_need "SNAP recertifications denied for a need-based/eligibility reason"
label var recerts_denied_proc "SNAP recertifications denied for a procedural reason"
label var recerts_disposed "SNAP recertifications disposed of during the month" 
label var recerts_elig "SNAP recertifications determined continuing eligible"
label var recerts_overdue "SNAP recertifications overdue during the month"
// label var recerts_inelig_f "" 
label var disabled "SNAP enrollment - disabled" // **KP: households or individuals?
label var elderly "SNAP enrollment - elderly" // **KP: households or individuals?
label var infants "SNAP enrollment - infants" // **KP: households or individuals?
label var tanf_households "Households enrolled in TANF"
label var tanf_adults "Adults enrolled in TANF"
label var tanf_children "Children enrolled in TANF"
label var tanf_individuals "Individuals enrolled in TANF"
label var tanf_issuance "Total TANF benefits issued"
label var tanf_apps_received "TANF applications received"
label var tanf_apps_approved "TANF applications approved"
label var tanf_apps_denied "TANF applications denied"
label var tanf_cases_closed "TANF cases closed"
label var medicaid_apps_received "Medicaid applications received"
label var medicaid_households "Medicaid households"
label var medicaid_apps_approved "Medicaid applications approved" 
// label var households_carryover_start ""
// label var households_new ""
// label var households_new_apps ""
// label var households_new_change_pacfnacf ""
// label var households_new_change_county ""
// label var households_new_reinstated ""
// label var households_new_other ""

**KP: make sure 2019 is not imputed

// save 
*check 


// save "${dir_root}/data/clean/county_ym_enrollment_detail_applications.dta", replace


***************************************************************************************************
/*
// log which time periods are covered
set linesize 200
capture log close 
*log using "${dir_logs}/county_time_coverage_public.log", replace 
levelsof state, local(states)
foreach state of local states {
	display in red "`state'"
	preserve
		qui keep if state == "`state'"
		qui dropmiss, force
		qui dropmiss, force obs 
		qui describe, varlist 
		dis in red "`r(varlist)'"
		*tab ym 
		sort ym 
		list ym if _n == 1
		qui sum ym if _n == 1
		local ym_min = `r(mean)'
		gsort -ym 
		list ym if _n == 1
		qui sum ym if _n == 1
		local ym_max = `r(mean)'
		// see if same number of counties at the start and end of the state's data
		qui count if ym == `ym_min'
		local num_counties_ym_min = `r(N)'
		qui count if ym == `ym_max'
		local num_counties_ym_max = `r(N)'
		capture noisily assert `num_counties_ym_min' == `num_counties_ym_max'
		dis in red "num_counties_ym_min = " `num_counties_ym_min'
		dis in red "num_counties_ym_max = " `num_counties_ym_max'
	restore 

}
log close 
*/
// accounting for missingness
**KP: ideally, should do this for each variable individually
gen missingness_code = 0 // 0 = not accounted for yet 
replace missingness_code = 1 if !missing(households) & households != 0 // 1 = not missing
replace missingness_code = 1 if !missing(individuals) & individuals != 0 & state_abbrev == "ID" // 1 = not missing
replace missingness_code = 1 if !missing(individuals) & individuals != 0 & state_abbrev == "PA" // 1 = not missing
replace missingness_code = 1 if !missing(issuance) & issuance != 0 & state_abbrev == "FL" // 1 = not missing

// states that don't have county level data
// AK
// CT
// DE
// GA
// HI
// IN
// KY
// MS
// NE
// NV
// NH
// ND
// OK
// RI
// UT
// VT
// WA
// WV
// WY

// merge in state abbreviation to help
statastates, name(state)
assert inlist(_m,2,3)
replace state = proper(state)
replace state = "District of Columbia" if state == "District Of Columbia"
#delimit ;
assert 	inlist(state,"Alaska","Connecticut","Delaware","Georgia","Hawaii") |
		inlist(state,"Indiana","Kentucky","Mississippi","Nebraska","Nevada") |
		inlist(state,"New Hampshire","North Dakota","Oklahoma","Rhode Island") |
		inlist(state,"Utah","Vermont","Washington","West Virginia","Wyoming") |
		inlist(state,"District of Columbia") if _m == 2
;
#delimit cr 
drop if _m == 2
assert _m == 3
drop _m 
drop state_fips

// missingness_code: 2 = date falls outside of state's available range
assert !missing(ym)
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "AL" & (ym < ym(2001,1)  | ym > ym(2024,1))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "AZ" & (ym < ym(2006,4)  | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "AR" & (ym < ym(2008,1)  | ym > ym(2019,8))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "CA" & (ym < ym(2016,7)  | ym > ym(2024,2))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "CO" & (ym < ym(2020,1)  | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "FL" & (ym < ym(1993,1)  | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "ID" & (ym < ym(2009,11) | ym > ym(2024,4))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "IL" & (ym < ym(2010,1)  | ym > ym(2024,3))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "IA" & (ym < ym(2016,7)  | ym > ym(2024,4))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "KS" & (ym < ym(2010,7)  | ym > ym(2023,9))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "LA" & (ym < ym(2000,7)  | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "ME" & (ym < ym(2005,1)  | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "MD" & (ym < ym(2007,7)  | ym > ym(2024,6))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "MA" & (ym < ym(2021,7)  | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "MI" & (ym < ym(2008,10) | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "MN" & (ym < ym(2014,1)  | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "MO" & (ym < ym(2008,10) | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "MT" & (ym < ym(2012,7) | ym > ym(2024,6))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "NJ" & (ym < ym(2007,1) | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "NM" & (ym < ym(2012,1) | ym > ym(2024,4))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "NY" & (ym < ym(2001,1) | ym > ym(2024,4))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "NC" & (ym < ym(2006,7) | ym > ym(2024,6))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "OH" & (ym < ym(2002,6) | ym > ym(2023,12))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "OR" & (ym < ym(2017,1) | ym > ym(2020,11))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "PA" & (ym < ym(2004,1) | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "SC" & (ym < ym(2008,3) | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "SD" & (ym < ym(2013,1) | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "TN" & (ym < ym(2011,1) | ym > ym(2024,5))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "TX" & (ym < ym(2014,1) | ym > ym(2024,6))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "VA" & (ym < ym(2001,9) | ym > ym(2001,9))
replace missingness_code = 2 if missingness_code == 0 & state_abbrev == "WI" & (ym < ym(2011,1) | ym > ym(2024,4))
    


tab missingness_code
br if missingness_code == 0
**KP: keep going here


**KP: I should check when values are 0, which could be instead of missing


check 

// log which vars are covered 
set linesize 200
capture log close 
log using "${dir_logs}/county_variable_coverage_public.log", replace 
foreach var of varlist _all {
  display in red "`var'"
  tab state if !missing(`var')
}
log close 


check


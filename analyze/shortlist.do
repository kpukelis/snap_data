// shortlist.do 
// Kelsey Pukelis
// create shortlist of states that have fixed statewide and county (partial) work requirement waivers 

local background_color white 
*************************************************************************************

// import data 
use "${dir_root}/data/state_data/state_ym.dta", clear 
// state ym level

// expand to balanced panel 
assert !missing(state)
encode state, gen(state_id)
order state_id, after(state)
label var state_id "just a number for each state, NOT state fips"
xtset state_id ym 
tsfill, full 
// replace state names 
levelsof state, local(state_names)
foreach s of local state_names {
	qui sum state_id if state == "`s'"
	assert `r(min)' == `r(max)'
	replace state = "`s'" if state_id == `r(min)' & missing(state)
}
assert !missing(state)

// mark non-missing NM_enrollment data 
gen NM_enrollment = (!missing(households) |  !missing(individuals) | !missing(issuance))
assert !missing(NM_enrollment)

// mark last month of data, for each state 
gen temp = ym if NM_enrollment == 1
bysort state: egen last_ym_enrollment_data = max(temp)
format last_ym_enrollment_data %tm 
assert !missing(last_ym_enrollment_data)
drop temp 

// shortlist of vars for now 
keep state ym NM_enrollment last_ym_enrollment_data

// generate yq variable 
gen year = year(dofm(ym))
gen quarter = quarter(dofm(ym))
gen yq = yq(year,quarter)
format yq %tq
drop year 
drop quarter

// yq version of last_ym_enrollment_data
gen last_year = year(dofm(last_ym_enrollment_data))
gen last_quarter = quarter(dofm(last_ym_enrollment_data))
gen last_yq_enrollment_data = yq(last_year,last_quarter)
format last_yq_enrollment_data %tq 
assert !missing(last_yq_enrollment_data)
drop last_year
drop last_quarter


**********************************************************************************************

// merge in basic waiver info 
merge m:1 state yq using "${dir_root}/data/state_data/waivers_quarter.dta"
// state-yq level

// mark if the state has any enrollment data 
gen temp = (NM_enrollment == 1)
bysort state: egen any_enrollment_data = max(temp)
drop temp 
*tab state any_enrollment_data
assert (any_enrollment_data == 0 | yq >= last_yq_enrollment_data) | yq >= yq(2021,1) if _m == 2
*br if _m == 2 & any_enrollment_data != 0 & yq < last_yq_enrollment_data
assert NM_enrollment == 0 | yq <= yq(2015,3) if _m == 1
rename _m _merge_data_waivers

**********************************************************************************************
// merge in clock info 
merge m:1 state using "${dir_root}/data/state_data/clocks_wide.dta"
// state level 
assert _merge == 3
drop _merge 

sort state yq ym 

**********************************************************************************************
// visualization of waivers 
/*
preserve 
use "${dir_root}/data/state_data/waivers_quarter.dta", clear 
twoway connected waiver_num yq, by(state)
restore 
*/

// binding yq 
gen bindingclockstart_yq = yq(year(dofm(bindingclockstart_ym)),quarter(dofm(bindingclockstart_ym)))
format bindingclockstart_yq %tq 

levelsof state, local(state_names)
foreach s of local state_names {
	qui sum bindingclockstart_yq if state == "`s'"
	if `r(N)' > 0 {
		assert `r(min)' == `r(max)'
		twoway connected waiver_num yq if state == "`s'" & yq >= yq(2015,3), ylabel(0(0.5)1) title("`s'") xtitle("") ytitle("statewide waiver") graphregion(fcolor(`background_color')) xline(`r(mean)') 
	}
	else {
		twoway connected waiver_num yq if state == "`s'"  & yq >= yq(2015,3), ylabel(0(0.5)1) title("`s'") xtitle("") ytitle("statewide waiver") graphregion(fcolor(`background_color'))
	}
	graph export "${dir_graphs}/waiver_`s'.png", replace as(png)
}
check



// list of states with partial waivers (doesn't have to be fixed statewide)

gen partial = ()

tab state if 


check


// mark if 


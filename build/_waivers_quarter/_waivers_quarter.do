// _waivers_quarter.do 
// Kelsey Pukelis 

// import data 
import excel "${dir_root}/data/policy_data/clock_data/snap_time_limits (1).xlsx", sheet("time_limit_waiver") allstring case(lower) clear 
dropmiss, force obs 

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

// drop bad observations 
drop if strpos(_state,"https://www.cbpp.org/research/food")

// reshape
rename _state statelong 
reshape long _, i(statelong) j(yearquarter) string 
rename _ waiver 
foreach var in statelong waiver {
	replace `var' = subinstr(`var', "`=char(9)'", " ", .)
	replace `var' = subinstr(`var', "`=char(10)'", " ", .)
	replace `var' = subinstr(`var', "`=char(13)'", " ", .)
	replace `var' = subinstr(`var', "`=char(14)'", " ", .)
	replace `var' = ustrregexra(`var'," ","")
}
drop if missing(statelong) & missing(waiver)

// clean statename 
replace statelong = strlower(statelong)
replace statelong = trim(statelong)
split statelong, parse("-")
drop statelong
rename statelong1 state
rename statelong2 state_abbrev 
replace state = ustrregexra(state," ","")
replace state_abbrev = ustrregexra(state_abbrev," ","")
drop state_abbrev

// clean waiver 
replace waiver = ustrregexra(waiver," ","")
assert inlist(waiver,"none","statewide","partial")
gen waiver_num = .
replace waiver_num = 0 if waiver == "none"
replace waiver_num = 1 if waiver == "statewide"
replace waiver_num = 0.5 if waiver == "partial"

// clean quarter
split yearquarter, parse("q")
rename yearquarter1 year 
rename yearquarter2 quarter
foreach v in year quarter {
	destring `v', replace 
	confirm numeric variable `v'
}
gen yq = yq(year,quarter)
format yq %tq 
drop year quarter
drop yearquarter

// assert balanced panel 
encode state, gen(state_num)
xtset state_num yq 
tsfill 
assert !missing(waiver)
drop state_num

// order and sort 
sort state yq 
order state yq waiver waiver_num

// save 
save "${dir_root}/data/state_data/waivers_quarter.dta", replace 


// clocks.do 
// Kelsey Pukelis


// import data 
import excel "${dir_root}/snap_time_limits (1).xlsx", sheet("clocks") firstrow allstring case(lower) clear 
dropmiss, force obs 

// drop unncessary vars 
drop notes
drop clockexacttext 
drop link
drop state_long

**KP: drop for now, so that there is only one binding 
drop bindingclockstartyear2 bindingclockstartyear3 bindingclockstartmonth2 bindingclockstartmonth3

// fix state 
*split state, parse("-")
*drop state2 state
*rename state1 state
replace state = trim(state)
replace state = ustrregexra(state," ","")
replace state = strlower(state)
drop if missing(state)

// check clocktype 
assert inlist(clocktype,"fixed statewide","fixed individual","rolling clock","unclear")

// reshape 
reshape long clockstartyear clockstartmonth /*bindingclockstartyear bindingclockstartmonth*/, i(state) j(num)
drop num 
rename bindingclockstartmonth1 bindingclockstartmonth
rename bindingclockstartyear1 bindingclockstartyear

// time vars 
destring clockstartmonth, replace 
destring clockstartyear, replace 
confirm numeric variable clockstartmonth
confirm numeric variable clockstartyear
gen clockstart_ym = ym(clockstartyear,clockstartmonth)
format clockstart_ym %tm 
drop clockstartyear clockstartmonth

destring bindingclockstartmonth, replace 
destring bindingclockstartyear, replace 
confirm numeric variable bindingclockstartmonth
confirm numeric variable bindingclockstartyear
gen bindingclockstart_ym = ym(bindingclockstartyear,bindingclockstartmonth)
format bindingclockstart_ym %tm 
drop bindingclockstartyear bindingclockstartmonth

// drop unncessary obs 
keep if (inlist(clocktype,"fixed statewide") & !missing(clockstart_ym)) | inlist(clocktype,"fixed individual","rolling clock","unclear")
duplicates drop 

// assert clockstart nonmissing if fixed statewide state 
assert !missing(clockstart_ym) if clocktype == "fixed statewide"

// order and sort 
order state clockstart_ym
sort state clockstart_ym

// add or subtract from clock
gen adjust_clock = .
replace adjust_clock = -1 if inlist(state,"arizona","arkansas","florida","georgia","iowa") | inlist(state,"kansas","maine","maryland","missouri","montana","southcarolina")
replace adjust_clock = 0 if inlist(state,"indiana") 
replace adjust_clock = 1 if inlist(state,"pennsylvania") 

// save 	
save "${dir_root}/data/state_data/clocks.dta", replace 

// wide version 
bysort state (clockstart_ym): gen num = _n
reshape wide clockstart_ym, i(state) j(num)
order state clocktype
save "${dir_root}/data/state_data/clocks_wide.dta", replace 


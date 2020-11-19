// georgia.do 

local year_start 				= 2010
local year_end 					= 2019

*********************************************************************

forvalues year = `year_start'(1)`year_end' {
if !inlist(`year',2013,2014) {

	display in red "year `year'"

	// import 
	import excel using "${dir_root}/state_data/georgia/excel/state/Desc Data_`year'.xlsx", allstring case(lower) clear

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	keep if strpos(v1,"CY") | strpos(v1,"SFY") | strpos(v1,"S FY")
	drop if strpos(v1,"SFY2012") & strpos(v8,"SFY2013")
	drop if strpos(v1,"SFY2014") & strpos(v1,"SFY2015")
	drop if strpos(v1,"SFY2014") & strpos(v8,"SFY2015")
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// assert shape of data 
	assert r(k) == 13
	assert r(N) == 6 | r(N) == 5

	// rename vars 
	rename v1 year_string 
	rename v2 m1
	rename v3 m2
	rename v4 m3
	rename v5 m4
	rename v6 m5
	rename v7 m6
	rename v8 m7
	rename v9 m8
	rename v10 m9
	rename v11 m10
	rename v12 m11
	rename v13 m12

	// year variable 
	replace year_string = trim(year_string)
	assert inlist(strlen(year_string),6,7,11)
	gen year_type = ""
	replace year_type = "CY" if strpos(year_string,"CY")
	replace year_type = "SFY" if strpos(year_string,"SFY") | strpos(year_string,"S FY")
	gen year = ""
	replace year = substr(year_string,-4,.) 
	destring year, replace
	drop year_string

	// reshape 
	reshape long m, i(year) j(month)
	rename m individuals

	// fix if state FY
**KP: could be plus 1 or minus 1
	replace year = year - 1 if year_type == "SFY" & inrange(month,1,6)
	recode month (7=1) (8=2) (9=3) (10=4) (11=5) (12=6) (1=7) (2=8) (3=9) (4=10) (5=11) (6=12) if year_type == "SFY"

	// ym var 
	gen ym = ym(year,month)
	format ym %tm 
	drop year month 

	// destring 
	destring individuals, replace 
	confirm numeric variable individuals

	// order and sort 
	order ym individuals 
	sort ym individuals 

	// save 
	tempfile _`year'
	save `_`year''
}
}

******************************************

// append all year's 
forvalues year = `year_start'(1)`year_end' {
if !inlist(`year',2013,2014) {
	if `year' == `year_start' {
		use `_`year'', clear
	}
	else {
		append using `_`year''
	}
}
}

// drop duplicates
drop year_type
duplicates drop

// get rid of more duplicates 
drop if ym == ym(2007,6) & individuals == 384481

// assert no more duplicates
bysort ym: assert _N == 1

// order and sort 
order ym individuals
sort ym 

// save 
save "${dir_root}/state_data/georgia/georgia.dta", replace 



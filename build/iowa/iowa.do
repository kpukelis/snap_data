
global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/iowa"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

**new format**
local ym_start 					= ym(2016,7)
local ym_end 					= ym(2020,3)

********************************************************************
// STATE TOTALS 

forvalues ym = `ym_start'(1)`ym_end' {

	dis in red "`ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	gen monthminus1 = month - 1
	gen yearminus1 = year - 1
	tostring month, replace 
	tostring monthminus1, replace
	replace month = "0" + month if strlen(month) == 1
	replace monthminus1 = "0" + monthminus1 if strlen(monthminus1) == 1
	local month = month
	display "`month'"
	local year = year 
	display "`year'"
	local monthminus1 = monthminus1
	display "`monthminus1'"
	local yearminus1 = yearminus1
	display "`yearminus1'"

	// import data 
	import excel "${dir_data}/csvs/newformat/FA-F1-2016 `year'-`month'.xlsx", allstring case(lower) clear
	dropmiss, force
	foreach v of varlist _all {
		replace `v' = trim(`v')
		replace `v' = strlower(`v')
	}
	gen obsnum = _n 

	// first get state totals 
	keep if inlist(A,"total households","total recipients","total allotments","overall average per household","overall average per recipient")
	dropmiss, force
	qui describe, varlist
	assert r(N) == 5
	assert r(k) == 6
	rename (`r(varlist)') (variable _`year'_`month' _`year'_`monthminus1' _`yearminus1'_`month' percentchange obsnum)
** watch out for jan/dec months
	drop percentchange
	reshape long _, i(variable) j(yyyy_mm) string 
	drop obsnum
	destring _, replace 
	gen year = substr(yyyy_mm,1,4)
	gen month = substr(yyyy_mm,6,7)
	destring year month, replace 
	gen ym = ym(year, month)
	format ym %tm 
	drop year month yyyy_mm
	replace variable = ustrregexra(variable," ","")
	reshape wide _, i(ym) j(variable) string 
	tempfile _`ym'
	save `_`ym''
}

forvalues ym = `ym_start'(1)`ym_end' {

	dis in red "`ym'"
	if `ym' == `ym_start' {
		use `_`ym'', clear
	} 
	else {
		append using `_`ym''
	}
}
drop if missing(ym) // comes from miss assigning one month less than january as 0, rather than 12 for december. This is fine because I have all the data I want otherwise
duplicates drop 
sort ym
bysort ym: assert _N == 1
sum ym
assert r(min) <= `ym_start'
assert r(max) == `ym_end'
save "${dir_data}/iowa.dta", replace 


********************************************************************

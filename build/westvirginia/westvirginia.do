// westvirginia.do
// Kelsey Pukelis
// 2022-06-25

local ym_start	 				= ym(2011,1)
local ym_end 					= ym(2022,5)

************************************************************

forvalues ym = `ym_start'(1)`ym_end' {

	// display
	dis in red `ym'

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	local month = month 
	display in red "`month'"
	gen monthname = ""
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
	local monthname = monthname
	display in red "`monthname'"
	local year = year 
	display in red "`year'"

	// import 
	import excel using "${dir_root}/data/state_data/westvirginia/excel/`year'/binder/Document Cloud/`monthname' `year' Secretary's Report.xlsx", case(lower) allstring clear

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	foreach v of varlist _all {
		replace `v' = subinstr(`v', "`=char(9)'", " ", .)
		replace `v' = subinstr(`v', "`=char(10)'", " ", .)
		replace `v' = subinstr(`v', "`=char(13)'", " ", .)
		replace `v' = subinstr(`v', "`=char(14)'", " ", .)
	}

	// get data
*	while !strpos(v2,"January") & !strpos(v2,"February") & !strpos(v2,"March") & !strpos(v2,"April") & !strpos(v2,"May") & !strpos(v2,"June") & !strpos(v2,"July") & !strpos(v2,"August") & !strpos(v2,"September") & !strpos(v2,"October") & !strpos(v2,"November") & !strpos(v2,"December") {
*		drop in 1
*	}
	if inrange(`ym',ym(2011,1),ym(2013,1)) | inrange(`ym',ym(2013,3),ym(2016,4)) {
		drop in 1 
		drop in 1 
		drop in 1 
	}
	else if inlist(`ym',ym(2013,2)) {
		drop in 1 
		drop in 1
	}
	else {
		drop in 1
	}
	// clean up variables
	dropmiss, force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	assert `r(k)' == 4 
	rename v2 monthA
	rename v3 monthB
	rename v4 change
	drop change

	// keep observations
	gen obsnum = _n
	order obsnum
	gen keep = 0
	replace keep = 1 if obsnum == 1
	sum obsnum if strpos(v1,"Supplemental Nutrition Assistance Program")
	assert `r(N)' == 1
	local snap_obs = `r(mean)'
	local snap_obs_plus1 = `snap_obs' + 1
	replace keep = 1 if obsnum == `snap_obs'
	replace keep = 1 if obsnum == `snap_obs_plus1'
	keep if keep == 1
	drop keep 
	drop v1 
	count 
	assert `r(N)' == 3
	gen varname = ""
	replace varname = "month_year" if _n == 1
	replace varname = "households" if _n == 2
	replace varname = "issuance"   if _n == 3
	order varname
	drop obsnum
	sxpose, clear firstnames
	
	// clean up date 
	split month_year, parse(" ")
	rename month_year1 monthname
	rename month_year2 year
	gen month = .
	replace month = 1 if monthname == "January"
	replace month = 2 if monthname == "February"
	replace month = 3 if monthname == "March"
	replace month = 4 if monthname == "April"
	replace month = 5 if monthname == "May"
	replace month = 6 if monthname == "June"
	replace month = 7 if monthname == "July"
	replace month = 8 if monthname == "August"
	replace month = 9 if monthname == "September"
	replace month = 10 if monthname == "October"
	replace month = 11 if monthname == "November"
	replace month = 12 if monthname == "December"
	assert !missing(month)
	assert !missing(year)
	destring year, replace
	confirm numeric variable year 
	gen ym = ym(year,month)
	format ym %tm 
	drop year 
	drop month 
	drop monthname
	drop month_year
	order ym 

	// clean up variables
	replace households = ustrregexra(households,"Households","")
	replace issuance = ustrregexra(issuance,"Benefits","")
	replace issuance = subinstr(issuance, "$", "",.)
	foreach var in households issuance {
		destring `var', replace ignore(",")
		confirm numeric variable `var'
	}

	// one manual fix 
	replace households = 146601 if households == 146.601 & ym == ym(2021,1)

	// file origin 
	gen ym_origin = `ym'
	format ym_origin %tm 

	// order and sort 
	order ym households issuance ym_origin
	sort ym 

	// save 
	tempfile _`ym'
	save `_`ym''

}

// append years 
forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// since all data is statewide, create "county"
gen county = "total"

*duplicates drop county ym households issuance, force
*duplicates tag county ym, gen(dup)
*assert dup == 0
*drop dup 

// drop duplicates
drop ym_origin
duplicates drop 

// manually drop duplicates 
// ym	households	issuance	ym_origin	county	dup
// 2021m12	151002	39777257	2022m1	total	1
// 2021m12	165972	74652874	2022m2	total	1
// deciding to keep earlier one
// data from origin 2022m2 onwards appears to come from a different source: "SNAP-OMAR"
// ym	households	issuance	county	dup
// 2014m9	162082	37788213	total	1
// 2014m9	162082	37778213	total	1
duplicates tag county ym, gen(dup)
count if ym == ym(2021,12) & households == 165972 & dup == 1
assert `r(N)' == 1
drop if ym == ym(2021,12) & households == 165972 & dup == 1
count if ym == ym(2014,9) & issuance == 37778213 & dup == 1
assert `r(N)' == 1
drop if ym == ym(2014,9) & issuance == 37778213 & dup == 1
drop dup 

// assert level of data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order and sort 
order county ym households issuance
sort county ym 

// save 
save "${dir_root}/data/state_data/westvirginia/westvirginia.dta", replace 

*dis ym(2016,1) + 3.5
*twoway connected households ym, xline(672) xline(675.5)
*twoway connected issuance ym, xline(672) xline(675.5)

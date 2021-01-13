// mississippi.do
// Kelsey Pukelis

local ym_start	 				= ym(2014,7)
local ym_end 					= ym(2020,4)

************************************************************
forvalues ym = `ym_start'(1)`ym_end' {
if !inlist(`ym',ym(2017,8),ym(2018,7),ym(2019,10),ym(2019,11)) {

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
	if inrange(`ym',ym(2017,1),ym(2019,12)) | `ym' >= ym(2020,1) {
		replace monthname = "Jan" if month == 1
		replace monthname = "Feb" if month == 2
		replace monthname = "Mar" if month == 3
		replace monthname = "Apr" if month == 4
		replace monthname = "May" if month == 5
		replace monthname = "Jun" if month == 6
		replace monthname = "Jul" if month == 7
		replace monthname = "Aug" if month == 8
		replace monthname = "Sep" if month == 9
		replace monthname = "Oct" if month == 10
		replace monthname = "Nov" if month == 11
		replace monthname = "Dec" if month == 12	
	}
	else {
		replace monthname = "jan" if month == 1
		replace monthname = "feb" if month == 2
		replace monthname = "mar" if month == 3
		replace monthname = "apr" if month == 4
		replace monthname = "may" if month == 5
		replace monthname = "jun" if month == 6
		replace monthname = "jul" if month == 7
		replace monthname = "aug" if month == 8
		replace monthname = "sep" if month == 9
		replace monthname = "oct" if month == 10
		replace monthname = "nov" if month == 11
		replace monthname = "dec" if month == 12	
	}
	local monthname = monthname
	display in red "`monthname'"
	local year_short = year_short 
	display in red "`year_short'"
	local year = year 
	display in red "`year'"

	// import 
	if inrange(`ym',ym(2014,7),ym(2015,12)) {
		import excel using "${dir_root}/data/state_data/mississippi/excel/`year'/binder/Document Cloud/rs`monthname'`year_short'r.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2016,1),ym(2017,12)) {
		import excel using "${dir_root}/data/state_data/mississippi/excel/`year'/binder/Document Cloud/`monthname'`year'MonthlyStatisticalReport.pdf_short.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2018,1),ym(2019,12)) {
		import excel using "${dir_root}/data/state_data/mississippi/excel/`year'/binder/Document Cloud/`monthname'`year_short'.pdf_short.xlsx", case(lower) allstring clear
	}
	else {
		import excel using "${dir_root}/data/state_data/mississippi/excel/`year'/binder/Document Cloud/`monthname'`year_short'.MSR_.pdf_short.xlsx", case(lower) allstring clear
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

	// only keep data I want 
	count if strpos(v1,"Households")
	assert `r(N)' == 1
	count if strpos(v1,"Persons")
	assert `r(N)' == 1
	count if strpos(v1,"BENEFIT VALUE")
	assert `r(N)' == 1
	keep if strpos(v1,"Households") | strpos(v1,"Persons") | strpos(v1,"BENEFIT VALUE") 

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
	assert `r(N)' == 3
	assert `r(k)' == 5

	// rename vars 
	rename v1 varnames 
	rename v2 number
	rename v3 avg_benefit
	rename v4 change_number
	rename v5 change_avg_benefit

	// drop unnecessary vars 
	capture drop change_number
	capture drop change_avg_benefit

	// ym 
	gen ym = `ym'
	format ym %tm 

	// reshape
	replace varnames = strlower(varnames)
	replace varnames = ustrregexra(varnames," ","")
	replace number = avg_benefit if missing(number) & !missing(avg_benefit) & varnames == "benefitvalue"
	replace avg_benefit = "" if number == avg_benefit & varnames == "benefitvalue"
	reshape wide number avg_benefit, i(ym) j(varnames) string 
	dropmiss, force 
	rename numberbenefitvalue 		issuance
	rename numberhouseholds 		households
	rename numberpersons 			individuals
	rename avg_benefithouseholds 	avg_benefit_households
	rename avg_benefitpersons 		avg_benefit_individuals

	// destring 
	foreach var in issuance households individuals avg_benefit_households avg_benefit_individuals {
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

	// order and sort 
	order ym households individuals issuance avg_benefit_households avg_benefit_individuals
	sort ym 

	// save 
	tempfile _`ym'
	save `_`ym''

}
}

// append years 
forvalues ym = `ym_start'(1)`ym_end' {
if !inlist(`ym',ym(2017,8),ym(2018,7),ym(2019,10),ym(2019,11)) {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}
}

// order and sort 
order ym households individuals issuance avg_benefit_households avg_benefit_individuals
sort ym 

// save 
save "${dir_root}/data/state_data/mississippi/mississippi.dta", replace 

**KP: 2019m2 probably too low due to gov shutdown

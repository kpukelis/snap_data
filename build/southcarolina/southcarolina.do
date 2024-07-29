// southcarolina.do
// imports households and individuals from excel sheets

local ym_start					= ym(2008,3)
local ym_end 					= ym(2024,5)
local prefix_2008 				"fs-"
local prefix_2009 				"fs-"
local prefix_2010 				"fs-"
local prefix_2011 				"fs-"
local prefix_2012 				"fs-"
local prefix_2013 				"fs-"
local prefix_2014 				"fs-"
local prefix_2015 				"fs-"
local prefix_2016 				"fs-"
local prefix_2017 				"fs_"
local prefix_2018 				"fs_"
local prefix_2019 				"fs_"
local prefix_2020 				"fs_"
local prefix_2021 				""
local prefix_2022 				""
local prefix_2023 				""
local prefix_2024 				""
local middle_2008 				""
local middle_2009 				""
local middle_2010 				""
local middle_2011 				""
local middle_2012 				""
local middle_2013 				""
local middle_2014 				""
local middle_2015 				""
local middle_2016 				""
local middle_2017 				"-"
local middle_2018 				"-"
local middle_2019 				""
local suffix_2008 				""
local suffix_2009 				""
local suffix_2010 				""
local suffix_2011 				""
local suffix_2012 				""
local suffix_2013 				""
local suffix_2014 				""
local suffix_2015 				""
local suffix_2016 				""
local suffix_2017 				""
local suffix_2018 				""
local suffix_2019 				""
local suffix_2020				""
local suffix_2021				"tab13"
local suffix_2022				"tab13_1"
local suffix_2023				"tab13_2"
local suffix_2024 				"tab13-2024"
local yearname_2008				"08"
local yearname_2009				"09"
local yearname_2010				"10"
local yearname_2011				"11"
local yearname_2012				"12"
local yearname_2013				"13"
local yearname_2014				"14"
local yearname_2015				"15"
local yearname_2016				"16"
local yearname_2017				"2017"
local yearname_2018				"2018"
local yearname_2019				"2019"
local yearname_2020 			"2020"
local yearname_2021 			"2021"
local yearname_2022 			"2022"
local yearname_2023 			"2023"
local yearname_2024 			"2024"

***************************************************************

forvalues ym = `ym_start'(1)`ym_end' {

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace
	replace month = "0" + month if strlen(month) == 1
	local month = month
	local year = year 
	display in red  "`year' `month'" 
	gen monthname = ""
	replace monthname = "jan" if month == "01"
	replace monthname = "feb" if month == "02"
	replace monthname = "mar" if month == "03"
	replace monthname = "apr" if month == "04"
	replace monthname = "may" if month == "05"
	replace monthname = "jun" if month == "06"
	replace monthname = "jul" if month == "07"
	replace monthname = "aug" if month == "08"
	replace monthname = "sep" if month == "09"
	replace monthname = "oct" if month == "10"
	replace monthname = "nov" if month == "11"
	replace monthname = "dec" if month == "12"
	local monthname = monthname

	if inrange(`ym',ym(2008,3),ym(2012,9)) | inrange(`ym',ym(2013,7),ym(2014,8)) {
		local firstvar foodstampparticipation
	}
	else {
		local firstvar snapparticipation
	}

	// import 
	if !inlist(`year',2021,2022,2023,2024) {
		import excel using "${dir_root}/data/state_data/southcarolina/excel/`year'/`prefix_`year''`yearname_`year''`middle_`year''`month'`suffix_`year''.xlsx", firstrow case(lower) allstring clear	
	}
	else {
		import excel using "${dir_root}/data/state_data/southcarolina/excel/`year'/`monthname'`suffix_`year''.xlsx", firstrow case(lower) allstring clear
	}
	
	dropmiss, force
	dropmiss, obs force
	replace `firstvar' = trim(`firstvar')
	while !strpos(`firstvar',"State Total") {
		drop in 1
	}
	count 
	assert r(N) > 0
	drop if strpos(`firstvar',"Division of Information Systems")

	// assert 5 variables
	describe, varlist
	assert r(k) == 7 
	rename (`r(varlist)') (county households individuals issuance monthlyavgfy_households monthlyavgfy_individuals fytodate_issuance)
	drop if missing(households) & missing(individuals) & missing(issuance) & missing(monthlyavgfy_households) & missing(monthlyavgfy_individuals) & missing(fytodate_issuance)

	// clean up county 
	rename county county_copy
	gen county = county_copy
	drop county_copy
	replace county = trim(county)
	replace county = strlower(county)
	replace county = ustrregexra(county," ","")

	// clean up variables
	drop monthlyavgfy_households monthlyavgfy_individuals fytodate_issuance

	foreach v in households individuals issuance {
		destring `v', replace 
		confirm numeric variable `v'
	}

	// date 
	gen ym = ym(`year',`month')
	format ym %tm

	// order and sort 
	order county ym households individuals issuance
	sort county ym 

	// save 
	tempfile _`ym'
	save `_`ym''

}

***********************************

forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// rename county 
replace county = "total" if county == "statetotal"

// order and sort 
order county ym households individuals issuance
sort county ym 

// save 
save "${dir_root}/data/state_data/southcarolina/southcarolina.dta", replace 
check 


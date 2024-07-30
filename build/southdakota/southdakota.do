// southdakota.do
// imports households and individuals from excel sheets

local ym_start					= ym(2013,1)
local ym_end 					= ym(2024,5)
local prefix_2013 				"websnap"
local prefix_2014 				"websnap"
local prefix_2015 				"snap_"
local prefix_2016 				"snap_"
local prefix_2017 				"snap_"
local prefix_2018 				"snap_"
local prefix_2019 				"snap_"
local prefix_2020 				"snap_"
local prefix_2021 				"snap_"
local prefix_2022 				"snap_"
local prefix_2023 				""
local prefix_2024 				""
local suffix_2013 				""
local suffix_2014 				"_1"
local suffix_2015 				""
local suffix_2016 				"_1"
local suffix_2017 				"_2"
local suffix_2018 				"_3"
local suffix_2019 				"_4"
local suffix_2020 				"_5"
local suffix_2021 				"_6"
local suffix_2022 				"_7"
local suffix_2023 				""
local suffix_2024 				"_1"

***************************************************************

forvalues ym = `ym_start'(1)`ym_end' {

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	local month = month
	local year = year 
	display in red  "`year' `month'" 

	// month names for file
	if inrange(`year',2023,2024) {
		if `month' == 1 {
			local monthname = "January"
		}
		if `month' == 2 {
			local monthname = "February"
		}
		if `month' == 3 {
			local monthname = "March"
		}
		if `month' == 4 {
			local monthname = "April"
		}
		if `month' == 5 {
			local monthname = "May"
		}
		if `month' == 6 {
			local monthname = "June"
		}
		if `month' == 7 {
			local monthname = "July"
		}
		if `month' == 8 {
			local monthname = "August"
		}
		if `month' == 9 {
			local monthname = "September"
		}
		if `month' == 10 {
			local monthname = "October"
		}
		if `month' == 11 {
			local monthname = "November"
		}
		if `month' == 12 {
			local monthname = "December"
		}		
	}
	else {
		if `month' == 1 {
			local monthname = "jan"
		}
		if `month' == 2 {
			local monthname = "feb"
		}
		if `month' == 3 {
			local monthname = "march"
		}
		if `month' == 4 {
			local monthname = "april"
		}
		if `month' == 5 {
			local monthname = "may"
		}
		if `month' == 6 {
			local monthname = "june"
		}
		if `month' == 7 {
			local monthname = "july"
		}
		if `month' == 8 {
			local monthname = "aug"
		}
		if `month' == 9 {
			local monthname = "sept"
		}
		if `month' == 10 {
			local monthname = "oct"
		}
		if `month' == 11 {
			local monthname = "nov"
		}
		if `month' == 12 {
			local monthname = "dec"
		}		
	}


	// import 
	import excel using "${dir_root}/data/state_data/southdakota/excel/`year'/`prefix_`year''`monthname'`suffix_`year''.xlsx", firstrow case(lower) allstring clear	

	dropmiss, force
	dropmiss, obs force
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	while !strpos(v1,"State Totals") & _n == 1 {
		drop in 1
	}
	assert strpos(v1,"State Totals") if _n == 1
	drop if v1 == "Supplemental Nutrition Assistance Program Data"
	drop if v1 == "Households Participating"
	drop if strpos(v1,"Average Monthly Benefit per Household is")
	drop if strpos(v1,"`year' Data")
	drop if v1 == "County"
	drop if v2 == "Totals"
	drop if v1 == "a) Data not shown to avoid disclosure of information for particular individuals"
	drop if strpos(v1,"SNAP Emergency Allotment expenditures are not included")
	drop if strpos(v1,"SNAP Emergency Allotment & P-EBT expenditures are not included")
	drop if strpos(v1,"SNAP Emergency Allotment")
	drop if strpos(v1,"January 2020 Data")

	// determine number of variables
	dis in red "`ym'"
	if !inlist(`ym',ym(2016,7),ym(2019,12),ym(2020,8)) & !inrange(`ym',ym(2021,1),ym(2024,5)) {
		describe, varlist
		assert r(k) == 9 | r(k) == 10
		if r(k) == 9 & `ym' < ym(2017,1) {
			rename (`r(varlist)') (v#), addnumber
			replace v2 = v3 if missing(v2) & !missing(v3)
			replace v4 = v5 if missing(v4) & !missing(v5)
			replace v6 = v7 if missing(v6) & !missing(v7)
			replace v8 = v9 if missing(v8) & !missing(v9)
			replace v3 = "" if v2 == v3 & !missing(v3)
			replace v5 = "" if v4 == v5 & !missing(v5)
			replace v7 = "" if v6 == v7 & !missing(v7)
			replace v9 = "" if v8 == v9 & !missing(v9)
		}
		if r(k) == 9 & `ym' >= ym(2017,2) {
			rename (`r(varlist)') (v#), addnumber
			replace v3 = v4 if missing(v3) & !missing(v4)
			replace v6 = v7 if missing(v6) & !missing(v7)
			replace v8 = v9 if missing(v8) & !missing(v9)
			replace v4 = "" if v3 == v4 & !missing(v4)
			replace v7 = "" if v6 == v7 & !missing(v7)
			replace v9 = "" if v8 == v9 & !missing(v9)
		}
		if r(k) == 10 {
			rename (`r(varlist)') (v#), addnumber
			replace v3 = v4 if missing(v3) & !missing(v4)
			replace v5 = v6 if missing(v5) & !missing(v6)
			replace v7 = v8 if missing(v7) & !missing(v8)
			replace v9 = v10 if missing(v9) & !missing(v10)
			replace v4 = "" if v3 == v4 & !missing(v4)
			replace v6 = "" if v5 == v6 & !missing(v6)
			replace v8 = "" if v7 == v8 & !missing(v8)
			replace v10 = "" if v9 == v10 & !missing(v10)
		}
		dropmiss, force
	}
	else {

	}

	// assert 5 variables
	describe, varlist
	assert r(k) == 5 | r(k) == 6
	if r(k) == 5 {
		rename (`r(varlist)') (county households individuals adults children)
	}
	if r(k) == 6 {
		rename (`r(varlist)') (county households individuals adults children issuance)
	}

	// clean up county 
	rename county county_copy
	gen county = county_copy
	drop county_copy
	replace county = trim(county)
	replace county = strlower(county)
	replace county = ustrregexra(county," ","")

	// clean up variables
	capture confirm variable issuance
	if !_rc {

	}
	else {
		gen issuance = ""
	}
	foreach v in households individuals adults children issuance {
		replace `v' = "0" if `v' == "a" // "a) Data not shown to avoid disclosure of information for particular individuals"
		destring `v', replace 
		confirm numeric variable `v'
	}

	// date 
	gen ym = ym(`year',`month')
	format ym %tm

	// order and sort 
	order county ym households individuals adults children
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

// replace county
replace county = "total" if county == "statetotals"

// order and sort 
order county ym households individuals adults children issuance
sort county ym 

// save 
save "${dir_root}/data/state_data/southdakota/southdakota.dta", replace 


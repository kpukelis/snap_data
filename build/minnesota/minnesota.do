// minnesota.do 
// Kelsey Pukelis

local year_start 				= 2014
local year_end 					= 2020
local ym_start 					= ym(2014,1)
local ym_end 					= ym(2020,5)
local file_2014 				"SNAP-Calendar-Year-2014-(XLS)_tcm1053-165235.xls"
local file_2015 				"snap-calendar-year-2015_tcm1053-166277.xlsx"
local file_2016 				"snap-cy2016-0717_tcm1053-304106.xlsx"
local file_2017 				"snap-cy2017_tcm1053-326886.xlsx"
local file_2018 				"snap-cy2018_tcm1053-371462.xlsx"
local file_2019 				"snap-cy2019_tcm1053-419399.xlsx"
local file_2020 				"snap-cy2020-0620_tcm1053-434874.xlsx"

*********************************************************************

forvalues year = `year_start'(1)`year_end' {
	forvalues month = 1(1)12 {

		display in red "year `year' month `month'"

		if `month' == 1 {
			local monthname "January"
		}
		else if `month' == 2 {
			local monthname "February"
		}
		else if `month' == 3 {
			local monthname "March"
		}
		else if `month' == 4 {
			local monthname "April"
		}
		else if `month' == 5 {
			local monthname "May"
		}
		else if `month' == 6 {
			local monthname "June"
		}
		else if `month' == 7 {
			local monthname "July"
		}
		else if `month' == 8 {
			local monthname "August"
		}
		else if `month' == 9 {
			local monthname "September"
		}
		else if `month' == 10 {
			local monthname "October"
		}
		else if `month' == 11 {
			local monthname "November"
		}
		else if `month' == 12 {
			local monthname "December"
		}

		// import 
		import excel using "${dir_root}/state_data/minnesota/`file_`year''", sheet("`monthname'") case(lower) allstring clear
	
		// initial cleanup
		dropmiss, force 
		dropmiss, obs force 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
	
		// drop top row
		while v1 != "County" {
			drop in 1
		}
	
		// drop non data row 
		drop if strpos(v1,"(SNAP is the federally-funded, state/county administered program formerly known as Food Stamps)")
		drop if strpos(v1,"Data includes stand-alone food issued through SNAP (federally-funded) and MFAP (state-funded),")
		drop if strpos(v1,"and SNAP and state-funded food issued through MFIP")
		drop if strpos(v1,"Effective January 1, 2015, Dodge, Steele, and Waseca county human services are now combined in the Minnesota Prairie County iance (MNPrairie).")
		drop if strpos(v1,"Effective January 1, 2015")
		drop if strpos(v1,"Red Lake Indian Resv Began August 2015")
		drop if strpos(v1,"Counties 20 and 81 deleted and combined with County 74 Eff Jul 2015")
*		drop if strpos(v1,"")
*		drop if strpos(v1,"")

		// rename vars 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		assert r(k) == 5
		rename v1 county_num 
		rename v2 county 
		rename v3 households
		rename v4 individuals
		rename v5 issuance
		drop in 1 

		// destring 
		foreach var in county_num households individuals issuance {
			replace `var' = subinstr(`var', "`=char(9)'", " ", .)
			replace `var' = subinstr(`var', "`=char(13)'", " ", .)
			replace `var' = subinstr(`var', "`=char(14)'", " ", .)
			replace `var' = ustrregexra(`var',"All","")
			replace `var' = ustrregexra(`var',"OTHER","")
			destring `var', replace 
			confirm numeric variable `var'
		}

		// clean up county 
		replace county = strlower(county)
		replace county = trim(county)

		// ym 
		gen ym = ym(`year',`month')
		format ym %tm 

		// order and sort 
		order county ym 
		sort county ym 

		// save 
		tempfile _`year'_`month'
		save `_`year'_`month''
	}

}

******************************************

forvalues ym = `ym_start'(1)`ym_end' {
	local year = year(dofm(`ym'))
	local month = month(dofm(`ym'))
	if `ym' == `ym_start' {
		use `_`year'_`month'', clear
	}
	else {
		append using `_`year'_`month''
	}
}

// clean up county 
replace county = "total" if inlist(county,"statewide","statewide total")

// drop if county is missing 
foreach var in households individuals issuance {
	assert missing(`var') if missing(county)
}
drop if missing(county)

// assert no duplicates
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order 
order county county_num ym households individuals issuance
sort county ym 

// save
save "${dir_root}/state_data/minnesota/minnesota.dta", replace

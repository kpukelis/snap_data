// colorado.do 
// Kelsey Pukelis

local ym_start 					= ym(2020,1)
local ym_end 					= ym(2020,5)
local year_start 				= 10
local year_end 					= 20

**************************************************************************

forvalues ym = `ym_start'(1)`ym_end' {

	// display ym 
	display in red "`ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, gen(monthname) 
	replace monthname = "0" + monthname if strlen(monthname) == 1
	gen year_short = year - 2000
	local month = month
	display in red "`month'"
	local monthname = monthname
	display in red "`monthname'"
	local year = year
	display in red "`year'"
	local year_short = year_short
	display in red "`year_short'"

	if inrange(`ym',ym(2020,1),ym(2020,12)) {
		// load data 
		import excel "${dir_root}/data/state_data/colorado/excel/Caseload by county_CY2020 YTD.xlsx", sheet("`monthname'`year_short'") allstring case(lower) firstrow clear 
	}
	// drop empty variables
	dropmiss, force 
	
	// rename variables 
	capture rename countyname					county 
	rename issuanceamount 						issuance 
	capture rename casecount 					households
	capture rename clientcount 					individuals
	capture rename countofcases 				households 
	capture rename countofclients 				individuals
	capture rename countofdistinctcases 		households 
	capture rename countofdistinctclients 		individuals
	capture rename countofnpacases 				households_npa
	capture rename countofnpaclients 			individuals_npa
	capture rename countofpacases 				households_pa 
	capture rename countofpaclients 			individuals_pa
	capture rename nonpublicassistancecases 	households_npa
	capture rename nonpublicassistanceclients 	individuals_npa
	capture rename publicassistancecases 		households_pa 
	capture rename publicassistanceclients 		individuals_pa

	// destring
	foreach v in households individuals issuance households_npa households_pa individuals_npa individuals_pa {
		destring `v', replace
		confirm numeric variable `v'
	}
	
	// lowercase county 
	replace county = strlower(county)
	
	// drop statewide average 
	drop if strpos(county,"statewide average")
	replace county = "state totals" if county == "statewide total"

	// ym 
	gen ym = ym(`year',`month')
	format ym %tm
	
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

// totals
replace county = "total" if county == "state totals"

// order and sort 
order county ym issuance households individuals households_npa individuals_npa households_pa individuals_pa
sort county ym 

// save 
save "${dir_root}/data/state_data/colorado/colorado.dta", replace 

**************************************************************************

clear
forvalues year = `year_start'(1)`year_end' {

	// display year 
	display in red "`year'"

	if `year' <= 19 {
		// load data 
		import excel "${dir_root}/data/state_data/colorado/excel/Average caseload_CY.xlsx", sheet("CY`year'") allstring case(lower) firstrow cellrange(A1:H66) clear
	}
	else {
		// load data 
		import excel "${dir_root}/data/state_data/colorado/excel/Caseload by county_CY2020 YTD.xlsx", sheet("CY AVG") allstring case(lower) firstrow clear 
	}
	// drop empty variables
	dropmiss, force 
	
	// rename variables 
	capture rename countyname					county 
	rename issuanceamount 						issuance 
	capture rename casecount 					households
	capture rename clientcount 					individuals
	capture rename countofcases 				households 
	capture rename countofclients 				individuals
	capture rename countofdistinctcases 		households 
	capture rename countofdistinctclients 		individuals
	capture rename countofnpacases 				households_npa
	capture rename countofnpaclients 			individuals_npa
	capture rename countofpacases 				households_pa 
	capture rename countofpaclients 			individuals_pa
	capture rename nonpublicassistancecases 	households_npa
	capture rename nonpublicassistanceclients 	individuals_npa
	capture rename publicassistancecases 		households_pa 
	capture rename publicassistanceclients 		individuals_pa

	// destring
	foreach v in households individuals issuance households_npa households_pa individuals_npa individuals_pa {
		destring `v', replace
		confirm numeric variable `v'
	}
	
	// lowercase county 
	replace county = strlower(county)
	
	// drop statewide average 
	drop if strpos(county,"statewide average")
	drop if strpos(county,"state total")
	drop if strpos(county,"statewide total")

	// drop missing observations
	drop if missing(county)

	// year 
	gen year = 2000 + `year'
	
	// assert size 
	count 
	assert r(N) == 64

	// save 
	tempfile _`year'
	save `_`year''

}

// append years 
clear
forvalues year = `year_start'(1)`year_end' {
	if `year' == `year_start' {
		use `_`year'', clear
	}
	else {
		append using `_`year''
	}
}

// order and sort 
order county year issuance households individuals households_npa individuals_npa households_pa individuals_pa
sort county year 

// save 
save "${dir_root}/data/state_data/colorado/colorado_year.dta", replace 

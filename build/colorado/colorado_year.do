// colorado_year.do 
// Kelsey Pukelis

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/colorado"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local year_start = 10
local year_end = 20

**************************************************************************

forvalues year = `year_start'(1)`year_end' {

	// display year 
	display in red "`year'"

	if `year' <= 19 {
		// load data 
		import excel "${dir_data}/excel/Average caseload_CY.xlsx", sheet("CY`year'") allstring case(lower) firstrow cellrange(A1:H66) clear
	}
	else {
		// load data 
		import excel "${dir_data}/excel/Caseload by county_CY2020 YTD (2).xlsx", sheet("CY AVG") allstring case(lower) firstrow clear 
	}
	// drop empty variables
	dropmiss, force 
	
	// rename variables 
	capture rename countyname					county 
	rename issuanceamount 						issuance 
	capture rename casecount 					households
	capture rename clientcount 					persons
	capture rename countofcases 				households 
	capture rename countofclients 				persons
	capture rename countofdistinctcases 		households 
	capture rename countofdistinctclients 		persons
	capture rename countofnpacases 				households_npa
	capture rename countofnpaclients 			persons_npa
	capture rename countofpacases 				households_pa 
	capture rename countofpaclients 			persons_pa
	capture rename nonpublicassistancecases 	households_npa
	capture rename nonpublicassistanceclients 	persons_npa
	capture rename publicassistancecases 		households_pa 
	capture rename publicassistanceclients 		persons_pa

	// destring
	foreach v in households persons issuance households_npa households_pa persons_npa persons_pa {
		destring `v', replace
		confirm numeric variable `v'
	}
	
	// lowercase county 
	replace county = strlower(county)
	
	// drop statewide average 
	drop if strpos(county,"statewide average")
	drop if strpos(county,"state total")
	drop if strpos(county,"statewide total")

	// year 
	gen year = 2000 + `year'
	
	// save 
	tempfile _`year'
	save `_`year''

}

// append years 
forvalues year = `year_start'(1)`year_end' {
	if `year' == `year_start' {
		use `_`year'', clear
	}
	else {
		append using `_`year''
	}
}

// order and sort 
order county year issuance households persons households_npa persons_npa households_pa persons_pa
sort county year 

// save 
save "${dir_data}/colorado_year.dta", replace 


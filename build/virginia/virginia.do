// virginia.do
// imports households and individuals from excel sheets

local ym_start 					= ym(2001,9)
local ym_end 					= ym(2020,4)

***********************************************************************************
forvalues ym = `ym_start'(1)`ym_end' {

	dis in red `ym'

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace 
	replace month = "0" + month if strlen(month) == 1
	local month = month
	display in red "`month'"
	local year = year 
	display in red "`year'"

	// import 
	if inrange(`ym',ym(2001,9),ym(2006,12)) {
		import delimited using "${dir_root}/state_data/virginia/csv/participation_`month'-`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2007,1),ym(2016,5)) {
		import delimited using "${dir_root}/state_data/virginia/csv/`month'-`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2016,6),ym(2017,7)) {
		import excel using "${dir_root}/state_data/virginia/xlsx/`month'-`year'.xlsx", allstring clear 
	}
	else if inrange(`ym',ym(2017,8),ym(2019,6)) {
		import excel using "${dir_root}/state_data/virginia/xls/`month'-`year'.xls", allstring clear 
	}
	else if inrange(`ym',ym(2019,7),ym(2019,12)) {
		import excel using "${dir_root}/state_data/virginia/xls/`month'-`year'_SNAP_Participation.xls", allstring clear 
	}
	else if inrange(`ym',ym(2020,1),ym(2020,4)) {
		import excel using "${dir_root}/state_data/virginia/xls/`month'_`year'_SNAP_Participation_Report.xls", allstring clear 
	}

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// all lowercase
	foreach v of varlist _all {
		replace `v' = trim(`v')
		replace `v' = strlower(`v')
	}

	// clean up top
	if inrange(`ym',ym(2001,9),ym(2016,6)) | inrange(`ym',ym(2019,7),ym(2020,2)) | inlist(`ym',ym(2020,4)) {
		while !strpos(v1,"locality") & !strpos(v2,"fips") {
			drop in 1
		}
		drop in 1

		// rename variables
		describe, varlist 
		assert r(k) == 11
		rename v1 county 
		rename v2 fips
		rename v3 households_pa 
		rename v4 households_npa
		rename v5 households
		rename v6 individuals_pa
		rename v7 individuals_npa
		rename v8 individuals
		rename v9 issuance_pa
		rename v10 issuance_npa
		rename v11 issuance

		// split up names
		gen region_detail = ""
		replace region_detail = "city" if strpos(county," city")
		replace county = ustrregexra(county," city","")
		replace region_detail = "county" if strpos(county," county") & !inlist(county,"bedford county/city","fairfax county/city/falls church","roanoke county/salem","fairfax county/fairfax/falls church")
		replace county = ustrregexra(county," county","") if !inlist(county,"bedford county/city","fairfax county/city/falls church","roanoke county/salem","fairfax county/fairfax/falls church")
		replace region_detail = "multi fips" if strpos(county,"multi fips") 
		replace county = ustrregexra(county," multi fips","")

	}
	else if inrange(`ym',ym(2016,7),ym(2019,6)) {
		while !strpos(v1,"region") & !strpos(v2,"locality") {
			drop in 1
		}
		drop in 1

		// rename variables
		describe, varlist 
		assert r(k) == 12
		rename v1 region 
		rename v2 county 
		rename v3 fips
		rename v4 households_pa 
		rename v5 households_npa
		rename v6 households
		rename v7 individuals_pa
		rename v8 individuals_npa
		rename v9 individuals
		rename v10 issuance_pa
		rename v11 issuance_npa
		rename v12 issuance

		// split up names
		gen region_detail = ""
		replace region_detail = "city" if strpos(county," city")
		replace county = ustrregexra(county," city","")
		replace region_detail = "county" if strpos(county," county") & !inlist(county,"bedford county/city","fairfax county/city/falls church","roanoke county/salem","fairfax county/fairfax/falls church")
		replace county = ustrregexra(county," county","") if !inlist(county,"bedford county/city","fairfax county/city/falls church","roanoke county/salem","fairfax county/fairfax/falls church")
		replace region_detail = "multi fips" if strpos(region,"multi fips")
		replace region = ustrregexra(region," multi fips","")
		
		// trim 
		replace region = trim(region)
	}
	else if inlist(`ym',ym(2020,3)) {
		while !strpos(v3,"region") & !strpos(v1,"locality") {
			drop in 1
		}
		drop in 1

		// rename variables
		describe, varlist 
		assert r(k) == 12
		rename v1 county 
		rename v2 fips 
		rename v3 region
		rename v4 households_pa 
		rename v5 households_npa
		rename v6 households
		rename v7 individuals_pa
		rename v8 individuals_npa
		rename v9 individuals
		rename v10 issuance_pa
		rename v11 issuance_npa
		rename v12 issuance

		// split up names
		gen region_detail = ""
		replace region_detail = "city" if strpos(county," city")
		replace county = ustrregexra(county," city","")
		replace region_detail = "county" if strpos(county," county") & !inlist(county,"bedford county/city","fairfax county/city/falls church","roanoke county/salem","fairfax county/fairfax/falls church")
		replace county = ustrregexra(county," county","") if !inlist(county,"bedford county/city","fairfax county/city/falls church","roanoke county/salem","fairfax county/fairfax/falls church")
		replace region_detail = "multi fips" if strpos(region,"multi fips")
		replace region = ustrregexra(region," multi fips","")
		
		// trim 
		replace region = trim(region)
	}


	// clean up totals
	drop if county == "region totals:"
	drop if county == "multi-fips agencies:"
	if `ym' == ym(2017,2) {
		drop if households == "56874" & missing(county) & missing(region) // manual drop
	}

	// mark type of region
	gen county_marker = (!missing(fips))
	gen multicounty_marker = (inlist(county,"alleghany/covington","bedford county/city","chesterfield/colonial heights","fairfax county/city/falls church","greensville/emporia","halifax/south boston") | inlist(county,"henry/martinsville","roanoke county/salem","rockbridge/buena vista/lexington","rockingham/harrisonburg","york/poquoson","staunton/augusta") | inlist(county,"staunton/augusta/waynesboro","fairfax county/fairfax/falls church","augusta/staunton/waynesboro"))
	capture replace multicounty_marker = 1 if inlist(region,"alleghany/covington","bedford county/city","chesterfield/colonial heights","fairfax county/city/falls church","greensville/emporia","halifax/south boston") | inlist(region,"henry/martinsville","roanoke county/salem","rockbridge/buena vista/lexington","rockingham/harrisonburg","york/poquoson","staunton/augusta") | inlist(region,"staunton/augusta/waynesboro","fairfax county/fairfax/falls church","augusta/staunton/waynesboro")
	gen region_marker = (inlist(county,"central","eastern","northern","piedmont","western") | inlist(county,"v1","e2","e1","n1","n2","w1","w2") | inlist(county,"v1","cr","er","pr","wr","nr"))
	capture replace region_marker = 1 if inlist(region,"central","eastern","northern","piedmont","western") & missing(county)
	gen state_marker = (inlist(county,"statewide"))
	capture replace state_marker = 1 if inlist(region,"statewide")
	assert county_marker + multicounty_marker + region_marker + state_marker == 1

	// destring 
	foreach var in households_pa households_npa households individuals_pa individuals_npa individuals issuance_pa issuance_npa issuance {
		destring `var', replace ignore(",")
		confirm numeric variable `var'
	}

	// date 
	gen ym = `ym'
	format ym %tm 

	// order and sort 
	order county fips ym 
	sort fips ym 

	// save 
	tempfile _`ym'
	save `_`ym''

	
}

*****************************************************


// append across months 
forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// destring fips
destring fips, replace

// standardize county vs. region name 
replace county = region if missing(county) & (inlist(region,"region","northern","eastern","central","rockingham/harrisonburg","statewide","western","piedmont") | inlist(region,"henry/martinsville","chesterfield/colonial heights","fairfax county/fairfax/falls church","alleghany/covington","rockbridge/buena vista/lexington","greensville/emporia","augusta/staunton/waynesboro","york/poquoson"))
replace region = "" if county == region & (inlist(region,"region","northern","eastern","central","rockingham/harrisonburg","statewide","western","piedmont") | inlist(region,"henry/martinsville","chesterfield/colonial heights","fairfax county/fairfax/falls church","alleghany/covington","rockbridge/buena vista/lexington","greensville/emporia","augusta/staunton/waynesboro","york/poquoson"))

// clean up county names 
// Note: between 2006m9-2007m1, they used 6 regions instead of 5: e1, e2, n1, n2, w1, w2
replace county = "alleghany/covington" if county != "alleghany/covington" & strpos(county,"alleghany") & strpos(county,"covington")
replace county = "augusta/staunton/waynesboro" if county != "augusta/staunton/waynesboro" & strpos(county,"augusta") & strpos(county,"staunton") & strpos(county,"waynesboro")
replace county = "fairfax county/city/falls church" if county == "fairfax county/fairfax/falls church"
replace county = "colonial heights" if county == "colonial hgts."
replace county = "central" if county == "cr"
replace county = "eastern" if county == "er"
replace county = "northern" if county == "nr"
replace county = "northern" if county == "pr" & ym == ym(2007,2) // one typo
replace county = "piedmont" if county == "pr"
replace county = "western" if county == "wr"
*bedford county/city
*chesterfield/colonial heights
*greensville/emporia
*halifax/south boston
*henry/martinsville
*roanoke county/salem 
*rockbridge/buena vista/lexington
*rockingham/harrisonburg
*staunton/augusta
replace county = "total" if county == "statewide"

// drop if no data 
#delimit ;
drop if
households_pa == 0 &
households_npa == 0 &
households == 0 &
individuals_pa == 0 &
individuals_npa == 0 &
individuals == 0 &
issuance_pa == 0 &
issuance_npa == 0 &
issuance == 0
;
#delimit cr

// order and sort 
order county fips ym 
sort fips ym 

// save 
save "${dir_root}/state_data/virginia/virginia.dta", replace





// virginia.do
// imports households and individuals from excel sheets

local ym_start 					= ym(2001,9)
local ym_end 					= ym(2022,10)

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
	gen monthname = ""
	replace monthname = "Jan" if month == "01"
	replace monthname = "Feb" if month == "02"
	replace monthname = "Mar" if month == "03"
	replace monthname = "Apr" if month == "04"
	replace monthname = "May" if month == "05"
	replace monthname = "Jun" if month == "06"
	replace monthname = "Jul" if month == "07"
	replace monthname = "Aug" if month == "08"
	replace monthname = "Sep" if month == "09"
	replace monthname = "Oct" if month == "10"
	replace monthname = "Nov" if month == "11"
	replace monthname = "Dec" if month == "12"
	local monthname = monthname
	gen year_short = year - 2000
	local year_short = year_short

	// import 
	if inrange(`ym',ym(2001,9),ym(2006,12)) {
		import delimited using "${dir_root}/data/state_data/virginia/csv/participation_`month'-`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2007,1),ym(2016,5)) {
		import delimited using "${dir_root}/data/state_data/virginia/csv/`month'-`year'.csv", delimiters(",") case(lower) stringcols(_all) clear
	}
	else if inrange(`ym',ym(2016,6),ym(2017,7)) {
		import excel using "${dir_root}/data/state_data/virginia/xlsx/`month'-`year'.xlsx", allstring clear 
	}
	else if inrange(`ym',ym(2017,8),ym(2019,6)) {
		import excel using "${dir_root}/data/state_data/virginia/xls/`month'-`year'.xls", allstring clear 
	}
	else if inrange(`ym',ym(2019,7),ym(2019,12)) {
		import excel using "${dir_root}/data/state_data/virginia/xls/`month'-`year'_SNAP_Participation.xls", allstring clear 
	}
	else if inrange(`ym',ym(2020,1),ym(2020,11)) {
		import excel using "${dir_root}/data/state_data/virginia/xls/`month'_`year'_SNAP_Participation_Report.xls", allstring clear 
	}
	else if inlist(`ym',ym(2020,12)) {
		import excel using "${dir_root}/data/state_data/virginia/xlsx/`month'_`year'_SNAP_Participation_Report.xlsx", allstring clear 
	}
	else if inlist(`ym',ym(2021,1)) {
		import excel using "${dir_root}/data/state_data/virginia/xlsx/`monthname'_`year_short'.xlsx", allstring clear 
	}
	else if inrange(`ym',ym(2021,2),ym(2021,8)) {
		import excel using "${dir_root}/data/state_data/virginia/xls/`monthname'_`year_short'.xls", allstring clear 
	}
	else if inrange(`ym',ym(2021,9),ym(2021,12)) {
		import excel using "${dir_root}/data/state_data/virginia/xls/SNAP_Participation_Report_`month'`year'.xls", allstring clear 
	}
	else if inlist(`ym',ym(2022,1)) {
		import excel using "${dir_root}/data/state_data/virginia/xls/`monthname'_`year'_Participation_Report.xls", allstring clear 
	}
	else if inlist(`ym',ym(2022,2)) {
		import excel using "${dir_root}/data/state_data/virginia/xlsx/`monthname'_`year'_Participation_Report.xlsx", allstring clear 
	}
	else if inrange(`ym',ym(2022,3),ym(2022,10)) {
		import excel using "${dir_root}/data/state_data/virginia/xls/`monthname'_`year'_Participation_Report.xls", allstring clear 
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

	// drop title rows 
	drop if strpos(v1,"region") & strpos(v1,"locality") & strpos(v1,"fips")
	drop if v5 == "**********  end of report  **********"

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
	else if inrange(`ym',ym(2020,5),ym(2022,10)) {
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


save "C:/Users/Kelsey/Desktop/snap_temp.dta", replace 
*/

use "C:/Users/Kelsey/Desktop/snap_temp.dta", clear

// get rid of slashes, spaces
replace county = ustrregexra(county,"\/","")
replace county = ustrregexra(county," ","") 

// need to address multicounty cases
#delimit ; 
local pairs
alleghanycovington
/*bedfordcountycity*/
chesterfieldcolonialheights
greensvilleemporia
halifaxsouthboston
henrymartinsville
roanokecountysalem
rockinghamharrisonburg
stauntonaugusta
yorkpoquoson
augustastauntonwaynesboro 
fairfaxcountycityfallschurch
rockbridgebuenavistalexington
; 
#delimit cr 

// drop observations that already have county data 
foreach pair of local pairs {
	drop if county == "`pair'"
}

// fix county names to match full fips data 
drop if county == "bedford" & fips == 19 & inrange(ym,ym(2001,9),ym(2014,2))
drop if county == "bedford" & fips == 515 & inrange(ym,ym(2001,9),ym(2014,4))
replace county = "bedford" if county == "bedfordcountycity"
replace region_detail = "county" if county == "roanoke" & fips == 161
replace county = "roanokecounty" if county == "roanoke" & fips == 161
replace region_detail = "city" if county == "roanoke" & fips == 770
replace county = "roanokecity" if county == "roanoke" & fips == 770
replace county = "fairfaxcity" if county == "fairfax" & region_detail == "city"
replace county = "fairfaxcounty" if county == "fairfax" & region_detail == ""
replace county = "fairfaxcounty" if county == "fairfax" & region_detail == "county"
replace county = "richmondcity" if county == "richmond" & region_detail == "city"
replace county = "richmondcounty" if county == "richmond" & region_detail == ""
replace county = "richmondcounty" if county == "richmond" & region_detail == "county"
replace county = "franklincity" if county == "franklin" & fips == 620
replace county = "franklincounty" if county == "franklin" & fips == 67
drop if county == "southboston"
drop if county == "cliftonforge"

// drop extra observations 
drop if county == "northern" & households_pa == 11827 & ym == ym(2007,2)
drop if county == "piedmont" & households_pa == 13673 & ym == ym(2007,4)

// assert level of data 
bysort county ym: assert _N == 1

// order and sort 
order county fips ym 
sort fips ym 

// save 
save "${dir_root}/data/state_data/virginia/virginia.dta", replace

**********************************************************************************************************
**********************************************************************************************************



// montana.do
// Kelsey Pukelis

/////////////////
// LATE LOCALS //
/////////////////

local ym_start_late				= ym(2017,7)
local ym_end_late 				= ym(2022,12) 
local first_county 				_state_total
#delimit ;
local county_list 
	_state_total      
	beaverhead        
	big_horn          
	blaine            
	broadwater        
	carbon            
	carter            
	cascade           
	chouteau          
	custer            
	daniels           
	dawson            
	deer_lodge        
	fallon            
	fergus            
	flathead          
	gallatin          
	garfield          
	glacier           
	golden_valley     
	granite           
	hill              
	jefferson         
	judith_basin      
	lake              
	lewis_and_clark   
	liberty           
	lincoln           
	madison           
	mccone            
	meagher           
	mineral           
	missoula          
	musselshell       
	park              
	petroleum         
	phillips          
	pondera           
	powder_river      
	powell            
	prairie           
	ravalli           
	richland          
	roosevelt         
	rosebud           
	sanders           
	sheridan          
	silver_bow        
	stillwater        
	sweet_grass       
	teton             
	toole             
	treasure          
	valley            
	wheatland         
	wilbaux           
	yellowstone      
; 
#delimit cr 

//////////////////
// EARLY LOCALS //
//////////////////

local ym_start	 				= ym(2012,7) 
local ym_end 					= ym(2017,7)

local cutoff_name630 			"park" // 2012m7
local cutoff_name631 			"park"
local cutoff_name632 			"park"
local cutoff_name633 			"park"
local cutoff_name634 			"pondera"
local cutoff_name635 			"musselshell"
local cutoff_name636 			"park" // 2013m1
local cutoff_name637 			"pondera"
local cutoff_name638 			"pondera"
local cutoff_name639 			"ravalli"
local cutoff_name640 			"ravalli"
local cutoff_name641 			"ravalli"
local cutoff_name642 			"powell"
local cutoff_name643 			"powell"
local cutoff_name644 			"powell"
local cutoff_name645 			"powell"
local cutoff_name646 			"powell"
local cutoff_name647 			"powell"
local cutoff_name648 			"powell"
local cutoff_name649 			"powell"
local cutoff_name650 			"powell"
local cutoff_name651 			"powell"
local cutoff_name652 			"powell"
local cutoff_name653 			"powell"
local cutoff_name654 			"powell"
local cutoff_name655 			"powell"
local cutoff_name656 			"powell"
local cutoff_name657 			"powell"
local cutoff_name658 			"powell"
local cutoff_name659 			"powell"
local cutoff_name660 			"powell"
local cutoff_name661 			"powell"
local cutoff_name662 			"powell"
local cutoff_name663 			"powell"
local cutoff_name664 			"powell"
local cutoff_name665 			"powell"
local cutoff_name666 			"powell"
local cutoff_name667 			"powell"
local cutoff_name668 			"powell"
local cutoff_name669 			"powell"
local cutoff_name670 			"powell"
local cutoff_name671 			"powell"
local cutoff_name672 			"powell"
local cutoff_name673 			"powell"
local cutoff_name674 			"powell"
local cutoff_name675 			"powell"
local cutoff_name676 			"powell"
local cutoff_name677 			"powell"
local cutoff_name678 			"powell"
local cutoff_name679 			"powell"
local cutoff_name680 			"powell"
local cutoff_name681 			"powell"
local cutoff_name682 			"powell"
local cutoff_name683 			"powell"
local cutoff_name684 			"powell"
local cutoff_name685 			"powell"
local cutoff_name686 			"powell"
local cutoff_name687 			"powell"
local cutoff_name688 			"powell"
local cutoff_name689 			"powell"
local cutoff_name690 			"powell"

local top_count630	 			= 34
local top_count631	 			= 34
local top_count632	 			= 34
local top_count633	 			= 34
local top_count634	 			= 37
local top_count635	 			= 33
local top_count636	 			= 34
local top_count637	 			= 37
local top_count638	 			= 37
local top_count639				= 41
local top_count640				= 41
local top_count641				= 41
local top_count642				= 39
local top_count643				= 39
local top_count644				= 39
local top_count645				= 39
local top_count646				= 39
local top_count647				= 39
local top_count648				= 39
local top_count649				= 39
local top_count650				= 39
local top_count651				= 39
local top_count652				= 39
local top_count653				= 39
local top_count654				= 39
local top_count655				= 39
local top_count656				= 39
local top_count657				= 39
local top_count658				= 39
local top_count659				= 39
local top_count660				= 39
local top_count661				= 39
local top_count662				= 39
local top_count663				= 39
local top_count664				= 39
local top_count665				= 39
local top_count666				= 39
local top_count667				= 39
local top_count668				= 39
local top_count669				= 39
local top_count670				= 39
local top_count671				= 39
local top_count672 				= 39
local top_count673 				= 39
local top_count674 				= 39
local top_count675 				= 39
local top_count676 				= 39
local top_count677 				= 39
local top_count678 				= 39
local top_count679 				= 39
local top_count680 				= 39
local top_count681 				= 39
local top_count682 				= 39
local top_count683 				= 39
local top_count684 				= 39
local top_count685 				= 39
local top_count686 				= 39
local top_count687 				= 39
local top_count688 				= 39
local top_count689 				= 39
local top_count690 				= 39
***************************************************************
/*
///////////////////////
// LATE DATA -  APPS //
///////////////////////

foreach county of local county_list {

	// display
	dis in red "county: `county'"

	// import 
	clear 
	capture import excel using "${dir_root}/data/state_data/montana/excel/`county'/ChimesApps.xlsx", allstring clear
	capture import excel using "${dir_root}/data/state_data/montana/excel/`county'/ChimesApps (1).xlsx", allstring clear
	count 
	assert `r(N)' > 0

	// drop obs I don't need 
	drop A // drop A if _n == 1 & A == "LessThan5Label"
	drop B // drop B if _n == 1 & B == "CountyLabel"

	// clean up 
	dropmiss, force 
	dropmiss, force obs 
	describe, varlist
	rename (`r(varlist)') (v#), addnumber
	assert `r(k)' <= 67
 
	// transpose 
	// sxpose, clear firstnames
	// rewriting this code because sxpose is no longer available...
	gen id = _n 
	ds id, not 
	reshape long v, i(id) j(which) string 
	reshape wide v, i(which) j(id) /*string*/
	destring which, replace 
	confirm numeric variable which 
	sort which 
	drop which 

	// turn first row into variable names 
	foreach var of varlist * {
		replace `var' = strlower(`var')
		replace `var' = subinstr(`var', "`=char(9)'", " ", .) if _n == 1
		replace `var' = subinstr(`var', "`=char(10)'", " ", .) if _n == 1
		replace `var' = subinstr(`var', "`=char(13)'", " ", .) if _n == 1
		replace `var' = subinstr(`var', "`=char(14)'", " ", .) if _n == 1
		replace `var' = ustrregexra(`var',"\-","") if _n == 1
		replace `var' = ustrregexra(`var',"\(","") if _n == 1
		replace `var' = ustrregexra(`var',"\)","") if _n == 1
		replace `var' = ustrregexra(`var',"/","") if _n == 1
		replace `var' = ustrregexra(`var'," ","") if _n == 1
		replace `var' = substr(`var',1,32) if _n == 1
		label variable `var' "`=`var'[1]'"
		rename `var' `=`var'[1]'
	}
	drop in 1

	// target obs 
	local target_obs = (`ym_end_late' - `ym_start_late' + 1)
	local target_obs2 =(`ym_end_late' - `ym_start_late' + 0)
	count
	display in red "actual obs: " `r(N)'
	display in red "target_obs: " `target_obs'
	display in red "target_obs2: " `target_obs2'
	assert (`r(N)' == `target_obs') | (`r(N)' == `target_obs2')

	// rename 
	rename program mmm_yyyy 
	rename medicaid apps_received_medicaid
	rename snap apps_received
	rename tanf apps_received_tanf
 
	// fix date 
	gen month = substr(mmm_yyyy,1,3)
	gen year = substr(mmm_yyyy,5,4)
	replace month = "1" if month == "jan"
	replace month = "2" if month == "feb"
	replace month = "3" if month == "mar"
	replace month = "4" if month == "apr"
	replace month = "5" if month == "may"
	replace month = "6" if month == "jun"
	replace month = "7" if month == "jul"
	replace month = "8" if month == "aug"
	replace month = "9" if month == "sep"
	replace month = "10" if month == "oct"
	replace month = "11" if month == "nov"
	replace month = "12" if month == "dec"
	destring month, replace
	confirm numeric variable month
	destring year, replace
	confirm numeric variable year 
	gen ym = ym(year,month)
	format ym %tm 
	drop year month 
	drop mmm_yyyy

	// destring 
	foreach var in apps_received_medicaid apps_received apps_received_tanf {
		destring `var', replace ignore(",")
		confirm numeric variable `var'
	}

	// county 
	gen county = "`county'"

	// lower case 
	foreach var in county {
		replace `var' = strlower(`var')
		replace `var' = trim(`var')
	}
	replace county = "total" if strpos(county,"total")

	// assert level of data - after reshape 
	duplicates tag county ym, gen(dup)
	assert dup == 0
	drop dup 

	// order and sort 
	order county ym apps_received apps_received_tanf apps_received_medicaid
	sort county ym 

	// save 
	tempfile `county'
	save ``county''

}

// append across counties 
foreach county of local county_list {
	if "`county'" == "`first_county'" {
		use ``county'', clear
	}
	else {
		append using ``county''
	}
}

// change name of state total 
replace county = "total" if county == "state totals"
replace county = ustrregexra(county,"_","")
replace county = ustrregexra(county," ","")
replace county = "wibaux" if county == "wilbaux"

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order and sort 
order county ym 
sort county ym 

// save 
tempfile montana_late_apps
save `montana_late_apps'
save "${dir_root}/data/state_data/montana/montana_late_apps.dta", replace
 
*/
/////////////////////////////
// LATE DATA -  ENROLLMENT //
/////////////////////////////

foreach type in Recips House Expend {

foreach county of local county_list {

	// display
	dis in red "county: `county'"

	// import 
	clear 
	capture import excel using "${dir_root}/data/state_data/montana/excel/`county'/AL300_`type' (1).xlsx", allstring clear
	capture import excel using "${dir_root}/data/state_data/montana/excel/`county'/AL300_`type'.xlsx", allstring clear
	count 
	assert `r(N)' > 0
	
	// clean up 
	dropmiss, force 
	dropmiss, force obs 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// transpose 
	// sxpose, clear firstnames
	// rewriting this code because sxpose is no longer available...
	gen id = _n 
	ds id, not 
	reshape long v, i(id) j(which) string 
	reshape wide v, i(which) j(id) /*string*/
	destring which, replace 
	confirm numeric variable which 
	sort which 
	drop which 
 
	// turn first row into variable names 
	foreach var of varlist * {
		replace `var' = strlower(`var')
		replace `var' = "_" + `var' if _n == 1
		replace `var' = ustrregexra(`var',"-","") if _n == 1
		*replace `var' = ustrregexra(`var',".","") if _n == 1
		*replace `var' = ustrregexra(`var'," ","") if _n == 1
		label variable `var' "`=`var'[1]'"
		rename `var' `=`var'[1]'
	}
	drop in 1 
	
	*if "`type'" == "Recips" {
*		drop in 1 
*	}

	// rename 
	rename _ mmm_yyyy
	if "`type'" == "Recips" {
		rename _snap individuals
		rename _tanf individuals_tanf
	}
	else if "`type'" == "House" {
		rename _snap households 
		rename _tanf households_tanf
	}
	else if "`type'" == "Expend" {
		rename _snap issuance 
		rename _tanf issuance_tanf
	}

	// drop extras
	if "`type'" == "Recips" {
		drop if strpos(individuals,"due to privacy concerns all monthly counts for the individual")
	}
	else if "`type'" == "House" {
		drop if strpos(households,"due to privacy concerns all monthly counts for the individual")
	}
	else if "`type'" == "Expend" {
		drop if strpos(issuance,"due to privacy concerns all monthly amounts for the individual")
	}

	// target obs 
	count
	local target_obs = (`ym_end_late' - `ym_start_late' + 1)
	display in red "actual obs: " `r(N)'
	display in red "target_obs: " `target_obs'
	assert (`r(N)' == `target_obs') 

	// fix date 
	gen month = substr(mmm_yyyy,1,3)
	gen year = substr(mmm_yyyy,5,4)
	replace month = "1" if month == "jan"
	replace month = "2" if month == "feb"
	replace month = "3" if month == "mar"
	replace month = "4" if month == "apr"
	replace month = "5" if month == "may"
	replace month = "6" if month == "jun"
	replace month = "7" if month == "jul"
	replace month = "8" if month == "aug"
	replace month = "9" if month == "sep"
	replace month = "10" if month == "oct"
	replace month = "11" if month == "nov"
	replace month = "12" if month == "dec"
	destring month, replace
	confirm numeric variable month
	destring year, replace
	confirm numeric variable year 
	gen ym = ym(year,month)
	format ym %tm 
	drop year month 
	drop mmm_yyyy

	// destring 
	foreach var in individuals individuals_tanf households households_tanf issuance issuance_tanf {
		capture confirm variable `var'
		if !_rc {
			destring `var', replace ignore(",")
			confirm numeric variable `var'
		}
	}

	// county 
	gen county = "`county'"

	// lower case 
	foreach var in county {
		replace `var' = strlower(`var')
		replace `var' = trim(`var')
	}
	replace county = "total" if strpos(county,"total")

	// assert level of data - after reshape 
	duplicates tag county ym, gen(dup)
	assert dup == 0
	drop dup 

	// assert level of data - after reshape 
	duplicates tag county ym, gen(dup)
	assert dup == 0
	drop dup 

	// order and sort 
	order county ym 
	sort county ym 
 
	// save 
	tempfile `county'_`type'
	save ``county'_`type''

}

// append across counties 
foreach county of local county_list {
	if "`county'" == "`first_county'" {
		use ``county'_`type'', clear
	}
	else {
		append using ``county'_`type''
	}
}

// change name of state total 
replace county = "total" if county == "state totals"
replace county = ustrregexra(county,"_","")
replace county = ustrregexra(county," ","")
replace county = "wibaux" if county == "wilbaux"

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order and sort 
order county ym 
sort county ym 

// save 
tempfile montana_late_`type'
save `montana_late_`type''

}

// merge 
use `montana_late_Recips', clear 
merge 1:1 county ym using `montana_late_House'
assert _m == 3
drop _m 
merge 1:1 county ym using `montana_late_Expend'
assert _m == 3 
drop _m 

// save 
save "${dir_root}/data/state_data/montana/montana_late_enrollment.dta", replace
check 
*/
////////////////
// EARLY DATA //
////////////////
/*
forvalues ym = `ym_start'(1)`ym_end' {

	dis in red `ym' %tm

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace 
	replace month = "0" + month if strlen(month) == 1
	local month = month
	display "`month'"
	local year = year 
	display "`year'"

	// import 
	import delimited using "${dir_root}/data/state_data/montana/csvs/tabula-`year'-`month'.csv", delimiters(",") case(lower) stringcols(_all) clear

	// mark observation with Powell county
	replace v1 = trim(v1)
	replace v1 = strlower(v1)
	replace v1 = ustrregexra(v1,"\."," ")
	replace v1 = ustrregexra(v1," ","")
	gen obsnum = _n
	dis in red `ym'
	dis in red "`cutoff_name`ym''"
	sum obsnum if v1 == `"`cutoff_name`ym''"'
	assert r(N) == 1
	local cutoff_num`ym' = r(mean)

	// work with top table first
	preserve
	display `cutoff_num`ym''
	drop if obsnum > `cutoff_num`ym''
	drop obsnum
	dropmiss, force

	// assert number of variables
	qui describe
	assert r(k) <= 9
	drop in 1
	drop in 1
	count 
	assert r(N) == `top_count`ym'' 
	foreach v of varlist _all {
		replace `v' = ustrregexra(`v'," ","")
		replace `v' = ustrregexra(`v',"$","")
		replace `v' = ustrregexra(`v',"$","")
		replace `v' = ustrregexra(`v',"-","")
		replace `v' = ustrregexra(`v',",","")
		qui tab `v'
		if r(r) == 1 {
			drop `v' // variable has one value, contains no information
		}
	}
	dropmiss, force
	qui describe
	if `ym' <= ym(2012,10) {
		assert r(k) == 8

		// rename vars 
		qui describe, varlist 	
		rename (`r(varlist)') (county households individuals households_pa households_npa issuance issuance_percase issuance_perrecip)

		// clean 
		replace county = strlower(county)
		destring households individuals households_pa households_npa issuance issuance_percase	issuance_perrecip, replace ignore("$")

	}
	else {
		assert r(k) == 6

		// rename vars 
		qui describe, varlist 	
		rename (`r(varlist)') (county households individuals issuance issuance_percase issuance_perrecip)

		// clean 
		replace county = strlower(county)
		destring households individuals issuance issuance_percase	issuance_perrecip, replace ignore("$")

	}

	// ym
	gen ym = `ym'
	format ym %tm 

	// save top table
	tempfile _`ym'_top
	save `_`ym'_top'
	restore
	

	// work with bottom half of table 
	preserve
	drop if obsnum <= `cutoff_num`ym''
	drop obsnum
	dropmiss, force

	// assert number of variables
	qui describe
	assert r(k) <= 9
	drop in 1
	drop in 1
	count 
	assert r(N) == 57 - `top_count`ym''
	foreach v of varlist _all {
		replace `v' = ustrregexra(`v'," ","")
		replace `v' = ustrregexra(`v',"$","")
		replace `v' = ustrregexra(`v',"$","")
		replace `v' = ustrregexra(`v',"-","")
		replace `v' = ustrregexra(`v',",","")
		qui tab `v'
		if r(r) == 1 {
			drop `v' // variable has one value, contains no information
		}
	}
	dropmiss, force
	qui describe
	if `ym' <= ym(2012,10) {
		assert r(k) == 8

		// rename vars 
		qui describe, varlist 	
		rename (`r(varlist)') (county households individuals households_pa households_npa issuance issuance_percase issuance_perrecip)

		// clean 
		replace county = strlower(county)
		replace county = "total" if strpos(county,"total")
		destring households individuals households_pa households_npa issuance issuance_percase	issuance_perrecip, replace ignore("$")

	}
	else {
		assert r(k) == 6

		// rename vars 
		qui describe, varlist 	
		rename (`r(varlist)') (county households individuals issuance issuance_percase issuance_perrecip)

		// clean 
		replace county = strlower(county)
		replace county = "total" if strpos(county,"total")
		destring households individuals issuance issuance_percase	issuance_perrecip, replace ignore("$")

	}

	// ym
	gen ym = `ym'
	format ym %tm 

	// save bottom table
	tempfile _`ym'_bottom
	save `_`ym'_bottom'
	restore

	// append top and bottom
	clear 
	use `_`ym'_top', clear 
	append using `_`ym'_bottom'
	tempfile _`ym'
	save `_`ym''

}

forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// standardize county name 
replace county = ustrregexra(county,"\&","and")

// save 
tempfile montana_early
save `montana_early'
save "${dir_root}/data/state_data/montana/montana_early.dta", replace
*/
///////////////////////////
// MERGE AND APPEND DATA //
///////////////////////////

// merge
*use `montana_late_enrollment', clear 
use "${dir_root}/data/state_data/montana/montana_late_enrollment.dta", clear 
*merge 1:1 county ym using `montana_late_apps'
merge 1:1 county ym using "${dir_root}/data/state_data/montana/montana_late_apps.dta"
assert inlist(_m,1,3)
assert ym == ym(2019,10) if _m == 1 // data happens to be missing for some counties this month 
drop _m 

*merge 1:1 county ym using `montana_early', update 
merge 1:1 county ym using "${dir_root}/data/state_data/montana/montana_early.dta", update
assert inlist(_m,1,2,3)
assert _m == 3 if ym == ym(2017,7)
assert inrange(ym,`ym_start',`ym_end') if _m == 2
assert inrange(ym,`ym_start_late',`ym_end_late') if _m == 1
drop _m 

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order and sort 
order county ym 
sort county ym 

// save
save "${dir_root}/data/state_data/montana/montana.dta", replace

tab county 
tab ym 



// montana.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/montana"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

*local ym_start	 				= ym(2012,7)
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
	import delimited using "${dir_root}/csvs/tabula-`year'-`month'.csv", delimiters(",") case(lower) stringcols(_all) clear

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
		rename (`r(varlist)') (county cases recips pa npa issuance issuance_percase issuance_perrecip)

		// clean 
		replace county = strlower(county)
		destring cases recips pa npa issuance issuance_percase	issuance_perrecip, replace ignore("$")

	}
	else {
		assert r(k) == 6

		// rename vars 
		qui describe, varlist 	
		rename (`r(varlist)') (county cases recips issuance issuance_percase issuance_perrecip)

		// clean 
		replace county = strlower(county)
		destring cases recips issuance issuance_percase	issuance_perrecip, replace ignore("$")

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
		rename (`r(varlist)') (county cases recips pa npa issuance issuance_percase issuance_perrecip)

		// clean 
		replace county = strlower(county)
		replace county = "total" if strpos(county,"total")
		destring cases recips pa npa issuance issuance_percase	issuance_perrecip, replace ignore("$")

	}
	else {
		assert r(k) == 6

		// rename vars 
		qui describe, varlist 	
		rename (`r(varlist)') (county cases recips issuance issuance_percase issuance_perrecip)

		// clean 
		replace county = strlower(county)
		replace county = "total" if strpos(county,"total")
		destring cases recips issuance issuance_percase	issuance_perrecip, replace ignore("$")

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
save "${dir_root}/montana.dta", replace

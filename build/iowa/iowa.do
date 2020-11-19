// iowa.do 

**old format**
**KP: not digitized yet

**new format**
local ym_start 					= ym(2016,7)
local ym_end 					= ym(2020,3)

********************************************************************
// STATE TOTALS 

forvalues ym = `ym_start'(1)`ym_end' {

	dis in red "`ym'"

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	gen monthminus1 = month - 1
	gen yearminus1 = year - 1
	tostring month, replace 
	tostring monthminus1, replace
	replace month = "0" + month if strlen(month) == 1
	replace monthminus1 = "0" + monthminus1 if strlen(monthminus1) == 1
	local month = month
	display "`month'"
	local year = year 
	display "`year'"
	local monthminus1 = monthminus1
	display "`monthminus1'"
	local yearminus1 = yearminus1
	display "`yearminus1'"

	// import data 
	import excel "${dir_root}/state_data/iowa/csvs/newformat/FA-F1-2016 `year'-`month'.xlsx", allstring case(lower) clear
	dropmiss, force
	foreach v of varlist _all {
		replace `v' = trim(`v')
		replace `v' = strlower(`v')
	}
	gen obsnum = _n 

	// get data
	// use list of variables nonmissing for the state total row
	preserve
	keep if inlist(A,"state total")
	dropmiss, force 
	qui describe, varlist
	local keep_varlist `r(varlist)'
	restore

	// keep such variables, then keep all observations where at least one of the quant vars is nonmissing
	keep `keep_varlist'
	rename (`keep_varlist') (county snap_fip_households snap_fip_individuals snap_fip_issuance snap_medassist_households snap_medassist_individuals snap_medassist_issuance snap_hawki_households snap_hawki_individuals snap_hawki_issuance snap_only_households snap_only_individuals snap_only_issuance households individuals issuance participation_rate obsnum)
	if inrange(`ym',ym(2017,9),ym(2019,9)) {
		dropmiss snap_fip_households snap_fip_individuals snap_fip_issuance snap_medassist_households snap_medassist_individuals snap_medassist_issuance snap_hawki_households /*snap_hawki_individuals*/ /*snap_hawki_issuance*/ snap_only_households /*snap_only_individuals*/ snap_only_issuance households individuals issuance /*participation_rate*/, force obs
	}
	else if `ym' >= ym(2019,10) {
		dropmiss snap_fip_households snap_fip_individuals /*snap_fip_issuance*/ snap_medassist_households snap_medassist_individuals /*snap_medassist_issuance*/ snap_hawki_households /*snap_hawki_individuals*//* snap_hawki_issuance*/ snap_only_households /*snap_only_individuals*/ snap_only_issuance households individuals issuance /*participation_rate*/, force obs
	}
	else {
		dropmiss snap_fip_households snap_fip_individuals snap_fip_issuance snap_medassist_households snap_medassist_individuals snap_medassist_issuance snap_hawki_households /*snap_hawki_individuals*/ snap_hawki_issuance snap_only_households snap_only_individuals snap_only_issuance households individuals issuance participation_rate, force obs
	}
	drop if inlist(county,"area total") 

	// assert size of the resulting dataset
	describe, varlist
	assert r(N) == 101
	assert r(k) == 18

	/* NO NEED FOR THIS ANYMORE; THE ABOVE CODE IS A SUBSTITUTE AND DOES NOT DEPEND ON A SPECIFIC LIST OF COUNTIES
	#delimit ;
	keep if inlist(A,"dhs","audubon","buena vista","carroll","cass") |
			inlist(A,"cherokee","clay","crawford","dickinson","emmet") |
			inlist(A,"fremont","greene","guthrie","harrison","ida") |
			inlist(A,"kossuth","lyon","mills","monona","montgomery") |
			inlist(A,"o brien","osceola","page","palo alto","plymouth") |
			inlist(A,"pottawattamie","sac","shelby","sioux","taylor") |
			inlist(A,"woodbury","allamakee","black hawk","bremer") |
			inlist(A,"buchanan","butler","calhoun","cerro gordo","chickasaw") |
			inlist(A,"clayton","delaware","fayette","floyd","franklin") |
			inlist(A,"grundy","hamilton","hancock","hardin","howard") |
			inlist(A,"humboldt","marshall","mitchell","pocahontas") |
			inlist(A,"webster","winnebago","winneshiek","worth","wright") |
			inlist(A,"cedar","clinton","des moines","dubuque","henry") |
			inlist(A,"jackson","lee","louisa","muscatine","scott") |
			inlist(A,"appanoose","benton","davis","iowa","jasper") |
			inlist(A,"jefferson","johnson","jones","keokuk","linn","mahaska") |
			inlist(A,"monroe","poweshiek","tama","van buren") |
			inlist(A,"wapello","washington","adair","adams","boone","clarke") |
			inlist(A,"dallas","decatur","lucas","madison","marion") |
			inlist(A,"polk","ringgold","story","union","warren") |
			inlist(A,"wayne")
	;
	*drop if inlist(A,"area total") ;
	*drop if inlist(A,"state total") ;
	#delimit cr 
	dropmiss, force 
	*/

	// destring vars 
	foreach var in snap_fip_households snap_fip_individuals snap_fip_issuance snap_medassist_households snap_medassist_individuals snap_medassist_issuance snap_hawki_households snap_hawki_individuals snap_hawki_issuance snap_only_households snap_only_individuals snap_only_issuance households individuals issuance participation_rate {
		destring `var', replace
		confirm numeric variable `var'
	}

	// fix county name 
	replace county = "total" if county == "state total"

	// drop obsnum
	drop obsnum

	// generate ym 
	gen ym = `ym'
	format ym %tm

	/* STATE TOTALS ARE NOW GATHERED IN THE ABOVE CODE 

	// first get state totals 
	keep if inlist(A,"total households","total recipients","total allotments","overall average per household","overall average per recipient")
	dropmiss, force
	qui describe, varlist
	assert r(N) == 5
	assert r(k) == 6
	rename (`r(varlist)') (variable _`year'_`month' _`year'_`monthminus1' _`yearminus1'_`month' percentchange obsnum)
** watch out for jan/dec months
	drop percentchange
	reshape long _, i(variable) j(yyyy_mm) string 
	drop obsnum
	destring _, replace 
	gen year = substr(yyyy_mm,1,4)
	gen month = substr(yyyy_mm,6,7)
	destring year month, replace 
	gen ym = ym(year, month)
	format ym %tm 
	drop year month yyyy_mm
	replace variable = ustrregexra(variable," ","")
	reshape wide _, i(ym) j(variable) string 
	*/

	tempfile _`ym'
	save `_`ym''
}

forvalues ym = `ym_start'(1)`ym_end' {

	dis in red "`ym'"
	if `ym' == `ym_start' {
		use `_`ym'', clear
	} 
	else {
		append using `_`ym''
	}
}

*drop if missing(ym) // comes from miss assigning one month less than january as 0, rather than 12 for december. This is fine because I have all the data I want otherwise
duplicates drop 
*sum ym
*assert r(min) <= `ym_start'
*assert r(max) == `ym_end'

// assert level of data 
bysort county ym: assert _N == 1

// order and sort 
sort county ym
tab county

// save 
save "${dir_root}/state_data/iowa/iowa.dta", replace 


********************************************************************

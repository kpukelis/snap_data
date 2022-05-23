// oregon.do
// imports cases and clients from excel sheets

local years 					2017 2018 2019 2020
local sheets 					`""Allotments" "Total Recipients" "Cases"  "NA Recipients" "Persons Coded as CH" "Persons Over 60" "CH Under 5""'

***************************************************************

// import 
import excel using "${dir_root}/data/state_data/oregon/COPIED_Oregon Self-Sufficiency Statewide Data Charts FY 10-11 - FY 17-18 (Partial).xlsx", firstrow case(lower) allstring clear
		
// keep only interesting SNAP vars for now
replace selfsufficiencyprogramcategor = trim(selfsufficiencyprogramcategor)
keep if inlist(selfsufficiencyprogramcategor,"Statewide Supplemental Nutrition Assistance Program Benefits","Statewide Supplemental Nutrition Assistance Program Households","Statewide Supplemental Nutrition Assistance Program Persons")
gen varname = ""
replace varname = "benefits" if strpos(selfsufficiencyprogramcategor,"Benefits")
replace varname = "households" if strpos(selfsufficiencyprogramcategor,"Households")
replace varname = "persons" if strpos(selfsufficiencyprogramcategor,"Persons")
drop selfsufficiencyprogramcategor

// destring vars 
foreach v of varlist _all {
	destring `v', replace
	rename `v' _`v'
}
rename _varname varname

// reshape 
reshape long _, i(varname) j(monYY) string
reshape wide _, i(monYY) j(varname) string
rename _benefits benefits
rename _households households
rename _persons persons
label var benefits "SNAP benefits"
label var households "SNAP households"
label var persons "SNAP persons"

// date 
gen month = substr(monYY,1,3)
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
gen year = substr(monYY,4,5)
destring year, replace
replace year = 2000 + year
gen ym = ym(year,month)
format ym %tm 
drop year month monYY

// county 
gen county = "total"

// order and sort
order county ym benefits households persons
sort county ym

// save 
tempfile oregon_state
save `oregon_state'
*save "${dir_root}/oregon_state", replace

**********************************************************************************************************************************************
**********************************************************************************************************************************************
**********************************************************************************************************************************************
**********************************************************************************************************************************************
**********************************************************************************************************************************************
**********************************************************************************************************************************************
**********************************************************************************************************************************************

foreach sheet of local sheets {
	foreach year of local years {
 
		// year 
		display in red `"`sheet'"' `year'

		// filename suffix 
		if inlist(`year',2019,2020) {
			local filename_suffix xlsx
		}
		else {
			local filename_suffix xls
		}

		// import 
		import excel using "${dir_root}/data/state_data/oregon/SNAP County Tables by FIPS Jan`year' - Dec`year'.`filename_suffix'", sheet("`sheet'") firstrow case(lower) allstring clear
		capture drop datarefresh
		capture drop p 
		capture drop q

		if inlist(`year',2017,2018) {
			drop in 1
			drop in 1
			drop in 1
			drop in 1
			drop in 1
			drop in 1
			drop in 1
	
			// turn first row into variable names 
			foreach var of varlist * {
				replace `var' = strlower(`var')
				replace `var' = ustrregexra(`var',"-","") if _n == 1
				*replace `var' = ustrregexra(`var',".","") if _n == 1
				*replace `var' = ustrregexra(`var'," ","") if _n == 1
				label variable `var' "`=`var'[1]'"
				rename `var' `=`var'[1]'
			}
			drop in 1
			capture drop tot	
		}
		
		// drop notes
		replace county = strlower(county)
		drop if strpos(county,"emergency allotment")

		// clean fips 
		replace fips = strlower(fips)
		replace county = "blank" if fips == "blank"
		replace county = "total" if fips == "total"
		replace fips = "888" if fips == "blank"
		replace fips = "999" if county == "total"
		replace fips = trim(fips)
		replace fips = "0" + fips if strlen(fips) == 2
		replace fips = "00" + fips if strlen(fips) == 1
		drop if strlen(fips) == 0
		assert strlen(fips) == 3
		recast str3 fips 
		duplicates tag fips, gen(dup)
		drop if dup == 1 & fips == "093" & dec == "0"
		if "`sheet'" == "Persons Coded as CH" & `year' == 2019 {
			drop if dup == 1 & fips == "075" & total == "3"	
		}
		drop dup

		// destring
		foreach var in jan feb mar apr may jun jul aug sep oct nov dec {
			destring `var', replace
		}

		// reshape
		rename jan _1
		rename feb _2
		rename mar _3
		rename apr _4
		rename may _5
		rename jun _6
		rename jul _7
		rename aug _8
		rename sep _9
		rename oct _10
		rename nov _11
		rename dec _12
		reshape long _, i(fips) j(month) 

		// rename to actual variable
		local name = ustrregexra(lower(`"`sheet'"')," ","")
		rename _ `name'
		label var `name' `"`sheet'"'

		// date 
		gen year = `year'
		gen ym = ym(year,month)
		format ym %tm
		drop year month

		// make sure variable names are consistent
		capture rename fipscode fips 
	*	rename 

		// order and sort 
		order fips county ym 
		sort fips ym

		// save 
		tempfile `name'_`year'
		save ``name'_`year''

	}

}

****************************************************************
foreach sheet of local sheets {
	foreach year of local years {

		local name = ustrregexra(lower(`"`sheet'"')," ","")

		if `year' == 2017 {
			use ``name'_`year'', clear
		}
		else {
			append using ``name'_`year''
		}
	
		*tempfile `name'
		*save ``name''
		save "${dir_root}/data/state_data/oregon/oregon_`name'.dta", replace
	}
}
*/

foreach sheet of local sheets {
	local name = ustrregexra(`"`sheet'"'," ","")
	if "`sheet'" == "Allotments" {
		*use ``name'', clear
		use "${dir_root}/data/state_data/oregon/oregon_`name'.dta", clear 
	}
	else {
		*merge 1:1 fips ym using ``name'', assert(3) nogen
		merge 1:1 fips ym using "${dir_root}/data/state_data/oregon/oregon_`name'.dta"
		drop _m
	}
}

// drop vars I don't need 
drop monthlyavg 
drop total 

// rename vars to stay consistent 
rename allotments 		benefits
rename cases 			households
rename totalrecipients 	persons
rename personsover60 	age_60
rename chunder5 		age_0_5 
rename personscodedasch children 
rename narecipients 	persons_na

// replace data that should be missing 
foreach var in benefits households persons age_60 age_0_5 children persons_na {
	replace `var' = . if `var' == 0 & ym == ym(2020,12)
}

// append state data 
append using `oregon_state'

// resolve duplicates 
duplicates tag county ym, gen(dup)
drop if dup == 1 & inrange(ym,ym(2017,1),ym(2017,12)) & county == "total" & missing(children) & missing(persons_na) & missing(age_60) & missing(age_0_5)
drop if inlist(dup,4,5,6,8)	& missing(county)
	// drop these many duplicate codes for now 
drop dup 

// assert level of the data
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup

// order and sort 
order fips county ym 
sort county ym

// save
save "${dir_root}/data/state_data/oregon/oregon.dta", replace 


tab county, miss 
tab fips, miss 
tab ym 


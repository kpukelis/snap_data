// oregon.do
// imports cases and clients from excel sheets

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/oregon"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local years 					2017 2018 2019
local sheets 					"Allotments" //"Total Recipients" "Cases" // NOT DONE: "NA Recipients" "Persons Coded as CH" "Persons Over 60" "CH Under 5"
local sheets 					`"Cases"' // "Cases" "NA Recipients" "Persons Coded as CH" "Persons Over 60" "CH Under 5"
**KP for some reason having to do with annoying quotes, the sheets loop is not working. 

***************************************************************
/*
foreach sheet of local sheets {
	foreach year of local years {
 
		// year 
		display in red `"`sheet'"' `year'

		// import 
		import excel using "${dir_root}/SNAP County Tables by FIPS Jan`year' - Dec`year'.xls", sheet("`sheet'") firstrow case(lower) allstring clear
		drop in 1
		drop in 1
		drop in 1
		drop in 1
		drop in 1
		drop in 1
		drop in 1
		drop datarefresh
		capture drop p 
		capture drop q

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

		// clean fips 
		replace county = "blank" if fips == "blank"
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
		*local name = lower("`sheet')
		local name = ustrregexra(`"`sheet'"'," ","")
		rename _ `name'
		label var `name' `"`sheet'"'

		// date 
		gen year = `year'
		gen ym = ym(year,month)
		format ym %tm
		drop year month

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

		local name = ustrregexra(`"`sheet'"'," ","")

		if `year' == 2017 {
			use ``name'_`year'', clear
		}
		else {
			append using ``name'_`year''
		}
	
		*tempfile `name'
		*save ``name''
		save "${dir_root}/oregon_`name'.dta", replace
	}
}
*/

*foreach sheet of local sheets {
foreach sheet in Allotments Recipients Cases {
	local name = ustrregexra(`"`sheet'"'," ","")
	if "`name'" == "Allotments" {
		*use ``name'', clear
		use "${dir_root}/oregon_`name'.dta", clear 
	}
	else {
		*merge 1:1 fips ym using ``name'', assert(3) nogen
		merge 1:1 fips ym using "${dir_root}/oregon_`name'.dta"
		drop _m
	}
}

// order and sort 
order fips county ym 
sort fips ym

// save
save "${dir_root}/oregon.dta", replace 

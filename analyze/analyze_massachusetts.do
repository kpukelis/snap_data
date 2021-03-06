// massachusetts_analyze.do
// imports households and persons from excel sheets

local beginning_clock1 			= ym(2018,1) - 0.5 
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 			= ym(2019,3) - 0.5
*local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2008,3)
local ytitle_size 				small
local dot_size 					tiny // vsmall

*********************************************
/*
// statewide graphs 

use "${dir_root}/massachusetts.dta", clear
keep if city == "grand total"

**KP: move this elsewhere later
label var cases "SNAP households"
label var recipients "SNAP persons"


foreach outcome in cases recipients {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		msize(`dot_size') ///
		xtitle(`""') ///
		title(`""') ///
		graphregion(fcolor(`background_color'))
/*		xline(`expected_clock1') xline(`expected_clock2') /// */
/*		caption(`"Vertical lines at expected effect."') /// */

	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}
*/


*********************************************

// merge in county waiver status 
**KP: waiver stautus excel file incomplete for years 2019,2020 as of 2021-02-25; haven't entered list of cities yet
import excel "${dir_root}/data/policy_data/state_exempt_counties/massachusetts/ma_waivers.xlsx", firstrow case(lower) allstring clear

// zipcode 
replace zip = "0" + zip if strlen(zip) == 4
assert strlen(zip) == 5

// lowercase city name 
foreach var in citytownname county {
	replace `var' = strlower(`var')
	replace `var' = trim(`var')
}

// destring 
foreach var of varlist waiver???? {
	destring `var', replace 
	confirm numeric variable `var'
}


// assert level of the data 
duplicates tag zip, gen(dup)
sort zip citytownname
*br if dup > 0
drop dup

// collapse to level of zipcode (shouldn't affect many observations)
forvalues y = 2017(1)2020 {
	bysort zip: egen max_waiver`y' = max(waiver`y')
	bysort zip: egen mean_waiver`y' = mean(waiver`y')
	drop waiver`y'
}
drop citytownname
duplicates drop 
duplicates tag zip, gen(dup)
assert dup == 0
drop dup 

// reshape to year 
reshape long max_waiver mean_waiver, i(zip) j(year)

// expand to months 
bysort zip year: assert _N == 1
expand 12
bysort zip year: gen month = _n 
gen ym = ym(year,month)
format ym %tm 
drop year month 

// 2020 waivers only Jan - Mar 2020
// April 2020 onward statewide waiver due to covid
foreach type in max mean {
	replace `type'_waiver = 1 if inrange(ym,ym(2020,4),ym(2021,3)) // **KP: not sure when these will end
}

// order and sort 
order zip county ym max_waiver mean_waiver waiver2017group
sort zip ym 

// save 
tempfile waivers 
save `waivers'

// save 2018 waivers 
keep if ym == ym(2018,1)
drop ym 
rename max_waiver max_waiver2018
rename mean_waiver mean_waiver2018

// assert level 
duplicates tag zip, gen(dup)
assert dup == 0
drop dup 

// save 
tempfile waivers2018 
save `waivers2018'

**********************************************

// by county waiver status

// load massachusetts data 
use "${dir_root}/data/state_data/massachusetts/massachusetts.dta", clear 

// assert level of data 
duplicates tag zip ym, gen(dup)
assert dup == 0
drop dup 

// merge in 2018 waiver status 
merge m:1 zip using `waivers2018'
**not sure about _m == 2 cases, drop for now
drop if _m == 2
// zips not included don't have waivers 
replace max_waiver2018 = 0 if _m == 1
replace mean_waiver2018 = 0 if _m == 1
drop _m 

collapse (sum) households individuals, by(max_waiver2018 ym)

gen relative_ym = ym - `expected_clock1'

separate households, by(max_waiver2018)
separate individuals, by(max_waiver2018)

*keep if inrange(relative_ym,-12,12)
*ym >= `start_graph'
gen year = year(dofm(ym))
gen month = month(dofm(ym))

*forvalue d = 2

foreach var in households0 individuals0 households1 individuals1 {
	*regress `var' i.year i.month
	regress `var' ym 
	predict resid_`var', residual
}



// graph
#delimit ;
	twoway (connected households0 ym , yaxis(1) msize(`dot_size')) 
		   /*(connected individuals0 ym , yaxis(2) msize(`dot_size'))*/
		   (connected households1 ym , yaxis(2) msize(`dot_size')
		   /*(connected individuals1 ym , yaxis(2) msize(`dot_size')*/
		/*legend(label(1 "No county waiver (left axis)") label(2 "County waiver (right axis)") region(lstyle(none))) */
		ylabel(,labsize(vsmall) axis(1))
		ylabel(,labsize(vsmall) axis(2))
		xline(`expected_clock1') /*xline(`expected_clock2') */
		xtitle(`""') 
		title(`""') 
		caption(`"Vertical line at expected effect."' `"households series on left axis and individuals series on right axis."', size(small)) 
		graphregion(fcolor(`background_color')) 
		)
;
#delimit cr 
		
	graph export "${dir_graphs}/massachusetts_raw_bywaiver_byage.png", replace as(png)
check



check


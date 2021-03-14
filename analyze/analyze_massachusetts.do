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


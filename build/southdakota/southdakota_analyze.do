// southdakota_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/south dakota"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local beginning_clock1 			= ym(2014,12) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
local beginning_clock2 			= ym(2017,12) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2013,1)
local ytitle_size 				small

*********************************************
/*
// import waiver data 
import excel "${dir_root}/waivers.xlsx", sheet("waivers") firstrow allstring clear

foreach v of varlist waiver* {
	replace `v' = trim(`v')
	replace `v' = strlower(`v')
}

// clean up data to be indicators instead of names
gen county = waiver2018 
foreach v of varlist waiver* {
	replace `v' = "1" if !missing(`v')
	destring `v', replace
}
tempfile waivers
save `waivers'

// merge with southdakota data 
use "${dir_root}/southdakota.dta", clear
merge m:1 county using `waivers', assert(1 3)
drop _m 
foreach v of varlist waiver* {
	replace `v' = 0 if missing(`v')
}
save "${dir_root}/southdakota_withwaivers.dta", replace
*/

****
// now make the waiver variable dynamic across years
// note the years in waivers are fiscal years
/*
import excel "${dir_root}/waivers.xlsx", sheet("waivers") firstrow allstring clear

foreach v of varlist waiver* {
	replace `v' = trim(`v')
	replace `v' = strlower(`v')
}

// clean up data to be indicators instead of names
gen county = waiver2018 
foreach v of varlist waiver* {
	replace `v' = "1" if !missing(`v')
	destring `v', replace
}
reshape long waiver, i(county) j(fiscalyear)
**manual fix
**KP: should do this for the waiver data above also
replace county = "oglalalakota" if county == "shannon" & fiscalyear >= 2016
tempfile waivers_years
save `waivers_years'

// merge with southdakota data 
use "${dir_root}/southdakota.dta", clear
gen year = year(dofm(ym))
gen month = month(dofm(ym))
gen fiscalyear = .
replace fiscalyear = year if inrange(month,1,6)
replace fiscalyear = year + 1 if inrange(month,7,12)
merge m:1 county fiscalyear using `waivers_years', assert(1 3)
drop _m 
replace waiver = 0 if missing(waiver)
save "${dir_root}/southdakota_withwaiveryears.dta", replace
check
*/
*********************************************

// statewide graphs 

use "${dir_root}/southdakota.dta", clear
keep if county == "statetotals"

**KP: move this elsewhere later
label var households "SNAP households"
label var persons "SNAP persons"
label var adults "SNAP adults"
label var children "SNAP children"
label var issuance "SNAP issuance"


foreach outcome in households persons adults children issuance {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		xline(`beginning_clock1') xline(`beginning_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at beginning effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}

*********************************************
// statewide graphs - split by whether or not the county had a waiver in 2015

use "${dir_root}/southdakota_withwaivers.dta", clear 
drop if county == "statetotals"
collapse (sum) households persons adults children issuance, by(waiver2015 ym)

**KP: move this elsewhere later
label var households "SNAP households"
label var persons "SNAP persons"
label var adults "SNAP adults"
label var children "SNAP children"
label var issuance "SNAP issuance"

foreach outcome in households persons adults children issuance {

	// graph
	twoway (connected `outcome' ym if ym >= `start_graph' & waiver2015 == 0, yaxis(1)) ///
		   (connected `outcome' ym if ym >= `start_graph' & waiver2015 == 1, yaxis(2) ///
		legend(label(1 "No county waiver (left axis)") label(2 "County waiver 2015 (right axis)") region(lstyle(none))) ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color')) ///
		)
	graph export "${dir_graphs}/`outcome'_raw_bywaiver2015.png", replace as(png)

}
*********************************************
// graphs split by whether or not the county had a waiver (dynamic across years 2014-2019)

use "${dir_root}/southdakota_withwaiveryears.dta", clear

drop if county == "statetotals"
collapse (sum) households persons adults children issuance, by(waiver ym)

**KP: move this elsewhere later
label var households "SNAP households"
label var persons "SNAP persons"
label var adults "SNAP adults"
label var children "SNAP children"
label var issuance "SNAP issuance"

foreach outcome in households persons adults children issuance {

	// graph
	twoway (connected `outcome' ym if ym >= `start_graph' & waiver == 0, yaxis(1)) ///
		   (connected `outcome' ym if ym >= `start_graph' & waiver == 1, yaxis(2) ///
		legend(label(1 "No county waiver (left axis)") label(2 "County waiver (right axis)") region(lstyle(none))) ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color')) ///
		)
	graph export "${dir_graphs}/`outcome'_raw_bywaiver.png", replace as(png)

}

NOT SURE HOW TO INTERPRET THESE GRAPHS...MORE WORK TO DO HERE
check

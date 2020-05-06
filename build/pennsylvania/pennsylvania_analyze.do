// pennsylvania_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/pennsylvania"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

*local beginning_clock1 			= ym(2016,1) - 0.5 
local beginning_clock1 			= ym(2016,2) - 0.5 
local expected_clock1 			= `beginning_clock1' + 3 + 1
local beginning_clock2 			= ym(2018,1) - 0.5 
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
*local start_graph				ym(2004,1)
local start_graph				ym(2013,1)
local ytitle_size 				small
local dot_size 					vsmall // tiny //
local ylabel_size				tiny

*********************************************
// import waiver data
**KP move this elsewhere later

import excel using "C:\Users\Kelsey\Google Drive\Harvard\research\time_limits\state_exempt counties\pennsylvania\pennsylvania_waivers.xlsx", sheet("Sheet1") allstring firstrow clear
dropmiss, force 
destring waiver2016 waiver2017 waiver2018 waiver2019, replace
save "${dir_root}/pennsylvania_waivers_wide.dta", replace
reshape long waiver, i(county) j(year)
save "${dir_root}/pennsylvania_waivers.dta", replace


*********************************************
// statewide graphs 

use "${dir_root}/pennsylvania.dta", clear
keep if county == "state total"

**KP: move this elsewhere later
label var individuals "SNAP individuals"
label var issuance "SNAP issuance"


foreach outcome in individuals issuance {

	**KP: drop months that were weird due to gov shutdown(should double check why the data looks like this....?????)
	if "`outcome'" == "issuance" {
		drop if ym == ym(2019,1) | ym == ym(2019,2)
	}

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		msize(`dot_size') ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}

****************************************************************
// split by waiver status fixed for a particular year throughout the graph

use "${dir_root}/pennsylvania.dta", clear

// merge in waiver data 
drop if county == "state total"
gen year = year(dofm(ym))
*merge m:1 county year using "${dir_root}/pennsylvania_waivers.dta"
*drop if _m == 2 // drop cities and other municipalities for now; they are partially accounted for by 0.5's in the county-level data
*assert _m == 3 | (_m == 1 & !inrange(year,2016,2019))
merge m:1 county using "${dir_root}/pennsylvania_waivers_wide.dta"
drop if _m == 2 // drop cities and other municipalities for now; they are partially accounted for by 0.5's in the county-level data
assert _m == 3
drop _m


foreach year in 2016 2018 {
	
	// preserve
	preserve
	
	// collapse to sum by waiver status
	collapse (sum) individuals issuance, by(waiver`year' ym)
	**KP: move this elsewhere later
	label var individuals "SNAP individuals"
	label var issuance "SNAP issuance"
	
	// graph 
	foreach outcome in individuals issuance {
	
		**KP: drop months that were weird due to gov shutdown(should double check why the data looks like this....?????)
		if "`outcome'" == "issuance" {
			drop if ym == ym(2019,1) | ym == ym(2019,2)
		}

		// graph
		twoway (connected `outcome' ym if ym >= `start_graph' & waiver`year' == 0, yaxis(1) msize(`dot_size')) ///
			   (connected `outcome' ym if ym >= `start_graph' & waiver`year' == 0.5, yaxis(2) msize(`dot_size')) ///
			   (connected `outcome' ym if ym >= `start_graph' & waiver`year' == 1, yaxis(3) msize(`dot_size') ///
			legend( label(1 "No county waiver (left axis)") ///
					label(2 "Partial county waiver (middle axis)") ///
					label(3 "County waiver `year' (right axis)") ///
					region(lstyle(none)) size(vsmall)) ///
			xline(`expected_clock1') xline(`expected_clock2') ///
			ytitle("", axis(1)) ///
			ytitle("", axis(2)) ///
			ytitle("", axis(3)) ///
			ylabel(,labsize(`ylabel_size') axis(1)) ///
			ylabel(,labsize(`ylabel_size') axis(2)) ///
			ylabel(,labsize(`ylabel_size') axis(3)) ///
			xtitle(`""') ///
			title(`""') ///
			caption(`"Vertical lines at expected effect."') ///
			graphregion(fcolor(`background_color')) ///
			)
		graph export "${dir_graphs}/`outcome'_raw_bywaiver`year'.png", replace as(png)

	}
	
	restore	
}
check



// massachusetts_analyze.do
// imports households and persons from excel sheets

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/massachusetts"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

*local beginning_clock1 			= ym(2016,3) - 0.5 
*local expected_clock1 			= `beginning_clock1' + 3 + 1
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


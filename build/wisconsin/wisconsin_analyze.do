// wisconsin_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/wisconsin"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

/*
KP: THESE DATES NOT CONFIRMED
local beginning_clock1 			= ym(2015,11) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
local beginning_clock2 			= ym(2018,11) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
*/
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2011,1) 
local ytitle_size 				small
local dot_size 					vsmall

*********************************************
// statewide graphs 

use "${dir_root}/wisconsin.dta", clear
keep if county == "State Total"

**KP: move this elsewhere later
label var cases "SNAP households"
label var recipients "SNAP persons"
label var benefits "SNAP issuance"


foreach outcome in cases recipients benefits {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		msize(`dot_size') ///
		xtitle(`""') ///
		title(`""') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)
/*
		xline(`expected_clock1') xline(`expected_clock2') ///
		caption(`"Vertical lines at expected effect."') ///
*/
}

****************************************************************


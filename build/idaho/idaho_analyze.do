// idaho_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/idaho"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local beginning_clock1 			= ym(2017,12) - 0.5 **double check date, looks like the effect is at another date
local expected_clock1 			= `beginning_clock1' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
*local start_graph				ym(2009,11)
local start_graph				ym(2015,1)
local ytitle_size 				small

*********************************************
// statewide graphs 

use "${dir_root}/idaho.dta", clear
bysort ym: assert _N == 44
collapse (sum) persons, by(ym)


**KP: move this elsewhere later
label var persons "SNAP persons"


foreach outcome in persons {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		xline(`expected_clock1') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}


*/
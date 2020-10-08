// georgia_analyze.do 
// Kelsey Pukelis

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/georgia"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local beginning_clock1 			= ym(2005,12) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
local beginning_clock2 			= ym(2008,12) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local beginning_clock3 			= ym(2011,12) - 0.5
local expected_clock3 			= `beginning_clock3' + 3 + 1
local beginning_clock4 			= ym(2014,12) - 0.5
local expected_clock4 			= `beginning_clock4' + 3 + 1
local beginning_clock5 			= ym(2017,12) - 0.5
local expected_clock5 			= `beginning_clock5' + 3 + 1
local outcome					clients	
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2005,1)

**********************************

// load data 
use "${dir_data}/georgia.dta", clear

foreach outcome in individuals {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		xline(`expected_clock1') xline(`expected_clock2') xline(`expected_clock3') xline(`expected_clock4') xline(`expected_clock5') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}
check

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/north carolina"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local beginning_clock1 			= ym(2016,1) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
local beginning_clock2 			= ym(2019,1) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2014,1)

************************************************************

// save statewide totals 
*use "${dir_root}/northcarolina.dta", clear 
use "${dir_root}/northcarolina_state.dta", clear 


foreach outcome in participants cases apps abawdsactive abawdsclosed workfirst_cases workfirst_participants workfirst_apps {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		xline(`beginning_clock1') xline(`beginning_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at beginning effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}


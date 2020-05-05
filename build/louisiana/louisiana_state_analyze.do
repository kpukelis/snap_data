// louisiana_state_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/louisiana"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

*local beginning_clock1 			= ym() - 0.5 
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 			= ym() - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
*local start_graph				ym(1987,1)
local start_graph				ym(2005,1)
local ytitle_size 				small
local dot_size 					tiny // vsmall

*********************************************

// statewide graphs 

use "${dir_root}/louisiana_state.dta", clear

**KP: move this elsewhere later
label var households "SNAP households"
label var recipients "SNAP recipients"
label var avg_recips_per_hh "SNAP average recipients per household"
label var benefits  "SNAP benefits"
label var avg_payment  "SNAP average payment"
label var hh_with_earnedinc "SNAP households with earned income"
label var avg_earnedinc_per_hh "SNAP average earned income per household"

foreach outcome in households recipients avg_recips_per_hh benefits avg_payment hh_with_earnedinc avg_earnedinc_per_hh {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		msize(`dot_size') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

	/*xline(`expected_clock1') xline(`expected_clock2') /// */
		
}
check

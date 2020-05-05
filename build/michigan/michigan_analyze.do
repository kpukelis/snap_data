// michigan_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/michigan"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local beginning_clock1 			= ym(2017,1) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
local beginning_clock2 			= ym(2018,10) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2008,6) 
local ytitle_size 				small
local dot_size 					vsmall

*********************************************
// statewide graphs 

use "${dir_root}/michigan.dta", clear
collapse (sum) cases recipients adults children issuance (mean) avg_pay_per_case avg_pay_per_person avg_recip_per_case, by(ym)

**KP: move this elsewhere later
label var cases "SNAP households"
label var recipients "SNAP persons"
label var issuance "SNAP issuance"
label var adults "SNAP adults"
label var children "SNAP children"
label var avg_pay_per_case "SNAP - average payment per case"
label var avg_pay_per_person "SNAP - average payment per person"
label var avg_recip_per_case "SNAP - average # of recipients per case"


foreach outcome in cases recipients adults children issuance avg_pay_per_case avg_pay_per_person avg_recip_per_case {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		msize(`dot_size') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}

****************************************************************


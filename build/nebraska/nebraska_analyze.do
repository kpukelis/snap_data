// nebraska_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/nebraska"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local beginning_clock1 			= ym(2015,1) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
local beginning_clock2 			= ym(2018,1) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2014,1) 
local ytitle_size 				small
local dot_size 					vsmall

*********************************************
// statewide graphs 

use "${dir_root}/nebraska.dta", clear

**KP: move this elsewhere later
label var snap_households "SNAP households"
label var snap_individuals "SNAP persons"
label var adc_families "Aid to Dependent (ADC) families"
label var ccsubsidy_children "Children in Child Care Subsidy"
label var medicaid_enrol_total "Medicaid enrollment - "
label var medicaid_enrol_children_families "Medicaid enrollment - Children and Families"
label var medicaid_enrol_aged_disabled "Medicaid enrollment - Aged and Disabled"


foreach outcome in snap_households snap_individuals adc_families ccsubsidy_children medicaid_enrol_total medicaid_enrol_children_families medicaid_enrol_aged_disabled {

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


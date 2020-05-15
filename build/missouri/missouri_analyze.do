// missouri_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/missouri"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

*local beginning_clock1 			= ym(2016,1) - 0.5
local beginning_clock1 			= ym(2015,12) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 			= ym(2019,1) - 0.5
local beginning_clock2 			= ym(2018,12) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2007,1) 
local ytitle_size 				small
local dot_size 					vsmall

*********************************************
// statewide graphs 

*use "${dir_root}/missouri.dta", clear
use "${dir_root}/missouri_page1.dta", clear

**KP: move this elsewhere later

label var apps_received 			"applications received"
label var apps_approved 			"applications approved"
label var apps_rejected 			"applications rejected"
label var apps_expedited 			"applications expedited"
label var households 				"households"
label var households_pa 			"households - public assistance" 
label var households_npa 			"households - non-public assistance" 
label var persons 					"persons"
label var persons_pa 				"persons - public assistance" 
label var persons_npa 				"persons - non-public assistance" 
label var issuance 					"total benefits issued"
label var avg_benefits_perhousehold "average value of benefits per household"
label var avg_benefits_perperson    "average value of benefits per person"

foreach outcome in apps_received apps_approved apps_rejected apps_expedited households households_pa households_npa persons persons_pa persons_npa issuance avg_benefits_perhousehold avg_benefits_perperson {

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


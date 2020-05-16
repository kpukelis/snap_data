// texas_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/texas"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2005,6) 
local ytitle_size 				small
local dot_size 					vsmall

*********************************************
// statewide graphs 

*use "${dir_root}/texas.dta", clear
*keep if county == "State Total"
use "${dir_data}/texas_state.dta", clear

**KP: move this elsewhere later
label var cases "SNAP cases"
label var recipients "SNAP recipients"
label var issuance "SNAP issuance"
label var age_00_04 "Ages 0-4"
label var age_05_17 "Ages 5-17"
label var age_18_59 "Ages 18-59"
label var age_60_64 "Ages 60-64"
label var age_65 "Ages 65+"
label var avg_payment_percase "Avg payment per case"

foreach outcome in cases recipients issuance age_00_04 age_05_17 age_18_59 age_60_64 age_65 avg_payment_percase {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		msize(`dot_size') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}
check
****************************************************************
************************************************
use "${dir_root}/texas_applications.dta", clear


*twoway connected apps_perc_timely ym, by(region)
drop if missing(region)
encode region, gen(region_encode)
tab region region_encode
keep if inlist(region,"01","02/09","03","04","05") | inlist(region,"06","07","08","10","11")
replace region = "0209" if region == "02/09"

*drop region
*reshape wide apps_* recerts_*, i(ym) j(region_encode)
drop region_encode
reshape wide apps_* recerts_*, i(ym) j(region) string 
twoway connected apps_perc_timely* ym 


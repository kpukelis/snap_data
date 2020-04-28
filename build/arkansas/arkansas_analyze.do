// arkansas_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/arkansas"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local beginning_clock1 			= ym(2015,12) - 0.5
*local beginning_clock1 			= ym(2016,1) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 			= ym(,) - 0.5
*local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2008,1)
local end_graph					ym(2019,5)
local ytitle_size 				small

*********************************************
// statewide graphs 

use "${dir_root}/arkansas.dta", clear
keep if county == "total"

**KP: move this elsewhere later
label var households "SNAP households"
label var persons "SNAP persons"
label var issuance "SNAP issuance"
label var apps_received "SNAP applications received"
label var apps_approved "SNAP approved"
label var apps_denied "SNAP denied"
label var pendingdays_total "SNAP pending days - total"
label var pendingdays_1to30 "SNAP pending days - 1 to 30"
label var pendingdays_31to60 "SNAP pending days - 31 to 60"
label var pendingdays_60plus "SNAP pending days - 60 plus"
label var pendingoverdue_total "SNAP pending overdue - total"
label var pendingoverdue_AC "SNAP pending overdue - AC"
label var pendingoverdue_BD "SNAP pending overdue - BD"
label var pendingoverdue_perc "SNAP pending overdue - percentage"
label var overdue_approved "SNAP overdue - approved"
label var overdue_denied "SNAP overdue - denied"

/*

foreach outcome in households persons issuance apps_received apps_approved apps_denied { 

	// graph
	twoway connected `outcome' ym if inrange(ym,`start_graph',`end_graph'), ///
		xline(`expected_clock1') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}
*/

****************************************************************
foreach outcome in households persons issuance {

	// load data
	use "${dir_root}/arkansas.dta", clear
	
	// calculate % of population dropped, whole state 
	preserve
	keep if county == "total"
	egen county_id_notfips = group(county)
	tsset county_id_notfips	ym
*	gen diff = `outcome'[_n+1] - `outcome'[_n]
	gen diff = `outcome'[_n+2] - `outcome'[_n] // **EFFECT APPEARS TO TAKE 2 MONTHS
	gen perc = diff / `outcome' if ym == ym(2016,3)
	sum perc 
	local state_avg_dropped = r(mean)
	restore

	// calculate % of population dropped for each county
	egen county_id_notfips = group(county)
	tsset county_id_notfips	ym
*	bysort county_id_notfips: gen diff = `outcome'[_n+1] - `outcome'[_n]
	bysort county_id_notfips: gen diff = `outcome'[_n+2] - `outcome'[_n] // **EFFECT APPEARS TO TAKE 2 MONTHS
*	keep if ym == ym(2016,3) | ym == ym(2016,4)
	keep if ym == ym(2016,3) | ym == ym(2016,4) | ym == ym(2016,5)
	gen perc = diff / `outcome' if ym == ym(2016,3)
	
	// histogram: percentage dropped between 2016m3-m5 by county
	histogram perc, ///
		xline(`state_avg_dropped') ///
		bin(10) ///
		bcolor(`bar_color') ///
		lcolor(`baroutline_color') ///
		lwidth(`baroutline_size') ///
		freq ///
		xtitle(`"Percentage drop (`outcome')"') ///
		ytitle(`"Counties"') ///
		title(`"Arkansas: percentage dropped between 2016m3-m5 by county"') ///
		caption(`"Vertical line at state average."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_dropped_county_hist.png", replace as(png)
	
	// save 
	keep if ym == ym(2016,3)
	rename diff diff_drop_`outcome'
	rename perc perc_drop_`outcome'
	keep county diff_drop_`outcome' perc_drop_`outcome'
	save "${dir_data}/drop_`outcome'_county_level.dta", replace 

}

foreach outcome in households persons issuance {
	if "`outcome'" == "households" {
		use "${dir_data}/drop_`outcome'_county_level.dta", clear 
	}
	else {
		merge 1:1 county using "${dir_data}/drop_`outcome'_county_level.dta", assert(3) nogen
	}
}
save "${dir_data}/drop_county_level.dta", replace 

KEEP GOING HERE

check


check


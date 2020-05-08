// southcarolina_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/south carolina"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

*local beginning_clock1 			= ym(2016,4) - 0.5 // south carolina dropped its statewide waiver at the end of March 2016
local beginning_clock1 			= ym(2016,3) - 0.5 // south carolina dropped its statewide waiver at the end of March 2016
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 			= ym(2019,4) - 0.5
local beginning_clock2 			= ym(2019,3) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2008,3)
local ytitle_size 				small
local dot_size 					tiny // vsmall

*********************************************

// statewide graphs 

use "${dir_root}/southcarolina.dta", clear
keep if county == "statetotal"

**KP: move this elsewhere later
label var households "SNAP households"
label var persons "SNAP persons"
label var issuance "SNAP issuance"


foreach outcome in households persons issuance {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		msize(`dot_size') ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}

****************************************************************
foreach outcome in households persons issuance {

	// load data
	use "${dir_root}/southcarolina.dta", clear
	
	// calculate % of population dropped, whole state 
	preserve
	keep if county == "statetotal"
	egen county_id_notfips = group(county)
	tsset county_id_notfips	ym
	gen diff = `outcome'[_n+1] - `outcome'[_n]
	gen perc = diff / `outcome' if ym == ym(2016,6)
	sum perc 
	local state_avg_dropped = r(mean)
	restore

	// calculate % of population dropped for each county
	drop if county == "statetotal"
**KP: need to insert this line in other states dofiles so that state total is not included in the histogram
	egen county_id_notfips = group(county)
	tsset county_id_notfips	ym
	bysort county_id_notfips: gen diff = `outcome'[_n+1] - `outcome'[_n]
	keep if ym == ym(2016,6) | ym == ym(2016,7)
	gen perc = diff / `outcome' if ym == ym(2016,6)
	
	// histogram: percentage dropped between 2016m3-m4 by county
	histogram perc, ///
		xline(`state_avg_dropped') ///
		bin(10) ///
		bcolor(`bar_color') ///
		lcolor(`baroutline_color') ///
		lwidth(`baroutline_size') ///
		freq ///
		xtitle(`"Percentage drop (`outcome')"') ///
		ytitle(`"Counties"') ///
		title(`"South Carolina: percentage dropped between 2016m6-2016m7 by county"') ///
		caption(`"Vertical line at state average."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_dropped_county_hist.png", replace as(png)
	
	// save 
	keep if ym == ym(2016,6)
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



check



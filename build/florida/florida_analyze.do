// florida_analyze.do 
// Kelsey Pukelis

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/florida"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

*local beginning_clock1 		= ym(2016,1) - 0.5
local beginning_clock1 			= ym(2015,12) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 		= ym(2019,1) - 0.5
local beginning_clock2 			= ym(2018,12) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome					clients	
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2009,1)

**********************************

// load data 
use "${dir_data}/clean/florida_state_level.dta", clear

foreach outcome in clients households issuance {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}
check
**********************************

foreach outcome in clients households issuance {

	// load data
	use "${dir_data}/clean/florida_county_level.dta", clear
	
	// calculate % of population dropped, whole state 
	preserve
	collapse (sum) `outcome', by(ym)
	gen county = ""
	egen county_id_notfips = group(county)
	tsset county_id_notfips	ym
	gen diff = `outcome'[_n+1] - `outcome'[_n]
	gen perc = diff / `outcome' if ym == ym(2016,3)
	sum perc 
	local state_avg_dropped = r(mean)
	restore
	
	// calculate % of population dropped for each county
	egen county_id_notfips = group(county)
	tsset county_id_notfips	ym
	bysort county_id_notfips: gen diff = `outcome'[_n+1] - `outcome'[_n]
	keep if ym == ym(2016,3) | ym == ym(2016,4)
	gen perc = diff / `outcome' if ym == ym(2016,3)
	
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
		title(`"Florida: percentage dropped between 2016m3-m4 by county"') ///
		caption(`"Vertical line at state average."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_dropped_county_hist.png", replace as(png)
	
	// save 
	keep if ym == ym(2016,3)
	rename diff diff_drop_`outcome'
	rename perc perc_drop_`outcome'
	keep county diff_drop_`outcome' perc_drop_`outcome'
	save "${dir_data}/clean/drop_`outcome'_county_level.dta", replace 

}

foreach outcome in clients households issuance {
	if "`outcome'" == "clients" {
		use "${dir_data}/clean/drop_`outcome'_county_level.dta", clear 
	}
	else {
		merge 1:1 county using "${dir_data}/clean/drop_`outcome'_county_level.dta", assert(3) nogen
	}
}
save "${dir_data}/clean/drop_county_level.dta", replace 
check

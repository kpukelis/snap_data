// montana_analyze.do 
// Kelsey Pukelis
// 2019-12-14


global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/montana"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"


*local beginning_clock1 			= ym(2015,1) - 0.5
local beginning_clock1 			= ym(2014,12) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 			= ym(2018,1) - 0.5
local beginning_clock2 			= ym(2017,12) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2012,7)

***********************************************************************************************
**KP move this elsewhere
/*
// 2015 county waivers data 
use "${dir_root}/montana.dta", clear 
gen waiver2015 = 0
replace waiver2015 = 1 if inlist(county,"bighorn","blaine","flathead","glacier","goldenvalley","granite","judithbasin") | inlist(county,"lake","liberty","lincoln","mineral","musselshell","petroleum","sanders","wheatland")
unique county if waiver2015 == 1 // should be 15
save "${dir_root}/montana.dta", replace 
*/
***********************************************************************************************
/*

// statewide graphs 

use "${dir_root}/montana.dta", clear 
keep if county == "total"

**KP: move this elsewhere later
label var cases "SNAP cases"
label var recips "SNAP recipients"
label var issuance "SNAP issuance"
label var issuance_percase "SNAP average issuance per case"
label var issuance_perrecip "SNAP average issuance per recipient"
label var pa "SNAP - public assistance recipients"
label var npa "SNAP - non-public assistance recipients"

foreach outcome in cases recips issuance issuance_percase issuance_perrecip {

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
*/
**********************************

/*
// statewide graphs - split by whether or not the county had a waiver in 2015

use "${dir_root}/montana.dta", clear 
drop if county == "total"
collapse (sum) cases recips issuance issuance_percase issuance_perrecip, by(waiver2015 ym)


**KP: move this elsewhere later
label var cases "SNAP cases"
label var recips "SNAP recipients"
label var issuance "SNAP issuance"
label var issuance_percase "SNAP average issuance per case"
label var issuance_perrecip "SNAP average issuance per recipient"
*label var pa "SNAP - public assistance recipients"
*label var npa "SNAP - non-public assistance recipients"

foreach outcome in cases recips issuance issuance_percase issuance_perrecip {

	// graph
	twoway (connected `outcome' ym if ym >= `start_graph' & waiver2015 == 0, yaxis(1)) ///
		   (connected `outcome' ym if ym >= `start_graph' & waiver2015 == 1, yaxis(2) ///
		legend(label(1 "No county waiver (left axis)") label(2 "County waiver (right axis)") region(lstyle(none))) ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color')) ///
		)
	graph export "${dir_graphs}/`outcome'_raw_bywaiver.png", replace as(png)

}
check
*/
*************************************************
foreach outcome in cases recips issuance {

	// load data
	use "${dir_root}/montana.dta", clear 
	
	**KP: move this elsewhere later
	label var cases "SNAP cases"
	label var recips "SNAP recipients"
	label var issuance "SNAP issuance"
	label var issuance_percase "SNAP average issuance per case"
	label var issuance_perrecip "SNAP average issuance per recipient"
	label var pa "SNAP - public assistance recipients"
	label var npa "SNAP - non-public assistance recipients"


	// calculate % of population dropped, whole state 
	preserve
	keep if county == "total"
*	gen county = ""
	egen county_id_notfips = group(county)
	tsset county_id_notfips	ym
	gen diff = `outcome'[_n+1] - `outcome'[_n]
	gen perc = diff / `outcome' if ym == ym(2015,3)
	sum perc 
	local state_avg_dropped = r(mean)
	restore
	
	// calculate % of population dropped for each county
	drop if county == "total"
	egen county_id_notfips = group(county)
	tsset county_id_notfips	ym
	bysort county_id_notfips: gen diff = `outcome'[_n+1] - `outcome'[_n]
	keep if ym == ym(2015,3) | ym == ym(2015,4)
	gen perc = diff / `outcome' if ym == ym(2015,3)
	
	// histogram: percentage dropped between 2015m3-m4 by county
	histogram perc, ///
		xline(`state_avg_dropped') ///
		bin(25) ///
		fcolor(`bar_color') ///
		lcolor(`baroutline_color') ///
		lwidth(`baroutline_size') ///
		freq ///
		xtitle(`"Percentage drop (`outcome')"') ///
		ytitle(`"Counties"') ///
		title(`"Montana: percentage dropped between 2015m3-m4 by county"') ///
		caption(`"Vertical line at state average."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_dropped_county_hist.png", replace as(png)
	
	// histogram: percentage dropped between 2015m3-m4 by county, split by county waiver status in 2015
	twoway (histogram perc if waiver2015 == 1, fcolor(`bar_color') lcolor(`background_color') width(0.05) start(-0.6)) ///
	(histogram perc if waiver2015 == 0, fcolor(none) lcolor(black) width(0.05) start(-0.6) ///
		legend(label(1 "No county waiver") label(2 "County waiver") region(lstyle(none))) ///
		xline(`state_avg_dropped') ///
		lwidth(`baroutline_size') ///
		freq ///
		xtitle(`"Percentage drop (`outcome')"') ///
		ytitle(`"Counties"') ///
		title(`"Montana: percentage dropped between 2015m3-m4 by county"') ///
		caption(`"Vertical line at state average."') ///
		graphregion(fcolor(`background_color')) ///
		)
	graph export "${dir_graphs}/`outcome'_dropped_county_hist_bywaiver.png", replace as(png)

	// save 
	keep if ym == ym(2015,3)
	rename diff diff_drop_`outcome'
	rename perc perc_drop_`outcome'
	keep county diff_drop_`outcome' perc_drop_`outcome'
	save "${dir_data}/clean/drop_`outcome'_county_level.dta", replace 

}
check
foreach outcome in cases recips issuance{
	if "`outcome'" == "clients" {
		use "${dir_data}/clean/drop_`outcome'_county_level.dta", clear 
	}
	else {
		merge 1:1 county using "${dir_data}/clean/drop_`outcome'_county_level.dta", assert(3) nogen
	}
}
save "${dir_data}/clean/drop_county_level.dta", replace 

// maryland_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/maryland"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

*local beginning_clock1 			= ym(2008,11) - 0.5
*local beginning_clock1 			= ym(2008,10) - 0.5
*local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock1 			= ym(2016,1) - 0.5
local beginning_clock1 			= ym(2015,12) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
local beginning_clock2 			= ym(2016,10) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
*local start_graph				ym(2007,7)
*local end_graph 				ym(2009,7)
local start_graph				ym(2015,1)
local end_graph					ym(2020,1)
local ytitle_size 				small

*********************************************
**waivers
use "${dir_root}/maryland.dta", clear
keep county 
duplicates drop 
gen waiver2016_category = .
replace waiver2016_category = 0 if inlist(county,"anne arundel","baltimore co.","carroll","howard","montgomery","prince george's","washington")
replace waiver2016_category = 1 if inlist(county,"allegany","baltimore city","caroline","cecil","dorchester","garrett") | inlist(county,"harford","kent","queen anne's","somerset","talbot","wicomico","worcester")
replace waiver2016_category = 2 if inlist(county,"calvert","charles","frederick","st. mary's")
save "${dir_data}/maryland_waivers.dta", replace

*********************************************

// statewide graphs 

use "${dir_root}/maryland.dta", clear
collapse (sum) snap_households snap_recipients snap_apps_received snap_apps_approved snap_apps_notapproved snap_netexpenditure ssi ssi_apps_received ssi_apps_approved, by(ym)
**KP: move this elsewhere later

label var snap_households "SNAP households"
label var snap_recipients "SNAP persons"
label var snap_apps_received "SNAP applications - received"
label var snap_apps_approved "SNAP applications - approved"
label var snap_apps_notapproved "SNAP applications - not approved"
label var snap_netexpenditure "SNAP issuance"
label var ssi "SSI cases"
label var ssi_apps_received "SSI applications - received"
label var ssi_apps_approved "SSI applications - approved"
/*
foreach outcome in snap_households snap_recipients snap_apps_received snap_apps_approved snap_apps_notapproved snap_netexpenditure ssi ssi_apps_received ssi_apps_approved {

	// graph
	twoway connected `outcome' ym if inrange(ym,`start_graph',`end_graph'), ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}
*/
****************************************************************
// counties: not sure which are exempt, so see if there is an effect for each suspect county separately
/*

use "${dir_root}/maryland.dta", clear
**KP: move this elsewhere later
label var snap_households "SNAP households"
label var snap_recipients "SNAP persons"
label var snap_apps_received "SNAP applications - received"
label var snap_apps_approved "SNAP applications - approved"
label var snap_apps_notapproved "SNAP applications - not approved"
label var snap_netexpenditure "SNAP issuance"
label var ssi "SSI cases"
label var ssi_apps_received "SSI applications - received"
label var ssi_apps_approved "SSI applications - approved"

levelsof county, local(counties)
foreach county of local counties {
*foreach county in "calvert" "charles" "garrett" "st. mary's" {
	preserve 
	keep if county == "`county'"
foreach outcome in snap_households {

	// graph
	twoway connected `outcome' ym if inrange(ym,`start_graph',`end_graph'), ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_`county'_raw.png", replace as(png)

}
restore
}

*/

****************************************************************
// separate by exempt, not, or counties for which maryland used 15% exemptions (until about 2017m1, as it appears in the data)
use "${dir_root}/maryland.dta", clear
merge m:1 county using "${dir_data}/maryland_waivers.dta", assert(3) nogen

collapse (sum) snap_households snap_recipients snap_apps_received snap_apps_approved snap_apps_notapproved snap_netexpenditure ssi ssi_apps_received ssi_apps_approved, by(waiver2016_category ym)


**KP: move this elsewhere later
label var snap_households "SNAP households"
label var snap_recipients "SNAP persons"
label var snap_apps_received "SNAP applications - received"
label var snap_apps_approved "SNAP applications - approved"
label var snap_apps_notapproved "SNAP applications - not approved"
label var snap_netexpenditure "SNAP issuance"
label var ssi "SSI cases"
label var ssi_apps_received "SSI applications - received"
label var ssi_apps_approved "SSI applications - approved"

foreach outcome in snap_households snap_recipients snap_apps_received snap_apps_approved snap_apps_notapproved snap_netexpenditure ssi ssi_apps_received ssi_apps_approved {

	// graph
	twoway (connected `outcome' ym if ym >= `start_graph' & waiver2016_category == 0, msize(vsmall) yaxis(1)) ///
		   (connected `outcome' ym if ym >= `start_graph' & waiver2016_category == 1, msize(vsmall) yaxis(1)) ///
   		   (connected `outcome' ym if ym >= `start_graph' & waiver2016_category == 2, msize(vsmall) yaxis(2) ///
		legend(label(1 "No county waiver (left axis)") label(2 "County waiver (left axis)") label(3 "de facto waiver thru 2016 (right axis)") region(lstyle(none))) ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color')) ///
		)
	graph export "${dir_graphs}/`outcome'_raw_bywaiver.png", replace as(png)

}

KEEP GOING HERE

****************************************************************
foreach outcome in snap_households snap_persons snap_adults snap_children {

	// load data
	use "${dir_root}/maryland.dta", clear
	
	// calculate % of population dropped, whole state 
	preserve
	keep if county == "total"
	egen county_id_notfips = group(county)
	tsset county_id_notfips	ym
	gen diff = `outcome'[_n+1] - `outcome'[_n]
	gen perc = diff / `outcome' if ym == ym(2013,12)
	sum perc 
	local state_avg_dropped = r(mean)
	restore

	// calculate % of population dropped for each county
	egen county_id_notfips = group(county)
	tsset county_id_notfips	ym
	bysort county_id_notfips: gen diff = `outcome'[_n+1] - `outcome'[_n]
	keep if ym == ym(2013,12) | ym == ym(2014,1)
	gen perc = diff / `outcome' if ym == ym(2013,12)
	
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
		title(`"maryland: percentage dropped between 2013m12-2014m1 by county"') ///
		caption(`"Vertical line at state average."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_dropped_county_hist.png", replace as(png)
	
	// save 
	keep if ym == ym(2013,12)
	rename diff diff_drop_`outcome'
	rename perc perc_drop_`outcome'
	keep county diff_drop_`outcome' perc_drop_`outcome'
	save "${dir_data}/drop_`outcome'_county_level.dta", replace 

}

foreach outcome in snap_households snap_persons snap_adults snap_children {
	if "`outcome'" == "clients" {
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


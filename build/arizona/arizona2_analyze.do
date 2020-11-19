// arizona_analyze.do
// imports cases and clients from csvs

*local beginning_clock1 			= ym(2016,1) - 0.5
local beginning_clock1 			= ym(2005,12) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 			= ym(2019,1) - 0.5
local beginning_clock2 			= ym(2008,12) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2008,1)
local ytitle_size 				small

*********************************************

**KP move this elsewhere
/*
// 2016 county waivers data 
use "${dir_root}/arizona.dta", clear 
gen waiver2016 = 0
replace waiver2016 = 1 if inlist(county,"mohave","lapaz","yuma","coconino","navajo","apache","gila","pinal","santacruz") | inlist(county,"graham","greenlee","cochise")
unique county if waiver2016 == 1 // should be 12
save "${dir_root}/arizona.dta", replace 
*/

*********************************************
// statewide graphs 

use "${dir_root}/arizona_early.dta", clear
drop if county == "total"
bysort ym: assert _N == 15
collapse (sum) households persons adults children totalissuance (mean) issuancehousehold issuanceperson, by(ym)

**KP: move this elsewhere later
label var households "SNAP households"
label var persons "SNAP persons"
label var adults "SNAP adults"
label var children "SNAP children"
label var totalissuance "SNAP issuance"
label var issuancehousehold "SNAP average issuance per case"
label var issuanceperson "SNAP average issuance per recipient"

foreach outcome in households persons adults children totalissuance issuancehousehold issuanceperson {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw_early.png", replace as(png)

}
check
*/

** RESIDUALIZED GRAPHS 
gen month = month(dofm(ym))
gen year = year(dofm(ym))

foreach outcome in households persons adults /*children*/ totalissuance issuancehousehold issuanceperson {

	// get residuals 
	regress `outcome' children
	local Rsquared = round(e(r2),0.001)
	predict hat_`outcome'
	gen `outcome'_resid = `outcome' - hat_`outcome'

	// label residual variable
	local lbl : variable label `outcome'
	label var `outcome'_resid `"Residual - `lbl'"' 

	// graph 
	twoway connected `outcome'_resid ym, ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		ytitle(, size(`ytitle_size')) ///
		title(`""') ///
		caption(`"R-squared = `Rsquared'. Vertical lines at expected effect."', size(`caption_size')) ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_resid.png", replace as(png)

}

check
********************************************
// statewide graphs - split by whether or not the county had a waiver in 2015

use "${dir_root}/arizona.dta", clear 
drop if county == "total"
collapse (sum) households persons adults children totalissuance (mean) issuancehousehold issuanceperson, by(waiver2016 ym)


**KP: move this elsewhere later
label var households "SNAP households"
label var persons "SNAP persons"
label var adults "SNAP adults"
label var children "SNAP children"
label var totalissuance "SNAP issuance"
label var issuancehousehold "SNAP average issuance per case"
label var issuanceperson "SNAP average issuance per recipient"

foreach outcome in households persons adults children totalissuance issuancehousehold issuanceperson {

	// graph
	twoway (connected `outcome' ym if ym >= `start_graph' & waiver2016 == 0, yaxis(1)) ///
		   (connected `outcome' ym if ym >= `start_graph' & waiver2016 == 1, yaxis(2) ///
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
** RESIDUALIZED
gen month = month(dofm(ym))
gen year = year(dofm(ym))

foreach outcome in households persons adults /*children*/ totalissuance issuancehousehold issuanceperson {

	// get residuals 
	forvalues d = 0(1)1 {
		regress `outcome' children if waiver2016 == `d'
		local Rsquared`d' = round(e(r2),0.001)
		predict hat_`outcome'`d'
		gen `outcome'_resid`d' = `outcome' - hat_`outcome'`d'
	
		// label residual variable
		local lbl : variable label `outcome'
		label var `outcome'_resid`d' `"Residual - `lbl'"' 
	}

	// graph
	twoway (connected `outcome'_resid0 ym if ym >= `start_graph' & waiver2016 == 0, yaxis(1)) ///
		   (connected `outcome'_resid1 ym if ym >= `start_graph' & waiver2016 == 1, yaxis(2) ///
		legend(label(1 "No county waiver (left axis)") label(2 "County waiver (right axis)") region(lstyle(none))) ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"R-squared0 = `Rsquared0'. R-squared1 = `Rsquared1'. Vertical lines at expected effect."', size(`caption_size')) ///
		graphregion(fcolor(`background_color')) ///
		)
	graph export "${dir_graphs}/`outcome'_resid_bywaiver.png", replace as(png)


}


check
*/
*************************************************
check

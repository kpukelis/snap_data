// Kelsey Pukelis
// 2019-11-26

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/indiana"
global dir_data 				"${dir_root}/raw_csvs"
global dir_graphs 				"${dir_root}/graphs"

// analysis options
local beginning_clock1 			= ym(2015,7) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
local beginning_clock2 			= ym(2018,7) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcomes 					snap_impact_prop_emp snap_inelig tanf_inelig total_issuance total_hhs total_recip avg_per_hh avg_per_recip snap_impact tanf_impact snap_emp tanf_emp
local outcomes_resid			total_issuance // total_recip // total_hhs // snap_inelig
local snap_inelig_after 		= ym(2015,7)
local snap_inelig_lines 		expected // options are beginning expected
local snap_inelig_controls 		"after ym afterXym i.month"
local snap_inelig_controls_cap	"Includes after regime change dummy, separate before and after linear time trends, and month of year FE."
local total_hhs_after 			= ym(2015,7)
local total_hhs_lines 			expected
local total_hhs_controls 		"after ym ym_2 afterXym afterXym_2"
local total_hhs_controls_cap	"Includes after regime change dummy, separate before and after quadratic time trends."
*local total_hhs_controls 		"ym ym_2 ym_3 ym_4, nocons"
*local total_hhs_controls_cap	"Includes quadratic time trend."
local total_recip_after 		= ym(2015,7)
local total_recip_lines 		expected
local total_recip_controls 		"after ym ym_2 afterXym afterXym_2"
local total_recip_controls_cap	"Includes after regime change dummy, separate before and after quadratic time trends."
local total_issuance_after 		= ym(2015,7)
local total_issuance_lines 		expected
local total_issuance_controls 		"after after_2013m11 ym ym_2 afterXym afterXym_2 after_2013m11Xym after_2013m11Xym_2"
local total_issuance_controls_cap	"Includes dummy for 3 regimes, separate quadratic time trends within each regime."
local tanf_inelig_lines			expected
**KP: keep going with this outcomes for residual
local avg_per_hh_lines 			expected
local avg_per_recip_lines 		expected
local snap_impact_lines 		beginning
local tanf_impact_lines 		beginning
local snap_emp_lines 			beginning
local tanf_emp_lines 			beginning
local snap_impact_prop_emp_lines beginning

// graph options
local background_color 			white
local caption_size 				vsmall
local ytitle_size 				small 

*****************************************************************************

// load data 
use "${dir_data}/indiana.dta", clear


// new variable: IMPACT employed divided by IMPACT total caseload 
gen snap_impact_prop_emp = snap_emp / snap_impact
label var snap_impact_prop_emp "Proportion of IMPACT cases employed"

// raw graph
foreach outcome of local outcomes {
	twoway connected `outcome' ym, ///
		xline(```outcome'_lines'_clock1') xline(```outcome'_lines'_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at ``outcome'_lines' effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)
}
check
*/


// residualized graph 
foreach outcome_resid of local outcomes_resid {

	// after dummy 
	gen after = (ym >= ``outcome_resid'_after')
	gen after_2013m11 = (ym >= ym(2013,11))

	// polynomial ym
	gen ym_2 = ym*ym
	gen ym_3 = ym^3
	gen ym_4 = ym^4

	// time trend interacted with after dummy  
	gen afterXym = after*ym
	gen afterXym_2 = after*ym_2
	gen afterXym_3 = after*ym_3
	gen afterXym_4 = after*ym_4
	gen after_2013m11Xym = after_2013m11*ym
	gen after_2013m11Xym_2 = after_2013m11*ym_2
	gen after_2013m11Xym_3 = after_2013m11*ym_3
	gen after_2013m11Xym_4 = after_2013m11*ym_4

	// get residuals 
	regress `outcome_resid' ``outcome_resid'_controls'
	local Rsquared = round(e(r2),0.001)
	predict hat_`outcome_resid'
	gen `outcome_resid'_resid = `outcome_resid' - hat_`outcome_resid'

	// label residual variable
	local lbl : variable label `outcome_resid'
	label var `outcome_resid'_resid `"Residual - `lbl'"' 

	// graph 
	twoway connected `outcome_resid'_resid ym, ///
		xline(```outcome_resid'_lines'_clock1') xline(```outcome_resid'_lines'_clock2') ///
		xtitle(`""') ///
		ytitle(, size(`ytitle_size')) ///
		title(`""') ///
		caption(`"R-squared = `Rsquared'. Vertical lines at ``outcome_resid'_lines' effect."' `"``outcome_resid'_controls_cap'"', size(`caption_size')) ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome_resid'_resid.png", replace as(png)

}
check
*/
/*
twoway connected total_hhs ym
gen after = (ym >= ym(2015,11))
gen afterXym = after*ym
gen ym_2 = ym*ym
gen afterXym_2 = after*ym_2
regress total_hhs after ym ym_2 afterXym afterXym_2 // i.month
predict hat_total_hhs
gen total_hhs_resid = total_hhs - hat_total_hhs
twoway connected total_hhs_resid ym, xline(669.5) xline(705.5) 
*/
/*
local var total_recip 
twoway connected `var' ym
gen after = (ym >= ym(2015,11))
gen afterXym = after*ym
gen ym_2 = ym*ym
gen afterXym_2 = after*ym_2
regress total_recip after ym ym_2 afterXym afterXym_2 // i.month
predict hat_total_recip
gen total_recip_resid = total_recip - hat_total_recip
twoway connected total_recip_resid ym, xline(669.5) xline(705.5) 
*/
local var snap_impact // snap_inelig snap_emp
twoway connected `var' ym, xline(666) xline(702) 
local var tanf_impact // snap_inelig snap_emp
twoway connected `var' ym if year >= 2014, xline(666) xline(702) 

check
gen after = (ym >= ym(2015,11))
gen afterXym = after*ym
gen ym_2 = ym*ym
gen afterXym_2 = after*ym_2
regress `var' after ym ym_2 afterXym afterXym_2 // i.month
predict hat_`var'
gen `var'_resid = `var' - hat_`var'
twoway connected `var'_resid ym, xline(669.5) xline(705.5) 


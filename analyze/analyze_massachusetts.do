// massachusetts_analyze.do
// imports households and persons from excel sheets

local beginning_clock1 			= ym(2018,1) - 0.5 
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 			= ym(2019,3) - 0.5
*local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2008,3)
local ytitle_size 				small
local dot_size 					tiny // vsmall

*********************************************



/*
// statewide graphs 

use "${dir_root}/massachusetts.dta", clear
keep if city == "grand total"

**KP: move this elsewhere later
label var cases "SNAP households"
label var recipients "SNAP persons"


foreach outcome in cases recipients {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		msize(`dot_size') ///
		xtitle(`""') ///
		title(`""') ///
		graphregion(fcolor(`background_color'))
/*		xline(`expected_clock1') xline(`expected_clock2') /// */
/*		caption(`"Vertical lines at expected effect."') /// */

	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}
*/


*********************************************
// load waiver data 
use "${dir_root}/data/state_data/massachusetts/massachusetts_waivers.dta", clear

// save 2018 waivers 
keep if ym == ym(2018,1)
drop ym 
rename max_waiver max_waiver2018
rename mean_waiver mean_waiver2018
rename min_waiver min_waiver2018

// assert level 
duplicates tag zipcode_num, gen(dup)
assert dup == 0
drop dup 

// save 
tempfile waivers2018 
save `waivers2018'

**********************************************

// by county waiver status

// load massachusetts data 
use "${dir_root}/data/state_data/massachusetts/massachusetts.dta", clear 

// assert level of data 
duplicates tag zipcode ym, gen(dup)
assert dup == 0
drop dup 

// destring 
destring zipcode, gen(zipcode_num)
confirm numeric variable zipcode_num

// merge in 2018 waiver status 
merge m:1 zipcode_num using `waivers2018'
**not sure about _m == 2 cases, drop for now
drop if _m == 2
*drop _m 
/*
forvalues option = 0(1)1 {

	// preserve 
	preserve

	// unknown waiver status as separate group 
	if `option' == 0 {
		replace max_waiver2018 = 999 if missing(max_waiver2018)	
	}
	// unknown waiver status grouped with no waiver 
	else if `option' == 1 {
		replace max_waiver2018 = 0 if missing(max_waiver2018)		
	}
	
	// collapse by waiver status 
	collapse (sum) households individuals, by(max_waiver2018 ym)
	tab max_waiver, miss
	
	// y values by waiver status 
	separate households, by(max_waiver2018)
	separate individuals, by(max_waiver2018)
	
	// graph
	if `option' == 0 {
		#delimit ;
		twoway (connected households0 ym , yaxis(1) msize(`dot_size')) 
			   (connected households1 ym , yaxis(2) msize(`dot_size'))
			   (connected households999 ym , yaxis(3) msize(`dot_size')
			legend(label(1 "No county waiver (2018)") label(2 "County waiver") label(3 "Waiver status unknown") region(lstyle(none))) 
			ylabel(,labsize(vsmall) axis(1))
			ylabel(,labsize(vsmall) axis(2))
			ylabel(,labsize(vsmall) axis(3))
			xline(`expected_clock1') /*xline(`expected_clock2') */
			xtitle(`""') 
			ytitle(`""',axis(1)) 
			ytitle(`""',axis(2)) 
			ytitle(`""',axis(3)) 
			title(`""') 
			caption(`"Vertical line at expected effect."', size(small)) 
			graphregion(fcolor(`background_color')) 
			)
		;
		#delimit cr 
		graph export "${dir_graphs}/massachusetts_raw_bywaiver0.png", replace as(png)
	}
	if `option' == 1 {
		#delimit ;
		twoway (connected households0 ym , yaxis(1) msize(`dot_size')) 
			   (connected households1 ym , yaxis(2) msize(`dot_size')
			legend(label(1 "No county waiver (2018)") label(2 "County waiver") region(lstyle(none))) 
			ylabel(,labsize(vsmall) axis(1))
			ylabel(,labsize(vsmall) axis(2))
			xline(`expected_clock1') /*xline(`expected_clock2') */
			xtitle(`""') 
			ytitle(`""',axis(1)) 
			ytitle(`""',axis(2)) 
			title(`""') 
			caption(`"Vertical line at expected effect."', size(small)) 
			graphregion(fcolor(`background_color')) 
			)
		;
		#delimit cr 
		graph export "${dir_graphs}/massachusetts_raw_bywaiver1.png", replace as(png)
	}

	// restore 
	restore 

}
*/
*********************************************************************************************************
// GRAPHS AFTER RESIDUALIZING 

// parameters
local months_before                 = 8 // ** if this range changes, need to change label below
local months_by 					= 1
local months_after 					= 21
local plot_months_before 			= 8
local plot_months_by 				= 6
local plot_months_after 			= 21
local ci 							= 95
local scale 						= 1 // scale to represent percent (0-100 instead of 0-1)
local half_scale 					= `scale' / 2
local ylabel

// title options
local title_x 						`"Months since expected change"'
local title_y 						`"Percent change in `y', relative to t = -1"'

// graph options
local yline_pattern 				dash
local yline_color 					grey
local caption_size					vsmall
local ci_color 						gray
local mark_color 					black
local title_color 					black
local background_color 				white
local plot_border_color 			gs16
local legend_options 				off

**************************************************************************************

// loop over several outcomes: coefplot of the before and after terms
foreach y in households individuals {

	// preserve 
	preserve

	// option 1
	replace max_waiver2018 = 0 if missing(max_waiver2018)	

	// relative time 
	gen relative_ym = ym - `expected_clock1' + 0.5

	// gen version of relative_ym that is only positive so that i. notation can be used 
	gen relative_ym_idot = relative_ym + `months_before'
	assert relative_ym_idot >= 0

	// for this regression, limit to where outcome is nonmissing
	keep if !missing(`y')
	gen log_`y' = log(`y')

	// indicator for each group
	levelsof max_waiver2018, local(levels)
	foreach l of local levels {
		gen max_waiver2018_`l' = (max_waiver2018 == `l')	
	}

	// separate treatment effect for each month before and after the treatment starts
	// generate indicator and interaction variables
	gen _`plot_months_before'plus_months_before = 0
	forvalues t=`months_by'(`months_by')`months_before' {
		// generate indicator: t Months Before
		gen _`t'_months_before = (relative_ym == -`t')
		foreach l of local levels {
			gen _`t'_months_before_`l' = _`t'_months_before * max_waiver2018_`l'
		}
		if `t' >= `plot_months_before' {
			replace _`plot_months_before'plus_months_before = 1 if _`t'_months_before == 1
			drop _`t'_months_before
			foreach l of local levels {
				gen _`plot_months_before'plus_months_before_`l' = _`plot_months_before'plus_months_before * max_waiver2018_`l'
			}
		}
	}
	gen _`plot_months_after'plus_months_after = 0
	forvalues t=0(`months_by')`months_after' {
		// generate indicator: t Months After
		gen _`t'_months_after = (relative_ym == `t')
		foreach l of local levels {
			gen _`t'_months_after_`l' = _`t'_months_after * max_waiver2018_`l'
		}
		if `t' >= `plot_months_after' {
			replace _`plot_months_after'plus_months_after = 1 if _`t'_months_after == 1
			drop _`t'_months_after
			foreach l of local levels {
				gen _`plot_months_after'plus_months_after_`l' = _`plot_months_after'plus_months_after * max_waiver2018_`l'
			}
		}
	}

	********************************************************************************
	// initialize results matrix
	local rows = (`plot_months_after' + `plot_months_before' + 1) 
	local cols = 4 // t, beta, l95, u95
	matrix results = J(`rows', `cols', 0)
	
	// initialize row
	local row = 1
	
	// initialize col
	local col = 1

	// run full regression for event study
	// I'm omitting the t = -1 term (so that it becomes the constant)
	drop _1_months_before_0 _1_months_before_1
	#delimit ;
	reg log_`y' 
			_*_months_before_0 _*_months_after_0 
			i.zipcode_num i.ym, vce(cluster zipcode_num) // nocons
	;
	#delimit cr 

	// fill-in matrix
	local tail = (1 - (`ci'/100)) / 2
	local tstat = invttail(e(df_r),`tail')

	// before terms - grouped
		*local t = -`plot_months_before'
		*matrix results[`row',`col'+0] = `t'
		*matrix results[`row',`col'+1] = (_b[_`plot_months_before'plus_months_before]) * `scale'
		*matrix results[`row',`col'+2] = (_b[_`plot_months_before'plus_months_before] - `tstat'*_se[_`plot_months_before'plus_months_before]) * `scale'
		*matrix results[`row',`col'+3] = (_b[_`plot_months_before'plus_months_before] + `tstat'*_se[_`plot_months_before'plus_months_before]) * `scale'
		*local ++row
	// before terms - single
	local loop_start = -`plot_months_before' //+ 1
	forvalues minus_t=`loop_start'(`months_by')-2 {
		local t = -`minus_t'
		matrix results[`row',`col'+0] = `minus_t'
		matrix results[`row',`col'+1] = (_b[_`t'_months_before_0]) * `scale'
		matrix results[`row',`col'+2] = (_b[_`t'_months_before_0] - `tstat'*_se[_`t'_months_before_0]) * `scale'
		matrix results[`row',`col'+3] = (_b[_`t'_months_before_0] + `tstat'*_se[_`t'_months_before_0]) * `scale'
		local ++row
	}
	// the t = -1 term is the omitted FE term (so it is the constant term if using no other controls)
		matrix results[`row',`col'+0] = -1
		matrix results[`row',`col'+1] = 0
		matrix results[`row',`col'+2] = 0
		matrix results[`row',`col'+3] = 0
		local ++row
	// after terms - single
	local loop_end = `plot_months_after' //- 1
	forvalues t=0(`months_by')`loop_end' {
		matrix results[`row',`col'+0] = `t'
		matrix results[`row',`col'+1] = (_b[_`t'_months_after_0]) * `scale'
		matrix results[`row',`col'+2] = (_b[_`t'_months_after_0] - `tstat'*_se[_`t'_months_after_0]) * `scale'
		matrix results[`row',`col'+3] = (_b[_`t'_months_after_0] + `tstat'*_se[_`t'_months_after_0]) * `scale'
		local ++row
	}
	// after terms - grouped
		*matrix results[`row',`col'+0] = `plot_months_after'
		*matrix results[`row',`col'+1] = (_b[_`plot_months_after'plus_months_after]) * `scale'
		*matrix results[`row',`col'+2] = (_b[_`plot_months_after'plus_months_after] - `tstat'*_se[_`plot_months_after'plus_months_after]) * `scale'
		*matrix results[`row',`col'+3] = (_b[_`plot_months_after'plus_months_after] + `tstat'*_se[_`plot_months_after'plus_months_after]) * `scale'
		*local ++row

	// include t = -1 RAW mean (no suffix) as caption
	noi sum `y' if relative_ym == -1
	local caption = round(r(mean)*`scale',1)
	
	// view matrix
	matrix list results

	// move matrix to data
	clear
	svmat results
	rename results1 relative_ym 
	rename results2 beta 
	rename results3 l`ci'
	rename results4 u`ci'

	// limit plot range
	keep if inrange(relative_ym,-`plot_months_before',`plot_months_after')

	// label relative_ym appropriately
	label define relative_ym -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" //22 "22" 23 "23" 24 "24+"

	// relabel ends of range
	*label define relative_ym -`plot_months_before' "<= -`plot_months_before'", modify
	*label define relative_ym  `plot_months_after'  ">= `plot_months_after'", modify
	label values relative_ym relative_ym

	gen zero = 0

	// generate coefplot
	#delimit ;
	twoway 
		(rarea u`ci' l`ci' relative_ym, lcolor(`ci_color') fcolor(`ci_color'))
		/*(rcap u`ci' l`ci' relative_ym, lcolor(`ci_color') fcolor(`ci_color'))*/
		(scatter beta relative_ym, mcolor(`mark_color'))
		(line zero relative_ym,lcolor(`mark_color')
		xline(-0.5, lpattern(`yline_pattern') lcolor(`yline_color')) 
		legend(`legend_options')
		/*`ylabel'*/
		xlabel(-`plot_months_before'(`plot_months_by')`plot_months_after', valuelabel)
		xtitle(`"`title_x'"') 
		/*ytitle(`"`title_y'"') */
		ytitle(`"Percent change in `y', relative to r = -1"')
		title(`"${ttl_`y'}"', color(`title_color'))
		/*caption("*Average outcome at t = -1 was about `caption'.", size(`caption_size'))*/
		graphregion(fcolor(`background_color') color(`plot_border_color')) 
		bgcolor(`background_color')
		)
	;
	#delimit cr

	// save graph
	graph export "${dir_graphs}/massachusetts_event_plot_`y'.png", as(png) replace

	// restore 
	restore
				
}


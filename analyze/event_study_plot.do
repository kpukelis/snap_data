// event_study_plot.do 
// Kelsey Pukelis

// parameters
local months_before                 = 12 // ** if this range changes, need to change label below
local months_by 					= 1
local months_after 					= 12
local plot_months_before 			= 12
local plot_months_by 				= 1
local plot_months_after 			= 12
local ci 							= 95
local scale 						= 1 // scale to represent percent (0-100 instead of 0-1)
local half_scale 					= `scale' / 2
local ylabel
*local ylabel_ln 					ylabel(-`scale'(`half_scale')`scale')
*local ylabel_r 						
*local ylabel_lnr					ylabel(-`scale'(`half_scale')`scale')

// title options
local title_x 						`"Months since expected change"'
local title_y 						`"Percent change in `y', relative to t = -1"'

// graph options
local yline_pattern 				dash
local yline_color 					grey
local caption_size					vsmall
local ci_color 						black
local mark_color 					black
local title_color 					black
local background_color 				white
local plot_border_color 			gs16
local legend_options 				off

**************************************************************************************

// loop over several outcomes: coefplot of the before and after terms
foreach y in  households individuals  issuance {

	// load data
	use "${dir_root}/state_data/state_ym.dta", clear 
	merge m:1 state using "${dir_root}/state_data/clocks_wide.dta", assert(2 3) keep(3) nogen

	// event: binding events only 
	gen bindingexpected_ym = bindingclockstart_ym + 3 + 1 /*+ 0.5*/ + adjust_clock

	// relative time 
	gen relative_ym = ym - bindingexpected_ym

	// sample of states with a visible first stage 
	keep if !missing(bindingexpected_ym)

	// only keep data within this window
	keep if inrange(relative_ym,-`months_before',`months_after')

	// gen version of relative_ym that is only positive so that i. notation can be used 
	gen relative_ym_idot = relative_ym + `months_before'
	assert relative_ym_idot >= 0

	// generate polynomial terms 
	gen r_1 = relative_ym
	gen z = (r_1 >= 0)
	gen zXr_1 = z*r_1
	forvalues d = 2(1)7 {
		gen r_`d' = r_1^`d'
		gen zXr_`d' = z*r_`d'
	}

	// for this regression, limit to where outcome is nonmissing
	keep if !missing(`y')
	gen log_`y' = log(`y')

	// generate numeric state var (need it to be numeric to use i. notation)
	encode state, gen(state_num)
	
	// separate treatment effect for each month before and after the treatment starts
	// generate indicator and interaction variables
	gen _`plot_months_before'plus_months_before = 0
	forvalues t=`months_by'(`months_by')`months_before' {
		// generate indicator: t Months Before
		gen _`t'_months_before = (relative_ym == -`t')
		if `t' >= `plot_months_before' {
			replace _`plot_months_before'plus_months_before = 1 if _`t'_months_before == 1
			drop _`t'_months_before
		}
	}
	gen _`plot_months_after'plus_months_after = 0
	forvalues t=0(`months_by')`months_after' {
		// generate indicator: t Months After
		gen _`t'_months_after = (relative_ym == `t')
		if `t' >= `plot_months_after' {
			replace _`plot_months_after'plus_months_after = 1 if _`t'_months_after == 1
			drop _`t'_months_after
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

// residual exploration
/*
*regress log_`y' i.state_num
*regress log_`y' i.state_num r_1 
*regress log_`y' i.state_num r_1 zXr_1
regress log_`y' i.state_num r_1 r_2
predict resid, residuals

separate resid, by(state_num)
#delimit ;
twoway connected 
resid1
resid2
resid3
resid4
resid5
resid6
resid7
resid8
resid9
resid10
resid11
resid12 
relative_ym
;
#delimit cr 
check
*/
sum ym 
tab state_num
	// run full regression for event study
	// I'm omitting the t = -1 term (so that it becomes the constant)
	drop _1_months_before
	*reg log_`y' _*_months_before _*_months_after i.state_num , vce(cluster state_num) // nocons
	reg log_`y' _*_months_before _*_months_after i.state_num, vce(cluster state_num) // nocons
	*reg log_`y' _*_months_before _*_months_after i.state_num /*i.state_num#c.r_1 i.state_num#c.r_2*/ /*i.state_num#c.zXr_1*/ /*i.state_num#c.r_2 i.state_num#c.r_3 i.state_num#c.r_4 i.state_num#c.r_5*/ , vce(cluster state_num) // nocons
**KP: not sure if this is the right regression, with two-way FE
check
	// fill-in matrix
	local tail = (1 - (`ci'/100)) / 2
	local tstat = invttail(e(df_r),`tail')

	// before terms - grouped
		local t = -`plot_months_before'
		matrix results[`row',`col'+0] = `t'
		matrix results[`row',`col'+1] = (_b[_`plot_months_before'plus_months_before]) * `scale'
		matrix results[`row',`col'+2] = (_b[_`plot_months_before'plus_months_before] - `tstat'*_se[_`plot_months_before'plus_months_before]) * `scale'
		matrix results[`row',`col'+3] = (_b[_`plot_months_before'plus_months_before] + `tstat'*_se[_`plot_months_before'plus_months_before]) * `scale'
		local ++row
	// before terms - single
	local loop_start = -`plot_months_before' + 1
	forvalues minus_t=`loop_start'(`months_by')-2 {
		local t = -`minus_t'
		matrix results[`row',`col'+0] = `minus_t'
		matrix results[`row',`col'+1] = (_b[_`t'_months_before]) * `scale'
		matrix results[`row',`col'+2] = (_b[_`t'_months_before] - `tstat'*_se[_`t'_months_before]) * `scale'
		matrix results[`row',`col'+3] = (_b[_`t'_months_before] + `tstat'*_se[_`t'_months_before]) * `scale'
		local ++row
	}
	// the t = -1 term is the omitted FE term (so it is the constant term if using no other controls)
		matrix results[`row',`col'+0] = -1
		matrix results[`row',`col'+1] = 0
		matrix results[`row',`col'+2] = 0
		matrix results[`row',`col'+3] = 0
		local ++row
	// after terms - single
	local loop_end = `plot_months_after' - 1
	forvalues t=0(`months_by')`loop_end' {
		matrix results[`row',`col'+0] = `t'
		matrix results[`row',`col'+1] = (_b[_`t'_months_after]) * `scale'
		matrix results[`row',`col'+2] = (_b[_`t'_months_after] - `tstat'*_se[_`t'_months_after]) * `scale'
		matrix results[`row',`col'+3] = (_b[_`t'_months_after] + `tstat'*_se[_`t'_months_after]) * `scale'
		local ++row
	}
	// after terms - grouped
		matrix results[`row',`col'+0] = `plot_months_after'
		matrix results[`row',`col'+1] = (_b[_`plot_months_after'plus_months_after]) * `scale'
		matrix results[`row',`col'+2] = (_b[_`plot_months_after'plus_months_after] - `tstat'*_se[_`plot_months_after'plus_months_after]) * `scale'
		matrix results[`row',`col'+3] = (_b[_`plot_months_after'plus_months_after] + `tstat'*_se[_`plot_months_after'plus_months_after]) * `scale'
		local ++row

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
	label define relative_ym -12 "-12" -11 "-11"  -10 "-10" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12"

	// relabel ends of range
	*label define relative_ym -`plot_months_before' "<= -`plot_months_before'", modify
	*label define relative_ym  `plot_months_after'  ">= `plot_months_after'", modify
	label values relative_ym relative_ym

	// generate coefplot
	#delimit ;
	twoway 
		(rcap u`ci' l`ci' relative_ym, lcolor(`ci_color'))
		(scatter beta relative_ym, mcolor(`mark_color')
		yline(0, lpattern(`yline_pattern') lcolor(`yline_color')) 
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
	graph export "${dir_graphs}/event_plot_`y'.png", as(png) replace
				
}

check

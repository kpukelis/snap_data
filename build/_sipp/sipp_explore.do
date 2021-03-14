// sipp_explore.do 
// Kelsey Pukelis 
// explore SIPP data, check possible sample size 

#delimit ;
local vars1
ssuid
pnum
monthcode
rfscov
efslcy
rfs_contflg
tfs_amt
efs_bmonth
efs_emonth
efsown
efsbrsn1
efsbrsn2
efsersn1
tfsersn2
rfsyn 
tehc_st
tst_intv
rhnumu18wt2 
edob_bmonth
tdob_byear
;
#delimit cr 

#delimit ;
local vars2
ssuid
pnum
monthcode
rfscov
rfs_lcyr
rfs_contflg
tfs_amt
efs_bmonth
efs_emonth
efsown
efsbrsn1
efsbrsn2
efsersn1
tfsersn2
rfsyn 
tehc_st
tst_intv
rhnumu18wt2 
edob_bmonth
tdob_byear
;
#delimit cr 

local vars3 `vars2'
local vars4 `vars2'

*****************************************************************************************************
/*
// load certain variables, each wave 
forvalues w = 1(1)4 {
	display in red "wave `w'"
	use `vars`w'' using "${dir_root}/data/health_data/surveys/SIPP/data/pu2014w`w'_v13/pu2014w`w'.dta", clear
	gen wave = `w'
	gen year = 2012 + `w'
	save "${dir_root}/data/health_data/surveys/SIPP/data/wave`w'.dta", replace 

}

// append waves
forvalues w = 1(1)4 {
	if `w' == 1 {
		use "${dir_root}/data/health_data/surveys/SIPP/data/wave`w'.dta", clear 		
	}
	else {
		append using "${dir_root}/data/health_data/surveys/SIPP/data/wave`w'.dta"
	}

}
save "${dir_root}/data/health_data/surveys/SIPP/data/wave_all.dta", replace
*/

***********************************************************************************************************************
/*
// load data 
use "${dir_root}/data/health_data/surveys/SIPP/data/wave_all.dta", clear

// rename vars
rename ssuid 			hhid 
rename pnum 			pid 
rename monthcode 		month  
rename rfscov 			snap_everP
rename efslcy 			snap_yearbeganP
rename rfs_lcyr 		snap_yearbegan_groupP // different from wave 1
rename rfs_contflg 		snap_contP
rename tfs_amt 			snap_amtM
rename efs_bmonth 		snap_spellbeginS
rename efs_emonth 		snap_spellendS
rename efsown 			snap_ownerS
rename efsbrsn1 		snap_beginreason1S
rename efsbrsn2 		snap_beginreason2S
rename efsersn1 		snap_endreason1S
rename tfsersn2 		snap_endreason2S
rename rfsyn 			snap_nowS 
rename tehc_st 			statefips
rename tst_intv 		state_interview
rename rhnumu18wt2 		persons_18under // wt2 version includes individuals not in the household at the time of interview
rename edob_bmonth 		birthmonth
rename tdob_byear 		birthyear

// age
gen ym = ym(year,month)
format ym %tm 
gen birthym = ym(birthyear,birthmonth)
format birthmonth %tm 
drop birthyear 
drop birthmonth
gen age = (ym - birthym) / 12

// ever ever on snap (not just in a single wave)
recode snap_everP (1=1) (2=0)
tab snap_everP
bysort hhid pid: egen snap_everever = max(snap_everP)

// recode snap_nowS
recode snap_nowS (1=1) (2=0)

// merge in clock info, to get relative time 
preserve 
use "${dir_root}/data/state_data/clocks_wide.dta", clear 
merge 1:1 state using "${dir_root}/data/state_data/_fips/statefips_2015.dta", keepusing(statefips)
assert inlist(state,"dc","districtofcolumbia","puertorico") if _m != 3
keep if _m == 3
drop _m 
tempfile clocks 
save `clocks'
restore
destring statefips, replace
confirm numeric variable statefips
merge m:1 statefips using `clocks', keepusing(clocktype bindingclockstart_ym adjust_clock)
assert inlist(statefips,11,60,61) if _m != 3
keep if _m == 3
drop _m 

// event: binding events only 
gen bindingexpected_ym = bindingclockstart_ym + 3 + 1 + adjust_clock

// relative time 
gen relative_ym = ym - bindingexpected_ym

// age at relative time -1
gen temp = age if relative_ym == -1
forvalues i=2(1)65 {
	replace temp = age + (`i'-1)/12 if relative_ym == -`i' & missing(temp)	
}
forvalues i=0(1)35 {
	replace temp = age - (`i'+1)/12 if relative_ym == `i' & missing(temp)
}
bysort hhid pid: egen age0 = mean(temp)
assert !missing(age0) if !missing(relative_ym)

// mark people between ages 18-49
gen age18_49 = (inrange(age0,18,49.999))
replace age18_49 = . if missing(age0)

// save working data 
save "${dir_root}/data/health_data/surveys/SIPP/data/wave_all_WORKING.dta", replace 
*/
**********

use "${dir_root}/data/health_data/surveys/SIPP/data/wave_all_WORKING.dta", clear

////////////////////////
// SAMPLE RESTRICTION //
////////////////////////

// sample of states with a visible first stage 
keep if !missing(bindingexpected_ym)

// keep people ever on snap 
keep if snap_everever == 1

// households without children only 
keep if persons_18under == 0

// between the ages of 18-49
keep if age18_49 == 1

/*
// average 
collapse (mean) mean_snap_nowS = snap_nowS (semean) semean_snap_nowS = snap_nowS, by(relative_ym)
gen lci95 = mean_snap_nowS + 1.96*semean_snap_nowS
gen uci95 = mean_snap_nowS - 1.96*semean_snap_nowS

// graph 
keep if inrange(relative_ym,-20,20) 
#delimit ;
twoway 	(connected mean_snap_nowS relative_ym) (line lci95 relative_ym, lstyle(dotted))	(line uci95 relative_ym, lstyle(dotted) xline(0, lcolor(red)))
; 
#delimit cr 
*/

// parameters
local months_before                 = 65 // ** if this range changes, need to change label below
local months_by 					= 1
local months_after 					= 35
local plot_months_before 			= 24
local plot_months_by 				= 6
local plot_months_after 			= 24
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

// loop over several outcomes: coefplot of the before and after terms
foreach y in snap_nowS {

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
*	gen log_`y' = log(`y')

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

	// run full regression for event study
	// I'm omitting the t = -1 term (so that it becomes the constant)
	drop _1_months_before
*	reg `y' _*_months_before _*_months_after // nocons
	reg `y' _*_months_before _*_months_after i.statefips , vce(cluster statefips) // nocons
*	reg `y' _*_months_before _*_months_after i.statefips i.ym, vce(cluster statefips) // nocons

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
	label define relative_ym -12 "-12+" -11 "-11"  -10 "-10" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18+" //19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24+"

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
check
	// save graph
	graph export "${dir_graphs}/event_plot_`y'.png", as(png) replace
}







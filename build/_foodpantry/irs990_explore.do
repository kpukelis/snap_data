// irs990_explore.do 
// Kelsey Pukelis
// explores IRS 990 data, complied by Erik James 

// import 
*import delimited using "${dir_root}/data/food_pantry/IRS 990 - James, Erik/county_level_dataset.csv", delimiter(",") clear
import delimited using "${dir_root}/data/food_pantry/IRS 990 - James, Erik/county_level_dataset_v2.csv", delimiter(",") clear

// preserve order of variables 
qui describe, varlist
global varlist_og `r(varlist)'
display in red "${varlist_og}"

// label variables 
renamefrom using "${dir_root}/data/food_pantry/IRS 990 - James, Erik/dataset_documentation.xlsx", filetype(excel) raw(_IDlowercase) clean(_IDlowercase) label(county_id) keepx
order $varlist_og
sort _id 

// save min year and max year 
sum year 
global year_min = `r(min)'
global year_max = `r(max)'

// determine level of data 
// is it state county? No.
duplicates tag statefp countyfp, gen(dup)
tab dup 
drop dup 

// is it state county year? Yes. 
duplicates tag statefp countyfp year, gen(dup)
assert dup == 0
drop dup 

//////////////////////////////
// TURN INTO BALANCED PANEL //
//////////////////////////////

// joint state county id
assert !missing(statefp)
assert !missing(countyfp)
gen statecountyfp = statefp*1000+countyfp
order statecountyfp, after(countyfp)

// statecounty EVER has a food bank grant 
assert !missing(has_food_bank_grant)
assert inlist(has_food_bank_grant,0,1)
bysort statecountyfp: egen has_food_bank_grant_ever = max(has_food_bank_grant)
preserve 
	keep statecountyfp has_food_bank_grant_ever
	duplicates drop 
	sum has_food_bank_grant_ever
	display in red `r(mean)'*100 "percent of counties ever have a food bank grant"
	display in red `r(N)' " total counties listed (denominator)"
restore 

// balanced panel of ONLY areas that ever have a grant 
preserve 
	keep if has_food_bank_grant_ever == 1
	assert !missing(year)

	// set panel data 
	xtset statecountyfp year 
	tsfill, full 

	// carryforward variables 
	foreach var in _id statefp countyfp stateabbreviation statename countyname territories continental {

		// forward in time
		bysort statecountyfp (year): carryforward `var', replace 

		// backward in time 
		gsort statecountyfp -year
		by statecountyfp: carryforward `var', replace 
		gsort statecountyfp year 

	}

	// carryforward variables
	// **KP: not sure if all of this is correct 
	foreach var in copop coarea coarealand affid affid1 affid2 fa_fb_region split_shared combine_food_bank population201519acs estimatehouseholdstotal hh_inc_less_than_025 hh_inc_less_than_035 hh_inc_less_than_050 has_food_bank_grant_ever main_fiscal_year main_fiscal_year_percent {
	
		// forward in time
		bysort statecountyfp (year): carryforward `var', gen(`var'_for) 
		assert `var' == `var'_for if !missing(`var') & !missing(`var'_for)
		bysort statecountyfp (year): carryforward `var', replace 
		drop `var'_for  


		// backward in time 
		gsort statecountyfp -year
		by statecountyfp: carryforward `var', gen(`var'_back) 
		assert `var' == `var'_back if !missing(`var') & !missing(`var'_back)
		by statecountyfp: carryforward `var', replace 
		drop `var'_back
		gsort statecountyfp year 

	}

	// variables to fill in 
	replace has_food_bank_grant	= 0 if missing(has_food_bank_grant)

	// leave as missing if has_food_bank_grant = 0
	// amount_grant
	// amoung_grant_inregion
	// but create versions of these vars that are nonmissing (include zeros)
	foreach var in amount_grant	amount_grant_inregion {
		gen `var'_nomiss = `var'	
		replace `var'_nomiss	= 0 if missing(`var'_nomiss)
	}

	// save 
	tempfile ever_grant_yes
	save `ever_grant_yes'

restore

// balanced panel of ONLY areas that NEVER have a grant 
preserve 
	keep if has_food_bank_grant_ever == 0
	assert missing(year)

	// drop year 
	drop year 

	// assert level of data 
	duplicates tag statefp countyfp, gen(dup)
	assert dup == 0
	drop dup 

	// asset level of data (2)
	duplicates tag statecountyfp, gen(dup)
	assert dup == 0
	drop dup 

	// generate multiple observations, one for each year 
	local num_obs = $year_max - $year_min + 1
	expand `num_obs'
	bysort statefp countyfp: gen year = _n + $year_min - 1
	sum year 
	assert `r(min)' == $year_min
	assert `r(max)' == $year_max

	// assert level of the data 
	duplicates tag statecountyfp year, gen(dup)
	assert dup == 0
	drop dup 

	// set panel data 
	xtset statecountyfp year 
	*tsfill, full 

	// variables to fill in 
	assert !missing(has_food_bank_grant)
	
	// leave as missing if has_food_bank_grant = 0
	// amount_grant
	// amoung_grant_inregion
	// but create versions of these vars that are nonmissing (include zeros)
	foreach var in amount_grant	amount_grant_inregion {
		gen `var'_nomiss = `var'	
		replace `var'_nomiss	= 0 if missing(`var'_nomiss)
	}

	// save 
	tempfile ever_grant_no
	save `ever_grant_no'

restore


***********************************************************

// append two datasets 
use `ever_grant_yes', clear 
append using `ever_grant_no'

// assert level of the data 
duplicates tag statecountyfp year, gen(dup)
assert dup == 0
drop dup 

// check if panel is balanced
xtset statecountyfp year 
*tab statecountyfp 
*tab year 
unique statecountyfp
unique year 
dis 3218*7
count
assert `r(N)' == 22526

// does the data have all counties? Yes, looks like it. 
unique countyname if statename == "Virginia" // looks good 
unique countyname if statename == "Illinois" // looks good 

// save 
save "${dir_root}/data/food_pantry/IRS 990 - James, Erik/irs990_balancedpanel.dta", replace


**********************************************************************************************

// save version at the state-year level 

// load county-year level data 
use "${dir_root}/data/food_pantry/IRS 990 - James, Erik/irs990_balancedpanel.dta", clear 

// collapse 
// for now, weight by population
#delimit ;
collapse 
(sum) 
amount_grant 
amount_grant_inregion
/*amount_grant_nomiss this will give the same answer since collapse treats missings as zeros. They differ because of numerical calculations, data types, etc. (nothing to be concerned about)*/
/*amount_grant_inregion_nomiss*/
(mean)
has_food_bank_grant
has_food_bank_grant_ever
[fweight = copop]
, by(statefp year 
	 statename stateabbreviation 
	 )
;
#delimit cr 
*assert abs(amount_grant - amount_grant_nomiss) < 10000
*assert abs(amount_grant_inregion - amount_grant_inregion_nomiss) < 10000
capture drop amount_grant_nomiss
capture drop amount_grant_inregion_nomiss

// assert level of data 
duplicates tag statefp year, gen(dup)
assert dup == 0
drop dup 

// save **BASIC** state-year level data 
save "${dir_root}/data/food_pantry/IRS 990 - James, Erik/irs990_balancedpanel_stateyear.dta", replace

**KP: do something fancier with fiscal years (ignoring for now )


********************************************************************************************************

// load state data 
use "${dir_root}/data/food_pantry/IRS 990 - James, Erik/irs990_balancedpanel_stateyear.dta", clear 

KEEP GOING HERE: FIRST, MAKE A YEAR, RATHER THAN A MONTH VERSION OF THAT GRAPH


	// load data
	*use "${dir_root}/data/state_data/state_ym.dta", clear 
	merge m:1 state using "${dir_root}/data/state_data/clocks_wide.dta", assert(2 3) keep(3) nogen

	// event: binding events only 
	gen bindingexpected_year = year(dofm(bindingclockstart_ym + 3 + 1 + adjust_clock))
	*gen bindingexpected_ym = bindingclockstart_ym + 3 + 1 /*+ 0.5*/ + adjust_clock

	// relative time 
	gen relative_ym = ym - bindingexpected_ym
sum relative_ym
/*

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
 relative_ym |      2,158   -51.25579    74.94855       -279         71

*/
*check
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
	reg log_`y' _*_months_before _*_months_after i.state_num i.ym, vce(cluster state_num) // nocons
	*reg log_`y' _*_months_before _*_months_after i.state_num /*i.state_num#c.r_1 i.state_num#c.r_2*/ /*i.state_num#c.zXr_1*/ /*i.state_num#c.r_2 i.state_num#c.r_3 i.state_num#c.r_4 i.state_num#c.r_5*/ , vce(cluster state_num) // nocons
**KP: not sure if this is the right regression, with two-way FE

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





br 

check


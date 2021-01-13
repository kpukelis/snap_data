// analyze_state_ym.do
// Kelsey Pukelis

local clocks_num 				= 9
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local ytitle_size 				small
local dot_size 					vsmall
local vline_color 				black
local vline_color_binding		blue

*************************************************************************************

// load data 
use "${dir_root}/data/state_data/state_ym.dta", clear 
merge m:1 state using "${dir_root}/data/state_data/clocks_wide.dta", assert(2 3) keep(3) nogen

/*
// SET OF STATE GRAPHS 
levelsof state, local(states)
foreach state of local states {

	// preserve
	preserve
	
	// just keep this state's data
	keep if state == "`state'"
	dropmiss individuals households issuance adults children, force 

	// save adjust_clock amoung 
	qui sum adjust_clock
	if `r(N)' > 0 {
		assert `r(min)' == `r(max)'
		local adjust_clock = `r(mean)'
	}
	else {
		local adjust_clock = 0
	}

	// graph each var 
	foreach var in individuals households issuance adults children {
		capture confirm variable `var'
		if !_rc {

			// state up graph range 
			sum ym if !missing(`var')	
			local start_graph 	= `r(min)'
			local end_graph		= `r(max)'

			// set up vertical lines 
			forvalues n = 1/`clocks_num' {
				qui sum clockstart_ym`n'
				if `r(N)' > 0 {
					assert `r(min)' == `r(max)' 
					local expected`n' = `r(mean)' + 3 + 0.5 + `adjust_clock'
				}
				else {
					local expected`n' = `end_graph'
				}
			}
			qui sum bindingclockstart_ym
			if `r(N)' > 0 {
				assert `r(min)' == `r(max)' 
				local bindingexpected = `r(mean)' + 3 + 0.5 + `adjust_clock'
			}
			else {
				local bindingexpected = `end_graph'
			}

			// graph 
			#delimit ;
			twoway connected `var' ym if inrange(ym,`start_graph',`end_graph'), 
				msize(`dot_size')
				xline(`expected1', lcolor(`vline_color'))
				xline(`expected2', lcolor(`vline_color'))
				xline(`expected3', lcolor(`vline_color'))
				xline(`expected4', lcolor(`vline_color'))
				xline(`expected5', lcolor(`vline_color'))
				xline(`expected6', lcolor(`vline_color'))
				xline(`expected7', lcolor(`vline_color'))
				xline(`expected8', lcolor(`vline_color'))
				xline(`expected9', lcolor(`vline_color'))
				xline(`bindingexpected',lcolor(`vline_color_binding'))
				xtitle(`""')
				title(`"`state'"')
				graphregion(fcolor(`background_color'))
			;
			#delimit cr 
			graph export "${dir_graphs}/`state'_`var'.png", as(png) replace 
		}
		else {
		}
	
	}

	restore
}
*/

// event: binding events only 
gen bindingexpected_ym = bindingclockstart_ym + 3 + 1 /*+ 0.5*/ + adjust_clock

// relative time 
gen relative_ym = ym - bindingexpected_ym

// sample of states with a visible first stage 
keep if !missing(bindingexpected_ym)


// RESIDUAL

// generate polynomial terms 
gen r_1 = relative_ym
gen z = (r_1 >= 0)
gen zXr_1 = z*r_1
forvalues d = 2(1)7 {
	gen r_`d' = r_1^`d'
	gen zXr_`d' = z*r_`d'
}

// generate numeric state var (need it to be numeric to use i. notation)
encode state, gen(state_num)

// for this regression, limit to where outcome is nonmissing
keep if !missing(individuals)
gen log_individuals = log(individuals)


// event study plot 
**KP: expand this range later
keep if inrange(r_1,-12,12)

regress log_individuals 



// estimation of discontinuity
#delimit ;
qui regress log_individuals z i.state_num 
						i.state_num#c.r_1 i.state_num#c.zXr_1
						i.state_num#c.r_2 i.state_num#c.zXr_2
						i.state_num#c.r_3 i.state_num#c.zXr_3
						i.state_num#c.r_4 i.state_num#c.zXr_4
						i.state_num#c.r_5 i.state_num#c.zXr_5
						i.state_num#c.r_6 i.state_num#c.zXr_6
						i.state_num#c.r_7 i.state_num#c.zXr_7
;
display in red _b[z] ;
qui regress log_individuals z i.state_num 
						i.state_num#c.r_1 i.state_num#c.zXr_1
						i.state_num#c.r_2 i.state_num#c.zXr_2
						i.state_num#c.r_3 i.state_num#c.zXr_3
						i.state_num#c.r_4 i.state_num#c.zXr_4
						i.state_num#c.r_5 i.state_num#c.zXr_5
						i.state_num#c.r_6 i.state_num#c.zXr_6
;
display in red _b[z] ;
qui regress log_individuals z i.state_num 
						i.state_num#c.r_1 i.state_num#c.zXr_1
						i.state_num#c.r_2 i.state_num#c.zXr_2
						i.state_num#c.r_3 i.state_num#c.zXr_3
						i.state_num#c.r_4 i.state_num#c.zXr_4
						i.state_num#c.r_5 i.state_num#c.zXr_5
;
display in red _b[z] ;
qui regress log_individuals z i.state_num 
						i.state_num#c.r_1 i.state_num#c.zXr_1
						i.state_num#c.r_2 i.state_num#c.zXr_2
						i.state_num#c.r_3 i.state_num#c.zXr_3
						i.state_num#c.r_4 i.state_num#c.zXr_4
;
display in red _b[z] ;
#delimit cr 
*matrix list e(b)

check

/////////////////////
// AVERAGE / TOTAL //
///////////////////// 

// single graph in relative time, all states; one average, one total 
foreach var in individuals households issuance adults children {
	preserve
	keep if !missing(`var')
	collapse (sum) sum_`var'=`var' (mean) mean_`var'=`var', by(relative_ym)
	tempfile `var'
	save ``var''
	restore
}
foreach var in individuals households issuance adults children {
	if "`var'" == "individuals" {
		use ``var'', clear
	}
	else {
		merge 1:1 relative_ym using ``var'', nogen
	}
}


// label vars 
label var sum_individuals "Individuals - total"
label var sum_households "Households - total"
label var sum_issuance "Issuance - total"
label var sum_adults "Adults - total"
label var sum_children "Children - total"
label var mean_individuals "Individuals - mean"
label var mean_households "Households - mean"
label var mean_issuance "Issuance - mean"
label var mean_adults "Adults - mean"
label var mean_children "Children - mean"

foreach var in individuals households issuance adults children {
	foreach type in sum mean {

	// graph 
	#delimit ;
	twoway connected `type'_`var' relative_ym if inrange(relative_ym,-12,12), 
			msize(`dot_size')
			xline(-0.5,lcolor(`vline_color_binding'))
			xtitle(`""')
			title(`"`state'"')
			graphregion(fcolor(`background_color'))
		;
	#delimit cr 

	graph export "${dir_graphs}/_`var'_`type'.png", as(png) replace 
	
	}
}

check



///////////////////
// RELATIVE TIME //
///////////////////

/*
// relative time
forvalues n = 1/`clocks_num' {
	gen relative_3ym`n' = ym - (clockstart_ym`n' + 3)
	*gen relative_4ym`n' = ym - (clockstart_ym`n' + 4)
	gen abs_relative_3ym`n' = abs(relative_3ym`n')
}

describe abs_relative_3ym*, varlist
*assert "`r(k)'" == "`clocks_num'" **KP doesn't work
local abs_vars `r(varlist)'

// mark smallest absolute value 
egen min_abs_relative_3ym = rowmin(`abs_vars')

// generate final relative time based on the smallest relative time 
gen relative_3ym = .
forvalues n = 1/`clocks_num' {
	replace relative_3ym = relative_3ym`n' if abs_relative_3ym`n' == min_abs_relative_3ym
}
tab relative_3ym
drop relative_3ym? 
drop abs_relative_3ym?
drop min_abs_relative_3ym
*/

check

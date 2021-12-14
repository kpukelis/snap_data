// analyze_southcarolina.do 
// Kelsey Pukelis
// see if enrollment coincides with fixed statewide clock (no county waivers)

local statewide_nowaiver 		= ym(2016,6) + 0.5
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
*local start_graph				ym(2008,1) 
*local end_graph 				ym(2021,1)
local start_graph				ym(2014,1) 
local end_graph 				ym(2018,12)
local ytitle_size 				small
local dot_size 					vsmall

***********************************************************************************************
// combined county data 
use "${dir_root}/data/state_data/state_ym.dta", clear 

// just keep south carolina 
keep if state == "southcarolina"

// drop missing vars 
dropmiss, force 
dropmiss, force obs 

// for now, just drop 2019m2 because of outlier (gov shutdown)
drop if ym == ym(2019,2)

***********************************************************************************************

//////////////////////
// STATEWIDE GRAPHS //
//////////////////////

// assert level of data 
duplicates tag ym, gen(dup)
assert dup == 0
drop dup 

/*
foreach outcome in households individuals issuance {

	#delimit ;
	twoway connected `outcome' ym if ym >= `start_graph',
		xline(`statewide_nowaiver')
		msize(`dot_size')
		xtitle(`""')
		title(`""')
		caption(`"Vertical line where statewide waiver ends."')
		graphregion(fcolor(`background_color'))
	;
	#delimit cr 
	graph export "${dir_graphs}/southcarolina_raw_`outcome'.png", replace as(png)

}
*/
	#delimit ;
	twoway  (connected households ym if ym >= `start_graph' & ym <= `end_graph', yaxis(1) msize(`dot_size') mcolor(black) lcolor(black))
			(connected individuals ym if ym >= `start_graph' & ym <= `end_graph', yaxis(2) msize(`dot_size') mcolor(blue) lcolor(blue)
		/*	(connected issuance ym if ym >= `start_graph' & ym <= `end_graph', yaxis(2) msize(`dot_size') mcolor(green) lcolor(green)*/
			legend(label(1 "Households (left)") label(2 "Individuals (right)") /*label(3 "Issuance (right)")*/ region(lcolor(`background_color')))
			xline(`statewide_nowaiver')
			ylabel(,labsize(vsmall) angle(0) axis(1))
			ylabel(,labsize(vsmall) angle(0) axis(2))
			xtitle(`""')
			ytitle(`""', axis(1))
			ytitle(`""', axis(2))
			title(`""')
			caption(`"Vertical line where statewide waiver ends."')
			graphregion(fcolor(`background_color'))
		)
	;
	#delimit cr 

	graph export "${dir_graphs}/southcarolina_raw_start`start_graph'_end`end_graph'.png", replace as(png)

// determine number of people who lost benefits in this state
count if ym == ym(2016,6)
assert `r(N)' == 1
count if ym == ym(2016,7)
assert `r(N)' == 1
foreach var in households individuals {
	sum `var' if ym == ym(2016,6)	
	local `var'_before = `r(mean)'
	sum `var' if ym == ym(2016,7)	
	local `var'_after = `r(mean)'
	local `var'_lost = ``var'_before' - ``var'_after'
	display in red "ABAWD `var' lost" ``var'_lost' "=" ``var'_before' "-" ``var'_after'
}


check


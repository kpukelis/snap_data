// analyze_newyork.do 
// Kelsey Pukelis
// see if enrollment coincides with coming off of ARRA statewide waiver (statewide waiver to county waivers)

local statewide_nowaiver 		= ym(2016,3) + 0.5
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2000,1) 
local end_graph 				ym(2022,1)
*local start_graph				ym(2014,1) 
*local end_graph 				ym(2021,6)
local ytitle_size 				small
local dot_size 					tiny

***********************************************************************************************

// combined county data 
use "${dir_root}/data/state_data/county_ym.dta", clear 

// just keep new york
keep if state == "newyork"

// drop missing vars 
dropmiss, force 
dropmiss, force obs 

// tempfile 
tempfile enrollment_ny 
save `enrollment_ny'

***********************************************************************************************

// waiver data 
import excel using "${dir_root}/data/policy_data/state_exempt_counties/new york/ny_waivers.xlsx", sheet("counties") case(lower) allstring firstrow clear 

// clean up
dropmiss, force 
dropmiss, force obs

// destring 
foreach var in year month waiver {
	destring `var', replace
	confirm numeric variable `var'
}

// date 
gen ym = ym(year,month)
format ym %tm
drop year
drop month 

// assert level of data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order and sort 
order county ym waiver 
sort county ym 

// tempfile 
tempfile ny_waivers
save `ny_waivers'

***********************************************************************************************
//////////////////////
// STATEWIDE GRAPHS //
//////////////////////

// load data 
use `enrollment_ny', clear 

// collapse to state total level 
// (ignores county waiver variation, for now)
assert !strpos(county,"total") & !strpos(county,"state")
collapse (sum) households individuals issuance, by(ym)

// assert level of data 
duplicates tag ym, gen(dup)
assert dup == 0
drop dup 

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

	graph export "${dir_graphs}/newyork_raw_start`start_graph'_end`end_graph'.png", replace as(png)

***********************************************************************************************

///////////
// MERGE //
///////////

// merge 
use `enrollment_ny', clear
merge 1:1 county ym using `ny_waivers'

// check merge 
assert inrange(ym,ym(2001,1),ym(2009,3)) if _m == 1
assert inrange(ym,ym(2020,5),ym(2022,12)) | inlist(county,"bronx","kings","richmond") if _m == 2
rename _m merge_waivers

// variable that tells when first waiver was beginning 2016
preserve
	keep if inrange(ym,ym(2016,1),ym(2022,9))
	gen temp = ym if waiver == 1 | waiver == 0.5
	bysort county: egen first_waiver = min(temp)
	format first_waiver %tm
	keep county first_waiver
	duplicates drop 

	// assert level of data 
	duplicates tag county, gen(dup)
	assert dup == 0
	drop dup 

	// variable should be nonmissing
	assert !missing(first_waiver)

	// save 
	tempfile first_waiver
	save `first_waiver'
restore 

// merge in var that has month of first waiver 
merge m:1 county using `first_waiver'
assert _m == 3
drop _m

// collapse data by groups of counties that share the same month of a first waiver 
collapse (sum) individuals households issuance, by(first_waiver ym)

// assert level of data 
duplicates tag first_waiver ym, gen(dup)
assert dup == 0
drop dup 

tab first_waiver

local outcome households 

	#delimit ;
	twoway  (connected `outcome' ym if first_waiver == ym(2016,1) & ym >= `start_graph' & ym <= `end_graph', yaxis(1) msize(`dot_size') mcolor(black) lcolor(black))
			(connected `outcome' ym if first_waiver == ym(2020,10) & ym >= `start_graph' & ym <= `end_graph', yaxis(1) msize(`dot_size') mcolor(gray) lcolor(gray))
			(connected `outcome' ym if first_waiver == ym(2017,1) & ym >= `start_graph' & ym <= `end_graph', yaxis(2) msize(`dot_size') mcolor(blue) lcolor(blue))
			(connected `outcome' ym if first_waiver == ym(2018,1) & ym >= `start_graph' & ym <= `end_graph', yaxis(2) msize(`dot_size') mcolor(green) lcolor(green))
			(connected `outcome' ym if first_waiver == ym(2018,3) & ym >= `start_graph' & ym <= `end_graph', yaxis(2) msize(`dot_size') mcolor(red) lcolor(red))
			(connected `outcome' ym if first_waiver == ym(2019,1) & ym >= `start_graph' & ym <= `end_graph', yaxis(2) msize(`dot_size') mcolor(purple) lcolor(purple))
			(connected `outcome' ym if first_waiver == ym(2020,4) & ym >= `start_graph' & ym <= `end_graph', yaxis(2) msize(`dot_size') mcolor(orange) lcolor(orange)
			legend(label(1 "First waiver beginning 2016m1 (left)") label(2 "2020m10 (left)") label(3 "2017m1") label(4 "2018m1") label(5 "2018m3") label(6 "2019m1") label(7 "2020m4") region(lcolor(`background_color')))
			xline(`statewide_nowaiver')
			ylabel(,labsize(vsmall) angle(0) axis(1))
			ylabel(,labsize(vsmall) angle(0) axis(2))
			xtitle(`""')
			ytitle(`""', axis(1))
			ytitle(`""', axis(2))
			title(`""')
			caption(`"Vertical line where statewide waiver ends."' `"Includes partial waivers (e.g. city within county)."')
			graphregion(fcolor(`background_color'))
		)
	;
	#delimit cr 

	graph export "${dir_graphs}/newyork_groups_start`start_graph'_end`end_graph'.png", replace as(png)


check


***********************************************************************************************


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


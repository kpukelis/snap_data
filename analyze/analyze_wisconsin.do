// wisconsin_analyze.do
local statewide_nowaiver 		= ym(2015,4)
local statewide_nowaiver_year 	= 2015
local statewide_waiver_year 	= 2002
local outcome 					households
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2011,1) 
local ytitle_size 				small
local dot_size 					vsmall


****************************************************************
/*
/////////////
// WAIVERS //
/////////////

**KP: some of this is wrong based on CBPP map: https://www.cbpp.org/research/food-assistance/states-have-requested-waivers-from-snaps-time-limit-in-high-unemployment

// import waivers data 
import excel "${dir_root}/data/policy_data/state_exempt_counties/wisconsin/wisconsin_waivers.xlsx", firstrow case(lower) allstring clear

// county 
replace county = strlower(county)

// destring 
foreach v of varlist _all {
	if "`v'" != "county" {
		destring `v', replace	
		confirm numeric variable `v'
	}
}

// reshape
gen month = .
reshape long waiver, i(county) j(yyyymm) string 

// get to county ym level 
expand 12 if strlen(yyyymm) == 4
bysort county yyyymm: replace month = _n if strlen(yyyymm) == 4
expand 3 if inlist(yyyymm,"20150103")
bysort county yyyymm: replace month = _n if inlist(yyyymm,"20150103")
expand 9 if inlist(yyyymm,"20150412")
bysort county yyyymm: replace month = _n + 3 if inlist(yyyymm,"20150412")
gen monthname = substr(yyyymm,5,2) if strlen(yyyymm) == 6
destring monthname, replace 
confirm numeric variable monthname
replace month = monthname if strlen(yyyymm) == 6
drop monthname

// year, ym 
gen year = substr(yyyymm,1,4)
destring year, replace
confirm numeric variable year 
drop yyyymm
sort county year month 
gen ym = ym(year,month)
format ym %tm 
drop year month 

// order and sort 
order county ym waiver 
sort county ym 

// save 
save "${dir_root}/data/state_data/wisconsin/wisconsin_waivers.dta", replace 
gen year = year(dofm(ym))
collapse (mean) waiver, by(county year)
save "${dir_root}/data/state_data/wisconsin/wisconsin_waivers_year.dta", replace 
collapse (mean) waiver, by(year)
save "${dir_root}/data/state_data/wisconsin/wisconsin_waivers_year_state.dta", replace 
twoway connected waiver year 
*/
***********************************************************************************************

////////////////////////////////////
// ABAWDS LOST DUE TO TIME LIMITS //
////////////////////////////////////

// import data
import excel "${dir_root}/data/policy_data/state_exempt_counties/wisconsin/data on those who lost eligibility/wisconsin_lost.xlsx", firstrow case(lower) allstring clear

// reshape
reshape long _, i(region) j(yyyymm) string 
rename _ individuals_lost 

// date 
gen year = substr(yyyymm,1,4)
gen month = substr(yyyymm,5,2)
destring year, replace
destring month, replace
confirm numeric variable year 
confirm numeric variable month 
gen ym = ym(year,month)
format ym %tm 
drop year month 
drop yyyymm

// destring 
destring individuals_lost, replace 
confirm numeric variable individuals_lost

// region county crosswalk for later 
**import excel "${dir_root}/data/policy_data/state_exempt_counties/wisconsin/data on those who lost eligibility/wisconsin_lost.xlsx", sheet("region county crosswalk") firstrow case(lower) allstring clear

// order and sort 
order region ym individuals_lost
sort region ym 

// save 
save "${dir_root}/data/state_data/wisconsin/wisconsin_lost.dta", replace 
keep if region == "Total"
drop region 
save "${dir_root}/data/state_data/wisconsin/wisconsin_lost_state.dta", replace 

***********************************************************************************************

//////////////////////
// STATEWIDE GRAPHS //
//////////////////////

// monthly data 
use "${dir_root}/data/state_data/wisconsin/wisconsin.dta", clear 
keep if county == "total"

// assert level of data 
duplicates tag ym, gen(dup)
assert dup == 0
drop dup 

// merge in individuals_lost variable 
merge 1:1 ym using "${dir_root}/data/state_data/wisconsin/wisconsin_lost_state.dta"
assert _m == 3 if inrange(ym,ym(2015,7),ym(2019,12))
drop _m 

// cumulative total without individuals lost 
/*bysort state:*/ gen individuals_lost_cum = sum(individuals_lost)

// counterfactual individuals, if ABAWDs not lost 
// 2015m7: first month abawds could lose eligibility (3 months after statewide time limit ends)
// 2020m3: statewide waiver goes back into effect 2020m4
gen individuals_plus_lost_cum = individuals + individuals_lost_cum if inrange(ym,ym(2015,7),ym(2020,3))


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
	graph export "${dir_graphs}/wisconsin_raw_`outcome'.png", replace as(png)

}
*/
	#delimit ;
	twoway  (connected individuals ym if ym >= `start_graph', yaxis(1) msize(`dot_size') mcolor(black) lcolor(black))
			(connected individuals_plus_lost_cum ym if ym >= `start_graph', yaxis(1) msize(`dot_size') mcolor(blue) lcolor(blue))
			(connected individuals_lost ym if ym >= `start_graph', yaxis(2) msize(`dot_size') mcolor(green) lcolor(green)
			legend(label(1 "Individuals (left)") label(2 "Individuals if no time limits (left)") label(3 "ABAWDs lost elig. in month (right)") region(lcolor(`background_color')))
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
	graph export "${dir_graphs}/wisconsin_raw_individuals_lost.png", replace as(png)


check
// yearly data 
use "${dir_root}/data/state_data/wisconsin/wisconsin_year.dta", clear 
keep if county == "unduplicated state total"
rename cases households
rename recipients individuals
foreach outcome in households individuals adults children {

	#delimit ;
	twoway connected `outcome' year,
		xline(`statewide_waiver_year')
		xline(`statewide_nowaiver_year')
		msize(`dot_size')
		xtitle(`""')
		title(`""')
		caption(`"Vertical lines where statewide waiver begins and ends."')
		graphregion(fcolor(`background_color'))
	;
	#delimit cr 
	graph export "${dir_graphs}/wisconsin_raw_yearly_`outcome'.png", replace as(png)

}
*/


check


****************************************************************

// load yearly data 
use "${dir_root}/data/state_data/wisconsin/wisconsin_year.dta", clear 

// clean up county names 

// merge with 


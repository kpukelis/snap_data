// newyork_southerntier.do
// Kelsey Pukelis
// checks out first stage variation for Southern Tier food bank counties
// Broome, Chemung, Schuyler, Steuben, Tioga, and Tompkins
// https://www.foodbankst.org/about-us-2/
// https://www.cbpp.org/research/food-assistance/states-have-requested-waivers-from-snaps-time-limit-in-high-unemployment

use "${dir_root}/data/state_data/newyork/newyork.dta", clear

// only Southern Tier counties
foreach c in broome chemung schuyler steuben tioga tompkins {
	count if county == "`c'"
	assert `r(N)' > 0
}
keep if inlist(county,"broome","chemung","schuyler","steuben","tioga","tompkins")

// year 
gen year = year(dofm(ym))
gen month = month(dofm(ym))

// waiver info, from 
// https://www.cbpp.org/research/food-assistance/states-have-requested-waivers-from-snaps-time-limit-in-high-unemployment
gen waiver_year = .
replace waiver_year = 0 if inrange(year,2006,2008)
replace waiver_year = 1 if inrange(year,2009,2015)
replace waiver_year = 0 if year == 2016
replace waiver_year = 0 if year == 2017 & inlist(county,"chemung","tioga","tompkins")
replace waiver_year = 1 if year == 2017 & inlist(county,"steuben","schuyler","broome")
replace waiver_year = 0 if year == 2018 & inlist(county,"tioga","tompkins")
replace waiver_year = 1 if year == 2018 & inlist(county,"steuben","schuyler","broome","chemung")
replace waiver_year = 0 if year == 2019 & inlist(county,"tioga","tompkins")
replace waiver_year = 1 if year == 2019 & inlist(county,"steuben","schuyler","broome","chemung")

gen nowaiver_year = 1 - waiver_year

// total households 
*keep if year >= 2014
#delimit ;
twoway 
	(connected households ym if county == "broome", yaxis(1) msize(vsmall))
	(connected households ym if county == "chemung", yaxis(2) msize(vsmall))
	(connected households ym if county == "schuyler", yaxis(2) msize(vsmall))
	(connected households ym if county == "steuben", yaxis(2) msize(vsmall))
	(connected households ym if county == "tioga", yaxis(2) msize(vsmall))
	(connected households ym if county == "tompkins", yaxis(2) msize(vsmall)
	legend(off)
	xline(576, lcolor(blue))  /*ym(2008,1)*/
	xline(660.5, lcolor(red)) /*ym(2015,1)*/
	xline(672.5, lcolor(blue)) /*ym(2016,1)*/
	xline(684.5, lcolor(blue)) /*ym(2017,1)*/
	xline(708.5, lcolor(black)) /*ym(2019,1)*/
	caption("counties, from top to bottom: broome (only left), chemung, steuben, tompkins, tioga, schuyler", size(small))
	graphregion(fcolor(white))
	)
;
#delimit cr 

preserve
collapse (sum) households, by(ym)
keep if ym >= ym(2014,1)
#delimit ;
twoway 
	(connected households ym, msize(vsmall)
	legend(off)
	xline(576, lcolor(blue))  /*ym(2008,1)*/
	xline(660.5, lcolor(red)) /*ym(2015,1)*/
	xline(672.5, lcolor(blue)) /*ym(2016,1)*/
	xline(684.5, lcolor(blue)) /*ym(2017,1)*/
	xline(708.5, lcolor(black)) /*ym(2019,1)*/
	graphregion(fcolor(white))
	)
;
#delimit cr 
restore

encode county, gen(county_fakenum)
regress households waiver_year nowaiver_year, nocons
regress households waiver_year nowaiver_year i.month, nocons
regress households waiver_year nowaiver_year i.county_fakenum, nocons
regress households waiver_year nowaiver_year i.month i.county_fakenum, nocons


regress households waiver_year
regress households waiver_year i.month
regress households waiver_year i.county_fakenum
regress households waiver_year i.month i.county_fakenum

check


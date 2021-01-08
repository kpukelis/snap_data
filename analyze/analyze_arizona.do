// analyze_arizona.do 

local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2010,1)
local ytitle_size 				small
local dot_size 					vsmall

*local beginning_clock1 			= ym(2016,1) - 0.5
local beginning_clock1 			= ym(2015,12) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 			= ym(2019,1) - 0.5
local beginning_clock2 			= ym(2018,12) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1

******************************************************************

use "${dir_root}/state_data/arizona/arizona.dta", clear 
drop if county == "total"

gen waiver2016 = 0
replace waiver2016 = 1 if inlist(county,"mohave","la paz","yuma","coconino","navajo","apache","gila","pinal","santa cruz") | inlist(county,"graham","greenlee","cochise")
unique county if waiver2016 == 1 // should be 12

collapse (sum) households individual adults children issuance, by(waiver2016 ym)

gen relative_ym = ym - `expected_clock1'

separate adults, by(waiver2016)
separate children, by(waiver2016)

keep if inrange(relative_ym,-12,12)
*ym >= `start_graph'
gen year = year(dofm(ym))
gen month = month(dofm(ym))

*forvalue d = 2

foreach var in adults0 children0 adults1 children1 {
	*regress `var' i.year i.month
	regress `var' ym 
	predict resid_`var', residual
}



// graph
#delimit ;
	twoway (connected adults0 ym , yaxis(1) msize(`dot_size')) 
		   (connected children0 ym , yaxis(1) msize(`dot_size'))
		   (connected adults1 ym , yaxis(2) msize(`dot_size'))
		   (connected children1 ym , yaxis(2) msize(`dot_size')
		/*legend(label(1 "No county waiver (left axis)") label(2 "County waiver (right axis)") region(lstyle(none))) */
		ylabel(,labsize(vsmall) axis(1))
		ylabel(,labsize(vsmall) axis(2))
		xline(`expected_clock1') xline(`expected_clock2') 
		xtitle(`""') 
		title(`""') 
		caption(`"Vertical line at expected effect."' `"waiver2016 = 0 series on left axis and waiver2016 = 1 series on right axis."', size(small)) 
		graphregion(fcolor(`background_color')) 
		)
;
#delimit cr 
		
	graph export "${dir_graphs}/arizona_raw_bywaiver_byage.png", replace as(png)
check
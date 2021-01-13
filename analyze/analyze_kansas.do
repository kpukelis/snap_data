// analyze_kansas.do 

*local beginning_clock1 			= ym(2013,10) - 0.5
local beginning_clock1 			= ym(2013,9) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 			= ym(2016,10) - 0.5
local beginning_clock2 			= ym(2016,9) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
*local beginning_clock3 			= ym(2019,10) - 0.5
local beginning_clock3 			= ym(2019,9) - 0.5
local expected_clock3 			= `beginning_clock3' + 3 + 1
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local ytitle_size 				small
local dot_size 					vsmall


******************************************************************

use "${dir_root}/data/state_data/kansas/kansas.dta", clear 
keep if county == "total"


gen relative_ym = ym - (ym(2013,9) + 3)

keep if inrange(relative_ym,-12,12)
*ym >= `start_graph'

// graph
#delimit ;
	twoway (connected adults ym , yaxis(1) msize(`dot_size')) 
		   (connected children ym , yaxis(2) msize(`dot_size')
		/*legend(label(1 "No county waiver (left axis)") label(2 "County waiver (right axis)") region(lstyle(none))) */
		xline(`expected_clock1') xline(`expected_clock2') 
		xtitle(`""') 
		title(`""') 
		caption(`"Vertical line at expected effect."', size(small)) 
		graphregion(fcolor(`background_color')) 
		)
;
#delimit cr 

graph export "${dir_graphs}/kansas_raw_byage.png", replace as(png)

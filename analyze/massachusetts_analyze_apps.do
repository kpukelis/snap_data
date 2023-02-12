// massachusetts_analyze_apps.do
// Kelsey Pukelis

local graph_start 		= ym(2019,1)
local graph_end 		= ym(2022,8)
*local MA_extend_begin 	= ym(2020,3) - 0.5
local MA_extend_begin 	= ym(2020,4) - 0.5
local MA_extend_end 	= ym(2020,6) + 0.5
*local MA_extend_begin2 	= ym(2020,12) - 0.5
*local MA_extend_end2 	= ym(2021,1) + 0.5
local MA_extend_begin2 	= ym(2021,7) - 0.5
local MA_extend_end2 	= ym(2022,8) + 0.5
local shaded_center 	= ((`MA_extend_end' - `MA_extend_begin') / 2) + `MA_extend_begin'
local shaded_center2 	= ((`MA_extend_end2' - `MA_extend_begin2') / 2) + `MA_extend_begin2'
*local shaded_center3 	= ((`MA_extend_end3' - `MA_extend_begin3') / 2) + `MA_extend_begin3'
local shaded_width 		= `MA_extend_end' - `MA_extend_begin'
local shaded_width2		= `MA_extend_end2' - `MA_extend_begin2'
*local shaded_width3		= `MA_extend_end3' - `MA_extend_begin3'

display in red "`shaded_center'" // "`shaded_width'"


*************************************************************************

// load data
use "${dir_root}/data/state_data/massachusetts/massachusetts_zipcode.dta", clear 

// check nonmissingness
*tab city if !missing(churn_rate)
tab city if !missing(recerts_due)

// limit years of graph 
keep if inrange(ym,`graph_start',`graph_end')

// label vars 
label var churn_rate "Churn rate"
label var recerts_due "Recerts due"
label var reason_walkin_recert "Reason for walk-in: recertification"

// analyze churn rate, recerts_due
*preserve
keep if !missing(churn_rate) | !missing(recerts_due) | !missing(reason_walkin_recert)
assert city == "total"
sort ym 
#delimit ; 
	twoway 	(connected churn_rate ym, yaxis(1))
			(connected recerts_due ym, yaxis(2)
			/*(connected reason_walkin_recert ym, yaxis(2)*/
				xline(`shaded_center', lwidth(7) lcolor(gs12))
				xline(`shaded_center2', lwidth(33) lcolor(gs12))
				/*xline(`shaded_center3', lwidth(6) lcolor(gs12))*/
				xline(`MA_extend_begin', lcolor(gray))
        		xline(`MA_extend_end', lcolor(gray))
				xline(`MA_extend_begin2', lcolor(gray))
        		xline(`MA_extend_end2', lcolor(gray))
			/*	xline(`MA_extend_begin3', lcolor(gray))
        		xline(`MA_extend_end3', lcolor(gray))*/
			 	legend(region(lstyle(none)))
          		ylabel(,angle(0) axis(1))
          		ylabel(,angle(0) axis(2))
          		/*ylabel(,angle(0) axis(3))*/
          		xtitle(`""') 
          		title(`""') 
          		graphregion(fcolor(white)) 
          	)
;
#delimit cr 

// save graph 
graph export "${dir_graphs}/churn_MA.png", replace as(png)
graph export "C:/Users/Kelsey/OneDrive - Harvard University/research/SNAP_covid19/output/graphs/churn_MA.png", replace as(png)


*corr churn_rate recerts_due 

check
restore 



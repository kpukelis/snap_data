// california_analyze_apps.do 
// Kelsey Pukelis

// old code 
*use "${dir_root}/data/state_data/california/california.dta", clear
*tab county
*collapse (sum) apps_received apps_received_online, by(ym)

// load data 
use "${dir_root}/data/state_data/state_ym.dta", clear

// limit sample
keep if inlist(state,"california","massachusetts")
dropmiss, force 

// assert level of the data 
duplicates tag state ym, gen(dup)
assert dup == 0
drop dup 

// generate percent online 
gen perc_online = apps_received_web / apps_received * 100

// label vars 
label var apps_received "Applications received"
label var apps_received_web "Applications received - online"
label var perc_online "Percent of applications received online"

/*
#delimit ;
twoway  (connected apps_received ym, yaxis(1)) 
        (connected apps_received_web ym, yaxis(1)) 
        (connected perc_online ym, yaxis(2)
          legend(region(lstyle(none)))
          ylabel(,labsize(vsmall) angle(0) axis(1))
          ylabel(,labsize(vsmall) angle(0) axis(2))
          xtitle(`""') 
          title(`""') 
          graphregion(fcolor(white)) 
        )
;
#delimit cr 
*/

#delimit ;
twoway  (connected perc_online ym if state == "california", yaxis(1))
		(connected perc_online ym if state == "massachusetts", yaxis(1)
          legend(
          	label(1 "CA")
          	label(2 "MA")
          	region(lstyle(none)))
          ylabel(,angle(0) axis(1))
          ytitle(`"Percent of applications received online"')
          xtitle(`""') 
          title(`""') 
          graphregion(fcolor(white)) 
        )
;
#delimit cr 


// save graph 
graph export "${dir_graphs}/online_apps.png", replace as(png)
graph export "C:/Users/Kelsey/OneDrive - Harvard University/research/SNAP_covid19/output/graphs/online_apps.png", replace as(png)
check



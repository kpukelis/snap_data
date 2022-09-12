// california_analyze_apps.do 
// Kelsey Pukelis

use "${dir_root}/data/state_data/california/california.dta", clear

*tab county
collapse (sum) apps_received apps_received_online, by(ym)

gen perc_online = apps_received_online / apps_received * 100

label var apps_received "Applications received"
label var apps_received_online "Applications received - online"
label var perc_online "Percent of applications received online"

#delimit ;
twoway  (connected apps_received ym, yaxis(1)) 
        (connected apps_received_online ym, yaxis(1)) 
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



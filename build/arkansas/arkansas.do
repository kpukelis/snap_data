// arkansas.do 

local year_start 				= 2008
local year_end 					= 2019

********************************************************************

forvalues year = `year_start'(1)`year_end' {
	if inlist(`year',2019) {
		local month_start = 1
		local month_end = 4
	}
	else {
		local month_start = 1
		local month_end	= 12
	}
forvalues month = `month_start'(1)`month_end' {
	
	dis in red `year'
	dis in red `month'

	// filenames 
	if inlist(`year',2008,2009,2010,2011,2012,2013,2014,2015,2016,2019) {
		local suffix ""
	}
	if inlist(`year',2017,2018) {
		local suffix "final"
	}
	if inlist(`year',2008,2009) {
		if `month' == 1 {
			local monthname = "Jan"
		}
		if `month' == 2 {
			local monthname = "Feb"
		}
		if `month' == 3 {
			local monthname = "Mar"
		}
		if `month' == 4 {
			local monthname = "Apr"
		}
		if `month' == 5 {
			local monthname = "May"
		}
		if `month' == 6 {
			local monthname = "Jun"
		}
		if `month' == 7 {
			local monthname = "Jul"
		}
		if `month' == 8 {
			local monthname = "Aug"
		}
		if `month' == 9 {
			local monthname = "Sep"
		}
		if `month' == 10 {
			local monthname = "Oct"
		}
		if `month' == 11 {
			local monthname = "Nov"
		}
		if `month' == 12 {
			local monthname = "Dec"
		}
	}
	if inlist(`year',2010,2011,2012,2013,2014,2015,2016,2017,2018,2019) {
		if `month' == 1 {
			local monthname = "January"
		}
		if `month' == 2 {
			local monthname = "February"
		}
		if `month' == 3 {
			local monthname = "March"
		}
		if `month' == 4 {
			local monthname = "April"
		}
		if `month' == 5 {
			local monthname = "May"
		}
		if `month' == 6 {
			local monthname = "June"
		}
		if `month' == 7 {
			local monthname = "July"
		}
		if `month' == 8 {
			local monthname = "August"
		}
		if `month' == 9 {
			local monthname = "September"
		}
		if `month' == 10 {
			local monthname = "October"
		}
		if `month' == 11 {
			local monthname = "November"
		}
		if `month' == 12 {
			local monthname = "December"
		}
	}

	// import data 
	import excel "${dir_root}/data/state_data/arkansas/csvs/`year'/COOR`monthname'`year'`suffix'.xlsx", allstring case(lower) clear
	dropmiss, force
	foreach v of varlist _all {
		replace `v' = trim(`v')
		replace `v' = strlower(`v')
	}
	gen obsnum = _n 

	// keep only snap data
	sum obsnum if A == "statewide caseload"
	assert r(N) == 2
	local keep_first_obs = r(max)
	sum obsnum if A == "non-expedited applications disposed"
	assert r(N) == 2
	local keep_last_obs = r(min)
	keep if obsnum >= `keep_first_obs' & obsnum < `keep_last_obs'
	dropmiss, force 
	foreach v of varlist _all {
		gen `v'_copy = `v'
		drop `v'
		rename `v'_copy `v'
	}

	// NOTE: dropping these totals: "apcu*","area 1 total","area 2 total","area 3 total","area 4 total","area 5 total","area 6 total"
	#delimit ;
	keep if 
	  inlist(A,"baxter","benton","boone","carroll","crawford","franklin","logan","madison","marion")
	| inlist(A,"newton","polk","scott","searcy","sebastian","washington","clay","craighead","crittenden")
	| inlist(A,"cross","fulton","greene","independence","izard","jackson","lawrence","mississippi","poinsett")
	| inlist(A,"randolph","sharp","cleburne","conway","faulkner","johnson","lonoke","perry","pope")
	| inlist(A,"prairie","stone","van buren","white","woodruff","yell","calhoun","clark","columbia")
	| inlist(A,"dallas","garland","hempstead","hot spring","howard","lafayette","little river","miller","montgomery")
	| inlist(A,"nevada","ouachita","pike","saline","sevier","union","arkansas","ashley","bradley")
	| inlist(A,"chicot","cleveland","desha","drew","grant","jefferson","lee","lincoln","monroe")
	| inlist(A,"phillips","st. francis","pulaski-south","pulaski-north","pulaski-s.w.","pulaski-east","pulaski-jville","state total")
	;
	#delimit cr 
	bysort A (obsnum): assert _N == 2
	bysort A (obsnum): gen obsnum_withincounty = _n 
	sum obsnum_withincounty	
	assert r(max) == 2
	levelsof obsnum_withincounty, local(obsnum_withincounty_nums)
	foreach num of local obsnum_withincounty_nums {
*foreach num in 1 {
*foreach num in 2 {
		dis in red `num'
		preserve
		keep if obsnum_withincounty	== `num'
		dropmiss, force 
		if `num' == 1 {
			qui descr, varlist	
			assert r(k) == 9 | r(k) == 8 | r(k) == 7
			if r(k) == 9 {
				rename (`r(varlist)') (v#), addnumber
				replace v2 = v3 if missing(v2) & !missing(v3)
				replace v3 = "" if !missing(v3)
				replace v4 = v5 if missing(v4) & !missing(v5)
				replace v5 = "" if !missing(v5)
				replace v6 = v7 if missing(v6) & !missing(v7)
				replace v7 = "" if !missing(v7)
				dropmiss, force 
				drop v8 v9
			}
			if r(k) == 8 & (inlist(ym(`year',`month'),ym(2013,6),ym(2013,7),ym(2013,8),ym(2013,9),ym(2013,10),ym(2013,11),ym(2014,2),ym(2014,3),ym(2014,4),ym(2014,5),ym(2014,6),ym(2014,7),ym(2014,8),ym(2014,9),ym(2014,10),ym(2014,11),ym(2014,12),ym(2017,4),ym(2017,5),ym(2017,7),ym(2017,8),ym(2017,9),ym(2017,11)) | inrange(ym(`year',`month'),ym(2015,1),ym(2016,12)) | inlist(ym(`year',`month'),ym(2018,1),ym(2018,6),ym(2018,7),ym(2018,8),ym(2018,9),ym(2018,10),ym(2018,11),ym(2018,12),ym(2019,1),ym(2019,2),ym(2019,3),ym(2019,4))) {
				rename (`r(varlist)') (v#), addnumber
				replace v2 = v3 if missing(v2) & !missing(v3)
				replace v3 = "" if !missing(v3)
				replace v5 = v6 if missing(v5) & !missing(v6)
				replace v6 = "" if !missing(v6)
				dropmiss, force 
				drop v7 v8
			}
			if r(k) == 7 & inlist(ym(`year',`month'),ym(2017,2),ym(2017,3),ym(2017,6),ym(2017,10),ym(2017,12),ym(2018,2),ym(2018,3),ym(2018,4),ym(2018,5)) {
				rename (`r(varlist)') (v#), addnumber
				replace v2 = v3 if missing(v2) & !missing(v3)
				replace v3 = "" if !missing(v3)
				dropmiss, force 
				drop v6 v7
			}
		}
		if `num' == 2 {
			drop obsnum_withincounty obsnum	
		}
		descr, varlist
		if `num' == 1 {
			assert r(k) == 4
			rename (`r(varlist)') (county households individuals issuance)
			foreach v in households	individuals	issuance {
				destring `v', replace
			}
		}
		if `num' == 2 {
			assert r(k) == 14 | r(k) == 13 
			if r(k) == 14 {
				rename (`r(varlist)') (county apps_received apps_approved apps_denied pendingdays_total pendingdays_1to30 pendingdays_31to60 pendingdays_60plus pendingoverdue_total pendingoverdue_AC pendingoverdue_BD pendingoverdue_perc overdue_approved overdue_denied)
				foreach v in apps_received apps_approved apps_denied pendingdays_total pendingdays_1to30 pendingdays_31to60 pendingdays_60plus pendingoverdue_total pendingoverdue_AC pendingoverdue_BD pendingoverdue_perc overdue_approved overdue_denied {
					destring `v', replace
				}
			}
			if r(k) == 13 {
				rename (`r(varlist)') (county apps_received apps_approved apps_denied pendingdays_total pendingdays_1to30 pendingdays_31to60 pendingdays_60plus pendingoverdue_total pendingoverdue_AC pendingoverdue_perc overdue_approved overdue_denied)
				foreach v in apps_received apps_approved apps_denied pendingdays_total pendingdays_1to30 pendingdays_31to60 pendingdays_60plus pendingoverdue_total pendingoverdue_AC pendingoverdue_perc overdue_approved overdue_denied {
					destring `v', replace
				}
			}	
		}
		gen county_copy = county 
		drop county 
		rename county_copy county
	
		// date 
		gen ym = ym(`year',`month')
		format ym %tm
	
		// order and sort 
		order county ym 
		sort county ym 
	
		// save 
		tempfile _`year'_`month'_`num'
		save `_`year'_`month'_`num''
		save "${dir_root}/data/state_data/arkansas/_`year'_`month'_`num'.dta", replace
	
		// restore 
		restore
	}



}
}
*/
******************************************************
// clean 
forvalues num = 1(1)2 {
	forvalues year = `year_start'(1)`year_end' {
		if inlist(`year',2019) {
			local month_start = 1
			local month_end = 4
		}
		else {
			local month_start = 1
			local month_end	= 12
		}
		forvalues month = `month_start'(1)`month_end' {
			dis in red `year'
			dis in red `month'


			use "${dir_root}/data/state_data/arkansas/_`year'_`month'_`num'.dta", clear
			
			// make sure all variables (except county) are numeric
			foreach v of varlist _all {
			    if "`v'" != "county" {
			    	capture confirm string variable `v'
			        if !_rc {
			        	display "`v'"
			        	destring `v', replace ignore("#")
			        }
				}
			}
			replace county = "total" if county == "state total"
			tempfile new_`year'_`month'_`num'
			save `new_`year'_`month'_`num''
		}
	}
}
************************************

// merge 
forvalues num = 1(1)2 {
	forvalues year = `year_start'(1)`year_end' {
		if inlist(`year',2019) {
			local month_start = 1
			local month_end = 4
		}
		else {
			local month_start = 1
			local month_end	= 12
		}
		forvalues month = `month_start'(1)`month_end' {
			dis in red `year'
			dis in red `month'
			if `year' == `year_start' & `month' == `month_start' {
				use `new_`year'_`month'_`num'', clear
*				use "${dir_root}/data/state_data/arkansas/_`year'_`month'_`num'.dta", clear

			}
			else {
				append using `new_`year'_`month'_`num''
*				append using "${dir_root}/data/state_data/arkansas/_`year'_`month'_`num'.dta"
			}
		}
	}
	tempfile data_`num'
	save `data_`num''
}

use `data_1', clear 
merge 1:1 county ym using `data_2'
drop _m

// order and sort 
order county ym 
sort county ym

// save 
save "${dir_root}/data/state_data/arkansas/arkansas.dta", replace 


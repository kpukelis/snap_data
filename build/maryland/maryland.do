
global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/maryland"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"


*local year_start 					= year(1996,1)
local year_start 					= 2008
local year_end 						= 2020

********************************************************************
/*
forvalues year = `year_start'(1)`year_end' {

	dis in red "`year'"
	local yearminus1	= `year' - 1

	// import data 
	import excel "${dir_data}/csvs/`year'-All-Program-Monthly-Statistical-Report.xlsx", allstring case(lower) clear
	dropmiss, force
	foreach v of varlist _all {
		replace `v' = trim(`v')
		replace `v' = strlower(`v')
	}
	gen obsnum = _n 

#delimit ;
drop if !inlist(A,
"allegany",
"anne arundel",
"baltimore co.",
"calvert",
"caroline",
"carroll",
"cecil",
"charles",
"dorchester")
& !inlist(A,
"frederick",
"garrett",
"harford",
"howard",
"kent",
"montgomery",
"prince george's",
"queen anne's",
"st. mary's")
& !inlist(A,
"somerset",
"talbot",
"washington",
"wicomico",
"worcester",
"baltimore city")
;
#delimit cr 

bysort A (obsnum): gen obsnum_withincounty = _n 
sum obsnum_withincounty	
if `year' == 2008 {
	assert r(max) == 28 
}
else if `year' == 2009 {
	assert r(max) == 24
}
else if `year' == 2010 {
	assert r(max) == 42
}
else if inlist(`year',2011,2012,2013,2014,2016) {
	assert r(max) == 44
}
else if inlist(`year',2015) {
	assert r(max) == 34
}
else if inlist(`year',2017,2018,2019,2020) {
	assert r(max) == 42
}
levelsof obsnum_withincounty, local(obsnum_withincounty_nums)
foreach num of local obsnum_withincounty_nums {
	display in red `num'
	preserve
	keep if obsnum_withincounty == `num'
	dropmiss, force
	drop obsnum_withincounty	
	qui describe, varlist 
	if `year' == 2015 {
		assert r(k) == 15 | r(k) == 14 | r(k) == 12
 	}
	else if `year' == 2016 {
		assert r(k) == 15 | r(k) == 14 | r(k) == 6
 	}
 	else if `year' == 2020 {
 		assert r(k) == 6
 	}
 	else {
		assert r(k) == 15 | r(k) == 14
	}
	if r(k) == 15 {
		rename (`r(varlist)') (county _`yearminus1'_07 _`yearminus1'_08 _`yearminus1'_09 _`yearminus1'_10 _`yearminus1'_11 _`yearminus1'_12 _`year'_01 _`year'_02 _`year'_03 _`year'_04 _`year'_05 _`year'_06 average obsnum)
		drop average
	}
	if r(k) == 14 {
		rename (`r(varlist)') (county _`yearminus1'_07 _`yearminus1'_08 _`yearminus1'_09 _`yearminus1'_10 _`yearminus1'_11 _`yearminus1'_12 _`year'_01 _`year'_02 _`year'_03 _`year'_04 _`year'_05 _`year'_06 obsnum)
	}
	if r(k) == 12 {
		rename (`r(varlist)') (county _`yearminus1'_07 _`yearminus1'_08 _`yearminus1'_09 _`yearminus1'_10 _`yearminus1'_11 _`yearminus1'_12 _`year'_01 _`year'_02 _`year'_03 average obsnum)
		drop average
	}
	if r(k) == 6 {
		rename (`r(varlist)') (county _`yearminus1'_07 _`yearminus1'_08 _`yearminus1'_09 average obsnum)
		drop average		
	}
	if `year' == 2013 & `num' == 9 {
		replace _2013_02 = "521666.28" if _2013_02 == "521.666.28" & county == "montgomery"
	}
	foreach v of varlist _????_?? {
		destring `v', replace
	}
	// make string type shorter
	gen county_copy = county
	drop county 
	rename county_copy county 
	order county 
	// reshape 
	reshape	long _, i(county) j(yyyy_mm) string	

	// date 
	gen year = substr(yyyy_mm,1,4)
	destring year, replace	
	gen month = substr(yyyy_mm,6,7)
	destring month, replace 
	gen ym = ym(year,month)
	format ym %tm 
	drop year month yyyy_mm	
	drop obsnum	
	if inlist(`year',2010) {
		if `num' == 1 {
			rename _ tanf_apps_received			
		}
		if `num' == 2 {
			rename _ tanf_apps_approved				
		}
		if `num' == 3 {
			rename _ tanf_apps_notapproved		
		}
		if `num' == 4 {
			rename _ tanf_cases_closed				
		}
		if `num' == 5 {
			rename _ tanf_cases			
		}
		if `num' == 6 {
			rename _ tanf_recipients				
		}
		if `num' == 7 {
			rename _ tanf_adults				
		}
		if `num' == 8 {
			rename _ tanf_children				
		}
		if `num' == 9 {
			rename _ tanf_netexpenditure			
		}
		if `num' == 10 {
			rename _ snap_apps_received				
		}
		if `num' == 11 {
			rename _ snap_apps_approved				
		}
		if `num' == 12 {
			rename _ snap_apps_notapproved				
		}
		if `num' == 13 {
			rename _ snap_households			
		}
		if `num' == 14 {
			rename _ snap_recipients			
		}
		if `num' == 15 {
			rename _ snap_netexpenditure			
		}
		if `num' == 16 {
			rename _ tdap_apps_received				
		}
		if `num' == 17 {
			rename _ tdap_apps_approved			
		}
		if `num' == 18 {
			rename _ tdap_apps_notapproved				
		}
		if `num' == 19 {
			rename _ tdap_cases_closed				
		}
		if `num' == 20 {
			rename _ tdap_recipients				
		}
		if `num' == 21 {
			rename _ tdap_recipients_shortterm	
		}
		if `num' == 22 {
			rename _ tdap_recipients_longterm	
		}
		if `num' == 23 {
			rename _ tdap_netexpenditure
		}
		if `num' == 24 {
			rename _ ma_commcare_apps_received	
		}
		if `num' == 25 {
			rename _ ma_commcare_apps_approved	
		}
		if `num' == 26 {
			rename _ ma_longterm_apps_received	
		}
		if `num' == 27 {
			rename _ ma_longterm_apps_approved	
		}
		if `num' == 28 {
			rename _ ssi_apps_received
		}
		if `num' == 29 {
			rename _ ssi_apps_approved
		}
		if `num' == 30 {
			rename _ ma_commcare_cases	
		}
		if `num' == 31 {
			rename _ ma_longterm_cases	
		}
		if `num' == 32 {
			rename _ ssi
		}
		if `num' == 33 {
			rename _ paadults_apps_received
		}
		if `num' == 34 {
			rename _ paadults_apps_approved
		}
		if `num' == 35 {
			rename _ paadults_apps_notapproved	
		}
		if `num' == 36 {
			rename _ paadults_cases_closed
		} 
		if `num' == 37 {
			rename _ paadults_recipients
		}
		if `num' == 38 {
			rename _ paadults_netexpenditure
		}
		if `num' == 39 {
			rename _ emergassist_grants
		}
		if `num' == 40 {
			rename _ emergassist_netexpenditure
		}
		if `num' == 41 {
			rename _ burial_grants
		}
		if `num' == 42 {
			rename _ burial_netexpenditure
		}
	}
	if inlist(`year',2011) {
		if `num' == 1 {
			rename _ tanf_apps_received			
		}
		if `num' == 2 {
			rename _ tanf_apps_approved				
		}
		if `num' == 3 {
			rename _ tanf_apps_notapproved		
		}
		if `num' == 4 {
			rename _ tanf_cases_closed				
		}
		if `num' == 5 {
			rename _ tanf_cases			
		}
		if `num' == 6 {
			rename _ tanf_recipients				
		}
		if `num' == 7 {
			rename _ tanf_adults				
		}
		if `num' == 8 {
			rename _ tanf_children				
		}
		if `num' == 9 {
			rename _ tanf_netexpenditure			
		}
		if `num' == 10 {
			rename _ snap_apps_received				
		}
		if `num' == 11 {
			rename _ snap_apps_approved				
		}
		if `num' == 12 {
			rename _ snap_apps_notapproved				
		}
		if `num' == 13 {
			rename _ snap_households			
		}
		if `num' == 14 {
			rename _ snap_recipients			
		}
		if `num' == 15 {
			rename _ snap_netexpenditure			
		}
		if `num' == 16 {
			rename _ tdap_apps_received				
		}
		if `num' == 17 {
			rename _ tdap_apps_approved			
		}
		if `num' == 18 {
			rename _ tdap_apps_notapproved				
		}
		if `num' == 19 {
			rename _ tdap_cases_closed				
		}
		if `num' == 20 {
			rename _ tdap_recipients				
		}
		if `num' == 21 {
			rename _ tdap_recipients_shortterm	
		}
		if `num' == 22 {
			rename _ tdap_recipients_longterm	
		}
		if `num' == 23 {
			rename _ tdap_netexpenditure
		}
		if `num' == 24 {
			rename _ ma_commcare_apps_received	
		}
		if `num' == 25 {
			rename _ ma_commcare_apps_approved	
		}
		if `num' == 26 {
			rename _ ma_longterm_apps_received	
		}
		if `num' == 27 {
			rename _ ma_longterm_apps_approved	
		}
		if `num' == 28 {
			rename _ ssi_apps_received
		}
		if `num' == 29 {
			rename _ ssi_apps_approved
		}
		if `num' == 30 {
			rename _ ma_mchp_apps_received	
		}
		if `num' == 31 {
			rename _ ma_commcare_cases	
		}
		if `num' == 32 {
			rename _ ma_longterm_cases	
		}
		if `num' == 33 {
			rename _ ssi
		}
		if `num' == 34 {
			rename _ ma_mchp_assistanceunits
		}
		if `num' == 35 {
			rename _ paadults_apps_received		
		}
		if `num' == 36 {
			rename _ paadults_apps_approved	
		} 
		if `num' == 37 {
			rename _ paadults_apps_notapproved	
		}
		if `num' == 38 {
			rename _ paadults_cases_closed
		}
		if `num' == 39 {
			rename _ paadults_recipients	
		}
		if `num' == 40 {
			rename _ paadults_netexpenditure	
		}
		if `num' == 41 {
			rename _ emergassist_grants	
		}
		if `num' == 42 {
			rename _ emergassist_netexpenditure	
		}
		if `num' == 43 {
			rename _ burial_grants		
		}
		if `num' == 44 {
			rename _ burial_netexpenditure		
		}
	}
	if inlist(`year',2012,2013) {
		if `num' == 1 {
			rename _ tanf_apps_received			
		}
		if `num' == 2 {
			rename _ tanf_apps_approved				
		}
		if `num' == 3 {
			rename _ tanf_apps_notapproved		
		}
		if `num' == 4 {
			rename _ tanf_cases_closed				
		}
		if `num' == 5 {
			rename _ tanf_cases			
		}
		if `num' == 6 {
			rename _ tanf_recipients				
		}
		if `num' == 7 {
			rename _ tanf_adults				
		}
		if `num' == 8 {
			rename _ tanf_children				
		}
		if `num' == 9 {
			rename _ tanf_netexpenditure			
		}
		if `num' == 10 {
			rename _ snap_apps_received				
		}
		if `num' == 11 {
			rename _ snap_apps_approved				
		}
		if `num' == 12 {
			rename _ snap_apps_notapproved				
		}
		if `num' == 13 {
			rename _ snap_households			
		}
		if `num' == 14 {
			rename _ snap_recipients			
		}
		if `num' == 15 {
			rename _ snap_netexpenditure			
		}
		if `num' == 16 {
			rename _ tdap_apps_received				
		}
		if `num' == 17 {
			rename _ tdap_apps_approved			
		}
		if `num' == 18 {
			rename _ tdap_apps_notapproved				
		}
		if `num' == 19 {
			rename _ tdap_cases_closed				
		}
		if `num' == 20 {
			rename _ tdap_recipients				
		}
		if `num' == 21 {
			rename _ tdap_recipients_shortterm	
		}
		if `num' == 22 {
			rename _ tdap_recipients_longterm	
		}
		if `num' == 23 {
			rename _ tdap_netexpenditure
		}
		if `num' == 24 {
			rename _ ma_commcare_apps_received	
		}
		if `num' == 25 {
			rename _ ma_commcare_apps_approved	
		}
		if `num' == 26 {
			rename _ ma_longterm_apps_received	
		}
		if `num' == 27 {
			rename _ ma_longterm_apps_approved	
		}
		if `num' == 28 {
			rename _ ssi_apps_received
		}
		if `num' == 29 {
			rename _ ssi_apps_approved
		}
		if `num' == 30 {
			rename _ ma_mchp_apps_received	
		}
		if `num' == 31 {
			rename _ ma_commcare_cases		
		}
		if `num' == 32 {
			rename _ ma_longterm_cases		
		}
		if `num' == 33 {
			rename _ ssi
		}
		if `num' == 34 {
			rename _ ma_mchp_assistanceunits	
		}
		if `num' == 35 {
			rename _ paadults_apps_received		
		}
		if `num' == 36 {
			rename _ paadults_apps_approved	
		} 
		if `num' == 37 {
			rename _ paadults_apps_notapproved
		}
		if `num' == 38 {
			rename _ paadults_cases_closed	
		}
		if `num' == 39 {
			rename _ paadults_recipients	
		}
		if `num' == 40 {
			rename _ paadults_netexpenditure	
		}
		if `num' == 41 {
			rename _ emergassist_grants	
		}
		if `num' == 42 {
			rename _ emergassist_netexpenditure	
		}
		if `num' == 43 {
			rename _ burial_grants	
		}
		if `num' == 44 {
			rename _ burial_netexpenditure	
		}
	}
	if inlist(`year',2014,2015) {
		if `num' == 1 {
			rename _ tanf_apps_received			
		}
		if `num' == 2 {
			rename _ tanf_apps_approved				
		}
		if `num' == 3 {
			rename _ tanf_apps_notapproved		
		}
		if `num' == 4 {
			rename _ tanf_cases_closed				
		}
		if `num' == 5 {
			rename _ tanf_cases			
		}
		if `num' == 6 {
			rename _ tanf_recipients				
		}
		if `num' == 7 {
			rename _ tanf_adults				
		}
		if `num' == 8 {
			rename _ tanf_children				
		}
		if `num' == 9 {
			rename _ tanf_netexpenditure			
		}
		if `num' == 10 {
			rename _ snap_apps_received				
		}
		if `num' == 11 {
			rename _ snap_apps_approved				
		}
		if `num' == 12 {
			rename _ snap_apps_notapproved				
		}
		if `num' == 13 {
			rename _ snap_households /*last column shows up on later page*/
		}
		if `num' == 14 {
			rename _ snap_recipients /*last column shows up on later page*/
		}
		if `num' == 15 {
			rename _ snap_netexpenditure /*last column shows up on later page*/
		}
		if `num' == 16 {
			rename _ tdap_apps_received				
		}
		if `num' == 17 {
			rename _ tdap_apps_approved			
		}
		if `num' == 18 {
			rename _ tdap_apps_notapproved				
		}
		if `num' == 19 {
			rename _ tdap_cases_closed				
		}
		if `num' == 20 {
			rename _ tdap_recipients				
		}
		if `num' == 21 {
			rename _ tdap_recipients_shortterm	
		}
		if `num' == 22 {
			rename _ tdap_recipients_longterm	
		}
		if `num' == 23 {
			rename _ tdap_netexpenditure
		}
		if `num' == 24 {
			rename _ ma_commcare_apps_received	
		}
		if `num' == 25 {
			rename _ ma_commcare_apps_approved	
		}
		if `num' == 26 {
			rename _ ma_longterm_apps_received	
		}
		if `num' == 27 {
			rename _ ma_longterm_apps_approved	
		}
		if `num' == 28 {
			rename _ ssi_apps_received
		}
		if `num' == 29 {
			rename _ ssi_apps_approved
		}
		if `num' == 30 {
			rename _ ma_mchp_apps_received	
		}
		if `num' == 31 {
			rename _ ma_commcare_cases		
		}
		if `num' == 32 {
			rename _ ma_longterm_cases		
		}
		if `num' == 33 {
			rename _ ssi
		}
		if `num' == 34 {
			rename _ ma_mchp_assistanceunits	
		}
		if `num' == 35 {
			rename _ paadults_apps_received		
		}
		if `num' == 36 {
			rename _ paadults_apps_approved	
		} 
		if `num' == 37 {
			rename _ paadults_apps_notapproved
		}
		if `num' == 38 {
			rename _ paadults_cases_closed	
		}
		if `num' == 39 {
			rename _ paadults_recipients	
		}
		if `num' == 40 {
			rename _ paadults_netexpenditure	
		}
		if `num' == 41 {
			rename _ emergassist_grants	
		}
		if `num' == 42 {
			rename _ emergassist_netexpenditure	
		}
		if `num' == 43 {
			rename _ burial_grants	
		}
		if `num' == 44 {
			rename _ burial_netexpenditure	
		}
	}
	if inlist(`year',2016) {
		if `num' == 1 {
			rename _ tanf_apps_received			
		}
		if `num' == 2 {
			rename _ tanf_apps_approved				
		}
		if `num' == 3 {
			rename _ tanf_apps_notapproved		
		}
		if `num' == 4 {
			rename _ tanf_cases_closed				
		}
		if `num' == 5 {
			rename _ tanf_cases			
		}
		if `num' == 6 {
			rename _ tanf_recipients				
		}
		if `num' == 7 {
			rename _ tanf_adults				
		}
		if `num' == 8 {
			rename _ tanf_children				
		}
		if `num' == 9 {
			rename _ tanf_netexpenditure			
		}
		if `num' == 10 {
			rename _ snap_apps_received				
		}
		if `num' == 11 {
			rename _ snap_apps_approved				
		}
		if `num' == 12 {
			rename _ snap_apps_notapproved				
		}
		if `num' == 13 {
			rename _ snap_households /*last column shows up on later page*/
		}
		if `num' == 14 {
			rename _ snap_recipients /*last column shows up on later page*/
		}
		if `num' == 15 {
			rename _ snap_netexpenditure /*last column shows up on later page*/
		}
		if `num' == 16 {
			rename _ tdap_apps_received				
		}
		if `num' == 17 {
			rename _ tdap_apps_approved			
		}
		if `num' == 18 {
			rename _ tdap_apps_notapproved				
		}
		if `num' == 19 {
			rename _ tdap_cases_closed				
		}
		if `num' == 20 {
			rename _ tdap_recipients				
		}
		if `num' == 21 {
			rename _ tdap_recipients_shortterm	
		}
		if `num' == 22 {
			rename _ tdap_recipients_longterm	
		}
		if `num' == 23 {
			rename _ tdap_netexpenditure
		}
		if `num' == 24 {
			rename _ paadults_apps_received	
		}
		if `num' == 25 {
			rename _ paadults_apps_approved	
		}
		if `num' == 26 {
			rename _ paadults_apps_notapproved	
		}
		if `num' == 27 {
			rename _ paadults_cases_closed	
		}
		if `num' == 28 {
			rename _ paadults_recipients
		}
		if `num' == 29 {
			rename _ paadults_netexpenditure
		}
		if `num' == 30 {
			rename _ emergassist_grants	
		}
		if `num' == 31 {
			rename _ emergassist_netexpenditure		
		}
		if `num' == 32 {
			rename _ burial_grants		
		}
		if `num' == 33 {
			rename _ burial_netexpenditure
		}
		if `num' == 34 {
			rename _ ma_commcare_apps_received	
		}
		if `num' == 35 {
			rename _ ma_commcare_apps_approved		
		}
		if `num' == 36 {
			rename _ ma_longterm_apps_received	
		} 
		if `num' == 37 {
			rename _ ma_longterm_apps_approved
		}
		if `num' == 38 {
			rename _ ssi_apps_received	
		}
		if `num' == 39 {
			rename _ ssi_apps_approved
		}
		if `num' == 40 {
			rename _ ma_mchp_apps_received	
		}
		if `num' == 41 {
			rename _ ma_commcare_cases	
		}
		if `num' == 42 {
			rename _ ma_longterm_cases	
		}
		if `num' == 43 {
			rename _ ssi	
		}
		if `num' == 44 {
			rename _ ma_mchp_assistanceunits	
		}
	}
	if inlist(`year',2017,2018,2019,2020) {
		if `num' == 1 {
			rename _ tanf_apps_received			
		}
		if `num' == 2 {
			rename _ tanf_apps_approved				
		}
		if `num' == 3 {
			rename _ tanf_apps_notapproved		
		}
		if `num' == 4 {
			rename _ tanf_cases_closed				
		}
		if `num' == 5 {
			rename _ tanf_cases			
		}
		if `num' == 6 {
			rename _ tanf_recipients				
		}
		if `num' == 7 {
			rename _ tanf_adults				
		}
		if `num' == 8 {
			rename _ tanf_children				
		}
		if `num' == 9 {
			rename _ tanf_netexpenditure			
		}
		if `num' == 10 {
			rename _ snap_apps_received				
		}
		if `num' == 11 {
			rename _ snap_apps_approved				
		}
		if `num' == 12 {
			rename _ snap_apps_notapproved				
		}
		if `num' == 13 {
			rename _ snap_households /*last column shows up on later page*/
		}
		if `num' == 14 {
			rename _ snap_recipients /*last column shows up on later page*/
		}
		if `num' == 15 {
			rename _ snap_netexpenditure /*last column shows up on later page*/
		}
		if `num' == 16 {
			rename _ tdap_apps_received				
		}
		if `num' == 17 {
			rename _ tdap_apps_approved			
		}
		if `num' == 18 {
			rename _ tdap_apps_notapproved				
		}
		if `num' == 19 {
			rename _ tdap_cases_closed				
		}
		if `num' == 20 {
			rename _ tdap_recipients				
		}
		if `num' == 21 {
			rename _ tdap_recipients_shortterm	
		}
		if `num' == 22 {
			rename _ tdap_recipients_longterm	
		}
		if `num' == 23 {
			rename _ tdap_netexpenditure
		}
		if `num' == 24 {
			rename _ paadults_apps_received	
		}
		if `num' == 25 {
			rename _ paadults_apps_approved	
		}
		if `num' == 26 {
			rename _ paadults_apps_notapproved	
		}
		if `num' == 27 {
			rename _ paadults_cases_closed	
		}
		if `num' == 28 {
			rename _ paadults_recipients
		}
		if `num' == 29 {
			rename _ paadults_netexpenditure
		}
		if `num' == 30 {
			rename _ emergassist_grants	
		}
		if `num' == 31 {
			rename _ emergassist_netexpenditure		
		}
		if `num' == 32 {
			rename _ burial_grants		
		}
		if `num' == 33 {
			rename _ burial_netexpenditure
		}
		if `num' == 34 {
			rename _ ma_commcare_apps_received	
		}
		if `num' == 35 {
			rename _ ma_commcare_apps_approved		
		}
		if `num' == 36 {
			rename _ ma_longterm_apps_received	
		} 
		if `num' == 37 {
			rename _ ma_longterm_apps_approved
		}
		if `num' == 38 {
			rename _ ssi_apps_received	
		}
		if `num' == 39 {
			rename _ ssi_apps_approved
		}
		if `num' == 40 {
			rename _ ma_commcare_cases	
		}
		if `num' == 41 {
			rename _ ma_longterm_cases	
		}
		if `num' == 42 {
			rename _ ssi	
		}
	}


	if `num' == 1 & inlist(`year',2008,2009) {
		rename _ tanf_apps_received 
	}
	else if `num' == 2 & inlist(`year',2008,2009) {
		rename _ tanf_apps_approved
	}
	else if `num' == 3 & inlist(`year',2008,2009) {
		rename _ tanf_cases_closed
	}
	else if `num' == 4 & inlist(`year',2008,2009) {
		rename _ tanf_cases
	}
	else if `num' == 5 & inlist(`year',2008,2009) {
		rename _ tanf_recipients
	}
	else if `num' == 6 & inlist(`year',2008,2009) {
		rename _ tanf_adults
	}
	else if `num' == 7 & inlist(`year',2008,2009) {
		rename _ tanf_children
	}
	else if `num' == 8 & inlist(`year',2008) {
		rename _ snap_npa_apps_received
	}
	else if `num' == 9 & inlist(`year',2008) {
		rename _ snap_npa_apps_approved
	}
	else if `num' == 10 & inlist(`year',2008) {
		rename _ snap_pa_apps_received
	}
	else if `num' == 11 & inlist(`year',2008) {
		rename _ snap_pa_apps_approved
	}
	else if `num' == 12 & inlist(`year',2008) {
		rename _ snap_households
	}
	else if `num' == 13 & inlist(`year',2008) {
		rename _ snap_recipients
	}
	else if `num' == 14 & inlist(`year',2008) {
		rename _ snap_npa_recipients
	}
	else if `num' == 15 & inlist(`year',2008) {
		rename _ snap_pa_recipients
	}
	else if `num' == 16 & inlist(`year',2008) {
		rename _ tdap_apps_received
	}
	else if `num' == 17 & inlist(`year',2008) {
		rename _ tdap_apps_approved
	}
	else if `num' == 18 & inlist(`year',2008) {
		rename _ tdap_cases_closed
	}
	else if `num' == 19 & inlist(`year',2008) {
		rename _ tdap_recipients
	}
	else if `num' == 20 & inlist(`year',2008) {
		rename _ tdap_recipients_shortterm
	}
	else if `num' == 21 & inlist(`year',2008) {
		rename _ tdap_recipients_longterm
	}
	else if `num' == 22 & inlist(`year',2008) {
		rename _ ma_commcare_apps_received
	}
	else if `num' == 23 & inlist(`year',2008) {
		rename _ ma_commcare_apps_approved
	}
	else if `num' == 24 & inlist(`year',2008) {
		rename _ ma_longterm_apps_received
	}
	else if `num' == 25 & inlist(`year',2008) {
		rename _ ma_longterm_apps_approved
	}
	else if `num' == 26 & inlist(`year',2008) {
		rename _ ma_commcare_cases
	}
	else if `num' == 27 & inlist(`year',2008) {
		rename _ ma_longterm_cases
	}
	else if `num' == 28 & inlist(`year',2008) {
		rename _ ssi
	}
	else if `num' == 8 & inlist(`year',2009) {
		rename _ snap_apps_received
	}
	else if `num' == 9 & inlist(`year',2009) {
		rename _ snap_apps_approved
	}
	else if `num' == 10 & inlist(`year',2009) {
		rename _ snap_households
	}
	else if `num' == 11 & inlist(`year',2009) {
		rename _ snap_recipients
	}
	else if `num' == 12 & inlist(`year',2009) {
		rename _ tdap_apps_received
	}
	else if `num' == 13 & inlist(`year',2009) {
		rename _ tdap_apps_approved
	}
	else if `num' == 14 & inlist(`year',2009) {
		rename _ tdap_cases_closed
	}
	else if `num' == 15 & inlist(`year',2009) {
		rename _ tdap_recipients
	}
	else if `num' == 16 & inlist(`year',2009) {
		rename _ tdap_recipients_shortterm
	}
	else if `num' == 17 & inlist(`year',2009) {
		rename _ tdap_recipients_longterm
	}
	else if `num' == 18 & inlist(`year',2009) {
		rename _ ma_commcare_apps_received
	}
	else if `num' == 19 & inlist(`year',2009) {
		rename _ ma_commcare_apps_approved
	}
	else if `num' == 20 & inlist(`year',2009) {
		rename _ ma_longterm_apps_received
	}
	else if `num' == 21 & inlist(`year',2009) {
		rename _ ma_longterm_apps_approved
	}
	else if `num' == 22 & inlist(`year',2009) {
		rename _ ma_commcare_cases
	}
	else if `num' == 23 & inlist(`year',2009) {
		rename _ ma_longterm_cases
	}
	else if `num' == 24 & inlist(`year',2009) {
		rename _ ssi
	}
	// order and sort 
	order county ym 
	sort county ym 

	// save 
	tempfile _`year'_`num'
	save `_`year'_`num''

	restore
}
	foreach num of local obsnum_withincounty_nums {
		dis in red "`num'"
		if `num' == 1 {
			use `_`year'_`num'', clear
		}
		else {
			merge 1:1 county ym using `_`year'_`num''
			if (`year' == 2015 & inlist(`num',30,34)) | (`year' == 2016 & inlist(`num',40,44)) {
				assert inlist(_m,1,3)
			}
			else {
				assert _m == 3
			}
			drop _m
		}
	}
	*tempfile _`year'
	*save `_`year''
	save "${dir_data}/maryland_fy`year'.dta", replace
}
*/

**************************************************
forvalues year = `year_start'(1)`year_end' {
	if `year' == `year_start' {
		*use `_`year'', clear
		use "${dir_data}/maryland_fy`year'.dta", clear 
	}
	else {
		*append using `_`year''
		append using "${dir_data}/maryland_fy`year'.dta"
	}
}

// order and sort 
order county ym 
sort county ym 

// save 
save "${dir_data}/maryland.dta", replace 
check


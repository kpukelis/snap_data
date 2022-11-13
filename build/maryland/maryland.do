// maryland.do 
// Kelsey Pukelis

local year_start 					= 2008
local year_end 						= 2023

********************************************************************

// county level data 2008-2020
forvalues year = `year_start'(1)`year_end' {

	dis in red "`year'"
	local yearminus1	= `year' - 1

	// import data 
	import excel "${dir_root}/data/state_data/maryland/csvs/`year'-All-Program-Monthly-Statistical-Report.xlsx", allstring case(lower) clear
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
"saint mary's"
"somerset",
"talbot",
"washington",
"wicomico",
"worcester",
"baltimore city")
& !inlist(A,
"baltimore co")
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
else if inlist(`year',2017,2018,2019,2020,2021,2022) {
	assert r(max) == 42
}
else if inlist(`year',2023) {
	*display in red `r(max)'
	assert r(max) == 48
}
else {
	STOP
}
levelsof obsnum_withincounty, local(obsnum_withincounty_nums)
**local num = 29
foreach num of local obsnum_withincounty_nums {
	display in red `num'
	preserve
	keep if obsnum_withincounty == `num'
	dropmiss, force
	drop obsnum_withincounty	
	describe, varlist 
	if `year' == 2015 {
		assert r(k) == 15 | r(k) == 14 | r(k) == 12
 	}
	else if `year' == 2016 {
		assert r(k) == 15 | r(k) == 14 | r(k) == 6
 	}
	else if `year' == 2023 {
		*display in red `r(k)' 
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
	if r(k) == 13 {
		rename (`r(varlist)') (county _`yearminus1'_07 _`yearminus1'_08 _`yearminus1'_09 _`yearminus1'_10 _`yearminus1'_11 _`yearminus1'_12 _`year'_01 _`year'_02 _`year'_03 _`year'_04 average obsnum)
	}
	if r(k) == 12 {
		rename (`r(varlist)') (county _`yearminus1'_07 _`yearminus1'_08 _`yearminus1'_09 _`yearminus1'_10 _`yearminus1'_11 _`yearminus1'_12 _`year'_01 _`year'_02 _`year'_03 average obsnum)
		drop average
	}
	if r(k) == 6 & `year' == 2016 {
		rename (`r(varlist)') (county _`yearminus1'_07 _`yearminus1'_08 _`yearminus1'_09 average obsnum)
		drop average		
	}
	if r(k) == 7 & `year' == 2021 {
		rename (`r(varlist)') (county _`yearminus1'_07 _`yearminus1'_08 _`yearminus1'_09 _`yearminus1'_10 _`yearminus1'_11  obsnum)
		capture drop average		
	}
	if `year' == 2013 & `num' == 9 {
		replace _2013_02 = "521666.28" if _2013_02 == "521.666.28" & county == "montgomery"
	}
	if r(k) == 6 & `year' == 2023 {
		rename (`r(varlist)') (county _`yearminus1'_07 _`yearminus1'_08 _`yearminus1'_09 average obsnum)
	}
	foreach v of varlist _????_?? {
		replace `v' = ustrregexra(`v',"tbd","")
		destring `v', replace
		confirm numeric variable `v'
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
	if inlist(`year',2017,2018,2019,2020,2021,2022,2023) {
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
	save "${dir_root}/data/state_data/maryland/maryland_fy`year'.dta", replace

}
*/

**************************************************
forvalues year = `year_start'(1)`year_end' {
	if `year' == `year_start' {
		use "${dir_root}/data/state_data/maryland/maryland_fy`year'.dta", clear 
	}
	else {
		append using "${dir_root}/data/state_data/maryland/maryland_fy`year'.dta"
	}
}

// standardize county 
replace county = "st. mary's" if county == "saint mary's"
replace county = "baltimore co" if county == "baltimore co."

// order and sort 
order county ym 
sort county ym 

// save 
tempfile county_level
save `county_level'

********************************************************************
// STATE LEVEL DATA 2008-2020

// collapse to get totals
use `county_level', clear
keep county ym snap_households snap_recipients /*snap_npa_recipients snap_pa_recipients*/ snap_netexpenditure snap_apps_received snap_apps_approved snap_apps_notapproved
rename snap_households households
rename snap_recipients individuals
*rename snap_npa_recipients individuals_npa
*rename snap_pa_recipients individuals_pa
rename snap_netexpenditure issuance
*rename snap_apps_received apps_received
*rename snap_apps_approved apps_approved
*rename snap_apps_notapproved apps_denied
collapse (sum) households individuals /*individuals_npa individuals_pa*/ issuance snap_apps_received snap_apps_approved snap_apps_notapproved, by(ym)
tempfile late_state
save `late_state'

// STATE LEVEL DATA 1996-2005

// import data 
import excel "${dir_root}/data/state_data/maryland/csvs/Statistical Reports - Archive - cases.xlsx", allstring case(lower) clear

// initial cleanup
dropmiss, force 
dropmiss, obs force 
describe, varlist 
rename (`r(varlist)') (v#), addnumber

// lowercase everything 
foreach v of varlist _all {
	replace `v' = strlower(`v')
	replace `v' = ustrregexra(`v',"\/","")
	replace `v' = ustrregexra(`v',"\\","")
}

// mark original order of observations
gen obsnum = _n

// drop title rows 
drop if v1 == "program caseloads"

// rename vars 
describe, varlist
assert `r(k)' == 14
rename v1 varname 
rename v2 m1 
rename v3 m2
rename v4 m3 
rename v5 m4 
rename v6 m5 
rename v7 m6 
rename v8 m7 
rename v9 m8 
rename v10 m9 
rename v11 m10 
rename v12 m11 
rename v13 m12

// clean up varname a bit 
replace varname = ustrregexra(varname," - ","_")
replace varname = ustrregexra(varname," ","")

// mark year 
bysort varname (obsnum): gen year = _n + 1995

// assert this was done properly
levelsof varname, local(varnames)
foreach varname of local varnames {
	qui sum year if varname == "`varname'"
	assert `r(min)' == 1996
	assert `r(max)' == 2005
}
drop obsnum 

// reshape
reshape long m, i(varname year) j(month)
rename m value 

// destring value 
destring value, replace 
confirm numeric variable value

// ym 
gen ym = ym(year,month)
format ym %tm 
drop year month 

// reshape again
rename value _
reshape wide _, i(ym) j(varname) string

// rename snap variables 
**KP: not sure what the difference between cert and part is 
rename _fsnpa_hholdcert households_npa_cert
rename _fsnpa_hholdpart households_npa
rename _fsnpa_indvdpart individuals_npa
rename _fspa_hholdcert 	households_pa_cert
rename _fspa_hholdpart 	households_pa
rename _fspa_indvdpart 	individuals_pa
rename _fstotal_issued	issuance
**KP: need to rename non SNAP variables to match county-level data 

// generate total households and individuals
gen households_cert = households_npa_cert + households_pa_cert
gen households = households_npa + households_pa
gen individuals = individuals_npa + individuals_pa

// order and sort 
order ym households individuals issuance households_npa households_pa households_npa_cert households_pa_cert individuals_npa individuals_pa
sort ym

// save this early data 
tempfile early_state
save `early_state'

***************************************
// append early and late data 
use `early_state', clear 
append using `late_state'

// county 
gen county = "total"

// order and sort 
order county ym households individuals issuance households_npa households_pa households_npa_cert households_pa_cert individuals_npa individuals_pa
sort county ym

// save 
tempfile state_level
save `state_level'

***********************************************************

// combine data
use `county_level', clear 
append using `state_level'

// fix for maryland data only 
capture rename snap_npa_recipients individuals_npa
capture rename snap_pa_recipients individuals_pa
capture confirm variable individuals_npa
if !_rc {
	capture gen individuals = individuals_npa + individuals_pa
}
foreach type in received approved notapproved {
	capture confirm variable snap_npa_apps_`type' 
	if !_rc {
		replace snap_apps_`type' = snap_npa_apps_`type' + snap_pa_apps_`type' if missing(snap_apps_`type') & !missing(snap_npa_apps_`type') & !missing(snap_pa_apps_`type')
		assert !missing(snap_apps_`type') if !missing(snap_npa_apps_`type') & !missing(snap_pa_apps_`type')
	}
	capture drop snap_npa_apps_`type'
	capture drop snap_pa_apps_`type'
}
capture rename snap_apps_received 		apps_received
capture rename snap_apps_approved 		apps_approved
capture rename snap_apps_notapproved 	apps_denied

// combine vars that were not already combined
replace households = snap_households if missing(households) & !missing(snap_households)
replace individuals = snap_recipients if missing(individuals) & !missing(snap_recipients)
foreach v in individuals households {
	assert !missing(`v') if !missing(`v'_npa) & !missing(`v'_pa)	
}

// order and sort 
order county ym households individuals issuance households_npa households_pa households_npa_cert households_pa_cert individuals_npa individuals_pa
sort county ym

// remove all missing observations
foreach var in households individuals issuance households_npa households_pa households_npa_cert households_pa_cert individuals_npa individuals_pa {
	replace `var' = . if `var' == 0	
}
dropmiss households individuals issuance households_npa households_pa households_npa_cert households_pa_cert individuals_npa individuals_pa, force obs 

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// save 
save "${dir_root}/data/state_data/maryland/maryland.dta", replace 



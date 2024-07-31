// north carolina.do
// imports cases and clients from excel sheets
**KP: `mdy' != mdy(12,24,2018) /*they posted the micro data...also here, with a key: 2021-08-23 and 2021-11-08*/ 

local datasets 					cases apps abawds workcases workapps
local file_cases 				"FNS-Cases-and-Participants-Website-Data-thru-05-2024"
local file_apps 				"FNS-Applications-By-County-By-Month-thru-05-2024"
local file_abawds 				"FNS-ABAWDS-By-Month-By-County-thru-05-2024_hb"
local file_workcases			"Work-First-Cases-Participants-Counts-by-County-thru-09-2022"
local file_workapps 			"Work-First-Applications-By-Month-thru-09-2022"


local ym_start_cases			= ym(2006,7)
local ym_end_cases				= ym(2024,5)
local ym_start_apps				= ym(2007,4)
local ym_end_apps				= ym(2024,5)
local ym_start_abawds			= ym(2017,4)
local ym_end_abawds				= ym(2024,5)
local ym_start_workcases		= ym(2007,4)
local ym_end_workcases			= ym(2022,9)
local ym_start_workapps			= ym(2007,4)
local ym_end_workapps			= ym(2022,9)

local ym_start_timeliness_recert= ym(2017,9)
local ym_end_timeliness_recert	= ym(2024,5)


local mdy_start_timeliness_app 	= mdy(11,27,2017)
local mdy_end_timeliness_app    = mdy(6,17,2024) // Jun17_Jun23_2024

***************************************************************
***************************************************************
/*
///////////////////////////
// APPLICATIONS (WEEKLY) //
/////////////////////////// 

// load data 
forvalues mdy = `mdy_start_timeliness_app'(7)`mdy_end_timeliness_app' {
if `mdy' != mdy(3,26,2018) /*not listed on website*/ & `mdy' != mdy(12,24,2018) /*they posted the micro data...also here, with a key: 2021-08-23 and 2021-11-08*/ & `mdy' != mdy(8,29,2022) /*only state level summary stats posted*/ {


	///////////////////////////
	// FILE NAMES FOR IMPORT //
	///////////////////////////

	// for file names
	clear
	set obs 1
	gen year = year(`mdy')
	gen month = month(`mdy')
	gen day = day(`mdy')
	gen week = week(`mdy')
	tostring month, replace 
	replace month = "0" + month if strlen(month) == 1

	if inrange(`mdy',mdy(9,2,2019),mdy(12,30,2019)) | inrange(`mdy',mdy(1,1,2020),mdy(1,1,2099)) {
		gen mdy_end = `mdy' + 7 - 1 // inclusive	
	}
	else {
		gen mdy_end = `mdy' + 5 - 1 // inclusive			
	}
	gen year_end = year(mdy_end)
	gen month_end = month(mdy_end)
	gen day_end = day(mdy_end)
	gen week_end = week(mdy_end)
	tostring month_end, replace 
	replace month_end = "0" + month_end if strlen(month_end) == 1

	display in red "start date"
	local month = month
	display in red "`month'"
	local day = day 
	display in red "`day'"
	local year = year 
	display in red "`year'"
	local week = week 
	display in red "`week'"
	display in red "end date"
	local month_end = month_end
	display in red "`month_end'"
	local day_end = day_end 
	display in red "`day_end'"
	local year_end = year_end 
	display in red "`year_end'"
	local week_end = week_end 
	display in red "`week_end'"
	local mdy_end = mdy_end 
	display in red "`mdy_end'"

	// how months are listed 
	if inlist(`year',2017,2018) | inrange(`mdy',mdy(9,2,2019),mdy(12,30,2019)) | inrange(`mdy',mdy(4,24,2023),mdy(11,5,2023)) | inrange(`mdy',mdy(3,4,2024),mdy(1,1,2099)) {
		#delimit ;
		if `month' == 1 { ; local monthname = "Jan" ; } ; if `month_end' == 1 { ; local monthname_end = "Jan" ; } ;
		if `month' == 2 { ; local monthname = "Feb" ; } ; if `month_end' == 2 { ; local monthname_end = "Feb" ; } ;
 		if `month' == 3 { ; local monthname = "Mar" ; } ; if `month_end' == 3 { ; local monthname_end = "Mar" ; } ;
		if `month' == 4 { ; local monthname = "Apr" ; } ; if `month_end' == 4 { ; local monthname_end = "Apr" ; } ;
		if `month' == 5 { ; local monthname = "May" ; } ; if `month_end' == 5 { ; local monthname_end = "May" ; } ;
		if `month' == 6 { ; local monthname = "Jun" ; } ; if `month_end' == 6 { ; local monthname_end = "Jun" ; } ;
		if `month' == 7 { ; local monthname = "Jul" ; } ; if `month_end' == 7 { ; local monthname_end = "Jul" ; } ;
		if `month' == 8 { ; local monthname = "Aug" ; } ; if `month_end' == 8 { ; local monthname_end = "Aug" ; } ;
		if `month' == 9 { ; local monthname = "Sep" ; } ; if `month_end' == 9 { ; local monthname_end = "Sep" ; } ;
		if `month' == 10 { ; local monthname = "Oct" ; } ; if `month_end' == 10 { ; local monthname_end = "Oct" ; } ;
		if `month' == 11 { ; local monthname = "Nov" ; } ; if `month_end' == 11 { ; local monthname_end = "Nov" ; } ;
		if `month' == 12 { ; local monthname = "Dec" ; } ; if `month_end' == 12 { ; local monthname_end = "Dec" ; } ;
		#delimit cr 		
	}
	else if inrange(`mdy',mdy(2019,1,1),mdy(2019,8,26)) {
		#delimit ;
		if `month' == 1 { ; local monthname = "JAN" ; } ; if `month_end' == 1 { ; local monthname_end = "JAN" ; } ;
		if `month' == 2 { ; local monthname = "FEB" ; } ; if `month_end' == 2 { ; local monthname_end = "FEB" ; } ;
 		if `month' == 3 { ; local monthname = "MAR" ; } ; if `month_end' == 3 { ; local monthname_end = "MAR" ; } ;
		if `month' == 4 { ; local monthname = "APR" ; } ; if `month_end' == 4 { ; local monthname_end = "APR" ; } ;
		if `month' == 5 { ; local monthname = "MAY" ; } ; if `month_end' == 5 { ; local monthname_end = "MAY" ; } ;
		if `month' == 6 { ; local monthname = "JUN" ; } ; if `month_end' == 6 { ; local monthname_end = "JUN" ; } ;
		if `month' == 7 { ; local monthname = "JUL" ; } ; if `month_end' == 7 { ; local monthname_end = "JUL" ; } ;
		if `month' == 8 { ; local monthname = "AUG" ; } ; if `month_end' == 8 { ; local monthname_end = "AUG" ; } ;
		if `month' == 9 { ; local monthname = "SEP" ; } ; if `month_end' == 9 { ; local monthname_end = "SEP" ; } ;
		if `month' == 10 { ; local monthname = "OCT" ; } ; if `month_end' == 10 { ; local monthname_end = "OCT" ; } ;
		if `month' == 11 { ; local monthname = "NOV" ; } ; if `month_end' == 11 { ; local monthname_end = "NOV" ; } ;
		if `month' == 12 { ; local monthname = "DEC" ; } ; if `month_end' == 12 { ; local monthname_end = "DEC" ; } ;
		#delimit cr 		
	}
	else if inrange(`mdy',mdy(1,1,2020),mdy(4,23,2023)) | inrange(`mdy',mdy(11,6,2023),mdy(3,3,2024)) {
		#delimit ;
		if `month' == 1 { ; local monthname = "jan" ; } ; if `month_end' == 1 { ; local monthname_end = "jan" ; } ;
		if `month' == 2 { ; local monthname = "feb" ; } ; if `month_end' == 2 { ; local monthname_end = "feb" ; } ;
 		if `month' == 3 { ; local monthname = "mar" ; } ; if `month_end' == 3 { ; local monthname_end = "mar" ; } ;
		if `month' == 4 { ; local monthname = "apr" ; } ; if `month_end' == 4 { ; local monthname_end = "apr" ; } ;
		if `month' == 5 { ; local monthname = "may" ; } ; if `month_end' == 5 { ; local monthname_end = "may" ; } ;
		if `month' == 6 { ; local monthname = "jun" ; } ; if `month_end' == 6 { ; local monthname_end = "jun" ; } ;
		if `month' == 7 { ; local monthname = "jul" ; } ; if `month_end' == 7 { ; local monthname_end = "jul" ; } ;
		if `month' == 8 { ; local monthname = "aug" ; } ; if `month_end' == 8 { ; local monthname_end = "aug" ; } ;
		if `month' == 9 { ; local monthname = "sep" ; } ; if `month_end' == 9 { ; local monthname_end = "sep" ; } ;
		if `month' == 10 { ; local monthname = "oct" ; } ; if `month_end' == 10 { ; local monthname_end = "oct" ; } ;
		if `month' == 11 { ; local monthname = "nov" ; } ; if `month_end' == 11 { ; local monthname_end = "nov" ; } ;
		if `month' == 12 { ; local monthname = "dec" ; } ; if `month_end' == 12 { ; local monthname_end = "dec" ; } ;
		#delimit cr 		
	}
	else {
		stop 
	}

	// how days are listed - with or without a leading zero
	if inrange(`mdy',mdy(9,2,2019),mdy(12,30,2019)) {
		local dayname = "`day'"
		local dayname_end = "`day_end'"
	}
	else if inlist(`year',2017,2018) | inrange(`mdy',mdy(2019,1,1),mdy(2019,8,26)) | inrange(`mdy',mdy(1,1,2020),mdy(1,1,2099)) {
		if inrange(`day',1,9) {
			local dayname = "0" + "`day'"
		}
		else {
			local dayname = "`day'"
		}
		if inrange(`day_end',1,9) {
			local dayname_end = "0" + "`day_end'"
		}
		else {
			local dayname_end = "`day_end'"
		}
	}
	else {
		stop
	}

	// month date divider 
	if inrange(`mdy',mdy(9,2,2019),mdy(12,30,2019)) {
		local month_day_divider "-"
	}
	else {
		local month_day_divider ""
	}

	// date divider
	if inrange(`mdy',mdy(9,2,2019),mdy(12,30,2019)) {
		local day_divider = "-"
	}
	else if inlist(`year',2017,2018) | inrange(`mdy',mdy(2019,1,1),mdy(2019,8,26)) | inrange(`mdy',mdy(1,1,2020),mdy(1,1,2099)) {
		local day_divider = "_"
	}
	else {
		stop
	}

	////////////
	// IMPORT //
	////////////

	// import 
	if inlist(`mdy',mdy(8,23,2021),mdy(11,8,2021),mdy(4,17,2023),mdy(5,29,2023),mdy(11,6,2023),mdy(6,10,2024)) {
		display in red "`monthname'`month_day_divider'`dayname'`day_divider'`monthname_end'`month_day_divider'`dayname_end'`day_divider'`year'.xlsx"
		import excel using "${dir_root}/data/state_data/northcarolina/timeliness/excel/application/`year'/`monthname'`month_day_divider'`dayname'`day_divider'`monthname_end'`month_day_divider'`dayname_end'`day_divider'`year'.xlsx", sheet("County") allstring clear		
	}
	else {
		display in red "`monthname'`month_day_divider'`dayname'`day_divider'`monthname_end'`month_day_divider'`dayname_end'`day_divider'`year'.xlsx"
		import excel using "${dir_root}/data/state_data/northcarolina/timeliness/excel/application/`year'/`monthname'`month_day_divider'`dayname'`day_divider'`monthname_end'`month_day_divider'`dayname_end'`day_divider'`year'.xlsx", sheet("Table 1") allstring clear		
	}

	// drop top rows
	drop in 1

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// drop rows I don't need 
	drop if strpos(v1,"NORTH CAROLINA'S FNS APPLICATION PROCESSING TIMELINESS RATE BY COUNTY FOR THE WEEK ENDING")
	drop if strpos(v2,"NORTH CAROLINA'S FNS APPLICATION PROCESSING TIMELINESS RATE BY COUNTY FOR THE WEEK ENDING")
	drop if strpos(v1,"*NOTE: This report was revised to correct for the previous April 1-5 report.  It was called to our attention that the FNS timeliness data in the C SDW table als")
	drop if strpos(v1,"NORTH CAROLINA FNS APPLICATION PROCESSING TIMELINESS RATE BY COUNTY FOR THE WEEK ENDING")
	drop if v2 == "Not Expedited"
	drop if v2 == "Timely"
	drop if v2 == "Count"

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// drop rows I don't need 
	drop if strpos(v1,"NORTH CAROLINA'S FNS APPLICATION PROCESSING TIMELINESS RATE BY COUNTY FOR THE WEEK ENDING")
	drop if strpos(v2,"NORTH CAROLINA'S FNS APPLICATION PROCESSING TIMELINESS RATE BY COUNTY FOR THE WEEK ENDING")
	drop if v2 == "Not Expedited"
	drop if v2 == "Timely"
	drop if v2 == "Count"

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// assert shape 
	assert `r(k)' == 13
	assert `r(N)' == 101 | `r(N)' == 99 | `r(N)' == 94 | `r(N)' == 100

	// rename vars 
	rename v1 county 
	rename v2 apps_notexpedited_timely
	rename v3 apps_notexpedited_timely_perc
	rename v4 apps_notexpedited_untimely
	rename v5 apps_notexpedited_untimely_perc
	rename v6 apps_expedited_timely
	rename v7 apps_expedited_timely_perc
	rename v8 apps_expedited_untimely
	rename v9 apps_expedited_untimely_perc
	rename v10 apps_approved_timely
	rename v11 apps_approved_timely_perc
	rename v12 apps_approved_untimely
	rename v13 apps_approved_untimely_perc

	// drop vars I don't need 
	drop *_perc

	// clean county 
	replace county = strlower(county)
	replace county = "total" if county == "all counties"

	// copy to shorten varnames 
	rename county county_copy
	gen county = county_copy
	drop county_copy

	// destring
	foreach var in apps_notexpedited_timely apps_notexpedited_untimely apps_expedited_timely apps_expedited_untimely apps_approved_timely apps_approved_untimely {
		replace `var' = ustrregexra(`var',"-","")
		destring `var', replace 
		confirm numeric variable `var'
	}

	// generate vars 
	egen apps_notexpedited 	= rowtotal(apps_notexpedited_timely apps_notexpedited_untimely)
	egen apps_expedited 	= rowtotal(apps_expedited_timely apps_expedited_untimely)
	egen apps_approved 		= rowtotal(apps_approved_timely apps_approved_untimely)

	// week 
	gen yw = yw(`year',`week')
	format yw %tw

	// start and end dates of week 
	gen mdy_start = `mdy'
	format mdy_start %td 
	gen mdy_end = `mdy_end'
	format mdy_end %td 

	// ym 
	gen ym = ym(year(dofw(yw)),month(dofw(yw)))
	format ym %tm 
	order ym
	 
	// order and sort 
	order county yw ym mdy_start mdy_end apps_approved apps_approved_timely apps_approved_untimely apps_expedited apps_expedited_timely apps_expedited_untimely apps_notexpedited apps_notexpedited_timely apps_notexpedited_untimely
	sort county yw 

	// save 
	tempfile _`mdy'
	save `_`mdy''

}
}

// append all weeks data 
forvalues mdy = `mdy_start_timeliness_app'(7)`mdy_end_timeliness_app' {
if `mdy' != mdy(3,26,2018) /*not listed on website*/ & `mdy' != mdy(12,24,2018) /*they posted the micro data...also here, with a key: 2021-08-23 and 2021-11-08*/ & `mdy' != mdy(8,29,2022) /*only state level summary stats posted*/ {
	if `mdy' == `mdy_start_timeliness_app' {
		use `_`mdy'', clear
	}
	else {
		append using `_`mdy''
	}
}
}

/*
// get state totals 
preserve
	keep if county != "total"
	collapse (sum) recerts, by(mdy)
	gen county = "total"
	tempfile _total
	save `_total'
restore

// append state totals 
drop if county == "total"
append using `_total'
sort county ym 
*/
// make a balanced panel
egen countyid = group(county)
tsset countyid yw 
tsfill, full
gsort countyid -yw
by countyid: carryforward county, replace 
gsort countyid yw 
by countyid: carryforward county, replace 
drop countyid
tab county 

// save
save "${dir_root}/data/state_data/northcarolina/northcarolina_timeliness_app.dta", replace


/*
twoway (connected apps_approved yw if county == "total", yaxis(1)) (connected apps_expedited yw if county == "total", yaxis(2))
keep if county == "total"
sort countyid yw 
foreach var in apps_approved apps_expedited {
	gen `var'_movingavg = (F2.`var' + F1.`var' + `var' + L1.`var' + L2.`var') / 5	
}
twoway (connected apps_approved_movingavg yw, yaxis(1)) (connected apps_expedited_movingavg yw, yaxis(2))
*/


// MONTHLY

// create monthly version of data from weekly version - linearly interpolate for weeks that go across days 

// load data 
use "${dir_root}/data/state_data/northcarolina/northcarolina_timeliness_app.dta", clear 

// mark observations that go across more than one month 
gen repeat = 0
replace repeat = 1 if month(mdy_start) == month(mdy_end)
replace repeat = 2 if month(mdy_start) != month(mdy_end)
expand repeat 

// for observations that go across more than one month, make a copy 
bysort county yw: gen obsid = _n 
assert inlist(obsid,1,2)

// for second copy, replace month data 
replace ym = ym + 1 if obsid == 2

// generate weight 
gen weight = . 
replace weight = 1 if repeat == 1
replace weight = day(mdy_end) / 7 if repeat == 2 & obsid == 2
replace weight = (7 - day(mdy_end)) / 7 if repeat == 2 & obsid == 1

// collapse 
drop obsid
drop repeat 
drop yw 
drop mdy_start
drop mdy_end 
#delimit ;
collapse (sum) 
	apps_approved
	apps_approved_timely
	apps_approved_untimely
	apps_expedited
	apps_expedited_timely
	apps_expedited_untimely
	apps_notexpedited
	apps_notexpedited_timely
	apps_notexpedited_untimely
 		[pweight = weight], by(county ym)
;
#delimit cr 
 
// drop observations that are all missing 
#delimit ;
drop if 
	apps_approved == 0 &
	apps_approved_timely == 0 &
	apps_approved_untimely == 0 &
	apps_expedited == 0 &
	apps_expedited_timely == 0 &
	apps_expedited_untimely == 0 &
	apps_notexpedited == 0 &
	apps_notexpedited_timely == 0 &
	apps_notexpedited_untimely == 0
;
#delimit cr 
assert !missing(ym)

// save 
save "${dir_root}/data/state_data/northcarolina/northcarolina_timeliness_app_ym.dta", replace 
check
*/
***************************************************************
***************************************************************
/*
////////////////////////////////
// RECERTIFICATIONS (MONTHLY) //
////////////////////////////////

// load data 
forvalues ym = `ym_start_timeliness_recert'(1)`ym_end_timeliness_recert' {
if `ym' != ym(2019,8) {

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace 
	replace month = "0" + month if strlen(month) == 1
	local month = month
	display in red "`month'"
	local year = year 
	display in red "`year'"
	#delimit ;
	if `month' == 1 { ; local monthname = "January" ; } ;
	if `month' == 2 { ; local monthname = "February" ; } ;
 	if `month' == 3 { ; local monthname = "March" ; } ;
	if `month' == 4 { ; local monthname = "April" ; } ;
	if `month' == 5 { ; local monthname = "May" ; } ;
	if `month' == 6 { ; local monthname = "June" ; } ;
	if `month' == 7 { ; local monthname = "July" ; } ;
	if `month' == 8 { ; local monthname = "August" ; } ;
	if `month' == 9 { ; local monthname = "September" ; } ;
	if `month' == 10 { ; local monthname = "October" ; } ;
	if `month' == 11 { ; local monthname = "November" ; } ;
	if `month' == 12 { ; local monthname = "December" ; } ;
	#delimit cr 

	// import 
	if inlist(`year',2017,2018,2019,2020) {
		import excel using "${dir_root}/data/state_data/northcarolina/timeliness/excel/recertification/`year'/`monthname'-`year'.xlsx", allstring /*firstrow case(lower)*/ clear	
	}
	else {
		import excel using "${dir_root}/data/state_data/northcarolina/timeliness/excel/recertification/`year'/`monthname' `year'.xlsx", allstring /*firstrow case(lower)*/ clear
	}
	
	// drop top row 
	if `ym' >= ym(2019,2) {
		drop in 1
	}
	if inrange(`ym',ym(2020,5),ym(2023,1)) | inlist(`ym',ym(2023,5)) {
		drop in 1
	}

	// clean up 
	dropmiss, force 
	dropmiss, force obs 
	describe, varlist
	rename (`r(varlist)') (v#), addnumber

	// drop other obs
	drop if strpos(v1,"Recertification Timeliness Report data is only reflective of cases that were not included in the automatic certification extensions as a result of COVID 19.") 
 
	// make firstrow varnames 
	foreach var of varlist _all {
		replace `var' = subinstr(`var', "`=char(37)'", "perc_", .) if _n == 1 // char(37) = %
		replace `var' = subinstr(`var', "`=char(9)'", " ", .) if _n == 1
		replace `var' = subinstr(`var', "`=char(10)'", " ", .) if _n == 1
		replace `var' = subinstr(`var', "`=char(13)'", " ", .) if _n == 1
		replace `var' = subinstr(`var', "`=char(14)'", " ", .) if _n == 1
		replace `var' = subinstr(`var', " ", "", .) if _n == 1
		replace `var' = trim(`var')
		replace `var' = stritrim(`var')
		replace `var' = strlower(`var')
		replace `var' = "filler" if missing(`var') & _n == 1
		replace `var' = "grand_total" if strpos(`var',"grand") & strpos(`var',"total") & _n == 1
		rename `var' `=`var'[1]'
		capture drop filler 
	}
	drop in 1

	// keep only variables I need
	capture rename cuntyname countyname
	capture rename grand_total totals
	capture rename grand_totals totals
	capture rename total totals
	keep countyname totals

	// rename variables
	rename countyname 	county 
	rename totals 		recerts

	////////////
	// COUNTY //
	////////////

	// clean up county 
	replace county = stritrim(county)
	replace county = trim(county)
	replace county = subinstr(county, "`=char(9)'", "", .)
	replace county = subinstr(county, "`=char(10)'", "", .)
	replace county = subinstr(county, "`=char(13)'", "", .)
	replace county = subinstr(county, "`=char(14)'", "", .)
	replace county = subinstr(county, `"`=char(34)'"', "", .) // single quotation '
	*replace county = ustrregexra(county," ","")
	replace county = ustrregexra(county,"-","")
	replace county = ustrregexra(county,"\'","")
	replace county = ustrregexra(county,"\.","")

	// lowercase county 
	replace county = strlower(county)

	// manual fixes
	replace county = "yancey" if strpos(county,"yancey")
	replace county = "grandtotal" if county == "grand_total" | county == "grand_totals"
	replace county = "total" if county == "grandtotal" | (strpos(county,"grand") & strpos(county,"total"))
	drop if county == "sum:"
	drop if strpos(county,"2019  07/31/2019")

	// copy to shorten varnames 
	rename county county_copy
	gen county = county_copy
	drop county_copy

	if inlist(`ym',ym(2020,2),ym(2020,7)) {
		drop if missing(county)
	}

	//////////////
	// DESTRING //
	//////////////

	// destring 
	foreach var in recerts {
		destring `var', replace
		confirm numeric variable `var'
	}

	// ym 
	gen ym = `ym'
	format ym %tm 

	// order and sort 
	order county ym recerts
	sort county ym 

	// save 
	tempfile _`ym'
	save `_`ym''
}
}

// append all months data 
forvalues ym = `ym_start_timeliness_recert'(1)`ym_end_timeliness_recert' {
if `ym' != ym(2019,8) {
	if `ym' == `ym_start_timeliness_recert' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}
}

// get state totals 
preserve
	keep if county != "total"
	collapse (sum) recerts, by(ym)
	gen county = "total"
	tempfile _total
	save `_total'
restore

// append state totals 
drop if county == "total"
append using `_total'
sort county ym 

// make a balanced panel
egen countyid = group(county)
tsset countyid ym 
tsfill, full
gsort countyid -ym
by countyid: carryforward county, replace 
gsort countyid ym 
by countyid: carryforward county, replace 
drop countyid
tab county 

// drop observations with no info 
drop if missing(county) & missing(recerts)

// later: figure out how to deal with missing vs. zeros (I think zeros are not included, so need a principaled way of distinguishing what is currently missing as actually missing or zeros)

// save
save "${dir_root}/data/state_data/northcarolina/northcarolina_timeliness_recert.dta", replace
check
*/

**************************************************************
**************************************************************
**************************************************************
**************************************************************
/*
//////////////
// DATASETS //
//////////////

foreach dataset of local datasets {
	forvalues ym = `ym_start_`dataset''(1)`ym_end_`dataset'' {
	
		// for sheet names
		clear
		set obs 1
		gen year = year(dofm(`ym'))
		gen month = month(dofm(`ym'))
		tostring month, replace 
		replace month = "0" + month if strlen(month) == 1
		local month = month
		display "`month'"
		local year = year 
		display "`year'"
		 
		// import 
		import excel using "${dir_root}/data/state_data/northcarolina/`file_`dataset''.xlsx", sheet("`year'`month'") firstrow case(lower) clear
	
		// clean a bit 
		if "`dataset'" == "cases" {
			dropmiss, force
			if `ym' >= ym(2017,3) {
				rename reportmonth yearmonth
				tostring yearmonth, replace
			}
			else {
				rename month yearmonth
				tostring yearmonth, replace
			}
			gen ym = `ym'
			format ym %tm
			if inlist(`ym',ym(2018,2),ym(2018,3),ym(2018,4)) | inrange(`ym',ym(2018,8),ym(2022,9)) {
				rename countyname county
			}
			replace county = trim(county)
			replace county = strlower(county)
			replace county = "total" if strpos(county,"total") | strpos(yearmonth,"total")
			drop if missing(county)
			drop yearmonth

			// drop variable i and k
			capture confirm variable i
			if !_rc {
                di in red "i exists"
                drop i k
            }
            else {
            }
		}
		if "`dataset'" == "apps" {
			dropmiss, force 
			gen ym = `ym'
			format ym %tm
			rename a county 
			rename b apps_received
			replace county = trim(county)
			replace county = strlower(county)
			drop if missing(county)
			replace county = "total" if strpos(county,"total")
		}
		if "`dataset'" == "abawds" {
			gen ym = `ym'
			format ym %tm
			rename activecount abawdsactive 
			rename closedcount abawdsclosed
			replace county = trim(county)
			replace county = strlower(county)
			replace county = "total" if county == "grand total"
		}
		if "`dataset'" == "workcases" {
			dropmiss, force 
			drop reportmonth
			gen ym = `ym'
			format ym %tm
			rename county county1
			rename cases workfirst_cases1
			rename participants workfirst_participants1
			capture confirm variable f
			if !_rc {
				drop f 
       			rename g county2
       			rename h workfirst_cases2
       			rename i workfirst_participants2
            }
            else {
            }
            capture confirm variable n
			if !_rc {
				drop n 
            }
            else {
            }
			gen id = _n
			reshape long county workfirst_cases workfirst_participants, i(id) j(num)
			drop id num 
			replace county = trim(county)
			replace county = strlower(county)
			replace county = "total" if missing(county) & !missing(workfirst_cases) & !missing(workfirst_participants)
			drop if missing(county) & missing(workfirst_cases) & missing(workfirst_participants)
		}
		
		if "`dataset'" == "workapps" {
			gen ym = `ym'
			format ym %tm
			rename a county1 
			rename b workfirst_apps1
			rename c county2 
			capture confirm variable d
			if !_rc {
       			rename d workfirst_apps2
            }
            else {
            	gen workfirst_apps2 = .
            }

			dropmiss, force 
			gen id = _n
			reshape long county workfirst_apps, i(id) j(num)
			drop id num 
			replace county = trim(county)
			replace county = strlower(county)
			replace county = "total" if strpos(county,"total")
			drop if missing(county)
			sort county
		}

		// temp save 
		tempfile _`ym'
		save `_`ym''
	
	}
	
	// append all months data 
	forvalues ym = `ym_start_`dataset''(1)`ym_end_`dataset'' {
		if `ym' == `ym_start_`dataset'' {
			use `_`ym'', clear
		}
		else {
			append using `_`ym''
		}
	}
	dropmiss, force 
	save "${dir_root}/data/state_data/northcarolina/northcarolina_`dataset'.dta", replace
 
}
**"NOTE:  During January 2014, Work First began to transition into NCFAST.  The data in the first chart represents the case and participant count information from the EIS legacy system, while the data from the second chart represents the data from the NCFAST system. All counties did not transition at the same time, so there may not be data represented from the NCFAST system for each county. Therefore, to calculate the total per county on the summary tab, the case counts were added together from both systems."		
use "${dir_root}/data/state_data/northcarolina/northcarolina_workcases.dta", clear 
collapse (sum) workfirst_cases workfirst_participants, by(county ym)
save "${dir_root}/data/state_data/northcarolina/northcarolina_workcases.dta", replace
duplicates report county ym 
*/
 
**************************************************************
**************************************************************
**************************************************************
**************************************************************

///////////
// MERGE //
///////////

// collapse case data to state level 
use "${dir_root}/data/state_data/northcarolina/northcarolina_cases.dta", clear
drop if county == "total"
assert !strpos(county,"total") & !strpos(county,"state")
*tab county 
collapse (sum) cases participants, by(ym)
gen county = "total"
save "${dir_root}/data/state_data/northcarolina/northcarolina_cases_statelevel.dta", replace

// **TEMPORARY: makes sure the dataset contains no duplicates 
foreach dataset of local datasets {
	display in red "`dataset'"

	use "${dir_root}/data/state_data/northcarolina/northcarolina_`dataset'.dta", clear
	capture confirm variable countyname 
	if !_rc {
		replace county = countyname if missing(county) & !missing(countyname)
	}
	duplicates tag county ym, gen(dup)
	assert dup == 0 
	drop dup 

	save "${dir_root}/data/state_data/northcarolina/northcarolina_`dataset'_nodup.dta", replace
}

// merge all datasets together
foreach dataset of local datasets {
	display in red "`dataset'"
	if "`dataset'" == "cases" {
		use "${dir_root}/data/state_data/northcarolina/northcarolina_`dataset'_nodup.dta", clear
	}
	else {
		merge 1:1 county ym using "${dir_root}/data/state_data/northcarolina/northcarolina_`dataset'_nodup.dta"
		assert inlist(county,"total","not assigned") if _m == 2
		drop _m

	}
}

// merge app data 
merge 1:1 county ym using "${dir_root}/data/state_data/northcarolina/northcarolina_timeliness_app_ym.dta", update
assert inlist(county,"total","not assigned") | inlist(ym,ym(2024,6)) if _m == 2
drop _m

// merge recert data 
merge 1:1 county ym using "${dir_root}/data/state_data/northcarolina/northcarolina_timeliness_recert.dta"
assert inlist(county,"total","not assigned") if _m == 2
drop _m

// merge state level case data  
merge 1:1 county ym using "${dir_root}/data/state_data/northcarolina/northcarolina_cases_statelevel.dta", update replace
assert inlist(_m,1,3,4)
drop _m 

// order and sort 
order county ym 
sort county ym 

// label
label var participants "SNAP participants"
label var cases "SNAP cases"
label var apps_received "SNAP applications"
label var abawdsactive "ABAWDs - active cases"
label var abawdsclosed "ABAWDs - closed cases"
label var workfirst_cases "Work First cases"
label var workfirst_participants "Work First participants"
label var workfirst_apps "Work First applications"

// rename 
rename cases households
rename participants individuals

// drop bad vars 
dropmiss, force 
count if !missing(m)
assert `r(N)' == 43 // 26 // 23
drop m
dropmiss, force 
count if !missing(e)
assert `r(N)' == 11
drop e 

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// save 
save "${dir_root}/data/state_data/northcarolina/northcarolina.dta", replace 

check 

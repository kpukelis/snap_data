// california.do 
// Kelsey Pukelis

local year_short_list			/*10 14*/ 16 17 18 19 20 21 22 23
local first_year_short 			16

local year_short_list_churn 	20 21 22 23
local first_year_short_churn 	20 

**************************************************************************

////////////////
// CHURN DATA //
//////////////// 

/*
foreach year_short of local year_short_list_churn {

	// display ym 
	display in red "`year'"

	// for file names
	clear
	set obs 1
	gen year_short = `year_short'
	gen year_short_plus1 = `year_short' + 1
	gen year = 2000 + `year_short'
	local year_short = year_short
	display in red "`year_short'"
	local year_short_plus1 = year_short_plus1
	display in red "`year_short_plus1'"
	local year = year
	display in red "`year'"

	////////////////////////
	// GET VARIABLE NAMES //
	////////////////////////

	// load data 
	import excel "${dir_root}/data/state_data/california/excel/CF 18 - CalFresh Churn Monthly Report/CF18FY`year_short'-`year_short_plus1'.xlsx", sheet("DataDictionary") allstring case(lower) firstrow clear 		
	
	// rename 
	rename thissheetcontainsadatadicti cell 
	rename b churnmeasurement
	rename c part 
	rename d item 
	rename e column 
	drop in 1 

	// clean up vars 
	// item 
	// split item, parse(".")
	// drop item 
	// drop item1
	// rename item2 item 

	// part
	tab part 
	// qui replace part = "" if part == "a. participation during the month"
	// qui replace part = "issuance_" if part == "b. issuances during the month"
	// qui replace part = "vissuance_" if part == "c. value of benefit issuances during the month"
	// qui replace part = substr(part,1,1)
	*tab part 

	// remove parentheses
	foreach var in part column item {
		gen `var'_og = `var'
		qui replace `var' = ustrregexra(`var',"Within the Prior","")
		qui replace `var' = strlower(`var')
		qui replace `var' = ustrregexra(`var',"\-","")
		qui replace `var' = ustrregexra(`var',"\(","")
		qui replace `var' = ustrregexra(`var',"\)","")
		qui replace `var' = ustrregexra(`var',"/","")
		qui replace `var' = ustrregexra(`var',"\:","")
		qui replace `var' = ustrregexra(`var',"\'","")
		qui replace `var' = ustrregexra(`var',"\_","")
		qui replace `var' = ustrregexra(`var',"\,","")
		qui replace `var' = ustrregexra(`var',"\.","")
		qui replace `var' = ustrregexra(`var',"number of ","")
		qui replace `var' = ustrregexra(`var'," the ","")
		qui replace `var' = ustrregexra(`var',"$the ","")
		qui replace `var' = ustrregexra(`var'," ","")
		*qui replace `var' = ustrregexra(`var',"federalandstatepersons","fedstatepers")
		*qui replace `var' = ustrregexra(`var',"federalstatehouseholds","fedstatehhs")
		qui replace `var' = ustrregexra(`var',"persons","pers")
		qui replace `var' = ustrregexra(`var',"households","hhs")
		qui replace `var' = ustrregexra(`var',"federal","fed")
		qui replace `var' = ustrregexra(`var',"application","app")
		qui replace `var' = ustrregexra(`var',"priortodatacohortmonth","")
		qui replace `var' = ustrregexra(`var',"datacohortmonth","")
		qui replace `var' = ustrregexra(`var',"month","mth")
		qui replace `var' = ustrregexra(`var',"sar7orrrrcorrelateddiscontinuation","closure")
		qui replace `var' = ustrregexra(`var',"sar7orrrrrelatedrestoration","restoration")
		qui replace `var' = ustrregexra(`var',"eligible","elig")
		qui replace `var' = ustrregexra(`var',"expeditedservice","exp")
		qui replace `var' = ustrregexra(`var',"initialapp","app")
		qui replace `var' = ustrregexra(`var',"average","avg")
		// qui replace `var' = ustrregexra(`var',"total","ttl")
		qui replace `var' = ustrregexra(`var',"total","")
		qui replace `var' = ustrregexra(`var',"receivedfrom","")
		qui replace `var' = ustrregexra(`var',"thatweredisposedand","")
		qui replace `var' = ustrregexra(`var',"thatweredisposed","")
		qui replace `var' = ustrregexra(`var',"deemed","")
		qui replace `var' = ustrregexra(`var',"experienced","")
		qui replace `var' = ustrregexra(`var',"subsequently","")
		qui replace `var' = ustrregexra(`var',"either","")
		qui replace `var' = ustrregexra(`var',"recent","")
		qui replace `var' = ustrregexra(`var',"lossofbenefits","loss")
		qui replace `var' = ustrregexra(`var',"allcalfresh","")
		qui replace `var' = ustrregexra(`var',"during","")
		qui replace `var' = ustrregexra(`var',"calendar","")
		qui replace `var' = ustrregexra(`var',"withinthepe","")
		qui replace `var' = ustrregexra(`var',"with","")
		qui replace `var' = ustrregexra(`var',"forbenefits","")
		qui replace `var' = ustrregexra(`var',"1","")
		qui replace `var' = ustrregexra(`var',"2","")
		qui replace `var' = ustrregexra(`var',"3","")
		qui replace `var' = ustrregexra(`var',"4","")
		qui replace `var' = ustrregexra(`var',"5","")
		qui replace `var' = ustrregexra(`var',"6","")
		qui replace `var' = ustrregexra(`var',"7","")
		qui replace `var' = ustrregexra(`var',"8","")
		qui replace `var' = ustrregexra(`var',"9","")
		qui replace `var' = ustrregexra(`var',"0","")
		qui replace `var' = ustrregexra(`var',"four","4")
		qui replace `var' = ustrregexra(`var',"first","1st")
		qui replace `var' = ustrregexra(`var',"second","2nd")
		qui replace `var' = ustrregexra(`var',"third","3rd")
		qui replace `var' = ustrregexra(`var',"fourth","4th")
		qui replace `var' = ustrregexra(`var',"timely","time")
	}
	qui replace part = ustrregexra(part,"sars&rrrs","")
	qui replace item = ustrregexra(item,"sars&rrrs","")
	qui replace item = ustrregexra(item,"sar&rrr","")

	// manual item replacement
	replace item = "late1stelig" if item_og == "6. The total number of late SAR 7s & RRRs received from households within the First Month Following Data Cohort Month that were disposed and deemed eligible and experienced either no loss or loss of benefits."
	replace item = "late1stinelig" if item_og == "8. The total number of late SAR 7s & RRRs received from households within the First Month Following Data Cohort Month that were disposed and subsequently deemed ineligible"
	//	
	replace item = "newapp1stelig" if item_og == "9. The total number of SAR 7 & RRR households who do not renew in the Data Cohort Month, but submit a new application in the First Month Following Data Cohort Month were disposed and subsequently deemed eligible for benefits"
	replace item = "newapp1stinelig" if item_og == "10. The total number of SAR 7 & RRR households who do not renew in the Data Cohort Month, but submit a new application in the First Month Following Data Cohort Month were disposed and subsequently deemed ineligible (include withdrawals) for benefits"
	replace item = "newapp2ndelig" if item_og == "11. The total number of SAR 7 & RRR households who do not renew in the Data Cohort Month, but submit a new application in the Second Month Following Data Cohort Month were disposed and subsequently deemed eligible for benefits"
	replace item = "newapp2ndinelig" if item_og == "12. The total number of SAR 7 & RRR households who do not renew in the Data Cohort Month, but submit a new application in the Second Month Following Data Cohort Month were disposed and subsequently deemed ineligible (include withdrawals) for benefits."
	replace item = "newapp3rdelig" if item_og == "13. The total number of SAR 7 & RRR households who do not renew in the Data Cohort Month, but submit a new application in the Third Month Following Data Cohort Month were disposed and subsequently deemed eligible for benefits"
	replace item = "newapp3rdinelig" if item_og == "14. The total number of SAR 7 & RRR households who do not renew in the Data Cohort Month, but submit a new application in the Third Month Following Data Cohort Month were disposed and subsequently deemed ineligible (include withdrawals) for benefits"
	replace item = "newapp4thelig" if item_og == "15. The total number of SAR 7 & RRR households who do not renew in the Data Cohort Month, but submit a new application in the Fourth Month Following Data Cohort Month were disposed and subsequently deemed eligible for benefits"
	replace item = "newapp3thinelig" if item_og == "16. The total number of SAR 7 & RRR households who do not renew in the Data Cohort Month, but submit a new application in the Fourth Month Following Data Cohort Month were disposed and subsequently deemed ineligible (include withdrawals) for benefits"
	// 
	replace item = "apps_rec" if item_og == "17. The total number of CalFresh and CFAP applications disposed of during the Data Cohort Month"
	replace item = "apps_rec_churn" if item_og == "18. The total number of CalFresh and CFAP applications disposed of during the Data Cohort Month from a household who participated in CalFresh/CFAP within the prior four full calendar months"
	replace item = "apps_exp_1_3days" if item_og == "30. The total number of initial applications with expedited service approved within one to three days"
	replace item = "apps_exp_4_7days" if item_og == "31. The total number of initial applications with expedited service approved within four to seven days"
	replace item = "apps_exp_8days" if item_og == "32. The total number of initial applications with expedited service approved after seven days"
	replace item = "apps_nonexp_01_07days" if item_og == "34. The total number of initial applications non-expedited service approved within one to seven days"
	replace item = "apps_nonexp_08_15days" if item_og == "35. The total number of initial applications with non-expedited service approved within eight to fifteen days"
	replace item = "apps_nonexp_16_22days" if item_og == "36. The total number of initial applications with non-expedited service approved within sixteen to twenty-two days"
	replace item = "apps_nonexp_23_30days" if item_og == "37. The total number of initial applications with non-expedited service approved within twenty-three to thirty days"
	replace item = "apps_nonexp_31days" if item_og == "38. The total number of initial applications with non-expedited service approved over thirty days"


	// column
	// qui replace column = "pacf" if column == "a.publicassistance"
	// qui replace column = "nacf" if column == "b.nonpublicassistance"
	qui replace column = "ttl" if missing(column) // & missing(part)

	// generate variable name 
	qui gen varname = part + "_" + column + "_" + item 
	qui replace varname = stritrim(varname)
	qui replace varname = substr(varname,1,31)

	// initial varname 
	qui destring cell, replace 
	confirm numeric variable cell 
	if `year_short' == 20 {
		qui replace cell = cell + 5 // since there are year variables to start 	
	}
	else {
		qui replace cell = cell + 6 // since there are year variables to start 
	}
	
	qui tostring cell, gen(v)
	qui replace v = "v" + v 

	// get text for renaming 
	display in red "`year_short'"
	list v varname

	rename varname varname_`year_short'
	duplicates tag varname_`year_short', gen(dup)
	*br if dup > 0
	assert dup == 0
	drop dup 

	// save
	*tempfile varnames2
	save "${dir_root}/data/state_data/california/churn_varnames2_`year_short'.dta", replace
 
}
*/

// load data 
foreach year_short of local year_short_list_churn {

	// display ym 
	display in red "`year'"

	// for file names
	clear
	set obs 1
	gen year_short = `year_short'
	gen year_short_plus1 = `year_short' + 1
	gen year = 2000 + `year_short'
	local year_short = year_short
	display in red "`year_short'"
	local year_short_plus1 = year_short_plus1
	display in red "`year_short_plus1'"
	local year = year
	display in red "`year'"
	
	/////////////////
	// ACTUAL DATA //
	/////////////////

	if inrange(`year_short',20,24) {
		// load data 
		import excel "${dir_root}/data/state_data/california/excel/CF 18 - CalFresh Churn Monthly Report/CF18FY`year_short'-`year_short_plus1'.xlsx", sheet("Data_Internal") allstring case(lower) firstrow clear 		
	}
	else {
		stop 
	}

	// drop empty variables
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	drop in 1

	// one extra blank var in FY 2020
	if inlist(`year_short',20,21,22,23) { 
		drop v3 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
	}

	// rename variables
	describe, varlist
	if inlist(`year_short',20) {
		assert `r(k)' == 73
		assert `r(N)' == 299	
	}
	else if inlist(`year_short',21) { 
		assert `r(k)' == 74
		assert `r(N)' == 712	
	}
	else if inlist(`year_short',22) { 
		assert `r(k)' == 74
		assert `r(N)' == 594
	}
	else if inlist(`year_short',23) { 
		assert `r(k)' == 74
		assert `r(N)' == 417
	}

	*else if `year_short' == 23 {
		*assert `r(N)' == 181 // this will change as more data is added 
	*}

	
	if inlist(`year_short',20) {
		rename v1 date 
		rename v2 county 
		rename v3 sfy 
		rename v4 ffy 
		rename v5 reportmonth 
	}
	else if inlist(`year_short',21,22,23) {
		rename v1 date 
		rename v2 county
		rename v3 countycode 
		rename v4 sfy 
		rename v5 ffy 
		rename v6 reportmonth
	}
	
	// rename vars 
	renamefrom using "${dir_root}/data/state_data/california/churn_varnames2_`year_short'.dta", filetype(stata) raw(v) clean(varname_`year_short') keepx
	
	// drop last heading rows
	drop in 1 
	drop in 1 
	drop in 1 
	drop in 1 

	// split date 
	gen day = substr(date,1,2)
	gen month = substr(date,3,3)
	gen year = substr(date,6,4)
	replace month = "1" if month == "jan"
	replace month = "2" if month == "feb"
	replace month = "3" if month == "mar"
	replace month = "4" if month == "apr"
	replace month = "5" if month == "may"
	replace month = "6" if month == "jun"
	replace month = "7" if month == "jul"
	replace month = "8" if month == "aug"
	replace month = "9" if month == "sep"
	replace month = "10" if month == "oct"
	replace month = "11" if month == "nov"
	replace month = "12" if month == "dec"
	foreach var in day month year {
		destring `var', replace 
		confirm numeric variable `var'
	}
	assert day == 1 
	drop day 
	gen ym = ym(year,month)
	format ym %tm 
	drop year
	drop month 

	// clean up date 
	// capture confirm variable year 
	// capture confirm variable month 
	// if !_rc {
	// 	display in red "month var already created"
	// 	destring month, replace 
	// 	destring year, replace 
	// 	confirm numeric variable month 
	// 	confirm numeric variable year 
	// 	gen ym = ym(year,month)
	// 	format ym %tm 
	// 	drop year month 
	// }
	capture confirm variable ym 
	if !_rc {

	}
	else {
		capture confirm variable date 
		if !_rc {
			gen year = substr(date,6,4)
			destring year, replace 
			gen month = substr(reportmonth,3,3)
			replace month = "01" if month == "jan"
			replace month = "02" if month == "feb"
			replace month = "03" if month == "mar"
			replace month = "04" if month == "apr"
			replace month = "05" if month == "may"
			replace month = "06" if month == "jun"
			replace month = "07" if month == "jul"
			replace month = "08" if month == "aug"
			replace month = "09" if month == "sep"
			replace month = "10" if month == "oct"
			replace month = "11" if month == "nov"
			replace month = "12" if month == "dec"
			destring month, replace
			confirm numeric variable month
			drop date
			gen ym = ym(year,month)
			format ym %tm 
			drop year month 	
		}
		capture confirm variable ym 
		if !_rc {
			display in red "ym already created"
		}
		else {
			capture confirm variable month 
			if !_rc {
				destring month, replace 
				confirm numeric variable month
				destring year, replace
				confirm numeric variable year
				gen ym = ym(year,month)
				format ym %tm 	
				drop year month 	
			}
			capture confirm variable ym 
			if !_rc {
				display in red "ym already created"
			}
			else {
				capture confirm variable reportmonth
				if !_rc {
					gen year = substr(reportmonth,6,4)
					destring year, replace 
					confirm numeric variable year 
					gen month = substr(reportmonth,3,3)
					replace month = "01" if month == "jan"
					replace month = "02" if month == "feb"
					replace month = "03" if month == "mar"
					replace month = "04" if month == "apr"
					replace month = "05" if month == "may"
					replace month = "06" if month == "jun"
					replace month = "07" if month == "jul"
					replace month = "08" if month == "aug"
					replace month = "09" if month == "sep"
					replace month = "10" if month == "oct"
					replace month = "11" if month == "nov"
					replace month = "12" if month == "dec"
					destring month, replace
					confirm numeric variable month
					drop reportmonth
					gen ym = ym(year,month)
					format ym %tm 	
					drop year month 	
				}		
			}
		}
	}
	
	assert !missing(ym)
	drop sfy 
	drop ffy 

	// lowercase county 
	replace county = strlower(county)
	
	// destring 
	foreach var of varlist _all {
	if !inlist("`var'","ym","county","date","reportmonth") {
		replace `var' = ustrregexra(`var',"BLANK","")
		destring `var', replace 
		confirm numeric variable `var'
	}
	}

	// drop statewide average 
	drop if strpos(county,"statewide average")
	replace county = "state totals" if county == "statewide total" | county == "statewide"

	// order 
	order county ym 
	sort county ym 

	// save 
	tempfile _`year_short'_churn
	save `_`year_short'_churn'

}

// append years 
foreach year_short of local year_short_list_churn {
	if `year_short' == `first_year_short' {
		use `_`year_short'_churn', clear
	}
	else {
		append using `_`year_short'_churn'
	}
}

// drop countycode for now; it's not throughout 
drop countycode

// drop statewide totals; data is not consistent enough
drop if county == "state totals"

// drop exact duplicates 
duplicates drop 

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order and sort 
order county ym 
sort county ym 
 
// drop vars I don't need 
drop reportmonth
drop date 

// save 
tempfile california_churn
save `california_churn'
save "${dir_root}/data/state_data/california/california_churn.dta", replace 


*/
/////////////////////
// ENROLLMENT DATA //
/////////////////////
/*

foreach year_short of local year_short_list {

	// display ym 
	display in red "`year'"

	// for file names
	clear
	set obs 1
	gen year_short = `year_short'
	gen year_short_plus1 = `year_short' + 1
	gen year = 2000 + `year_short'
	local year_short = year_short
	display in red "`year_short'"
	local year_short_plus1 = year_short_plus1
	display in red "`year_short_plus1'"
	local year = year
	display in red "`year'"

	////////////////////////
	// GET VARIABLE NAMES //
	////////////////////////

	// load data 
	import excel "${dir_root}/data/state_data/california/excel/DFA 256 - Food Stamp Program Participation and Benefit Issuances/DFA256FY`year_short'-`year_short_plus1'.xlsx", sheet("DataDictionary") allstring case(lower) firstrow clear 		

	// make firstrow varnames 
	foreach var of varlist _all {
		qui replace `var' = subinstr(`var', "`=char(9)'", " ", .) if _n == 1
		qui replace `var' = subinstr(`var', "`=char(10)'", " ", .) if _n == 1
		qui replace `var' = subinstr(`var', "`=char(13)'", " ", .) if _n == 1
		qui replace `var' = subinstr(`var', "`=char(14)'", " ", .) if _n == 1
		qui replace `var' = trim(`var')
		qui replace `var' = stritrim(`var')
		qui replace `var' = strlower(`var')
		rename `var' `=`var'[1]'
	}
	drop in 1
	
	// clean up vars 
	// item 
	split item, parse(".")
	drop item 
	drop item1
	rename item2 item 
	qui replace item = ustrregexra(item,"number of ","")

	// part
	qui replace part = "" if part == "a. participation during the month"
	qui replace part = "issuance_" if part == "b. issuances during the month"
	qui replace part = "vissuance_" if part == "c. value of benefit issuances during the month"
	// qui replace part = substr(part,1,1)
	*tab part 
	// remove parentheses
	foreach var in column item {
		qui replace `var' = ustrregexra(`var',"\-","")
		qui replace `var' = ustrregexra(`var',"\(","")
		qui replace `var' = ustrregexra(`var',"\)","")
		qui replace `var' = ustrregexra(`var',"/","")
		qui replace `var' = ustrregexra(`var',"\:","")
		qui replace `var' = ustrregexra(`var',"\'","")
		qui replace `var' = ustrregexra(`var',"\_","")
		qui replace `var' = ustrregexra(`var',"\,","")
		qui replace `var' = ustrregexra(`var'," ","")
		*qui replace `var' = ustrregexra(`var',"federalandstatepersons","fedstatepers")
		*qui replace `var' = ustrregexra(`var',"federalstatehouseholds","fedstatehhs")
		qui replace `var' = ustrregexra(`var',"persons","pers")
		qui replace `var' = ustrregexra(`var',"households","hhs")
		qui replace `var' = ustrregexra(`var',"federal","fed")
	}

	// column
	qui replace column = "pacf" if column == "a.publicassistance"
	qui replace column = "nacf" if column == "b.nonpublicassistance"
	qui replace column = "total" if missing(column) & missing(part)

	// generate variable name 
	qui gen varname = part + column + item 
	qui replace varname = stritrim(varname)
	qui replace varname = substr(varname,1,31)

	// initial varname 
	qui destring cell, replace 
	confirm numeric variable cell 
	qui replace cell = cell + 7 // since there are year variables to start 
	qui tostring cell, gen(v)
	qui replace v = "v" + v 

	// get text for renaming 
	display in red "`year_short'"
	list v varname

	rename varname varname_`year_short'

	// save
	*tempfile varnames2
	save "${dir_root}/data/state_data/california/varnames2_`year_short'.dta", replace


}

// load data 
foreach year_short of local year_short_list {

	// display ym 
	display in red "`year'"

	// for file names
	clear
	set obs 1
	gen year_short = `year_short'
	gen year_short_plus1 = `year_short' + 1
	gen year = 2000 + `year_short'
	local year_short = year_short
	display in red "`year_short'"
	local year_short_plus1 = year_short_plus1
	display in red "`year_short_plus1'"
	local year = year
	display in red "`year'"
	
	/////////////////
	// ACTUAL DATA //
	/////////////////

	if inrange(`year_short',10,14) {
		// load data 
		import excel "${dir_root}/data/state_data/california/excel/DFA 256 - Food Stamp Program Participation and Benefit Issuances/DFA256FY`year_short'-`year_short_plus1'.xls", sheet("FinalData") allstring case(lower) firstrow clear 
	}
	else if inrange(`year_short',16,19) {
		// load data 
		import excel "${dir_root}/data/state_data/california/excel/DFA 256 - Food Stamp Program Participation and Benefit Issuances/DFA256FY`year_short'-`year_short_plus1'.xlsx", sheet("Data") allstring case(lower) firstrow clear 		
	}
	else if inrange(`year_short',20,23) {
		// load data 
		import excel "${dir_root}/data/state_data/california/excel/DFA 256 - Food Stamp Program Participation and Benefit Issuances/DFA256FY`year_short'-`year_short_plus1'.xlsx", sheet("Data_External") allstring case(lower) firstrow clear 		
	}

	// drop empty variables
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	drop in 1

	// one extra blank var in FY 2020
	if inlist(`year_short',20,21,22,23) { 
		drop v3 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
	}

	// rename variables
	describe, varlist
	if inlist(`year_short',20) {
		assert `r(k)' == 35
	}
	else if inlist(`year_short',21,22,23) { 
		assert `r(k)' == 36
	}
	else {
		assert `r(k)' == 37
	}
	else if `year_short' == 23 {
		assert `r(N)' == 181 // this will change as more data is added 
	}
	else {
		assert `r(N)' == 712	
	}

	if inlist(`year_short',16,17,18,19) {
		rename v1 date 
		rename v2 month 
		rename v3 year 
		rename v4 county
		rename v5 countycode
		rename v6 sfy 
		rename v7 ffy 
	}
	else if inlist(`year_short',20) {
		rename v1 date 
		rename v2 county 
		rename v3 sfy 
		rename v4 ffy 
		rename v5 reportmonth 
	}
	else if inlist(`year_short',21,22,23) {
		rename v1 date 
		rename v2 county
		rename v3 countycode 
		rename v4 sfy 
		rename v5 ffy 
		rename v6 reportmonth
	}
	
	// Note: reordering was done relative to what is in the varnames 
	if inlist(`year_short',16,17,18,19) {
		rename v8	pacffedhhs
		rename v9	pacffedstatehhs
		rename v10	pacfstatehhs
		rename v11	nacffedhhs
		rename v12	nacffedstatehhs
		rename v13	nacfstatehhs
		rename v14	totalhhsfed
		rename v15	totalhhsfedstate
		rename v16	totalhhsstate
		rename v17	pacfpersinfedonlyhhs
		rename v18	nacfpersinfedonlyhhs
		rename v19	totalpersinfedonlyhhs
		rename v20	pacffedstatepersinfedstatehhsfe
		rename v21	pacffedstatepersinfedstatehhsst
		rename v22	nacffedstatepersinfedstatehhsfe
		rename v23	nacffedstatepersinfedstatehhsst
		rename v24	totalfedstatepersinfedstatehhsf
		rename v25	totalfedstatepersinfedstatehhss
		rename v26	pacfpersinstateonlyhhs
		rename v27	nacfpersinstateonlyhhs
		rename v28	totalpersinstateonlyhhs
		rename v29	issuance_mail
		rename v30	issuance_contractedoverthecount
		rename v31	issuance_overthecounter
		rename v32	issuance_ebtissuances
		rename v33	issuance_total
		rename v34	issuance_ebtconvertedtocoupons
		rename v35	vissuance_valueoffedbenefiti
		rename v36	vissuance_valueofstatebenefitis
		rename v37	vissuance_total
	}
	else if inlist(`year_short',20) {
		rename v6	pacffedhhs
		rename v7	pacffedstatehhs
		rename v8	pacfstatehhs
		rename v9	nacffedhhs
		rename v10	nacffedstatehhs
		rename v11	nacfstatehhs
		rename v12	totalhhsfed
		rename v13	totalhhsfedstate
		rename v14	totalhhsstate
		rename v15	pacfpersinfedonlyhhs
		rename v16	nacfpersinfedonlyhhs
		rename v17	totalpersinfedonlyhhs
		rename v18	pacffedstatepersinfedstatehhsfe
		rename v19	pacffedstatepersinfedstatehhsst
		rename v20	nacffedstatepersinfedstatehhsfe
		rename v21	nacffedstatepersinfedstatehhsst
		rename v22	totalfedstatepersinfedstatehhsf
		rename v23	totalfedstatepersinfedstatehhss
		rename v24	pacfpersinstateonlyhhs
		rename v25	nacfpersinstateonlyhhs
		rename v26	totalpersinstateonlyhhs
		rename v27	issuance_mail
		rename v28	issuance_contractedoverthecount
		rename v29	issuance_overthecounter
		rename v30	issuance_ebtissuances
		rename v31	issuance_total
		rename v32	issuance_ebtconvertedtocoupons
		rename v33	vissuance_valueoffedbenefiti
		rename v34	vissuance_valueofstatebenefitis
		rename v35	vissuance_total
	}	
	else if inlist(`year_short',21,22,23) {
		rename v7	pacffedhhs
		rename v8	pacffedstatehhs
		rename v9	pacfstatehhs
		rename v10	nacffedhhs
		rename v11	nacffedstatehhs
		rename v12	nacfstatehhs
		rename v13	totalhhsfed
		rename v14	totalhhsfedstate
		rename v15	totalhhsstate
		rename v16	pacfpersinfedonlyhhs
		rename v17	nacfpersinfedonlyhhs
		rename v18	totalpersinfedonlyhhs
		rename v19	pacffedstatepersinfedstatehhsfe
		rename v20	pacffedstatepersinfedstatehhsst
		rename v21	nacffedstatepersinfedstatehhsfe
		rename v22	nacffedstatepersinfedstatehhsst
		rename v23	totalfedstatepersinfedstatehhsf
		rename v24	totalfedstatepersinfedstatehhss
		rename v25	pacfpersinstateonlyhhs
		rename v26	nacfpersinstateonlyhhs
		rename v27	totalpersinstateonlyhhs
		rename v28	issuance_mail
		rename v29	issuance_contractedoverthecount
		rename v30	issuance_overthecounter
		rename v31	issuance_ebtissuances
		rename v32	issuance_total
		rename v33	issuance_ebtconvertedtocoupons
		rename v34	vissuance_valueoffedbenefiti
		rename v35	vissuance_valueofstatebenefitis
		rename v36	vissuance_total
	}

	// rename vars 
*	renamefrom using "${dir_root}/data/state_data/california/varnames2_`year_short'.dta", filetype(stata) raw(v) clean(varname) keepx
	
	// drop unneeded vars 
	drop pacf*
	drop nacf*
	foreach var in issuance_contractedoverthecount issuance_overthecounter  {
		assert inlist(`var',"0","") if !inlist(_n,1,2,3,4)
		drop `var'
	}

	// combine same vars 
	**assert issuance_ebtissuances == issuance_total if !inlist(_n,1,2,3,4) & !inlist(issuance_ebtissuances,"BLANK")
	**drop issuance_ebtissuances
	rename issuance_total ebtissuance

	// rename main vars 
	rename vissuance_valueoffedbenefiti issuance_fed
	rename vissuance_valueofstatebenefitis issuance_state
	rename vissuance_total issuance

	// drop last heading rows
	drop in 1
	drop in 1
	drop in 1
	drop in 1	
	
	// destring
	// Cells that could identify an individual with a value of less than 11 have been replaced with a “*” to comply with the CDSS Data De-identification Guidelines .

	foreach v in totalhhsfed totalhhsfedstate totalhhsstate totalpersinfedonlyhhs totalfedstatepersinfedstatehhsf totalfedstatepersinfedstatehhss totalpersinstateonlyhhs ebtissuance issuance_fed issuance_state issuance issuance_mail issuance_ebtconvertedtocoupons issuance_ebtissuances {
		// censor flag
		gen `v'f = 0
		replace `v'f = 1 if `v' == "\*"
		replace `v' = "10" if `v' == "\*"
	
		replace `v' = ustrregexra(`v',"BLANK","")
		destring `v', replace ignore("*")
		confirm numeric variable `v'
	}

	// generate main vars 
	egen households = rowtotal(totalhhsfed totalhhsfedstate totalhhsstate)
	egen persons = rowtotal(totalpersinfedonlyhhs totalfedstatepersinfedstatehhsf totalfedstatepersinfedstatehhss totalpersinstateonlyhhs)
	egen householdsf = rowmax(totalhhsfedf totalhhsfedstatef totalhhsstatef)
	egen personsf = rowmax(totalpersinfedonlyhhsf totalfedstatepersinfedstatehhsff totalfedstatepersinfedstatehhssf totalpersinstateonlyhhsf)
	drop totalhhsfed totalhhsfedf
	drop totalhhsfedstate totalhhsfedstatef
	drop totalhhsstate totalhhsstatef
	drop totalpersinfedonlyhhs totalpersinfedonlyhhsf
	drop totalfedstatepersinfedstatehhsf totalfedstatepersinfedstatehhsff
	drop totalfedstatepersinfedstatehhss totalfedstatepersinfedstatehhssf
	drop totalpersinstateonlyhhs totalpersinstateonlyhhsf
	
	// clean up date 
	capture confirm variable year 
	capture confirm variable month 
	if !_rc {
		display in red "month var already created"
		destring month, replace 
		destring year, replace 
		confirm numeric variable month 
		confirm numeric variable year 
		gen ym = ym(year,month)
		format ym %tm 
		drop year month 
	}
	capture confirm variable ym 
	if !_rc {

	}
	else {
		capture confirm variable date 
		if !_rc {
			gen year = substr(date,6,4)
			destring year, replace 
			gen month = substr(reportmonth,3,3)
			replace month = "01" if month == "jan"
			replace month = "02" if month == "feb"
			replace month = "03" if month == "mar"
			replace month = "04" if month == "apr"
			replace month = "05" if month == "may"
			replace month = "06" if month == "jun"
			replace month = "07" if month == "jul"
			replace month = "08" if month == "aug"
			replace month = "09" if month == "sep"
			replace month = "10" if month == "oct"
			replace month = "11" if month == "nov"
			replace month = "12" if month == "dec"
			destring month, replace
			confirm numeric variable month
			drop date
			gen ym = ym(year,month)
			format ym %tm 
			drop year month 	
		}
		capture confirm variable ym 
		if !_rc {
			display in red "ym already created"
		}
		else {
			capture confirm variable month 
			if !_rc {
				destring month, replace 
				confirm numeric variable month
				destring year, replace
				confirm numeric variable year
				gen ym = ym(year,month)
				format ym %tm 	
				drop year month 	
			}
			capture confirm variable ym 
			if !_rc {
				display in red "ym already created"
			}
			else {
				capture confirm variable reportmonth
				if !_rc {
					gen year = substr(reportmonth,6,4)
					destring year, replace 
					confirm numeric variable year 
					gen month = substr(reportmonth,3,3)
					replace month = "01" if month == "jan"
					replace month = "02" if month == "feb"
					replace month = "03" if month == "mar"
					replace month = "04" if month == "apr"
					replace month = "05" if month == "may"
					replace month = "06" if month == "jun"
					replace month = "07" if month == "jul"
					replace month = "08" if month == "aug"
					replace month = "09" if month == "sep"
					replace month = "10" if month == "oct"
					replace month = "11" if month == "nov"
					replace month = "12" if month == "dec"
					destring month, replace
					confirm numeric variable month
					drop reportmonth
					gen ym = ym(year,month)
					format ym %tm 	
					drop year month 	
				}		
			}
		}
	}
	
	assert !missing(ym)
	drop sfy 
	drop ffy 

	// lowercase county 
	replace county = strlower(county)
	
	// drop statewide average 
	drop if strpos(county,"statewide average")
	replace county = "state totals" if county == "statewide total" | county == "statewide"

	// order 
	order county ym 
	sort county ym 

	// save 
	tempfile _`year_short'
	save `_`year_short''

}

// append years 
foreach year_short of local year_short_list {
	if `year_short' == `first_year_short' {
		use `_`year_short'', clear
	}
	else {
		append using `_`year_short''
	}
}

// drop countycode for now; it's not throughout 
drop countycode

// drop statewide totals; data is not consistent enough
drop if county == "state totals"

// drop exact duplicates 
duplicates drop 

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order and sort 
order county ym 
sort county ym 
 
// save 
tempfile california_enrollment
save `california_enrollment'
save "${dir_root}/data/state_data/california/california_enrollment.dta", replace 
*/

**************************************************************************
**************************************************************************
**************************************************************************
**************************************************************************
**************************************************************************
*/
/*
//////////////////////////
// APPLICATION ETC DATA //
//////////////////////////

foreach year_short of local year_short_list {

	// display ym 
	display in red "`year'"

	// for file names
	clear
	set obs 1
	gen year_short = `year_short'
	gen year_short_plus1 = `year_short' + 1
	gen year = 2000 + `year_short'
	local year_short = year_short
	display in red "`year_short'"
	local year_short_plus1 = year_short_plus1
	display in red "`year_short_plus1'"
	local year = year
	display in red "`year'"

	////////////////////////
	// GET VARIABLE NAMES //
	////////////////////////

	// load data 
	import excel "${dir_root}/data/state_data/california/excel/CF 296 - CalFresh Monthly Caseload/CF296FY`year_short'-`year_short_plus1'.xlsx", sheet("DataDictionary") allstring case(lower) firstrow clear 		

	// make firstrow varnames 
	foreach var of varlist _all {
		qui replace `var' = subinstr(`var', "`=char(9)'", " ", .) if _n == 1
		qui replace `var' = subinstr(`var', "`=char(10)'", " ", .) if _n == 1
		qui replace `var' = subinstr(`var', "`=char(13)'", " ", .) if _n == 1
		qui replace `var' = subinstr(`var', "`=char(14)'", " ", .) if _n == 1
		qui replace `var' = trim(`var')
		qui replace `var' = stritrim(`var')
		qui replace `var' = strlower(`var')
		rename `var' `=`var'[1]'
	}
	drop in 1
	
	// clean up vars 
	// item 
	split item, parse(".")
	drop item 
	drop item1
	rename item2 item 
	qui replace item = ustrregexra(item,"brought forward at the ","brought at ")

	// column
	qui replace column = "pacf" if column == "a. pacf"
	qui replace column = "nacf" if column == "b. nacf"
	qui replace column = "total" if column == "c. total"
	// part 
	qui replace part = substr(part,1,1)
	*tab part 
	// remove parentheses
	foreach var in column item {
		qui replace `var' = ustrregexra(`var',"\-","")
		qui replace `var' = ustrregexra(`var',"\(","")
		qui replace `var' = ustrregexra(`var',"\)","")
		qui replace `var' = ustrregexra(`var',"/","")
		qui replace `var' = ustrregexra(`var',"\:","")
		qui replace `var' = ustrregexra(`var',"\'","")
		qui replace `var' = ustrregexra(`var',"\_","")
		qui replace `var' = ustrregexra(`var',"\,","")
		qui replace `var' = ustrregexra(`var'," ","")
	}

	// generate variable name 
	qui gen varname = part + column + item 
	qui replace varname = stritrim(varname)
	qui replace varname = substr(varname,1,32)

	// initial varname 
	qui destring cell, replace 
	confirm numeric variable cell 
	qui replace cell = cell + 6 // since there are year variables to start 
	qui tostring cell, gen(v)
	qui replace v = "v" + v 

	// get text for renaming 
	display in red "`year_short'"
	list v varname

	rename varname varname_`year_short'

	// save
	*tempfile varnames
	save "${dir_root}/data/state_data/california/varnames_`year_short'.dta", replace


}
/*
// check consistency of variable names 
foreach year_short of local year_short_list {
	if `year_short' == `first_year_short' {
		use "${dir_root}/data/state_data/california/varnames_`year_short'.dta", clear 
	}
	else {
		merge 1:1 v using "${dir_root}/data/state_data/california/varnames_`year_short'.dta", keepusing(varname_`year_short')
		drop _m 
	}
}

assert varname_16 == varname_17
assert varname_16 == varname_18
assert varname_16 == varname_19
assert varname_16 == varname_20
assert varname_16 == varname_21

*check
*/

foreach year_short of local year_short_list {

	// display ym 
	display in red "`year'"

	// for file names
	clear
	set obs 1
	gen year_short = `year_short'
	gen year_short_plus1 = `year_short' + 1
	gen year = 2000 + `year_short'
	local year_short = year_short
	display in red "`year_short'"
	local year_short_plus1 = year_short_plus1
	display in red "`year_short_plus1'"
	local year = year
	display in red "`year'"
	
	/////////////////
	// ACTUAL DATA //
	/////////////////

	if inrange(`year_short',10,14) {
		// load data 
		import excel "${dir_root}/data/state_data/california/excel/CF 296 - CalFresh Monthly Caseload/DFA296FY`year_short'-`year_short_plus1'.xls", sheet("FinalData") allstring case(lower) firstrow clear 
	}
	else if inrange(`year_short',16,19) {
		// load data 
		import excel "${dir_root}/data/state_data/california/excel/CF 296 - CalFresh Monthly Caseload/CF296FY`year_short'-`year_short_plus1'.xlsx", sheet("FinalData") allstring case(lower) firstrow clear 		
	}
	else if inrange(`year_short',20,23) {
		// load data 
		import excel "${dir_root}/data/state_data/california/excel/CF 296 - CalFresh Monthly Caseload/CF296FY`year_short'-`year_short_plus1'.xlsx", sheet("Data_External") allstring case(lower) firstrow clear 		
	}

	// drop empty variables
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	drop in 1
*	drop in 1
*	drop in 1	

	// one extra blank var in FY 2020
	if inlist(`year_short',20,21,22,23) {
		drop v3 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
	}

	// rename variables
	describe, varlist
	assert `r(k)' == 129
	if `year_short' == 23 {
		assert `r(N)' == 475 // should change
	}
	else {
		assert `r(N)' == 711	
	}
	
	if inlist(`year_short',16,17,18,19) {
		rename v1 date 
		rename v2 month 
		rename v3 year 
		rename v4 county
		rename v5 sfy 
		rename v6 ffy 
	}
	else if inlist(`year_short',20,21,22,23) {
		rename v1 date 
		rename v2 county
		rename v3 countycode 
		rename v4 sfy 
		rename v5 ffy 
		rename v6 reportmonth
	}
	
	rename v7   atotalapplicationsreceivedduring 
    rename v8   atotalonlineapplicationsreceived 
    rename v9   atotalapplicationsdisposedofduri 
   	rename v10         atotalapplicationsapproved 
   	rename v11   apacf1applicationsapprovedinover 
   	rename v12   anacf1applicationsapprovedinover 
   	rename v13   atotal1applicationsapprovedinove 
   	rename v14   apacfapplicationsdenieditem2b1pl 
   	rename v15   anacfapplicationsdenieditem2b1pl 
  	rename v16   atotalapplicationsdenieditem2b1p 
  	rename v17   apacf1applicationsdeniedbecaused 
  	rename v18   anacf1applicationsdeniedbecaused 
  	rename v19   atotal1applicationsdeniedbecause 
  	rename v20   apacf2applicationsdeniedforproce 
  	rename v21   anacf2applicationsdeniedforproce 
  	rename v22   atotal2applicationsdeniedforproc 
  	rename v23   apacf3applicationsdeniedinover30 
  	rename v24   anacf3applicationsdeniedinover30 
  	rename v25   atotal3applicationsdeniedinover3 
  	rename v26         apacfapplicationswithdrawn 
  	rename v27         anacfapplicationswithdrawn 
  	rename v28        atotalapplicationswithdrawn 
  	rename v29   bpacfoftheapplicationsdisposedof 
  	rename v30   bnacfoftheapplicationsdisposedof 
  	rename v31   btotaloftheapplicationsdisposedo 
  	rename v32   bpacffoundentitledtoexpeditedser 
  	rename v33   bnacffoundentitledtoexpeditedser 
  	rename v34   btotalfoundentitledtoexpeditedse 
  	rename v35     bpacf1benefitsissuedin1to3days 
  	rename v36     bnacf1benefitsissuedin1to3days 
  	rename v37    btotal1benefitsissuedin1to3days 
  	rename v38     bpacf2benefitsissuedin4to7days 
  	rename v39     bnacf2benefitsissuedin4to7days 
  	rename v40    btotal2benefitsissuedin4to7days 
  	rename v41    bpacf3benefitsissuedinover7days 
  	rename v42    bnacf3benefitsissuedinover7days 
  	rename v43   btotal3benefitsissuedinover7days 
  	rename v44   bpacffoundnotentitledtoexpedited 
  	rename v45   bnacffoundnotentitledtoexpedited 
  	rename v46   btotalfoundnotentitledtoexpedite 
  	rename v47   cpacfcasesbroughtatbeginningofth 
  	rename v48   cnacfcasesbroughtatbeginningofth 
  	rename v49   ctotalcasesbroughtatbeginningoft 
  	rename v50   cpacfitem8fromlastmonthsreportas 
  	rename v51   cnacfitem8fromlastmonthsreportas 
  	rename v52   ctotalitem8fromlastmonthsreporta 
  	rename v53                    cpacfadjustment 
  	rename v54                    cnacfadjustment 
  	rename v55                   ctotaladjustment 
  	rename v56      cpacfcasesaddedduringthemonth 
  	rename v57      cnacfcasesaddedduringthemonth 
  	rename v58     ctotalcasesaddedduringthemonth 
  	rename v59   cpacffederalapplicationsapproved 
  	rename v60   cpacffederalstateapplicationsapp 
  	rename v61     cpacfstateapplicationsapproved 
  	rename v62   cnacffederalapplicationsapproved 
  	rename v63   cnacffederalstateapplicationsapp 
  	rename v64     cnacfstateapplicationsapproved 
  	rename v65          cpacfapplicationsapproved 
  	rename v66          cnacfapplicationsapproved 
  	rename v67         ctotalapplicationsapproved 
  	rename v68   cpacfchangeinasssistancestatusfr 
  	rename v69   cnacfchangeinasssistancestatusfr 
  	rename v70   ctotalchangeinasssistancestatusf 
  	rename v71          cpacfintercountytransfers 
  	rename v72          cnacfintercountytransfers 
  	rename v73         ctotalintercountytransfers 
  	rename v74   cpacfcaseswitheligibilityreinsta 
  	rename v75   cnacfcaseswitheligibilityreinsta 
  	rename v76   ctotalcaseswitheligibilityreinst 
  	rename v77                cpacfotherapprovals 
  	rename v78                cnacfotherapprovals 
  	rename v79               ctotalotherapprovals 
  	rename v80   cpacftotalcasesopenduringthemont 
  	rename v81   cnacftotalcasesopenduringthemont 
  	rename v82   ctotaltotalcasesopenduringthemon 
  	rename v83              cpacfpurefederalcases 
  	rename v84              cnacfpurefederalcases 
  	rename v85             ctotalpurefederalcases 
  	rename v86   cfederalpersons1federalpersonsin 
  	rename v87   cstatepersonssinglefederalstatec 
  	rename v88   cstatepersonsfamiliesfederalstat 
  	rename v89     cpacffederalstatecombinedcases 
  	rename v90     cnacffederalstatecombinedcases 
  	rename v91    ctotalfederalstatecombinedcases 
  	rename v92   cstatepersonssinglepurestatecase 
  	rename v93   cstatepersonsfamiliespurestateca 
  	rename v94                cpacfpurestatecases 
  	rename v95                cnacfpurestatecases 
  	rename v96               ctotalpurestatecases 
  	rename v97   cpacfcasesdiscontinuedduringthem 
  	rename v98   cnacfcasesdiscontinuedduringthem 
  	rename v99   ctotalcasesdiscontinuedduringthe 
 	rename v100   cpacfhouseholdsdiscontinueddueto 
 	rename v101   cnacfhouseholdsdiscontinueddueto 
 	rename v102   ctotalhouseholdsdiscontinuedduet 
 	rename v103   cpacfcasesbroughtatendofthemonth 
 	rename v104   cnacfcasesbroughtatendofthemonth 
 	rename v105   ctotalcasesbroughtatendofthemont 
	rename v106   dpacfrecertificationsdisposedofd 
	rename v107   dnacfrecertificationsdisposedofd 
	rename v108   dtotalrecertificationsdisposedof 
	rename v109   dpacffederaldeterminedcontinuing 
	rename v110   dpacffederalstatedeterminedconti 
	rename v111   dpacfstatedeterminedcontinuingel 
	rename v112   dnacffederaldeterminedcontinuing 
	rename v113   dnacffederalstatedeterminedconti 
	rename v114   dnacfstatedeterminedcontinuingel 
	rename v115   dpacfdeterminedcontinuingeligibl 
	rename v116   dnacfdeterminedcontinuingeligibl 
	rename v117   dtotaldeterminedcontinuingeligib 
	rename v118   dpacffederaldeterminedineligible 
	rename v119   dpacffederalstatedeterminedineli 
	rename v120     dpacfstatedeterminedineligible 
	rename v121   dnacffederaldeterminedineligible 
	rename v122   dnacffederalstatedeterminedineli 
	rename v123     dnacfstatedeterminedineligible 
	rename v124          dpacfdeterminedineligible 
	rename v125          dnacfdeterminedineligible 
	rename v126         dtotaldeterminedineligible 
	rename v127   dpacfoverduerecertificationsduri 
	rename v128   dnacfoverduerecertificationsduri 
	rename v129   dtotaloverduerecertificationsdur 

	// rename vars 
*	renamefrom using "${dir_root}/data/state_data/california/varnames_`year_short'.dta", filetype(stata) raw(v) clean(varname) keepx

	// drop unneeded vars 
	drop ?pacf*
	drop ?nacf*

	// rename main vars 
	rename atotalapplicationsreceivedduring apps_received
	rename atotalonlineapplicationsreceived apps_received_online
	rename atotalapplicationsdisposedofduri apps_disposed // in this case, not the same as received, although they should be close
	rename atotalapplicationsapproved 		apps_approved
	rename atotalapplicationsdenieditem2b1p apps_denied 
	rename atotalapplicationswithdrawn 		apps_withdrawn
	rename btotaloftheapplicationsdisposedo apps_expedited
	rename atotal1applicationsapprovedinove apps_nottimely
  	rename atotal1applicationsdeniedbecause apps_denied_reason_inelig
  	rename atotal2applicationsdeniedforproc apps_denied_reason_procedural
  	rename atotal3applicationsdeniedinover3 apps_denied_nottimely
  	rename btotalfoundentitledtoexpeditedse apps_expedited_elig
  	rename btotal1benefitsissuedin1to3days  apps_expedited_elig_days1_3
  	rename btotal2benefitsissuedin4to7days  apps_expedited_elig_days4_7
  	rename btotal3benefitsissuedinover7days apps_expedited_elig_days8
  	rename btotalfoundnotentitledtoexpedite apps_expedited_notelig 
  	rename ctotalcasesbroughtatbeginningoft households_carryover_start
  	rename ctotalitem8fromlastmonthsreporta households_carryover_start_i8
  	rename ctotaladjustment 				households_carryover_start_adj
  	rename ctotalcasesaddedduringthemonth   households_new
  	rename ctotalapplicationsapproved 		households_new_apps
  	rename ctotalchangeinasssistancestatusf households_new_change_pacfnacf
  	rename ctotalintercountytransfers       households_new_change_county
  	rename ctotalcaseswitheligibilityreinst households_new_reinstated
  	rename ctotalotherapprovals             households_new_other 
  	rename ctotaltotalcasesopenduringthemon households
  	rename ctotalpurefederalcases 			households_federal_pure
  	rename cfederalpersons1federalpersonsin households_federal_total
  	rename cstatepersonssinglefederalstatec households_federalstate_single
  	rename cstatepersonsfamiliesfederalstat households_federalstate_family
  	rename ctotalfederalstatecombinedcases  households_federalstate 
  	rename cstatepersonssinglepurestatecase households_state_single
  	rename cstatepersonsfamiliespurestateca households_state_family
  	rename ctotalpurestatecases 			households_state_pure
  	rename ctotalcasesdiscontinuedduringthe households_discontinued
 	rename ctotalhouseholdsdiscontinuedduet households_discontinued_exp
 	rename ctotalcasesbroughtatendofthemont households_carryover_end
	rename dtotalrecertificationsdisposedof recerts_disposed
	rename dtotaldeterminedcontinuingeligib recerts_elig
	rename dtotaldeterminedineligible       recerts_inelig
	rename dtotaloverduerecertificationsdur recerts_overdue

	// drop last heading rows
	drop in 1
	drop in 1
	drop in 1

	// destring
	// Cells that could identify an individual with a value of less than 11 have been replaced with a “*” to comply with the CDSS Data De-identification Guidelines .

	*foreach v in households individuals issuance households_npa households_pa individuals_npa individuals_pa {
	foreach v of varlist apps_* {	
		// censor flag
		gen `v'_f = 0
		replace `v'_f = 1 if `v' == "\*"
		replace `v' = "10" if `v' == "\*"
	
		destring `v', replace ignore("*")
		confirm numeric variable `v'
	}
	foreach v of varlist households* {
		// censor flag
		gen `v'_f = 0
		replace `v'_f = 1 if `v' == "\*"
		replace `v' = "10" if `v' == "\*"

		destring `v', replace ignore("*")
		confirm numeric variable `v'	
	}
	foreach v of varlist recerts* {
		// censor flag
		gen `v'_f = 0
		replace `v'_f = 1 if `v' == "\*"
		replace `v' = "10" if `v' == "\*"

		destring `v', replace ignore("*")
		confirm numeric variable `v'
	}
	
	// clean up date 
	capture confirm variable year 
	capture confirm variable month 
	if !_rc {
		display in red "month var already created"
		destring month, replace 
		destring year, replace 
		confirm numeric variable month 
		confirm numeric variable year 
		gen ym = ym(year,month)
		format ym %tm 
		drop year month 
	}
	capture confirm variable ym 
	if !_rc {

	}
	else {
		capture confirm variable date 
		if !_rc {
			gen year = substr(date,6,4)
			destring year, replace 
			gen month = substr(reportmonth,3,3)
			replace month = "01" if month == "jan"
			replace month = "02" if month == "feb"
			replace month = "03" if month == "mar"
			replace month = "04" if month == "apr"
			replace month = "05" if month == "may"
			replace month = "06" if month == "jun"
			replace month = "07" if month == "jul"
			replace month = "08" if month == "aug"
			replace month = "09" if month == "sep"
			replace month = "10" if month == "oct"
			replace month = "11" if month == "nov"
			replace month = "12" if month == "dec"
			destring month, replace
			confirm numeric variable month
			drop date
			gen ym = ym(year,month)
			format ym %tm 
			drop year month 	
		}
		capture confirm variable ym 
		if !_rc {
			display in red "ym already created"
		}
		else {
			capture confirm variable month 
			if !_rc {
				destring month, replace 
				confirm numeric variable month
				destring year, replace
				confirm numeric variable year
				gen ym = ym(year,month)
				format ym %tm 	
				drop year month 	
			}
			capture confirm variable ym 
			if !_rc {
				display in red "ym already created"
			}
			else {
				capture confirm variable reportmonth
				if !_rc {
					gen year = substr(reportmonth,6,4)
					destring year, replace 
					confirm numeric variable year 
					gen month = substr(reportmonth,3,3)
					replace month = "01" if month == "jan"
					replace month = "02" if month == "feb"
					replace month = "03" if month == "mar"
					replace month = "04" if month == "apr"
					replace month = "05" if month == "may"
					replace month = "06" if month == "jun"
					replace month = "07" if month == "jul"
					replace month = "08" if month == "aug"
					replace month = "09" if month == "sep"
					replace month = "10" if month == "oct"
					replace month = "11" if month == "nov"
					replace month = "12" if month == "dec"
					destring month, replace
					confirm numeric variable month
					drop reportmonth
					gen ym = ym(year,month)
					format ym %tm 	
					drop year month 	
				}		
			}
		}
	}
	
	assert !missing(ym)
	drop sfy 
	drop ffy 

	// lowercase county 
	replace county = strlower(county)
	
	// drop statewide average 
	drop if strpos(county,"statewide average")
	replace county = "state totals" if county == "statewide total" | county == "statewide"

	// order 
	order county ym 
	sort county ym 

	// save 
	tempfile _`year_short'
	save `_`year_short''

}

// append years 
foreach year_short of local year_short_list {
	if `year_short' == `first_year_short' {
		use `_`year_short'', clear
	}
	else {
		append using `_`year_short''
	}
}

// drop countycode for now; it's not throughout 
drop countycode

// drop statewide totals; data is not consistent enough
drop if county == "state totals"

// drop exact duplicates 
duplicates drop 

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order and sort 
order county ym // issuance households individuals households_npa individuals_npa households_pa individuals_pa
sort county ym 
 
// rename var to avoid conflict 
rename households householdsA 
rename households_f householdsA_f

// IMPUTE APPLICATIONS DENIED FOR PLACES WHERE IT'S CENSORED 

// this is the calculus for most observations = (3828-838)/3828 = 78 percent of observations
capture noisily assert apps_approved + apps_denied + apps_withdrawn == apps_disposed

// since other state's data does not include withdrawls, combine withdrawals into denials 
// rename og vars 
foreach var in apps_approved apps_denied apps_withdrawn {
	rename `var' `var'_og	
}

// appropriately mark zeros 
// manual 
replace apps_disposed = 0 if missing(apps_disposed) & ((county == "alpine" & ym == ym(2018,4)) | (county == "sierra" & ym == ym(2021,4)))

// mark complete vs. incomplete observations 
gen miss_none 				= (!missing(apps_approved_og) & !missing(apps_denied_og) & !missing(apps_withdrawn_og))
gen miss_approved_only 		= ( missing(apps_approved_og) & !missing(apps_denied_og) & !missing(apps_withdrawn_og))
gen miss_denied_only 		= (!missing(apps_approved_og) &  missing(apps_denied_og) & !missing(apps_withdrawn_og))
gen miss_withdrawn_only 	= (!missing(apps_approved_og) & !missing(apps_denied_og) &  missing(apps_withdrawn_og))
gen miss_denied_withdrawn 	= (!missing(apps_approved_og) &  missing(apps_denied_og) &  missing(apps_withdrawn_og))
gen miss_approved_withdrawn = ( missing(apps_approved_og) & !missing(apps_denied_og) &  missing(apps_withdrawn_og))
gen miss_approved_denied 	= ( missing(apps_approved_og) &  missing(apps_denied_og) & !missing(apps_withdrawn_og))
gen miss_all 				= ( missing(apps_approved_og) &  missing(apps_denied_og) &  missing(apps_withdrawn_og))
gen temp_miss_sum = miss_none + miss_approved_only + miss_denied_only + miss_withdrawn_only + miss_denied_withdrawn + miss_approved_withdrawn + miss_approved_denied + miss_all
assert temp_miss_sum == 1

// since other state's data does not include withdrawls, combine withdrawals into denials 
// denied apps 
gen apps_denied = .
replace apps_denied = apps_denied_og + apps_withdrawn_og	if miss_none == 1 | miss_approved_only == 1
replace apps_denied = apps_disposed - apps_approved_og 		if miss_denied_withdrawn == 1 | miss_denied_only == 1 | miss_withdrawn_only == 1
replace apps_denied = apps_denied_og  						if miss_approved_withdrawn == 1
replace apps_denied = apps_withdrawn_og						if miss_approved_denied == 1
assert !missing(apps_denied) if miss_all != 1

// approved apps 
gen apps_approved = apps_approved_og 
replace apps_approved = apps_disposed - apps_denied_og if missing(apps_approved)
assert !missing(apps_denied) if miss_all != 1

// save 
tempfile california_detail
save `california_detail'
save "${dir_root}/data/state_data/california/california_detail.dta", replace 
*/

****************************************************************************************
****************************************************************************************

// merge two datasets 
use "${dir_root}/data/state_data/california/california_detail.dta", clear 
merge 1:1 county ym using "${dir_root}/data/state_data/california/california_enrollment.dta", update replace

// check merge 
assert inlist(_m,2,3)
assert inrange(ym,ym(2022,1),ym(2022,6)) if _m == 2
drop _m 

// merge in churn data 
merge 1:1 county ym using "${dir_root}/data/state_data/california/california_churn.dta", update replace

// check merge 
assert inlist(_m,1,3)
assert inrange(ym,ym(2016,7),ym(2020,12)) | inlist(ym,ym(2021,1),ym(2023,5),ym(2023,6),ym(2024,2)) if _m == 1 
drop _m 

// order and sort 
order county ym // issuance households individuals households_npa individuals_npa households_pa individuals_pa
sort county ym 

// save 
save "${dir_root}/data/state_data/california/california.dta", replace 

chgeck 


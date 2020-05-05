global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/nebraska"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local ym_start 					= ym(2015,3)
local ym_end 					= ym(2020,3)

**KP: snap not properly imported for ym(2019,4)
**KP: 2019m6 snap is 2018m7-2019m6, medicaid is 2018m6-2019m5, so double check if numbers match up

*********************************************************************
/*
forvalues ym = `ym_start'(1)`ym_end' {

	display in red "year and month `ym'"

	if inlist(`ym',ym(2019,4),ym(2019,5)) {
		local datalist "medicaid"
	}
	else {
		local datalist "snap medicaid"
	}

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

	// import 
	import excel using "${dir_root}/excel/`year'/`monthname' `year'.xlsx", allstring firstrow case(lower) clear
	
	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	drop if strpos(v1,"Nebraska - Medicaid Enrollment")
	drop if strpos(v1,"300,000")
	drop if strpos(v1,"Children and Families Enrollment") & strpos(v1,"Aged and Disabled Enrollment")

	foreach data in `datalist' {

		display in red "`data'"

		// preserve 
		preserve 

		if "`data'" == "snap" {
			// keep data tables
			#delimit ;
			keep if 
			strpos(v1,"Economic Assistance Enrollment") |
			strpos(v1,"SNAP (food stamp) Households") |
			strpos(v1,"SNAP (food stamp) Individuals") |
			strpos(v1,"Aid to Dependent (ADC) families") |
			strpos(v1,"Children in Child Care Subsidy") 
			;
			#delimit cr 

			// cleanup again 
			dropmiss, force 
			dropmiss, obs force 
			describe, varlist 
			rename (`r(varlist)') (v#), addnumber

			// assert shape of data 
			if inlist(`ym',ym(2020,2)) {
				assert r(k) == 12
			}
			else {
				assert r(k) == 13 
			}
			assert r(N) == 5 

			// fix error in data 
			if `ym' == ym(2018,7) {
				replace v13 = "Jul-18" if v13 == "Aug-18"
			}

			// transpose data, including new variable names first 
			gen varname = ""
			replace varname = "monthyear" 			if strpos(v1,"Economic Assistance Enrollment")
			replace varname = "snap_households" 	if strpos(v1,"SNAP (food stamp) Households")
			replace varname = "snap_individuals" 	if strpos(v1,"SNAP (food stamp) Individuals") 
			replace varname = "adc_families" 		if strpos(v1,"Aid to Dependent (ADC) families") 
			replace varname = "ccsubsidy_children" 	if strpos(v1,"Children in Child Care Subsidy") 
			order varname
			drop v1 
			sxpose, clear firstnames

			// destring
			foreach var in snap_households snap_individuals adc_families ccsubsidy_children {

				// destring 
				destring `var', replace ignore("*")
			
				// assert variable is numeric
				confirm numeric variable `var'

			}

		} // end of snap loop

		else if "`data'" == "medicaid" {

			#delimit ;
			keep if 
			strpos(v1,"Medicaid Enrollment") |
			strpos(v1,"Total Enrollment") |
			strpos(v1,"Children and Families Enrollment") |
			strpos(v1,"Aged and Disabled Enrollment") 
			;
			#delimit cr 

			// cleanup again 
			dropmiss, force 
			dropmiss, obs force 
			describe, varlist 
			rename (`r(varlist)') (v#), addnumber

			// assert shape of data 
			if inlist(`ym',ym(2017,4),ym(2017,5),ym(2018,1)) {
				assert r(k) == 14
			}
			else if inlist(`ym',ym(2018,11),ym(2020,2)) {
				assert r(k) == 15
			}
			else if inlist(`ym',ym(2020,3)) {
				assert r(k) == 16
			}
			else {
				assert r(k) == 13 
			}
			assert r(N) == 4

			// transpose data, including new variable names first 
			gen varname = ""
			replace varname = "monthyear" 							if strpos(v1,"Medicaid Enrollment")
			replace varname = "medicaid_enrol_total"				if strpos(v1,"Total Enrollment")
			replace varname = "medicaid_enrol_children_families" 	if strpos(v1,"Children and Families Enrollment")
			replace varname = "medicaid_enrol_aged_disabled" 		if strpos(v1,"Aged and Disabled Enrollment") 
			order varname
			drop v1 
			sxpose, clear firstnames

			// destring
			foreach var in medicaid_enrol_total medicaid_enrol_children_families medicaid_enrol_aged_disabled {

				// destring 
				destring `var', replace 
			
				// assert variable is numeric
				confirm numeric variable `var'

			}
		
		} // end of medicaid loop

		// clean up date 
		replace monthyear = trim(monthyear)
		split monthyear, parse("-")
		rename monthyear1 monthname 
		rename monthyear2 yearshort 
		gen month = ""
		replace month = "1" if monthname == "Jan"
		replace month = "2" if monthname == "Feb"
		replace month = "3" if monthname == "Mar"
		replace month = "4" if monthname == "Apr"
		replace month = "5" if monthname == "May"
		replace month = "6" if monthname == "Jun"
		replace month = "7" if monthname == "Jul"
		replace month = "8" if monthname == "Aug"
		replace month = "9" if monthname == "Sep"
		replace month = "10" if monthname == "Oct"
		replace month = "11" if monthname == "Nov"
		replace month = "12" if monthname == "Dec"
		assert !missing(month)
		destring month, replace 
		drop monthname
		destring yearshort, replace ignore("\'")
		confirm numeric variable yearshort
		gen year = yearshort + 2000
		drop yearshort
		drop monthyear
		gen ym = ym(year,month)
		format ym %tm 
		drop year month

		// save 
		tempfile _`data'
		save `_`data''

		// restore 
		restore
	}

	if "`datalist'" == "snap medicaid" {
		foreach data in `datalist' {
			if "`data'" == "snap" {
				use `_`data'', clear
			}
			else {
				merge 1:1 ym using `_`data''
				if inlist(`ym',ym(2017,4),ym(2017,5),ym(2018,1),ym(2020,2)) {
					// has one extra month of data in medicaid but not snap
				}
				else if inlist(`ym',ym(2018,11)) {
					// has 2 extra months of data in medicaid but not snap
				}
				else if inlist(`ym',ym(2020,3)) {
					// extra months of data in medicaid
				}
				else if inlist(`ym',ym(2019,6)) {
					// **KP: 2019m6 snap is 2018m7-2019m6, medicaid is 2018m6-2019m5, so double check if numbers match up
				}
				else {
					assert _m == 3
				}
				drop _m 
			}
		}
	}
	else if "`datalist'" == "medicaid" {
		use `_medicaid', clear
	}
	else if "`datalist'" == "snap" {
		use `_snap', clear
	}

	// order and sort 
	order ym 
	sort ym 

	// save 
	tempfile _`ym'
	save `_`ym''
}

******************************************

// append all ym's 
forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// drop duplicates
duplicates drop

// order and sort 
order ym 
sort ym 

// save 
save "${dir_data}/nebraska.dta", replace 
*/
****************************

use "${dir_data}/nebraska.dta", clear

// get rid of more duplicates 
*preserve
keep ym medicaid_enrol_total medicaid_enrol_children_families medicaid_enrol_aged_disabled
duplicates drop 
drop if missing(medicaid_enrol_total) & missing(medicaid_enrol_children_families) & missing(medicaid_enrol_aged_disabled)


br if inrange(ym,ym(2016,6),ym(2016,8))
check 
KEEP GOING HERE

tempfile medicaid_final
save `medicaid_final'
restore
preserve
keep ym snap_households snap_individuals adc_families ccsubsidy_children
duplicates drop 
drop if missing(snap_households) & missing(snap_individuals) & missing(adc_families) & missing(ccsubsidy_children)
drop if ym == ym(2018,6) & missing(adc_families) // manual drop 
drop if ym == ym(2019,6) & snap_individuals == 159963 // was mislabeled and is really just a copy of 2019m5 data 
tempfile snap_final
save `snap_final'
restore

use `snap_final', clear
merge 1:1 ym using `medicaid_final', assert(3) nogen



**KP: make sure just one of each month
**KP: keep going to figure out where multiples are coming from and which ones are correct

tab ym 


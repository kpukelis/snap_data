// north carolina.do
// imports cases and clients from excel sheets

local datasets 					cases apps abawds workcases workapps
local file_cases 				"FNS-Cases-and-Participants-Website-Data-thru-12-2020"
local file_apps 				"FNS-Applications-By-County-By-Month-thru-12-2017-rev4-17-2018 (1)"
local file_abawds 				"FNS-ABAWDS-By-Month-By-County-thru-12-2020"
local file_workcases			"Work-First-Cases-Participants-Counts-by-County-thru-11-2020"
local file_workapps 			"Work-First-Applications-By-Month-thru-12-2017 (1)"

local ym_start_cases			= ym(2006,7)
local ym_end_cases				= ym(2020,12)
local ym_start_apps				= ym(2007,4)
local ym_end_apps				= ym(2017,12)
local ym_start_abawds			= ym(2017,4)
local ym_end_abawds				= ym(2020,12)
local ym_start_workcases		= ym(2007,4)
local ym_end_workcases			= ym(2020,11)
local ym_start_workapps			= ym(2007,4)
local ym_end_workapps			= ym(2017,12)

***************************************************************
/*
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
			if inlist(`ym',ym(2018,2),ym(2018,3),ym(2018,4)) | inrange(`ym',ym(2018,8),ym(2020,12)) {
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
			rename b apps
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
	save "${dir_root}/data/state_data/northcarolina/northcarolina_`dataset'.dta", replace

}
**"NOTE:  During January 2014, Work First began to transition into NCFAST.  The data in the first chart represents the case and participant count information from the EIS legacy system, while the data from the second chart represents the data from the NCFAST system. All counties did not transition at the same time, so there may not be data represented from the NCFAST system for each county. Therefore, to calculate the total per county on the summary tab, the case counts were added together from both systems."		
use "${dir_root}/data/state_data/northcarolina/northcarolina_workcases.dta", clear 
collapse (sum) workfirst_cases workfirst_participants, by(county ym)
save "${dir_root}/data/state_data/northcarolina/northcarolina_workcases.dta", replace
duplicates report county ym 
*/
***********************************************************

// merge all datasets together
foreach dataset of local datasets {
	if "`dataset'" == "cases" {
		use "${dir_root}/data/state_data/northcarolina/northcarolina_`dataset'.dta", clear
	}
	else {
		merge 1:1 county ym using "${dir_root}/data/state_data/northcarolina/northcarolina_`dataset'.dta"
		assert county == "total" if _m == 2
		drop _m

	}
}
order county ym 
sort county ym 

// label
label var participants "SNAP participants"
label var cases "SNAP cases"
label var apps "SNAP applications"
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
if `r(N)' == 2 {
	drop m
}

// save 
save "${dir_root}/data/state_data/northcarolina/northcarolina.dta", replace 



// illinois.do
// imports households and persons from excel sheets

local year_start				2010
local year_end 					2020
local sheets 					persons households

***************************************************************

forvalues year = `year_start'(1)`year_end' {
	foreach sheet of local sheets {
	if `year' < 2018 {

		// year 
		display in red `"`sheet'"' `year'

		// import 
		import excel using "${dir_root}/data/state_data/illinois/snap`year'.xlsx", sheet("`sheet'") firstrow case(lower) allstring clear
		
		// drop observations, then variables with all missing values
		dropmiss, obs force
		dropmiss, force

		// clean up county 
		replace county = strlower(county)
		replace county = trim(county)
		drop if county == "cntl all kid"
		if inlist(`year',2013) {
			drop if strpos(county,"notice:")
		}
		capture confirm variable office 
		if !_rc {
			stop 	
		}

		// reshape
		rename january _1 
		rename february _2 
		rename march _3
		rename april _4 
		rename may _5
		rename june _6 
		rename july _7
		rename august _8
		rename september _9
		rename october _10 
		rename november _11
		rename december _12
		reshape long _, i(county) j(month)
		rename _ `sheet'

		// clean up main variable
		replace `sheet' = ustrregexra(`sheet',",","")
		replace `sheet' = ustrregexra(`sheet',"-","")
		replace `sheet' = ustrregexra(`sheet'," ","")
		gen consolidated_note = ""
		replace consolidated_note = `sheet' if strpos(`sheet',"consolidated")
		replace consolidated_note = `sheet' if inlist(`sheet',"Closed","closed")
		replace consolidated_note = county if strpos(county,"consolidated")
		replace `sheet' = "" if strpos(`sheet',"consolidated")
		replace `sheet' = "" if  inlist(`sheet',"Closed","closed")
		if !inrange(`year',2014,2017) {
			replace county = ustrregexra(county," ","")
		}
		gen county_temp = county 
		split county_temp, parse(" ")
		foreach v of varlist county_temp? {
			replace `v' = trim(`v') 
			replace `v' = ustrregexra(`v'," ","")
		}
		capture confirm variable county_temp2
		if !_rc {
			capture noisily assert inlist(county_temp2,"county","")
			replace county = county_temp1 if inlist(county_temp2,"county","")
			capture confirm variable county_temp3
			if !_rc {
				capture noisily assert inlist(county_temp2,"county","") | inlist(county_temp3,"county","")
				replace county = county_temp1 + " " + county_temp2 if inlist(county_temp3,"county","")
				capture confirm variable county_temp4
				if !_rc {
					noisily assert inlist(county_temp2,"county","") | inlist(county_temp3,"county","","illinois)")
					replace county = county_temp1 + " " + county_temp2 + " " + county_temp3 if inlist(county_temp3,"illinois)")
				}
			}
		}
		else {

		}
		
		drop county_temp*
		replace county = ustrregexra(county," ","")
		if `year' == 2013 {
			replace county = "clinton" if county == "clintonclintoncountyofficeclosedandconsolidatedwithmarioncountyoffice."
			replace county = "mercer" if county == "mercer mercercountyofficeclosed,consolidatedwithwarrencountyoffice."
		}
		
		replace `sheet' = ustrregexra(`sheet'," ","")
		destring `sheet', replace
        confirm numeric variable `sheet'

		// date 
		gen year = `year'
		gen ym = ym(year,month)
		format ym %tm 
		drop year month 

		// order and sort 
		order county ym `sheet'
		sort county ym

		// manually fix duplicates
		if `year' == 2014 {
			drop if county == "bond" & ym == ym(2014,1) & consolidated_note == "bond county office closed and consolidated with madison county office, effective 2/2014."
			drop if county == "bond" & inrange(ym,ym(2014,2),ym(2014,12)) & consolidated_note != "bond county office closed and consolidated with madison county office, effective 2/2014."
		}
		if `year' == 2015 {
			drop if county == "hancock" & ym == ym(2015,1) & consolidated_note == "hancock county office closed and consolidated with adams county office."
			drop if county == "hancock" & inrange(ym,ym(2015,2),ym(2015,12)) & consolidated_note != "hancock county office closed and consolidated with adams county office."
			drop if county == "schuyler" & inrange(ym,ym(2015,1),ym(2015,6)) & consolidated_note == "schuyler county office closed and consolidated with cass county office."
			drop if county == "schuyler" & inrange(ym,ym(2015,7),ym(2015,12)) & consolidated_note != "schuyler county office closed and consolidated with cass county office."
		}

		// assert no duplicates by county ym 
		duplicates tag county ym, gen(dup)
		assert dup == 0
		drop dup

	}

	*********************************************************************************************************************

	else if `year' >= 2018 {

		// year 
		display in red `"`sheet'"' `year'

		// import 
		import excel using "${dir_root}/data/state_data/illinois/snap`year'.xlsx", sheet("`sheet'") firstrow case(lower) allstring clear
		
		// drop observations, then variables with all missing values
		dropmiss, obs force
		dropmiss, force

		// clean up office 
		replace office = officenumber if inlist(officenumber,"DOWNSTATE","COOK COUNTY","TOTAL STATE")
		replace officenumber = "" if inlist(officenumber,"DOWNSTATE","COOK COUNTY","TOTAL STATE")
		destring officenumber, replace
		confirm numeric variable officenumber
		replace office = strlower(office)
		replace office = trim(office)
		drop if office == "cntl all kid"

		// reshape
		rename january _1 
		rename february _2 
		rename march _3
		rename april _4 
		rename may _5
		if `year' != 2020 {
			rename june _6 
			rename july _7
			rename august _8
			rename september _9
			rename october _10 
			rename november _11
			rename december _12
		}
		reshape long _, i(office) j(month)
		rename _ `sheet'

		// clean up main variable
		replace `sheet' = ustrregexra(`sheet',",","")
		replace `sheet' = ustrregexra(`sheet',"-","")
		replace `sheet' = ustrregexra(`sheet'," ","")
		gen consolidated_note = ""
		replace consolidated_note = `sheet' if strpos(`sheet',"consolidated")
		replace consolidated_note = `sheet' if inlist(`sheet',"Closed","closed")
		replace consolidated_note = office if strpos(office,"consolidated")
		replace `sheet' = "" if strpos(`sheet',"consolidated")
		replace `sheet' = "" if  inlist(`sheet',"Closed","closed")
		if !inrange(`year',2014,2017) {
			replace office = ustrregexra(office," ","")
		}
		gen office_temp = office 
		split office_temp, parse(" ")
		foreach v of varlist office_temp? {
			replace `v' = trim(`v') 
			replace `v' = ustrregexra(`v'," ","")
		}
		capture confirm variable office_temp2
		if !_rc {
			capture noisily assert inlist(office_temp2,"office","")
			replace office = office_temp1 if inlist(office_temp2,"office","")
			capture confirm variable office_temp3
			if !_rc {
				capture noisily assert inlist(office_temp2,"office","") | inlist(office_temp3,"office","")
				replace office = office_temp1 + " " + office_temp2 if inlist(office_temp3,"office","")
				capture confirm variable office_temp4
				if !_rc {
					noisily assert inlist(office_temp2,"office","") | inlist(office_temp3,"office","","illinois)")
					replace office = office_temp1 + " " + office_temp2 + " " + office_temp3 if inlist(office_temp3,"illinois)")
				}
			}
		}
		else {

		}
		
		drop office_temp*
		replace office = ustrregexra(office," ","")		
		replace `sheet' = ustrregexra(`sheet'," ","")
		destring `sheet', replace
        confirm numeric variable `sheet'

		// date 
		gen year = `year'
		gen ym = ym(year,month)
		format ym %tm 
		drop year month 

		// order and sort 
		order office ym `sheet'
		sort office ym

		// assert no duplicates by office ym 
		duplicates tag office ym, gen(dup)
		assert dup == 0
		drop dup

		// save 
		tempfile `year'_`sheet'
		save ``year'_`sheet''

	}
	}

}

***************************************************************

forvalues year = `year_start'(1)`year_end' {
	if `year' < 2018 {
		local level county
	}
	else {
		local level office 
	}
	display in red "`year'"
	foreach sheet of local sheets {
		display in red "`sheet'"
		if "`sheet'" == "persons" {
			use ``year'_`sheet'', clear
		}
		else {
			merge 1:1 `level' ym using ``year'_`sheet''
			assert _m == 3
			drop _m
		}
	}
	save "${dir_root}/data/state_data/illinois/illinois_`year'_TEMP.dta", replace 
}

// Note only merging 2017 for now; going to get to the office level and then append with 2018-2020 data
forvalues year = `year_start'(1)2017 {
	if `year' == `year_start' {
		use "${dir_root}/data/state_data/illinois/illinois_`year'_TEMP.dta", clear
	}
	else {
		append using "${dir_root}/data/state_data/illinois/illinois_`year'_TEMP.dta"
	}
}

// order and sort 
order county ym 
sort county ym

// rename 
rename persons individuals

// save
save "${dir_root}/data/state_data/illinois/illinois_county.dta", replace 
check
*/
******************************************************************************

// load data
use "${dir_root}/data/state_data/illinois/illinois_county.dta", clear 

// collapse to larger office level

// generate closed date 
gen ym_closed = .
replace ym_closed = ym(2011,1) if inlist(county,"brown","calhoun","clark","cumberland","dewitt","edwards","ford","gallatin","grundy") | inlist(county,"hardin","jasper","johnson","lee","menard","monroe","piatt","putnum") | inlist(county,"scott","stark","washington","wayne","woodford")
replace ym_closed = ym(2011,3) if inlist(county,"mercer")
replace ym_closed = ym(2011,7) if inlist(county,"boone","perry")
replace ym_closed = ym(2013,10) if inlist(county,"alexander","clay","douglas","edgar","effingham","kendall","pope","shelby")
/*
henderson
KEEP GOING HERE

madison |         36        0.73       53.54
                        madison-e.alton |         21        0.43       53.96
                         madison-g.city |         21        0.43       5

 kane |         36        0.73       40.18
                            kane-aurora |         21        0.43       40.61
                             kane-elgin |         21        0.43       41.04

  st.clair |         36        0.73       83.17
                    st.clair-e.st.louis |         21        0.43       8
*/

// mark consolidations
rename county office
replace office = "pulaski" 		if office == "alexander" 	& ym >= ym(2013,11)
replace office = "madison" 		if office == "bond" 		& ym >= ym(2014,2)
replace office = "winnebago" 	if office == "boone" 		& ym >= ym(2011,7)
replace office = "schuyler" 	if office == "brown" 		& ym >= ym(2011,1)
replace office = "jersey" 		if office == "calhoun" 		& ym >= ym(2011,1)
replace office = "whiteside" 	if office == "carroll" 		& ym >= ym(2012,10)
replace office = "edgar" 		if office == "clark" 		& ym >= ym(2011,1)
replace office = "richland" 	if office == "clay" 		& ym >= ym(2014,1)
replace office = "marion" 		if office == "clinton" 		& ym >= ym(2012,2)
replace office = "effingham" 	if office == "cumberland" 	& ym >= ym(2011,1)
replace office = "logan" 		if office == "dewitt" 		& ym >= ym(2011,1)
replace office = "coles" 		if office == "douglas" 		& ym >= ym(2014,1)
replace office = "coles" 		if office == "edgar" 		& ym >= ym(2014,1)
replace office = "wabash" 		if office == "edwards" 		& ym >= ym(2011,1)
replace office = "coles" 		if office == "effingham" 	& ym >= ym(2014,1)
replace office = "marion" 		if office == "fayette" 		& ym >= ym(2012,2)
replace office = "champaign" 	if office == "ford" 		& ym >= ym(2011,1)
replace office = "saline" 		if office == "gallatin" 	& ym >= ym(2011,1)
replace office = "jersey" 		if office == "greene" 		& ym >= ym(2012,9)
replace office = "lasalle" 		if office == "grundy" 		& ym >= ym(2011,1)
replace office = "franklin" 	if office == "hamilton" 	& ym >= ym(2012,4)
replace office = "adams" 		if office == "hancock" 		& ym >= ym(2015,2)
replace office = "pop" 			if office == "hardin" 		& ym >= ym(2011,1)
replace office = "warren" 		if office == "henderson" 	& ym >= ym(2011,1)
replace office = "kankakee" 	if office == "iroquois" 	& ym >= ym(2012,3)
replace office = "crawford" 	if office == "jasper" 		& ym >= ym(2011,1)
replace office = "stephenson" 	if office == "jodaviess" 	& ym >= ym(2012,8)
replace office = "union" 		if office == "johnson" 		& ym >= ym(2011,1)
replace office = "kane" 		if office == "kendall" 		& ym >= ym(2014,1)
replace office = "lawre" 		if office == "kendall" 		& ym >= ym(2014,1)
replace office = "richland" 	if office == "lawrence" 	& ym >= ym(2017,1)
replace office = "ogle" 		if office == "lee" 			& ym >= ym(2014,1)
replace office = "massac" 		if office == "pope" 		& ym >= ym(2014,1)
replace office = "cass" 		if office == "schuyler" 	& ym >= ym(2015,7)
replace office = "coles" 		if office == "shelby" 		& ym >= ym(2014,1)
replace office = "ogle" 		if office == "lee" 			& ym >= ym(2011,1)
replace office = "mclean" 		if office == "livingston" 	& ym >= ym(2012,10)
replace office = "bureau" 		if office == "marshall" 	& ym >= ym(2012,10)
replace office = "logan" 		if office == "menard" 		& ym >= ym(2011,1)
replace office = "warren" 		if office == "mercer" 		& ym >= ym(2011,3)
replace office = "randolph" 	if office == "monroe" 		& ym >= ym(2011,1)
replace office = "douglas" 		if office == "moultrie" 	& ym >= ym(2012,9)
replace office = "jackson" 		if office == "perry" 		& ym >= ym(2011,7)
replace office = "moultrie" 	if office == "piatt" 		& ym >= ym(2011,1)
replace office = "adams" 		if office == "pike" 		& ym >= ym(2012,8)
replace office = "marshall" 	if office == "putnam" 		& ym >= ym(2011,1)
replace office = "bureau" 		if office == "putnam" 		& ym >= ym(2012,1)
replace office = "pike" 		if office == "scott" 		& ym >= ym(2011,1)
replace office = "henry" 		if office == "stark" 		& ym >= ym(2011,1)
replace office = "jefferson" 	if office == "washington" 	& ym >= ym(2011,1)
replace office = "jefferson" 	if office == "wayne" 		& ym >= ym(2011,1)
replace office = "wabash" 		if office == "white" 		& ym >= ym(2012,12)
replace office = "peoria" 		if office == "woodford" 	& ym >= ym(2011,1)
check
collapse (sum) individuals households, by(office ym)


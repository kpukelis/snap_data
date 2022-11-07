// california.do 
// Kelsey Pukelis

local year_short_list			/*10 14*/ 16 17 18 19 20 21
local first_year_short 			16

**************************************************************************

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
	else if inrange(`year_short',20,21) {
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
	if inlist(`year_short',20,21) {
		drop v3 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
	}

	// rename variables
	describe, varlist
	assert `r(k)' == 129
	if `year_short' == 21 {
		assert `r(N)' == 357
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
	else if inlist(`year_short',20,21) {
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
	rename dtotalrecertificationsdisposedof recerts
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
	drop date 
	drop sfy 
	drop ffy 
	capture confirm variable month 
	if !_rc {
		destring month, replace 
		confirm numeric variable month
		destring year, replace
		confirm numeric variable year	
	}
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
	}
	gen ym = ym(year,month)
	format ym %tm 
	drop year month 

	// lowercase county 
	replace county = strlower(county)
	
	// drop statewide average 
	drop if strpos(county,"statewide average")
	replace county = "state totals" if county == "statewide total"

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

save "${dir_root}/data/state_data/california/california_TEMP.dta", replace 

check

// drop statewide totals; data is not consistent enough
drop if county == "statewide"

// assert level of the data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order and sort 
order county ym // issuance households individuals households_npa individuals_npa households_pa individuals_pa
sort county ym 
 
// save 
save "${dir_root}/data/state_data/california/california.dta", replace 


// oregon_pdf.do
// imports cases and clients from excel sheets

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/oregon"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local year_start				= 2006
*local year_start				= 2014
local year_end 					= 2019

*KP: left to do
*KEEP GOING WITH PAGE 5, still need to do page 4 

***************************************************************

forvalues year = `year_start'(1)`year_end' {

	if `year' == 2006 {
		local month_start = 5
		local month_end = 12
	}
	else if `year' == 2019 {
		local month_start = 1
		local month_end = 8
	}
	else {
		local month_start = 1
		local month_end = 12
	}

	forvalues month = `month_start'(1)`month_end' {
 
		if `month' == 1 {
			local monthname "January"
		}
		if `month' == 2 {
			local monthname "February"
		}
		if `month' == 3 {
			local monthname "March"
		}
		if `month' == 4 {
			local monthname "April"
		}
		if `month' == 5 {
			local monthname "May"
		}
		if `month' == 6 {
			local monthname "June"
		}
		if `month' == 7 {
			local monthname "July"
		}
		if `month' == 8 {
			local monthname "August"
		}
		if `month' == 9 {
			local monthname "September"
		}
		if `month' == 10 {
			local monthname "October"
		}
		if `month' == 11 {
			local monthname "November"
		}
		if `month' == 12 {
			local monthname "December"
		}

		// year 
		display in red "`year' `monthname'"
		local ym = ym(`year',`month')

		// import 
		import excel using "${dir_root}/excel_short/`year'/`monthname'20`year'.xlsx", firstrow case(lower) allstring clear
		
		// rename vars 
		describe, varlist 
		rename (`r(varlist)') (v#), addnumber
		replace v1 = trim(v1)
		replace v1 = stritrim(v1)

		// separate pages/batches
		gen obsnum = _n
		qui sum obsnum if strpos(v1,"ASTORIA")
		local batch_start_1 = `r(min)'
		if `ym' <= ym(2009,11) {
			qui sum obsnum if strpos(v1,"STATEWIDE FOOD STAMP ACTIVITY")
		}
		else if inrange(`ym',ym(2009,12),ym(2015,8)) {
			qui sum obsnum if strpos(v1,"STATEWIDE SUPPLEMENTAL NUTRITIONAL ASSIATANCE PROGRAM ACTIVITY") | strpos(v1,"STATEWIDE SUPPLEMENTAL NUTRITION ASSISTANCE PROGRAM ACTIVITY")
		}
		else if inrange(`ym',ym(2015,9),ym(2017,12)) | inlist(`ym',ym(2018,4)) | inrange(`ym',ym(2018,6),ym(2019,10)) {
			qui sum obsnum if strpos(v1,"STATEWIDE - SSP, APD, AND AAA COMBINED")
		}
		else {
			qui sum obsnum if strpos(v1,"STATEWIDE ‐ SSP, APD, AND AAA COMBINED")
		}
		assert r(N) == 1
		local batch_start_2 = `r(min)'
		if `ym' <= ym(2012,6) { 
			qui sum obsnum if strpos(v1,"CHILDREN, ADULTS AND FAMILIES")
		}
		else { 
			qui sum obsnum if strpos(v1,"SELF SUFFICIENCY PROGRAMS SUPPLEMENTAL NUTRITION ASSISTANCE PROGRAM")
		}
		assert r(N) == 1
		local batch_start_3 = `r(min)'
		if `ym' <= ym(2012,6) { 
			qui sum obsnum if strpos(v1,"SENIORS AND PEOPLE WITH DISABILITIES")
		}
		else {
			qui sum obsnum if strpos(v1,"ADULTS AND PEOPLE WITH DISABILITIES SUPPLEMENTAL NUTRITION ASSISTANCE PROGRAM")
		}
		assert r(N) == 1
		local batch_start_4 = `r(min)'
		if inrange(`ym',ym(2006,1),ym(2008,5)) {
			qui sum obsnum if strpos(v1,"(6) FOOD STAMPS")
			assert r(N) == 1
			local batch_start_5 = `r(min)'
			qui sum obsnum if strpos(v1,"(6) FOOD STAMP INFORMATION INCLUDES ALL STATEWIDE ISSUANCE")
			assert r(N) == 1
			local batch_start_6 = `r(min)'
		}
		if inrange(`ym',ym(2008,6),ym(2013,9)) {
			qui sum obsnum if strpos(v1,"STATE OF OREGON PUBLIC ASSISTANCE DATA BY COUNTY")
			assert r(N) == 1
			local batch_start_5 = `r(min)'
			qui sum obsnum if strpos(v1,"(1) WHEELER & SHERMAN COUNTIES HAVE NO BRANCHES.")
			assert r(N) == 1
			local batch_start_6 = `r(min)'
		}
		if inrange(`ym',ym(2013,10),ym(2020,1)) {
			qui sum obsnum if strpos(v1,"STATE OF OREGON PUBLIC ASSISTANCE DATA BY COUNTY")
			assert r(N) == 1
			local batch_start_5 = `r(min)'
			qui sum obsnum if strpos(v1,"(1) WHEELER & SHERMAN AND MORROW COUNTIES HAVE NO BRANCHES.")
			assert r(N) == 1
			local batch_start_6 = `r(min)'
		}
		// keep a particular page of data
*		forvalues n = 1(1)5 {
local n = 5
*KEEP GOING HERE, GO THROUGH PAGE 3 FOR ALL YEARS
*			preserve
	
**KP: skip these months for now
*if !inlist(`ym',ym(2014,7),ym(2014,8)) & !inrange(`ym',ym(2015,2),ym(2018,12)) {		
			local nplus1 = `n' + 1

			if `n' == 1 & inrange(`ym',ym(2010,3),ym(2013,10)) {
				import delimited using "${dir_root}/excel_short/`year'/tabula-`monthname'20`year'.csv", varnames(2) case(lower) stringcols(_all) clear
			}
			else {
				keep if obsnum >= `batch_start_`n'' & obsnum < `batch_start_`nplus1''
			}
			
			dropmiss, force 
			dropmiss, obs force 
			describe, varlist 
			rename (`r(varlist)') (v#), addnumber
			replace v1 = strlower(v1)
			drop if strpos(v1,"statistical purposes only")
			drop if strpos(v1,"statewide food stamp activity")
			drop if strpos(v1,"caf, spd and aaa combined")
			drop if strpos(v1,"children, adults and families food stamp able-bodied adults without children")
			drop if strpos(v1,"seniors and people with disabilities")
			drop if strpos(v1,"abawd medical abawd other total")
			drop if strpos(v1,"state of oregon public assistance data by county")
			drop if strpos(v1,"page 31")
			drop if strpos(v1,"food stamps")
			drop if strpos(v1,"(1) wheeler & sherman counties have no branches. clients in those counties are served in surrounding counties.")
			drop if strpos(v1,"(5) the data for the chip, plm and ohp cases handled by branch 5503 are distributed to each county based upon estimated populations.")
			drop if strpos(v1,"page 14")
			drop if strpos(v1,"page 13")
			drop if strpos(v1,"page 28")
			drop if strpos(v1,"page 27")
			drop if strpos(v1,"* this does not include apd issuance.")
			drop if strpos(v1,"* as of april 2009 this data includes the north salem caf branch and the salem mso branch.")
			drop if strpos(v1,"** as of february 2008 the data source for this report was updated. page 15")
			drop if strpos(v1,"statewide supplemental nutritional assiatance program activity")
			drop if strpos(v1,"hh's one % change hh's first mo o % change")
			drop if strpos(v1,"ssp, apd and aaa combined")
			drop if strpos(v1,"ssp, apd, and aaa combined")
			drop if strpos(v1,"benefits households persons")
			drop if strpos(v1,"statewide supplemental nutrition assistance program activity")
			drop if strpos(v1,"self sufficiency programs supplemental nutrition assistance program able-bodied adults ithout children")
			drop if strpos(v1,"abawd medicalabawd other total % mandatory abawds")
			drop if strpos(v1,"self sufficiency programs supplemental nutrition assistance program")
			drop if strpos(v1,"children, adults and families")
			drop if v1 == "="
			drop if v1 == "5"
			drop if v1 == "abawd"
			drop if missing(v1)

			// make county shorter
			rename v1 v1_copy
			gen v1 = v1_copy
			drop v1_copy
			order v1 

			// drop district totals, page total
			drop if strpos(v1,"district")
			drop if strpos(v1,"caf total")
			**KP: note that I'm leaving in "state total" from page 2

			// drop missing vars once more
			dropmiss, force 
			dropmiss, obs force 
			describe, varlist 
			rename (`r(varlist)') (v#), addnumber
		
			// page 1 
			if inlist(`n',1) {

				if inrange(`ym',ym(2009,6),ym(2009,12)) | inrange(`ym',ym(2014,1),ym(2014,10)) | inrange(`ym',ym(2015,7),ym(2015,7)) {
					drop v4-v8
					replace v3 = trim(v3)
					gen v3_old = v3 
					drop v3
					gen v3 = substr(v3_old,1,14)
					gen v4 = substr(v3_old,15,28)
					drop v3_old
					replace v3 = trim(v3)
					replace v4 = trim(v4)			
				}
				else if inlist(`ym',ym(2015,8)) {
					drop v5
				}
				else if inrange(`ym',ym(2010,3),ym(2013,10)) {
					drop v5-v8
				}
				else {
					drop v5-v9
				}

				// rename vars I have
				rename v1 county
				rename v2 issuance 
				rename v3 households
				rename v4 persons
	
				// clean these vars up
				foreach var in issuance households persons {
					replace `var' = trim(`var')
					replace `var' = ustrregexra(`var',",","")
					replace `var' = ustrregexra(`var'," ","")
					replace `var' = ustrregexra(`var',"$","")
					
					// shorten length of string variable
					gen `var'_copy = `var'
					drop `var'
					rename `var'_copy `var'
	
					// destring 
					destring `var', replace ignore("$")

					// assert variable is numeric
					confirm numeric variable `var'
				}
			}

			// page 2 
			if inlist(`n',2) {

				// drop unneeded vars
				drop v5-v9	

				// rename vars I have
				rename v1 county
				rename v2 issuance 
				rename v3 households
				rename v4 persons
	
				// clean these vars up
				foreach var in issuance households persons {
					replace `var' = trim(`var')
					replace `var' = ustrregexra(`var',",","")
					replace `var' = ustrregexra(`var'," ","")
					replace `var' = ustrregexra(`var',"$","")
					
					// shorten length of string variable
					gen `var'_copy = `var'
					drop `var'
					rename `var'_copy `var'
	
					// destring 
					destring `var', replace ignore("$")

					// assert variable is numeric
					confirm numeric variable `var'
				}
			}

			// page 3 
			if inlist(`n',3,4) {
				display in red "`year' `monthname'"

				if inrange(`ym',ym(2006,5),ym(2007,9)) {
					// droppingn some of the later variables that were not imported cleanly
					describe
					assert r(k) == 15
					drop v13 v14
					sum v15 if v1 == "state total"
					assert r(N) == 1
					drop if v15 > r(mean)

					// rename  vars once more
					dropmiss, force 
					dropmiss, obs force 
					describe, varlist 
					rename (`r(varlist)') (v#), addnumber

				}

				if inrange(`ym',ym(2015,4),ym(2015,8)) {
					// split variable 6
					gen v6_old = v6 
					drop v6
					gen v6A = substr(v6_old,1,8)
					gen v6B = substr(v6_old,-6,.)
					drop v6_old
					replace v6A = trim(v6A)
					replace v6B = trim(v6B)		
					order v6A v6B, after(v5)

					// rename  vars once more
					dropmiss, force 
					dropmiss, obs force 
					describe, varlist 
					rename (`r(varlist)') (v#), addnumber

				}


				if inlist(`ym',ym(2014,7)) | inrange(`ym',ym(2015,2),ym(2015,8)) {
					// split variable 8
					gen v8_old = v8 
					drop v8
					gen v8A = substr(v8_old,1,6)
					gen v8B = substr(v8_old,-6,.)
					drop v8_old
					replace v8A = trim(v8A)
					replace v8B = trim(v8B)		
					order v8A v8B, after(v7)

					// split variable 10
					gen v10_old = v10 
					drop v10
					gen v10A = substr(v10_old,1,7)
					gen v10B = substr(v10_old,-6,.)
					drop v10_old
					replace v10A = trim(v10A)
					replace v10B = trim(v10B)		
					order v10A v10B, after(v9)

					// rename  vars once more
					dropmiss, force 
					dropmiss, obs force 
					describe, varlist 
					rename (`r(varlist)') (v#), addnumber
				}

				if inrange(`ym',ym(2015,9),ym(2019,8)) {
					// split variable 11
					gen v11_old = v11 
					drop v11
					gen v11A = substr(v11_old,1,7)
					gen v11B = substr(v11_old,-6,.)
					drop v11_old
					replace v11A = trim(v11A)
					replace v11B = trim(v11B)		
					order v11A v11B, after(v10)

					// rename  vars once more
					dropmiss, force 
					dropmiss, obs force 
					describe, varlist 
					rename (`r(varlist)') (v#), addnumber
				}

				// assert there are x variables
				**KP: date could change
				if `ym' <= ym(2014,6) {
					local x = 13
				}
				else {
					local x = 14
				}
				describe
				display in red "`year' `monthname'"
				assert r(k) == `x'

				foreach v of varlist v1-v`x' {
					// make string vars shorter
					gen `v'_copy = `v'
					drop `v'
					rename `v'_copy `v'
				}

				dropmiss, force 
				if inlist(`n',4) {
					drop v14
					// fix last variable 
					gen v12A = substr(v12,1,10)
					gen v12B = substr(v12,-5,.)
					**KP: hand check to make sure this works
					drop v12 
				}

				// rename vars 
				describe, varlist 
				rename (`r(varlist)') (v#), addnumber

				// rename vars I have
				rename v1 county
				rename v2 abawd_persons 
				rename v3 medical_exempt
				rename v4 abawd_vol
				rename v5 other_exempt
				rename v6 total_exempt
				rename v7 perc_exempt
				rename v8 mandabawds_voced
				rename v9 mandabawds_workfare
				rename v10 mandabawds_other
				rename v11 mandabawds_total
				rename v12 mandabawds_perc
				**KP: date could change
				if `ym' <= ym(2014,7) {
	*				rename v13 abawd_totalcaffshhs
					**KP: note this variable was not captured in page 3, the only place it occurs		**KP mandabawds_total is problem, not reliable, especially for months like ym(2014,7) where columns were split manually
		**KP: can check/confirm total by: mandabawds_voced + mandabawds_workfare + mandabawds_other = mandabawds_total
				drop v13
					if `ym' == ym(2014,7) {
						drop v14
					}
				}
				else {
					rename v13 abawd_totalssphhs
					drop v14
				}

				// clean these vars up
				foreach var in abawd_persons medical_exempt abawd_vol other_exempt total_exempt perc_exempt mandabawds_voced mandabawds_workfare mandabawds_other mandabawds_total mandabawds_perc /*abawd_totalcaffshhs*/ abawd_totalssphhs {
				
					noisily capture confirm variable `var'
					if !_rc {
						replace `var' = trim(`var')
						replace `var' = ustrregexra(`var',",","")
						replace `var' = ustrregexra(`var'," ","")
						replace `var' = ustrregexra(`var',"%","")
						replace `var' = ustrregexra(`var',"#","")
						replace `var' = ustrregexra(`var',"DIV/0!","")
						replace `var' = ustrregexra(`var',"D","")
						replace `var' = ustrregexra(`var',"I","")
						replace `var' = ustrregexra(`var',"DIV/0!","")
						replace `var' = ustrregexra(`var',"0DI","")

						// shorten length of string variable
						gen `var'_copy = `var'
						drop `var'
						rename `var'_copy `var'
		
						// destring 
						destring `var', replace ignore("$\%")

						// assert variable is numeric
						confirm numeric variable `var'
					}
				}
			}

			// page 5
			if inlist(`n',5) {

				// 
				if inlist(`ym',ym(2012,12)) | inrange(`ym',ym(2014,10),ym(2015,9)) {
					drop in 1
				}
				else if inlist(`ym',ym(2013,11)) {
					drop in 1
					drop in 1
					drop in 1
				}
				else {
					drop in 1
					drop in 1
				}
				assert v1 == "baker" if _n == 1
				dropmiss, force 

				// rename vars 
				describe, varlist 
				rename (`r(varlist)') (v#), addnumber
				
				if inrange(`ym',ym(2006,1),ym(2008,5)) {

					// drop variables that I don't need
					drop v16
*					drop v6-v16
					*KP: don't drop these non-snap variables unless cleaning them becomes too much of a hassle later
				
					// rename vars I have
					rename v1 county
					rename v2 nonassist_persons 
					rename v3 persons
					rename v4 households 
					rename v5 issuance
					rename v6 oaa_med_elig_persons
					rename v7 ab_med_elig_persons
					rename v8 ad_med_elig_persons
					rename v9 total_med_elig_persons
					rename v10 ohpqmgsmb_med_needycancer
					rename v11 ga_med_elig_persons
					rename v12 child_hlthins_elig_persons
					rename v13 empdaycare_cases
					rename v14 empdaycare_children
					rename v15 empdaycare_expenditure

					// clean these vars up
					foreach var in nonassist_persons  persons households  issuance oaa_med_elig_persons ab_med_elig_persons ad_med_elig_persons total_med_elig_persons ohpqmgsmb_med_needycancer ga_med_elig_persons child_hlthins_elig_persons empdaycare_cases empdaycare_children empdaycare_expenditure {
						replace `var' = trim(`var')
						replace `var' = ustrregexra(`var',",","")
						replace `var' = ustrregexra(`var'," ","")
		
						// shorten length of string variable
						gen `var'_copy = `var'
						drop `var'
						rename `var'_copy `var'
		
						// destring 
						destring `var', replace

						// assert variable is numeric
						confirm numeric variable `var'
					}
				}

				if inrange(`ym',ym(2008,6),ym(2014,4)) {
					// drop variables that I don't need
					drop v15

					// rename vars I have
					rename v1 county
					rename v2 pop_by_county
					rename v3 est_persons_below_poverty
					rename v4 est_pop_under_age18
					rename v5 unemploy_rate
					rename v6 est_clients_served
					rename v7 total_expend
					rename v8 tanf_children_per1000
					rename v9 tanf_persons_per1000
					rename v10 snap_persons_per1000
					rename v11 nonassist_persons 
					rename v12 persons
					rename v13 households 
					rename v14 issuance

					// clean these vars up
					foreach var in pop_by_county est_persons_below_poverty est_pop_under_age18 unemploy_rate est_clients_served total_expend tanf_children_per1000 tanf_persons_per1000 snap_persons_per1000 nonassist_persons persons households issuance {
						replace `var' = trim(`var')
						replace `var' = ustrregexra(`var',",","")
						replace `var' = ustrregexra(`var'," ","")
						replace `var' = ustrregexra(`var',"$","")
						replace `var' = ustrregexra(`var',"\(","")
						replace `var' = ustrregexra(`var',"\)","")

						// shorten length of string variable
						gen `var'_copy = `var'
						drop `var'
						rename `var'_copy `var'
		
						// destring 
						destring `var', replace ignore("$")

						// assert variable is numeric
						confirm numeric variable `var'
					}
		
				}

				if inrange(`ym',ym(2014,5),ym(2019,8)) {
					// drop variables that I don't need
					drop v15

					// rename vars I have
					rename v1 county
					rename v2 pop_by_county
					rename v3 est_persons_below_poverty
					rename v4 est_pop_under_age18
					rename v5 unemploy_rate
					rename v6 tanf_children_per1000
					rename v7 tanf_persons_per1000
					rename v8 snap_persons_per1000
					rename v9 nonassist_persons
					rename v10 persons
					rename v11 households 
					rename v12 issuance
					rename v13 pre_ssissdi_cases 
					rename v14 pre_ssissdi_expend

					// clean these vars up
					foreach var in pop_by_county est_persons_below_poverty est_pop_under_age18 unemploy_rate tanf_children_per1000 tanf_persons_per1000 snap_persons_per1000 nonassist_persons persons households issuance pre_ssissdi_cases pre_ssissdi_expend {
						replace `var' = trim(`var')
						replace `var' = ustrregexra(`var',",","")
						replace `var' = ustrregexra(`var'," ","")
						replace `var' = ustrregexra(`var',"$","")
						replace `var' = ustrregexra(`var',"\(","")
						replace `var' = ustrregexra(`var',"\)","")

						// shorten length of string variable
						gen `var'_copy = `var'
						drop `var'
						rename `var'_copy `var'
		
						// destring 
						destring `var', replace ignore("$")

						// assert variable is numeric
						confirm numeric variable `var'
					}
		
				}

				// shorten length of string variable
				foreach var in county {
					gen `var'_copy = `var'
					drop `var'
					rename `var'_copy `var'
				}
				order county
			}

			// save tempfile
			tempfile year`year'_month`month'_page`n'
			save `year`year'_month`month'_page`n''
		
*} // closes if clause **KP: take this away later
			// restore
*			restore
*		} // closes loop over pages	                                          

	} // closes loop over months

} // closes loop over years
***KP: going to have to check mandabawds_perc scale: some are on 0-1, others on 0-100

****************************************************************

// append all months of data

// keep a particular page of data
*forvalues n = 1(1)5 {
local n = 5

	clear 

	forvalues year = `year_start'(1)`year_end' {
	
		if `year' == 2006 {
			local month_start = 5
			local month_end = 12
		}
		else if `year' == 2019 {
			local month_start = 1
			local month_end = 8
		}
		else {
			local month_start = 1
			local month_end = 12
		}
	
		forvalues month = `month_start'(1)`month_end' {
	 
			// year 
			display in red "`year' `monthname'"
			local ym = ym(`year',`month')
		
			// append data	
			if `ym' == ym(2006,5) {
				use `year`year'_month`month'_page`n'', clear
				gen ym = `ym'
				format ym %tm
			}
			else {
				append using `year`year'_month`month'_page`n''
				replace ym = `ym' if missing(ym)
			}



		} // end month loop
	} // end year loop

	// standardize county name
	replace county = "la pine connection" if strpos(county,"la pine connect") | strpos(county,"la pine")
	replace county = "rogue family ctr" if strpos(county,"rogue family") | strpos(county,"rogue fam ctr")
	replace county = "n valley proc ctr" if strpos(county,"n valley proc ctr")
	replace county = "s umpqua" if strpos(county,"s umpqua") | strpos(county,"s umqua")
	replace county = "east" if county == "east**"
	replace county = "erdc proc center" if inlist(county,"erdc proc cente","erdc service center")
	replace county = "fam stability/emp (dist 2)" if county == "fam stability/emp"
	replace county = "food stamp center" if strpos(county,"food stamp cent") | county == "food stamp ctr"
	replace county = "fs processing ctr" if strpos(county,"fs processing ct")
	replace county = "la grande" if county == "lagrande"
	replace county = "mltn-frwtr" if county == "mltn‐frwtr"
	replace county = "north emp/training" if strpos(county,"north emp/traini")
	replace county = "northeast ptlnd" if strpos(county,"northeast ptld")
	replace county = "pdx integrated svcs" if strpos(county,"pdx integrated s")
	replace county = "portland proc ctr" if strpos(county,"portland proc ctr")
	replace county = "service delivery area 11" if strpos(county,"service delivery area 11")
	replace county = "southeast ptlnd" if strpos(county,"southeast ptld")
	replace county = "st helens" if strpos(county,"st. helens")
	replace county = "teen parents" if strpos(county,"teen parents")
	replace county = "wa co proc center" if strpos(county,"wa co proc cent")
	replace county = "n val proc ctr" if strpos(county,"n val proc ctr")
	replace county = "north salem" if strpos(county,"north salem")
	replace county = "n clackamas" if county == "clackamas"
	replace county = "new market" if county == "new market theatre"
	replace county = "milwaukee" if county == "milwaukie"
	replace county = "metro proc ctr" if county == "metro"
	replace county = "tualatin proc center" if county == "tualatin proc cente"
	replace county = "refugee center" if county == "refugee unit"
	replace county = "wheeler" if strpos(county,"wheeler")
	replace county = "washington" if county == "washingto"
	replace county = "state total" if county == "state tota"
	replace county = "sherman" if strpos(county,"sherman") 
	replace county = "multnomah" if county == "multnoma"
	replace county = "adj/ohp/sbg" if county == "adj/ohp"
	*replace county = "" if strpos(county,"")
	*replace county = "" if strpos(county,"")
	*replace county = "" if strpos(county,"")

	// clean up percentage variables
	**KP: need to check this for other pages
	if `n' == 5 {
		replace unemploy_rate = unemploy_rate * 100 if unemploy_rate < 0.15
	}
	

	// order and sort 
	order county ym 
	sort ym

	// save
	save "${dir_root}/oregon_page`n'.dta", replace

	// issues to consider
	*foreach var in issuance households persons {
	*foreach var in abawd_persons medical_exempt abawd_vol other_exempt total_exempt perc_exempt mandabawds_voced mandabawds_workfare mandabawds_other mandabawds_total mandabawds_perc /*abawd_totalcaffshhs*/ abawd_totalssphhs {
	foreach var in pop_by_county est_persons_below_poverty est_pop_under_age18 unemploy_rate est_clients_served total_expend tanf_children_per1000 tanf_persons_per1000  snap_persons_per1000  nonassist_persons   persons  households   issuance oaa_med_elig_persons ab_med_elig_persons ad_med_elig_persons total_med_elig_persons  ohpqmgsmb_med_needycancer  ga_med_elig_persons  child_hlthins_elig_persons  empdaycare_cases  empdaycare_children  empdaycare_expenditure pre_ssissdi_cases pre_ssissdi_expend {
		tab ym if missing(`var')
	}
	
check
*} // end page loop

**KP: eventually combine data across pages

/*
// order and sort 
order fips county ym 
sort fips ym

// save
save "${dir_root}/oregon.dta", replace 

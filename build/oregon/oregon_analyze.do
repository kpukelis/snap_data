// oregon_analyze.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/oregon"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

*local beginning_clock1 		= ym(2013,1) - 0.5
local beginning_clock1 			= ym(2012,12) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 		= ym(2016,1) - 0.5
local beginning_clock2			= ym(2015,12) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1
local beginning_clock3 		= ym(2019,1) - 0.5
local expected_clock3 			= `beginning_clock3' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2006,1)
*local start_graph				ym(2012,1)
local ytitle_size 				small
*local num_counties 				= 
local page 						= 2 // for now, 1 or 2
*********************************************
// statewide graphs 
/*
use "${dir_root}/oregon_page`page'.dta", clear
keep if county == "state total"
foreach var in issuance households persons {
	rename `var' statetotal_`var'
}
drop county
save "${dir_root}/oregon_page`page'_statetotalTEMP.dta", replace


*use "${dir_root}/oregon.dta", clear
**KP: THIS IS PRELIMINARY, NOT SURE IF I'M INCLUDING ANY DOUBLE COUNTS HERE
**KP: ALSO SHOULD CHECK TO SEE WHEN DATA SWITCHES FROM CAF TO SSP ON PAGE 1 AND IF THAT MATTERS
use "${dir_root}/oregon_page`page'.dta", clear
drop if inlist(county,"state total","teen parents")

**KP: this is for when county level data is used later. page 1 is office-level data, I believe
*tab county if !inlist(county,"baker","benton","clackamas","clatsop","columbia","coos","crook","curry","deschutes")| inlist(county,"douglas","gilliam","grant","harney","hood river","jackson","jefferson","josephine","klamath")| inlist(county,"lake","lane","lincoln","linn","malheur","marion","morrow","multnomah","polk")| inlist(county,"sherman","tillamook","umatilla","union","wallowa","wasco","washington","wheeler","yamhill")
*keep if inlist(county,"baker","benton","clackamas","clatsop","columbia","coos","crook","curry","deschutes")| inlist(county,"douglas","gilliam","grant","harney","hood river","jackson","jefferson","josephine","klamath")| inlist(county,"lake","lane","lincoln","linn","malheur","marion","morrow","multnomah","polk")| inlist(county,"sherman","tillamook","umatilla","union","wallowa","wasco","washington","wheeler","yamhill")

collapse (sum) issuance households persons, by(ym)

// see how well actual state total matches up
*merge 1:1 ym using "${dir_root}/oregon_page`page'_statetotalTEMP.dta"
**KP: page 1,2, numbers are very close for inrange(ym,ym(2015,9),ym(2019,8))

**KP: move this elsewhere later
label var persons "SNAP persons"
label var households "SNAP households"
label var issuance "SNAP issuance"

foreach outcome in persons households issuance {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		msize(vsmall) ///
		xline(`expected_clock1') xline(`expected_clock2') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw_page`page'.png", replace as(png)

}

dis in red `expected_clock2'
*/

*********************************************
// statewide graphs 
local page = 3

/* NOT RUNNING THIS PART
use "${dir_root}/oregon_page`page'.dta", clear
keep if county == "state total"
foreach var in abawd_persons medical_exempt abawd_vol other_exempt total_exempt perc_exempt mandabawds_voced mandabawds_workfare mandabawds_other mandabawds_total mandabawds_perc abawd_totalssphhs {
	rename `var' statetotal_`var'
}
drop county
save "${dir_root}/oregon_page`page'_statetotalTEMP.dta", replace


*use "${dir_root}/oregon.dta", clear
**KP: THIS IS PRELIMINARY, NOT SURE IF I'M INCLUDING ANY DOUBLE COUNTS HERE
**KP: ALSO SHOULD CHECK TO SEE WHEN DATA SWITCHES FROM CAF TO SSP ON PAGE 1 AND IF THAT MATTERS
use "${dir_root}/oregon_page`page'.dta", clear
drop if inlist(county,"state total","teen parents")

**KP: this is for when county level data is used later. page 1 is office-level data, I believe
*tab county if !inlist(county,"baker","benton","clackamas","clatsop","columbia","coos","crook","curry","deschutes")| inlist(county,"douglas","gilliam","grant","harney","hood river","jackson","jefferson","josephine","klamath")| inlist(county,"lake","lane","lincoln","linn","malheur","marion","morrow","multnomah","polk")| inlist(county,"sherman","tillamook","umatilla","union","wallowa","wasco","washington","wheeler","yamhill")
*keep if inlist(county,"baker","benton","clackamas","clatsop","columbia","coos","crook","curry","deschutes")| inlist(county,"douglas","gilliam","grant","harney","hood river","jackson","jefferson","josephine","klamath")| inlist(county,"lake","lane","lincoln","linn","malheur","marion","morrow","multnomah","polk")| inlist(county,"sherman","tillamook","umatilla","union","wallowa","wasco","washington","wheeler","yamhill")

collapse (sum) abawd_persons medical_exempt abawd_vol other_exempt total_exempt perc_exempt mandabawds_voced mandabawds_workfare mandabawds_other mandabawds_total mandabawds_perc abawd_totalssphhs, by(ym)

// see how well actual state total matches up
merge 1:1 ym using "${dir_root}/oregon_page`page'_statetotalTEMP.dta"

foreach var in abawd_persons medical_exempt abawd_vol other_exempt total_exempt perc_exempt mandabawds_voced mandabawds_workfare mandabawds_other mandabawds_total mandabawds_perc abawd_totalssphhs {
	order statetotal_`var', before(`var')
}
check
**KP: page 3 not the same, but we do have state totals, so just use those for now
*/
/*

use "${dir_root}/oregon_page`page'.dta", clear
keep if county == "state total"

**KP: move this elsewhere later
label var abawd_persons "ABAWD persons"
label var medical_exempt "Medical exempt"
label var abawd_vol "ABAWD vol"
label var other_exempt "Other exempt"
label var total_exempt "Total exempt"
label var perc_exempt "% exempt"
label var mandabawds_voced "Mandatory ABAWDs: Voc Ed"
label var mandabawds_workfare "Mandatory ABAWDs: Workfare"
label var mandabawds_other "Mandatory ABAWDs: Other"
label var mandabawds_total "Mandatory ABAWDs: Total"
label var mandabawds_perc "Mandatory ABAWDs: %"
label var abawd_totalssphhs "Total SSP SNAP HH's"

**KP: something is weird with data from ym(2015,7) so dropping it for now
drop if ym == ym(2015,7)

foreach outcome in abawd_persons medical_exempt abawd_vol other_exempt total_exempt perc_exempt mandabawds_voced mandabawds_workfare mandabawds_other mandabawds_total mandabawds_perc abawd_totalssphhs {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		msize(vsmall) ///
		xline(`beginning_clock1',lcolor(blue)) xline(`beginning_clock2',lcolor(blue)) xline(`beginning_clock3',lcolor(blue)) ///
		xline(`expected_clock1',lcolor(red)) xline(`expected_clock2',lcolor(red)) xline(`expected_clock3',lcolor(red)) ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
	graph export "${dir_graphs}/`outcome'_raw_page`page'.png", replace as(png)

}

*/
*********************************************
// statewide graphs 
local page = 5

/*
use "${dir_root}/oregon_page`page'.dta", clear
keep if county == "state total"
foreach var in abawd_persons medical_exempt abawd_vol other_exempt total_exempt perc_exempt mandabawds_voced mandabawds_workfare mandabawds_other mandabawds_total mandabawds_perc abawd_totalssphhs {
	rename `var' statetotal_`var'
}
drop county
save "${dir_root}/oregon_page`page'_statetotalTEMP.dta", replace


*use "${dir_root}/oregon.dta", clear
**KP: THIS IS PRELIMINARY, NOT SURE IF I'M INCLUDING ANY DOUBLE COUNTS HERE
**KP: ALSO SHOULD CHECK TO SEE WHEN DATA SWITCHES FROM CAF TO SSP ON PAGE 1 AND IF THAT MATTERS
use "${dir_root}/oregon_page`page'.dta", clear
drop if inlist(county,"state total","teen parents")

**KP: this is for when county level data is used later. page 1 is office-level data, I believe
*tab county if !inlist(county,"baker","benton","clackamas","clatsop","columbia","coos","crook","curry","deschutes")| inlist(county,"douglas","gilliam","grant","harney","hood river","jackson","jefferson","josephine","klamath")| inlist(county,"lake","lane","lincoln","linn","malheur","marion","morrow","multnomah","polk")| inlist(county,"sherman","tillamook","umatilla","union","wallowa","wasco","washington","wheeler","yamhill")
*keep if inlist(county,"baker","benton","clackamas","clatsop","columbia","coos","crook","curry","deschutes")| inlist(county,"douglas","gilliam","grant","harney","hood river","jackson","jefferson","josephine","klamath")| inlist(county,"lake","lane","lincoln","linn","malheur","marion","morrow","multnomah","polk")| inlist(county,"sherman","tillamook","umatilla","union","wallowa","wasco","washington","wheeler","yamhill")

collapse (sum) abawd_persons medical_exempt abawd_vol other_exempt total_exempt perc_exempt mandabawds_voced mandabawds_workfare mandabawds_other mandabawds_total mandabawds_perc abawd_totalssphhs, by(ym)

// see how well actual state total matches up
merge 1:1 ym using "${dir_root}/oregon_page`page'_statetotalTEMP.dta"

foreach var in abawd_persons medical_exempt abawd_vol other_exempt total_exempt perc_exempt mandabawds_voced mandabawds_workfare mandabawds_other mandabawds_total mandabawds_perc abawd_totalssphhs {
	order statetotal_`var', before(`var')
}
check
**KP: page 3 not the same, but we do have state totals, so just use those for now
*/

/*
use "${dir_root}/oregon_page`page'.dta", clear
keep if county == "state total"

**KP: move this elsewhere later
label var nonassist_persons "SNAP - non-assist persons"
label var persons "SNAP - persons"
label var households "SNAP - households"
label var issuance "SNAP - issuance"
label var oaa_med_elig_persons "Adult programs - OAA Med eligible persons"
label var ab_med_elig_persons "Adult programs - AB Med eligible persons"
label var ad_med_elig_persons "Adult programs - AD Med eligible persons"
label var total_med_elig_persons "Adult programs - Total Adult Med eligible persons"
label var ohpqmgsmb_med_needycancer "OHP, QMG, SMB Med Neey Caner, Sub Adopt"
label var ga_med_elig_persons  "GA Med eligible persons"
label var child_hlthins_elig_persons "Children's health insurance program eligible persons"
label var empdaycare_cases "Employment-related daycare - cases"
label var empdaycare_children "Employment-related daycare - children"
label var empdaycare_expenditure "Employment-related daycare - expenditure"
label var pop_by_county "Population by county"
label var est_persons_below_poverty "Estimated persons below poverty"
label var est_pop_under_age18 "Estimated population under 18"
label var unemploy_rate "Unemployment rate"
label var est_clients_served "Estimated clients served"
label var total_expend "Total expenditure"
label var tanf_children_per1000 "TANF Basic - children per thousand children"
label var tanf_persons_per1000 "TANF Basic - persons per thousand persons"
label var snap_persons_per1000 "SNAP persons per thousand persons"
label var pre_ssissdi_cases "State family pre-SSI/SSDI - cases"
label var pre_ssissdi_expend  "State family pre-SSI/SSDI - expenditure"

foreach outcome in nonassist_persons persons households issuance oaa_med_elig_persons ab_med_elig_persons ad_med_elig_persons total_med_elig_persons ohpqmgsmb_med_needycancer ga_med_elig_persons child_hlthins_elig_persons empdaycare_cases empdaycare_children empdaycare_expenditure pop_by_county est_persons_below_poverty est_pop_under_age18 unemploy_rate est_clients_served total_expend tanf_children_per1000 tanf_persons_per1000 snap_persons_per1000 pre_ssissdi_cases pre_ssissdi_expend {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		msize(vsmall) ///
		xline(`expected_clock1',lcolor(red)) xline(`expected_clock2',lcolor(red)) xline(`expected_clock3',lcolor(red)) ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color'))
		/*xline(`beginning_clock1',lcolor(blue)) xline(`beginning_clock2',lcolor(blue)) xline(`beginning_clock3',lcolor(blue)) /// */

	graph export "${dir_graphs}/`outcome'_raw_page`page'.png", replace as(png)

}
*/
****************************************************
// by county waiver or not, as of 2019

import excel using "C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_exempt counties/oregon/oregon_county_exemption.xlsx", sheet("Sheet1") firstrow clear
save "${dir_root}/oregon_exemptions.dta", replace

use "${dir_root}/oregon_page`page'.dta", clear
merge m:1 county using "${dir_root}/oregon_exemptions.dta"
assert _m == 3
drop _m 
// this is just county level analysis
drop if county == "state total"
drop if county == "adj/ohp/sbg"


#delimit ;
collapse (sum) 
nonassist_persons
persons
households
issuance
oaa_med_elig_persons
ab_med_elig_persons
ad_med_elig_persons
total_med_elig_persons
ohpqmgsmb_med_needycancer
ga_med_elig_persons
child_hlthins_elig_persons
empdaycare_cases
empdaycare_children
empdaycare_expenditure
est_persons_below_poverty
est_pop_under_age18
est_clients_served
total_expend
pop_by_county
pre_ssissdi_cases
pre_ssissdi_expend
, by(ym waiver2019)
;
#delimit cr 

#delimit ;
foreach outcome in 
nonassist_persons
persons
households
issuance
oaa_med_elig_persons
ab_med_elig_persons
ad_med_elig_persons
total_med_elig_persons
ohpqmgsmb_med_needycancer
ga_med_elig_persons
child_hlthins_elig_persons
empdaycare_cases
empdaycare_children
empdaycare_expenditure
est_persons_below_poverty
est_pop_under_age18
est_clients_served
total_expend
pop_by_county
pre_ssissdi_cases
pre_ssissdi_expend
{
;
#delimit cr 
	// graph
	twoway (connected `outcome' ym if ym >= `start_graph' & waiver2019 == 0, msize(vsmall) yaxis(1)) ///
		   (connected `outcome' ym if ym >= `start_graph' & waiver2019 == 1, msize(vsmall) yaxis(2) ///
		legend(label(1 "No county waiver (left axis)") label(2 "County waiver (left axis)") region(lstyle(none))) ///
		xline(`expected_clock1') xline(`expected_clock2') xline(`expected_clock3') ///
		xtitle(`""') ///
		title(`""') ///
		caption(`"Vertical lines at expected effect."') ///
		graphregion(fcolor(`background_color')) ///
		)
	graph export "${dir_graphs}/page`n'_`outcome'_raw_bywaiver.png", replace as(png)
}


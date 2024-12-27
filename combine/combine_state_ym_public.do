// combine_state_ym_public.do
// Kelsey Pukelis
// 2024-12-26
// create public version of state-level data

// keep varlist  -- copied from combine_state_ym.do, with modifications
	#delimit ;
	local keep_varlist_abridged
	households
	individuals
	issuance
	adults
	children
	infants
	elderly
	disabled
	gender_female
	gender_male
	/*
	female_00_05 
	female_06_17 
	female_18_34 
	female_35_49 
	female_50_64 
	female_65plus 
	male_00_05 
	male_06_17 
	male_18_34 
	male_35_49 
	male_50_64 
	male_65plus 
	*/
	ethnicity_hispanic
	ethnicity_nonhispanic
	race_africanamericanorblack
	race_asian
	race_morethanonerace
	race_nativeamericanoralaskanna
	race_nativehawaiianorpacificis
	race_unknownnotdeclared
	race_white
	apps_received
	apps_approved
	apps_processed
	apps_denied
	apps_denied_needbased
	apps_denied_procedural
 	/*don't include; California only*/
    /*
    apps_denied_untimely
    apps_denied_untimely_f
    */
    /*don't include; New Mexico only*/
    /*
    apps_withdrawn
    */
	/*apps_delinquent*/
	apps_expedited
	apps_expedited_elig
	apps_expedited_notelig
	/**/
	apps_timely 
	apps_untimely
    /*don't include; can calculate*/
    /*
    apps_timely_perc
    */
    apps_expedited_timely
	apps_expedited_untimely
    /*don't include; North Carolina only*/
    /*
    apps_notexpedited_timely
    apps_notexpedited_untimely
    */
	/*don't include; California only*/
	/*
	households_carryover_start
	households_new 
	households_new_apps
	households_new_change_pacfnacf
	households_new_change_county
	households_new_reinstated
	households_new_other
	*/
	/**/
	recerts
	recerts_approved
	recerts_denied
	recerts_denied_proc
	recerts_denied_need
 	recerts_disposed
 	recerts_elig 
 	/*recerts_inelig*/
 	recerts_overdue
	firsttimehouseholds
	churn_rate
	/**/
	tanf_households
	tanf_individuals
	tanf_issuance
	tanf_children
	tanf_adults
	tanf_elderly
	tanf_disabled
	tanf_apps_received
	tanf_apps_approved
	tanf_apps_denied
	tanf_cases_closed
	medicaid_households
	medicaid_individuals
	medicaid_children
	medicaid_elderly_disabled
	medicaid_apps_received
	medicaid_apps_approved
	/*
	childcare_children
	childcare_households
	eaedc_individuals
	eaedc_households
	eaedc_children
	eaedc_elderly
	eaedc_disabled
	*/
	/**/
	walk_in_visitors_daily_avg
	walk_in_visitors_avg_waittime
	reason_walkin_accesstodocs
	reason_walkin_cashapp
	reason_walkin_snapapp
	reason_walkin_docprocess
	reason_walkin_ebtcard
	reason_walkin_speaktostaff
	reason_walkin_pebt
	reason_walkin_recert
	reason_walking_other
	calls_daily_avg
	calls_daily_avg_endivr
	calls_daily_avg_connect
	calls_daily_avg_noconnect
	calls_avg_waittime_min
	calls_avg_waittime_sec
	app_avg_processing_days
	apps_received_walkin
	apps_received_dropoff
	apps_received_mailin
	apps_received_fax
	apps_received_masshealthcheck
	apps_received_web
	apps_received_telephone
	apps_received_tanf_inoffice
	apps_received_tanf_homevisit
	apps_received_tanf_mailinfax
	apps_received_tanf_web
	apps_received_tanf_telephone
	/*
	apps_received_eaedc_inoffice
	apps_received_eaedc_homevisit
	apps_received_eaedc_mailinfax
	apps_received_eaedc_web
	apps_received_eaedc_telephone
	apps_received_eaedc
	*/
	c_1_statetotal
	c_2_earnedincometotal
	c_2_othereligibilitytotal
	c_2_otherreasonstotal
	c_2_proceduralreasonstotal
	c_2_sanctionreasonstotal
	c_2_unearnedincometotal
	c_2_voluntarywithdrawal
	c_3_abawdindividualfailedtomeet
	c_3_changeinstatelaworpolicy
	c_3_citizenshipnotmet
	c_3_clientrequest
	c_3_convictedofipv
	c_3_deathofapplicantheadofhouse
	c_3_decreaseneedorexpenses
	c_3_doesnotpurchasepreparemeals
	c_3_doesnotreceivessi
	c_3_drugconviction
	c_3_expiredredetermination
	c_3_failednetincometest
	c_3_failedrefusedtoprovideverif
	c_3_failedtocomplywithlajet
	c_3_failedtocomplywithlwc
	c_3_failedtokeepappointment
	c_3_failedtoprovidecompletesemi
	c_3_failedtoregisterforworkhire
	c_3_failedtotimelyreapply
	c_3_failureduetoeandtsanction
	c_3_failureduetovoluntarywithdr
	c_3_grossinceligibilitynetexcee
	c_3_grossincomeineligible
	c_3_headofhhpayeelefthome
	c_3_householdmemberdisqualified
	c_3_includedinanothercertificat
	c_3_increaseinchildsupport
	c_3_increaseincontributions
	c_3_increaseinotherfederalbenef
	c_3_increaseinotherstatebenefit
	c_3_increaseinsocialsecurityors
	c_3_increaseinwagesornewemploym
	c_3_individualdoesnotmeetagereq
	c_3_individualdoesnotmeetprogra
	c_3_institutionalizationincarce
	c_3_livingwithchildunderage22la
	c_3_livingwithspouselacaponly
	c_3_movedoutofstate
	c_3_noeligiblechildmemberintheh
	c_3_nolongerinlivingarrangement
	c_3_notaonepersonhouseholdineli
	c_3_originallyineligible
	c_3_otherdisasterclosuresinclud
	c_3_questionableinformationnotp
	c_3_refusedtocomplywitheligibil
	c_3_refusedtocomplywithpres
	c_3_refusedtocomplywithqualityc
	c_3_residenceoutofparish
	c_3_residencerequirementnotmet
	c_3_resourcesoverlimit
	c_3_selectedregularfsbecauseofe
	c_3_transferredresources
	c_3_unabletolocate
	c_3_voluntaryquitwithoutgoodcau
	;
	#delimit cr


// load data
use "${dir_root}/data/state_data/state_ym.dta", clear

// replace state with proper capitalization
replace state = "new hampshire" if state == "newhampshire"
replace state = "new jersey" if state == "newjersey"
replace state = "new mexico" if state == "newmexico"
replace state = "new york" if state == "newyork"
replace state = "north carolina" if state == "northcarolina"
replace state = "north dakota" if state == "northdakota"
replace state = "rhode island" if state == "rhodeisland"
replace state = "south carolina" if state == "southcarolina"
replace state = "south dakota" if state == "southdakota"
replace state = "west virginia" if state == "westvirginia"
replace state = proper(state)

// merge in state abbreviation, state fips code 
statastates, name(state)
assert inlist(_m,2,3)
drop if _m == 2
drop _m 
replace state = proper(state)
replace state = "District of Columbia" if state == "District Of Columbia"
rename state_fips statefips 
order state state_abbrev statefips 

// keep only vars I want 
keep state state_abbrev statefips ym `keep_varlist_abridged'
// individuals households issuance adults children apps_received apps_approved apps_denied infants elderly disabled gender_* ethnicity_* race_*

// drop observations that don't have info 
dropmiss `keep_varlist_abridged', force obs 
// adults children apps_received apps_approved apps_denied infants elderly disabled gender_* ethnicity_* race_*, force obs 

// rename to shorten 
rename recerts_denied_procedural recerts_denied_proc
rename recerts_denied_needbased recerts_denied_need 

// assert level of the data 
duplicates tag statefips ym, gen(dup)
assert dup == 0
drop dup 

// generate year and month vars 
gen year = year(dofm(ym))
gen month = month(dofm(ym))

// make sure variables are not missing
assert !missing(state)
assert !missing(state_abbrev)
assert !missing(statefips)
assert !missing(ym)
assert !missing(year)
assert !missing(month)

// order and sort 
order state state_abbrev statefips ym year month `keep_varlist_abridged'
sort statefips ym 

// label vars
label var state "State name"
label var state_abbrev "State abbreviation"
label var statefips "State FIPS code"
label var ym "Year and month"
label var year "Year"
label var month "Month"
label var individuals "Individuals enrolled in SNAP"
label var households "Households enrolled in SNAP"
label var issuance "Total SNAP benefits issued"
label var adults "Adults enrolled in SNAP"
label var children "Children enrolled in SNAP"
label var apps_received "SNAP applications received"
label var apps_approved "SNAP applications approved"
label var apps_denied "SNAP applications denied"
label var apps_denied_needbased "SNAP applications denied for a need-based/eligibility reason"
label var apps_denied_procedural "SNAP applications denied for a procedural reason"
label var apps_expedited "SNAP applications, expedited service"
label var apps_processed "SNAP applications processed this month"
label var apps_timely "SNAP applications processed within timely manner"
label var apps_untimely "SNAP applications processed within untimely manner"
// label var apps_timely_perc "SNAP applications processed within timely manner, as share of SNAP apps processed"
// label var apps_withdrawn "SNAP applications withdrawn"
label var apps_expedited_timely "SNAP expedited applications processed within timely manner"
label var apps_expedited_untimely "SNAP expedited applications processed within untimely manner"
// label var apps_notexpedited_timely "SNAP non-expedited applications processed within timely manner"
// label var apps_notexpedited_untimely "SNAP non-expedited applications processed within untimely manner"
label var apps_expedited_elig "SNAP expedited applications - found eligible for expedited service" 
label var apps_expedited_notelig "SNAP expedited applications - found not eligible for expedited service" 
// label var apps_denied_untimely "" 
// label var apps_denied_untimely_f "" 
label var recerts "SNAP recertifications"
label var recerts_approved "SNAP recertifications approved"
label var recerts_denied "SNAP recertifications denied"
label var recerts_denied_need "SNAP recertifications denied for a need-based/eligibility reason"
label var recerts_denied_proc "SNAP recertifications denied for a procedural reason"
label var recerts_disposed "SNAP recertifications disposed of during the month" 
label var recerts_elig "SNAP recertifications determined continuing eligible"
label var recerts_overdue "SNAP recertifications overdue during the month"
// label var recerts_inelig_f "" 
label var disabled "SNAP enrollment - disabled" // **KP: households or individuals?
label var elderly "SNAP enrollment - elderly" // **KP: households or individuals?
label var infants "SNAP enrollment - infants" // **KP: households or individuals?
label var tanf_households "Households enrolled in TANF"
label var tanf_adults "Adults enrolled in TANF"
label var tanf_children "Children enrolled in TANF"
label var tanf_individuals "Individuals enrolled in TANF"
label var tanf_issuance "Total TANF benefits issued"
label var tanf_apps_received "TANF applications received"
label var tanf_apps_approved "TANF applications approved"
label var tanf_apps_denied "TANF applications denied"
label var tanf_cases_closed "TANF cases closed"
label var medicaid_apps_received "Medicaid applications received"
label var medicaid_households "Medicaid households"
label var medicaid_individuals "Medicaid individuals"
label var medicaid_children "Medicaid children"
label var medicaid_elderly_disabled "Medicaid elderly and disabled"
label var medicaid_apps_approved "Medicaid applications approved" 
// label var households_carryover_start ""
// label var households_new ""
// label var households_new_apps ""
// label var households_new_change_pacfnacf ""
// label var households_new_change_county ""
// label var households_new_reinstated ""
// label var households_new_other ""
label var firsttimehouseholds "Households on SNAP for the first time"
label var churn_rate "SNAP churn rate"


label var gender_female "SNAP enroll. gender: Female"
label var gender_male "SNAP enroll. gender: Male"
label var ethnicity_his "SNAP enroll. ethnicity: Hispanic"
label var ethnicity_non "SNAP enroll. ethnicity: Non Hispanic"
label var race_africana "SNAP enroll. race: African American or Black"
label var race_asian "SNAP enroll. race: Asian"
label var race_morethan "SNAP enroll. race: More than one race"
label var race_nativeam "SNAP enroll. race: Native American or Alaska Native"
label var race_nativeha "SNAP enroll. race: Native Hawaiian or Pacific Islander"
label var race_unknownn "SNAP enroll. race: Unknown / Not declared"
label var race_white "SNAP enroll. race: White"

label var calls_avg_waittime_min "Calls, average wait time (minutes)"
label var calls_avg_waittime_sec "Calls, average wait time (seconds)"
label var app_avg_processing_days "SNAP apps, average days to process"
label var apps_received_walkin "SNAP apps received: walk in"
label var apps_received_dropoff "SNAP apps received: drop off"
label var apps_received_mailin "SNAP apps received: mailed in"
label var apps_received_fax "SNAP apps received: faxed"
label var apps_received_masshealthcheck "SNAP apps received: checkbox on MassHealth app"
label var apps_received_web "SNAP apps received: web"
label var apps_received_telephone "SNAP apps received: telephone"
label var apps_received_tanf_inoffice "TANF apps received: in office"
label var apps_received_tanf_homevisit "TANF apps received: home visit"
label var apps_received_tanf_mailinfax "TANF apps received: mail in or fax"
label var apps_received_tanf_web "TANF apps received: web"
label var apps_received_tanf_telephone "TANF apps received: telephone"
label var c_1_statetotal "LA Closures: state total"
label var c_2_earnedincometotal "LA Closures: earned income total"
label var c_2_othereligibilitytotal "LA Closures: other eligibility total"
label var c_2_otherreasonstotal "LA Closures: other reasons total"
label var c_2_proceduralreasonstotal "LA Closures: procedural reasons total"
label var c_2_sanctionreasonstotal "LA Closures: sanction reasons total"
label var c_2_unearnedincometotal "LA Closures: unearned income total"
label var c_2_voluntarywithdrawal "LA Closures: voluntary withdrawal"
label var c_3_abawdindividualfailedtomeet "LA Closures: abawd individual failed to meet requirements to work 20 hrs/week"
label var c_3_changeinstatelaworpolicy "LA Closures: change in state law or policy"
label var c_3_citizenshipnotmet "LA Closures: citizenship not met"
label var c_3_clientrequest "LA Closures: client request"
label var c_3_convictedofipv "LA Closures: convicted of ipv"
label var c_3_deathofapplicantheadofhouse "LA Closures: death of applicant/head of household"
label var c_3_decreaseneedorexpenses "LA Closures: decrease need or expenses"
label var c_3_doesnotpurchasepreparemeals "LA Closures: does not purchase prepare meals separately"
label var c_3_doesnotreceivessi "LA Closures: does not receive ssi"
label var c_3_drugconviction "LA Closures: drug conviction"
label var c_3_expiredredetermination "LA Closures: expired redetermination"
label var c_3_failednetincometest "LA Closures: failed net income test"
label var c_3_failedrefusedtoprovideverif "LA Closures: failed/refused to provide verification"
label var c_3_failedtocomplywithlajet "LA Closures: failed to comply with lajet"
label var c_3_failedtocomplywithlwc "LA Closures: failed to comply with lwc"
label var c_3_failedtokeepappointment "LA Closures: failed to keep appointment"
label var c_3_failedtoprovidecompletesemi "LA Closures: failed to provide complete semi-annual rpt by due dat"
label var c_3_failedtoregisterforworkhire "LA Closures: failed to register for work - hire"
label var c_3_failedtotimelyreapply "LA Closures: failed to timely reapply"
label var c_3_failureduetoeandtsanction "LA Closures: failure due to e&t sanction"
label var c_3_failureduetovoluntarywithdr "LA Closures: failure due to voluntary withdrawal"
label var c_3_grossinceligibilitynetexcee "LA Closures: gross inc. eligibility net exceeds limit"
label var c_3_grossincomeineligible "LA Closures: gross income ineligible"
label var c_3_headofhhpayeelefthome "LA Closures: head of hh (payee) left home"
label var c_3_householdmemberdisqualified "LA Closures: household member disqualified"
label var c_3_includedinanothercertificat "LA Closures: included in another certification"
label var c_3_increaseinchildsupport "LA Closures: increase in child support"
label var c_3_increaseincontributions "LA Closures: increase in contributions"
label var c_3_increaseinotherfederalbenef "LA Closures: increase in other federal benefits"
label var c_3_increaseinotherstatebenefit "LA Closures: increase in other state benefits"
label var c_3_increaseinsocialsecurityors "LA Closures: increase in social security or ssi"
label var c_3_increaseinwagesornewemploym "LA Closures: increase in wages or new employment"
label var c_3_individualdoesnotmeetagereq "LA Closures: age requirement not met"
label var c_3_individualdoesnotmeetprogra "LA Closures: individual does not meet program requirement"
label var c_3_institutionalizationincarce "LA Closures: institutionalization/incarceration"
label var c_3_livingwithchildunderage22la "LA Closures: living with child under age 22 (lacap only)"
label var c_3_livingwithspouselacaponly "LA Closures: living with spouse (lacap only)"
label var c_3_movedoutofstate "LA Closures: moved out of state"
label var c_3_noeligiblechildmemberintheh "LA Closures: no eligible child/member in the home"
label var c_3_nolongerinlivingarrangement `"LA Closures: no longer in living arrangement code "a""'
label var c_3_notaonepersonhouseholdineli "LA Closures: not a one person household ineligible for lacap"
label var c_3_originallyineligible "LA Closures: originally ineligible"
label var c_3_otherdisasterclosuresinclud "LA Closures: other (disaster closures included)"
label var c_3_questionableinformationnotp "LA Closures: questionable information not provided"
label var c_3_refusedtocomplywitheligibil "LA Closures: refused to comply with eligibility requirement"
label var c_3_refusedtocomplywithpres "LA Closures: refused to comply with pres"
label var c_3_refusedtocomplywithqualityc "LA Closures: refused to comply with qc"
label var c_3_residenceoutofparish "LA Closures: residence out of parish"
label var c_3_residencerequirementnotmet "LA Closures: residence requirement not met"
label var c_3_resourcesoverlimit "LA Closures: resources over limit"
label var c_3_selectedregularfsbecauseofe "LA Closures: selected regular fs because of excess shelter or medic"
label var c_3_transferredresources "LA Closures: transferred resources"
label var c_3_unabletolocate "LA Closures: unable to locate"
label var c_3_voluntaryquitwithoutgoodcau "LA Closures: voluntary quit without good cause"
 
// save 
save "${dir_root}/data/state_data/state_ym_public.dta", replace 
 
 
// log which vars are covered 
set linesize 200
capture log close 
*log using "${dir_logs}/state_variable_coverage_public.log", replace 
foreach var of varlist _all {
  display in red "`var'"
  tab state if !missing(`var')
}
capture log close 

// log which time periods are covered
set linesize 200
capture log close 
*log using "${dir_logs}/state_time_coverage_public.log", replace 
levelsof state, local(states)
foreach state of local states {
	display in red "`state'"
	preserve
		qui keep if state == "`state'"
		qui dropmiss, force
		qui dropmiss, force obs 
		qui describe, varlist 
		dis in red "`r(varlist)'"
		*tab ym 
		sort ym 
		list ym if _n == 1
		qui sum ym if _n == 1
		local ym_min = `r(mean)'
		gsort -ym 
		list ym if _n == 1
		qui sum ym if _n == 1
		local ym_max = `r(mean)'
	restore 

}
log close 
check 

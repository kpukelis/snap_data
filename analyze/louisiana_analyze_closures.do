// louisiana_analyze_closures.do
// Kelsey Pukelis

use "${dir_root}/data/state_data/louisiana/louisiana.dta", clear 

keep if county == "total"
*keep if ym >= ym(2000,1)
keep if ym >= ym(2017,1)



/*
#delimit ; 
twoway 	(connected c_1_statetotal* ym, msize(tiny) yaxis(1))
		(connected c_2_applicationwithdrawal ym, msize(tiny) yaxis(2))
		(connected c_2_earnedincometotal ym, msize(tiny) yaxis(3))
		(connected c_2_othereligibilitytotal ym, msize(tiny) yaxis(2))
		(connected c_2_otherreasonstotal ym, msize(tiny) yaxis(3))
		(connected c_2_proceduralreasonstotal ym, msize(tiny) yaxis(1))
		(connected c_2_sanctionreasonstotal ym, msize(tiny) yaxis(3))
		(connected c_2_unearnedincometotal ym, msize(tiny) yaxis(2))
		(connected c_2_voluntarywithdrawal ym, msize(tiny) yaxis(2))
;
#delimit cr 								

#delimit ; 
twoway 	(connected c_1_statetotal* ym, msize(tiny) yaxis(1))
		(connected c_2_applicationwithdrawal ym, msize(tiny) yaxis(2))
		(connected c_2_earnedincometotal ym, msize(tiny) yaxis(2))
		(connected c_2_othereligibilitytotal ym, msize(tiny) yaxis(2))
		(connected c_2_otherreasonstotal ym, msize(tiny) yaxis(2))
		(connected c_2_proceduralreasonstotal ym, msize(tiny) yaxis(2))
		(connected c_2_sanctionreasonstotal ym, msize(tiny) yaxis(2))
		(connected c_2_unearnedincometotal ym, msize(tiny) yaxis(2))
		(connected c_2_voluntarywithdrawal ym, msize(tiny) yaxis(2))
;
#delimit cr 
check	
*/
/*
#delimit ;
twoway
		(connected c_3_failedtotimelyreapply ym, msize(tiny) yaxis(1))
		(connected c_3_failedtoprovidecompletesemi ym, msize(tiny) yaxis(1))
		(connected c_3_failedrefusedtoprovideverif ym, msize(tiny) yaxis(1))
		(connected c_3_grossincomeineligible ym, msize(tiny) yaxis(1))
		(connected c_3_otherdisasterclosuresinclud ym, msize(tiny) yaxis(1))
		(connected c_3_failedtokeepappointment ym, msize(tiny) yaxis(1))
		(connected c_3_grossinceligibilitynetexcee ym, msize(tiny) yaxis(1))
		(connected c_3_deathofapplicantheadofhouse ym, msize(tiny) yaxis(1))
		(connected c_3_movedoutofstate ym, msize(tiny) yaxis(1))
		(connected c_3_refusedtocomplywitheligibil ym, msize(tiny) yaxis(1))
		(connected c_3_householdmemberdisqualified ym, msize(tiny) yaxis(1))
		(connected c_3_noeligiblechildmemberintheh ym, msize(tiny) yaxis(1))
		(connected c_3_doesnotreceivessi ym, msize(tiny) yaxis(1))
		(connected c_3_institutionalizationincarce ym, msize(tiny) yaxis(1))
		(connected c_3_failedtocomplywithlajet ym, msize(tiny) yaxis(1))
		(connected c_3_changeinstatelaworpolicy ym, msize(tiny) yaxis(1))
		(connected c_3_resourcesoverlimit ym, msize(tiny) yaxis(1))
		(connected c_3_questionableinformationnotp ym, msize(tiny) yaxis(1))
		(connected c_3_residencerequirementnotmet ym, msize(tiny) yaxis(1))
		(connected c_3_refusedtocomplywithqualityc ym, msize(tiny) yaxis(1)
		/*legend(off)*/
		)
;
#delimit cr 
*/

********************************************************************
// count as needbased closures: 
	// c_2_earnedincometotal
	// c_2_unearnedincometotal
	// c_2_othereligibilitytotal
	// c_2_otherreasonstotal other reasons, which are really just "client request" (assuming client doesn't need the benefits anymore)
	// c_2_voluntarywithdrawal voluntary withdrawal (again, assuming client doesn't need benefits)

// count as procedural closures: 
	// c_2_proceduralreasonstotal
	// c_2_sanctionreasonstotal sanctions, which are a substantial factor in 2018-2019 and are driven by faiture to comply with work requirements ("LWC" = Louisiana Workforce Commission and HiRE)

egen recert_closure_needbased = rowtotal(c_2_earnedincometotal c_2_unearnedincometotal c_2_othereligibilitytotal c_2_otherreasonstotal c_2_voluntarywithdrawal)
egen recert_closure_procedural = rowtotal(c_2_proceduralreasonstotal c_2_sanctionreasonstotal)

#delimit ; 
twoway 	(connected recert_closure_needbased ym, msize(tiny) yaxis(1))
		(connected recert_closure_procedural ym, msize(tiny) yaxis(1))
;
#delimit cr 


check	
check

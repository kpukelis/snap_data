display in red "state is:"
display in red "${state}"

	// rename to combine 
	capture rename persons 				individuals
	capture rename snap_households 		households 
	capture rename snap_recipients 		individuals
	capture rename issuancehousehold 	avg_issuance_households
	capture rename issuance_percase 	avg_issuance_households
	capture rename avg_pay_per_case 	avg_issuance_households
	capture rename avg_payment_percase 	avg_issuance_households
	capture rename issuanceperson 		avg_issuance_individuals
	capture rename issuance_perrecip	avg_issuance_individuals
	capture rename avg_pay_per_person	avg_issuance_individuals
	*capture drop issuancehousehold
	*capture drop issuance_percase
	*capture drop avg_pay_per_case
	*capture drop avg_payment_percase
	*capture drop issuanceperson
	*capture drop issuance_perrecip
	*capture drop avg_pay_per_person
	capture rename avg_recip_per_case	avg_individuals_households
	*capture drop avg_recip_per_case
	// ***apps_received CA MO TX NM MD LA AK NC CO IN RI TN MA
		// TN
		// some info for 2019-2020, from picture; includes SNAP and TANF combined, but it is estimated that 261,800 / (78,249+96,590+48,860+56,209) = 261,800 / 279,908 = 93.5 % of those are SNAP applications. (Quote from report: "During the months of March 2020 through June 2020, approximately 261,800 applications were received")
		capture rename apps_received_snaptanf apps_received 
		// XX
		capture rename apps_received_snap apps_received
	// apps_received_* MA 
	// ***apps_approved CA MO NM MD LA AK NC
		// XX
		capture rename apps_approved_snap apps_approved
	// ***apps_disposed CA XX 
		// CA 
		capture rename apps_disposed apps_processed
	// apps_delinquent XX
	// ***apps_denied CA MO MD LA AK
		// XX 
		capture rename apps_denied_snap apps_denied
		// calculate for NM, NC
		if inlist("${state}","northcarolina") {
			gen apps_denied = apps_received - apps_approved
		}
	// ***apps_denied_needbased CA NM 
		// CA 
		capture rename apps_denied_reason_inelig apps_denied_needbased
		// NM
		capture rename apps_denied_needbased_calc apps_denied_needbased
	// ***apps_denied_procedural CA NM 
		// CA 
		capture rename apps_denied_reason_procedural apps_denied_procedural
		// NM
		capture rename apps_denied_procedural_calc apps_denied_procedural 
	// ***apps_denied_nottimely CA only
	// ***apps_withdrawn CA
	// ***apps_expedited CA MO CO NM NC AK
	// ***apps_expedited_elig CA only
	// ***apps_expedited_notelig CA only
	// ***apps_timely, ***apps_untimely CA CO NM NC TX - not AK or MO 
		if "${state}" == "california" {
			// apps_nottimely CA - "denominator" here is approved apps
			// apps_denied_nottimely CA 
			egen apps_untimely = rowtotal(apps_nottimely apps_denied_nottimely), missing
			gen apps_timely = apps_received - apps_untimely
		}
		// apps_received_timely CO 
		capture rename apps_received_timely apps_timely
		// apps_received_untimely CO 
		capture rename apps_received_untimely apps_untimely
		// apps_approved_timely NC 
		capture rename apps_approved_timely apps_timely
		// apps_approved_untimely NC 
		capture rename apps_approved_untimely apps_untimely
		// XX 
		capture rename apps_nottimely apps_untimely 
		capture rename apps_nottimely_f apps_untimely_f
		// XX 
		capture rename apps_denied_nottimely apps_denied_untimely
		capture rename apps_denied_nottimely_f apps_denied_untimely_f
		// apps_timely TX
		// pendingdays* AK
		// avg_days_process?? MO - not enough to do anything with 
	// ***apps_timely_perc CO 
		// apps_received_timely_perc CO 
		capture rename apps_received_timely_perc apps_timely_perc 
		// apps_perc_timely TX 
		capture rename apps_perc_timely apps_timely_perc
	// ***apps_expedited_timely NM NC CA
		if "${state}" == "california" {
			egen apps_expedited_timely = rowtotal(apps_expedited_elig_days1_3 apps_expedited_elig_days4_7), missing
		}
	// ***apps_expedited_untimely NM NC CA 
		// apps_expedited_elig_days8 CA 
		capture rename apps_expedited_elig_days8 apps_expedited_untimely
	// ***apps_notexpedited_timely NC 
	// ***apps_notexpedited_untimely NC 
	// ***apps_received_web CA MA
		// CA apps_received_online
		capture rename apps_received_online apps_received_web 	
		// MA apps_received_web
	// ***children MO  TX SD  OR  OH NM NJ LA KS AZ MI (WI) MA 
		// calculate for WI
		if "${state}" == "wisconsin" {
			egen children = rowtotal(female_00_05 male_00_05 female_06_17 male_06_17), missing
		}
	// ***adults  (MO) TX SD (OR) OH NM NJ LA KS AZ MI (WI) MA 
		// calculate for MO, OR, MA 
		if inlist("${state}","missouri","oregon","massachusetts") {
			gen adults = individuals - children
		}
		// calculate for WI
		if "${state}" == "wisconsin" {
			egen adults = rowtotal(female_18_34 male_18_34 female_35_49 male_35_49 female_50_64 male_50_64 female_65plus male_65plus), missing
		}
	// ***generate infants TX OR WI
		// age_00_04 TX
		if "${state}" == "texas" {
			gen infants = age_00_04 	
		}
		// age_0_5 OR
		if "${state}" == "oregon" {
			gen infants = age_0_5
		}
		// female_00_05 WI
		// male_00_05 WI 
		if "${state}" == "wisconsin" {
			egen infants = rowtotal(female_00_05 male_00_05), missing
		}
	// age_05_17 TX
	// age_18_59 MO TX
	// ***generate elderly MO NJ OR TX WI MA 
		// age_60_64 TX
		// age_65    TX
		if "${state}" == "texas" {
			egen elderly = rowtotal(age_60_64 age_65), missing
		}
		// age_60    MO OR NJ MA
		if "${state}" == "missouri" | "${state}" == "newjersey" | "${state}" == "oregon" {
			gen elderly = age_60
		}
		// female_65plus WI
		// male_65plus WI
		if "${state}" == "wisconsin" {
			egen elderly = rowtotal(female_65plus male_65plus), missing
		}
	// ***disabled MO NJ MA 
	// ***generate female, male NM WI
		// gender_female NM
		// gender_male NM
		// female_00_05 WI
		// female_06_17 WI
		// female_18_34 WI
		// female_35_49 WI
		// female_50_64 WI
		// female_65plus WI
		if "${state}" == "wisconsin" {
			egen gender_female = rowtotal(female_00_05 female_06_17 female_18_34 female_35_49 female_50_64 female_65plus), missing
		}
		// male_00_05 WI
		// male_06_17 WI
		// male_18_34 WI
		// male_35_49 WI
		// male_50_64 WI
		// male_65plus WI
		if "${state}" == "wisconsin" {
			egen gender_male = rowtotal(male_00_05 male_06_17 male_18_34 male_35_49 male_50_64 male_65plus), missing
		}	
	// race and ethnicity
	// NM only
		// ethnicity_hispanic
		// ethnicity_nonhispanic
		// race_africanamericanorblack
		// race_asian
		// race_morethanonerace
		// race_nativeamericanoralaskanna
		// race_nativehawaiianorpacificis
		// race_unknownnotdeclared
		// race_white
	// CASE MOVEMENT: CA only
		// "Flow in" breakdown
			// ***households_carryover_start: Cases brought forward at the beginning of the month
			// Vs. ***households_new: cases added during the month. 
				// This is further broken down into:
					// --***households_new_apps: Applications approved
					// --***households_new_change_pacfnacf: Change in assistance status from PACF or NACF
					// --***households_new_change_county: Intercounty transfers (for county-level data only?)
					// --***households_new_reinstated: Cases with eligibility reinstates and benefits pro-rated during the month
					// --***households_new_other: Other approvals
		// ***households: “Cases open” = Total cases open during the month
	// ***firsttimehouseholds WI only 
	// RECERTIFICATIONS
	// ***recerts, total CA CO NM NC TX MA 
		// CA recerts
		if "${state}" == "california" {
			egen recerts = rowtotal(recerts_disposed recerts_overdue), missing
		}	
		// NC recerts
		// CO recert
		capture rename recert recerts 
		// TX recerts_disposed
		if "${state}" == "texas" {
			capture rename recerts_disposed recerts 
		}
		// NM recert_approved + recert_denied
		if "${state}" == "newmexico" {
			egen recerts = rowtotal(recert_approved recert_denied), missing
		}
		// LA XXXX data only goes through 2013
		// households_cert MD - not sure what this is and it only goes through 2005
		// MA recerts_due 
		capture rename recerts_due recerts 
	// ***recerts_approved CA, NM, (LA doesn't have this)
		// CA
		// leaving name as is, see data appendix 
		// capture rename recerts_elig recerts_approved
		// NM 
		capture rename recert_approved recerts_approved
		// LA (LA does not have an equivalent during this period, but has monthly data ending in 2013
	// ***recerts_denied
		// CA 
		// does not really exist, see data appendix 
		// if "${state}" == "california" {
		// egen recerts_denied = rowtotal(recerts_inelig recerts_overdue), missing
		//	gen recerts_deniedB = recerts_disposed - recerts_approved
		// }
**maybe check to see if these numbers are close: recerts_denied & recerts_deniedB
		// NM 
		capture rename recert_denied recerts_denied
		// LA 
		if "${state}" == "louisiana" {
			// all types of closures 
			#delimit ;
			egen recerts_denied = rowtotal(
				c_2_earnedincometotal 
				c_2_unearnedincometotal 
				c_2_othereligibilitytotal 
				c_2_otherreasonstotal 
				c_2_voluntarywithdrawal 
				c_2_proceduralreasonstotal 
				c_2_sanctionreasonstotal
				), missing
			;
			#delimit cr 
		}
	// ***recerts_denied_procedural 
		// CA 
		// does not really exist, see data appendix 
		// capture rename recerts_overdue recerts_denied_procedural
		// NM 
		capture rename recert_denied_procedural recerts_denied_procedural
		// LA 
		if "${state}" == "louisiana" {
			egen recerts_denied_procedural = rowtotal(c_2_proceduralreasonstotal c_2_sanctionreasonstotal), missing
		}
	// ***recerts_denied_needbased
		// CA 
		capture rename recerts_inelig recerts_denied_needbased
		// NM 
		capture rename recert_denied_needbased recerts_denied_needbased
		// LA 
		// Justification for including other reasons here: other reasons is just client request, which suggests the household no longer needs benefits
		// Justification for including voluntary withdrawals here: similar to above
		if "${state}" == "louisiana" {
			egen recerts_denied_needbased = rowtotal(c_2_earnedincometotal c_2_unearnedincometotal c_2_othereligibilitytotal c_2_otherreasonstotal c_2_voluntarywithdrawal), missing
		}
	// ***churn_rate MA 
	// closure details from LA: 
		// ***c_1_statetotal
		// ***c_2_earnedincometotal
		// ***c_2_othereligibilitytotal
		// ***c_2_otherreasonstotal
		// ***c_2_proceduralreasonstotal
		// ***c_2_sanctionreasonstotal
		// ***c_2_unearnedincometotal
		// ***c_2_voluntarywithdrawal
		// ***c_3_abawdindividualfailedtomeetr
		// ***c_3_changeinstatelaworpolicy
		// ***c_3_citizenshipnotmet
		// ***c_3_clientrequest
		// ***c_3_convictedofipv
		// ***c_3_deathofapplicantheadofhouseh
		// ***c_3_decreaseneedorexpenses
		// ***c_3_doesnotpurchasepreparemealss
		// ***c_3_doesnotreceivessi
		// ***c_3_drugconviction
		// ***c_3_expiredredetermination
		// ***c_3_failednetincometest
		// ***c_3_failedrefusedtoprovideverifi
		// ***c_3_failedtocomplywithlajet
		// ***c_3_failedtocomplywithlwc
		// ***c_3_failedtokeepappointment
		// ***c_3_failedtoprovidecompletesemi
		// ***c_3_failedtoregisterforworkhire
		// ***c_3_failedtotimelyreapply
		// ***c_3_failureduetoeandtsanction
		// ***c_3_failureduetovoluntarywithdra
		// ***c_3_grossinceligibilitynetexceed
		// ***c_3_grossincomeineligible
		// ***c_3_headofhhpayeelefthome
		// ***c_3_householdmemberdisqualified
		// ***c_3_includedinanothercertificati
		// ***c_3_increaseinchildsupport
		// ***c_3_increaseincontributions
		// ***c_3_increaseinotherfederalbenefi
		// ***c_3_increaseinotherstatebenefits
		// ***c_3_increaseinsocialsecurityorss
		// ***c_3_increaseinwagesornewemployme
		// ***c_3_individualdoesnotmeetagerequ
		// ***c_3_individualdoesnotmeetprogram
		// ***c_3_institutionalizationincarcer
		// ***c_3_livingwithchildunderage22lac
		// ***c_3_livingwithspouselacaponly
		// ***c_3_movedoutofstate
		// ***c_3_noeligiblechildmemberintheho
		// ***c_3_nolongerinlivingarrangementc
		// ***c_3_notaonepersonhouseholdinelig
		// ***c_3_originallyineligible
		// ***c_3_otherdisasterclosuresinclude
		// ***c_3_questionableinformationnotpr
		// ***c_3_refusedtocomplywitheligibili
		// ***c_3_refusedtocomplywithpres
		// ***c_3_refusedtocomplywithqualityco
		// ***c_3_residenceoutofparish
		// ***c_3_residencerequirementnotmet
		// ***c_3_resourcesoverlimit
		// ***c_3_selectedregularfsbecauseofex
		// ***c_3_transferredresources
		// ***c_3_unabletolocate
		// ***c_3_voluntaryquitwithoutgoodcaus					
																																																																		
// MEDICAID ENROLLMENT
// available in at least the following states, if cleaned: 
// AK FL GA MD MI MO NE NM ND OH PA TX WA
// actually available in NE MD 
// ***medicaid_individuals NE 
	// NE medicaid_enrol_total
	capture rename medicaid_enrol_total medicaid_individuals
// ***medicaid_children
	// NE medicaid_enrol_children_families
	capture rename medicaid_enrol_children_families medicaid_children
// ***medicaid_elderly_disabled
	// NE medicaid_enrol_aged_disabled
	capture rename medicaid_enrol_aged_disabled medicaid_elderly_disabled
// ***medicaid_households MD 
	// MD 
		// MD ma_commcare_cases
		// MD ma_longterm_cases
		// MD ssi 
		// MD ma_mchp_assistanceunits
	if "${state}" == "maryland" {
		egen medicaid_households = rowtotal(ma_commcare_cases ma_longterm_cases ssi ma_mchp_assistanceunits), missing
	}
// ***medicaid_apps_received MD
	// MD 
		// MD ma_commcare_apps_received
		// MD ma_longterm_apps_received
		// MD ssi_apps_received
		// MD ma_mchp_apps_received ** leave this category out since it is not in the approved categories
	if "${state}" == "maryland" {
		egen medicaid_apps_received = rowtotal(ma_commcare_apps_received ma_longterm_apps_received ssi_apps_received), missing
	}
	// MT apps_received_medicaid
	capture rename apps_received_medicaid medicaid_apps_received

// ***medicaid_apps_approved MD 
	// MD 
		// MD ma_commcare_apps_approved
		// MD ma_longterm_apps_approved
		// MD ssi_apps_approved
	if "${state}" == "maryland" {
		egen medicaid_apps_approved = rowtotal(ma_commcare_apps_approved ma_longterm_apps_approved ssi_apps_approved), missing
	}
// TANF ENROLLMENT
// possibly available in more states
// ***tanf_households KS ME MD NE MA 
	// KS tanf_households
	// ME tanf_cases
	// MD tanf_cases
	capture rename tanf_cases tanf_households
	// NE adc_families
	capture rename adc_families tanf_households 
	// MA tanf_households
	**capture rename households_tafdc tanf_households // **KP need to do more work to combine these from different sources
	// XX households_tanf 
	capture rename households_tanf tanf_households
// ***tanf_individuals KS MD MA 
	// KS tanf_persons
	capture rename tanf_persons tanf_individuals
	// MD tanf_recipients
	// MA tanf_recipients
	capture rename tanf_recipients tanf_individuals
	capture rename individuals_tafdc tanf_individuals
	// XX individuals_tanf 
	capture rename individuals_tanf tanf_individuals
// ***tanf_children KS ME MD MA 
	// KS tanf_children
	// ME tanf_children
	// MD tanf_children
	// MA tanf_children 
// ***tanf_adults KS MD MA 
	// KS tanf_adults
	// MD tanf_adults
	// MA 
	if "${state}" == "massachusetts" {
		gen tanf_adults = tanf_individuals - tanf_children
	}
// tanf_elderly MA 
// tanf_disabled MA 
// ***tanf_apps_received MD MA 
	// MD tanf_apps_received
	// MA apps_received_tanf 
	capture rename apps_received_tanf tanf_apps_received
// MA apps_received_tanf_*

// ***tanf_apps_approved MD 
	// MD tanf_apps_approved
// ***tanf_apps_denied
	// MD tanf_apps_notapproved
	capture rename tanf_apps_notapproved tanf_apps_denied 
// ***tanf_issuance 
	// MD tanf_netexpenditure
	capture rename tanf_netexpenditure tanf_issuance
	// XX issuance_tanf 
	capture rename issuance_tanf tanf_issuance
// MD tanf_cases_closed
// ***childcare_children NE KS 
	// NE ccsubsidy_children
	capture rename ccsubsidy_children childcare_children
	// KS childcare_children
// ***childcare_households KS 
	// KS childcare_households

// ***individuals_eaedc MA 
	// MA eaedc_recipients
	capture rename eaedc_recipients eaedc_individuals
// ***eaedc_households MA 
// ***eaedc_children MA 
// ***eaedc_elderly MA 
// ***eaedc_disabled MA 

// MA scorecard data 
	// ***walk_in_visitors_daily_avg
	// ***walk_in_visitors_avg_waittime
	// ***reason_walkin_accesstodocs
	// ***reason_walkin_cashapp
	// ***reason_walkin_snapapp
	// ***reason_walkin_docprocess
	// ***reason_walkin_ebtcard
	// ***reason_walkin_speaktostaff
	// ***reason_walkin_pebt
	// ***reason_walkin_recert
	// ***reason_walking_other
	// ***calls_daily_avg
	// ***calls_daily_avg_endivr
	// ***calls_daily_avg_connect
	// ***calls_daily_avg_noconnect
	// ***calls_avg_waittime_min
	// ***calls_avg_waittime_sec
	// ***app_avg_processing_days
	// ***apps_received_walkin
	// ***apps_received_dropoff
	// ***apps_received_mailin
	// ***apps_received_fax
	// ***apps_received_masshealthcheckbox
	// ***apps_received_web
	// ***apps_received_telephone
	// ***apps_received_tanf_inoffice
	// ***apps_received_tanf_homevisit
	// ***apps_received_tanf_mailinfax
	// ***apps_received_tanf_web
	// ***apps_received_tanf_telephone
	// ***apps_received_eaedc_inoffice
	// ***apps_received_eaedc_homevisit
	// ***apps_received_eaedc_mailinfax
	// ***apps_received_eaedc_web
	// ***apps_received_eaedc_telephone
	// ***apps_received_eaedc

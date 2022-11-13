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
	// apps_disposed CA 
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
	// apps_processed 
	// apps_delinquent
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
	// ***children MO  TX SD  OR  OH NM NJ LA KS AZ MI MA 
	// ***adults  TX SD (OR) OH NM NJ LA KS AZ MI
		// calculate for OR
		if inlist("${state}","oregon") {
			gen adults = individuals - children
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
	// age_05_17 TX
	// age_18_59 MO TX
	// ***generate elderly MO NJ OR TX MA 
		// age_60_64 TX
		// age_65    TX
		if "${state}" == "texas" {
			egen elderly = rowtotal(age_60_64 age_65), missing
		}
		// age_60    MO OR NJ MA
		if "${state}" == "newjersey" | "${state}" == "oregon" {
			gen elderly = age_60
		}
	// ***disabled MO NJ MA 
	// ***generate female, male NM
		// gender_female NM
		// gender_male NM
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
		// NC recerts
		// CO recert
		capture rename recert recerts 
		// TX recerts_disposed
		capture rename recerts_disposed recerts 
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
		capture rename recerts_elig recerts_approved
		// NM 
		capture rename recert_approved recerts_approved
		// LA (LA does not have an equivalent during this period, but has monthly data ending in 2013
	// ***recerts_denied
		// CA 
		if "${state}" == "california" {
			egen recerts_denied = rowtotal(recerts_inelig recerts_overdue), missing
			gen recerts_deniedB = recerts - recerts_approved
		}
**maybe check to see if these numbers are close: recerts_denied & recerts_deniedB
		// NM 
		capture rename recert_denied recerts_denied
	// ***recerts_denied_procedural 
		// CA 
		capture rename recerts_overdue recerts_denied_procedural
		// NM 
		capture rename recert_denied_procedural recerts_denied_procedural
	// ***recerts_denied_needbased
		// CA 
		capture rename recerts_inelig recerts_denied_needbased
		// NM 
		capture rename recert_denied_needbased recerts_denied_needbased

				
																																																																		
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
	// MA 
	capture rename households_tafdc tanf_households
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
// ***tanf_adults KS MD 
	// KS tanf_adults
	// MD tanf_adults
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
// NE ccsubsidy_children
// KS childcare_children
// KS childcare_households
// MA eaedc_recipients
// MA eaedc_households
// MA eaedc_elderly
// MA eaedc_disabled
// MA eaedc_children
// MA apps_received_eaedc
// MA apps_received_eaedc_*


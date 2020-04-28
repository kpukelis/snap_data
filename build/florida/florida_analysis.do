use "${dir_data}/clean/analysis.dta", clear

**this code should be moved elsewhere
// recode drops as as positive
foreach outcome in clients households issuance {
	foreach type in diff perc {
		replace `type'_drop_`outcome' = -1 * `type'_drop_`outcome'
	}
}

// recode all percentages into units of 100
foreach var in perc_drop_clients perc_drop_households perc_drop_issuance {
	replace `var' = `var' * 100
}

foreach outcome in laborforce emp unemp {
	gen `outcome'_per_center_total = `outcome' / total
	gen `outcome'_per_center_total_1000 = `outcome' / total / 1000

	foreach type in full satellite {
		gen `outcome'_per_center_`type' = `outcome' / total_`type'

	}
	gen `outcome'_per_center_full_1000 = `outcome' / total / 1000
}
gen unemp_r_per_center_total = unemp_per_center_total / laborforce_per_center_total
gen unemp_r_per_center_full = unemp_per_center_full / laborforce_per_center_full

*regress perc_drop_clients unemp_rate_precise

**************

regress diff_drop_clients laborforce
regress diff_drop_clients emp
regress diff_drop_clients unemp 

regress diff_drop_clients emp unemp 

regress diff_drop_clients avg_loo_laborforce
regress diff_drop_clients laborforce avg_loo_laborforce


regress diff_drop_clients unemp_per_center_total
regress diff_drop_clients unemp_per_center_full 
regress diff_drop_clients unemp_per_center_full unemp_per_center_satellite

regress diff_drop_clients total_full
regress diff_drop_clients total_full laborforce
regress diff_drop_clients total_full unemp 
regress diff_drop_clients total_full unemp laborforce

regress diff_drop_clients unemp_per_center_full 
regress diff_drop_clients unemp_per_center_full laborforce
regress diff_drop_clients unemp_per_center_full unemp 
regress diff_drop_clients unemp_per_center_full unemp laborforce


check
*******
regress perc_drop_clients unemp_rate_precise 

regress perc_drop_clients unemp_rate_precise avg_loo_unemp_rate_served

regress perc_drop_clients unemp_rate_precise total
regress perc_drop_clients unemp_rate_precise total_full
**full service places seem to matter more
gen unemp_rate_preciseXtotal_full = unemp_rate_precise * total_full
regress perc_drop_clients unemp_rate_precise total_full unemp_rate_preciseXtotal_full

regress perc_drop_clients unemp_rate_precise avg_unemp_rate_served

regress perc_drop_clients unemp_rate_precise laborforce_per_center_total_1000

gen total_fullXavg_loo_unemp_rate = total_full * avg_loo_unemp_rate_served
regress perc_drop_clients unemp_rate_precise total_full
regress perc_drop_clients unemp_rate_precise avg_loo_unemp_rate_served
regress perc_drop_clients unemp_rate_precise total_full avg_loo_unemp_rate_served total_fullXavg_loo_unemp_rate
*regress perc_drop_clients 

 
#delimit ;
regress 
perc_drop_clients
unemp_rate_precise
total_full
avg_loo_unemp_rate_served
;
check;
unemp_r_per_center_full
avg_unemp_rate_served

total
unemp_r_per_center_total


// sipp_explore.do 
// Kelsey Pukelis 
// explore SIPP data, check possible sample size 

#delimit ;
local vars1
ssuid
pnum
monthcode
rfscov
efslcy
rfs_contflg
tfs_amt
efs_bmonth
efs_emonth
efsown
efsbrsn1
efsbrsn2
efsersn1
/*efsersn2*/
rfsyn 
tehc_st
tst_intv
rhnumu18wt2 
edob_bmonth
tdob_byear
;
#delimit cr 
KEEP GOING HERE 
#delimit ;
local vars2
`vars1'
efsersn2
;
#delimit cr 

*****************************************************************************************************

// load certain variables, each wave 
forvalues w = 1(1)4 {
	use `vars`w'' using "${dir_root}/data/health_data/surveys/SIPP/data/pu2014w`w'_v13/pu2014w`w'.dta", clear
	gen wave = `w'
	gen year = 2012 + `w'
	save "${dir_root}/data/health_data/surveys/SIPP/data/wave`w'.dta", replace 

}

// append waves
forvalues w = 1(1)4 {
	if `w' == 1 {
		use "${dir_root}/data/health_data/surveys/SIPP/data/wave`w'.dta", clear 		
	}
	else {
		append using "${dir_root}/data/health_data/surveys/SIPP/data/wave`w'.dta"
	}

}
save "${dir_root}/data/health_data/surveys/SIPP/data/wave_all.dta", replace
check

// rename vars 
rename ssuid hhid 
rename pnum pid 
rename monthcode month  
rename rfscov snap_everP
rename efslcy snap_yearbeganP
rename rfs_contflg snap_contP
rename tfs_amt snap_amtM
rename efs_bmonth snap_spellbeginS
rename efs_emonth snap_spellendS
rename efsown snap_ownerS
rename efsbrsn1 snap_beginreason1S
rename efsbrsn2 snap_beginreason2S
rename efsersn1 snap_endreason1S
// rename efsersn2 snap_endreason2S
rename rfsyn snap_nowS 
rename tehc_st statefips
rename tst_intv state_interview
// rename rhnumu18 persons_18under
rename rhnumu18wt2 persons_18under // includes individuals not in the household at the time of interview
rename edob_bmonth birthmonth
rename tdob_byear birthyear


// age
gen ym = ym(year,month)
format ym %tm 
gen birthym = ym(birthyear,birthmonth)
format birthmonth %tm 
drop birthyear 
drop birthmonth
gen age = (ym - birthym) / 12

// merge in clock info, to get relative time 
preserve 
use "${dir_root}/data/state_data/clocks_wide.dta", clear 
merge 1:1 state using "${dir_root}/data/state_data/_fips/statefips_2015.dta", keepusing(statefips)
assert inlist(state,"dc","districtofcolumbia","puertorico") if _m != 3
keep if _m == 3
drop _m 
tempfile clocks 
save `clocks'
restore
destring statefips, replace
confirm numeric variable statefips
merge m:1 statefips using `clocks', keepusing(clocktype bindingclockstart_ym adjust_clock)
assert inlist(statefips,11,60,61) if _m != 3
keep if _m == 3
drop _m 

// event: binding events only 
gen bindingexpected_ym = bindingclockstart_ym + 3 + 1 + adjust_clock

// relative time 
gen relative_ym = ym - bindingexpected_ym

// sample of states with a visible first stage 
*keep if !missing(bindingexpected_ym)




check




// MARK POTENTIALLY TREATED INDIVIDUALS


// mark people between ages 18-49


// households without children only 
keep if persons_18under == 0


// age at relative time -1
gen temp = age if relative_ym == -1
bysort hhid pid: egen age0 = mean(temp)
assert !missing(age0)


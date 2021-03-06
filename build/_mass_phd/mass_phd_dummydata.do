// mass_phd_dummydata.do
// Kelsey Pukelis
// imports dummy data files into Stata to take a look at structure

#delimit ;
local filenames 
/*
dummy_apcd_general

dummy_apcd_member
dummy_apcd_ortho
dummy_apcd_pharmacy
dummy_apcd_samh
dummy_birth
dummy_bsas
dummy_cancer
dummy_casemix_general
dummy_casemix_mh
dummy_casemix_sa
dummy_death       
dummy_dhcd
dummy_dmh

dummy_doc

dummy_dvs

dummy_masshealth

dummy_masterdemo

dummy_matris

dummy_ocmetox

dummy_pmp_pat
dummy_pmp_rx
*/
dummy_sheriff
;
#delimit cr 


*****************************************************************************************

// import 
foreach filename of local filenames {
	import sas "${dir_root}/data/health_data/admin/Massachusetts/notice of opportunity 2018/PHD Dummy SAS Datasets/`filename'.sas7bdat", clear 	
check
}

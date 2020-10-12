// build_unemp.do
// Kelsey Pukelis
// build BLS county-level unemployment statistics, retrived from BLS website using the series ID's below

local num_counties 				= 68 // includes statewide average

/*
LAUST120000000000003
LAUST120000000000004
LAUST120000000000005
LAUST120000000000006
LAUCN120010000000003
LAUCN120010000000004
LAUCN120010000000005
LAUCN120010000000006
LAUCN120030000000003
LAUCN120030000000004
LAUCN120030000000005
LAUCN120030000000006
LAUCN120050000000003
LAUCN120050000000004
LAUCN120050000000005
LAUCN120050000000006
LAUCN120070000000003
LAUCN120070000000004
LAUCN120070000000005
LAUCN120070000000006
LAUCN120090000000003
LAUCN120090000000004
LAUCN120090000000005
LAUCN120090000000006
LAUCN120110000000003
LAUCN120110000000004
LAUCN120110000000005
LAUCN120110000000006
LAUCN120130000000003
LAUCN120130000000004
LAUCN120130000000005
LAUCN120130000000006
LAUCN120150000000003
LAUCN120150000000004
LAUCN120150000000005
LAUCN120150000000006
LAUCN120170000000003
LAUCN120170000000004
LAUCN120170000000005
LAUCN120170000000006
LAUCN120190000000003
LAUCN120190000000004
LAUCN120190000000005
LAUCN120190000000006
LAUCN120210000000003
LAUCN120210000000004
LAUCN120210000000005
LAUCN120210000000006
LAUCN120230000000003
LAUCN120230000000004
LAUCN120230000000005
LAUCN120230000000006
LAUCN120270000000003
LAUCN120270000000004
LAUCN120270000000005
LAUCN120270000000006
LAUCN120290000000003
LAUCN120290000000004
LAUCN120290000000005
LAUCN120290000000006
LAUCN120310000000003
LAUCN120310000000004
LAUCN120310000000005
LAUCN120310000000006
LAUCN120330000000003
LAUCN120330000000004
LAUCN120330000000005
LAUCN120330000000006
LAUCN120350000000003
LAUCN120350000000004
LAUCN120350000000005
LAUCN120350000000006
LAUCN120370000000003
LAUCN120370000000004
LAUCN120370000000005
LAUCN120370000000006
LAUCN120390000000003
LAUCN120390000000004
LAUCN120390000000005
LAUCN120390000000006
LAUCN120410000000003
LAUCN120410000000004
LAUCN120410000000005
LAUCN120410000000006
LAUCN120430000000003
LAUCN120430000000004
LAUCN120430000000005
LAUCN120430000000006
LAUCN120450000000003
LAUCN120450000000004
LAUCN120450000000005
LAUCN120450000000006
LAUCN120470000000003
LAUCN120470000000004
LAUCN120470000000005
LAUCN120470000000006
LAUCN120490000000003
LAUCN120490000000004
LAUCN120490000000005
LAUCN120490000000006
LAUCN120510000000003
LAUCN120510000000004
LAUCN120510000000005
LAUCN120510000000006
LAUCN120530000000003
LAUCN120530000000004
LAUCN120530000000005
LAUCN120530000000006
LAUCN120550000000003
LAUCN120550000000004
LAUCN120550000000005
LAUCN120550000000006
LAUCN120570000000003
LAUCN120570000000004
LAUCN120570000000005
LAUCN120570000000006
LAUCN120590000000003
LAUCN120590000000004
LAUCN120590000000005
LAUCN120590000000006
LAUCN120610000000003
LAUCN120610000000004
LAUCN120610000000005
LAUCN120610000000006
LAUCN120630000000003
LAUCN120630000000004
LAUCN120630000000005
LAUCN120630000000006
LAUCN120650000000003
LAUCN120650000000004
LAUCN120650000000005
LAUCN120650000000006
LAUCN120670000000003
LAUCN120670000000004
LAUCN120670000000005
LAUCN120670000000006
LAUCN120690000000003
LAUCN120690000000004
LAUCN120690000000005
LAUCN120690000000006
LAUCN120710000000003
LAUCN120710000000004
LAUCN120710000000005
LAUCN120710000000006
LAUCN120730000000003
LAUCN120730000000004
LAUCN120730000000005
LAUCN120730000000006
LAUCN120750000000003
LAUCN120750000000004
LAUCN120750000000005
LAUCN120750000000006
LAUCN120770000000003
LAUCN120770000000004
LAUCN120770000000005
LAUCN120770000000006
LAUCN120790000000003
LAUCN120790000000004
LAUCN120790000000005
LAUCN120790000000006
LAUCN120810000000003
LAUCN120810000000004
LAUCN120810000000005
LAUCN120810000000006
LAUCN120830000000003
LAUCN120830000000004
LAUCN120830000000005
LAUCN120830000000006
LAUCN120850000000003
LAUCN120850000000004
LAUCN120850000000005
LAUCN120850000000006
LAUCN120860000000003
LAUCN120860000000004
LAUCN120860000000005
LAUCN120860000000006
LAUCN120870000000003
LAUCN120870000000004
LAUCN120870000000005
LAUCN120870000000006
LAUCN120890000000003
LAUCN120890000000004
LAUCN120890000000005
LAUCN120890000000006
LAUCN120910000000003
LAUCN120910000000004
LAUCN120910000000005
LAUCN120910000000006
LAUCN120930000000003
LAUCN120930000000004
LAUCN120930000000005
LAUCN120930000000006
LAUCN120950000000003
LAUCN120950000000004
LAUCN120950000000005
LAUCN120950000000006
LAUCN120970000000003
LAUCN120970000000004
LAUCN120970000000005
LAUCN120970000000006
LAUCN120990000000003
LAUCN120990000000004
LAUCN120990000000005
LAUCN120990000000006
LAUCN121010000000003
LAUCN121010000000004
LAUCN121010000000005
LAUCN121010000000006
LAUCN121030000000003
LAUCN121030000000004
LAUCN121030000000005
LAUCN121030000000006
LAUCN121050000000003
LAUCN121050000000004
LAUCN121050000000005
LAUCN121050000000006
LAUCN121070000000003
LAUCN121070000000004
LAUCN121070000000005
LAUCN121070000000006
LAUCN121090000000003
LAUCN121090000000004
LAUCN121090000000005
LAUCN121090000000006
LAUCN121110000000003
LAUCN121110000000004
LAUCN121110000000005
LAUCN121110000000006
LAUCN121130000000003
LAUCN121130000000004
LAUCN121130000000005
LAUCN121130000000006
LAUCN121150000000003
LAUCN121150000000004
LAUCN121150000000005
LAUCN121150000000006
LAUCN121170000000003
LAUCN121170000000004
LAUCN121170000000005
LAUCN121170000000006
LAUCN121190000000003
LAUCN121190000000004
LAUCN121190000000005
LAUCN121190000000006
LAUCN121210000000003
LAUCN121210000000004
LAUCN121210000000005
LAUCN121210000000006
LAUCN121230000000003
LAUCN121230000000004
LAUCN121230000000005
LAUCN121230000000006
LAUCN121250000000003
LAUCN121250000000004
LAUCN121250000000005
LAUCN121250000000006
LAUCN121270000000003
LAUCN121270000000004
LAUCN121270000000005
LAUCN121270000000006
LAUCN121290000000003
LAUCN121290000000004
LAUCN121290000000005
LAUCN121290000000006
LAUCN121310000000003
LAUCN121310000000004
LAUCN121310000000005
LAUCN121310000000006
LAUCN121330000000003
LAUCN121330000000004
LAUCN121330000000005
LAUCN121330000000006*/

*************************************************************************

///////////////////
// IMPORT COUNTY //
///////////////////

// generate list of files
cd "${dir_root}/raw/unemployment/"
ls

#delimit ; 
local i = 1;
foreach file in 
"SeriesReport-20191204220321_22f3a6"
"SeriesReport-20191204220331_bd55dc"
"SeriesReport-20191204220338_7e5c05"
"SeriesReport-20191204220344_0a1326"
"SeriesReport-20191204220349_63acf9"
"SeriesReport-20191204220454_698425"
"SeriesReport-20191204220500_312cf7"
"SeriesReport-20191204220506_8d099c"
"SeriesReport-20191204220510_701600"
"SeriesReport-20191204220514_6dc695"
"SeriesReport-20191204220519_5a0ded"
"SeriesReport-20191204220524_8d1cb7"
"SeriesReport-20191204220529_3430b1"
"SeriesReport-20191204220556_43231a"
"SeriesReport-20191204220601_fb0d4a"
"SeriesReport-20191204220605_3c7ac3"
"SeriesReport-20191204220610_bc18d0"
"SeriesReport-20191204220614_891506"
"SeriesReport-20191204220619_eff842"
"SeriesReport-20191204220624_f01870"
"SeriesReport-20191204220628_6c25e9"
"SeriesReport-20191204220633_ad91db"
"SeriesReport-20191204220638_ebcfa1"
"SeriesReport-20191204220642_836d6a"
"SeriesReport-20191204220647_91bcb2"
"SeriesReport-20191204220652_268c8f"
"SeriesReport-20191204220656_d72aab"
"SeriesReport-20191204220701_8192a6"
"SeriesReport-20191204220706_49a754"
"SeriesReport-20191204220712_0bb7c1"
"SeriesReport-20191204220717_fca5fd"
"SeriesReport-20191204220722_d56a0e"
"SeriesReport-20191204220727_1a4bb6"
"SeriesReport-20191204220732_c9215c"
"SeriesReport-20191204220737_1fc0cf"
"SeriesReport-20191204220743_4157b9"
"SeriesReport-20191204220748_3c0f31"
"SeriesReport-20191204220756_33e66f"
"SeriesReport-20191204220800_c1f9e0"
"SeriesReport-20191204220805_9cf316"
"SeriesReport-20191204220810_0f5824"
"SeriesReport-20191204220814_d8e63c"
"SeriesReport-20191204220819_c120e9"
"SeriesReport-20191204220824_ec98a3"
"SeriesReport-20191204220829_6d935f"
"SeriesReport-20191204220834_4647c6"
"SeriesReport-20191204220840_e7e867"
"SeriesReport-20191204220845_2a2b1d"
"SeriesReport-20191204220849_92ac5a"
"SeriesReport-20191204220855_34155c"
"SeriesReport-20191204220900_fa0f0a"
"SeriesReport-20191204220905_81dd4b"
"SeriesReport-20191204220910_dbc49f"
"SeriesReport-20191204220915_7265e9"
"SeriesReport-20191204220920_a73732"
"SeriesReport-20191204220924_b7cbc6"
"SeriesReport-20191204220929_a7e7f9"
"SeriesReport-20191204220934_0cc412"
"SeriesReport-20191204220939_c5f62c"
"SeriesReport-20191204220944_e5c063"
"SeriesReport-20191204220948_3d402c"
"SeriesReport-20191204220953_0eff54"
"SeriesReport-20191204220959_5b0c26"
"SeriesReport-20191204221004_29ef27"
"SeriesReport-20191204221009_ba2466"
"SeriesReport-20191204221014_3793bf"
"SeriesReport-20191204221020_8a5113"
"SeriesReport-20191204221024_c216dc"
{ ; 

	// import 
	import excel "${dir_root}/raw/unemployment/`file'.xlsx", allstring clear ;
	drop if missing(A) ;
	drop in 1;
	drop in 1; 
	drop in 1; 
	drop in 1; 
	
	// county name of this file 
	gen countyname = B if A == "Area:" ;
	carryforward countyname, replace ; 
	
	// drop more rows
	drop in 1;
	drop in 1; 
	drop in 1; 
	drop in 1; 
	drop in 1; 
	
	// rename vars
	rename A year;
	rename B month;
	rename C laborforce;
	rename D emp;
	rename E unemp;
	rename F unemp_rate;
	
	// clean up month 
	replace month = "1" if month == "Jan";
	replace month = "2" if month == "Feb";
	replace month = "3" if month == "Mar";
	replace month = "4" if month == "Apr";
	replace month = "5" if month == "May";
	replace month = "6" if month == "Jun";
	replace month = "7" if month == "Jul";
	replace month = "8" if month == "Aug";
	replace month = "9" if month == "Sep";
	replace month = "10" if month == "Oct";
	replace month = "11" if month == "Nov";
	replace month = "12" if month == "Dec";
	destring month, replace;

	// lower-case county name 
	replace countyname = lower(countyname);

	// destring
	destring year laborforce emp unemp unemp_rate, replace ;
	
	// save 
	tempfile _`i';
	save `_`i'';
	*save "${dir_temp}/`i'.dta", replace ;
	
	// increment index
	local ++i ;

} ; 
#delimit cr 

///////////////////
// APPEND COUNTY //
///////////////////

#delimit ;

// append all counties
forvalues n = 1(1)`num_counties' { ;
	if "`n'" == "1" { ;
		*use "${dir_temp}/`n'.dta", clear ;
		use `_`n'', clear ;
	} ;
	else { ;
		*append using "${dir_temp}/`n'.dta" ;
		append using `_`n'';
	} ;
} ;

// ym 
gen ym = ym(year,month) ;
format ym %tm ;
drop year month ;

// county name
split countyname, parse(",") ;
drop countyname ;
rename countyname1 countyname ;
rename countyname2 state ;
gen citycounty = "" ;
replace citycounty = "city" if strpos(countyname," city") | strpos(countyname," City") ;
replace citycounty = "county" if strpos(countyname," county") | strpos(countyname," County") ;
replace citycounty = "statewide" if countyname == "florida";
assert !missing(citycounty) ;
replace countyname = subinstr(countyname," city","",.) ;
replace countyname = subinstr(countyname," county","",.) ;
replace countyname = subinstr(countyname," City","",.) ;
replace countyname = subinstr(countyname," County","",.) ;
replace state = "fl" if missing(state);

// order
order countyname citycounty state ym laborforce emp unemp unemp_rate ;

// save 
save "${dir_data}/clean/unemp_built_county.dta", replace ;

#delimit cr 

*****************************************************************************************************
**KP: maybe get the national data back in later 2019-12-04
/*
/////////////////////
// IMPORT NATIONAL //
/////////////////////

#delimit ; 

// national unemployment rate
local i = 1 ;
foreach file in 
"SeriesReport-20190224155445_6d98ca"
"SeriesReport-20190224155939_bfe683"
{ ;

	// import 
	import excel "${dir_external}/raw/va_county_unemployment/raw/`file'.xlsx", allstring clear ;
	drop if missing(A) ;
	drop in 1;
	drop in 1; 
	drop in 1; 
	drop in 1; 
	
	// county name of this file 
	gen countyname = B if A == "Series title:" ;
	carryforward countyname, replace ; 
	
	// drop more rows
	drop in 1;
	drop in 1; 
	drop in 1; 
	drop in 1; 
	drop in 1;
	
	// rename vars
	rename A year;
	rename B _1;
	rename C _2;
	rename D _3;
	rename E _4;
	rename F _5;
	rename G _6;
	rename H _7;
	rename I _8;
	rename J _9;
	rename K _10;
	rename L _11;
	rename M _12;
	drop in 1 ;
	
	// reshape 
	greshape long _, i(countyname year) j(month) ;
	rename _ natl_unemp_rate ;
	
	// destring
	destring year natl_unemp_rate, replace ;
	
	// save 
	save "${dir_temp}/national_`i'.dta", replace ;

	// increment index
	local ++i ;

} ;

#delimit cr 

/////////////////////
// APPEND NATIONAL // 
/////////////////////

#delimit ;

// append national datasets
use "${dir_temp}/national_1.dta", clear ;
append using "${dir_temp}/national_2.dta" ;

// ym 
gen ym = ym(year,month) ;
format ym %tm ;
drop year month ;

// county name
gen adjusted = . ;
replace adjusted = 1 if strpos(countyname,"(Seas)") ;
replace adjusted = 0 if strpos(countyname,"(Unadj)") ;
replace countyname = "National" ;

// reshape wide
rename natl_unemp_rate natl_unemp_rate_adj ;
greshape wide natl_unemp_rate_adj, i(countyname ym) j(adjusted) ;
drop countyname ;

// order
order ym natl_unemp_rate* ;

// save 
save "${dir_temp}/unemp_built_national.dta", replace ;

#delimit cr 

*****************************************************************************************************

///////////////////////////////
// MERGE COUNTY AND NATIONAL //
/////////////////////////////// 

#delimit ;

// load data 
use "${dir_temp}/unemp_built_national.dta", clear ;

// merge county with national
merge 1:m ym using "${dir_temp}/unemp_built_county.dta", assert(1 3) keep(3) nogen ;

// generate unique id for reclink
gen id_unemp = _n ;

// fuzzy merge on string 
reclink countyname citycounty using "${dir_data_build}/countyxwalk.dta", idmaster(id_unemp) idusing(id_countyxwalk) gen(reclink) ;
assert _m == 3 ;
drop _merge Ucountyname Ucitycounty id_unemp id_countyxwalk reclink ;

// destring countycode_num
destring countycode_num, replace ;

// order 
order countyname citycounty state countycode_num ym unemp_rate natl_unemp_rate_adj0 natl_unemp_rate_adj1 ;

// save 
save "${dir_data_build}/unemp_built.dta", replace ;

#delimit cr 

**************************************************************
**************************************************************
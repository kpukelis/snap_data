// run.do 
// Kelsey Pukelis

// preamble
clear all
label  drop _all
matrix drop _all
macro  drop _all
set matsize 10000
set more off
cls

// directories and file names
*global dir_root 		"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits"
global dir_root 		"G:/My Drive/Harvard/research/time_limits"
global dir_code 		"C:/Users/Kelsey/Documents/GitHub/snap_data"
*global dir_graphs 		"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/data/state_data/_graphs"
global dir_graphs 		"G:/My Drive/Harvard/research/time_limits/data/state_data/_graphs"

// run globals
*do "${dir_code}/0_utility/globals.do"
global monthsinayear 		= 12

// switches
local switch_install 		= 0

// Build data 
local _fips 				= 0 
local _zip 					= 0 // unfinished, unused
local _clocks 				= 0
local _waivers_quarter 		= 0
local sipp_explore 			= 0 // KEEP GOING HERE 2021-03-06
local pub78list 			= 0
local irs990_explore		= 0 // KEEP GOING HERE 2021-10-18
local mass_phd_dummydata	= 0
local hia 					= 0 // KEEP GOING HERE 2021-02-04
local massachusetts_waivers = 0 
local alabama				= 0 // not completed (fixed individual)
// local alaska				= 0 fixed statewide 
local arizona				= 0
local arkansas				= 1 // KEEP GOING HERE 2022-09-02
local california			= 0
local colorado 				= 0
local connecticut			= 0 // not completed (fixed individual)
// local delaware			= 0 rolling clock
local florida				= 0
local georgia				= 0
local hawaii				= 0 // not completed (rolling clock)
local idaho					= 0
local illinois				= 0 // STILL REMAINING ISSUES WITH THE STATE TOTAL TIME SERIES
local indiana				= 0 // **KP: can go back further cleaning indiana data 
local iowa					= 0 // **KP: can go back further cleaning iowa data 
local kansas				= 0 
local kentucky				= 0
local louisiana				= 0
local maine					= 0 
local maryland				= 0
local massachusetts			= 0 // **KP: need to crosswalk zipcode to county
local michigan				= 0
local minnesota				= 0 
local mississippi			= 0 
local missouri				= 0 // **KP: right now only state level, come back to clean county-level 
local montana				= 0 
local nebraska				= 0
// local nevada				= 0 fixed individual
// local newhampshire		= 0 fixed individual
local newjersey				= 0
local newmexico				= 0 
local newyork				= 0 
local northcarolina			= 0 
local northdakota			= 0 // not completed (rolling clock)
local ohio					= 0
local oklahoma				= 0 // not completed (fixed individual)
local oregon				= 0
local pennsylvania			= 0 
local rhodeisland 			= 0 // fixed statewide
local southcarolina			= 0
local southdakota 			= 0
local tennessee 			= 0
local texas	 				= 0
// local utah 				= 0
local vermont 				= 0 // handful of data years 
local virginia 				= 0 
local washington 			= 0 // **not completed (fixed statewide, but yearly)
local westvirginia 			= 0 // fixed statewide
local wisconsin 			= 0
// local wyoming 			= 0 fixed statewide
// local districtofcolumbia	= 0 unclear clock

**KP: 2020-02-09 missouri oregon left to be done 

// combine 
local combine_state_ym 		= 1 // KEEP GOING HERE 2022-09-09
local combine_county_ym		= 0 // still more work here 

// analyze
local shortlist 			= 0 // KEEP GOING HERE 2021-02-04
local analyze_state_ym		= 0
local event_study_plot 		= 0
local analyze_arizona 		= 0
local analyze_kansas 		= 0
local analyze_massachusetts = 0 // KEEP GOING HERE 2021-03-13
local analyze_newyork 		= 0 // KEEP GOING HERE 2021-12-06
local analyze_southcarolina	= 0 
local analyze_wisconsin 	= 0
local newyork_southerntier 	= 0 // KEEP GOING HERE 2021-04-26
local louisiana_analyze_closures = 0
local california_analyze_apps = 0

***********************************************

// install special Stata packages
if `switch_install' == 1 {
*	ssc install egenmore
}

// build county pop data 
#delimit ;
foreach step in 
	illinois
	ohio
	virginia
	{ ;
		if ``step'' == 1 { ;
			do "${dir_code}/build/`step'/`step'_county_pop.do" ;
		} ;
	} ;
;
#delimit cr

// build other data 
#delimit ;
foreach step in 
	hia
	{ ;
		if ``step'' == 1 { ;
			do "${dir_code}/build/_hia/`step'.do" ;
		} ;
	} ;
;
#delimit cr

// build other data 
#delimit ;
foreach step in 
	pub78list
	irs990_explore
	{ ;
		if ``step'' == 1 { ;
			do "${dir_code}/build/_foodpantry/`step'.do" ;
		} ;
	} ;
;
#delimit cr

// build other data 
#delimit ;
foreach step in 
	mass_phd_dummydata
	{ ;
		if ``step'' == 1 { ;
			do "${dir_code}/build/_mass_phd/`step'.do" ;
		} ;
	} ;
;
#delimit cr

// build other data 
#delimit ;
foreach step in 
	sipp_explore
	{ ;
		if ``step'' == 1 { ;
			do "${dir_code}/build/_sipp/`step'.do" ;
		} ;
	} ;
;
#delimit cr

// waiver data 
#delimit ;
foreach step in 
	massachusetts_waivers
	{ ;
		if ``step'' == 1 { ;
			do "${dir_code}/build/massachusetts/`step'.do" ;
		} ;
	} ;
;
#delimit cr

// build data for each state 
#delimit ;
foreach step in 
	_fips
	_zip
	_clocks
	_waivers_quarter
	alabama
/* 	alaska*/
	arizona
	arkansas
	california
	colorado
	connecticut
/* 	delaware*/
	florida
	georgia
	hawaii
	idaho
	illinois
	indiana
	iowa
	kansas
	kentucky
	louisiana
	maine
	maryland
	massachusetts
	michigan
	minnesota
	mississippi
	missouri
	montana
	nebraska
/* 	nevada*/
/* 	newhampshire*/
	newjersey
	newmexico
	newyork
	northcarolina
	northdakota
	ohio
	oklahoma
	oregon
	pennsylvania
 	rhodeisland
	southcarolina
	southdakota
	tennessee
	texas
/* 	utah*/
	vermont
	virginia
	washington
 	westvirginia
	wisconsin
/* 	wyoming*/
/* 	districtofcolumbia*/
	{ ;
		if ``step'' == 1 { ;
			do "${dir_code}/build/`step'/`step'.do" ;
		} ;
	} ;
#delimit cr 

// combine data
#delimit ;
foreach step in 
	combine_state_ym
	combine_county_ym
	{ ;
		if ``step'' == 1 { ;
			do "${dir_code}/combine/`step'.do" ;
		} ;
	} ;
#delimit cr 

// analyze data
#delimit ;
foreach step in 
	shortlist
	analyze_state_ym
	event_study_plot
	analyze_arizona 
	analyze_kansas
	analyze_massachusetts
	analyze_newyork
	analyze_southcarolina	
	analyze_wisconsin
	newyork_southerntier
	louisiana_analyze_closures
	california_analyze_apps
	{ ;
		if ``step'' == 1 { ;
			do "${dir_code}/analyze/`step'.do" ;
		} ;
	} ;
#delimit cr 

***********************************************

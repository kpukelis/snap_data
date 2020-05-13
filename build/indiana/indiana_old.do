// Indiana enrollment 
// Kelsey Pukelis
// 2019-11-22

// import data 
import excel "C:\Users\Kelsey\Google Drive\Harvard\research\time_limits\state_data\indiana\enrollment_abawds.xlsx", sheet("Sheet1") firstrow

// generate year month variable
gen ym = ym(year,month)
format ym %tm

// full period 
twoway connected NumberofSNAPadultsineligible ym

// keep after this number went up (probably because work requirements went back into effect at this time)
**KP: figure out why**
keep if ym >= ym(2015,7)

// mark when we would expect an effect, based on statewide fixed clock
dis ym(2015,10)
*669
*local cutoff1 = ym(2015,10) + 0.5
dis ym(2018,10)
*705
*local cutoff2 = ym(2018,10) + 0.5

// graph 
twoway connected NumberofSNAPadultsineligible ym, xline(669.5) xline(705.5)

// export graph
graph export "C:\Users\Kelsey\Google Drive\Harvard\research\time_limits\indiana_ineligibleWR.png", as(png) replace

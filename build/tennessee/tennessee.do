global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/tennessee"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local ym_start 					= ym(2011,1)
local ym_end 					= ym(2020,4)

*********************************************************************

forvalues ym = `ym_start'(1)`ym_end' {

	display in red "year and month `ym'"

}


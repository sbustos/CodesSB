*------------------------------------------------------------------------
clear all
set more off
*------------------------------------------------------------------------


/*
This DO-file prepares the WDI+ dataset, including some additional variables
 - Its the basic WDI plus
		* Data on Economic Complexity
		* Governance indicators
		* Natural resource Exports		
*/

// working and output directory
global wd "/Users/sbustos/Dropbox/datasets/WDI"
global od "/Users/sbustos/Dropbox/datasets/WDI"



*------------------------------------------------------------------------
* Ecomplexity SITC
*------------------------------------------------------------------------
use "/Users/sbustos/Dropbox/datasets/Trade_data/S2_final_cpy_all.dta", clear
rename exporter iso
cap replace inatlas = 1 if inlist(exporter,"SDN","SYR","HKG")
cap rename inatlas in_atlas
egen byte tyc = tag(year iso)
keep if tyc
keep year iso eci oppval in_atlas 
label var in_atlas  "1 = selected ctry in Atlas of Economic Complexity"
replace iso="ROM" if iso=="ROU"
drop if iso=="ROU"
foreach var of varlist _all {
	cap recast float `var', force  
}
compress
cd $wd
save temp_complexity.dta, replace 
*-----------------------------------------------------------------------

*------------------------------------------------------------------------
* Barro Lee
*------------------------------------------------------------------------
clear
cd $wd
use iso year using "WDI_current.dta", clear
cap rename countrycode iso
save temp_listisoyear.dta, replace 
use "/Users/sbustos/Documents/_s/_datos/BarroLee/BL2013_MF1599_v2.1.dta", clear
rename WBcode iso
drop if iso=="ROU"
*replace iso="ROM" if iso=="ROU"
merge 1:1 year iso using temp_listisoyear
drop _merge 
sort iso year
drop region_code BLcode country sex pop 
egen ncount = count(yr_sch), by(iso)
drop if ncount==0
save temp_barrolee.dta, replace 
levelsof iso if ncount>1, local(listiso)
foreach i of local listiso {
		noi di "`i'"
		quietly{
			keep if iso=="`i'"
			keep iso year yr_sch
			sort year 
			cap ipolate yr_sch year, g(temp)
			merge 1:1 year iso using  temp_barrolee.dta
			drop _merge 
			cap replace yr_sch = temp if iso=="`i'"
			cap drop temp
			save temp_barrolee.dta, replace 
		}	
}
drop ncount
sort iso year
foreach var of varlist _all {
	cap recast float `var', force  
}
compress
save temp_barrolee.dta, replace 

*------------------------------------------------------------------------
* PISA Scores
*------------------------------------------------------------------------
clear 
import excel using "/Users/sbustos/Documents/_s/_datos/PISA/pisa.xlsx", first
rename *, lower
destring pisa*, replace force
drop if iso==""

reshape long pisa, i(iso) j(year)
label var pisa "Pisa - Reading Scores"
replace iso="ROM" if iso=="ROU"
drop if iso=="ROU"
cd $wd
save temp_pisa.dta, replace

*------------------------------------------------------------------------
* Woessmann Cognitive Scores
*------------------------------------------------------------------------
clear 
insheet using "/Users/sbustos/Documents/_s/_datos/Woessmann/woessmann.csv"
label var gsample "gsample = HW" 
label var cognitive "cognitive = HW" 
label var lowsec  "lowsec = HW" 
label var basic "basic  = HW" 
label var top "top = HW" 
drop country
replace iso="ROM" if iso=="ROU"
drop if iso=="ROU"
cd $wd
save temp_woessmann.dta, replace 


*------------------------------------------------------------------------
* Governance indicators
*------------------------------------------------------------------------
use "/Users/sbustos/Documents/_s/_datos/Quality_of_Government/qog_std_ts_jan18.dta", clear
keep ccodealp year bl_asy25mf hf_prights kun_legabs kun_polabs wbgi*
rename ccodealp iso
sort  year iso
replace iso="ROM" if iso=="ROU"
drop if iso=="ROU"
collapse (mean) bl_asy25mf hf_prights kun_legabs kun_polabs wbgi_* , by(year iso)
save temp_qog.dta, replace 
*------------------------------------------------------------------------

*------------------------------------------------------------------------
* Natural resource exports 
*------------------------------------------------------------------------
use "/Users/sbustos/Documents/_s/_datos/Trade/NR_net_exports/NR_net_exports", clear
replace iso="ROM" if iso=="ROU"
drop if iso=="ROU"
foreach var of varlist _all {
	cap recast float `var', force  
}
compress
cd $wd
save temp_nrexports.dta, replace 
*------------------------------------------------------------------------

 
*------------------------------------------------------------------------
* PWT
*------------------------------------------------------------------------
use "/Users/sbustos/Documents/_s/_datos/International/PWT/pwt90.dta", clear
drop country
rename countrycode iso
//keep iso year emp hc rgdpo ck rkna
replace iso="ROM" if iso=="ROU"
drop if iso=="ROU"
//collapse (mean) emp hc rgdpo ck rkna, by( year iso )
foreach var of varlist _all {
	cap recast float `var', force  
}
compress


cd $wd
save temp_pwt.dta, replace 
*------------------------------------------------------------------------
 
 


*------------------------------------------------------------------------
*** 	MERGING THE FINAL DATASET 	
*------------------------------------------------------------------------
cd $wd
//use "WDI_current.dta", clear
use "WDI_current.dta", clear
cap rename countrycode iso


replace iso="ROM" if iso=="ROU"
*compress
cd $wd

merge 1:1 year iso using "temp_complexity.dta"
drop if iso=="" | year==.
drop _merge 

merge 1:1 year iso using "temp_nrexports.dta"
drop if iso=="" | year==.
drop _merge 

merge 1:1 year iso using temp_qog.dta 
drop if iso=="" | year==.
drop _merge 

merge 1:1 year iso  using temp_barrolee, keepusing(yr_sch yr_sch_pri yr_sch_sec yr_sch_ter lu lpc lsc lhc)
drop if iso=="" | year==.
drop _merge 

merge 1:1 year iso  using temp_pisa, keepusing(pisa)
drop if iso=="" | year==.
drop _merge 

merge m:1  iso  using temp_woessmann
drop if iso=="" | year==.
drop _merge 


merge 1:1  year iso  using temp_pwt
drop if iso=="" | year==.
drop _merge 


merge m:1 iso using "/Users/sbustos/Documents/_s/_datos/International/Fractionalization/fractionalization.dta", nogen 


*-----------------------------------------------------------------------------
erase temp_complexity.dta
erase temp_qog.dta
erase temp_barrolee.dta
erase temp_pisa.dta
erase temp_woessmann.dta
erase temp_nrexports.dta
*-----------------------------------------------------------------------------

// some cleaning 
sort  iso year
egen aux=max(in_atlas), by(iso)
replace in_atlas=aux if in_atlas==.
replace in_atlas=0 if in_atlas==.
cap drop aux

//       
cap label var nr_net_exports "Net Natural Resource Exports max(nr,0)"
label var nr_exports  "Natural Resource Exports"
label var nr_imports  "Natural Resource Imports"
label var wbgi_cce "Control of Corruption (WBGI)"
label var wbgi_rle  "Rule of Law (WBGI)"
label var wbgi_gee  "Government Effectiveness (WBGI)"
label var wbgi_pve  "Political Stability (WBGI)"
label var wbgi_rqe  "Regulatory Quality (WBGI)"
label var wbgi_vae  "Voice and Accountability (WBGI)"

recast int year, force
compress
egen int idc = group(iso)
label var idc "numeric id"


cd $od
merge m:1 iso using "iso2codes.dta", keep(3 1) nogen

gen byte isregion = (region=="" | region=="Aggregates")

order year iso iso2code countryname idc isregion  


cd $od
saveold wdi_extended.dta, replace 
*------------------------------------------------------------------------

//----------------------------------------------------------------------------------------
cap program drop retriveWDI
program define retriveWDI
//----------------------------------------------------------------------------------------

quietly {
		noi di "-------------------------------------------------------------------------------"
		noi di "	Downloading the World Development Indicators from the World Bank "
		noi di "-------------------------------------------------------------------------------"
		clear 
		 // Makes sure the hoi command is installed in STATA (ssc install hoi)
		*-------------------------------------------------------------------------------
		//global path "/Users/sbustos/Documents/_s/_datos/International/WDI/" // set here the path to your desired folder
		global path  "/Users/sbustos/Dropbox/datasets/WDI"
		cd "${path}"
		*-------------------------------------------------------------------------------
		noi di " - Downloading the different sections of the WDI"
		forvalues i=1/21 {
				noi di "section : `i'"
				clear 
				cap wbopendata, language(en - English) topics(`i') long clear
				cap save "${path}WDIv_`i'.dta", replace
		}
  
		clear
		use "WDIv_1.dta"
		forvalues i=2/21 {
				noi di "section : `i'"
				//cap merge 1:1 countrycode year using "${path}WDIv_`i'.dta", nogen
				cap merge 1:1 countrycode year using "WDIv_`i'.dta", nogen
				cap erase "WDIv_`i'.dta"
		}
		cap erase "WDIv_1.dta"
		cap save "WDI_current"
		noi di " "
		noi di " - Sorting and cleaning"
		*-------------------------------------------------------------------------------
		cap order _all, alpha
		cap rename countrycode iso
		order year iso    	
		noi di " "
		noi di " - Storing as float when possible"
		*-------------------------------------------------------------------------------
		// WB has their data saved as double. Here I change it to float. 
		foreach var of varlist _all {
			if "`var'" == "year" | "`var'" == "iso" | "`var'" == "countryname" ///
			 | "`var'" == "iso2code" | "`var'" == "region" | "`var'" == "regioncode"  {
			  noi di "Skipping = `var'"
			}	
			else {
				cap recast float `var' , force
			}
			
			
		}
		compress
		*-------------------------------------------------------------------------------
		save "WDI_current.dta", replace	
		noi display "Done!"
}

end 
*-------------------------------------------------------------------------------

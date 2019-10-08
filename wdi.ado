cap program drop wdi
program define wdi
 
 
* save this file in the equivalent to this folder:
* /Users/sbustos/Library/Application Support/Stata/ado/personal 
version 10

clear all
display "****************************************************************************************"
display "*****         Loading World Development Indicators - WDI     ***************************"

//use "/Users/sbustos/Documents/_s/_datos/International/WDI/WDI_current.dta"
use "/Users/sbustos/Dropbox/datasets/WDI/wdi_extended.dta", clear
sort year iso
cap sum year
local nn = `r(max)'
display "*****         Latest year in sample = `nn'                   ***************************"
display "****************************************************************************************", _c
des, short
display "****************************************************************************************"
end

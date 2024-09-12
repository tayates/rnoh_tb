** Analysis for paper
* Tom Yates, 23 November 2023

log using "V:\Tom Yates - RNOH TB audit\analysisforpaper.log", replace

* This script inputs data taken from RNOH laboratory records, which we do not have permission to share
* It was run in STATA 13.1 on an NHS desktop
* This performs some descriptive checks then runs univariable logistic regression
* Regression is performed with and without including the matching variable, calendar year
 
clear
set more off

* Import data

import excel "V:\Tom Yates - RNOH TB audit\Deidentified data 200323.xlsx", sheet("Merged data") firstrow
gen marker1=1
append using "V:\Tom Yates - RNOH TB audit\NTM data to append.dta", generate (new_obs) nolabel nonotes force
gen marker2=1

* Generate separate markers for MTBC and NTM

drop if YEAR==.

gen MTBC = 0

recode MTBC 0=1 if marker1==1 & Culture=="YES"

gen NTMonly = 0

recode NTMonly 0=1 if marker1==. & marker2==1 & Culture=="YES"

* Data checks

tab MDTupdate Sarcoma, m
tab MDTupdate2 Sarcoma, m

tab MTBC Sex if NTMonly!=1
tab MTBC Site if NTMonly!=1
tab MTBC Spine if NTMonly!=1
tab MTBC Sarcoma if NTMonly!=1

tab NTMonly Sex if MTBC!=1
tab NTMonly Site if MTBC!=1
tab NTMonly Spine if MTBC!=1
tab NTMonly Sarcoma if MTBC!=1

tab Culture Sex
tab Culture Site
tab Culture Spine
tab Culture Sarcoma

* Numbers are as expected

* Generate a prosthetic joint category

gen Prosthetic = 0
recode Prosthetic 0=1 if Site=="Prosthetic"

tab Site Prosthetic
tab Culture Prosthetic

* Tidy variables

encode Culture, gen(nCulture)
encode Sex, gen(nSex)
encode Spine, gen(nSpine)
encode Sarcoma, gen(nSarcoma)

recode nCulture 1=0 2=1

* Generate odds ratios with CIs for MTBC

logistic MTBC i.nSex ib2020.YEAR if NTMonly!=1
logistic MTBC i.Prosthetic ib2020.YEAR if NTMonly!=1
logistic MTBC i.nSpine ib2020.YEAR if NTMonly!=1
logistic MTBC i.nSarcoma ib2020.YEAR if NTMonly!=1

* Generate odds ratios with CIs for all Mycobacteria

logistic nCulture i.nSex ib2020.YEAR
logistic nCulture i.Prosthetic ib2020.YEAR
logistic nCulture i.nSpine ib2020.YEAR
logistic nCulture i.nSarcoma ib2020.YEAR

* Check the year variable doesn't mess things up

logistic MTBC i.nSex if NTMonly!=1
logistic MTBC i.Prosthetic if NTMonly!=1
logistic MTBC i.nSpine if NTMonly!=1
logistic MTBC i.nSarcoma if NTMonly!=1

logistic nCulture i.nSex
logistic nCulture i.Prosthetic
logistic nCulture i.nSpine
logistic nCulture i.nSarcoma

* Output is not meaningfully different if we omit to include the matching variable in the regression model

* FWIW (small numbers), generate odds ratios with CIs for NTMonly
* - note, number of events to small to include the matching variable

logistic NTMonly i.nSex if MTBC!=1
logistic NTMonly i.Prosthetic if MTBC!=1
logistic NTMonly i.nSpine if MTBC!=1
logistic NTMonly i.nSarcoma if MTBC!=1

* Spine does not work, because 0/6 NTM cases were in the spine

log close

# Igor8 functions
This repository contains Igor8 functions for analysis in Kano-lab.

## Functions 

1. MEM related functions 
2. Gauss-fit related functions 
3. Other functions



## Overview of analysis

1. MEM for obtaining imchi3_data

   1. prep data (three .spe files, raw, bg and nr)
   2. compile DataLoad_Preprocessing.ipf
   3. load data (use SpeloaderM())
   4. load x axis and rename it (xwavelength -> ramanshift)
   5. Preprocessing (use darknonres() and wave2Dto4DMS())
   6. memprep 
   7. memit (it will take some minutes)
   8. makeramanshift4
   9. save imchi3_data and re_ramanshift2
2. Fitting for a specific Raman band
   1. Get an averaged spectrum (sum function or other)
   2. fit with Igor Funcfit
   3. make fit image with MakeFitImageMS.ipf



# License

The source code is licensed MIT. The website content is licensed MIT license.

# LiMon_4DAIR_Data_Processing_Algorithms
<div style="text-align: justify"> Here are found the data processing algorithms related to LiMon and the technical requirements for their correct execution. The objective of this project is to retrieve aerosol optical properties such as backscattering and extinction coefficients and linear depolarization ratios. This project hosts the processing codes developed until 2022-11. </div>


# Table of contents
1. [Overview of the information flux for the LiMon data inversion algorithms](#overview)
2. [Overview of the software project built in MATLAB](#overviewcodes)
3. [1st and 2nd step: data reading and preprocessing](#first_sec)
    1. [Sub paragraph](#subparagraph1)
4. [3rd step: Klett - Fernald - Sasano Method (KFS)](#third)
5. [4th step: depolarization calibration](#fourth)


## Overview of the information flux for the LiMon data inversion algorithms <a name="overview"></a>

<img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Flujo_Lidar_KFS.svg" 
        align="center"
     	alt="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Flujo_Lidar_KFS.svg" 
        width="700" 
        height="180" 
        style="display: block; margin: 0 auto" />

In the first step the root folder for storing raw signal is defined 

## Overview of the software project built in MATLAB <a name="overviewcodes"></a>




Before stating the codes flow, it is mandatory to describe the input files. These are binary files provided by the Licel acquisition system installed on LiMon and in order to process it, a conversion to .TXT format is required and done by Licel software "Advanced Viewer". Then, the resulting file will have the following structure:

<img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/files_description.PNG" 
        align="center"
     	alt="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/files_description.PNG" 
        width="750" 
        height="350" 
        style="display: block; margin: 0 auto" />

Notice that the file name contains the date and time of the measurement, therefore, one can capture those characters in the code for naming date associated variables.
	
The codes presented in the following flow diagram are saved in this project and are thought to be as autonomous as possible, being developed based on functions that ease the reading of the programs and its execution by the researcher. The built functions are:

- telecover_obtention_profile.m: brief explanation of the function
- profile_plots.m: brief explanation of the function
- open_files.m: brief explanation of the function
- optical_products.m: brief explanation of the function 
- calibration_products.m: brief explanation of the function


<img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Flujo_Lidar_codes.svg" 
        align="center"
     	alt="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Flujo_Lidar_codes.svg" 
        width="950" 
        height="350" 
        style="display: block; margin: 0 auto" />




## 1st and 2nd step: data reading and preprocessing <a name="title1"></a>

![](https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Procesamiento%20diagrama%20de%20flujo_PRE.svg)

	
### Sub paragraph <a name="subparagraph1"></a>
This is a sub paragraph, formatted in heading 3 style

## 3rd step: Klett - Fernald - Sasano Method (KFS) <a name="title2"></a>


<img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Procesamiento%20diagrama%20de%20flujo_KFS.svg"
        alt="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Procesamiento%20diagrama%20de%20flujo_KFS.svg"
        width="800" 
        height="600" 
        style="display: block; margin: 0 auto" />

Textico:
**The Cauchy-Schwarz Inequality**

$$\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)$$


## 4th step: depolarization calibration <a name="title3"></a>


------------


------------



# LiMon Hardware



![](https://img.shields.io/github/stars/pandao/editor.md.svg) ![](https://img.shields.io/github/forks/pandao/editor.md.svg) ![](https://img.shields.io/github/tag/pandao/editor.md.svg) ![](https://img.shields.io/github/release/pandao/editor.md.svg) ![](https://img.shields.io/github/issues/pandao/editor.md.svg) ![](https://img.shields.io/bower/v/editor.md.svg)




# 4th step: depolarization calibration

Textico

----

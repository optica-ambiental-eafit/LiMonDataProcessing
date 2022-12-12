# LiMon_4DAIR_Data_Processing_Algorithms

Here are found the data processing algorithms related to LiMon and the technical requirements for their correct execution. The objective of this project is to  retrieve aerosol optical properties such as backscattering and extinction coefficients and linear depolarization ratios. This project hosts the processing codes developed until 2022-11.

# Table of contents
1. [How to use the repository](#howtorepo)
    1. [Download GitHub Desktop](#howtodownload) 
    2. [Clone the repository](#cloning)
    3. [Folder and file names](#folders)
2. [Overview of the information flux for the LiMon data inversion algorithms](#overview)
3. [Overview of the software project built in MATLAB](#overviewcodes)
4. [1st and 2nd step: data reading and preprocessing](#first_sec)
5. [3rd step: Klett - Fernald - Sasano Method (KFS)](#third)
6. [4th step: depolarization calibration](#fourth)
7. [Telecover technique for overlap characterization](#telecover)
    1. [Overlap condition](#overlapcondition)

## How to use the repository <a name="howtorepo"></a>
The repo is contained in https://github.com/optica-ambiental-eafit/LiMonDataProcessing but can be cloned to the local computer in order to edit the project easier using GitHub desktop since this application enables the user to interact with the project through a GUI (Graphic User Interface) instead of a command window or an online website.

### Download GitHub Desktop <a name="howtodownload"></a>

Download for Windows 64 bits here: https://desktop.github.com/. Once it is installed, sign in with the following username: optica.ambiental@gmail.com. The password is contained in LiMon's logbook.

### Clone the repository <a name="cloning"></a>

Before cloning, a folder called "Github" must be created in the local disc of the computer you are going to work with (C:\User\Desktop path is suggested). Here is were you are goint to "Pull down" your repo, from remote GitHub to local. In this folder, a local copy of the repository will be created and a sync between both locations will be stablished.

Follow this steps for cloning:
- Navigate to https://github.com/optica-ambiental-eafit/LiMonDataProcessing.
- Click **Code** button.
<p align="center">
  <img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/tuto_cloning1.PNG" 
   width="450" 
   height="200" />
</p>

- Copy the URL for the repository. Select **HTTPS** option and copy the link generated below.

<p align="center">
  <img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/tuto_cloning2.PNG" 
   width="390" 
   height="250" />
</p>

- Open **GitHub Desktop** in your computer and press "CTRL + Shift + O" for cloning. Select **URL** option and paste the link in the bar displayed. Then, write down the local path previously created.
- Finally, the codes are in your computer and you can edit them while changes are sync with the repository! :D. Please, copy and paste this codes to an independent folder in order to have a backup.

*This brief tutorial was written based on the one contained here: https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository.*

## Overview of the information flux for the LiMon data inversion algorithms <a name="overview"></a>

<p align="center">
  <img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Flujo_Lidar_general.svg" 
   width="860" 
   height="150" />
</p>


## Overview of the software project built in MATLAB <a name="overviewcodes"></a>

<p align="justify">
Before stating the codes flow, it is mandatory to describe the input files. These are binary files provided by the Licel acquisition system installed on LiMon and in order to process it, a conversion to .TXT format is required and done by Licel software "Advanced Viewer". Then, the resulting file will have the following structure: 
	
<p align="center">
  <img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/files_description.PNG" 
   width="750" 
   height="350" />

<p align="justify">
Notice that the file name contains the date and time of the measurement, therefore, one can capture those characters in the code for naming date associated variables. 

The codes presented in the following flow diagram are saved in this project and are thought to be as autonomous as possible, being developed based on functions that ease the reading of the programs and its execution by the researcher. The built functions are:  
	
- **telecover_obtention_profile.m:** this code aims to read telecover data and plot its profiles for each channel and can be executed in the field in order to check the alignment quality nimbly.
- **profile_plots.m:** allows to plot the signal profiles individually or all together as subplots in a figure, depending on user's request.
- **open_files.m:** takes a directory path and returns the files name for then capturing the date and time of the measurement.
- **optical_products.m:** plots the backscattering and extinction coefficients after being computed by **KFS_code.m**. Asks the user how many profiles wants to retrieve and their associated time intervals for integration.
- **calibration_products.m:** opens calibration data and computes the $\Delta 90$ gain ratio for finally calculating the particle and volume depolarization ratios. 
	
<p align="center">
  <img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Flujo_Lidar_codes.svg" 
   width="1100" 
   height="250" />
</p>

The **KFS_code.m** and **quicklook_code.m** routines are the main codes of the project and will be adressed in the following section.

## 1st and 2nd step: data reading and preprocessing <a name="first_sec"></a>

<p align="justify">
The raw data used for obtaining the optical properties of aerosols is read in the first step performed by quicklook_code.m after defining the day, month and year of the measurements of interest. This code has the Dark Current (DC) filter implemented and if the user realizes that the signal does not tend to null values, then background correction can be done from 6800 m (Rayligh's fit performed by M.Hoyos(2022)). About trigger delay correction, it was concluded by M.Hoyos(2022) that the data has an offset of 29 bins. Finally the filtered signal $P(R)$ is range corrected multiplied by the height squared and is plotted as a color scaled image (quicklook  $RCS(R)$ ). It is noteworthy that the program includes some smoothing data techniques that aim to reduce color saturation such as linear regression or gaussian weighted moving average (this have to be choose by the user in the source code).

	
<p align="center">
  <img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Depolarization%20Scanning%20lidar%20workflow.svg" 
   width="450" 
   height="500" />
</p>

## 3rd step: Klett - Fernald - Sasano Method (KFS) <a name="third"></a>

<p align="justify">
In order to perform mathematical data inversion by KFS executing KFS_code.m, the molecular Lidar Ratio and the molecular backscattering coefficient have to be well characterized at 532 nm for the local atmosphere with radiosounding, nevertheless, since 4DAIR project does not have the means to do so yet, a .TXT file of pressure and temperature profiles for a standard atmosphere model is read. Inside KFS_code.m, the function molecular.m (developed by H.M.J Barbosa, B.Barja and R.Costa) is implemented and retrieves $LR_{mol}$ and $\beta_{mol}$.

<p align="center">
  <img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Depolarization%20Scanning%20lidar%20workflow_inversion.svg" 
   width="800" 
   height="600" />
</p>


**KFS method basics**

<p align="justify">
After running molecular.m, one can proceed to evaluate the following expressions:

1) $$\beta_{aer} = -\beta_{mol} + \frac{factor1}{factor2}$$
2) $$factor_1 = RCS(R) \beta(R_0) exp\left(-2\int_{R_0}^{R} [LR_{aer}(r) - LR_{mol}]\beta_{mol}(r) dr]\right)$$
3) $$factor_2 = RCS(R_0) - 2\beta(R_0)\int_{R_0}^{R}LR_{aer}(r)RCS(r)exp\left[\left(-2\int_{R_0}^{r} [LR_{aer}(r') - LR_{mol}]\beta_{mol}(r')dr'\right)\right]dr$$

where $R_0$ is the reference height obtained with the Rayleigh fit.
This factors are calculated for each file and the function **optical_products.m** is called for the plotting of the integrated profiles.

When the code computes the value of $\beta_{aer}$, then it calculates extinction $\alpha_{aer}$ from the linear dependence stablished through the aerosol Lidar ratio $LR_{aer}$ which value for Medellin is 61 sr and it is decision of the user which quantity display with the aid of the next menus:

<img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/menu_profiles.PNG"
        alt="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/menu_profiles.PNG"
        width="500" 
        height="350" 
        style="display: block; margin: 0 auto" />

*It is noteworthy that the user **must be aware** of the time associated to the files that will enumerate in the menus*.


## 4th step: depolarization calibration <a name="fourth"></a>

The variables taken into account in **calibration_products.m** are the following:

- $\eta*(\Psi)$: apparent calibration factor at angle $\Psi$.
- $I_R(\Psi)$: light intensity at channel 1.
- $I_T(\Psi)$: light intensity at channel 0.
- $\epsilon$: error associated to the polarizer misalignment.
- $\eta_{\Delta 90}$: calibration factor with $K = 1$.
- $G_T = G_R = H_R = H_T = 1$: crosstalk parameters.
- $\delta_v*$: apparent volume linear depolarization ratio.
- $\delta_v$: volume linear depolarization ratio.
- $R$: backscatter ratio.
- $\delta_{pmol}$: molecular depolarization ratio.
- $\delta_p$: particle depolarization ratio.

which domine the equations shown in the workflow:
	
<p align="center">
  <img src="https://github.com/optica-ambiental-eafit/LiMonDataProcessing/blob/main/Local%20figures/Calibration%20workflow.svg" 
   width="580" 
   height="500" />
</p>

## Telecover technique for overlap characterization <a name="telecover"></a>

If the laser is misaligned, a telecover must be carried out for assuring the quality of the measurements. The code **telecover_obtention_profile.m** evaluates the signal registered when each one of the channels were covered and can be executed in the field to check if the overlap condition is satisfied.

### Overlap condition: <a name="overlapcondition"></a>

$$ North(1A) = North(1B) < East(2) = West (3) < South(4)$$

------------


------------



# LiMon Hardware



![](https://img.shields.io/github/stars/pandao/editor.md.svg) ![](https://img.shields.io/github/forks/pandao/editor.md.svg) ![](https://img.shields.io/github/tag/pandao/editor.md.svg) ![](https://img.shields.io/github/release/pandao/editor.md.svg) ![](https://img.shields.io/github/issues/pandao/editor.md.svg) ![](https://img.shields.io/bower/v/editor.md.svg)


----

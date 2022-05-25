Colocalization and Quantification script for P3HT Immunofluorescence

This script was built and run in MATLAB R2021a running on Windows 10 Pro, v10.0.18362 Build 18362

Required Software:
MATLAB and MATLAB Image Processing Toolbox
ImageJ (recommended to keep clean reference open while thresholding)

Included files:
- NanoEx.m - main script file (launch this)
	
- ci_loadLif.m - script to load Leica .lif files into MATLAB (made by Ron Hoebe, Cellular Imaging - Core Facility, AMC - UvA - Amsterdam - The Netherlands)[1]
	
- abThresh.m - function module to handle inputs and outputs for channel thresholding

Instructions:
Make sure your MATLAB and its Image Processing Toolbox add-on are up to date, and run MATLAB with admin rights.

IMPORTANT: This script was made to work with a 3-channel image with nuclear staining on channel 1, antibody staining on channel 2 and NP fluorescence on channel 3. other channel numbers/configurations might give nonsensical results or not work outright.

Launch NanoEx.m, and point the dialog to the .lif file to analyze.

Once it loads (this might take a minute), a dialog will ask for the sequence number from the list on the left. 

A max intensity projection of the nuclei will appear, allowing you to draw points of a polygonal ROI (we used this to isolate the the retinal Inner Nuclear Layer). double-click the last point to close the polygon and proceed.

You will then be asked to threshold the antibody channel. The upper slider in the window is the threshold level, coupled with a density histogram. the lower slider is the z-depth.
once you set and apply, you will be asked to threshold the NP channel in the same manner.

The following elaboration phase might take a couple of minutes, after which you should see a 3D plot of your image with the NP in red and NP-Antibody contacts represented by magenta squares.

This figure and the output data will be written to an .xlsx file in a new folder named Output Data.

[1] Ron Hoebe (2022). Load Leica LIF File (https://www.mathworks.com/matlabcentral/fileexchange/48774-load-leica-lif-file), MATLAB Central File Exchange. Retrieved May 25, 2022.

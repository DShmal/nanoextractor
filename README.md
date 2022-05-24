# nanoextractor
MATLAB script for .lif image analysis of P3HT nanoparticles
Colocalization and Quantification script for P3HT Immunofluorescence

This script was built and run in MATLAB R2021a running on Windows 10 Pro, v10.0.18362 Build 18362

Required Software:
MATLAB and MATLAB Image Processing Toolbox
ImageJ (recommended to keep clean reference open while thresholding)

Included files:
	NanoEx.m - main script file (launch this)
	ci_loadLif.m - script to load Leica .lif files into MATLAB (made by Ron Hoebe, Cellular Imaging - Core Facility, AMC - UvA - Amsterdam - The Netherlands)
	abThresh.m - function module to handle inputs and outputs for channel thresholding
	Test Image for Review.lif - sample raw image containing a juxta-injection-site z-stack acquisition on 3 channels: Hoechst, Alexa 488 (anti-Calbindin1), P3HT fluorescence at 650-700nm.
	Test Image for Review.lifext - extended metadata file for the above

Instructions:
Make sure your MATLAB and its Image Processing Toolbox add-on are up to date, and run MATLAB with admin rights.

Launch NanoEx.m, and point the dialog to the 3-channel .lif to analyze.
Nuclear staining should be on channel 1, Antibody on channel 2 and Nanoparticles on channel 3.

Once it loads (this might take a minute), a dialog will ask for the sequence number to analyze from the list on the left.
A max intensity projection of the nuclei will appear, allowing you to draw points of a polygonal ROI (we used this to isolate the the Inner Nuclear Layer). double-click the last point to close the polygon and proceed.

You will then be asked to threshold the antibody channel. the sample image is a staining for Calbindin1, which marks Horizontal Cells of the outer retina. the upper slider in the window is the threshold level, coupled with a density histogram. the lower slider is the z-depth.
once you set and apply, you will be asked to threshold the P3HT channel in the same manner.

The following elaboration phase might take a couple of minutes, after which you should see a 3D plot of your image with the P3HT in red and P3HT-Antibody contacts represented by magenta squares.

This figure and the output data will be written to an .xlsx file in a new folder named Output Data.


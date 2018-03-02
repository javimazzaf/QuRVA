% Copyright (C) 2018 Javier Mazzaferri and Santiago Costantino 
% <javier.mazzaferri@gmail.com>
% <santiago.costantino@umontreal.ca>
% Hopital Maisonneuve-Rosemont, 
% Centre de Recherche
% www.biophotonics.ca
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


QuRVA (Version 1.2)
-------------------

This algorithm is described in :
A machine learning approach for automated assessment of retinal vasculature 
in the oxygen induced retinopathy model.
Javier Mazzaferri, Bruno Larrivee, Bertan Cakir, Przemyslaw Sapieha, Santiago Costantino 
Scientific Reports, 2018

https://www.nature.com/articles/s41598-018-22251-7

************************
* PLEASE CITE OUR WORK *
************************

Software operation: 
------------------

1. Gather the flat mount images in one folder in tif of jpg format
2. Run the function processFolder.m and select the previous folder in 
   the selector dialog.

The quantitative results are stored in the Reports folder withing the 
images folder. The images for the avascular region and tufts are stored in 
VasculatureImages and TuftImages respectivelly.

All parameters for the processing are in the parameters.ini file and can be 
adjusted to optmize the results in a particular images set.

Training your own database:
--------------------------

The software is released with a model trained with a limited number of images.
You can train the model yourself by running the trainModel script. 
To do so:
 1. Create a folder inside your images folder and name it 
    "ManualSegmentations" store the manual segmentations of all the images 
    you have in your image folder and name them with the same name as the 
    original image but adding .tif to the file name. This images must be 
    binary images having foreground pixels where there are tufts.
 2. Run the script trainModel. It will save a file named model.mat in your 
    images folder. Copy this file to the code folder and it will be ready 
    to run processFolder with your new model.

Dependencies:
------------
 - MATLAB version 9.3
 - Signal Processing Toolbox Version 7.5
 - Image Processing Toolbox version 10.1
 - Statistics and Machine Learning Toolbox version 11.2
 - Curve Fitting Toolbox version 3.5.6




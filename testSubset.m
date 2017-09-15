
thisDir = '/Users/javimazzaf/Dropbox (Biophotonics)/Francois/310117TOTM/';
selectedFiles = getImageList(thisDir);

selectedFiles = selectedFiles(1:10);

processFolder(thisDir, selectedFiles);
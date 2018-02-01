function mask = getSwiftMask(swiftFolder, imageFileName, userName, consensusMask)

    fname = fullfile(swiftFolder, userName, imageFileName);
    
    if exist(fname,'file')
        thisImage = imread(fname);
    
        thisImage = imresize(thisImage, size(consensusMask));
        mask = logical(rgb2gray(thisImage));
    else
        mask = zeros(size(consensusMask));
    end
        
end
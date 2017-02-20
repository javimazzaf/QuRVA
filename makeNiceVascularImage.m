function niceImage=makeNiceVascularImage(myImage, myAVascZone, mySkeleton, myBrchPts)
    
    dikSize=round(size(myImage, 1)/1000);

    redChannel=myImage/2;
    greenChannel=myImage/2;
    blueChannel=myImage/2;

    myBrchPts=imdilate(myBrchPts, strel('disk', dikSize));
    mySkeleton=imdilate(mySkeleton, strel('disk', dikSize));
    
    redChannel(mySkeleton~=0)=255;
    greenChannel(myBrchPts~=0)=255;
    blueChannel(myAVascZone~=0)=255;

    niceImage=cat(3, redChannel, greenChannel, blueChannel);

end

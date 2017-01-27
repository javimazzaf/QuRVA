function niceImage=makeNiceVascularImage(myImage, myAVascZone, mySkeleton, myBrchPts)

    redChannel=myImage/2;
    greenChannel=myImage/2;
    blueChannel=myImage/2;

    mySkeleton=imdilate(mySkeleton, strel('disk', 3));
    redChannel(mySkeleton~=0)=255;

    myBrchPts=imdilate(myBrchPts, strel('disk', 3));
    greenChannel(myBrchPts~=0)=255;

    blueChannel(myAVascZone~=0)=255;

    niceImage=cat(3, redChannel, greenChannel, blueChannel);

end

function [maskProps, maskNoCenter]=processMask(varargin)


myMask=varargin{1};
myImage=varargin{2};

maskProps=regionprops(myMask, myImage, 'EquivDiameter', 'WeightedCentroid');

if nargin==3
    thisONCenter=varargin{3};

    newCenterCircleMask=createCircularMask(size(myMask, 1), size(myMask, 2),...
        thisONCenter(1), thisONCenter(2), maskProps.EquivDiameter*.1);

    maskNoEdge=createCircularMask(size(myMask, 1), size(myMask, 2),...
        thisONCenter(1), thisONCenter(2), maskProps.EquivDiameter*.4);

else
    maskOfCenter=createCircularMask(size(myMask, 1), size(myMask, 2),...
        maskProps.WeightedCentroid(1), maskProps.WeightedCentroid(2), maskProps.EquivDiameter*.2);

    newCentroid=regionprops(maskOfCenter, myImage, 'WeightedCentroid');

    newCenterCircleMask=createCircularMask(size(myMask, 1), size(myMask, 2),...
        maskProps.WeightedCentroid(1), maskProps.WeightedCentroid(2), maskProps.EquivDiameter*.1);

    maskNoEdge=createCircularMask(size(myMask, 1), size(myMask, 2),...
        maskProps.WeightedCentroid(1), maskProps.WeightedCentroid(2), maskProps.EquivDiameter*.4);
end

maskNoCenter=maskNoEdge.*~newCenterCircleMask;
function [maskProps, maskNoCenter, thisONCenter]=processMask(varargin)

readConfig

myMask=varargin{1};
myImage=varargin{2};

maskProps=regionprops(myMask, myImage, 'EquivDiameter', 'WeightedCentroid', 'BoundingBox');
[~,ix] = max([maskProps(:).EquivDiameter]);
maskProps = maskProps(ix);

rMin = maskProps.EquivDiameter/2 *tufts.circMask.min;
rMax = maskProps.EquivDiameter/2 *tufts.circMask.max;

if nargin==3
    thisONCenter=varargin{3};

    newCenterCircleMask=createCircularMask(size(myMask, 1), size(myMask, 2),...
        thisONCenter(1), thisONCenter(2), rMin);

    maskNoEdge=createCircularMask(size(myMask, 1), size(myMask, 2),...
        thisONCenter(1), thisONCenter(2), rMax);

else
    maskOfCenter=createCircularMask(size(myMask, 1), size(myMask, 2),...
        maskProps.WeightedCentroid(1), maskProps.WeightedCentroid(2), maskProps.EquivDiameter*.2);

    newCentroid=regionprops(maskOfCenter, myImage, 'WeightedCentroid');

    newCenterCircleMask=createCircularMask(size(myMask, 1), size(myMask, 2),...
        maskProps.WeightedCentroid(1), maskProps.WeightedCentroid(2), rMin);

    maskNoEdge=createCircularMask(size(myMask, 1), size(myMask, 2),...
        maskProps.WeightedCentroid(1), maskProps.WeightedCentroid(2), rMax);
    
    thisONCenter=maskProps.WeightedCentroid;
end

maskNoCenter = maskNoEdge .* ~newCenterCircleMask;
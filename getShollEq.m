function shollOut=getShollEq(vesselSkelMask, maskStats, thisONCenter)

[rr cc] = meshgrid(1:round(size(vesselSkelMask,2)), 1:round(size(vesselSkelMask,1)));

shollOut=0;

for it=1:round(maskStats.EquivDiameter/100):round(maskStats.EquivDiameter)

    thisCircle = round(sqrt((rr-thisONCenter(1,1)).^2+(cc-thisONCenter(1,2)).^2))==it;
    
    shollOut=[shollOut; sum(sum(thisCircle.*logical(vesselSkelMask)))];
    
end

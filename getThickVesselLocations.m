function getThickVesselLocations()
miDistancia=bwdist(~smoothVessels);
skelMiDist=(miDistancia.*vesselSkelMask);
imshow(skelMiDist>mean(nonzeros(skelMiDist(:)))+3*std(nonzeros(skelMiDist(:))))
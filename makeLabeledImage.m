function outMask=makeLabeledImage(inMask)

imageStats=struct2table(regionprops(inMask, 'Centroid'));
lblImage=label2rgb(bwlabel(inMask), 'prism', 'k');
thisColorMap=prism;

for it=1:size(imageStats,1)
    lblImage=addNumbersImage(lblImage, it, [20 40], [round(imageStats.Centroid(it,2)),...
        round(imageStats.Centroid(it,1))], thisColorMap(mod(it+1,64)+1,:)*255);
end

outMask=lblImage;
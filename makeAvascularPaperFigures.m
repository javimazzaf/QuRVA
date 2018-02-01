% Usa las variables de la función getAvascularZone2. Para generar estas
% imagenes, ejecuté AnalyzeThisFolder en la imagen 11, y puse un breakpoint
% al final de getAvascularZone. Luego ejecuté este script con cmd+return

statsMask = regionprops(originalMask, 'BoundingBox');

% Step 1
dilSkel = imdilate(vesselSkelMask,strel('disk',2));

imPlusSkel = imoverlay(zeros(size(imOrig)),dilSkel,[0.5,0.5,0]);

circImage = imdilate(bwperim(maskNoEdge),strel('disk',3));

imPlusSkelPlusCirc = imoverlay(imPlusSkel,circImage,'r');

niceLbl=bwlabel(aVascRegions);

imPlusSkelPlusCircPlusRegions = imPlusSkelPlusCirc + label2rgb(niceLbl, 'lines', 'k');

imPlusSkelPlusCircPlusRegions = imcrop(imPlusSkelPlusCircPlusRegions, statsMask.BoundingBox);

imwrite(imPlusSkelPlusCircPlusRegions,fullfile('/Users/javimazzaf/Documents/work/proyectos/flatMounts/Anonymous/ValidationVasculature/','step1.png'))

% Step 2
allRegionsPerim = imdilate(bwperim(aVascRegions),strel('disk',2));
distPlusAll     = imoverlay(mat2gray(dist2vessels),allRegionsPerim,'r');

selRegionsPerim = imdilate(bwperim(mostEmptyIm),strel('disk',2));
distPlusAllPlusSel = imoverlay(distPlusAll,selRegionsPerim,'c');

distPlusAllPlusSel = imcrop(distPlusAllPlusSel, statsMask.BoundingBox);

imwrite(distPlusAllPlusSel,fullfile('/Users/javimazzaf/Documents/work/proyectos/flatMounts/Anonymous/ValidationVasculature/','step2.png'))

% Step 3
imwrite(imcrop(imoverlay(imOrig,aVascZone,'c'), statsMask.BoundingBox),fullfile('/Users/javimazzaf/Documents/work/proyectos/flatMounts/Anonymous/ValidationVasculature/','step3.png'))

% testing

% cutPerc = 3;
% 
% mn = min(double(rawImage(:))) + double(range(rawImage(:))) / 100 * cutPerc; mx = max(double(rawImage(:))) - double(range(rawImage(:))) / 100 * cutPerc;
% noExtremeMask = rawImage > mn & rawImage < mx;

% threshold = double(median(enhancedTufts(vascMask)))
% threshold = double(mean(rawImageNorm(noExtremeMask & vascMask)))
% threshold = 0.4;
% outMask = enhancedTufts >= threshold;

[outMask, coarse, intens ] = getTuftNew(rawImageNorm, vascMask);

thickMask = outMask;
tuftsMask = logical(thickMask) .* maskNoCenter;

load(fullfile(masterFolder,'TuftConsensusMasks',['Image001.jpg.mat']),'allMasks','consensusMask')
redImage = rawImage; 
imErrors = imoverlay(imoverlay(imoverlay(redImage, uint8(tuftsMask-consensusMask>0)*255, 'm'), uint8(tuftsMask-consensusMask<0)*255, 'y'), uint8(and(consensusMask, tuftsMask))*255, 'g');

satIm = rawImage == max(rawImage(:));
imErrors = imoverlay(imErrors,satIm,'r');

visualizeMultiImages(imErrors,{rawImageNorm;coarse;intens;outMask},100);

% readConfig;
% 
% myFiles = getImageList(masterFolder);
% 
% scl = 0.25;
% 
% sz = 30 * scl;
% sgm = sz / 2 / sqrt(2);
% ker1 = fspecial('gaussian', ceil(0.5 * 6) * [1 1] , 0.5);
% ker2 = - fspecial('log', ceil(sgm * 2 * 8) * [1 1] , sgm * 2);
% 
% %% Do loop
% for it = 1:14
%     
%     %% Verbose current Image
%     disp(myFiles{it})
%     
%     %% Read image
%     thisImage = double(imread(fullfile(masterFolder, myFiles{it})));
%     
%     thisImage = imresize(thisImage,scl);
%     
%     bp1 = filter2(ker1,thisImage,'same');
%     bp1 = max(bp1,0);
% 
%     bp2 = filter2(ker2,thisImage,'same');
%     bp2 = max(bp2,0);
%     
% %     bp1   = bpass(thisImage,5,400);
% %     bp2   = bpass(thisImage,30,400);
%     multi = bp1 .* bp2;
%     
%     mask = 
%     
%     resIm = [[mat2gray(thisImage),...
%              mat2gray(bp1)];...
%              [mat2gray(bp2),...
%              mat2gray(multi)]...
%              ];
%     
%     imshow(resIm,[])
%     
%     
% end




% sz = 30;
% sgm = sz / sqrt(2);
% ker = - fspecial('log', ceil(sgm * 8) * [1 1] , sgm);
% 
% delta = zeros(1024);
% delta(512,512) = 1;
% 
% r = [];
% mx = [];
% mn = [];
% for k = 1:4:100
%     
%     im = imdilate(delta,strel('disk',k,8));
%     
%     res = filter2(ker,im,'same');
%     
%     r = [r k];
%     mx = [mx max(res(:))];
%     mn = [mn min(res(:))];
%     
%     disp(k)
% end
% 
% subplot(2,1,1), plot(r,mx)
% 
% subplot(2,1,2), plot(r,mn)


% imshow([mat2gray(im),mat2gray(res)],[])


%%
% lp = filter2(fspecial('disk',tufts.lowpassFilterSize/2), rawImageNorm,'same'); 
lp = filter2(fspecial('gaussian',[11 11],5),rawImageNorm,'same');
% lp = bpass(rawImageNorm,1,30); 

hp = bpass(rawImageNorm,1,5);
mskHP = imbinarize(hp, adaptthresh(hp, 'NeighborhoodSize', vascNet.ThreshNeighborSize));
mskHP = bwareaopen(mskHP, 100);
% thresholdHP = (max(hp(:)) - min(hp(:))) * 0.05 + min(hp(:)); 
% mskHP = double(hp >= thresholdHP);

counterHP = filter2(fspecial('disk',11),mskHP,'same');
sumHP     = filter2(fspecial('disk',11),mskHP .* rawImageNorm,'same');
avgHP     = sumHP ./ counterHP;

% SEGUIR PROBANDO ESTA MEJORA DE COMPRAR EL PASABAJO CON UNA ESTIMACION LOCAL DEL BRILLO EN LOS OBJETOS DEL TAMAO DE LOS VASOS.

%% ESTOY PROBANDO ESTO
msk = lp > 0.8 * avgHP;

% msk = bwareaopen(msk,25);

alone = cat(3, zeros(size(rawImage)),rawImage, rawImage);
full  = cat(3, uint8(msk).*rawImage,rawImage, rawImage);

figure; imshow(alone,[])
figure; imshow(full,[])
% FALTARIA VER SI AYUDA USAR bwareaopen para sacar objetos chicos y ver que nos queda.
% Luego jugar con las escalas de los filtros.

%% Testings
% testIm = zeros(256);
% 
% 
% for k=1:50
% testIm = zeros(256);
% testIm(:,128+(0:k-1)) = 1;
% 
% bajo = filter2(fspecial('gaussian',[31 31],15),testIm,'same');
% 
% 
% 
% vascMask  = imbinarize(mat2gray(bpass(rawImageNorm,1,5)));
% threshold = median(rawImageNorm(vascMask));
% 
% % plot(bajo(128,:),'-b'), hold on
% % plot(alto(128,:),'-r')
% 
% % ratio(k) = (max(bajo(128,:)) / max(alto(128,:)));
% ratio(k) = max(alto(128,:));
% 
% end
% 
% plot(1:k,ratio,'.-r')
% 
% % hp = imdilate(bpass(rawImageNorm,1,5),strel('disk',20));
% % 
% % test = (lp > 0.5*hp) & hp > median(nonzeros(hp(:)));
% % 
% % imred = rawImageNorm;
% % imred = uint8(mat2gray(imred) * 255);
% % quadNW=cat(3, uint8(test).*imred,imred, imred);
% % quadNE=cat(3, imred, imred, imred);
% 
% % figure; imshow([quadNW quadNE])

%% FFT test
smt = filter2(fspecial('gaussian',[5 5],1),rawImageNorm,'same');
ft = abs(fftshift(fft2(double(mat2gray(smt)))));

[yo,xo] = find(ft == max(ft(:)),1,'first');

Nx = size(ft,2);
Ny = size(ft,1);

[X,Y] = meshgrid(1:Nx,1:Ny);
R = round(sqrt((X-xo).^2+(Y-yo).^2));

maxR = min([R(yo,1) R(yo,Nx) R(1,xo) R(Ny, xo)]);

for k = 1:maxR
    ring = R == k;
    prof(k) = sum(ft(ring(:)));
end

plot(prof)

% imshow(log(),[])
% plot(ft(size(ft,1)/2,:))

%%
lowpass = filter2(fspecial('disk',5),rawImageNorm,'same');
regions = detectMSERFeatures(lowpass);

areas = [];
bright = [];

for k = 1:regions.Count
    pxInd = sub2ind(size(lowpass),regions.PixelList{k}(:,2),regions.PixelList{k}(:,1));
    areas(k) = numel(pxInd);
    bright(k) = mean(lowpass(pxInd));
end


msk = bright > 0.6;

selectedRegions = regions(msk);

outMask = zeros(size(lowpass),'logical');

for k = 1:selectedRegions.Count
    pxInd = sub2ind(size(rawImageNorm),selectedRegions.PixelList{k}(:,2),selectedRegions.PixelList{k}(:,1));
    outMask(pxInd) = true;
end

newMask = imopen(outMask,strel('disk',6));

set(0,'DefaultFigureWindowStyle','docked')
figure(1); imshow(rawImageNorm,[])
figure(2); imshow(lowpass,[])
% figure(2); imshow(imoverlay(rawImageNorm,newMask,'g'))
set(0,'DefaultFigureWindowStyle','normal')

%%




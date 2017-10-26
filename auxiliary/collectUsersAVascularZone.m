clear 

users={'Santiago' 'Carlos' 'Javier' 'Bruno' 'Erika' 'Natalija'};

rotatedAngles=-90*[1 0 1 1 1 0 1 1 1 0 0 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 0 1 0 1 1 1 1];

readConfig;

rawFileNames = dir([masterFolder 'Im*']);

for itUser=1:numel(users)
    users{itUser}

    for it=1:14% numel(rawFileNames)
        image4channel=imread(fullfile(testersFolder, 'vascular', [users{itUser} '.tiff']),it);
        image4channel=imrotate(image4channel, rotatedAngles(it));
        thisRawImage=imread(fullfile(masterFolder, rawFileNames(it).name));

        trimedImage=trimThisImage(image4channel);

        magentaMaskOriginal=createMagentaMask(trimedImage);
        
        magentaMaskOriginal = imclose(magentaMaskOriginal,strel('disk',5));
        
        magentaMaskFilled=imfill(magentaMaskOriginal, 'holes');
        
        magentaMaskFilled = imerode(magentaMaskFilled,strel('disk',5));
        
        magentaMasks{it}=imresize(logical(magentaMaskFilled), [size(thisRawImage,1), size(thisRawImage,2)]);
    end

save(fullfile(testersFolder, 'vascular', ['Masks' users{itUser} '.mat']), 'magentaMasks')

end
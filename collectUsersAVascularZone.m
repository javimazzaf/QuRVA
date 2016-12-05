clear 

users={'Santiago'};

rotatedAngles=-90*[1 0 1 1 1 0 1 1 1 0 0 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 0 1 0 1 1 1 1];

masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/Bruno/Images/ToTest/';
rawImgFolder=[masterFolder 'Anonymous/'];

rawFileNames=dir([rawImgFolder 'Im*']);

for itUser=1:numel(users)
    users{itUser}

    for it=1:15% numel(rawFileNames)
        image4channel=imread([masterFolder 'Testers/vascular/' users{itUser} '.tiff'],it);
        image4channel=imrotate(image4channel, rotatedAngles(it));
        thisRawImage=imread([rawImgFolder rawFileNames(it).name]);

        trimedImage=trimThisImage(image4channel);

        magentaMaskOriginal=createMagentaMask(trimedImage);

        magentaMasks{it}=imresize(logical(magentaMaskOriginal), [size(thisRawImage,1), size(thisRawImage,2)]);
    end

save([masterFolder 'Testers/vascular/Masks' users{itUser} '.mat'], 'magentaMasks')

end
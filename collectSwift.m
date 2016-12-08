function allSwiftMasks=collectSwift(masterFolder, imageFileName, consensusMask)

folderNames={'Kalo' 'Bruno' 'Santiago' 'Francois' 'Carlos' 'Agnieszka'};

for itUser=1:numel(folderNames)
    isFile(itUser)=logical(exist([masterFolder 'SWIFT' filesep folderNames{itUser} ...
        filesep imageFileName(strfind(imageFileName, 'Image'):strfind(imageFileName, '.mat')-1)],'file'));  
    if isFile(itUser)==1
        thisImage=imread([masterFolder 'SWIFT' filesep folderNames{itUser} ...
        filesep imageFileName(strfind(imageFileName, 'Image'):strfind(imageFileName, '.mat')-1)]);
    
        thisImage=imresize(thisImage, size(consensusMask));
        allSwiftMasks(:,:,itUser)=logical(rgb2gray(thisImage));
    else
        allSwiftMasks(:,:,itUser)=zeros(size(consensusMask));
    end
        
end


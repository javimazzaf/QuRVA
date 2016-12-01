function allSwiftMasks=collectSwift(masterFolder, imageFileName, consensusMask)

folderNames={'Bruno', 'Carlos', 'Santiago'};

for itUser=1:numel(folderNames)
    isFile(itUser)=logical(exist([masterFolder 'SWIFT' filesep folderNames{itUser} ...
        filesep imageFileName(strfind(imageFileName, 'Image'):strfind(imageFileName, '.mat')-1)],'file'));    
end

haveThisImage=find(isFile);

for itFolder=1:sum(isFile)
    thisImage=imread([masterFolder 'SWIFT' filesep folderNames{haveThisImage(itFolder)} ...
        filesep imageFileName(strfind(imageFileName, 'Image'):strfind(imageFileName, '.mat')-1)]);
    
    thisImage=imresize(thisImage, size(consensusMask));
    
    allSwiftMasks(:,:,itFolder)=logical(rgb2gray(thisImage));
end

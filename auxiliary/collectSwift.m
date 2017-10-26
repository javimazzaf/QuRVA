function allSwiftMasks=collectSwift(masterFolder, imageFileName, consensusMask)

folderNames={'Kalo' 'Bruno' 'Santiago' 'Francois' 'Carlos' 'Agnieszka'};

for itUser=1:numel(folderNames)
    imName = regexp(imageFileName,'(?=Image).+?(?=\.mat)','match');
    fname = fullfile(masterFolder, 'SWIFT', folderNames{itUser}, imName{:});
    
    if exist(fname,'file')
        thisImage = imread(fname);
    
        thisImage = imresize(thisImage, size(consensusMask));
        allSwiftMasks(:,:,itUser)=logical(rgb2gray(thisImage));
    else
        allSwiftMasks(:,:,itUser)=zeros(size(consensusMask));
    end
        
end


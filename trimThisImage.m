function smallImage=trimThisImage(image4channel)

redImage=(image4channel(:,:,1));

mySum=sum(redImage);
emptyCols=sum(mySum==255*size(redImage,1));

mySum=sum(redImage');
emptyRows=sum(mySum==255*size(redImage,2));

smallImage=image4channel(ceil(emptyRows/2+1):floor(end-emptyRows/2), ceil(emptyCols/2+1):floor(end-emptyCols/2), :);

    

function smallImage=trimThisImage(image4channel)

redImage=(image4channel(:,:,1));

mySum=sum(redImage);
emptyCols=sum(mySum==255*size(redImage,1));

mySum=sum(redImage');
emptyRows=sum(mySum==255*size(redImage,2));


smallImage=image4channel(emptyRows/2+1:end-emptyRows/2, emptyCols/2+1:end-emptyCols/2, :);

    

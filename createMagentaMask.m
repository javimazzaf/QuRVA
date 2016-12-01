function magentaMask=createMagentaMask(image4channel)

thisRed=image4channel(:,:,1);
thisGreen=image4channel(:,:,2);
thisBlue=image4channel(:,:,3);

positiveRed=find(and(thisRed>120,thisRed<210));
positiveGreen=find(and(thisGreen>=0,thisGreen<120));
positiveBlue=find(and(thisBlue>75,thisBlue<255));

positivePixels=intersect(intersect(positiveRed, positiveGreen), positiveBlue);

magentaMask=zeros(size(thisRed));
magentaMask(positivePixels)=1;
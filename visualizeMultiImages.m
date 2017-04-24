function visualizeMultiImages(masterIm,images,sz)

rng = (-floor(sz/2)+1:floor(sz/2)); 

set(0,'DefaultFigureWindowStyle','docked')

figure(1); imshow(masterIm,[],'Border','Tight')
dc = datacursormode(1);

set(dc,'UpdateFcn',@onUpdate,'DisplayStyle','datatip',...
    'SnapToDataVertex','off','Enable','on');

figure(2); imshow(images{1},[],'Border','Tight')   

set(0,'DefaultFigureWindowStyle','normal')

function txt = onUpdate(~,event_obj)
% Customizes text of data tips

cp = get(event_obj,'Position');
txt = {['row: ',num2str(cp(2))],...
	   ['col: ',num2str(cp(1))]};
   

rr = rng + cp(2);
cr = rng + cp(1);
   
subImages = images;

for k = 1:numel(images)

    aux = mat2gray(images{k}(rr,cr));

    aux = insertText(aux,[10 10],num2str(images{k}(cp(2),cp(1))),...
                   'FontSize',10,...
                   'BoxColor','yellow',...
                   'BoxOpacity',0.4,...
                   'TextColor','green');
    subImages{k} = insertMarker(aux,[50 50]);
end

clf(2,'reset');

switch numel(subImages)
    case 1, dispImage = subImages{1};
    case 2, dispImage = [subImages{1};subImages{2}];
    case 3, dispImage = [subImages{1};subImages{2};subImages{3}];
    case 4, dispImage = [subImages{1},subImages{2};subImages{3},subImages{4}];
end

figure(2); imshow(dispImage,[],'Border','Tight') 
figure(1);
   
end


end
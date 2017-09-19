% [x, y] = meshgrid(1:256,1:256);
% 
% sigma = 4;
% 
% 
% 
% h = fspecial('log',(2*ceil(2*sz)+1) * [1 1], sigma);
% 
% for sz = 1:30
%     
%     im = exp( - (x - 128).^2 / 2 / sz^2);
%     
%     imshow(imregionalmax(im),[]);
%     
% %     h = h / max(h(:));
%     
%     imFilt = filter2(h,im);
% 
%     plot(im(128,:)), hold on
% %     plot((1:size(h,2)) - (size(h,2)-1) / 2 + 127, h((size(h,2)-1) / 2 + 1,:))
%     plot(imFilt(128,:)), hold off
%     
%     mx(sz) = max(imFilt(128,:));
% 
% end
% 
% plot(mx)
% 
% % imshow(im,[])
% 

im = imread('/Users/javimazzaf/Documents/work/proyectos/flatMounts/Anonymous/Image002.jpg');
im = im(:,:,1);
% msk = imregionalmax(im);
% msk = imextendedmax(im,100);



imshow(imoverlay(im,bwareaopen(msk,3),'m'),[])

function outMask = getTuftQC(inMask)

tb = struct2table(regionprops(logical(inMask),'Perimeter','Area','Solidity','PixelIdxList'));

id = (1:size(tb,1))';

fillIndex = tb.Perimeter(:) ./ tb.Area(:);

tb = [table(id), tb, table(fillIndex)];

figure;
% subplot(2,1,1)
% plot(id,tb.Perimeter(:),'.-r'), hold on
% plot(id,tb.Area(:),'.-b'), hold off
% 
% subplot(2,1,2)
% plot(id,fillIndex,'.-k')
plot(id,tb.Solidity(:),'.-k')

outMask = zeros(size(inMask),'logical');

idx = tb.PixelIdxList(tb.Solidity > 0.5); 

idx = [cell2mat(idx(:))];

outMask(idx) = true;

disp(1)



% outMask = filter2(fspecial('disk',20),inMask,'same') > 0.5;
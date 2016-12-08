function outMask = getTuftQC(inMask)

tb = struct2table(regionprops(logical(inMask),'Perimeter','Area'));

fillIndex = tb.Perimeter(:) ./ tb.Area(:);

tb = [tb table(fillIndex)];

figure;

outMask = filter2(fspecial('disk',20),inMask,'same') > 0.5;
function prepareTrainingImages

% Including code path safely
codeDirectory = '..';
addpath(codeDirectory);
toDelete = onCleanup(@() rmpath(codeDirectory));

masterFolder = '/Users/javimazzaf/Documents/work/proyectos/flatMounts/Anonymous/';

fls = dir(fullfile(masterFolder,'*.jpg'));
fls = {fls(:).name};

fg = figure();

for it = 1:numel(fls)
    
    [im, ~] = resetScale(imread(fullfile(masterFolder,fls{it})));
    
    imshow(im,[],'Border','Tight');
    hold on
    text(20, 100, fls{it}, 'Color','y', 'FontSize', 40)
    
    imAnnotated = print('-RGBImage');
    
    imwrite(imAnnotated, fullfile(masterFolder,'testingImages.tiff'),'WriteMode','append')
    
    clf(fg)
end

end

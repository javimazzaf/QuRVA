function compareAvascularResults

readConfig

mkdir(masterFolder, 'GlobalVascular')

%% Get file names
myFiles = dir(fullfile(masterFolder, 'VasculatureNumbers','*.mat'));
myFiles = {myFiles(:).name};

for it = 1:numel(myFiles)
    
    fname = myFiles{it};
    fname = fname(1:end-4);
    
    thisImage = imread(fullfile(masterFolder, fname));
    
    load(fullfile(masterFolder, 'Masks',    myFiles{it}), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', myFiles{it}), 'thisONCenter');
    
    [aVascAllMasks, aVascVotos] = getAVascularConsensusMask(it);
    
    aVascTodos = logical(sum(aVascAllMasks,3));
    
    load(fullfile(masterFolder, 'VasculatureNumbers', myFiles{it}),...
            'vesselSkelMask', 'aVascZone');
        
    % Votos    
    FNimage = (aVascVotos > aVascZone) & thisMask; 
    FPimage = (aVascVotos < aVascZone) & thisMask;
    TPimage = aVascVotos & aVascZone & thisMask;
    FNpixelsVotos(1,it) = sum(FNimage(:)); 
    FPpixelsVotos(1,it) = sum(FPimage(:)); 
    
    compImageVotos = imoverlay(imoverlay(imoverlay(imoverlay(thisImage,...
                       uint8(FPimage)*255, 'm'),...
                       uint8(FNimage)*255, 'y'),...
                       uint8(TPimage)*255, 'g'),...
                       vesselSkelMask,'r');
    
    % Todos               
    FNimage = (aVascTodos > aVascZone) & thisMask; 
    FPimage = (aVascTodos < aVascZone) & thisMask;
    TPimage = aVascTodos & aVascZone & thisMask;
    FNpixelsTodos(1,it) = sum(FNimage(:)); 
    FPpixelsTodos(1,it) = sum(FPimage(:));  
    
    compImageTodos = imoverlay(imoverlay(imoverlay(imoverlay(thisImage,...
                       uint8(FPimage)*255, 'm'),...
                       uint8(FNimage)*255, 'y'),...
                       uint8(TPimage)*255, 'g'),...
                       vesselSkelMask,'r');
    
    totalPix(1,it)   = sum(aVascZone(:) & thisMask(:));
    retinaPix(it)  = sum(thisMask(:));
    VotosPix(it)   = sum(aVascVotos(:) & thisMask(:));
    TodosPix(it)   = sum(aVascTodos(:) & thisMask(:));
    
    imwrite(compImageVotos,fullfile(masterFolder, 'GlobalVascular',['votos_' fname '.png']))
    imwrite(compImageTodos,fullfile(masterFolder, 'GlobalVascular',['todos_' fname '.png']))
    
    % Compute users
    for us = 1:size(aVascAllMasks,3)
        userMask = aVascAllMasks(:,:,us);
        
        totalPix(1+us,it)   = sum(userMask(:) & thisMask(:));
        
        FNimage = (aVascVotos > userMask) & thisMask; 
        FPimage = (aVascVotos < userMask) & thisMask;
        FNpixelsVotos(1+us,it) = sum(FNimage(:)); 
        FPpixelsVotos(1+us,it) = sum(FPimage(:));
        
        FNimage = (aVascTodos > userMask) & thisMask; 
        FPimage = (aVascTodos < userMask) & thisMask;
        FNpixelsTodos(1+us,it) = sum(FNimage(:)); 
        FPpixelsTodos(1+us,it) = sum(FPimage(:));        
        
    end
    
    FNpixelsTodosRel(:,it) = FNpixelsTodos(:,it) / retinaPix(it); 
    FPpixelsTodosRel(:,it) = FPpixelsTodos(:,it) / retinaPix(it); 
    
    FNpixelsVotosRel(:,it) = FNpixelsVotos(:,it) / retinaPix(it); 
    FPpixelsVotosRel(:,it) = FPpixelsVotos(:,it) / retinaPix(it); 
    
end

save(fullfile(masterFolder, 'GlobalVascular', 'results.mat'), 'totalPix',...
     'retinaPix', 'VotosPix', 'TodosPix','FNpixelsVotos','FPpixelsVotos',...
     'FNpixelsTodos','FPpixelsTodos','FNpixelsTodosRel','FPpixelsTodosRel',...
     'FNpixelsVotosRel','FPpixelsVotosRel');

%% Votos 
figure; yLab='FNpixelsVotos'; makeNiceFigure(FNpixelsVotos,yLab)
print(gcf,'-dpng',fullfile(masterFolder,'GlobalVascular',[yLab '.png']));

figure; yLab='FPpixelsVotos'; makeNiceFigure(FPpixelsVotos,yLab)
print(gcf,'-dpng',fullfile(masterFolder,'GlobalVascular',[yLab '.png']));

figure; yLab='FNpixelsVotosRel'; makeNiceFigure(FNpixelsVotosRel,yLab)
print(gcf,'-dpng',fullfile(masterFolder,'GlobalVascular',[yLab '.png']));

figure; yLab='FPpixelsVotosRel'; makeNiceFigure(FPpixelsVotosRel,yLab)
print(gcf,'-dpng',fullfile(masterFolder,'GlobalVascular',[yLab '.png']));

%% Todos

figure; yLab='FNpixelsTodos'; makeNiceFigure(FNpixelsTodos,yLab)
print(gcf,'-dpng',fullfile(masterFolder,'GlobalVascular',[yLab '.png']));

figure; yLab='FPpixelsTodos'; makeNiceFigure(FPpixelsTodos,yLab)
print(gcf,'-dpng',fullfile(masterFolder,'GlobalVascular',[yLab '.png']));

figure; yLab='FNpixelsTodosRel'; makeNiceFigure(FNpixelsTodosRel,yLab)
print(gcf,'-dpng',fullfile(masterFolder,'GlobalVascular',[yLab '.png']));

figure; yLab='FPpixelsTodosRel'; makeNiceFigure(FPpixelsTodosRel,yLab)
print(gcf,'-dpng',fullfile(masterFolder,'GlobalVascular',[yLab '.png']));

%% Area
figure; yLab='Area'; makeNiceFigure(totalPix,yLab)
print(gcf,'-dpng',fullfile(masterFolder,'GlobalVascular',[yLab '.png']));

end
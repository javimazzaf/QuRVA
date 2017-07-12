% function compareAvascularResults
clear

readConfig

%Ensures everything is commited before starting test.
[versionInfo.branch, versionInfo.sha] = getGitInfo;

if ~exist(fullfile(masterFolder, 'GlobalVascular', 'results.mat'),'file')
    
    mkdir(masterFolder, 'GlobalVascular')
    
    %% Get file names
    myFiles = dir(fullfile(masterFolder, 'VasculatureNumbers','*.mat'));
    myFiles = {myFiles(:).name};
    
    for it = 1:14
        it
        fname = myFiles{it};
        fname = fname(1:end-4);
        
        thisImage = imread(fullfile(masterFolder, fname));
        
        load(fullfile(masterFolder, 'Masks',    myFiles{it}), 'thisMask');
        load(fullfile(masterFolder, 'ONCenter', myFiles{it}), 'thisONCenter');
        [maskStats, maskNoCenter] = processMask(thisMask, thisImage, thisONCenter);
        
        [aVascAllMasks, aVascVotos] = getAVascularConsensusMask(it);
        
        aVascVotos=aVascVotos.*maskNoCenter;
        
        %aVascTodos = logical(sum(aVascAllMasks,3));
        
        load(fullfile(masterFolder, 'VasculatureNumbers', myFiles{it}),...
            'vesselSkelMask', 'aVascZone');
        aVascZone=aVascZone.*maskNoCenter;
        
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
        
        
        totalPix(1,it)   = sum(aVascZone(:) & thisMask(:))/sum(thisMask(:));
        retinaPix(it)  = sum(thisMask(:));
        VotosPix(it)   = sum(aVascVotos(:) & thisMask(:));
        %     TodosPix(it)   = sum(aVascTodos(:) & thisMask(:));
        
        %     imwrite(compImageVotos,fullfile(masterFolder, 'GlobalVascular',['votos_' fname '.png']))
        %     imwrite(compImageTodos,fullfile(masterFolder, 'GlobalVascular',['todos_' fname '.png']))
        
        % Compute users
        for us = 1:size(aVascAllMasks,3)
            userMask = aVascAllMasks(:,:,us);
            userMask = userMask .* maskNoCenter;
            
            totalPix(1+us,it)   = sum(userMask(:) & thisMask(:))/sum(thisMask(:));
            
            FNimage = (aVascVotos > userMask) & thisMask;
            FPimage = (aVascVotos < userMask) & thisMask;
            FNpixelsVotos(1+us,it) = sum(FNimage(:));
            FPpixelsVotos(1+us,it) = sum(FPimage(:));
            
            %         FNimage = (aVascTodos > userMask) & thisMask;
            %         FPimage = (aVascTodos < userMask) & thisMask;
            %         FNpixelsTodos(1+us,it) = sum(FNimage(:));
            %         FPpixelsTodos(1+us,it) = sum(FPimage(:));
            
        end
        
        %     FNpixelsTodosRel(:,it) = FNpixelsTodos(:,it) / retinaPix(it);
        %     FPpixelsTodosRel(:,it) = FPpixelsTodos(:,it) / retinaPix(it);
        %
        FNpixelsVotosRel(:,it) = FNpixelsVotos(:,it) / sum(aVascVotos(:));
        FPpixelsVotosRel(:,it) = FPpixelsVotos(:,it) / sum(aVascVotos(:));
        
    end
    
    save(fullfile(masterFolder, 'GlobalVascular', 'results.mat'), 'totalPix',...
        'retinaPix', 'VotosPix','FNpixelsVotos','FPpixelsVotos',...
        'FNpixelsVotosRel','FPpixelsVotosRel');
    
end

load(fullfile(masterFolder, 'GlobalVascular', 'results.mat'), 'totalPix',...
    'retinaPix', 'VotosPix','FNpixelsVotos','FPpixelsVotos',...
    'FNpixelsVotosRel','FPpixelsVotosRel');

% Errors
allErrorRel = (FNpixelsVotosRel + FPpixelsVotosRel) * 100;

fg=figure;
makeUserDistributionFigure(allErrorRel,'Error pixels [%]',true)
makeFigureTight(fg)
imRGB = print('-RGBImage');
imwrite(imRGB,fullfile(masterFolder,'GlobalVascular','ErrorPixels.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

% Area
fg=figure;
makeUserDistributionFigure(totalPix*100,'Avascular area [%]',true)
makeFigureTight(fg)
imRGB = print('-RGBImage');
imwrite(imRGB,fullfile(masterFolder,'GlobalVascular','AvascularArea.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])



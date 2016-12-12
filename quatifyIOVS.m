clear 
masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/Bruno/Images/IOVS/';

pWeeks=2:7;

mutants={'WT' 'Lyz' 'NrpLyz'};
for itMutant=1:3
    for it=1:numel(pWeeks)

        %% Get file names
        myFiles=dir([masterFolder mutants{itMutant} filesep 'P' num2str(pWeeks(it)) filesep '*.jpg']);

        if numel(myFiles)==0
            myFiles=dir([masterFolder mutants{itMutant} filesep 'P' num2str(pWeeks(it)) filesep '*.tif']);
        end

        for itFile=1:numel(myFiles)
            load([masterFolder mutants{itMutant} filesep 'P' num2str(pWeeks(it)) filesep 'VasculatureNumbers' filesep myFiles(itFile).name '.mat'])
            load([masterFolder mutants{itMutant} filesep 'P' num2str(pWeeks(it)) filesep 'Masks' filesep myFiles(itFile).name '.mat'])
            skelLength=sum(sum(vesselSkelMask));
            skelRatio{it, itMutant, itFile}=double(skelLength)/double(sum(sum(thisMask)));
        end

        pSkelMean(it, itMutant)=mean(cell2mat(skelRatio(it, itMutant, :)));
        pSkelSTD(it, itMutant)=std(cell2mat(skelRatio(it, itMutant, :)));

    end
end

%% Make figure
figure1 = figure;
axes1 = axes('Parent',figure1);
bar1 = bar([2:7],pSkelMean,'Parent',axes1);
set(bar1(3),...
    'FaceColor',[0.929411768913269 0.694117665290833 0.125490203499794]);
set(bar1(1),'DisplayName','WT');
set(bar1(2),'DisplayName','Lyz');
set(bar1(3),'DisplayName','NrpLyz');
set(axes1,'XTick',[2 3 4 5 6 7]);
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.163879598662207 0.783653827939326 0.107023411371237 0.0913461538461539]);



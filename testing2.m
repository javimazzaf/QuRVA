% function testing

betterFN = zeros(size(auto.FN(1,:)));
worseFN  = zeros(size(auto.FN(1,:)));
betterFP = zeros(size(auto.FP(1,:)));
worseFP  = zeros(size(auto.FP(1,:)));

for e = 1:6
    
    figure(1);
    subplot(6,1,e)
    plot(auto.FN(e,:),'o-r'), hold on
    plot(evaluator.FN(e,:),'s-b')
    sFNauto = sum(auto.FN(e,:));
    sFNeval = sum(evaluator.FN(e,:));
    dif = (sFNauto - sFNeval) / sFNeval * 100;
    legend({['auto: ' num2str(sFNauto) ' (' num2str(dif,'%3.0f') '%)'];['manual: ' num2str(sFNeval)]},'Location','NorthWest')
    
    betterFN = betterFN + (auto.FN(e,:) < evaluator.FN(e,:));
    worseFN  = worseFN +  (auto.FN(e,:) > evaluator.FN(e,:));
    
    figure(2);
    subplot(6,1,e)
    plot(auto.FP(e,:),'o-r'), hold on
    plot(evaluator.FP(e,:),'s-b')
    sFPauto = sum(auto.FP(e,:));
    sFPeval = sum(evaluator.FP(e,:));
    dif = (sFPauto - sFPeval) / sFPeval * 100;
    legend({['auto: ' num2str(sFPauto) ' (' num2str(dif,'%3.0f') '%)'];['manual: ' num2str(sFPeval)]},'Location','NorthWest')
    
    betterFP = betterFP + (auto.FP(e,:) < evaluator.FP(e,:));
    worseFP  = worseFP  + (auto.FP(e,:) > evaluator.FP(e,:));
    
end

betterFNprc = sum(betterFN) / (sum(betterFN) + sum(worseFN)) * 100;
worseFNprc  = sum(worseFN) / (sum(betterFN) + sum(worseFN)) * 100;

betterFPprc = sum(betterFP) / (sum(betterFP) + sum(worseFP)) * 100;
worseFPprc  = sum(worseFP) / (sum(betterFP) + sum(worseFP)) * 100;

figure(3)
b = bar([betterFNprc, worseFNprc;betterFPprc, worseFPprc]);
b(1).FaceColor = 'g';
b(2).FaceColor = 'r';
set(gca,'XTickLabels',{'FN';'FP'})


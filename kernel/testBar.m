function testBar

h = waitbar(0,'Testing bar',...
    'CreateCancelBtn',...
    'setappdata(gcbf,''stop'',0)');

cleanObj = onCleanup(@()delete(h));

for k = 1:1000
    
    pause(1)
    disp(1)
    
    waitbar(k/1000,h,sprintf('%1.0f',k))
    
    if getappdata(h,'stop') == 0
        disp('stopped by user.')
        break
    end
    
end

end

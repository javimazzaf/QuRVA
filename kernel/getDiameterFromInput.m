function maxRadius = getDiameterFromInput

try
    name='[20...100]';
    prompt = {'Diameter [%]'};
    defaultans = {'90'};
    
    maxRadius = NaN;
    while isnan(maxRadius)
        answer = inputdlg(prompt,name,[1 20],defaultans);
        answer = answer{1};
        maxRadius = str2double(answer);
    end
    
    if maxRadius < 10 || maxRadius > 100
        maxRadius = 90;
    end
    
    maxRadius = maxRadius / 100;
    
catch
    maxRadius = 0.9;
end

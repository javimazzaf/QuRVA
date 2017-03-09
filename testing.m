function testing

cleanupObj = onCleanup(@finalClean);

for k = 1:100000
    disp(num2str(k))
end

function finalClean
        disp(['termina en ' num2str(k)])
end

end







function [outEmailAddress, outFileName]=parseImageName(inFileName)

    atPositions=strfind(inFileName, '@');
    outEmailAddress=inFileName(1:atPositions(2)-1);
    outFileName=inFileName(atPositions(3)+1:end);
end
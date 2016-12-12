% addNumbersImage
% Santiago Costantino
% www.biophotonics.ca

function imageWithNumber = addNumbersImage(imagen, number, numberSize, position, clr)

%% adds to an image a legend with a number embedded into it
%% Example
%% addNumbersImage(imagen, 146, [25, 75], [20, 10]) will embed the number 146
%% into the image with a size of [25 75] with top right corner [20, 10]

%%Check the numbers image fits in the image, if not, shifts it until it does

warning('off')

imchar = makeCharaterImage(number, numberSize);
lbSz = size(imchar);

position(2) = max(position(2) - floor(lbSz(2) / 2),0);

if position(1) + lbSz(1) - 1 > size(imagen, 1)
    position(1) = size(imagen, 1) - lbSz(1);
end

if position(2) + lbSz(2) - 1 > size(imagen, 2)
    position(2) = size(imagen, 2) - lbSz(2);
end

%image index where to draw the number
[y,x] = find(imchar > 0.5);
try 
ix    = sub2ind([size(imagen,1), size(imagen,2)],position(1) + y - 1,position(2) + x - 1);
catch exemption
    disp('error')
end
%% Adds the number
if size(imagen, 3)<3
            
    imagen(ix)      = 255;
    imageWithNumber = imagen;
    
else
                  
    for itColor=1:3
        thisColor = imagen(:,:,itColor);

        thisColor(ix) = clr(itColor);
        
        imageWithNumber(:,:,itColor) = thisColor;
    end
end


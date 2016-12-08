% Santiago Costantino
% Hopital Maisonneuve-Rosemont, Centre de Recherche
% www.biophotonics.ca

function imagen=makeCharaterImage(numero, imageSize)

% Outputs a binary image with the elements of a vector considered as a
% number
% Expample
% makeCharaterImage([2 4 7]) returns a binary matrix representing the
% number 247

cero=[0 1 1 0; 1 0 0 1; 1 0 0 1; 1 0 0 1; 1 0 0 1;1 0 0 1; 0 1 1 0];

uno=[0 1 0; 1 1 0; 0 1 0;0 1 0; 0 1 0; 0 1 0; 1 1 1];

dos=[0 1 1 0; 1 0 0 1; 0 0 0 1; 0 0 1 0;0 1 0 0;1 0 0 1; 1 1 1 1];

tres=[0 1 1 0; 1 0 0 1; 0 0 0 1; 0 1 1 1; 0 0 0 1; 1 0 0 1; 0 1 1 0];

cuatro=[1 0 0 1;1 0 0 1;1 0 0 1;1 1 1 1; 0 0 0 1;0 0 0 1;0 0 0 1];

cinco=[1 1 1 1;1 0 0 0;1 0 0 0; 0 1 1 0;0 0 0 1;1 0 0 1;0 1 1 0];

seis=[0 1 1 1;1 0 0 0;1 0 0 0;1 1 1 1;1 0 0 1;1 0 0 1;1 1 1 1];

siete=[1 1 1 1;0 0 0 1;0 0 0 1;0 0 1 0;0 0 1 0;0 1 0 0;0 1 0 0];

ocho=[0 1 1 0;1 0 0 1;1 0 0 1;0 1 1 0;1 0 0 1;1 0 0 1;0 1 1 0];

nueve=[1 1 1 1;1 0 0 1;1 0 0 1;1 1 1 1;0 0 0 1;0 0 0 1;1 1 1 1];

espacio=[0 0; 0 0;0 0; 0 0; 0 0; 0 0; 0 0];

if numero == 0
    cifras = 1;
else
    cifras=floor(log10(numero))+1;
end

for it=1:cifras
    vector(it)=floor(numero/10^(cifras-it));
    numero=numero-vector(it)*10^(cifras-it);
end

imagen=espacio;
for itCifra=1:size(vector, 2)
    switch vector(itCifra)
        case 1
            imagen=[imagen uno espacio];
        case 2
            imagen=[imagen dos espacio];
        case 3
            imagen=[imagen tres espacio];
        case 4
            imagen=[imagen cuatro espacio];
        case 5
            imagen=[imagen cinco espacio];
        case 6
            imagen=[imagen seis espacio];
        case 7
            imagen=[imagen siete espacio];
        case 8
            imagen=[imagen ocho espacio];
        case 9
            imagen=[imagen nueve espacio];
        case 0
            imagen=[imagen cero espacio];
    end
end
imagen=imresize(imagen, imageSize);
    
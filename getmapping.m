%GETMAPPING returns a structure containing a mapping table for LBP codes.
%  MAPPING = GETMAPPING(SAMPLES,MAPPINGTYPE) returns a 
%  structure containing a mapping table for
%  LBP codes in a neighbourhood of SAMPLES sampling
%  points. Possible values for MAPPINGTYPE are
%       'u2'   for uniform LBP
%       'ri'   for rotation-invariant LBP
%       'riu2' for uniform rotation-invariant LBP.
%
%  Example:
%       I=imread('rice.tif');
%       MAPPING=getmapping(16,'riu2');
%       LBPHIST=lbp(I,2,16,MAPPING,'hist');
%  Now LBPHIST contains a rotation-invariant uniform LBP
%  histogram in a (16,2) neighbourhood.
%

function mapping = getmapping(samples,mappingtype)
% Version 0.1.1
% Authors: Marko Heikkilä and Timo Ahonen

% Changelog
% 0.1.1 Changed output to be a structure
% Fixed a bug causing out of memory errors when generating rotation 
% invariant mappings with high number of sampling points.
% Lauge Sorensen is acknowledged for spotting this problem.

% Modification Javier Mazzaferri. 
% Updated to work with Matlab 2016b:
% Functions that have changed type of parameters.
% bitset
% bitshift
% bitget

switch samples
    case 8
        intType = 'uint8';
    case 16
        intType = 'uint16';  
    case 32
        intType = 'uint32';
    case 64
        intType = 'uint64';
    otherwise
        error('We may need to change the implementation to consider this number of samples')
end


table = 0:2^samples-1;
newMax  = 0; %number of patterns in the resulting LBP code
index   = 0;

if strcmp(mappingtype,'u2') %Uniform 2
  newMax = samples*(samples-1) + 3; 
  for i = 0:2^samples-1
     %if samples ==8
    j = bitset(bitshift(i,1,'uint64'),1,bitget(i,samples)); %rotate left
     %else
        % error('The number of neighbour is different from 8 (sample!=8) replace uint8 by samples in bitshift 2 lines above')
     %end
    numt = sum(bitget(bitxor(i,j),1:samples)); %number of 1->0 and
                                               %0->1 transitions
                                               %in binary string 
                                               %x is equal to the
                                               %number of 1-bits in
                                               %XOR(x,Rotate left(x)) 
    if numt <= 2
      table(i+1) = index;
      index = index + 1;
    else
      table(i+1) = newMax - 1;
    end
  end
end

if strcmp(mappingtype,'ri') %Rotation invariant
  tmpMap = zeros(2^samples,1) - 1;
  for i = 0:2^samples-1 %JM: loop through table numbers
    rm = i;
    r  = i; %JM: I think this is useless
    for j = 1:samples-1 %JM: loop thorugh possible bit rotations
      r = bitset(bitshift(r,1,intType),1,bitget(r,samples,intType),intType); %rotate left
      if r < rm % Looks for the minimum value among rotations
        rm = r;
      end
    end
    if tmpMap(rm+1) < 0 %JM: If it is the first time for the pattern, adds it
      tmpMap(rm+1) = newMax;
      newMax = newMax + 1;
    end
    table(i+1) = tmpMap(rm+1); %JM: Set the label as for the smallest rotation
  end
end

% if strcmp(mappingtype,'riu2') %Uniform & Rotation invariant
%   % JM comment: all number that have more than 2 bit jumps goes to miscelaneous tag (samples+1)
%   % The rest is labeled as the number of 1 bits.
%   newMax = samples + 2;
%   for i = 0:2^samples - 1
%     j = bitset(bitshift(i,1,intType),1,bitget(i,samples,intType),intType); %rotate left
%     numt = sum(bitget(bitxor(i,j),1:samples));
%     if numt <= 2
%       table(i+1) = sum(bitget(i,1:samples));
%     else
%       table(i+1) = samples+1;
%     end
%   end
% end

%JM More robust and compact computation
if strcmp(mappingtype,'riu2') %Uniform & Rotation invariant
    bitArray = bitand((0:2^samples-1)',2.^(samples-1:-1:0)) > 0;
    rotArray = circshift(bitArray,1,2);
    miscMask = sum(xor(bitArray,rotArray),2) > 2; %Mask for miscelaneous Labels
    table    = sum(bitArray,2);  %Write labels
    table(miscMask) = samples+1; %Write miscelaneous labels
    newMax = samples + 2;
end

mapping.table=table;
mapping.samples=samples;
mapping.num=newMax;

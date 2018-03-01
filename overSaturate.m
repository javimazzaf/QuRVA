function outIm = overSaturate(imIm,percBelow,percAbove)
% Reshapes the image histogram so that percBelow and percAbove pixels are
% saturated, additionally to the already saturated pixels.

% *************************************************************************
% Copyright (C) 2018 Javier Mazzaferri and Santiago Costantino 
% <javier.mazzaferri@gmail.com>
% <santiago.costantino@umontreal.ca>
% Hopital Maisonneuve-Rosemont, 
% Centre de Recherche
% www.biophotonics.ca
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% *************************************************************************

if ~exist('percBelow','var'), percBelow = 0.01; end
if ~exist('percAbove','var'), percAbove = 0.99; end

lowSatLevel  = percBelow + sum(imIm(:) == min(imIm(:))) / numel(imIm);
highSatLevel = percAbove - sum(imIm(:) == max(imIm(:))) / numel(imIm);

outIm = imadjust(mat2gray(imIm),stretchlim(imIm,[lowSatLevel highSatLevel]));

end
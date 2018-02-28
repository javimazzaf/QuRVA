function [maskProps, maskNoCenter, thisONCenter] = processMask(myMask, thisONCenter)
% Trims the edges and center of the retinal region.

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

readConfig

maskProps = regionprops(myMask, 'EquivDiameter');
[~,ix]    = max([maskProps(:).EquivDiameter]);
maskProps = maskProps(ix);

rMin = maskProps.EquivDiameter/2 * tufts.circMask.min;
rMax = maskProps.EquivDiameter/2 * tufts.circMask.max;

newCenterCircleMask = createCircularMask(size(myMask, 1), size(myMask, 2),...
                      thisONCenter(1), thisONCenter(2), rMin);

maskNoEdge          = createCircularMask(size(myMask, 1), size(myMask, 2),...
                      thisONCenter(1), thisONCenter(2), rMax);

maskNoCenter = maskNoEdge .* ~newCenterCircleMask;

end
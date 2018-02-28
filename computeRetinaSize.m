function meanRadius = computeRetinaSize(mask, center)
% Estimates the radius of the retina

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

    [r,c] = find(bwperim(mask)>0.5);

    ind = convhull(c,r);
    
    c = c(ind);
    r = r(ind);

    d = sqrt((r - center(2)).^2 + (c - center(1)).^2); 

    meanRadius = mean(d) * 2;

end

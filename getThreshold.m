function thresh = getThreshold(inIm)

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

[N,edges] = histcounts(inIm,(0:255)/255);

N = N / max(N);

otsuThresh = graythresh(inIm(:));

[pks,locs] = findpeaks(N); 

[~,ix] = sort(pks,'descend');

ixMx1 = min(locs(ix([1,2])));
ixMx2 = max(locs(ix([1,2])));

absmin = prctile(N(ixMx1:ixMx2),2);
[~,ix]=min(N(ixMx1:ixMx2)-absmin);

absmin=N(ixMx1+ix-1);

ix = find(N <= absmin & edges(1:end-1) > edges(ixMx1)& edges(1:end-1) < edges(ixMx2), 1, 'first');

thresh = edges(ix);

if isempty(thresh)
  thresh = otsuThresh;
end

end
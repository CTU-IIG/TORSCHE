function color=colorfromcolormap(n)
%COLORFROMCOLORMAP   Compute n colors from color map
%
% Syntax
%    color=colorfromcolormap(n)
%       n     - number of colors
%       color - n x 3 matrix with colors from the colormap
%
% See also: colormap, colorcube


% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2895 $  $Date:: 2009-03-18 11:24:58 +0100 #$


% This file is part of TORSCHE Scheduling Toolbox for Matlab.
% TORSCHE Scheduling Toolbox for Matlab can be used, copied 
% and modified under the next licenses
%
% - GPL - GNU General Public License
%
% - and other licenses added by project originators or responsible
%
% Code can be modified and re-distributed under any combination
% of the above listed licenses. If a contributor does not agree
% with some of the licenses, he/she can delete appropriate line.
% If you delete all lines, you are not allowed to distribute 
% source code and/or binaries utilizing code.
%
% --------------------------------------------------------------
%                  GNU General Public License  
%
% TORSCHE Scheduling Toolbox for Matlab is free software;
% you can redistribute it and/or modify it under the terms of the
% GNU General Public License as published by the Free Software
% Foundation; either version 2 of the License, or (at your option)
% any later version.
% 
% TORSCHE Scheduling Toolbox for Matlab is distributed in the hope
% that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with TORSCHE Scheduling Toolbox for Matlab; if not, write
% to the Free Software Foundation, Inc., 59 Temple Place,
% Suite 330, Boston, MA 02111-1307 USA


currentFigureHandler = get(0,'CurrentFigure');
mapColor = colormap;
if isempty(currentFigureHandler)
    close; %Close figure opened by colormap command
end

colorPointsLength = size(mapColor,1)/(n+1);
colorPoints = colorPointsLength:colorPointsLength:size(mapColor,1);
colorPoints = colorPoints(1:max(length(colorPoints)-1,1));

colorPre = mapColor(max(floor(colorPoints),1),:);
colorPost = mapColor(ceil(colorPoints),:);


color = mapColor(max(floor(colorPoints),1),:) + (colorPost-colorPre).*[(colorPoints-floor(colorPoints))' (colorPoints-floor(colorPoints))' (colorPoints-floor(colorPoints))'];

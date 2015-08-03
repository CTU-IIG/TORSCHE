function out = color2rgb (color)
%ISCOLOR converts color name to the RGB equivalent.
%    ISCOLOR(C) returns RGB triple equivalent to predefined color name C
%    in long format {'yellow','magenta','cyan','red','green','blue',
%    'white','black'} or short format {'y','m','c','r','g','b','w','k'}.
%  
%     See also ISCOLOR

% Author: Premysl Sucha <suchap@fel.cvut.cz>
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

 
colorLongName={'yellow','magenta','cyan','red','green','blue','white','black'};
colorShortName={'y','m','c','r','g','b','w','k'};
colorRGB={[1 1 0],[1 0 1],[0 1 1],[1 0 0],[0 1 0],[0 0 1],[1 1 1],[0 0 0]};

switch(iscolor(color))
    case 1
        out = color;
    case 2
        [tf loc]=ismember(color,colorLongName);
        out = colorRGB{loc};
    case 3
        [tf loc]=ismember(color,colorShortName);
        out = colorRGB{loc};
    otherwise
        error('Input parameter ''color'' is not valid color.');
end;

%end .. color2rgb

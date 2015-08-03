function [TS] = colour(TS,varargin)
%COLOUR returns taskset where tasks have set the color property
%
%Synopsis
% T = COLOUR(T[,colors])
%
%Description
% Properties:
%  T:
%    - taskset
%  colors:
%    - colors specification
%
% Colors specification: 
%   - RGB color matrix with 3 columns
%   - char with color name
%   - cell with combination RGB and names
%   - keyword 'gray' to use gray palete for coloring
%   - keyword 'colorcube' to use colorcube for coloring
%   - nothing - color palete use for coloring
%
% For more information about colors in Matlab, see the documentation:
%
%  >>doc ColorSpec
%
%
% See also ISCOLOR, SCHEDOBJ/SET_GRAPHIC_PARAM, SCHEDOBJ/GET_GRAPHIC_PARAM,
%          COLORCUBE 


% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2897 $  $Date:: 2009-03-18 15:17:31 +0100 #$


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


ni = nargin;
if ni>1
    colors_in = varargin{1};
    if iscell(colors_in)
        for i=1:length(colors_in) 
            if ~iscolor(colors_in{i}) 
                error('No valid color!');
            end
        end
        colors = {};
        for i=1:ceil(count(TS)/length(colors_in))
            colors = [colors colors_in];
        end
    elseif isnumeric(colors_in)
        if size(colors_in,2) == 3
            for i = 1:size(colors_in,1)
                if ~iscolor(colors_in(i,:)) 
                    error('No valid color!');
                end
            end
            colors = [];
            for i = 1:ceil(count(TS)/size(colors_in,1))
                colors = [colors;colors_in];
            end
        else
            error('No valid color format!');
        end
    elseif ischar(colors_in);
        if iscolor(colors_in)
            colors = {};
            for i = 1:count(TS)
                colors{i} = colors_in;
            end
        elseif strcmpi(colors_in, 'gray')
            colors = gray(count(TS));
        elseif strcmpi(colors_in, 'colorcube')
            colors = colorcube(count(TS)+8);
        end
    end
else        
    %colors = colorcube(count(TS)+8);
    colors = colorfromcolormap(count(TS));
end

for i = 1:count(TS)
    task_tmp = TS.tasks{i};
    if iscell(colors)
        set_graphic_param(task_tmp,'color',colors{i});
    else
        set_graphic_param(task_tmp,'color',colors(i,:));
    end
    TS.tasks{i} = task_tmp;
end

%end .. @taskset/colour

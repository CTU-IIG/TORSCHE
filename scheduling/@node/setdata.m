function nOut = setdata(nIn,property,value)
%SETDATA helpful function for method set. 
%
%    graph = SETDATA(node, property, varargin)
%      node     - object node
%      property  - keyword:
%                       'Color' color of node for graph coloring
%
%  See also SET, GET, NODE.

% Author: Vojtech Navratil <navrav1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2896 $  $Date:: 2009-03-18 12:20:12 +0100 #$


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


if ~isa(nIn,'node')
    error('1st parameter must be node.');
end
if ~isa(property,'char')
    error('Property has to be char.');
end

try
    switch lower(property)
        
        case {'color', 'clr'}
            if iscolor(value),
                nOut = setnodecolor(nIn, value);
            else
                error('RGB vector is required as value.');
            end
                        
        otherwise
            error('Property %s isn''t available!', property);
            return;
    end
catch
    rethrow(lasterror);
end

%==============================================================================        

function nOut = setnodecolor(nOut,color)
    try
        if iscell(nOut.GraphicParam)
            structure = nOut.GraphicParam{1};
        else
            structure = nOut.GraphicParam;
            nOut.GraphicParam = [];
        end
        if isfield(structure,'facecolor')
            structure.facecolor = color;
            nOut.GraphicParam{1} = structure;
        else
            newRectangle.x = -2;
            newRectangle.y = -2;
            newRectangle.width = 10;
            newRectangle.height = 10;            
            newRectangle.curvature = 0;
            newRectangle.facecolor = color;
            newRectangle.edgecolor = [0 0 0];
            newRectangle.linestyle = '-';
            newRectangle.linewidth = 1;
            nOut.GraphicParam{end+1} = newRectangle;
        end
    catch
        rethrow(lasterror);
        return;
    end


function [listNames,listHandles] = grapheditgetnamesofnodesoredges(param)
%GRAPHEDITGETNAMESOFNODESOREDGES returns list of names and handles of all created nodes or edges. 
%   This file is part of Scheduling Toolbox.
%
%   listNames - list of names - type cell
%   listHandles - list of handles - numeric array
%


% Author: Vojtech Navratil <navrav1@fel.cvut.cz>
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


    saveStructure = get(gca,'UserData');
    listNames = []; listHandles = []; name = [];
    switch (param)
        case ('nodes')
            if ~isempty(saveStructure.node)
                for i = 1:length(saveStructure.node)  
                    rectangleStructure = get(saveStructure.node(i),'UserData');
                    objNode = rectangleStructure.node;
                    if (~isempty(objNode.name) || (strcmp(objNode.name,' ') == 0))
                        name = objNode.name;
                        hObject = saveStructure.node(i);
                    end
                    if isempty(listNames)
                        listNames = {name};
                        listHandles = hObject;
                    else
                        listNames(i) = {name};
                        listHandles(i) = hObject;
                    end
                end
            end
        case ('edges')
            if ~isempty(saveStructure.edge)
                for i = 1:length(saveStructure.edge(:,1))  
                    lineStructure = get(saveStructure.edge(i,1),'UserData');
                    objEdge = lineStructure.edge;
                    if (~isempty(objEdge.name) || (strcmp(objEdge.name,' ') == 0))
                        name = objEdge.name;
                        hObject = saveStructure.edge(i,1);
                    end
                    if isempty(listNames)
                        listNames = {name};
                        listHandles = hObject;
                    else
                        listNames(i) = {name};
                        listHandles(i) = hObject;
                    end
                end     
            end
    end

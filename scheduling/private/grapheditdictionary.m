function property = grapheditdictionary(varargin)
%DICTIONARY for getting properties of selected object graph, node, edge.
%   This file is part of Scheduling Toolbox.
%
%   property - list of properties including their actual values
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

    
    if(nargin == 1 && isnumeric(varargin{1}))
        
        object = get(varargin{1});
        i = 1;
        switch(object.Type)
                
            case('axes')
                saveStructure = get(varargin{1},'UserData');
   %             if ~isempty(saveStructure)
                    objGraph = saveStructure.graph;
                    params = fieldnames(get(objGraph));
                        
                    params{length(params)+1} = 'Color'; params{length(params)+1} = 'X'; params{length(params)+1} = 'Y';
                    
                    i = 1;
                    wasColor = 0;
                    while ~isempty(params)
                        if (strcmp('Name',params{1}) || strcmp('Notes',params{1}))
                            if (i == 1)
                                property = getProperty('Text',params(1),get(objGraph,params{1}));
                            else
                                property(i) = getProperty('Text',params(1),get(objGraph,params{1}));
                            end   
                            i=i+1;
                        elseif (strcmp('UserParam',params{1}))
                            %assignin('base','X',get(objGraph,params{i}));
                            property(i) = getProperty('OtherLocked',params{1},get(objGraph,params{1}));
                            i=i+1;
                        elseif (strcmp('Color',params{1}) && ~wasColor)
                            value = get_graphic_param(objGraph,params{1});
                            if (length(value) ~= 3) value = [1 1 1]; end
                            property(i) = getProperty('Color',params{1},value);
                            i=i+1; wasColor = 1;
                        elseif (strcmp('X',params{1}) || strcmp('Y',params{1}))
                            property(i) = getProperty('CoordinatesLocked',params{1},get_graphic_param(objGraph,params{1}));
                            i=i+1;               
                        elseif (strcmp('N',params{1}) || strcmp('E',params{1}))
                            %get_graphic_param(saveStructure.graph,params{i})
                            property(i) = getProperty('OtherLocked',params{1},get(objGraph,params{1}));
                            i=i+1;
                        elseif (strcmp('Position',params{1}))
                            %get_graphic_param(saveStructure.graph,params{i})
                            property(i) = getProperty('OtherLocked',params{1},get(objGraph,params{1}));
                            i=i+1;
                        elseif (strcmp('GridFreq',params{1}))
                            %get_graphic_param(saveStructure.graph,params{i})
                            property(i) = getProperty('OtherLocked',params{1},get(objGraph,params{1}));
                            i=i+1;
                        else
                        end
                        params(1) = [];
                    end
                    %assignin('base','p',property);
                    %               end


            case('line')
                edgeStructure = get(varargin{1},'UserData');
  %              if ~isempty(edgeStructure)
                    objEdge = edgeStructure.edge;
                    params = fieldnames(get(objEdge));
                    
                    params{length(params)+1} = 'Color'; params{length(params)+1} = 'X'; params{length(params)+1} = 'Y';
                
                    i = 1; wasColor = 0;
                    while ~isempty(params)
                        if (~isempty(findstr('Name',params{1})) || ~isempty(findstr('Notes',params{1})))
                            if (i == 1)
                                property = getProperty('Text',params(1),get(objEdge,params{1}));
                            else
                                property(i) = getProperty('Text',params(1),get(objEdge,params{1}));
                            end    
                            i=i+1;
                        elseif (~isempty(findstr('User',params{1})))
                            property(i) = getProperty('Text',params{1},get(objEdge,params{1}));
                            i=i+1;
                        elseif (~isempty(findstr('Color',params{1})) && ~wasColor)
                            value = get_graphic_param(objEdge,params{1});
                            if (length(value) ~= 3) value = [0 0 0]; end
                            property(i) = getProperty('Color',params{1},value);
                            i=i+1; wasColor = 1;
                        elseif (~isempty(findstr('X',params{1})) || ~isempty(findstr('Y',params{1})))
                            property(i) = getProperty('CoordinatesLocked',params{1},get_graphic_param(objEdge,params{1}));
                            i=i+1;                  
                        else
%                             get_graphic_param(edge,params{i})
%                             property(i) = getProperty('OtherLocked',params{i},get_graphic_param(objEdge,params{i})); i=i+1;
                        
                        end
                        params(1) = [];
                    end
                    %                end
                
                
            case('rectangle')
                nodeStructure = get(varargin{1},'UserData');
%                if ~isempty(nodeStructure)
                   objNode = nodeStructure.node;
                    params = fieldnames(get(objNode));
                    
                    params{length(params)+1} = 'Color'; params{length(params)+1} = 'X'; params{length(params)+1} = 'Y';
                
                    i = 1; wasColor = 0;
                    while ~isempty(params)
                        if (~isempty(findstr('Name',params{1})) || ~isempty(findstr('Notes',params{1})))
                            if (i == 1)
                                property = getProperty('Text',params(1),get(objNode,params{1})); 
                                i=i+1;
                            else
                                property(i) = getProperty('Text',params(1),get(objNode,params{1})); 
                                i=i+1;
                            end                      
                        elseif (~isempty(findstr('User',params{1})))
                            property(i) = getProperty('Text',params{1},get(objNode,params{1})); 
                            i=i+1;
                            
                        elseif (~isempty(findstr('Color',params{1})) && ~wasColor)
                            value = get_graphic_param(objNode,params{1});
                            if (length(value) ~= 3) value = [1 1 1]; end
                            property(i) = getProperty('Color',params{1},value); 
                            i=i+1; wasColor = 1;
                            
                        elseif (~isempty(findstr('X',params{1})) || ~isempty(findstr('Y',params{1})))
                            property(i) = getProperty('Coordinates',params{1},get_graphic_param(objNode,params{1})); 
                            i=i+1;
                                                    
                        else
%                             get_graphic_param(node,params{i})
%                             property(i) = getProperty('OtherLocked',params{i},get_graphic_param(objNode,params{i})); i=i+1;
                            
                        end
                        params(1) = [];
                    end
                    %               end 
                
        end
        
        return;
    
    end
    
    return;
    
    
    
    
function property = getProperty(type,name,value)
    property = struct('type',{type},'name',{name},'value',{value},'options',{'whatever'});
    return;
    
    

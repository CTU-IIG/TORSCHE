function gOut = setdata(gIn,property,value)
%SETDATA helpful function for method set. 
%
%    graph = SETDATA(graph, property, varargin)
%      graph     - object graph
%      property  - keyword:
%                       'edl' (list of edges)
%                       'ndl' (list of nodes)
%                       'nodeuserparamdatatype'
%                       'edgeuserparamdatatype
%                       'inc' - incidency matrix
%                       'adj' - adjacency matrix
%                       'p2e' - matrix or cell of user prameters of edges
%                       'p2n' - matrix or cell of user prameters of nodes
%
%  See also SET, GET, GRAPH, PARAM2EDGE, PARAM2NODE.


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


if ~isa(gIn,'graph')
    error('1st parameter must be graph.');
end
if ~isa(property,'char')
    error('Property must be char.');
end

try
    switch lower(property)
        
        case {'edl', 'edgelist'}
            gOut = createedges(gIn, value);
            
        case {'ndl', 'nodelist'}
            gOut = createnodes(gIn, value);
            
        case {'edgeuserparamdatatype','edgesdatatype','edgedatatype','edt'}
            gOut = gIn;
            gOut.DataTypes.edges = value;
            gOut.E = changeofuserparam(gIn.E, value);
            
        case {'nodeuserparamdatatype','nodesdatatype','nodedatatype','ndt'}
            gOut = gIn;
            gOut.DataTypes.nodes = value;
            gOut.N = changeofuserparam(gIn.N, value);
            
        case {'inc', 'incidency'}
            gOut = setincidencymatrix(gIn, value);
            
        case {'adj', 'adjacency'}
            gOut = setadjacencymatrix(gIn, value);
            
            %     case {'p2e', 'param2edge', 'param2edges'}
            %         gOut = param2edge(gIn,value,varargin(:));
            %         
            %     case {'p2n', 'param2node', 'param2nodes'}
            %         gOut = param2node(gIn,value,arargin(:));
            
        otherwise
            error('Property %s isn''t available!', property);
            return;
    end
catch
    rethrow(lasterror);
end

%==============================================================================        

function gOut = createnodes(gOut,nodeList)
    try        
        dataTypes = gOut.DataTypes.nodes;
        if ~isempty(dataTypes)
            [isOK,nodeList,dataTypes] = testofdatatypes('node', nodeList, dataTypes);
            if ~isOK
                error('Parameters in list do not match datatypes.');
            end
        end
        [num_nodes, num_paramsNodePlusOne] = size(nodeList);
        max_node = max([nodeList{:,1}]);
        
        values = cell(1,length(dataTypes));
        for i = 2:length(dataTypes)
            values{i} = eval([dataTypes{i} '([])']);
        end
        n = node;
        n.UserParam = values;
        N(1:max_node) = n;
        list = [nodeList{:,1}];
        for i = 1 : num_nodes
            N(list(i)).UserParam = nodeList(i,2:num_paramsNodePlusOne); % setting userparams
        end
        gOut.N = N;
        if max_node < max(gOut.eps(:)) 
            listOfEdge2Delete = find((gOut.eps(:,1) > max_node) | (gOut.eps(:,2) > max_node));
            gOut.E(listOfEdge2Delete) = [];
            gOut.eps(listOfEdge2Delete,:) = [];
        end
    catch
        rethrow(lasterror);
%        error('Execution of changes was interrupted. Invalid format of list of nodes.');
        return;
    end

%==============================================================================        

function gOut = createedges(gOut,edgeList)
    try
        dataTypes = gOut.DataTypes.edges;
        if ~isempty(dataTypes)
            [isOK,edgeList,dataTypes] = testofdatatypes('edge', edgeList, dataTypes);
            if ~isOK
                error('Parameters in list do not match datatypes.');
            end
        end
        [num_edges, num_paramsEdgePlusTwo] = size(edgeList);
        E(1:num_edges) = edge;        % creating edges
        for i = 1:num_edges
            E(i).UserParam = edgeList(i,3:num_paramsEdgePlusTwo);           
            eps(i,:) = [edgeList{i,1:2}];
        end
        delta = max(eps(:)) - length(gOut.N);
        if delta > 0
            gOut.N((end+1):(end+delta)) = node;
        end
        gOut.E = E;
        gOut.eps = eps;
    catch
        rethrow(lasterror);
        %error('Invalid format of list of edges. Execution of changes was interrupted.');
        return;
    end

%==============================================================================        

function [out,list,dataTypes] = testofdatatypes(type, list, dataTypes)
    out = 1;
    if ~isempty(list)
        numDataTypes = length(dataTypes);
        index = 2; 
        if strcmp(type,'edge')
            index = 3;
        end
        [numOfRows,numOfColumns] = size(list);
        if numOfColumns < numDataTypes
            warning('TORSCHE:graph:missingUserParams', 'Some userParams in new list are missing. Missing param was replaced by empty value.')
            numOfColumns = numDataTypes + index - 1;
        end
        for i = 1:numOfRows
            for j = index:numOfColumns
                try
                    if (length(dataTypes) < j-index+1)
                        out = 0;
                        return;
                    elseif isempty(dataTypes{j-index+1})
                        if isempty(list{i,j})
                            list{i,j} = [];
                        end
                    elseif ~isa(list{i,j},dataTypes{j-index+1})
                        out = 0;
                        return;
                    end
                catch
                    value = eval([dataTypes{j-index+1} '([])']);
                    for k = 1:numOfRows
                        list{k,j} = value;
                    end
                end
            end
        end
    end
            
%==============================================================================

function list = changeofuserparam(list,dataTypes)
    if ~isempty(dataTypes)
        displayWarning = 1;
        numDataTypes = length(dataTypes);
        for i = 1:length(list)
            n = list(i);
            userParamOld = n.UserParam;
            if length(userParamOld) >  numDataTypes && displayWarning
                warning('TORSCHE:graph:moreUserParamsThenDataTypes',...
                        sprintf('There are more UserParams then DataTypes. Redundant UserParams will be erased.'));
                displayWarning = 0;
            end
            userParamNew = cell(1,numDataTypes);
            for j = 1:numDataTypes
                if length(userParamOld) < j
                    userParamNew{j} = eval([dataTypes{j} '([])']);
                elseif isempty(dataTypes{j})
                    userParamNew{j} = userParamOld{j};
                elseif ~isa(userParamOld{j},dataTypes{j})
                    switch dataTypes{j}
                        case {'double'}
                            userParamNew{j} = double(userParamOld{j});
                        case 'logical'
                            userParamNew{j} = logical(userParamOld{j});
                        case 'cell'
                            userParamNew{j} = cell(userParamOld{j});
                        case 'struct'
                            userParamNew{j} = struct(userParamOld{j});
                        case 'char'
                            userParamNew{j} = char(userParamOld{j});
                        otherwise
                            userParamNew{j} = eval([dataTypes{j} '([])']);
                    end
                else
                    userParamNew{j} = userParamOld{j};
                end
            end
            set(n,'UserParam',userParamNew);
            list(i) = n;
        end
    end

%==============================================================================

function gOut = setadjacencymatrix(gIn,mat)
    try
        eps = gIn.eps;
        numEdges = size(eps,1);
        listOfEdgesToRemove = [];
        for i = 1:numEdges
            if mat(eps(i,1),eps(i,2)) == 0
                listOfEdgesToRemove(end+1) = i;
            elseif mat(eps(i,1),eps(i,2)) > 1
                error('Setting of adjacency matrix is allowed for simple graph only.')
            else                
                mat(eps(i,1),eps(i,2)) = 0;
            end
        end
        if ~isempty(listOfEdgesToRemove)        
            gOut = removeedge(gIn,listOfEdgesToRemove);
        else
            gOut = gIn;
        end
        if sum(mat(:)) > 0
            warning('TORSCHE:graph:tooMuchEdgesInMatrix',...
                sprintf('There are too many edges in ordered matrix - it is not allowed create new edges by this function.\nRedundant edges were ignored.'));
        end
    catch
        rethrow(lasterror);
    end
        
%==============================================================================

function gOut = setincidencymatrix(gIn,mat)
    try
        eps = gIn.eps;
        numMatrixCols = size(mat,2);
        numEdges = size(eps,1);
        listOfEdgesToRemove = [];
        if numMatrixCols <= numEdges    
            listOfEdgesToSave = [];
            for i = 1:numMatrixCols
                nodeInit = find(mat(:,i) == 1);
                nodeFinal = find(mat(:,i) == -1);
                if length(nodeInit) == 1 && length(nodeFinal) == 1
                    listOfEdgesToSave(end+1) = find((eps(:,1) == nodeInit) & (eps(:,2) == nodeFinal));
                elseif ~isempty(nodeInit) || ~isempty(nodeFinal)
                    listOfEdgesToSave(end+1) = find(((eps(:,1) == nodeInit) & (eps(:,2) == nodeInit)) |...
                        ((eps(:,1) == nodeFinal) & (eps(:,2) == nodeFinal)));
                else
                    error('Invalid input matrix.');
                end
            end
            listOfEdgesToRemove = 1:numEdges;
            listOfEdgesToRemove(listOfEdgesToSave) = [];
        end
        if ~isempty(listOfEdgesToRemove)        
            gOut = removeedge(gIn,listOfEdgesToRemove);
        else
            gOut = gIn;
       end
    catch
        rethrow(lasterror);
    end

%==============================================================================


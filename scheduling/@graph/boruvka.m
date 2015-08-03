function [spanningTree usedEdges] = boruvka(g,varargin)
% BORUVKA is a function for searching spanning tree.
%
%Synopsis
%         SPANNINGTREE = BORUVKA(G,USERPARAMPOSITION)
% [SPANNINGTREE USEDEDGES] = BORUVKA(G,USERPARAMPOSITION)
%Description
% Input is an object of type graph G, which is has to be weighted and
% every weight can be used only once.
% Output of the function is an graph object respresenting
% the spanning Tree of graph G. If a graph G was not weighted,
% you would have to add weightes of edges. It's necessary to enter a number
% of parameter like a second input parameter. In others instances 
% will be taken a first value of edgeDatatype
% parameter of input graph g has to be 'double'.
% Variable USEDEDGES includes order of edges as was added to the spaning tree
% and there is order of usage in the second row.
%
%Example
% adding weightes of edges:
% >> edgeList= {1 2,1;1 3,2;2 3,4;4 3,5;5 6,6;7 8,8;7 9,7;8 9,9};
% >> g = graph('edl',edgeList,'edgeDatatype',{'double'});
% >> spanningtree = boruvka(g)
%
% See also GRAPH/GRAPH, GRAPHEDIT, GRAPH/PRIM, GRAPH/KRUSKAL, SPANNINGTREE_DEMO


% Author: Elvira  Hanakova <hanake1@fel.cvut.cz>
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


% check of the input parameters
if nargin > 1
    if isnumeric(varargin{1})
        userParamPos = varargin{1};
        userParamPos = round(userParamPos(1));
    else
        error ('TORSCHE:graph:wrongparamtype',...
            'Second parameter must be numerical!');
    end
else
    userParamPos = 1;
end


% load of edges
edgeList = get(g,'edl');
if size(edgeList,2) < (userParamPos + 2) ||...
    ~all(cellfun(@length, {edgeList{:,(userParamPos + 2)}}, 'UniformOutput', true)==1)
    error ('TORSCHE:graph:weightsOfGraphAreMissing','Weights of edges are missing!');
end
edgesTemp = get(g,'edl');
dataType = get(g,'edgeDatatype');
if size(dataType,1) == 0 || strcmp(dataType(1),'double') == 0
    if isa(edgesTemp{1, (userParamPos + 2)}, 'double')
        set(g,'edl',edgesTemp,'edgeDatatype',{'double'});
        warning('TORSCHE:graph:weightsOfGraphAreMissing','Edge data type missing, set to "double"');
    else
        error ('TORSCHE:graph:weightsOfGraphAreMissing','Weights of edges are missing!');
    end
end

% load of nodes and parameter VertexFinish, which is represent connected space
E = cell2mat(edgesTemp(:,[1:2 userParamPos + 2]))';
costE = E(3,:);
vertexTemp = get(g,'ndl');
component = cell2mat(vertexTemp(:,1));
addComponent = cell2mat(vertexTemp(:,1));
if min(component)< 1
    error ('TORSCHE:graph:wrongEnteredNodeOfGraph','Node of graph were wrong entered!');
end
% edge index for removing (default all edges will be erase)
eAddIndex = zeros(1,size(costE,2)); 
usedVertex = zeros(1,size(vertexTemp,1));
touchedEdges = zeros(1,length(costE));
for i = 1:length(costE)
    sameWeight = find(costE==costE(i));
    if length(sameWeight) > 1
        error ('TORSCHE:graph:moreSameWeightsOfGraph','Graph g includes more edges with the same weight!');
    end
end
usedComponent = [];
%% ALGORITHM
% Boruvka's algorithm
% Input: A connected undirected graph $G$, weights $c: E(G)\rightarrow \mathbb{R}$
% Output: A spanning tree $T$ of minimum weight
% Ref: http://en.wikipedia.org/wiki/Boruvka's_algorithm 
%% Begin with an empty set of edges $E$ and an empty set of edges $S$
%% 1 Add the cheapest edge from the vertex in the component to another vertex in a disjoint component to $S$ 
j = 1;
someEdgeAdded = 1;
while (min(component) ~= max(component)) && (someEdgeAdded == 1) % First conndition check if all nodes are connected, second if there are any edges, which are possible to add.
    someEdgeAdded = 0;
    for i = 1:length(component)
        usedVertex(find(component==component(i))) = 1;
        numberOfEdges = ...
            ([between(g,find(usedVertex==1),find(usedVertex==0));...
            between(g,find(usedVertex==0),find(usedVertex==1))]);
        usedVertex = zeros(1,size(vertexTemp,1));
        if (length(numberOfEdges)<1) && (i == length(touchedEdges))
            break
        end 
        if length(numberOfEdges)<1
            continue
        end
%% 2 Add the cheapest edge in $S$ to $E$
        someEdgeAdded = 1;
        [tempE edges] = sort(E(3,numberOfEdges));
        newEdge = E(:,(numberOfEdges(edges(1))));
        touchedEdges(numberOfEdges(edges(1))) = 1;
        
        eAddIndex(numberOfEdges(edges(1))) = j;
        addComponent(find(addComponent==addComponent(newEdge(2,1)))) = addComponent(newEdge(1,1));
%%        
    end
    component = addComponent;
    j = j + 1;
    
end
%% END ALGORITHM
usedEdges = find(eAddIndex~=0);
usedEdges = [usedEdges;eAddIndex(usedEdges)];
% modification of g to spanningTree graph
spanningTree = removeedge(g, find(eAddIndex ==0));

function [spanningTree usedEdges]= prim(g,varargin)
% PRIM is a function for searching spanning tree.
%
%Synopsis
%              SPANNINGTREE = PRIM(G,USERPARAMPOSITION)
%  [SPANNINGTREE USEDEDGES] = PRIM(G,USERPARAMPOSITION)
%
%Description
% Input is an object of type graph G, which is has to be weighted.
% Output of the function is an graph object respresenting
% the spanning Tree of graph G. If a graph G was not weighted,
% you would have to add weightes of edges. It's necessary to enter a number
% of parameter like a second input parameter. In others instances
% will be taken a first value of edgeDatatype parameter of input graph g
% has to be 'double'. 
% Variable USEDEDGES includes order of edges as was added to the spaning
% tree and there is order of usage in the second row.
%
%Example
% adding weightes of edges:
% >> edgeList = {1 2 1; 2 3 1; 2 4 2; 3 4 5; 3 1 8; 5 7 2};
% >> g = graph('edl',edgeList,'edgeDatatype',{'double'});
% >> spanningtree = prim(g)
%
% See also GRAPH/GRAPH, GRAPHEDIT, GRAPH/BORUVKA, GRAPH/KRUSKAL


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
    if isnumerical(varargin{1})
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
edgelist = get(g,'edl');
if size(edgelist,2) < (userParamPos + 2) ||...
        ~all(cellfun(@length, {edgelist{:,(userParamPos + 2)}}, 'UniformOutput', true)==1)
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

% load of nodes(vertex)
E = cell2mat(edgesTemp(:,[1:2 userParamPos + 2]))';
costE = E(3,:);
vertexTemp = get(g,'ndl');
% edge index for removing (default all edges will be erase)
eAddIndex = zeros(1,size(costE,2));
usedVertex = zeros(1,size(vertexTemp,1));
%% ALGORITHM
% Prim's algorithm
% Input: A connected undirected graph $G$, weigths $c: E(G)\rightarrow \mathbb{R}$
% Output: A spanning tree $T$ of minimum weight
% Ref: lit-Korte

%% 1. Choose $v \in V(G)$. Set $T:=(\{v\},0)$.
todoVertex = 1;

%% 2. While $V(T) \neq V(G)$ do: ...
% n - Booth while loop are necessary for this while loop condition.
while size(todoVertex,2) > 0
    usedVertex(todoVertex(1))= 1;
    while 1
%%   choose an edge $e \in \delta(V(T))$ ...
        numberOfEdges = ...
            ([between(g,find(usedVertex==1),find(usedVertex==0));...
            between(g,find(usedVertex==0),find(usedVertex==1))]);
%%        
        if isempty(numberOfEdges)
            break;
        end
%% ... of minimum weight. ...
        [tempE edges] = sort(E(3,numberOfEdges)); %TODO: O(n log n) -> O(n)
        newEdge = E(:,(numberOfEdges(edges(1))));
%% ... Set $T:=T+e$.
        eAddIndex(numberOfEdges(edges(1))) = max(eAddIndex)+1;
        usedVertex(newEdge([1 2],1))= 1;
%%
    end
    todoVertex = find(usedVertex == 0);
end
%% END ALGORITHM
eAddedIndex = find(eAddIndex);
[tmp,eAddedOrder] = sort(eAddIndex(eAddedIndex));
usedEdges = eAddedIndex(eAddedOrder);
usedEdges = [usedEdges;1:length(usedEdges)];
% modification of g to spanninTree graph
spanningTree = removeedge(g, find(eAddIndex ==0));

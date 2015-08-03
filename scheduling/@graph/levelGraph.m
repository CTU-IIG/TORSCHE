function [gl usedEdges] = levelGraph(gf,s,t)
% LEVELGRAPH is a function, which modification graph to the level graph.
%
%Synopsis
%         GL = LEVELGRAPH(GF,S,T)
%         [GL ESEDEDGES] = LEVELGRAPH(GF,S,T)
%Description
% The function have a tree inputs, gf - graph, s - source vertex and 
% t - sink vertex.
% Outputs are graph gl and second is usedEdges, matrix of edges,
% which were used in graph gl from graph gf.
%  
%
%Example
% >> edgeList= {1 2,3;1 4,3;3 1,3;2 3,4;3 4,1;3 5,2;5 2,1;4 5,2;5 6,1;4 6,6;6 7,9};
% >> gf = graph('edl',edgeList,'edgeDatatype',{'double'});
% >> gl = levelGraph(gf,s,t)
%
% See also DINIC


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


g = gf;
edgesTemp = get(g,'edl');
dataType = get(g,'edgeDatatype');
if size(dataType,1) == 0 || strcmp(dataType(1),'double') == 0
    if isa(edgesTemp{1,2}, 'double')
        set(g,'edl',edgesTemp,'edgeDatatype',{'double'});
        warning('TORSCHE:graph:weightsOfGraphAreMissing','Edge data type missing, set to "double"');
    else
        error ('TORSCHE:graph:weightsOfGraphAreMissing','Weights of edges are missing!');
    end
end
edl = cell2mat(edgesTemp(:,1:2));
n = max(edl(:, 1:2));
n = max(n);
E = cell(1, n);
for i = 1:n
    index = find(edl(:, 1) == i);
    E{i} = edl(index, 2);
end
edges = [];
usedEdges = ones(1,size(edl,1));
Q = [];
Q = [Q s];
j = 1;
e = ones(size(edl,1),1);
edl = [edl e];
edgeList = mat2cell(edl,[ones(1,size(edl,1))],[ones(1,size(edl,2))]);
set(g,'edl',edgeList);
%  looking for the shortest path by the graph gf
U = floyd(g);
for i = 1:length(U)
    U(i,i) = 0;
end
while j <= length(Q)
    u = Q(j);
    j = j + 1;
    vertex = E{u};
    for i = 1:length(vertex)
        v = vertex(i);
        if U(s,u) + 1 == U(s,v)
            if v ~= t
                Q = [Q v];
            end
        else edges = between(g,u,v);
            if isempty(edges)
                edges = between(g,v,u);
            end
            usedEdges(edges) = 0;
        end
    end
end
usedEdges1 = find(usedEdges==0);
% modification of graph gf to level graph (gl)
gl = removeedge(gf, usedEdges1);
usedEdges = find(usedEdges==1);
end

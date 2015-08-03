function [f flowMatrix] = edmondsKarp(g,s,t)
% EDMONDSKARP is a function, which compute maximum flow of the graph.
%
%Synopsis
%         [F FLOWMATRIX] = EDMODSKARP(G,S,T)
%Description
% The function have a tree inputs, G - graph, S - source vertex and 
% T - sink vertex.
% Outputs are F - value of maximum flow of the graph
% and FLOWMATRIX - a matrix with number of flow. 
%  
%Example
% >> edgeList= {1 2,3;1 4,3;3 1,3;2 3,4;3 4,1;3 5,2;5 2,1;4 5,2;5 6,1;4 6,6;6 7,9};
% >> g = graph('edl',edgeList,'edgeDatatype',{'double'});
% >> s=1;t=7;
% >> [f flowMatrix] = edmondsKarp(g,s,t)
%
% See also GRAPH/DINIC 


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
edl = cell2mat(edgesTemp(:,1:3));
n = max(edl(:, 1:2));
n = max(n);
E = cell(1, n);
for i = 1:n
    index = find(edl(:, 1) == i);
    E{i} = edl(index, 2);
end
C = zeros(n, n);
for i = 1:size(edl, 1)
     C(edl(i,1), edl(i,2)) = edl(i,3);
end
%% ALGORITHM
% edmodsKarp algorithm
% Input: A network (G,s,t).
% Output: An s-t flow f of maximum value.
% Ref: lit-Korte, page 164
%% 1 Set f(e)=0 for all e \in E(G).
f = 0;
F = zeros(n, n);
%% 2 Find a shortest f-augmenting path P. ...
while 1
    [m P]= breadthFirstSearch(F,C,E,s,t);
%% ... If there is none, then stop.    
    if m == 0
        break
    end
%% 3 Compute \gamma:=min_{e\inE(P)} u_{f}(e). Augment f along P by \gamma and go to 2  
    f = f + m;
    v = t;
    while v ~= s
        u = P(v);
        F(u,v) = F(u,v) + m;
        F(v,u) = F(v,u) - m;
        v = u;
    end
end
flowMatrix = F;
end

%% function [Mt P]= breadthFirstSearch(F,C,E,s,t)
function [Mt P]= breadthFirstSearch(F,C,E,s,t)
P = -1*ones(1,length(C));
P(s)= -2;
M = zeros(1,length(C));
M(s) = inf;
Mt=0;
Q = [];
Q = [Q s];
j = 1;
while j <= length(Q)
    u = Q(j);
    j = j + 1;
    vertex = E{u};
    for i = 1:length(vertex)
        v = vertex(i);
        if C(u,v) - F(u,v) > 0 && P(v) == -1
            P(v) = u;
            M(v) = min(M(u), C(u,v) - F(u,v));
            if v ~= t
                Q = [Q v];
            else
                Mt = M(t);
                return;
            end
        end
    end
end
end



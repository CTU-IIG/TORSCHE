function [f flowMatrix] = dinic(g,s,t)
% DINIC is a function, which compute maximum flow of the graph.
%
%Synopsis
%         F = DINIC(G,S,T)
%         [F FLOWMATRIX] = DINIC(G,S,T)
%Description
% The function have a tree inputs, G - graph, S - source vertex and 
% T - sink vertex.
% Outputs are F - maxFlow, value of maximum flow of the graph
% and FLOWMATRIX - a matrix with number of flow. 
%
%Example
% >> edgeList= {1 2,3;1 4,3;3 1,3;2 3,4;3 4,1;3 5,2;5 2,1;4 5,2;5 6,1;4 6,6;6 7,9};
% >> g = graph('edl',edgeList,'edgeDatatype',{'double'});
% >> s=1;t=7;
% >> f = dinic(g,s,t)
%
% See also GRAPH/EDMONDSKARP, GRAPH/LEVELGRAPH


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
MF = [];
%% ALGORITHM
% dinic algorithm
% Input: A network (G,s,t).
% Output: An s-t flow f of maximum value.
% Ref: lit-Korte, page 166
%% 1 Set f(e)=0 for all e \in E(G) ???
flow = zeros(t,t);
%% construct of graph gf
gf = g;
usedEdges = 1:size(edl,1);
while 1
    edgeListOrig = get(gf,'edl');
    edgeListOrig = cell2mat(edgeListOrig(:,1:3));
    full = find(edgeListOrig(:,3)==0);
    if ~isempty(full)
        gf = removeedge(gf, full);
        edgeListOrig = get(gf,'edl');
        edgeListOrig = cell2mat(edgeListOrig(:,1:3));
    end
%% 2 Construct the level graf G_f^L 
    [gl usedEdges] = levelGraph(gf,s,t);
%%
    edgesTemp = get(gl,'edl');
    edl = cell2mat(edgesTemp(:,1:3));
    n = max(edl(:, 1:2));
    n = max(n);
    E = cell(1, n);
    numberOfEdges = cell(1, n);
    for i = 1:n
        index = find(edl(:, 1) == i);
        if isempty(index)
            E{i} = [];
            numberOfEdges{i} = [];
        else
            E{i} = edl(index, 2);
            numberOfEdges{i} = (index);
        end
    end
%% 3 Find a blocking s-t flow f' in G_f^L. ...
    [mf edl status flow] = expandVertex(s,E,edl,numberOfEdges,inf,t,flow);
%% 4 Augmenting f by f' and go to 2    
    if status == 1
        MF = [MF mf];
        edgeListOrig(usedEdges,3) = edl(:,3);
        edgeListOrig = mat2cell(edgeListOrig,[ones(1,size(edgeListOrig,1))],[ones(1,size(edgeListOrig,2))]);
        set(gf,'edl',edgeListOrig);
    else
%% ...  If f'=0, than stop.        
        break
    end
end
%% END ALGORITHM
f = sum(MF);
flowMatrix = flow;
end

function [mf edl status flow] = expandVertex(vertex,E,edl,numberOfEdges,mf,t,flow)
if vertex == t
    status = 1;
   return
end
nextVertex = E{vertex};
if isempty(nextVertex)
    status = 0;
    return
end
for i = 1:length(nextVertex)
    mf1 = min([mf edl(numberOfEdges{vertex}(i),3)]);
    [mf1 edl status flow]  = expandVertex(nextVertex(i),E,edl,numberOfEdges,mf1,t,flow);
   if status == 1
      edl(numberOfEdges{vertex}(i),3) = edl(numberOfEdges{vertex}(i),3) - mf1;
      mf = mf1;
      flow(edl(numberOfEdges{vertex}(i),1),edl(numberOfEdges{vertex}(i),2)) = mf1;
      return
   end
end

end




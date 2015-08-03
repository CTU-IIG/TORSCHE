function subgraph=subgraph(G,nodes)
%SUBGRAPH   Return subgraph of graph G, which includes nodes 'nodes'
%
% Syntax
%    subgraph = SUBGRAPH(G,nodes)
%     nodes    - nodes in new graph (list of node numbers or logical array)
%     G        - graph
%     subgraph - subgraph of graph G


% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2903 $  $Date:: 2009-03-26 13:53:34 +0100 #$


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

if islogical(nodes)
    nodes = find(nodes);
end

v_adj = adj(G);
adj_new = v_adj(nodes, nodes);
subgraph = graph('adj',adj_new);

% move nodes
for i = 1 : length (nodes)
    subgraph.N(i) = G.N(nodes(i));
end
[x,y]=find(adj_new);
for i = 1 : length(x);
    edge = between(G,nodes(x(i)),nodes(y(i)));
    edge_new=between(subgraph,x(i),y(i));
    edge = G.E(edge);
    if iscell(edge) 
        edge=edge{1};
    end
    subgraph.E(edge_new) = edge;
end 

% Other graph param
exceptParam = char('N','E','inc','adj','edl','ndl');
listOfParam = fieldnames(get(G));
for i=1:length(listOfParam)
    if isempty(strmatch(listOfParam{i},exceptParam,'exact'))
        set(subgraph,listOfParam{i},get(G,listOfParam{i}));
    end
end
%end .. @graph/subgraph
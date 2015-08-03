function gpair  = mwpm(g) 
% MWPM is a function, which solves minimum weight perfect matching
% of the graph.
%
%Synopsis
%        GPAIR  = MWPM(G)
%Description
% The function have one input, G - graph and one output, which is a graph
% GPAIR. This graph contains the same nodes as a graph G and edges, which
% are adherent to minimum weight perfect matching. The number of edges has
% to be even number and graph G must be weigthed.
%
%Example 1
% >> edgeList= {1 2,3;1 3,2;1 4,3;1 5,2;1 6 5;2 3,4;2 4,1;2 5,1;2 6,4;3 4,1;3 5,2;3 6,8;4 5,4;4 6,7;5 6,2};
% >> g = graph('edl',edgeList,'edgeDatatype',{'double'});
% >> gpair = mwpm(g)
%
%Example 2
% >> pairscount = 10;
% >> g = graph('adj',zeros(2*pairscount),'name','graph');
% >> ax = 1000;
% >> ay = 400;
% >> bx = 20;
% >> by = 20;
% >> randmx = rand(2,2*pairscount);
% >> for i = 1:length(g.N)
% >>    g.N(i).GraphicParam(1).x = round(ax*randmx(1,i))+bx;
% >>     g.N(i).GraphicParam(1).y = round(ay*randmx(2,i))+by;
% >> end
% >> graphedit(mwpm(distance(complete(g))),'viewedgesuserparams','off');
% >> graphedit('fit');
%
% See also GRAPH, GRAPH/EULER, GRAPH/DISTANCE, GRAPH/COMPLETE, 
% GRAPH/ILINPROG, GRAPH/CHRISTOFIDES


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


edgeList = get(g,'edl');
edgeList = cell2mat(edgeList);
edgeNumber = length(g.E);
nodeNumber = length(g.N);
if size(edgeList,2)<3
    error('Torsche:graph:wronginputparam',...
            'Missing the weigths of edges!');
end
nodeList = get(g,'ndl');
nodeList = cell2mat(nodeList);
if mod(size(nodeList,1),2)~=0
    error('Torsche:graph:oddnumberofnodes',...
            'The number of nodes is odd!');
end
A = abs(inc(g));
B = ones(nodeNumber,1);
C = edgeList(:,3);
LB = zeros(edgeNumber,1);
UB = ones(edgeNumber,1);
CTYPE(1:nodeNumber,1) = 'E';
VARTYPE(1:edgeNumber,1) = 'I';
xmin = ilinprog(schoptionsset(),1,C,A,B,CTYPE,LB,UB,VARTYPE);
del = find(xmin == 0);
if isempty(del)
    error('Torsche:graph:notexistmwpm',...
            'The mwpm does not exist in this graph!');
end
gpair = removeedge(g,del);
    
                
            

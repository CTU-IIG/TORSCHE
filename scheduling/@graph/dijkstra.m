function distance = dijkstra(g,startNode,varargin)
%DIJKSTRA finds the shortest path between reference node and other nodes in
%graph.
%
% Synopsis
%   DISTANCE = DIJKSTRA(GRAPH,STARTNODE,USERPARAMPOSITION)
%
% Description
%  Parameters:
%    GRAPH:
%      - graph with cost betweens nodes
%      - type inf when edge between two edges does not exist
%    STARTNODE:
%      - reference node
%    USERPARAMPOSITION:
%      - position in UserParam of Nodes where number representative color
%        is saved. This parameter is optional. Default is 1. 
%    DISTANCE:
%      - list of distances between reference node and other nodes 
%
% See also GRAPH/GRAPH, GRAPH/FLOYD, GRAPH/CRITICALCIRCUITRATIO


% Author: R. Prikner
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


if nargin > 2
    userParamPosition = varargin{1};
else
    userParamPosition = 1;
end

matrix = edge2param(g,userParamPosition);
n = size(matrix,1);

visited(1:n) = 0;
no_visited = zeros(1,n);

distance(1:n) = inf;

distance(startNode) = 0;

for a = 1:(n-1)
    
    %mark no visited nodes
    for b = 1:n
         if visited(b) == 0 
             no_visited(b) = distance(b);
         else
             no_visited(b) = inf;
         end             
    end
    
     %selection of min
     [x,y] = min(no_visited);
    
     %mark visited node
     visited(y) = 1;
     
     if(x==inf)
         break
     end;
     
     %expand and update last visited node
     for v = 1:n,          
         if ( ( matrix(y, v) + distance(y)) < distance(v) )
             distance(v) = distance(y) + matrix(y, v);                                    
         end;
     end;    
end;

return


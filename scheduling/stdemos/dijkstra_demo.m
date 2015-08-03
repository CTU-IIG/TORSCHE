% DIJKSTRA_DEMO Demo application of the longest paths
%
%    See also DIJKSTRA

% Author: Roman Capek <capekr1@fel.cvut.cz>
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


clc;
disp('Demo of shortest paths (Dijkstra''s algorithm).');
disp('------------------------------------------------------');


%create graph
disp(' ');
disp('Adjacency matrix of the input graph');
A = [0   1   2   inf 7;
     inf 0   3   4   inf;
     inf 9   0   1   1;
     8   5   inf 0   inf;
     7   inf 4   5   0  ]
g = graph(A);
g.Name = 'G_{1}';

graphedit(g);

%define reference node
ref = 2;

%call algorithm
distance = dijkstra(g, ref);

%display results
disp(' ');
disp('Results:');
for i = 1:size(A,1);
    display(['Minimal distance from node ' int2str(ref) ' to node ' int2str(i) ' is ' int2str(distance(i)) '.']);
end


% TORSCHE Scheduling Toolbox for Matlab.
% Version 0.4.0 12-October-2007
%
% General objects of toolbox
%   task      - Create object of task
%   taskset   - Create Set of tasks
%   problem   - Define scheduling problem
%   graph     - Create object of graph
%
% Scheduling algorithms
%   alg1rjcmax - Algorithm for 1|rj|Cmax
%   bratley   - Bratley’s Algorithm	
%   alg1sumuj - Hodgson's Algorithm	
%   algpcmax  - Algorithm for P||Cmax	
%   mcnaughtonrule - McNaughton's Algorithm
%   algprjdeadlinepreccmax - Algorithm for P|rj,prec,~dj|Cmax	 
%   hu        - Hu's Algorithm	
%   brucker76	  - Brucker's algorithm	(1976)
%   horn	    - Horn's Algorithm
%   listsch	  - List Scheduling	
%   coffmangraham	- Coffman's and Graham's Algorithm	
%   spntl	    - Scheduling with Positive and Negative Time-Lags	
%   cycsch	  - Cyclic scheduling (General)	
%   satsch	  - SAT Scheduling	P|prec|Cmax	[TORSCHE06]
%   fps       - Fixed Priority Scheduling
%   resptime  - Response Time Equation
%   taskset/alap      - As Late As Posible
%   taskset/asap      - As Soon As Posible
%
% Graph algorithms
%   graph/spanningtree - Minimum spanning tree
%   graph/floyd - Floyd: The shortests paths
%   graph/mincostflow - Minimum Cost Flow
%   graph/criticalcircuitratio - Critical Circuit Ratio
%   graph/hamiltoncircuit - Hamilton circuit
%   graph/qap - Quadratic Assignment Problem	
%   graph/pred - Return all predecessors of node from graph
%   graph/succ - Return all succecessors of node from graph
%
% Supplementary algorithms
%   ilinprog  - Univerzal interface for integer linear programming
%   iquadprog - Univerzal interface for integer quadratic programming
%   randdfg   - Random Data Flow Graph (DFG) genarator
%   schoptionsset - Scheduling Toolbox solvers settings
%   graphedit - Editor of graphs
%
% Tasks
%   task      - Create object of task
%   set  - Set/modify properties of task
%   get  - Access values of task properties
%   task/plot - Draw the task with properties
%   task/add_scht - Add schedule to the task
%   task/get_scht - Get schedule from the task
%   task/task2node - Convert task to the graph object node
%   task/task2userparam  - Convert task to the cell array
%   []        - Concate tasks to taskset
%
% Set of tasks (taskset)
%   taskset   - Create object taskset
%   set       - Set/modify properties of taskset
%   get       - Access values of taskset properties
%   taskset/plot - Draw the tasks
%   taskset/colour - Colour tasks in set of tasks
%   taskset/add_schedule - Add schedule to taskset
%   taskset/count - Return number of tasks inside taskset
%   taskset/schparam - Return a details about taskset schedule
%   taskset/sort - Order the tasks inside the taskset
%
% Problem
%   problem   - Notation of problem
%   problem/is - Check parameters inside the problem
%
% Graph
%   graph     - Create object graph
%   graph/adj - Return adjacency matrix of graph
%   graph/inc - Return incidence matrix of graph
%   graph/between - Return edges between two nodes
%   graph/subgraph - Subgraph of graph
%   graph/edges2param - Convert edges to cell array
%   graph/param2edges - Convert cell array to edges
%
% Other
%   make      - Compile Scheduling Toolbox mex-filesm


% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Author: Premysl Sucha <suchap@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2895 $  $Date:: 2009-03-18 11:24:58 +0100 #$


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


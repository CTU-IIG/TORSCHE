function [map,fmin,status,extra] = qap(distancesgraph,flowsgraph)
%QAP solves the Quadratic Assignment Problem
%
% Synopsis
%    [MAP,FMIN,STATUS,EXTRA] = QAP(DISTANCESGRAPH,FLOWSGRAPH)
%
% Description
%    The problem is defined using two graphs: graph of distances
%    DISTANCESGRAPH and graph of flows FLOWSGRAPH.
%
%    A nonempty output is returned if a solution is found. The first return
%    parameter MAP is the optimal mapping of nodes to locations. FMIN is
%    optimal value of the objective function. Status of the optimization
%    is returned in the third parameter STATUS (1-solution is optimal).
%    The last parameter EXTRA is a data structure containing the
%    field TIME - time (in seconds) used for solving.
%
% Example
%
% >> D = [0 1 1 2 3; ... % distances matrix
%         1 0 2 1 2; ...
%         1 2 0 1 2; ...
%         2 1 1 0 1; ...
%         3 2 2 1 0];
% >> F = [0 5 2 4 1; ... % flows matrix
%         5 0 3 0 2; ...
%         2 3 0 0 0; ...
%         4 0 0 0 5; ...
%         1 2 0 5 0];
% >> distancesg=graph(1*(D~=0));                      %Create graph of distances
% >> distancesg=matrixparam2edges(distancesg,D,1,0);  %Insert distances into the graph
% >> flowsg=graph(1*(F~=0));                          %Create graph of flow
% >> flowsg=matrixparam2edges(flowsg,F,1,0);          %Insert flows into the graph
% >> qap(distancesg,flowsg);
%
% See also GRAPH/GRAPH, IQUADPROG.


% Author: M. Nemec
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


D = edges2matrixparam(distancesgraph,1,0);
F = edges2matrixparam(flowsgraph,1,0);

n = length(D(1,:));
row=[];
H=[];
for i=1:n,
    for j=1:n,
        row = [row,D(i,j)*F];
    end
    H = [H;row];                      % quadratic objective function
    row = [];
end

c = zeros(1,n^2)';                      % linear objective function

A = []; 
qM = zeros(n,n);
for i=1:n,
    qM(i,:) = 1;
    qM = [qM;diag(ones(1,n))];
    A = [A,qM];                         % matrix representing linear constraints
    qM = zeros(n,n);
end

b = ones(1,2*n)';                       % right sides for the inequality constraints

ctype = '';
ctype(1:2*n,1) = 'E';                   % sense of the inequalities

lb=zeros(n^2,1);                        % lower bound on variables
ub=ones(n^2,1);                         % upper bound on variables

vartype = '';
vartype(1:n^2,1) = 'B';                 % variable type
             
schoptions=schoptionsset('miqpSolver','miqp','solverVerbosity',0);   %ILP solver options (use default values)

%disp('The solution is:');
[xmin,fmin,status,extra] = iquadprog(schoptions,1,H,c,A,b,ctype,lb,ub,vartype);

map = reshape(xmin,n,n);

%end .. @graph/qap

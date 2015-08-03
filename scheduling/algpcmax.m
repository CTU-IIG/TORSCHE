function [TS] = algpcmax(T, prob, No_Proc)
% ALGPCMAX  computes schedule for 'P||Cmax'problem
%
% Synopsis
%   TS = algpcmax(T, problem, No_Proc)
%
% Description
%	TS = algpcmax(T, problem, No_Proc) finds schedule of scheduling problem 'P||Cmax'.
%    Parameters:
%     T:
%       - input set of tasks
%     TS:
%       - set of tasks with a schedule
%     PROBLEM:
%       - description of scheduling problem (object PROBLEM) - 'P||Cmax', 
%     No_Proc:
%       - number of processors for scheduling  
%
% See also ALGPRJDEADLINEPRECCMAX, MCNAUGHTONRULE, HU, LISTSCH.


% Author: M. Silar
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


m = No_Proc; 
n = size(T);

if ~(is(prob,'alpha','P') && is(prob,'betha','') && is(prob,'gamma','Cmax') && (m > 0))
    error('This problem can''t be solved by this algorithm or number of processors is smaller than zero');
end

% matrix A

prosesses = eye(n);
for i=2:m
    prosesses = [prosesses, eye(n)];
end

row2 = [T.ProcTime(:)',zeros(1,2*n)];

processors(1,:) = row2;
for i=1:n
    for u=1:length(row2)
        processors(i+1,u+(i*n)) = row2(1,u);
    end
end

c_max_column = [zeros(n,1);-1*ones(m,1)];

A = [prosesses;processors(1:m,1:n*m)];
A = [A,c_max_column];


%vector b
b = [ones(n,1);zeros(m,1)];

%vector c
c = [zeros(m*n,1);1];

% CTYPE         %type of condition: 'E'="=", 'L'="<=", 'G'=">="
ctype = 'E';
for i=2:n
    ctype = [ctype;'E'];         
end
for i=n+1:n+m
    ctype = [ctype;'L'];
end

%lower bound of variables
lb = [zeros(m*n,1);ceil(sum(T.ProcTime)/m)];

%upper bound of variables
ub = [ones(m*n,1);sum(T.ProcTime)];


% VARTYPE    %Type of variable 'C'=continous, 'I'=integer
vartype = 'I';
for i=2:m*n+1
	vartype = [vartype;'I'];
end

schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',0);

%type of optimalization: 1=minimalization, -1=maximalization
sense=1;											

[xmin,fmin,status,extra] = ilinprog (schoptions,sense,c,A,b,ctype,lb,ub,vartype);

if(status==1)
    C_max = xmin(m*n+1);
else
    error('ILP solver internal problem.');
end;

% ----------------------------------------------------
t_proc = zeros(1,m);                %disponibility time of processor
s = inf*ones(1,n);                  %start of executing tasks
processorSchedule = zeros(1,n);     %vector of task assignment to processor

xmin = xmin';

for i=0:m-1
    for u=1:n
        if xmin(i*n+u)==1
            processorSchedule(u) = i+1;
            s(u) = t_proc(i+1);
            t_proc(i+1) = t_proc(i+1) + T.ProcTime(u);
        end
    end
end

% ----------------------------------------------------
description = 'Parallel scheduling without preemption';
add_schedule(T,description,s,T.ProcTime,processorSchedule);      %Pridani rozvrhu do mnoziny uloh (taskset).

TS = T;

% end

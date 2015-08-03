function [TS] = algprjdeadlinepreccmax(T,prob,m)
% ALGPRJDEADLINEPRECCMAX computes schedule for P|rj,prec,~dj|Cmax problem
%
% Synopsis
%   TS = algprjdeadlinepreccmax(T, problem, No_proc)
%
% Description
%	TS = algprjdeadlinepreccmax(T, problem, No_proc) finds schedule to the
%   scheduling problem 'P|rj,prec,~dj|Cmax'.
%   Parameters: 
%     T:
%       - input set of tasks
%     TS:
%       - set of tasks with a schedule,
%     PROBLEM: 
%       - description of scheduling problem (object PROBLEM) -
%	      'P|rj,prec,~dj|Cmax'
%     No_proc:
%       - number of processors for scheduling
%
% See also PROBLEM/PROBLEM, TASKSET/TASKSET, ALGPCMAX, CYCSCH.


% Author: M. Silar
% Author: J. Maly <malyj5@fel.cvut.cz>
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


if ~all(T.Deadline-T.ReleaseTime-T.ProcTime >= 0)
    error('Wrong input data');
end

if ~(is(prob,'alpha','P') && is(prob,'betha','rj,prec,~dj') && is(prob,'gamma','Cmax') && (m > 0))
    error('This problem can''t be solved by this algorithm or number of processors is smaller than zero');
end

n = size(T);

CmaxUB = scheduleLength(T,m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create constraints:

%each task must be scheduled once
A1 = zeros(n,CmaxUB*n+1);
for i=1:n
    A1(i,((i-1)*CmaxUB+1):(i*CmaxUB))=1;
end
b1 = ones(n,1);
ctype1(1:n,1)='E';

%no more than m tasks can be processed at a given time
 A2 = zeros(CmaxUB,CmaxUB*n+1);

for j=1:CmaxUB
    for i=1:n
            A2OneTaskLine = zeros(1,CmaxUB);
            A2OneTaskLine(max(1,j-T.ProcTime(i)+1):j) = 1;
            A2(j,(i-1)*CmaxUB+1:i*CmaxUB) = A2OneTaskLine;
    end
end
b2 = m*ones(CmaxUB,1);
ctype2(1:CmaxUB,1)='L';


%add release dates
A3 = zeros(n,CmaxUB*n+1);
for i=1:n
    A3(i,((i-1)*CmaxUB+1):(i*CmaxUB)) = 0:(CmaxUB-1);
end
b3 = (T.ReleaseTime)';
ctype3(1:n,1)='G';

%add deadlines
A4 = zeros(n,CmaxUB*n+1);
for i=1:n
    A4(i,((i-1)*CmaxUB+1):(i*CmaxUB)) = 0:(CmaxUB-1);
end
b4 = ( min(T.Deadline,CmaxUB-T.ProcTime) )';
ctype4(1:n,1)='L';

%add precedence constraints
A5 = zeros(0,CmaxUB*n+1);
b5=[];
ctype5=[];
for i=1:n
    for j=1:n
        if T.prec(i,j) == 1
            if i==j
                error('Incorrect precedence constraints!');
            end
            A5line = zeros(1,CmaxUB*n+1);
            A5line(((i-1)*CmaxUB+1):(i*CmaxUB)) = 0:(CmaxUB-1);
            A5line(((j-1)*CmaxUB+1):(j*CmaxUB)) = -(0:(CmaxUB-1));
            b5(end+1,1) = -T.ProcTime(i); %#ok<AGROW>
            ctype5(end+1,1) = 'L'; %#ok<AGROW>
            A5 = [A5; A5line]; %#ok<AGROW>
        end
    end
end


%add Cmax constraint
A6 = zeros(0,CmaxUB*n+1);
b6=[];
ctype6=[];
for i=1:n
    A6(i,((i-1)*CmaxUB+1):(i*CmaxUB)) = 0:(CmaxUB-1);
    A6(i,end) = -1;
    b6(end+1,1) = -T.ProcTime(i); %#ok<AGROW>
    ctype6(end+1,1) = 'L'; %#ok<AGROW>
end


%join all constraints together
A = [A1; A2; A3; A4; A5; A6];
b = [b1; b2; b3; b4; b5; b6];
c = zeros(CmaxUB*n+1,1);
c(end) = 1;
ctype = [ctype1; ctype2; ctype3; ctype4; ctype5; ctype6];
lb = zeros(CmaxUB*n+1,1);
ub = ones(CmaxUB*n+1,1);
ub(end) = CmaxUB;
vartype(1:CmaxUB*n+1) = 'I';
sense = 1;

schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',0);

%solve the problem
[xmin,fmin,status] = ilinprog (schoptions,sense,c,A,b,ctype,lb,ub,vartype);
if status~=1
    TS = T;
    return;
end

s = zeros(1,n);
procesor = zeros(1,n);

for i=1:n
    xminI = xmin(((i-1)*CmaxUB+1):(i*CmaxUB));
    s(i) = mod(0:(CmaxUB-1),CmaxUB) * xminI;
end

[val,ind] = sort(s);
proc_task = zeros(m,1);

for i = 1:n
    for j = 1:m
        if (val(i) >= proc_task(j))
            procesor(ind(i)) = j;
            proc_task(j,1) = val(i) + T.ProcTime(ind(i));
            break;
        end
    
    end
end

description = 'Optimal schedule obtained by ILP';
add_schedule(T,description,s,T.ProcTime,procesor);

TS = T;

end


%--------------------------------------------------------------------------
%Function scheduleLength is used to evaluate a upper bound for ILP
function scheduleLength = scheduleLength(T,m)

n=length(T.Name);           %pocet uloh

%Pomocne promenne
t=zeros(1,m);                   %disponibility time of processor
s=inf*ones(1,n);                %start of executing tasks
processorSchedule=zeros(1,n);   %vector of assignment tasks to processor
startCondition = inf(1,n);

%Sort tasks according to its deadlines (list)
[p,list] = sort(T.Deadline);
numberOfTasks = size(T);
maxCmax = sum(T.ProcTime);         %The worst Cmax upper bound

for i=1:n
    if ( T.Prec(:,i) == zeros(n,1))
        startCondition(i) = 0;
    end
end
ammountOfScheduled = 0;             %a counter of scheduled tasks
t_index = 1;                        %an index of chiced processor

while ((ammountOfScheduled ~= numberOfTasks) && (t(t_index)<=maxCmax))

    %Choosing processor
    [t_hodn,t_index] = min(t);

    %Choosing task
    x = 0;
    test = false;
    while((test == false) && (x < numberOfTasks))
        x = x+1;
        if ((startCondition(list(x)) ~= Inf) && (startCondition(list(x)) ~= -Inf) && ...
                (startCondition(list(x))<= t_hodn) && (T.ReleaseTime(list(x))<= t_hodn))
            actual_task = list(x);
            test = true;
        end
    end

    if test == true
        %Schedule task
        s(actual_task) = t_hodn;
        processorSchedule(actual_task) =  t_index;
        t(t_index)= t_hodn + T.procTime(actual_task);
        startCondition(actual_task) = -Inf;
        ammountOfScheduled = ammountOfScheduled + 1;

        for i=1:n
            if (sum(T.Prec(actual_task,:) == zeros(1,n)) < n)
                for v=1:n
                    if(T.Prec(actual_task,v) == 1);
                        startCondition(v) = t(t_index);
                    end
                end
            end;
        end;

    else
        t(t_index)=t(t_index)+1;
    end
end

scheduleLength=max(t);
end


%end of file

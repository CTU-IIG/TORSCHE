function [TS] = mcnaughtonrule (T, prob, No_Proc)
% MCNAUGHTONRULE  computes schedule with McNaughtons's algorithm
%
% Synopsis
%           TS = MCNAUGHTONRULE(T, prob, M)
%
% Description
%	TS = MCNAUGHTONRULE(T, prob, No_Proc) finds schedule of scheduling problem
%    'P|pmtn|Cmax'. First input parameter T is set of tasks to be schedule.
%    The second parameter is description of the scheduling problem (see PROBLEM/PROBLEM)
%    and the last parameter M is number of processors. Resulting schedule is 
%    returned in TS.
%
% See also PROBLEM/PROBLEM, TASKSET/TASKSET, ALGPCMAX.


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


m = No_Proc;           %amount of processors
n = size(T);           %amount of tasks

if ~(is(prob,'alpha','P') && is(prob,'betha','pmtn') && is(prob,'gamma','Cmax') && (m > 0))
    error('This problem can''t be solved by McNaughton''s algorithm or number of processors is smaller than zero');
end


t_proc = zeros(1,m);                 %processor's disponibility time

for i=1:n
    ProcTime{i}(1)= T.ProcTime(i);
    processorSchedule{i}(1) = 0;        %vector of task assignment to a processor
    s{i}(1) = inf;                   %task performing start
end

C_max = max(max(T.ProcTime),sum(T.ProcTime/m));


%task Ti and processor Pj
t = 0;
full = zeros(1,m);
finished = zeros(1,n);
    
for j=1:m
    for i=1:n
      if (full(j) == 0 )
        if (finished(i) == 0)  
            if ((t_proc(j) + ProcTime{i}(1) <= C_max))
                processorSchedule{i}(1) = j;
                s{i}(1) = t_proc(j);
                t_proc(j) = t_proc(j) + ProcTime{i}(1);
                finished(i) = 1;
            else
                ProcTime{i}(1) = t_proc(j) + ProcTime{i}(1) - C_max; 
                ProcTime{i}(2) = C_max - t_proc(j);
                processorSchedule{i}(2) = j;
                processorSchedule{i}(1) = j + 1;
                s{i}(2) = t_proc(j);
                s{i}(1) = t_proc(j+1);
                t_proc(j) = C_max;
                t_proc(j+1) = ProcTime{i}(1);
                finished(i) = 1;
             end
        end
        if t_proc(j) == C_max
               full(j) = 1;
        end
      end
    end
end

description = ('Preemtive Scheduling according to McNaughton rule');
add_schedule(T,description,s,ProcTime,processorSchedule);      %assignment of schedule to the taskset

TS = T;

% end of file

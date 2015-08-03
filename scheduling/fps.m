function resultts = fps(ts)
%FPS  Schedules periodic tasks in taskset T according to their
%   fixed priorities (property Weight of a task).
%
% Synopsis
%           TS = fps(T)
%
% Description
%	TS = fps(T) adds schedule to the set of tasks, T -
%	input set of tasks, TS - set of tasks with a schedule
%
% See also: PTASK

% Author: Michal Sojka <sojkam1@fel.cvut.cz>
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

resultts = [];

c    =  ts.ProcTime;
per  =  ts.Period;
prio =  ts.Weight;

noft=size(c,2);

%initialization
ready = zeros(size(c));

schedtask=-1;
tmax=0;% time of scheduler

%ts=colour(ts); TODO - colorize only tasks with no color specified

% the length of hyper-period
% FIXME: Should be a parameter
tstop = 1;
for i = 1:noft
    tstop = lcm(tstop, per(i));
end
   

while(tmax < tstop)
    offs = mod(tmax, per);
    for i=1:noft
        if (offs(i) == 0)
            
            ready(i)=c(i); % put the tasks to the ready set
            pt = ts.tasks(i);
            pts = struct(pt);
            temptask = pts.task;
            temptask.Processor = i; % Hack for plotting the schedule
            temptask.ReleaseTime = tmax;
            readyTasks{i} = temptask;
        end
    end
   
    
    schedtask=-1; %  -1 means the idle task
    maxprio=1;
    for i=1:noft
        if(((ready(i)~=0))&&((maxprio<=prio(i))))
            maxprio=prio(i);
            schedtask=i;
        end
    end
    
    % Find the ready task with maximum priority
    
     hp_ind = find(prio > prio(schedtask));
     % find the closest time, where somebody can preempt schedtask
     a = per(hp_ind)-mod(tmax, per(hp_ind)); 
     astar = min(a);
     
     [start, len, processor] = get_scht(readyTasks{schedtask});
     start = [start tmax];
     processor = [processor readyTasks{schedtask}.Processor]; % Hack for plotting the schedule
     if astar < ready(schedtask) % the task is preempted
        len = [len astar];
        readyTasks{schedtask} = add_scht(readyTasks{schedtask}, start, len, processor);
        ready(schedtask)= ready(schedtask)-astar; 
        tmax=tmax+astar;
     else % the whole task will be executed
        executed = ready(schedtask);
        len = [len executed];
        readyTasks{schedtask} = add_scht(readyTasks{schedtask}, start, len, processor);
        ready(schedtask)= 0;
        
        if any(ready)
            tmax = tmax + executed;
        else
            tmax = tmax + astar;
        end
        if isempty(resultts)
            resultts = [readyTasks{schedtask}];
        else
            resultts = [resultts readyTasks{schedtask}];
        end
     end
end
add_schedule(resultts, 'Fixed priority schedule');

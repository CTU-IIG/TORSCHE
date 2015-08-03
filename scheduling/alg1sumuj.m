function [TS] = alg1sumuj (T, prob)
%ALG1SUMUJ computes schedule with Hodgson's algorithm
%
% Synopsis
%   TS = alg1sumuj(T, problem)
%
% Description
%	TS = alg1sumuj(T, problem) inds schedule of the scheduling problem '1||sumUj'.
%    Parameters:
%     T:
%       - input set of tasks
%     TS:
%       - set of tasks with a schedule
%     PROBLEM:
%       - description of scheduling problem (object PROBLEM) - '1||sumUj'
%
% See also PROBLEM/PROBLEM, TASKSET/TASKSET, ALG1RJCMAX, HORN.


% Author: Roman Capek <capekr1@fel.cvut.cz>
% Author: Ondrej Nyvlt
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


if ~(is(prob,'alpha','1') && is(prob,'betha','') && is(prob,'gamma','sumUj'))
    error('This problem can''t be solved by alg1sumuj algorithm.');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = length(T.Name);           %number of tasks
s = inf*ones(1,n);            %start dates of tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Algorithm start
% SEE Blazewicz - Scheduling Computer and Manufacturing Processes
%  2. edition, page 47, Algorithm 4.3.6

%%%%%%%%% Sort tasks in EDD rule - Earliest Due Date First
save_T = T;
[T, order] = sort(T, 'Duedate');

%%%%%%%%%% Main body of algorithm
Tn = [];
p = 0;
ord = [];
for j = 1:n
    if j==1
        Ts = [T(j)];
    else
        Ts = [Ts  T(j)];
    end
    p = p + T.proctime(j);
    if (p > T.Duedate(j))
        [pk, k] = max(Ts.proctime);
        p = p - pk;
        if isempty(Tn)
            Tn = [Ts(k)];
        else
            Tn = [Tn Ts(k)];
        end
        ord = [ord, order(k)];
        order = [order(1:(k-1)), order((k+1):end)];
        Ts = Ts([1:(k-1),(k+1):length(Ts.name)]);
    end
end

%%%%%%%%% EDD - Earliest Due Date First
% Schedule the tasks of Ts according to EDD rule
TS = sort(Ts, 'Duedate');

% Remaining tasks Tn = (T - Ts) we can schedule in an arbitrary order
%%%%%%%%%% Make final taskset from Ts and Tn
T = [Ts Tn];

%%%%%%% Computing of Start dates of scheduled Tasks
order = [order, ord];
time = 0;
for i = 1:length(save_T.name)
    s(order(i)) = time;
    time = time + save_T.proctime(order(i));
end

%%%%%%%%% Algorithm finishing
description = 'alg1sumuj algorithm for 1||sumUj';
add_schedule(save_T,description,s,save_T.ProcTime);      %Add schedule into taskset
TS = save_T;

%end of file

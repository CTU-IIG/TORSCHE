function [taskset] = brucker76(taskset, prob, m)
%BRUCKER76 Brucker's scheduling algorithm
%
% Synopsis
%    TS = Brucker76(T, PROB, M)
%
% Description
%    TS = Brucker76(T, PROB, M) returns optimal schedule of problem
%    P|in-tree,pj=1|Lmax defined in object PROB.
%      Parameters:
%       T:
%         - input taskset
%       PROB:
%         - problem
%       M:
%         - number of processors
%
%    See also PROBLEM/PROBLEM, TASKSET/TASKSET, LISTSCH, HU.

% Author: M. Stibor
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



if ~(is(prob,'alpha','P') && is(prob,'betha','in-tree,pj=1') && is(prob,'gamma','Lmax'))
    error('This problem can''t be solved by Brucker76.');
end

% Inicialization
DueSave=taskset.duedate; % save DueDates for correction later

% Brucker76
root=find(sum(taskset.prec,2)==0); %find roots - root hasn't successors
taskset.DueDate(root) = 1 - taskset.DueDate(root); %change duedate of roots
flow=root;

while ~isempty(flow) %while any root exists
    stack=find(sum(taskset.prec(:,flow),2)); % find predecessors of roots
    for i=1:length(stack)
        taskset.tasks(stack(i)).DueDate=max(...
            1+taskset.tasks(find(taskset.prec(stack(i),:))).DueDate,...  % 1 + Duedate of successor
            1-taskset.tasks(stack(i)).DueDate); % 1 - DueDate of actual task "i"
    end
    flow=stack; % actual tasks are new flowroots
end

[taskset, order] = sort(taskset,'DueDate','dec'); %sort tasks in nonincreasing order

p=problem('P|prec|Cmax'); %problem overloaded
taskset=listsch(taskset,p,m); %List Scheduling method
taskset.DueDate=DueSave(order); %correction of DueDates
add_schedule(taskset,'Brucker76');


% end .. Brucker76

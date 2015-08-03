function [TS] = bratley(T, prob)
% BRATLEY computes schedule by algorithm described by Bratley
%
% Synopsis
%   TS = BRATLEY(T, problem)
%
% Description
%	TS = BRATLEY(T, problem) finds schedule of the scheduling 
%      problem '1|rj,~dj|Cmax'.
%    Parameters:
%     T:
%      - input set of tasks
%     TS:
%      - set of tasks with a schedule
%     PROBLEM:
%      - description of scheduling problem (object PROBLEM)'1|rj,~dj|Cmax'
%
% See also PROBLEM/PROBLEM, TASKSET/TASKSET, ALG1RJCMAX, SPNTL.


% Author: Roman Capek <capekr1@fel.cvut.cz>
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


if ~(is(prob,'alpha','1') && is(prob,'betha','rj,~dj') && is(prob,'gamma','Cmax'))
    error('This problem can''t be solved by Bratley.');
end


Tin = T;
[T, init_ord] = sort(T,'ReleaseTime','ascend');
ReleaseTime = get(T,'ReleaseTime');
Deadline = get(T,'Deadline');
ProcTime = get(T,'ProcTime');
if sum((ProcTime+ReleaseTime)>Deadline)>0
    display('No solution for this problem');
    TS={};
else
    ret = 0;
    opt = 0;
    absolute = 1;
    Cmax = max(Deadline);
    save_T = T;
    count = size(ProcTime,2);
    tasks = (1:count);
    A = zeros(count);
    solved = 0;
    i = 0;
    while i<=count-1
        if ~ret
            i = i+1;
        end
        ret = 0;
        elapsed_time = ProcTime(i)+ReleaseTime(i);
        scheduled = i;
        if i == 1
            A(1,1:end-1) = tasks(2:end);
        elseif i == count
            A(1,1:end-1) = tasks(1:end-1);
        else
            A(1,1:end-1) = [tasks(1:i-1) tasks(i+1:end)];
        end
        j = 1;
        while size(scheduled,2)<count
            while size(scheduled,2)<count
                child = A(j,:);
                child = child(child>0);
                RT = ReleaseTime(child);
                PT = ProcTime(child);
                DL = Deadline(child);
                if sum((PT+max(RT, elapsed_time))>DL)>0 || (elapsed_time+sum(PT)>=Cmax && solved)
                    break;
                else
                    j = j+1;
                    scheduled = [scheduled, child(1)];
                    child = tasks(~ismember(tasks, scheduled));
                    A(j,1:size(child,2)) = child;
                    elapsed_time = max(elapsed_time,ReleaseTime(scheduled(end)))...
                        +ProcTime(scheduled(end));
                    if elapsed_time<=min(ReleaseTime(child))
                        opt = 1;
                        break;
                    end
                end
            end
            if opt
                break;
            end
            if (j>1)&&(size(scheduled,2)<count)
                while(sum(A(j,:)>0)<2)
                    if sum(A(1,:)>0)<2
                        break;
                    end
                    j = j-1;
                    scheduled = scheduled(1:end-1);
                end
                if sum(A(1,:)>0)<2
                    break;
                end
                A(j,1:end) = [A(j,2:end) 0];
                elapsed_time = 0;
                for h=1:size(scheduled,2)
                    elapsed_time = max(ReleaseTime(scheduled(h)),elapsed_time)...
                        +ProcTime(scheduled(h));
                end
            else
                break;
            end
        end
        if size(scheduled,2)==count && (elapsed_time<Cmax || ~solved)
            ret = 1;
            solved = 1;
            T = save_T(scheduled);
            ord = init_ord(scheduled);
            Cmax = elapsed_time;
            Release = get(T,'ReleaseTime');
            Proc = get(T,'ProcTime');
            s(1) = Release(1);
            for k = 1:count-1
                s(k+1) = max(Release(k+1),s(k)+Proc(k));
            end
            for k = 0:count-1
                if Release(count-k) == s(count-k)
                    if sum(Release(count-k+1:end)<Release(count-k))>0
                        absolute = 0;
                    end
                    break;
                end
            end
            if absolute
                break;
            end
            absolute = 1;
        end
        if opt
            a = A(j,:);
            rest = save_T(a(a>0));
            row = 1:size(T);
            ord = [init_ord(scheduled) row(~ismember(row,init_ord(scheduled)))];
            T = [save_T(scheduled), bratley(rest, prob)];
            if(size(T) == count)
                Release = get(T,'ReleaseTime');
                Proc = get(T,'ProcTime');
                s(1) = Release(1);
                for k = 1:count-1
                    s(k+1) = max(Release(k+1),s(k)+Proc(k));
                end
                for k = 1:count-1
                    if Release(count-k)==s(count-k)
                        if sum(Release(k+1:end)<Release(k))>0
                            absolute = 0;
                        end
                        break;
                    end
                end
                solved = 1;
                if absolute
                    break;
                end
                absolute = 1;
            end
            opt = 0;
            break;
        end
    end
    if ~solved
        TS = {};
        display('No solution for this problem');
    else
        description = 'Bratley''s algorithm';
        ProcTime = get(Tin,'ProcTime');
        [a, fin_ord] = sort(ord);
        add_schedule(Tin,description,s(fin_ord),ProcTime);
        TS = Tin;
    end
end

%end of file

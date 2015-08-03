function [taskset] = satsch (taskset, prob, m)
%SATSCH computes schedule by algorithm described in [TORSCHE06]
%
%Synopsis
% taskset = SATSCH(taskset, problem, m)
%
%Description
% Properties:
%  taskset:
%    - set of tasks
%  problem:
%    - description of scheduling problem (object PROBLEM)
%  m:
%    - number of processors
%
% See also PROBLEM/PROBLEM, TASKSET/TASKSET


% Author: Michal Kutil <kutilm@fel.cvut.cz>
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



if ~(is(prob,'alpha','P') & is(prob,'betha','prec') & is(prob,'gamma','Cmax'))
    error('This problem can''t be solved by List Scheduling.');
end

% Inicialization
p = problem ('P|prec|Cmax');

% Use heuristics for start time search
% 1st heuristic
Theuristic_best = listsch(taskset, p, m);
maxtime=schparam(Theuristic_best,'Cmax');
% 2nd heuristic
Theuristic = heuristic(taskset, 1);
Theuristic = listsch(Theuristic, p, m);
maxtime2=schparam(Theuristic,'Cmax');
if maxtime2<maxtime
    maxtime = maxtime2;
    Theuristic_best = Theuristic;
end
% 3nd heuristic
Theuristic = heuristic(taskset, 2);
Theuristic = listsch(Theuristic, p, m);
maxtime2=schparam(Theuristic,'Cmax');
if maxtime2<maxtime
    maxtime = maxtime2;
    Theuristic_best = Theuristic;
end

% interations
iteration = 0;
times = [];
memories = [];
try
    for besttime = (maxtime-1):-1:1
        iteration = iteration + 1;
        fprintf('\n');
        disp (['Time : ' num2str(besttime)]);
        for idash=1:length(num2str(besttime)) fprintf('-'); end
        disp (['-------']);

        taskset=asap(taskset,m);
        taskset=alap(taskset,besttime,m);

        struct = sat_prepare_clause(taskset,m);
        [SAT,SOL,PAR]=satsch_mex(struct); % TODO - check that SATSCH_MEX exist.

        % solution time
        disp(['SAT time: ' num2str(PAR.time)]);
        times = [times PAR.time];
        memories = [memories PAR.memory];
        %satisfiable
        if SAT
            % solution
            sat_true_var = find(SOL);
            % for decoding
            asap_table = asap(taskset,'asap');
            alap_table = alap(taskset,'alap');
        else
            break
        end
    end
catch
    [lastmsg, lastid] = lasterr;
    if ~strcmp(lastid,'scheduling:alap')
        rethrow(lasterror)
    end
end
fprintf('\n');
% solution
if exist('sat_true_var','var')
    % SAT was used for search solutions
    for i = 1:length(sat_true_var)
        solution=sat_ind2subaa(sat_true_var(i),asap_table,alap_table,m);
        start(solution(1,1)) = solution(1,2);
        processor(solution(1,1)) = solution(1,3);
    end
    add_schedule(taskset,'SAT solver',start,taskset.ProcTime,processor);
else
    % heuristic was used
    taskset = Theuristic_best;
    add_schedule(taskset,'SAT solver (heuristic)');
    iteration=0;
end
add_schedule(taskset,'time',times);
add_schedule(taskset,'memory',memories);
add_schedule(taskset,'iteration',iteration);

fprintf('\n');
% end .. satsch



function [T] = heuristic(T, type)
% type = 1 - SPT
% type = 2 - LPT

% place for heuristic
tmp = struct(T);
tmpproctime = get(T,'proctime'); % get processing times

[varnull,ordertask]=sort(tmpproctime); % sort - SPT
if type==2
    ordertask=rot90(rot90(ordertask)); % Uncoment for LPT
end

nts = 'T = taskset([';
% reorder tasks
for i = 1:length(ordertask)
    nts=[nts ' tmp.tasks{' int2str(ordertask(i)) '}'];
end
% new prec matrix
prec=T.prec;
newprec = zeros(length(ordertask));
[fromtask,totask]=find(prec);
for i = 1:length(fromtask)
    newprec(find(ordertask==fromtask(i)),find(ordertask==totask(i))) = 1;
end
nts=[nts ' ],newprec);'];
eval(nts);
clear nts newprec tmpproctime tmp varnull ordertask fromtask totask i;
% ^- end of heuristic

%end of file


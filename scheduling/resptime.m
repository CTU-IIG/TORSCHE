function [R, schedulable]=resptime(taskset)
% resptime - algoritm Response Time Equation for a set of periodic tasks
%	R = resptime(taskset) is a row vector where R(i) is worst-case
%       response time of i-th task of the taskset. The tasks are scheduled by fixed
%       priority scheduller
%   Syntax:
%        RESPTIME(taskset)
%               taskset - set of periodic tasks

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


for i = 1:length(taskset.tasks),
    ptask = taskset.tasks(i);
    if isa(ptask, 'ptask')

        C(i)=get(ptask,'ProcTime'); %C is row vector of computation times
        T(i)=get(ptask,'Period');   %T is row vector of periods
        P(i)=get(ptask,'Weight');   %P is a row vector of priorities

    else
        error('noptask', sprintf('Task: [%s] is not a periodic task!!!', ptask.name))
    end

end
noft=size(C,2);


schedulable = true;

%Wm computing
R = zeros(1, length(T));
for i = 1:noft;   %for all taks
    % get indexes of higer and lower priority tasks
    ind_hi=find(P>P(i));
    ind_lo=find(P<P(i));
    % iterative algorithm for w of the current task
    w_old=-1;
    w=C(i);
    while w_old ~= w
        w_old = w;
        w = C(i) + sum(ceil(w_old./T(ind_hi)).*C(ind_hi));
        if w > T(i),
            schedulable = false;
            return
        end
    end
    R(i)=w;
end

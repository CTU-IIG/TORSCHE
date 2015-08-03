function out=alap(this, varargin)
%ALAP compute ALAP(As Late As Posible) for taskset
%
%Synopsis
%        Tout = ALAP(T, UB, [m])
% alap_vector = ALAP(T, 'alap')
%
%Description
% Tout=ALAP(T, UB, [m]) computes ALAP for all tasks in taskset T.
% Properties:
%  T:
%    - set of tasks
%  UB:
%    - upper bound
%  m:
%    - number of processors
%  Tout:
%    - set of tasks with alap
%
% alap_vector = ALAP(T, 'alap') returns alap vector from taskset.
% Properties:
%  T:
%    - set of tasks
%  alap_vector:
%    - alap vector
%     
% ALAP for each task is stored into set of task, the biggest ALAP is
% returned.
%
% See also TASKSET/ASAP.


% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2897 $  $Date:: 2009-03-18 15:17:31 +0100 #$


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


% output vector
if nargin>1
    if strcmpi(varargin{1},'alap')
        out(count(this))=0;
        for i = 1:count(this)
            str = struct(this.tasks{i});
            if isempty(str.ALAP)
                out(i) = nan;
            else
                out(i) = str.ALAP;
            end
        end
        return
    end
end

% computing vector
if nargin>1
    UB = varargin{1};
else
    error('Input argument "UB" is undefined.');
end

g = graph('adj',[this.Prec, ones(size(this),1);zeros(1,size(this)+1)]); % ones(... virtual node for last task
for i = 1 : size(this)
    to=find(this.Prec(i,:));
    for ii = 1 : length(to)
        g.E(between(g,i,to(ii))).UserParam = -this.tasks{i}.ProcTime;
    end
    % add time for virtual node
    g.E(between(g,i,size(this)+1)).UserParam = -this.tasks{i}.ProcTime;
end

%proctime = [get_vprop(this, 'ProcTime') 0]; 
proctime = [get(this,'ProcTime') 0]; 
for i = 1 : count(this)
    % critical path
    if ~isempty(succ(g,i))
        g_succ = subgraph(g,[i succ(g,i)]);
        U=floyd(g_succ);
        cp = -min(U(1,:)); %cp = critical path
    else
        cp = 0;
    end
    % resourse bound
    resbound = 0;
    if nargin == 3
        K = varargin{2};
        succe = succ(g,i);
        resbound = sum(floor(proctime(succe)./K)) + this.tasks{i}.ProcTime;
    end
    
    alap = UB - max(cp,resbound);
    if alap<0
        warning('TORSCHE:ALAPless0','ALAP is less than 0!')
    end
    task_struct = struct(this.tasks{i});
    if alap<task_struct.ASAP
        error('scheduling:alap','ALAP is less than ASAP!')
    end    
    %this.tasks{i} = set_helper(this.tasks{i},'ALAP',alap);
    eval(['this.tasks{i} =' class(this.tasks{i}) '(this.tasks{i},' char(39) 'ALAP' char(39) ',' num2str(alap) ');']);
end
out = this;
%end .. @taskset/alap

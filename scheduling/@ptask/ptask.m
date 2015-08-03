function ptask = ptask(varargin)
%PTASK  Creation of object ptask.
%
%  Creation:
%    ptask = PTASK([Name,]ProcTime,Period[,ReleaseTime[,Deadline[,Duedate[,Weight[,Processor]]]]])
%    periodic task with parameters:
%      name   - name of task (must by char!)
%      p      - proces time
%      period - period of the task
%      r      - release date
%      dl     - deadline
%      dd     - duedate
%      w      - weight
%      machine - dedicate machine
%    The output task is a PTASK object.  
%
%  See also TASK/TASK.


% Author: Michal Sojka <sojkam1@fel.cvut.cz>
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

 
if nargin==3
	if isa(varargin{1},'ptask') && ischar(varargin{2}) 
		ptask = set_helper(varargin{:});
		return;
	end
end

next = 1;
if (nargin >= next) & isa(varargin{next},'char'),
    name = varargin{next};
    varargin = {varargin{next+1:end}};
    if nargin < 3
        error('Not enough parameters');
    end
else
    name='';
    if nargin < 2
        error('Not enough parameters');
    end
end

parent = task(name, varargin{[1,3:end]});

ptask = struct(...
        'parent',       'task',...
        'Period',       varargin{2},...
        'version',      0);


ptask = class(ptask, 'ptask', parent); 

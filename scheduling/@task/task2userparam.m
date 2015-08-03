function parameters = task2userparam(t,varargin)
%TASK2USERPARAM  return task's parameters as cell.
%
%  Creation:
%    parameters = TASK2USERPARAM(task[,order])
%      parameters  - task's parameters as cell
%      task        - object of task
%      order       - cell with order output parameters
%                    For example: {'Name','ProcTime'}
%                    allowed are all parameters which can be obtained be
%                    the function GET: get(task).
%
%  See also TASK, GET.


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

 
na = nargin;
paramorder = {};
parameters = [];
if na>1
    if iscell(varargin{1})
        paramorder = varargin{1};
        if length(paramorder) == 1 & iscell(paramorder{1})
            paramorder = paramorder{1};
        end
    end
end
try
    for i=1:length(paramorder)
        parameters{i} = get(t,paramorder{i});
    end
catch
    rethrow(lasterror);
end
%end .. @task/task2userparam

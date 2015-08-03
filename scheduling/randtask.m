function rtask = randtask(varargin)
% RANDTASK Generates task of random parameters selected from uniform distribution.
%
%    task = RANDTASK([Name,]ProcTime[,ReleaseTime[,Deadline[,DueDate[,Weight[,Processor]]]]])
%    creates a task with parameters:
%      Name        - name of the task (must by char!)
%      ProcTime    - range of processing time (execution time)
%      ReleaseTime - range of release date (arrival time)
%      Deadline    - range of deadline
%      DueDate     - range of due date
%      Weight      - range of weight (priotiry)
%      Processor   - range of dedicated processor
%    The output task is a TASK object.


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


% name of task
next = 1;
if (nargin >= next) & isa(varargin{next},'char'),
    name = varargin{next};
    next = next + 1;
else
    name='';
end

% set parameters
[p,next]=set_parameter(varargin,next,-inf,1);
[r,next]=set_parameter(varargin,next,0,0);
[dl,next]=set_parameter(varargin,next,inf,0);
[dd,next]=set_parameter(varargin,next,inf,0);
[w,next]=set_parameter(varargin,next,1,0);
[machine,next]=set_parameter(varargin,next,[],0);

% generate task with random parameters
rtask = task(name,p,r,dl,dd,w,machine);

% internal function set_param
function [par, next] = set_parameter(var, next, defvalue, multi)

if (size(var,2)>=next) & (isa(var{next},'double'))
    range = var{next};
    if size(range,2)==2     % if parameter is range type
        if multi            % dedicated to processing time parameter
            for i=1:size(range,1)
                result(i) = round((range(i,2)-range(i,1)).*rand)+range(i,1);
            end
        else                % dedicated for other parameters
            result = round((range(2)-range(1)).*rand)+range(1);
        end
        par = result;       % randomized value of parameter
    else
        par = var{next};    % parameter is single number
    end

    next = next + 1;        % to next parameter
else
    par = defvalue;        % default value of parameter
end

% end of RANDTASK

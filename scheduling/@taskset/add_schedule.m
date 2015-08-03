function add_schedule (TASKSET, varargin)
%ADD_SCHEDULE adds schedule (starts time and lenght of time) for set of
%  tasks 
%
%Synopsis
% ADD_SCHEDULE(T, description[, start, length[, processor]])
% ADD_SCHEDULE(T, keyword1, param1, ..., keywordn, paramn)
%
%Description
% Properties:
%  T:
%   - taskset; schedule will be save into this taskset.
%  description:
%   - description for schedule. It must be diferent than a keywords below!
%  start:
%   - set of start time
%  lenght:
%   - set of lenght of time
%  processor:
%   - set of number of processor
%  keyword:
%   - keyword (char)
%  param:
%   - parameter
%
% Available keywords are:
%   description:
%     - schedule description (it is same as above)
%   time:
%     - calculation time for search schedule
%   iteration:
%     - number of interations for search schedule
%   memory:
%     - memory allocation during schedule search
%   period:
%     - taskset period - scalar or vector for diferent period of each task
%
% See also TASKSET/GET_SCHEDULE


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


ni = nargin-1;

TASKSET.schedule.is = 1;

if sum(strcmpi(varargin{1},{'description', 'time', 'iteration', 'memory', 'period'})) >= 1
    % Add param about schedule
    if mod(ni,2)
        error('Incorrect parameters number!');
    end
    for i = 1:2:ni
        switch lower(varargin{i})
            case 'description'
                TASKSET.schedule.desc = varargin{i+1};
            case 'time'
                TASKSET.schedule.time = varargin{i+1};
            case 'iteration'
                TASKSET.schedule.iterations = varargin{i+1};
            case 'memory'
                TASKSET.schedule.memory = varargin{i+1};
			case 'period'
				period = varargin{i+1};
				if length(period) == 1
					period(1:count(TASKSET)) = period;
				end
				for iper=1:min(length(period),count(TASKSET))
                    if isnan(period(iper))
                        continue; 
                    end
					taskforperiod = TASKSET.tasks{iper};
					%taskforperiod=set_helper(taskforperiod,'schPeriod',period(i));
					eval(['taskforperiod='	class(taskforperiod) '(taskforperiod,' char(39) 'schPeriod' char(39) 	',period(iper));']); 
					TASKSET.tasks{iper} = taskforperiod;
				end
            otherwise
                error('Unknow keyword!');
        end
    end
else
    % Add schedule
    TASKSET.schedule.desc = varargin{1};

    if ni >= 3
        start = varargin{2};
        if  isa(start,'double')
            start = num2cell(varargin{2});
        end
        lenght = varargin{3};
        if isa(lenght,'double')
            lenght = num2cell(varargin{3});
        end

        if ni >= 4
            procesor = varargin{4};
            if isa(procesor,'double')
                procesor = num2cell(varargin{4});
            end          
        end
        for i=1:size(start,2)
            if exist('procesor','var'),
                procesor_for_task = procesor{i};
            else
                procesor_for_task = 1;
            end
            TASKSET.tasks{i}=add_scht(TASKSET.tasks{i},start{i},lenght{i},procesor_for_task);
        end
    end
end

% Assign TS in caller's workspace
snname = inputname(1);
assignin('caller',snname,TASKSET)

%end .. @taskset/add_schedule

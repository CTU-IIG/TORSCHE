function [TS, varargout] = sort(TS,varargin)
%SORT  return sorted set of tasks over selected parameter.
%
% Synopsis
%    TS = SORT(TS,parameter[,tendency])
%    [TS,order] = SORT(TS,parameter[,tendency])
%
% Description
%    The function sorts tasks inside taskset. Input parameters are:
%      TS:
%                - Set of tasks
%      parameter:
%                - the propety for sorting ('ProcTime','ReleaseTime',
%                  'Deadline','DueDate','Weight','Processor' or
%                  any vector with the same length as taskset)
%      tendency:
%                - 'inc' as increasing (default), 'dec' as decreasing
%      order:
%                - list with re-arranged order
%
%    note: 'inc' tendenci is exactly nondecreasing, and 'dec' is exactly
%          calcuated as nonincreasing
%
%    See also TASKSET/TASKSET


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


ni = length(varargin);
if ni >= 1
    if sum(strcmpi(varargin{1},{'ProcTime','ReleaseTime','Deadline','DueDate','Weight','Processor'})) | length(varargin{1})==size(TS);
        
        if sum(strcmpi(varargin{1},{'ProcTime','ReleaseTime','Deadline','DueDate','Weight','Processor'}));
            sortval = get(TS,varargin{1});    
        elseif length(varargin{1})==size(TS)
            sortval = varargin{1};
        end
    
        if ni == 2 & strcmpi(varargin{2},'dec')
            ordering = -1;
        else
            ordering = 1;
        end    
        [varnull,ordertasks]=sort(sortval.*ordering);

        TS.tasks = TS.tasks(ordertasks);
        
        % new prec matrix
        [fromtask,totask,numberofedge]=find(TS.Prec);
        TS.Prec = zeros(length(ordertasks));
        for i = 1:length(fromtask)
            TS.Prec(find(ordertasks==fromtask(i)),find(ordertasks==totask(i))) = numberofedge(i);
        end
    else
        error('Unknown parameter!?');
    end
else
    error('Parameter isn''t specified');
end

if nargout==2
    varargout{1} = ordertasks;
end
%end .. @taskset/sort

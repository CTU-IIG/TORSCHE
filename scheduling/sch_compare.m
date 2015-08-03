function status = sch_compare(S1,S2);
% SCH_COMPARE       Compare two schedules.
%
%   SCH_COMPARE(S1,S2) returns logical 1 (true) if schedules/structures
%   S1 and S2 are the same and logical 0 (false) otherwise. S1 and/or S2
%   is a structure or a taskset with schedule information.
%
%   If S1 and/or S2 is structure, it contains following fields:
%       - 'schStart':     starting time vector of tasks
%       - 'schLength':    length of tasks vector
%       - 'schProcessor': number of processor vector
%
%  See also ADD_SCHEDULE, GET_SCHEDULE.

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


% prepare input1
if isa(S1,'struct')
    sch_start_1 = S1.schStart;
    sch_length_1 = S1.schLength;
    sch_processor_1 = S1.schProcessor;
elseif isa(S1,'taskset')
    [sch_start_1,sch_length_1,sch_processor_1] = get_schedule(S1);
else
    error('Function schCompare is available only for structure or taskset variables.')
end

% prepare input2
if isa(S2,'struct')
    sch_start_2 = S2.schStart;
    sch_length_2 = S2.schLength;
    sch_processor_2 = S2.schProcessor;
elseif isa(S2,'taskset')
    [sch_start_2,sch_length_2,sch_processor_2] = get_schedule(S2);
else
    error('Function schCompare is available only for structure or taskset variables.')
end

% quick size check
if length(sch_start_1) == length(sch_start_2)
    tsize = length(sch_start_1);
else
    status = 0;
    return;
end

% compare tasksets
if isequal(sch_start_1,sch_start_2) & ...
        isequal(sch_length_1,sch_length_2) & ...
        isequal(sch_processor_1,sch_processor_2)
    status = 1;
else
    status = 0;
end

% end .. SCH_COMPARE

function [start, lenght] = edf_horn (stasks)
%EDF_horn  Compute schedule in agreement with Horn'74
%
%    [start, lenght] = EDF_HORN(stasks)
%      stasks   - set of tasks
%      start    - Cell of vectors with start times
%      lenght   - Cell of vectors with lenght time of task


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
 

rj=get(stasks,'ReleaseTime');
dl=get(stasks,'Deadline');
p=get(stasks,'ProcTime');
rj=[rj inf];

free = ones(1, size(rj,2)); % 1 - must be scheduled; inf - is scheduled

end_of_time = inf;
time_stamp = -inf;
start=[];
start_index = ones(1, size(p,2)); % TODO % Eliminate vector start_index and lenght_index
lenght=[];
lenght_index = ones(1, size(p,2));

index_min_dl_old = -1; %index runed task one step before

while min([rj(rj>time_stamp), end_of_time]) < inf;

    time_stamp = min([rj(rj>time_stamp), end_of_time]);
    
    % take away  -  whole task is scheduled
    if (index_min_dl_old>0 & (p(index_min_dl_old)==sum([lenght{index_min_dl_old}, time_stamp - start{index_min_dl_old}(start_index(index_min_dl_old)-1)])))
        lenght{index_min_dl_old}(lenght_index(index_min_dl_old)) = time_stamp - start{index_min_dl_old}(start_index(index_min_dl_old)-1);
        free(index_min_dl_old) = inf;
        end_of_time = inf;
    end        
    
    pos = find(rj.*free <= time_stamp);  % Find released tasks
    [dl_min,index_min_dl] = min(dl(pos)); % Find task width min. deadline from released tasks
    
    if (index_min_dl_old > 0 & ~isempty(dl_min) & (dl_min == free(index_min_dl_old)*dl(index_min_dl_old))) index_min_dl = index_min_dl_old; % don't preemption task if you needn't
    else index_min_dl = pos(index_min_dl); end % corection number of task in set for all dl
    
    if (size(index_min_dl,2))
        % not empty - is time for schedule
        if (index_min_dl ~= index_min_dl_old)
            % new task for schedule
            if(index_min_dl_old>0)
                % old task is preempted
                % take away
                lenght{index_min_dl_old}(lenght_index(index_min_dl_old)) = time_stamp - start{index_min_dl_old}(start_index(index_min_dl_old)-1);
                if (p(index_min_dl_old)==sum(lenght{index_min_dl_old})) 
                    free(index_min_dl_old) = inf;
                else
                    lenght_index(index_min_dl_old) = lenght_index(index_min_dl_old) + 1;                    
                end
                % set new
                start{index_min_dl}(start_index(index_min_dl)) = time_stamp;
                lenght{index_min_dl}(lenght_index(index_min_dl)) = 0;
                start_index(index_min_dl) = start_index(index_min_dl) + 1;
                
                end_of_time = time_stamp + p(index_min_dl) - sum(lenght{index_min_dl});
            else
                % new task
                % set new
                start{index_min_dl}(start_index(index_min_dl)) = time_stamp;
                lenght{index_min_dl}(lenght_index(index_min_dl)) = 0;
                start_index(index_min_dl) = start_index(index_min_dl) + 1;

                end_of_time = time_stamp + p(index_min_dl) - sum(lenght{index_min_dl});
            end
        end
    end

    if (isempty(index_min_dl)) index_min_dl_old = -inf; else index_min_dl_old = index_min_dl; end
end

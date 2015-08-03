function txt = visisparsetask(t, index1, index2)
%VISISPARSETASK generates code for given task
%
%Synopsis
% txt = visisparsetask(task, index1, index1)
%
%Description
%  txt:
%    - generated string
%  task:
%    - task object
%  index1:
%    - index of start time of task in S-Function states
%  index2:
%    - index of stop time of task in S-Function states


% Author: Roman Capek <capekr1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2957 $  $Date:: 2009-07-14 13:07:04 +0200 #$


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


userParam = t.UserParam(1);

row = 1;
ind = [];
new = 1;
txt = '';
key = 0;
for i = 1:size(userParam,2)
    s = userParam(i);
    %Separate text into lines
    if strcmp(s,sprintf('\n'));
        line = userParam(new:i);
        commentary = min(regexp(line, '%'));
        if ~isempty(commentary)
            line = sprintf('%s\n',line(1:commentary(1)-1));
        end
        new = i+1;
        %Recognize keyword
        include = strfind(line, 'repeat ');
        if size(line,2)>=4 && size(include,2)>0 && include(1) == 1
            todo = 1;
        else
            include = strfind(line, 'in ');
            if size(line,2)>=4 && size(include,2)>0 && include(1) == 1
               todo = 2;
            else
                include = strfind(line, 'divide ');
                if size(line,2)>=4 && size(include,2)>0 && include(1) == 1
                    todo = 3;
                else
                    todo = 4;
                end
            end
        end
        %Generate if condition
        switch todo
            case 1
                key = 1;
                if row ~= 1
                	txt = sprintf('%s%s\n', txt, 'end');
                end
                for k = 1:size(line,2)
                    if line(k) == 't'
                        ind = k+2;
                    end
                    if line(k) == ':'
                        ind = [ind k]; %#ok<AGROW>
                    end
                end
                start = line(ind(1):ind(2)-1);
                if isa(line(ind(1):ind(2)-1),'numeric')
                    step = line(ind(2)+1:ind(3)-1);
                else
                    step = line(ind(2)+1:ind(3)-1);
                end
                stop = line(ind(3)+1:end-1);
                str = ['if isin(x(' num2str(index1) ')+' start ',x(' num2str(index1) ')+' stop ];
                str = [str ',period,dt) && ((mod(dt-rem(x(' num2str(index1) '),period),' step ') == 0) || period == inf)']; %#ok<AGROW>
                txt = sprintf('%s%s\n', txt, str);
            case 2
                key = 1;
                if row ~= 1
                    txt = sprintf('%s%s\n', txt, 'end');
                end
                if ~isempty(strfind(line, 'endtime'))
                    str = ['if isin(x(' num2str(index2) '),x(' num2str(index2) '),period,dt)'];
                    txt = sprintf('%s%s\n', txt, str);
                else
                for k = 1:size(line,2)
                    if line(k) == 'n'
                        ind = k;
                        break
                    end
                end
                t = line(ind+2:end-1);
                str = ['if isin(x(' num2str(index1) ')+' t ',x(' num2str(index1) ')+' t ',period,dt)'];
                txt = sprintf('%s%s\n', txt, str);
                end
            case 3
                key = 1;
                if row ~= 1
                    txt = sprintf('%s%s\n', txt, 'end');
                end
                for k = 1:size(line,2)
                    if line(k) == 'e'
                        ind = k+2;
                    end
                    if line(k) == ':'
                        ind = [ind k]; %#ok<AGROW>
                    end
                end
                start = line(ind(1):ind(2)-1);
                if isa(line(ind(1):ind(2)-1),'numeric')
                    step = line(ind(2)+1:ind(3)-1);
                else
                    step = line(ind(2)+1:ind(3)-1);
                end
                stop = line(ind(3)+1:end-1);
                str = ['if isin(x(' num2str(index1) ')+' start '*(x(' num2str(index2) ')-x(' num2str(index1) '))'];
                str = [str ',x(' num2str(index1) ')+' stop '*(x(' num2str(index2) ')-x(' num2str(index1) '))']; %#ok<AGROW>
                str = [str ',period,dt)']; %#ok<AGROW>
                str = [str ' && ((mod(dt-rem(x(' num2str(index1) '),period),' step ') == 0) || period == inf)']; %#ok<AGROW>
                txt = sprintf('%s%s\n', txt, str);
           case 4
                %Copy command
                if key
                    txt = sprintf('%s\t%s', txt ,line);
                else
                    str = ['if isin(x(' num2str(index1) '),x(' num2str(index2) '),period,dt)'];
                    txt = sprintf('%s%s\n', txt, str);                   
                    txt = sprintf('%s\t%s', txt ,line);
                    txt = sprintf('%s%s\n', txt, 'end');
                    row = 0;
                end
        end
        row = row+1;
    end
end
if key
    txt = sprintf('%s%s\n', txt, 'end');
end


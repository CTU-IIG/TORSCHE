function adduserparam(TS, file)
%ADDUSERPARAM Adds code for tasks in taskset from txt file
%
%Synopsis
%  adduserparam(TS, file)
%
%Description
%  TS:
%    - taskset object
%  file:
%    - name of txt file


% Author: Roman Capek <capekr1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2958 $  $Date:: 2009-07-15 11:03:10 +0200 #$


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


if ~isa(TS, 'taskset')
    err = 'TORSCHE:invalidParameter';
    err = sprintf('%s\n%s', err, 'First parameter must of type taskset!');
    error(err) %#ok
end

fid = fopen(file);
if fid<0
    err = 'TORSCHE:invalidFile';
    error('%s\n%s', err, ['Input file ''' file ''' not found!'])
end

vartype = 'char';

while 1
    tline = fgets(fid);
    if ~ischar(tline)
        fclose(fid);
        break
    end
    tline = strtrim(tline);
    if isempty(tline)
        continue
    end
    first = tline(1);
    commentary = min(regexp(tline, '%'));
    if ~isempty(commentary)
        tline = sprintf('%s\n\n', tline(1:commentary(1)-1));
    end
    switch first
        
        %change default type
        case ':'
            vartype = tline(2:end);
        
        %comentary => do nothing
        case '%'
        
        %task number
        case '#'
            [curType, structure, ind] = parseline(tline, vartype);
            if isfinite(ind)
                taskNum = str2double(tline(2:ind-1));
            else
                taskNum = str2double(tline(2:end));
            end
            if (taskNum < 1) || (taskNum > size(TS))
                err = 'TORSCHE:parseError';
                error('%s\n%s', err, ['Task index ' num2str(taskNum) ' out of taskset range!'])
            end
            TS = addpar(TS, taskNum, structure, curType, fid);
        
        %name of task
        otherwise
            [curType, structure, ind] = parseline(tline, vartype); 
            if length(tline)>1
                if isfinite(ind)
                    taskName = tline(1:ind-1);
                else
                    taskName = tline(1:end);
                end
                UserParam = strcmp(taskName, 'UserParam');
                taskNum = 0;
                for i = 1:size(TS)
                    if strcmp(taskName, TS.tasks{i}.Name)
                        taskNum = i;
                        break;
                    end
                end
                if (taskNum == 0) && (~UserParam)
                    err = 'TORSCHE:parseError';
                    error('%s\n%s', err, ['There is no task with name ''' taskName ''' in taskset!'])
                end
                if UserParam
                    taskNum = 0;
                end
                TS = addpar(TS, taskNum, structure, curType, fid);
            end
    end
end
snname = inputname(1);
assignin('caller', snname, TS)

end

%% Add UserParam to one task or TSUserParam to taskset
function TSout = addpar(TS, taskNum, structure, vartype, fid)

str = '';
TSout = TS;

while 1
    tline = fgets(fid);
    if ~ischar(tline)
        break
    end
    tline = strtrim(tline);
    if strcmp(tline, 'endparam')
        break
    end
    str = sprintf('%s\n%s', str, tline(1:end));
end

if strcmp(vartype,'char')
    str = sprintf('%s\n', str);
    if taskNum == 0
        if isempty(structure)
            TSout.TSUserParam = str;
        else
            eval(['TSout.TSUserParam.' structure ' = str;'])
        end  
    else
        if isempty(structure)
            TSout.tasks{taskNum}.UserParam = str ;
        else
            eval(['TSout.tasks{taskNum}.UserParam.' structure ' = str;'])
        end            
    end
else
    str = strtrim(str);
    try
        eval(['con = isa(' str ',vartype);'])
    catch le
        err = 'TORSCHE:parseError';
        err = sprintf('%s\n%s\n%s\n%s', err, 'Incorrect type definition: ', str, ['is not of type ' vartype '!']);
        error('%s\n%s', err, le.message) %#ok<SPERR>
    end
    if ~con
        err = 'TORSCHE:parseError';
        err = sprintf('%s\n%s\n%s\n%s', err, 'Incorrect type definition: ', str, ['is not of type ' vartype '!']);
        error('%s\n%s', err, le.message) %#ok<SPERR>
    end
    if taskNum == 0
        if isempty(structure)
            eval(['TSout.TSUserParam = ' str ';'])            
        else
            eval(['TSout.TSUserParam.' structure ' = ' str ';'])
        end
    else
        if isempty(structure)
            eval(['TSout.tasks{taskNum}.UserParam = ' str ';'])
        else
            eval(['TSout.tasks{taskNum}.UserParam.' structure ' = ' str ';'])
        end
    end    
end

end

%% Parse one line of txt file
function [vartype, structure, ind] = parseline(tline, vartype)

ind1 = min(regexp(tline, '\.'));
ind2 = min(regexp(tline, ':'));
if ~isempty(ind2)
    vartype = tline(ind2+1:end);
else
    ind2 = inf;
end
if ~isempty(ind1)
    structure = tline(ind1+1:min(ind2-1, end));
else
    structure = [];
    ind1 = inf;
end            
ind = min(ind1, ind2);

end

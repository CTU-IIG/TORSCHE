function visiscontrolcode(file, TS, ports, VRin, dispVR, destDir)
%VISISCONTROLCODE generates code for Simulink S-Function according to given TS
%
% Synopsis
% visiscontrolcode(file, taskset, ports, VRin, dispVR, destDir)
%
% Description
%  Function has following parameters:
%  file:
%    - name of Virtual Reality file or implicit name if Virtual Reality is
%    not needed
%  taskset:
%    - taskset object with schedule or shop object
%  ports:
%    - structure with names of S-Function block ports
%  VRin:
%    - structure with inputs to Virtual Reality
%  dispVR:
%    - 1 - display VR block
%    - 0 - don't display VR block
%  destDir:
%    - directory to store generated files


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


%amount of user states
nStates = 0;
nTasks = 0;
if isa(TS,'shop')
    nJobs = size(TS.jobs,2);
    for i = 1:nJobs
        nStates = nStates + cntStates(TS.jobs{i});
        nTasks = nTasks + size(TS.jobs{i});
    end
else
    nStates = cntStates(TS);
    nTasks = size(TS);
end

%amount of inputs and outputs of S-Function and amount of according states
nOuts = 0;
nInputs = 0;
dimensionOfOuts = 0;
dimensionOfIns = 0;
for i = 1:size(ports,2)
    if ~isempty(ports(i).no)
        dimensionOfOuts = dimensionOfOuts + ports(i).no;
        nOuts = nOuts+1;
    end
    if ~isempty(ports(i).ni)
        dimensionOfIns = dimensionOfIns + ports(i).ni;
        nInputs = nInputs+1;
    end    
end
if dispVR
    fid = fopen('visisfunctionbase.m', 'r');
    if fid == -1
        err = 'TORSCHE:VISIS:invalidFile';
        error('%s\n%s', err,'S-function base file ''visisfunctionbase.m'' not found!')
    end    
else
    fid = fopen('visisfunctionbase2.m', 'r');
    if fid == -1
        err = 'TORSCHE:VISIS:invalidFile';
        error('%s\n%s', err,'S-function base file ''sfunctionbase2.m'' not found!')
    end    
end

fid2 = fopen([destDir '\S_' file(1:end-4) '.m'], 'w'); %#ok<MCMFL>
tline = fgets(fid); %#ok - jumps over one row
if dispVR
    str = ['function [sys,x0,str,ts] = S_' file(1:end-4) '(t,x,u,flag,file,sampleTime,TS,period)'];
else
    str = ['function [sys,x0,str,ts] = S_' file(1:end-4) '(t,x,u,flag,sampleTime,TS,period)'];
end
fprintf(fid2, '%s\n', str);

%%
%Define number of inputs,outputs and states
while 1
    tline = fgets(fid);
    if strcmp(tline(1:end-2),'sys = [];')
        break
    end
    if strcmp(tline(1:end-2),'sizes.NumDiscStates  = 0;')
        str = ['sizes.NumDiscStates  = ' num2str(dimensionOfOuts+nStates+3*nTasks) ';'];
        fprintf(fid2, '%s\n', str);
        str = ['sizes.NumOutputs     = ' num2str(max(1,dimensionOfOuts)) ';'];
        fprintf(fid2, '%s\n', str);
        str = ['sizes.NumInputs      = ' num2str(max(1,dimensionOfIns)) ';'];
        fprintf(fid2, '%s\n', str);
        tline = fgets(fid); %#ok - jumps over one row
        tline = fgets(fid); %#ok - jumps over one row
    else if strcmp(tline(1:end-2),'x0  = [];')
            if isa(TS,'shop')
                str = 'start = [];';
                fprintf(fid2, '%s\n', str);
                str = 'stop = [];';
                fprintf(fid2, '%s\n', str);
                str = 'proc = [];';
                fprintf(fid2, '%s\n', str);                
                str = 'for i = 1:size(TS.jobs,2)';
                fprintf(fid2, '%s\n', str);
                str = 'T = TS.jobs{i};';
                fprintf(fid2, '\t%s\n', str);
                str = '[st,len,pr] = get_schedule(T);';
                fprintf(fid2, '\t%s\n', str);
                str = 'stop = [stop st+T.ProcTime];';
                fprintf(fid2, '\t%s\n', str);
                str = 'start = [start st];';
                fprintf(fid2, '\t%s\n', str);
                str = 'proc = [proc pr];';
                fprintf(fid2, '\t%s\n', str);
                str = 'end';
                fprintf(fid2, '%s\n', str);
            else
                str = '[start,len,proc] = get_schedule(TS);';
                fprintf(fid2, '%s\n', str);
                str = 'stop = start+TS.ProcTime;';
                fprintf(fid2, '%s\n', str);
            end            
            for i = 1:size(ports,2)
                if ~isempty(ports(i).Output)
                    if size(VRin,2)>=i
                        str = [ports(i).Output ' = vrgetpar(file, ''' VRin(i).Node ''', ''' VRin(i).Variable ''');'];
                        fprintf(fid2, '%s\n', str);
                    else
                        str = [ports(i).Output ' = zeros(1,' num2str(ports(i).no) ');'];
                        fprintf(fid2, '%s\n', str);
                    end
                end
            end
            str = 'x0 = [';
            str = [str 'zeros(1,' num2str(nStates) ') ']; %#ok<AGROW>
            for i = 1:nOuts
                str = [str ports(i).Output ' ']; %#ok<AGROW>
            end            
            str = [str 'start stop proc];']; %#ok<AGROW>
            fprintf(fid2, '%s\n', str);
            if dispVR
                str = 'x0 = mdlUpdate(0,x0'',0,file,sampleTime,period,TS);';
            else
                str = 'x0 = mdlUpdate(0,x0'',0,sampleTime,period,TS);';
            end
            fprintf(fid2, '%s\n', str); 
        else
            fprintf(fid2, '%s', tline);
        end
    end
end

%%
%Write code for updating discrete states here

ind = 0;
for i = 1:size(ports,2)
    if ~isempty(ports(i).Input)
        str = [ports(i).Input ' = u(' num2str(ind+1) ':' num2str(ind+ports(i).ni) ');'];
        ind = ind+ports(i).ni;
        fprintf(fid2, '%s\n', str);
    end
end

str = 'dt = round(t/sampleTime);';
fprintf(fid2, '%s\n', str);
str = 't = dt*sampleTime;';
fprintf(fid2, '%s\n\n', str);

ind = 0;
for i = 1:size(ports,2)
    if ~isempty(ports(i).Output)
        if size(VRin,2)>=i
            str = [ports(i).Output ' = vrgetpar(file, ''' VRin(i).Node ''', ''' VRin(i).Variable ''');'];
            fprintf(fid2, '%s\n', str);
            ind = ind+ports(i).no;
        else
            str = [ports(i).Output ' = x(' num2str(ind+nStates+1) ':' num2str(ind+ports(i).no+nStates) ')'';'];
            fprintf(fid2, '%s\n', str);
            ind = ind+ports(i).no;
        end
    end
end

fprintf(fid2, '\n'); 

if isa(TS,'shop')
    for k = 1:nJobs
        curTS = TS.jobs{k};
        for i = 1:size(curTS)
            fprintf(fid2, '%s\n', ['%task ' num2str(i)]);
            tt = curTS(i);
            index1 = dimensionOfOuts + nStates + i;
            index2 = dimensionOfOuts + nStates + i + size(curTS);
            try
                str = visisparsetask(tt, index1, index2);
            catch le
                err = 'TORSCHE:VISIS:parseError';
                err = sprintf('%s\n%s', err,['Incorrect task definition - task ' num2str(i)]);
                error('%s\n%s', err, le.message) %#ok
            end
            fprintf(fid2, '%s', str);
            fprintf(fid2, '%s\n\n', ['%end of task ' num2str(i)]);
        end
    end
else
    begin = TS.TSUserParam.begin;
    if ~isempty(begin)
        fprintf(fid2, '%s\n%s\n', '%Do this every sample', begin);
    end
    for i = 1:size(TS)
        tt = TS(i);
        index1 = dimensionOfOuts + nStates + i;
        index2 = dimensionOfOuts + nStates + i + size(TS);
        fprintf(fid2, '%s\n', ['%task ' num2str(i)]);
        try
            str = visisparsetask(tt, index1, index2);
        catch le
            err = 'TORSCHE:VISIS:parseError';
            err = sprintf('%s\n%s', err,['Incorrect task definition - task ' num2str(i)]);
            error('%s\n%s', err, le.message) %#ok
        end
        fprintf(fid2, '%s', str);
        fprintf(fid2, '%s\n\n', ['%end of task ' num2str(i)]);
    end
end

str = 'sys = [';
if nStates>0
    str = [str 'x(1:' num2str(nStates) ')'' '];
end
for i = 1:nOuts
    str = [str ports(i).Output ' ']; %#ok<AGROW>
end
str = [str 'x(' num2str(dimensionOfOuts + nStates + 1) ':end)'''];
str = [str '];'];
fprintf(fid2, '%s\n', str); 

while 1
    tline = fgets(fid);
    if strcmp(tline(1:end-2),'sys = [];')
        break
    end
    fprintf(fid2, '%s', tline);    
end

%%
%Write code for updating discrete outputs here

str = ['sys = x(' num2str(nStates+1) ':' num2str(dimensionOfOuts+nStates) ');'];
fprintf(fid2, '%s\n', str); 

while 1
    tline = fgets(fid);
    if strcmp(tline(1:end-2),'sys = [];')
        break
    end
    fprintf(fid2, '%s', tline);    
end

%%
%Write code for teminating program here
str = 'sys = [];';
fprintf(fid2, '%s\n', str); 

%%
%Define isin as internal function

str = '%%';
str = sprintf('\n%s\n%s', str, '%Internal function for recognition of active tasks');
str = sprintf('%s\n%s\n', str, 'function status = isin(start, stop, period, t)');
str = sprintf('%s\n%s', str, 'if start<=t & isfinite(period)');
str = sprintf('%s\n%s', str, '    curPeriodOffset = period*floor((t-start)/period);');
str = sprintf('%s\n%s', str, '    start = start + curPeriodOffset;');
str = sprintf('%s\n%s', str, '    stop = stop + curPeriodOffset;');
str = sprintf('%s\n%s', str, 'end');
str = sprintf('%s\n%s', str, 'if t>=start && t<=stop');
str = sprintf('%s\n%s', str, '    status = 1;');
str = sprintf('%s\n%s', str, 'else');
str = sprintf('%s\n%s', str, '    status = 0;');
str = sprintf('%s\n%s', str, 'end');
fprintf(fid2, '%s\n', str);

fclose(fid);
fclose(fid2);

end %end of main function

%%
function cnt = cntStates(TS)
%Returns amount of user's states
    cnt = 0;
    userParam = '';
    for i = 1:size(TS)
        userParam = [userParam TS.tasks(i).UserParam TS.TSUserParam.begin]; %#ok<AGROW>
    end
    match = regexp(userParam, '\<x(\d+', 'match');
    for i = 1:size(match,2)
        str = cell2mat(match(i));
        num = str2double(str(3:end));
        cnt = max(cnt,num);
    end
end

function taskset2simulink(file, TS, ports, VRin, stopTime, destDir, varargin)
%TASKSET2SIMULINK creates Simulink model and S-Function code
%
%Synopsis
% taskset2simulink(file, taskset, ports, VRin, stopTime, destDir[,Property Name,Property Value])
%
%Description
%  file:
%    - name of project or Virtual Reality file
%  taskset:
%    - taskset object with schedule or shop object
%  ports:
%    - structure with names of S-Function block ports
%  VRin:
%    - structure with inputs to Virtual Reality
%  stopTime:
%    - stop time of simulink simulation
%  destDir:
%    - directory to store generated files (empty argument for current dir)
%  Property Name  : Property Value
%    - 'Sample'   : numeric sample time of Simulink simulation, default value 1
%    - 'Period'   : numeric period of repeatable tasks, without repetetion as default
%    - 'Simulink' : string with additional information
%                   'off' - if generating of simulink scheme is not needed


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


if isempty(file)
    file = 'project1    ';
    VRin = [];
    dispVR = 0;
else if strcmp(file(end-3:end), '.wrl')
        dispVR = 1;
    else
        dispVR = 0;
        file = [file '    '];
        VRin = [];
    end
end

if isempty(destDir)
    destDir = pwd;
end

if ~isdir(destDir)
    err = 'TORSCHE:VISIS:invalidParameter';
    error('%s\n%s%s%s%s', err, '''', destDir,  ''' is not a valid directory.')
end

if destDir(end) == '\'
    destDir(end) = [];
end

valid = isa(TS, 'shop') || isa(TS, 'taskset');
if ~valid    
    err = 'TORSCHE:VISIS:invalidParameter';
    error('%s\n%s', err, 'Second argument must be of type ''shop'' or ''taskset''.')
end

simulink = 1;
sampleTime = 1;
period = [];
connect = 0;

narg = size(varargin, 2);
if mod(narg, 2) > 0
    err = 'TORSCHE:VISIS:invalidParameter';
    error('%s\n%s', err, 'Additional parameters must be in pairs!')
end
for i = 1:2:narg
    if isa(varargin{1, i}, 'char')
        switch(varargin{1, i})
            case 'Sample'
                if isa(varargin{1,i+1}, 'numeric')
                    sampleTime = varargin{1, i+1};
                else
                    err = 'TORSCHE:VISIS:invalidParameter';
                    error('%s\n%s', err, 'Sample time must be numeric!')
                end
            case 'Period'
                if isa(varargin{1, i+1}, 'numeric')
                    period = varargin{1, i+1};
                else
                    err = 'TORSCHE:VISIS:invalidParameter';
                    error('%s\n%s', err, 'Period must be numeric!')
                end
            case 'Simulink'
                if strcmp(varargin{1, i+1}, 'off')
                    simulink = 0;
                else
                    err = 'TORSCHE:VISIS:invalidParameter';
                    error('%s\n%s', err, ['Unknown parameter ' varargin{1, i+1} '!'])
                end
            case 'Connect'
                if isa(varargin{1, i+1},'numeric')
                    connect = varargin{1, i+1};
                else
                    err = 'TORSCHE:VISIS:invalidParameter';
                    error('%s\n%s', err, ['Unknown parameter ' varargin{1, i+1} '!'])
                end
            otherwise
                err = 'TORSCHE:VISIS:invalidParameter';
                error('%s\n%s', err, ['Unknown parameter ' varargin{1, i} '!'])
        end
    else
        err = 'TORSCHE:VISIS:invalidParameter';
        error('%s\n%s', err, 'First parameter must be string!')
    end
end

if isempty(period)
    period = inf;
end

assignin('caller', 'sampleTime', sampleTime);
assignin('caller', 'period', period);
assignin('caller', 'TS', TS);
assignin('caller', 'file', file);

try
    visiscontrolcode(file, TS, ports, VRin, dispVR, destDir);
    display(['S-Function ''S_' file(1:end-4) '.m'' created.']);
catch le
    err = le.message;
    error(err)
end

try
    eval(['pcode ''' destDir '\S_' file(1:end-4) '.m'' -inplace'])
    eval(['delete ''' destDir '\S_' file(1:end-4) '.p'''])
catch le
    display(['Warning: S-Function ''' file(1:end-4) '.m'' seems to be corrupted']);
    disp(le.message)
    display('Press any key to continue...');
    pause();
end

if simulink
    try
        visismodel(file, stopTime, sampleTime, ports, VRin, dispVR, destDir);
    catch le
        err = le.message;
        error(err)
    end
    if connect>0
        f = file(1:end-4);
        visisconnectblocks([destDir '\' f '.mdl'], [f '_Subsystem'], f, connect);
    end
    open([destDir '\' file(1:end-4) '.mdl']);
end

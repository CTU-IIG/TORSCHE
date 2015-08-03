% DSVF_DEMO Demo application of the scheduling application in digital filtering.
%
%    See also TASKSET2SIMULINK


% Author: Roman Capek <capekr1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2955 $  $Date:: 2009-07-15 11:03:10 +0200 #$


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

clc;
clear all;

destDir = prefdir;

%Define taskset and add code for tasks
T = taskset([3 1 3 1 1 3 1 1]);
adduserparam(T,'dsvf.txt');

%Define period of tasks
period = 11;

%Set schedule
starts = [0 4 3 5 6 7 10 7];
lengths = [3 1 3 1 1 3 1 1];
processor = [2 1 2 1 1 2 1 1];
add_schedule(T, 'dsvf', starts, lengths, processor)

%Define parameters for simulation in simulink
stopTime = 1;
sampleTime = 1/220000;

%Define inputs and outputs for S-Function block
ports = visiscontrolports('Input','I',1,'Output','L',1);

%Call main function
taskset2simulink('dsvf', T, ports, [], stopTime, destDir, 'Period', period, ...
                 'Sample', sampleTime, 'Simulink', 'off');

%Open simulink model
open('dsvf.mdl')

%Start simulation
addpath(destDir)
set_param('dsvf', 'simulationcommand', 'start')


% ONEHOIST_DEMO Demo application of the hoist scheduling problem visualization.
%
%    See also TASKSET2SIMULINK


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

clc;
clear all;

destDir = prefdir;

%Minimum and maximum processing time in stages
a = [0 70 70 30];
b = [0 100 200 75];

%Empty hoist move times
C = toeplitz([0 15 20 25]);

%Loaded hoist move times
d = [36 36 36 51];

%Define taskset
T = taskset(d);
adduserparam(T,'onehoist.txt');

T.TSUserParam.SetupTime = C;
T.TSUserParam.minDistance = a;
T.TSUserParam.maxDistance = b;

schoptions = schoptionsset();

%Schedule tasks
TS = singlehoist(T,schoptions,0);

%Virutal Reality file name
name = 'onehoist.wrl';

%Define parameters for simulation in simulink
stopTime = 1039;
period = 208;

%Define inputs and outputs for S-Function block
ports = visiscontrolports('Output','T1trans',3,'T2trans',3,'T3trans',3,'T4trans',3 ...
                ,'H1trans',3,'Wrist1',3,'ArmStick1',1,'Fingers1',3,'Upper_text',3,'Pointer',3);

%Define inputs for Virtual Reality block
VRin = vrports('T1','translation','T2','translation','T3','translation','T4','translation' ...
            ,'Arm1','translation','Wrist1','translation','ArmStick1','height','Fingers1','translation' ...
            , 'Upper_text', 'translation', 'Pointer', 'translation');

%Call main function
taskset2simulink(name, TS, ports, VRin, stopTime, destDir, 'Period', period, 'Connect', size(VRin, 2));

%Start simulation
addpath(destDir)
set_param('onehoist', 'simulationcommand', 'start')
% sim([destDir '\onehoist'])

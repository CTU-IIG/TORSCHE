% LAMPS_DEMO Demo application of visualization for production line.
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

%Define taskset
T = taskset([35 8 35 4 43 15 30 35 8 35 4 43 15 30]);
for i = 1:size(T)
    T.Name{i} = ['task' num2str(i)];
end
adduserparam(T,'lamps.txt');
      
%Set schedule
add_schedule(T, 'lamps', [0 40 30 70 0 50 85 70 110 100 140 70 120 155], T.ProcTime, 1:14)

%Define Virtual Reality file
name = 'lamps.wrl';

%Define parameters for simulation in simulink
stopTime = 3000;
period = 140;

%Define inputs and outputs for S-Function block
ports = visiscontrolports('Output','ColM1',3,'ColM2',3,'ColM3',3,'T1trans',3,'T1rot',4,'T2trans',3 ... 
                ,'T2rot',4,'T3trans',3,'T3size',3,'T4trans',3,'T4rot',4,'T5trans',3 ... 
                ,'T5rot',4,'T6trans',3,'T6size',3,'Drill1',3,'Press1',3,'Press2',3 ...
                ,'Lift1',3,'Lift2',3,'Lift1size',1,'Lift2size',1,'ColKiln',3,'ColHeat',3);

%Define inputs for Virtual Reality block
VRin = vrports('ColorMachine1','diffuseColor','ColorMachine2','diffuseColor','ColorMachine3','diffuseColor'...
            ,'Task1','translation','Task1','rotation','Task2','translation','Task2','rotation' ...
            ,'Task3','translation','T3size','size','Task4','translation','Task4','rotation','Task5','translation','Task5','rotation' ...
            ,'Task6','translation','T6size','size','Drill1','translation','Press_up','translation' ...
            ,'Press_down','translation','Lift_up','translation','Lift_down','translation' ...
            ,'Lift_down_size','height','Lift_up_size','height','ColorKiln','diffuseColor','ColorHeat','diffuseColor');

%Call main function
taskset2simulink(name, T, ports, VRin, stopTime, destDir, 'Period', period, 'Connect', size(VRin, 2));

%Start simulation
addpath(destDir)
set_param('lamps', 'simulationcommand', 'start')
% sim([destDir '\lamps'])

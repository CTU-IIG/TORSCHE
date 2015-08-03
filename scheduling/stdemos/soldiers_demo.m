% SOLDIERS_DEMO Demo application of motivation example visualization.
%
%    See also TASKSET2SIMULINK

% Author: Roman Capek <capekr1@fel.cvut.cz>
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


clc;
clear all;

%Correct version
T = taskset([20 20 90 10 20]);
T = adduserparam(T,'soldiers.txt');
add_schedule(T, 'soldiers', [0 20 40 130 140], T.ProcTime)

%Slower version
% T = taskset([20 10 50 10 90]);
% T = adduserparam(T,'soldiers2.txt');
% add_schedule(T, 'soldiers', [160 90 100 150 0], T.ProcTime)

%Define Virtual Reality file
name = 'soldiers.wrl';

%Define parameters for simulation in simulink
stopTime = 20;
sample = 0.1;

%Define inputs and outputs for S-Function block
ports = visiscontrolports('Output','Soldier1',3,'Soldier2',3,'Soldier3',3,'Soldier4',3);

%Define inputs for Virtual Reality block
VRin = vrports('Soldier1','translation','Soldier2','translation', ...
             'Soldier3','translation','Soldier4','translation');

%Call main function
taskset2simulink(name, T, ports, VRin, stopTime, 'Sample', sample);

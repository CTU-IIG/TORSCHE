% ALG1SUMWJDJ_DEMO Demo application of the scheduling problem '1||sumwjDj'.
%    Example 4.3.13 - J. Blazewicz et al, Scheduling in Computer and Manufacturing
%                     Systems , Springer,2001
%
%    See also ALG1SUMUJ


% Author: Jan Zahradnik <zahraj1@fel.cvut.cz>
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
disp('Demo of scheduling algorithm for problem ''1||sumwjDj''.');
disp('------------------------------------------------------');


%define problem
prob = problem('1||sumwjDj');

%create set of tasks
T=taskset([121 79 147 83 130 102 96 88]);
T.DueDate = [260 266 269 336 337 400 683 719];
T.Weight = [3 8 1 6 3 3 5 6];
T.Name={'T1','T2','T3','T4','T5','T6','T7','T8'};

disp(' ');
disp('An instance of the scheduling problem:');
get(T)

TS = alg1sumwjdj(T, prob);

%display taskset
plot(TS);
title('Schedule obtained by algorithm alg1sumwjdj');


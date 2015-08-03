% ALG1RJCMAX_DEMO Demo application of the scheduling problem '1|rj|Cmax'.
%
%    See also ALG1RJCMAX

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
disp('Demo of scheduling algorithm for problem ''1|rj|Cmax''.');
disp('------------------------------------------------------');


%define the problem
p = problem('1|rj|Cmax');

%create set of tasks
t1=task('t1', 2, 3);
t2=task('t2', 3, 0);
t3=task('t3', 1, 4);
t4=task('t4', 2, 1);
t5=task('t5', 4, 9);
T = taskset([t1 t2 t3 t4 t5]);

%display taskset
figure(1)
subplot(2,1,1)
plot(T);
title('Tasks to be scheduled.');

disp(' ');
disp('An instance of the scheduling problem:');
get(T)

%call a scheduling algorithm
TS = alg1rjcmax(T,p);

%display results
subplot(2,1,2)
plot(TS);
title('Schedule obtained by ''alg1rjcmax'' algorithm.');

%end of file

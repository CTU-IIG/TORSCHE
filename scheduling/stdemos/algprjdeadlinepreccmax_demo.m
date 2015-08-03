% ALG1RJCMAX_DEMO Demo application of the scheduling problem 'P|rj,~dj,prec|Cmax'.
%
%    See also ALGPRJDEADLINEPRECCMAX

% Author: M. Silar
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
disp('Demo of scheduling algorithm for problem ''P|rj,~dj,prec|Cmax''.');
disp('----------------------------------------------------------------');

%create set of tasks
t1 = task('t1',4,0,4);
t2 = task('t2',2,3,12);
t3 = task('t3',1,3,11);
t4 = task('t4',6,3,10);
t5 = task('t5',4,3,12);
prec = [0 0 0 0 0;...
        0 0 0 0 0;...
        0 0 0 1 0;...
        0 0 0 0 0;...
        0 1 0 0 0];
T = taskset([t1 t2 t3 t4 t5],prec);

disp(' ');
disp('An instance of the scheduling problem:');
get(T)

%define the problem
pro= problem('P|rj,prec,~dj|Cmax');

T = algprjdeadlinepreccmax(T,pro,3);

plot(T);
title('Schedule obtained by ''algprjdeadlinepreccmax'' algorithm.');

%end of file


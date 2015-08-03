%ILINPROG_DEMO Demonstrates the universal Integer Linear Programming
%    interface ILINPROG on a simple example.
%
%    See also ILINPROG


% Author: Premysl Sucha <suchap@fel.cvut.cz>
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
disp('Integer linear programming demo.');
disp('------------------------------------------------------');
disp(' ');

disp('An example of integer linear programming problem:');
disp(' ');
disp('max 10*x1 + 6*x2 + 4*x3');
disp(' ');
disp('Subject to:');
disp('       x1 +   x2 +   x3 <= 100');
disp('    10*x1 + 4*x2 + 5*x3 <= 600');
disp('     2*x1 + 2*x2 + 6*x3 <= 300');
disp('where:');
disp('     x1>=0, x2>=0, x3>=0');
disp('     x1,x2,x3 are integer variables');
disp(' ');

c=[10,6,4]';                %objective function
A=[1,1,1;...
   10,4,5;...
   2,2,6];                  %matrix representing linear constraints
b=[100,600,300]';           %right sides for the inequality constraints
ctype=['L','L','L']';       %sense of the inequalities
lb=[0,0,0]';                %lower bounds of variables
ub=[inf inf inf]';          %upper bounds of variables
vartype=['I','I','I']';     %types of variables

schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',0);   %ILP solver options (use default values)

disp('The solution is:');
[xmin,fmin,status,extra] = ilinprog(schoptions,-1,c,A,b,ctype,lb,ub,vartype)

% end .. ILINPROG_DEMO

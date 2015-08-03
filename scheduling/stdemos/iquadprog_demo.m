%IQUADPROG_DEMO Demonstrates the universal Integer Quadratic Programming
%    interface IQUADPROG on a simple example.
%
%    See also IQUADPROG, ILINPROG


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
disp('Integer quadratic programming demo.');
disp('------------------------------------------------------');
disp(' ');

disp('An example of integer quadratic programming problem:');
disp(' ');
disp('min - x1 - 2*x2 - 3*x3 - x4');
disp('    + 0.5 ( 33*x1*x1 + 22*x2*x2 + 11*x3*x3 - 12*x1*x2 - 23*x2*x3)');
disp(' ');
disp('Subject to:');
disp('    - x1 +   x2 + x3  + 10*x4  <= 20');
disp('      x1 - 3*x2 + x3           <= 30');
disp('             x2      - 3.5*x4   =  0');
disp('where:');
disp('     0<=x1<=1, 0<=x1<=1, 0<=x1<=1, 0<=x1<=1');
disp('     x4 is a binary variable');
disp(' ');


H= [33  -6     0    0;...
    -6  22    -11.5 0;...
    0   -11.5  11   0;...
    0   0      0    0];                 %quadratic objective function
c=[-1 -2 -3 -1]';                       %linear objective function
A=[-1 1 1 10;...
    1 -3 1 0;...
    0 1 0 -3.5];                        %matrix representing linear constraints
b=[20 30 0]';                           %right sides for the inequality constraints
ctype=['L','L','E']';                   %sense of the inequalities
lb=[0; 0; 0; 0];                        % lower bound on variables
ub=[1; 1; 1; 1];                        % upper bound on variables
vartype=['C' 'C' 'C' 'B']';             % variable type

schoptions=schoptionsset('miqpSolver','miqp','solverVerbosity',0);   %ILP solver options (use default values)

disp('The solution is:');
[xmin,fmin,status,extra] = iquadprog(schoptions,1,H,c,A,b,ctype,lb,ub,vartype)


% end .. IQUADPROG_DEMO

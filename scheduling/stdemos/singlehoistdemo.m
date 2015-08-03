%SINGLEHOISTDEMO demonstrates single hoist scheduling problem.
%
%    See also SINGLEHOIST.


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
disp('Demo of single hoist scheduling algorithm.');
disp('------------------------------------------------------');

%Example:
%Phillips, L.W. and Unger, P.S. (1976) Mathematical programming
%solution of a hoist scheduling program. AIIE Transactions, 8(2),219–225.
a = [30 100 30 125];            %the minimum processing time in stage
b = [1000 110 60 130];          %the maximum processing time in stage
C = toeplitz([0 5 10 15]);      %the traveling time of the empty hoist
d = [10 10 10 20];              %the minimum time required for the hoist to move

%Another example
% a = [4 6 6];                  %the minimum processing time in stage
% b = [5 7 7];                  %the maximum processing time in stage
% C = toeplitz([0 1 2]);        %the traveling time of the empty hoist
% d = [1 1 2];                  %the minimum time required for the hoist to move

%Create taskset (d is considered as processing time)
T = taskset(d);

T.TSUserParam.SetupTime = C;
T.TSUserParam.minDistance = a;
T.TSUserParam.maxDistance = b;

schoptions = schoptionsset();

%Call the algorithm
TS = singlehoist(T,schoptions,1)

%end of file


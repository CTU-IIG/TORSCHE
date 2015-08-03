% ALGPCMAX_DEMO Demo application of the scheduling problem 'P||Cmax'.
%
%    see also ALGPCMAX

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
disp('Demo of scheduling algorithm for problem ''P||Cmax''.');
disp('------------------------------------------------------');

% Example 5.1.2 from Pinedo, Scheduling - Theory, Algorithms
%  and Systems)
T=taskset([7 7 6 6 5 5 4 4 4]);
T.Name={'T_1' 'T_2' 'T_3' 'T_4' 'T_5' 'T_6' 'T_7' 'T_8' 'T_9'};

disp(' ');
disp('An instance of the scheduling problem (example 5.1.2 - Pinedo, Scheduling, 2002):');
get(T)


%define the problem
p = problem('P||Cmax');

%call a scheduling algorithm
T = algpcmaxdp(T,p,4);

plot(T);
title('Schedule obtained by ''algpcmaxdp'' algorithm.');

%end of file

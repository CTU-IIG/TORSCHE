% HORN_DEMO Demo application of the scheduling with '1|pmtn,rj|Lmax' notation
%
%    See also HORN


% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Author: Vojtech Navratil <navrav1@fel.cvut.cz>
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
disp('Demo of scheduling algorithm for problem ''1|pmtn,rj|Lmax''.');
disp('------------------------------------------------------');

%define scheduling problem
p=problem('1|pmtn,rj|Lmax');

%create set of tasks
T = randtaskset(6, [1 10], [0 15], inf, [25 35]);

disp(' ');
disp('An instance of the scheduling problem:');
get(T)

TS = horn(T,p);
maxAxis = max(schparam(TS,'cmax'),max(get(TS,'DueDate')));

clf;
subplot(2,1,1);
title('Input set of tasks');
plot(T,'proc',0,'Axis',[0 maxAxis]);

subplot(2,1,2);
title('Schedule obtained by Horn''s algorithm');
plot(TS,'Axis',[0 maxAxis]);
%end of file

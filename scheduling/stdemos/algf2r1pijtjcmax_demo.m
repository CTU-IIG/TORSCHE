function varargout = algf2r1pijtjcmax_demo
%ALGF2R1PIJTJCMAX_DEMO Demo application of the scheduling with 'F2,R1|pij=1,tj|Cmax' notation
%
% Synopsis
%  ALGF2R1PIJTJCMAX_DEMO
%  [inputShop scheduledShop] = ALGF2R1PIJTJCMAX_DEMO
%
% Description
%  Demo shows how to solve flow-shop problems. If 2 output arguments are
%  mentioned no figure is shown. Only 2 objects are returned. inputShop - 
%  input shop including trasportrobots object and scheduledShop including 
%  shop schedule and robots schedule as well.
%
%    See also ALGF2R1PIJTJCMAX.

% Author: Lukas Hamacek
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


FROM_PROCESSOR = 1;
TO_PROCESSOR = 2;
START_TIME = 3;
ROBOT_ID = 4;
DIRECTION = 5;

PFS = [1 2; 1 2; 1 2; 1 2];
PTFS = [1 1; 1 1; 1 1; 1 1];
tr = transportrobots({[inf 3; inf inf], [inf 1; inf inf], [inf 0; inf inf], [inf 4; inf inf]});
tr.schedule = 1;
robotSchedule = zeros(4, 5);
for i = 1:4
    robotSchedule(i, FROM_PROCESSOR) = 1;
    robotSchedule(i, TO_PROCESSOR) = 2;
    robotSchedule(i, START_TIME) = 0;
    robotSchedule(i, ROBOT_ID) = i;
    robotSchedule(i, DIRECTION) = 2;
end

tr = set(tr, 'schedule', robotSchedule);
inputShop = shop(PTFS, PFS);
inputShop.type = 'F';
inputShop.robots = tr;
ts = shop2taskset(inputShop);
yax = {};
for i=1:size(ts)
	[e r t] = regexpi(ts(i).name,'^T_\{(\d+)\}_\{(\d+)\}$');
	n = char(ts(i).name);
    yax{i} = ['T' n(t{1}{1}(1,1):t{1}{1}(1,2)) n(t{1}{1}(2,1):t{1}{1}(2,2))];
end

inputProblem = problem('F2|pj=1|Cmax');
scheduledShop = algf2r1pijtjcmax(inputShop, inputProblem);
if nargout == 2
    varargout{1} = inputShop;
    varargout{2} = scheduledShop;
else
    figure('Name', 'F2,R1|pij=1,tj|Cmax algoritm demo application');
    subplot(2,2,1);
    plot(ts, 'Axname', yax, 'Axis', [-1,2]);
    title('Unscheduled jobs of the shop');
    subplot(2, 2, 2);
    plot(tr);
    title('Unscheduled transport robots');
    subplot(2, 2, 3);
    plot(scheduledShop);
    title('Scheduled Flow-shop by F2,R1|pij=1,tj|Cmax algorithm');
    subplot(2, 2, 4);
    plot(scheduledShop.robots);
    title('Scheduled transport robots by F2,R1|pij=1,tj|Cmax algorithm');
end

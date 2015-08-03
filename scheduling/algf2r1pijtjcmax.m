function [scheduledShop] = algf2r1pijtjcmax(inputShop, inputProblem)
%ALGF2R1PIJTJCMAX Algoritm solving scheduling problem 'F2,R1|pij=1,tj|Cmax'
%
% Synopsis
%	[scheduledShop] = ALGF2R1PIJTJCMAX(inputShop, inputProblem)
%
% Description
%	Compute schedule for input shop object inputShop which includes
%	transport robot definition. inputProblem has the value of
%	'F2,R1|pij=1,tj|Cmax'.
%
% Example
%  >>PFS = [1 2; 1 2; 1 2; 1 2]; % processor dedication 
%  >>PTFS = [1 1; 1 1; 1 1; 1 1]; % task processing time
%  >>tr = transportrobots({[inf 3; inf inf], [inf 1; inf inf], [inf 0; inf inf], [inf 4; inf inf]}); 
%               % transportrobots object creation
%  >>inputShop = shop(PTFS, PFS); % shop object creation
%  >>inputShop.type = 'FS'; % shop type = flow shop
%  >>inputShop.robots = tr; % adding transport robots to the shop
%  >>inputProblem = problem('F2|pj=1|Cmax');
%  >>scheduledShop = algf2r1pijtjcmax(inputShop, inputProblem);
%  >>plot(scheduledShop); % show gantt chart of the shop and transport robots
%
% See also SHOP/SHOP SHOP/PLOT PROBLEM/PROBLEM TRANSPORTROBOTS/TRANSPORTROBOTS.


% Author: Lukas Hamacek
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2895 $  $Date:: 2009-03-18 11:24:58 +0100 #$


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


%checking parameters
if ~isa(inputShop, 'shop') || ~isa(inputProblem, 'problem')
    error('TORSCHE:shop:invalidParam', 'Invalid parameters - see help!')
end
if ~is(inputProblem, 'alpha', 'F2')
    error('TORSCHE:shop:invalidProblemType', 'Invalid parameters, problem must be F2,R1|pij=1,tj|Cmax - see help!')
end
for i=1:max(size(inputShop.jobs))
    if size(inputShop.jobs(i)) ~= 2
        error('TORSCHE:shop:invalidParam', 'Each job must have 2 tasks, see help! ')
    end
end
if ~isa(inputShop.TransportRobots, 'transportrobots')
    error('TORSCHE:shop:invalidParam', 'Invalid parameters, inputShop.robots has to be a tranportrobots object - see help!')
end

FROM_PROCESSOR = 1;
TO_PROCESSOR = 2;
START_TIME = 3;
ROBOT_ID = 4;
DIRECTION = 5;

robots = inputShop.TransportRobots;
transportationTimes = get(robots, 'transportationTimes');
jobs = get(inputShop, 'jobs');
N = length(jobs);
if ~all(cellfun('length', transportationTimes) == 2) || ~all(cellfun('prodofsize', transportationTimes) == 4)
    error('TORSCHE:shop:invalidParam', 'Transportations times of robots has wrong size!');
end
for i = 1:length(transportationTimes)
    robot = transportationTimes{i};
    if robot(1, 2) == inf || robot(1, 2) < 0
        error('TORSCHE:shop:invalidParam', 'Transportation time from processor 1 to 2 of each robot has to be positive integer - see help transportrobots!');
    end
end

% dividing transport robots into two groups (zero time and non zero time)
zeroTime = cellfun('prodofsize', (cellfun(@(x) x(x(1,2)==0), transportationTimes, 'UniformOutput', false)));
zeroTimeRobots = find(zeroTime > 0);
nonZeroTimeRobots = find(zeroTime == 0);

starts1 = zeros(1, N);
starts2 = zeros(1, N);
robotSchedule = zeros(N, 5);
scheduledJobs = cell(1, N);

% scheduling non zero time robots and their jobs
for i = 1:length(nonZeroTimeRobots)
    job = jobs{nonZeroTimeRobots(i)};
    robotSchedule(nonZeroTimeRobots(i), FROM_PROCESSOR) = job.Processor(1);
    robotSchedule(nonZeroTimeRobots(i), TO_PROCESSOR) = job.Processor(2);
    if i > 1
        robot = transportationTimes{nonZeroTimeRobots(i-1)};
        robotSchedule(nonZeroTimeRobots(i), START_TIME) = robotSchedule(nonZeroTimeRobots(i-1), START_TIME) + robot(jobs{nonZeroTimeRobots(i-1)}.Processor(1), jobs{nonZeroTimeRobots(i-1)}.Processor(2));
    else
        robotSchedule(nonZeroTimeRobots(i), START_TIME) = 1;    
    end
    robot = transportationTimes{nonZeroTimeRobots(i)};
    robotSchedule(nonZeroTimeRobots(i), ROBOT_ID) = nonZeroTimeRobots(i);
    robotSchedule(nonZeroTimeRobots(i), DIRECTION) = 2;
    starts1(nonZeroTimeRobots(i)) = max(0, robotSchedule(nonZeroTimeRobots(i), START_TIME) - 1);
    starts2(nonZeroTimeRobots(i)) = robotSchedule(nonZeroTimeRobots(i), START_TIME) + robot(job.Processor(1), job.Processor(2));
end

% searching for free time slices of processor 1
freePeriods1 = zeros(1, max(starts1));
freePeriods1(starts1+1) = 1:length(starts1);
freePositions1 = find(freePeriods1 == 0);

% scheduling zero time robots and their jobs
for i = 1:length(zeroTimeRobots)
    job = jobs{zeroTimeRobots(i)};
    
    % scheduling first task of the job
    if i <= length(freePositions1)
        starts1(zeroTimeRobots(i)) = freePositions1(i) - 1;
    else
        if isempty(nonZeroTimeRobots) && i == 1
            starts1(zeroTimeRobots(i)) = 0;
        else
            starts1(zeroTimeRobots(i)) = max(starts1) + 1;
        end
    end
    
    %scheduling robot
    robotSchedule(zeroTimeRobots(i), FROM_PROCESSOR) = job.Processor(1);
    robotSchedule(zeroTimeRobots(i), TO_PROCESSOR) = job.Processor(2);
    if max(robotSchedule(:, START_TIME)) < starts1(zeroTimeRobots(i))
        robotStarts = starts1(zeroTimeRobots(i)) + 1;
    else
        robotStarts = find(robotSchedule(:, START_TIME) > starts1(zeroTimeRobots(i)));
        if ~isempty(robotStarts)
            robotStarts = robotSchedule(robotStarts(1), START_TIME);
        else
            if isempty(nonZeroTimeRobots)
                robotStarts = starts1(zeroTimeRobots(i)) + 1;
            else
                robotStarts = starts2(nonZeroTimeRobots(length(nonZeroTimeRobots)));
            end
        end
    end
    robotSchedule(zeroTimeRobots(i), START_TIME) = robotStarts;
    robotSchedule(zeroTimeRobots(i), ROBOT_ID) = zeroTimeRobots(i);
    robotSchedule(zeroTimeRobots(i), DIRECTION) = 2;

    % scheduling second task of the job
    if max(starts2) < robotStarts
        task2Starts = robotStarts;
    else
        task2Starts = find(starts2 >= robotStarts);
        if ~isempty(task2Starts)
            task2Starts = starts2(task2Starts(1)) + 1;
        else
            task2Starts = starts2(nonZeroTimeRobots(length(nonZeroTimeRobots))) + 1;
        end
    end
    
    % checking free time slice of the processor 2
    freePeriods2 = zeros(1, max(starts2) + 5);
    freePeriods2(starts2([nonZeroTimeRobots zeroTimeRobots(1:max((i-1), 0))])+1) = 1;
    freePositions2 = find(freePeriods2 == 0);
    freeIndexes2 = find(freePositions2 >= task2Starts);
    if isempty(freeIndexes2)
        starts2(zeroTimeRobots(i)) = max(max(starts2), task2Starts);
    else
        starts2(zeroTimeRobots(i)) = max(starts1(zeroTimeRobots(i)) + 1, freePositions2(freeIndexes2(1)) - 1);
    end
end

% sorting tasks on 2nd processor in the same order as processed on the 1st
% processor
[task1StartTimes task1Sequence] = sort(starts1, 'ascend');
[task2StartTimes task2Sequence] = sort(starts2, 'ascend');
starts2(task1Sequence) = starts2(task2Sequence);
for i = 1:N
    job = jobs{i};
    add_schedule(job, ['Schedule for job ' int2str(i)], [starts1(i) starts2(i)], job.ProcTime, [job.Processor(1) job.Processor(2)]);
    scheduledJobs{i} = job;
end

% writing output properties
scheduledShop = shop(scheduledJobs);
scheduledShop.schedule = 1;
robots.schedule = 1;
set(robots, 'schedule', robotSchedule);
scheduledShop.type = 'F';
scheduledShop.transportrobots = robots;

end


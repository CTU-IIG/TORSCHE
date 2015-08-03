function [S] = johnson(S,p)
%JOHNSON Computation of schedule of shop using Johnson's algorithm.
%
% Synopsis
%	sh = JOHNSON(s, p)
%
% Description
%	Compute schedule for input shop object s and problem p (F2||Cmax).
%	Output sh is shop object.
%
% Example
%  >>PT = [1 3; 4 2]; P=[1 2; 1 2];%Matrixes of processing times and dedicated processors
%  >>s = shop(PT,P); %Creation of object shop
%  >>p = problem('F2||Cmax');
%  >>s = johnson(s,p); %Computation of schedule
%  >>plot(s); %show gantt chart of the shop.
%
% See also SHOP/SHOP SHOP/PLOT PROBLEM/PROBLEM.


% Author: Jiri Cigler <ciglej1@fel.cvut.cz>
% Author: Jan Kelbel <kelbelj@fel.cvut.cz>
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
 

if isa(S,'shop') && isa(p,'problem')
	%check param
	if ~is(p,'alpha','F')
		error('TORSCHE:shop:invalidProblemType','Invalid parameters, Problem must be F2||Cmax - see help!')
	end
	for i=1:max(size(S.jobs))
		if size(S.jobs(i))~=2
			error('TORSCHE:shop:invalidJohnsonPrerequirements','Each job must have 2 tasks, See help! ')
		end
	end
	%prepare data
	jobs = [];
	for i=1:max(size(S.jobs))
		jobs(:,i)= [S.jobs(i).ProcTime i];
	end
	jobs = johnsonAlgorithm(jobs);	
	minTimeProc1 = 0;
	minTimeProc2 = 0;
	jobs;
	startTimeProc1= [];
	startTimeProc2= [];
	for i=1:size(jobs,2)
	%	S.jobs{jobs(3,i)}.ReleaseTime(1) = minTimeProc1;
	%	minTimeProc1 = minTimeProc1 + jobs(1,i);
	%	if minTimeProc2<minTimeProc1 
	%		minTimeProc2 = minTimeProc1;
	%	end
	%	S.jobs{jobs(3,i)}.ReleaseTime(2) = minTimeProc2;
	%	minTimeProc2 = minTimeProc2 + jobs(2,i);
		startTimeProc1(jobs(3,i)) = minTimeProc1;
		minTimeProc1 = minTimeProc1 + jobs(1,i);
		if minTimeProc2 <minTimeProc1
			minTimeProc2 = minTimeProc1;
		end
		startTimeProc2(jobs(3,i)) = minTimeProc2;
		minTimeProc2 = minTimeProc2 +jobs(2,i);	
	end%endfor
	st = [];
	st(:,1)=startTimeProc1;
	st(:,2)=startTimeProc2;	
	for i =1:max(size(S.jobs))
        TS = S.jobs(i);
		%add_schedule(TS,['Schedule for job ' int2str(i)],st(i,:),S.jobs(i).ProcTime,S.jobs(i).Processor	);
		add_schedule(TS,['Schedule for job ' int2str(i)],st(i,:),S.jobs(i).ProcTime,[1 	2]	);
        S.jobs(i)=TS;
    end
    
    S.type = 'F';

%	startTimeProc1
%	startTimeProc2
%	st
	S.Schedule = 1;
else
	error('TORSCHE:shop:invalidParam','Invalid parameters - see help!')
end
end



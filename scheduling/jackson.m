function S = jackson(S, p)
%JACKSON computation of schedule of shop using Jackson's algorithm.
%
% Synopsis
%	sh = JACKSON(s, p)
%
% Description
%  Compute schedule for input shop s and problem p. The output is also shop
%  object with schedule.
%
% Example
%  >>PT = [1 3; 4 2]; P=[2 1; 1 2]; %Matrices of processing times and dedicated processors
%  >>s = shop(PT,P); %Creation of object shop
%  >>p = problem('J2|nj<=2|Cmax');
%  >>s = jackson(s,p); %Computation of schedule
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
	if ~is(p,'alpha','J') || ~is(p,'betha','nj<=2')
		error('TORSCHE:shop:invalidProblemType','Invalid parameters, Problem must be J2|nj<=2|Cmax - see help!');
  end
      

	for i=1:max(size(S.jobs))
		n = max(size(S.jobs(i)));
		if n~=2 && n~=1
			error('TORSCHE:shop:invalidJohnsonPrerequirements','Each job must have 2 tasks, See help! ')
		end
	end
	
	%prepare data
	J1 = [];index1=1;
	J2 = [];index2=1;
	J12 = [];index12=1;
	J21 = [];index21=1;

	
	for i=1:max(size(S.jobs))
		if size(S.jobs(i))==1
			if S.jobs(i).Processor == 1
				J1(:,index1)= [S.jobs(i).ProcTime i];
				index1 = index1 + 1;
			elseif S.jobs(i).Processor == 2
				J2(:,index2)= [S.jobs(i).ProcTime i];
				index2 = index2 + 1;
			else
				error('TORSCHE:shop:unknownProcessor','Unknown 	processor number')
			end
		else
			if S.jobs(i).Processor(1) == 1 && S.jobs(i).Processor(2) == 2
				J12(:,index12)= [S.jobs(i).ProcTime i];
				index12 = index12 + 1;
			elseif S.jobs(i).Processor(1) == 2 && S.jobs(i).Processor(2) == 1
				J21(:,index21)= [S.jobs(i).ProcTime i];
				index21 = index21 + 1;
			
			else
				error('TORSCHE:shop:unknownProcessor',[ 'Unknown processor number ']);
			end

		end
	end
	J12 = johnsonAlgorithm(J12);
	J21 = johnsonAlgorithm(J21);
	

	minTimeProc1 = 0;
	minTimeProc2 = 0;
    start = [];
	%proc 1
 
	for i=1:size(J12,2);
%		S.jobs{J12(3,i)}.ReleaseTime(1) = minTimeProc1;
        start(J12(3,i),1) = minTimeProc1;
		minTimeProc1 = minTimeProc1 + J12(1,i);
	end

	for i=1:size(J1,2)
%		S.jobs{J1(3,i)}.ReleaseTime(1) = minTimeProc1;
        start(J1(3,i),1)= minTimeProc1;
		minTimeProc1 = minTimeProc1 + J1(1,i);
    	end
    

	%proc 2
	for i=1:size(J21,2)
		%S.jobs{J21(3,i)}.ReleaseTime(1) = minTimeProc2;
       		 start(J21(3,i),1)=minTimeProc2;
		minTimeProc2 = minTimeProc2 + J21(1,i);
	end
	for i=1:size(J2,2)
		%S.jobs{J2(3,i)}.ReleaseTime(1) = minTimeProc2;
        start(J2(3,i),1) = minTimeProc2;
		minTimeProc2 = minTimeProc2 + J2(1,i);
	end
%proc 1
	for i=1:size(J21,2)
		%t=S.jobs{J21(3,i)}.ReleaseTime(1)+S.jobs{J21(3,i)}.ProcTime(1);
        t = start(J21(3,i),1)+S.jobs(J21(3,i)).ProcTime(1);
		if  t > minTimeProc1
			minTimeProc1=t;
		end
		%S.jobs{J21(3,i)}.ReleaseTime(2) = minTimeProc1;
        start(J21(3,i),2) = minTimeProc1;
		minTimeProc1 = minTimeProc1 + J21(2,i);
	end

%proc2
	for i=1:size(J12,2)
		%t=S.jobs{J12(3,i)}.ReleaseTime(1)+S.jobs{J12(3,i)}.ProcTime(1);
        t = start(J12(3,i),1) + S.jobs(J12(3,i)).ProcTime(1);
		if  t > minTimeProc2
			minTimeProc2=t;
		end

		%S.jobs{J12(3,i)}.ReleaseTime(2) = minTimeProc2;
        start(J12(3,i),2) = minTimeProc2;
		minTimeProc2 = minTimeProc2 + J12(2,i);
    end


    for i=1:max(size(S.jobs))
           ts = S.jobs(i);
           add_schedule(ts,['Schedule of job ' int2str(i)],start(i,:),S.jobs(i).ProcTime,S.jobs(i).Processor);
           S.jobs(i)=ts;
    end

	S.Schedule = 1;
    S.type = 'J';
else
	error('TORSCHE:shop:invalidParam','Invalid parameters - see help!')
end
end



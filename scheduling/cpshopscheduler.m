function [S] = cpshopscheduler(S, p)
%CPSHOPSCHEDULER computation of schedule of shop using constraint programming technique
%
% Synopsis
%	sh = CPSHOPSCHEDULER(s, p)
%
% Description
%  Compute schedule for input shop s and problem p. The output is also shop
%  object with schedule.
%
% Example
%  >>PT = [1 3; 4 2]; P=[1 2; 2 1];%Matrices of processing times and dedicated processors
%  >>s = shop(PT,P); %Creation of object shop
%  >>p = problem('J||Cmax');
%  >>s = cps(s,p); %Computation of schedule
%  >>plot(s); %show gantt chart of the shop.
%
% See also SHOP/SHOP SHOP/PLOT PROBLEM/PROBLEM


% Author: Jiri Cigler <ciglej1@fel.cvut.cz>
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
	JS = 'J';
	FS = 'F';
	OS = 'O';
	
	processors = [];
	processingTimes = [];
	for i=1:max(size(S.jobs))
		processingTimes(i,:)=S.jobs(i).ProcTime;
		processors(i,:) = S.jobs(i).Processor;
	end
  
	r = [];
	t = [];
	if isempty(S.TransportRobots) && isempty(S.LimitedBuffers)
		if is(p,'alpha','J') && is(p,'gamma','Cmax') 
 			[r,t]=shopScheduler(processors,processingTimes,1);
%            [r,t]=shopScheduler(processors,processingTimes,1);
			S.type = JS; 
		elseif is(p,'alpha','O') && is(p,'gamma','Cmax') 

			[r,t]=shopScheduler(processors,processingTimes,2);
			S.type = OS;
		elseif is(p,'alpha','F') && is(p,'gamma','Cmax') 

            S=checkFlowShop(S);
            for i=1:max(size(S.jobs))
            	processors(i,:) = S.jobs(i).Processor;
            end
  %          processors
  
			[r,t]=shopScheduler(processors,processingTimes,3);
			S.type = FS;
		else
			error('TORSCHE:shop:invalidProblemType','Unknown problem')
			S.type = 'none';
		end
	else
	%TODO
		error('TORSCHE:shop:notImplemented','Transport robots or limited buffers are not implemented ')
	end

    add_schedule(S,'Schedule for shop problem',r,S.ProcTime,S.Processor);
    

    disp(['Schedule computed in ',int2str(t),' ms'])
else
	error('TORSCHE:shop:invalidParam','Invalid parameters - see help!')
end

end%function

function [S] =checkFlowShop(S)
% CHECKFLOWSHOP validate dedicated processors of flow-shop whether pass flow-shop
% conditions, if shop don't pass then dedicated processors are updated.
%
% Synopsis
%	shop = CHECKFLOWSHOP(S)
%
% Description
%	S	- Input shop object
%	shop	- Output shop object.
%
% See also SHOP/SHOP SHOP/CPS


    %holds information about correct processor values in shop
    incorrectFlowShop = 0;
    for i=1:(max(size(S.jobs))-1)
        for j=1:max(size(S.jobs{i}.Processor))
           if S.jobs{i}.Processor(j) ~=S.jobs{i+1}.Processor(j)
               if ~incorrectFlowShop
                   warning('TORSCHE:shop:InvalidFlowShopInputProcessors','Flow-shop should has n-th processor of each job same');
                   incorrectFlowShop = 1;
               end
           end
        end
    end
    if incorrectFlowShop
        for i=1:(max(size(S.jobs)))
            for j=1:max(size(S.jobs{i}.Processor))
                S.jobs{i}.Processor(j)=j;
            end
        end
    end
end%function

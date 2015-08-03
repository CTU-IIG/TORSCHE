function ts = shop2taskset(sh, varargin)
% SHOP2TASKSET Convert shop to one taskset (both precedence constraints
%		and shedule is not changed)
% 
% Synopsis
%  ts = SHOP2TASKSET(sh)
%  ts = SHOP2TASKSET(sh[, separateJobs])
%
%
% Description
%  Return taskset ts from shop sh. If configuration property separateJobs
%  is set to 1 function returns taskset with tasks of jobs on same
%  processor. If this property is not set or is 0 function returns taskset
%  with correct dedicated processor
%
% See also TASKSET/TASKSET, SHOP/SHOP.


% Author: Jiri Cigler <ciglej1@fel.cvut.cz>
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


    retJobsOnProc = 0;
    if nargin ==2
    	if varargin{1}==1
            retJobsOnProc =1;
        end
    end
	if isa(sh,'shop')
        ts = [];
        start = [];
        proctime = [];
        processor = [];
		switch sh.Type
			case {'F', 'J' }
				for i=1:max(size(sh.Jobs))
					job = sh.Jobs{i};
					jobSize = max(size(job));
					precMatrix(jobSize,jobSize)=0;
					for ii=1:(jobSize-1)
						precMatrix(ii,ii+1)=1;
					end;
                    if iscell(job)
                        job=job{1};
                    end
					[st,le,pr,is_sch]=get_schedule(job);

                    if i==1                       
                        start = st;
                        proctime = le;
                    	if ~retJobsOnProc
	                        processor = pr;
                        else
                        	processor = i*ones(1,max(size(sh.Jobs{1})));
                        end
                        job = taskset(job, precMatrix);
                        ts = job;
                    else
    			        start = [start st];
                                proctime = [proctime le];
            			if ~retJobsOnProc 
	                        processor = [processor pr];
                        else
            				processor = [processor 	i*ones(1,max(size(sh.Jobs{i})))];
                        end
                        job = taskset(job, precMatrix);
                        ts = [ts job];
                    end
                end
        		if sh.Schedule
                    add_schedule(ts, ['Schedule for ' sh.Type], start,proctime,processor);
                end
			case 'O'
				for i=1:max(size(sh.Jobs))
                    job = sh.Jobs{i};
                    if iscell(job)
                        job=job{1};
                    end
                    [st,le,pr,is_sch]=get_schedule(job);
                    
                    start = [start st];
                    proctime = [proctime le];
                    if ~retJobsOnProc
	                    processor = [processor pr];
                    else
                       	processor = [processor 	i*ones(1,max(size(sh.Jobs{i})))];
            		end
                    if i==1
                        ts = job;
                    else
    					ts = [ts job];
                    end
                end
        		if sh.Schedule
                    add_schedule(ts, ['Schedule for ' sh.Type], start,proctime,processor);
                end
            otherwise
				warning('TORSCHE:shop:unknownShopType','Unknown shop type - cant convert shop to taskset with correct precedence constraints');
				for i=1:max(size(sh.Jobs))
					job = sh.Jobs{i};
                    
                    [st,le,pr,is_sch]=get_schedule(job);
                    start = [start st];
                    proctime = [proctime le];
                    if ~retJobsOnProc
	                    processor = [processor pr];
                    else
                       	processor = [processor 	i*ones(1,max(size(sh.Jobs{i})))];
        		   end

                    if i==1
                        ts = job;
                    else
    					ts = [ts job];
                    end
                end
                if sh.Schedule
	                add_schedule(ts, ['Schedule for ' sh.Type], start,proctime,processor);
                end

            end


			
	else
		error('TORSCHE:shop:invalidParam','Input must be shop object, See help!');
	end;
        if isa(ts, 'job')
                ts1 = taskset(ts);
                [s,pt, proc] = get_schedule(ts);
                ts1.add_schedule([ 'Schedule for ' sh.Type],s,pt,proc);
                ts = ts1;
        end	

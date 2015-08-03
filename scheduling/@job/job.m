function varargout = job(varargin)
% JOB Creation of object job
% 
% Synopsis
%  J = JOB(TS)
%  J = JOB(processingTime, processors)
%
% Description
%  Constructor of job object has parameters:
%  - TS:
%       - Taskset with tasks that job contains
%  - processingTime:
%       - Vector 1xM containing  processing times of tasks in job.
%		M >=2 (Each job contains at least 2 tasks) 
%  - processors:
%       - Vector 1xM (same size as processingTime) containing 
%		dedicated processors for each task 
%  - J:
%       - is a JOB object
%
% See also TASK/TASK, TASKSET/TASKSET, SHOP/SHOP.


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


if nargin==3
	if isa(varargin{1},'job') && ischar(varargin{2}) 
		varargout{1} = set_helper(varargin{:});
		return;
	end
end

if nargin==2 && nargout == 2
	if isa(varargin{1},'job') && ischar(varargin{2}) 
		[varargout{1} varargout{2}] = get_helper(varargin{:});
		return;
	end
end

 
	this = struct(...
	'parent','taskset',...
	'Name','',...
	'ReleaseTime', 0, ...
	'DeadLine' , NaN, ...
	'DueDate', NaN, ...
	'Weight',1 , ...
	'Version',0.1 ...
	);
	
	parent = taskset;
	this = class(this,'job', parent);  
	
	
	
	switch nargin
	    case 1 %input is taskset
	        if isa(varargin{1},'taskset')
	            for i=1:max(size(varargin{1}))
	                this.taskset.tasks(i) = varargin{1}.tasks(i);
	            end
	        else
	            error('TORSCHE:Job:InvalidParam','Invalid parameters, see help!');
	        end
	    case 2 % inputs are procTime and processor matrices 
	        procTime = varargin{1};
	        processor = varargin{2};
	        if isvector(procTime) && isvector(processor) && isnumeric(procTime) && isnumeric(processor) && max(size(procTime))==max(size(processor))
	            for i=1:max(size(procTime))
	                t = task(procTime(i));
					t.Name = [this.Name, '_{', int2str(i), '}'];
					t.Processor = processor(i);
	                this.taskset.tasks(i) = t;
	            end
	        else
	            error('TORSCHE:Job:InvalidParam','Invalid parameters, see help!');
	        end
	            
	    otherwise
	       error('TORSCHE:Job:InvalidParam','Invalid parameters, see help!');
end%switch
    varargout{1} = this;
end


%end .. @job/job
	

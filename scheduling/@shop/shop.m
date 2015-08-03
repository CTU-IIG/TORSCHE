function varargout = shop(varargin)
% SHOP Creation of object shop
% 
% Synopsis
%  sh = SHOP(jobs)
%  sh = SHOP(jobs, robots)
%  sh = SHOP(jobs, buffers)
%  sh = SHOP(jobs, robots, buffers)
%  sh = SHOP(processingTime, processors)
%
% Description
%  Constructor of shop object has parameters:
%  - jobs:
%       - Cell of job objects
%  - robots:
%       - Transport robots object 
%  - buffers:
%       - Limited buffers object
%  - processingTime:
%       - Matrix NxM containing  processing times of task in jobs.
%		Each row of the matrix means one job, column means task of job. 
%		M >=2 (Each job contains at least 2 tasks) 
%  - processors:
%       - Matrix NxM (same size as processingTime) containing 
%		dedicated processors for each task 
%  - shop:
%       - is a SHOP object
%
% See also JOB/JOB, LIMITEDBUFFERS/LIMITEDBUFFERS, TRANSPORTROBOTS/TRANSPORTROBOTS.


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
	if isa(varargin{1},'shop') && ischar(varargin{2}) 
		varargout{1} = set_helper(varargin{:});
		return;
	end
end

if nargin==2 && nargout == 2
	if isa(varargin{1},'shop') && ischar(varargin{2}) 
		[varargout{1} varargout{2}] = get_helper(varargin{:});
		return;
	end
end

 
s.Jobs=[];
s.TransportRobots = [];
s.LimitedBuffers = [];
s.Schedule = 0;%Information whether schedule was computed.
s.Type = 'none';
s.parent = 'schedobj';
parent = schedobj;

%%2 inputs(matrixes proc time and processors)
if nargin == 2
	if isnumeric(varargin{1}) && isnumeric(varargin{2})
		jobs = size(varargin{1},1);
		tasksInJob = size(varargin{1},2);
		if jobs~=size(varargin{2},1) || tasksInJob~= size(varargin{2},2)
			error('TORSCHE:shop:invalidParam','Input must be cell of tasksets or 2 matrixes of same size, See help!');
		end
		if tasksInJob==1
			error('TORSCHE:shop:invalidParam','Each job must contain at least 2 tasks');
		end

		for i=1:jobs
			s.Jobs{i}=job(varargin{1}(i,:),varargin{2}(i,:));
			s.Jobs{i}.Name = ['T_{' int2str(i) '}'];
		end	
		
		s = class(s,'shop',parent);
         varargout{1} = s;
		return
	end
end

%%input is cell of jobs..
	if nargin==1 || nargin==2 || nargin==3
		ts = varargin{1};
		if iscell(ts)
			if isa(ts{1}, 'job')
		       		s.Jobs = ts;
			else
				error('TORSCHE:shop:invalidParam','First parameter must be cell of tasksets, See help!');
			end;	
		else
			error('TORSCHE:shop:invalidParam','First parameter must be cell of tasksets');

		end;
	end;
	%.. with transport robots xor limited buffers
	if  nargin==2 || nargin==3
		if(isa(varargin{2},'limitedbuffers'))
			s.LimitedBuffers = varargin{2};
		elseif isa(varargin{2},'transportrobots')
			s.TransportRobots = varargin{2};
		else
			error('TORSCHE:shop:invalidParam','Second parametr must be type transportrobots or limitedbuffers. See help!');
		end;
	end;
	%..with transport robots and limited buffers
	if nargin==3
		if(isa(varargin{3},'limitedbuffers'))
			s.LimitedBuffers = varargin{3};
		elseif isa(varargin{3},'transportrobots')
			s.TransportRobots = varargin{3};
		else
			error('TORSCHE:shop:invalidParam','Third parametr must be type transportrobots or limitedbuffers. See help!');
		end;
	end;
	if nargin~=1 && nargin ~=2 && nargin ~=3
		error('TORSCHE:shop:invalidParam','Bad parameters, See help!');

	end

s = class(s,'shop',parent);
 varargout{1} = s;
end

%end @shop/shop

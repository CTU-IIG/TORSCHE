function add_schedule (S, varargin)
%ADD_SCHEDULE adds schedule (start times) for a shop 
%
%Synopsis
% ADD_SCHEDULE(S, description[, start, length[, processor]])
% ADD_SCHEDULE(S, keyword1, param1, ..., keywordn, paramn)
%
%Description
% Properties:
%  S:
%   - shop; schedule will be save into this shop.
%  description:
%   - description for schedule. It must be diferent than a keywords below!
%  start:
%   - matrix containing start times (size is NxM)
%  lenght:
%   - matrix NxM -  lenght of task
%  processor:
%   - matrix NxM 
%  keyword:
%   - keyword (char)
%  param:
%   - parameter
%
% Available keywords are:
%   description:
%     - schedule description (it is same as above)
%   time:
%     - calculation time for search schedule
%   iteration:
%     - number of interations for search schedule
%   memory:
%     - memory allocation during schedule search
%   period:
%     - taskset period - scalar or vector for diferent period of each task
%
% See also SHOP/SHOP


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


ni = nargin-1;
if size(varargin,2)<1
    error('TORSCHE:shop:invalidParam','Invalid param');
end
if sum(strcmpi(varargin{1},{'description', 'time', 'iteration', 'memory', 'period'})) >= 1
	% Add param about schedule
	if mod(ni,2)
		error('Incorrect parameters number!');
	end
 
	for i=1:max(size(S.Jobs))
		TS = S.Jobs{i};
		add_schedule(TS,varargin{:});
		S.Jobs(i)=TS;
	end
else
	for i=1:max(size(S.Jobs))
		TS = S.Jobs{i};
		switch max(size(varargin))
			case {1}
				add_schedule(TS,varargin{:});
			case {3}
				start_time = varargin{2};
				length = varargin{3};
				add_schedule(TS,varargin{1},start_time(i,:),length(i,:));
			case {4}
				start_time = varargin{2};
				length = varargin{3};
				processor = varargin{4};
				add_schedule(TS,varargin{1},start_time(i,:),length(i,:),processor(i,:));
                
            otherwise
				error('TORSCHE:Shop:invalidParam','Invalid param ');
		end
		S.Jobs{i}=TS;
    end
   
   S.Schedule = 1;
end

snname = inputname(1);
assignin('caller',snname,S)

%end .. @shop/add_schedule



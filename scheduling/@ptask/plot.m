function varargout=plot(T, varargin)
%PLOT Graphics display of a periodic task
%
%Synopsis
%           PLOT(T[,keyword1,value1[,keyword2,value2[...]]])
%           PLOT(T[,CELL])
% handle = PLOT(...)
%
%Description
% Properties:
%  T:
%    - task
%  keyword:
%    - configuration parameters for plot style
%  value:
%    - configuration value
%
% Available keywords:
%  color:
%    - color of task
%  movtop:
%    - vertical position of task (array if task is preempted)
%  texton:
%    - show text description above task (defaut value is true)
%  maxTime:
%    - default 3 times task's period
%
%  PLOT returns a handle to first graphic object of task.
%
% See also TASK/GET_SCHT.


% Author: Michal Sojka <sojkam1@fel.cvut.cz>
% Author: Michal Kutil <kutilm@fel.cvut.cz>
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
 

ni = length(varargin);
if mod(ni,2) == 1
    error('Invalid count of input parameters.');
end 
i=1;
while i <= ni,
    switch lower(varargin{i})
%         case 'color'
%             colorInd=i+1;
        case 'movtop'
            movtopInd=i+1; %#ok<NASGU> line 76
        case 'texton'
            textonInd=i+1; %#ok<NASGU> line 79
        case 'maxtime'
            maxtime=varargin{i+1};
            varargin(i:i+1)=[];
            ni = ni - 2;
    end
    i=i+2;
end


if ~exist('movtopInd','var') 
    varargin = {varargin{:}, 'movtop', 0};
end
if ~exist('textonInd','var') 
    varargin = {varargin{:}, 'texton', 1};
end
if ~exist('maxtimeInd','var') 
    maxtime = 3*T.Period;
end

holding = ishold;
hold on;

time = 0;

while time <= maxtime
    args = {varargin{:} , 'timeOffset' , time};
    if (exist('handleOut','var'))
        plot(T.task, args);
    else
        handleOut=plot(T.task, args);
    end
    time = time + T.Period;
end

if ( ~holding) 
    hold off;
end

% return value
if nargout > 0
    varargout{1} = handleOut;
end
%end .. @ptask/plot

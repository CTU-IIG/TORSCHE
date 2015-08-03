function varargout=plot(T, varargin)
%PLOT graphic display of task
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
%  CELL:
%    - cell array of configuration parameters and values
%
% Available keywords:
%  color:
%    - color of task
%  movtop:
%    - vertical position of task (array if task is preempted)
%  texton:
%    - show text description above task (defaut value is true)
%  textin:
%    - show name of task inside the task (defaut value is false)
%  textins:
%    - structure with textin param detail. (see a. taskset/plot)
%  asap:
%    - show ASAP and ALAP borders (defaut value is false)
%  period:
%    - draw period mark
%  timeOffset:
%    - time offset. Offset of task's time.
%  timeMultiple:
%    - time multiple. Task's time is multiple by this value.
%
%  PLOT returns a handle to graphic object of task.
%
% See also TASK/GET_SCHT.


% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Author: Michal Sojka <sojkam1@fel.cvut.cz>
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
if ni == 1 && iscell(varargin{1})
    varargin = varargin{1};
    ni = length(varargin);
elseif mod(ni,2) == 1
    error('Invalid count of input parameters.');
end

% default values
movtop = 0;
texton = 1;
textin = 0;
asapdraw = 0;
period_draw = 1;
color = get_graphic_param(T,'color');
if ~iscolor(color)
    color='g';
end
time_ofs = 0;
timeMultiple = 1;
textins.fontsize = 12;
textins.textmovetop = 0;

i=1;
while i <= ni,
    switch lower(varargin{i})
        case 'color'
            color=varargin{i+1};
        case 'movtop'
            movtop=varargin{i+1};
        case 'texton'
            texton=varargin{i+1};
        case 'textin'
            textin=varargin{i+1};
        case 'asap'
            asapdraw=varargin{i+1};
        case 'timeofs'
            warning('TORSCHE:deprecated','Param timeofs is deprecated, use timeOffset instead.');
            time_ofs=varargin{i+1};
        case 'timeoffset'
            time_ofs=varargin{i+1};
        case 'period'
            period_draw=varargin{i+1};
        case 'timemultiple'
            timeMultiple=varargin{i+1};
        case 'textins'
            if (isstruct(varargin{i+1}))
                textins=varargin{i+1};
            end

        otherwise
            error(['Unknown parameter: ',varargin{i}]);
    end
    i=i+2;
end

start = T.ReleaseTime;
if (size(T.schStart,2))
    % Is schedule  - draw with schedule
    % Select propper part of schedule (for periodic tasks)

    %movtop full fill
    movtopfull(1:size(T.schStart,2))=movtop(1);
    movtopfull(1:size(movtop,2)) = movtop;
    movtop = movtopfull;
    
    start = T.schStart;
    len = T.schLength;
    cas_add = max(start+len);
    for i=1:size(start,2)
        handle = fill(time_ofs + timeMultiple.*[start(i) start(i)+len(i) start(i)+len(i) start(i)], ...
            [movtop(i) movtop(i) movtop(i)+0.75 movtop(i)+0.75],color);
    end
    handleOut = handle(1);
else
    % Draw without schedule
    % with ASAP

    %movtop one
    movtop=movtop(1);
    
    if (asapdraw) && ~isempty(T.ASAP)
        handleOut = fill(time_ofs + ...
            timeMultiple.*[T.ASAP T.ASAP+T.ProcTime T.ASAP+T.ProcTime T.ASAP], ...
            [movtop(1) movtop(1) movtop(1)+0.75 movtop(1)+0.75], ...
            color);
        cas_add = T.ASAP+T.ProcTime;
    else
        % without ASAP
        handleOut = fill(time_ofs + ...
            timeMultiple.*[T.ReleaseTime T.ReleaseTime+T.ProcTime T.ReleaseTime+T.ProcTime T.ReleaseTime], ...
            [movtop(1) movtop(1) movtop(1)+0.75 movtop(1)+0.75], ...
            color);
        cas_add = T.ReleaseTime+T.ProcTime;
    end
end
holding = ishold;
hold on;

handle=plot(time_ofs + timeMultiple.*[T.ReleaseTime T.ReleaseTime],[movtop(1) movtop(1)+0.9],'k^-'); % release date
try
    set(handle,'MarkerFaceColor',color);
catch
end
handle=plot(time_ofs + timeMultiple.*[T.Deadline T.Deadline],[movtop(end) movtop(end)+0.9],'kv-'); % deadline
set(handle,'MarkerFaceColor',color);
plot(time_ofs + timeMultiple.*[T.DueDate T.DueDate],[movtop(end) movtop(end)+0.9],'k-'); % duedate
if period_draw && ~isempty(T.schPeriod)
    plot(time_ofs + timeMultiple.*[T.schPeriod T.schPeriod],[movtop(1) movtop(1)+1.1],'r-'); % period
end

% range of axis x
casy=[T.ReleaseTime T.DueDate T.Deadline];
minx = time_ofs + timeMultiple.*min(casy(casy~=inf)); %min without inf
casy=[cas_add T.DueDate T.Deadline];
maxx = time_ofs + timeMultiple.*max(casy(casy~=inf)); %max without inf
for imovtop=1:length(movtop)
    plot([minx maxx],[movtop(imovtop) movtop(imovtop)],'k-'); % axis
end

% Write text
reducename = schfeval('private/tex2mtex',T.Name);
if (texton)
    hand_text = text((minx+0.2),movtop(1)+1.3,reducename);
    set(hand_text,'FontWeight','bold');
    if (T.Weight ~= 1)
        text((minx+0.2),movtop(1)+1.2, ['Weight:  ' int2str(T.Weight)]);
    end
    if (~isempty(T.Processor))
        text((minx+0.2),movtop(1)+1.1,['Processor: ' int2str(T.Processor)]);
    end
end
if (textin)
    hand_text = text(time_ofs + timeMultiple.*(T.ReleaseTime*0+0.2+start(1)),movtop(1)+0.15+textins.textmovetop,reducename);
    set(hand_text,'FontWeight','normal');
    set(hand_text,'FontSize',textins.fontsize);
end
if (asapdraw)
    if ~isempty(T.ASAP)
        plot(time_ofs + timeMultiple.*[T.ASAP T.ASAP],[movtop(1) movtop(1)+0.9],'k--'); % asap
    end
    if ~isempty(T.ALAP)
        plot(time_ofs + timeMultiple.*[T.ALAP T.ALAP],[movtop(end) movtop(end)+0.9],'k--'); % alap
    end
end

% set axis
axis auto;
ax = axis;
axis([ax(1)-1 ax(2)+1 ax(3) ax(4)+0.5]);

if ( ~holding)
    hold off;
end

% switch off y-axes
set (get(handle,'Parent'),'YTickMode','manual');
set (get(handle,'Parent'),'YTick',[]);

% label
xlabel('t');

% return value
if nargout > 0
    varargout{1} = handleOut;
end
%end .. @task/plot

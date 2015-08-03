function varargout=plot(T, varargin)
%PLOT graphic display of set of tasks
%
%Synopsis
%             PLOT(T)
%             PLOT(T[,C1,V1,C2,V2...])
%   handles = PLOT(...)
%
%Description
% Parameters:
%  T:
%    - set of tasks
%  Cx:
%    - configuration parameters for plot style
%  Vx:
%    - configuration value
%
% Properties:
%  MaxTime:
%    - ... default: LCM (least common multiple) of task periods
%  Proc:
%    - 0 - draw each task to one line
%    - 1 - draw each task to his processor
%  Color:
%    - 0 - Black & White
%    - 1 - Generate colors only for tasks without color
%    - 2 - Generate colors for all tasks 
%    - default value is 1)
%  ASAP:
%    - 0 - normal draw (default)
%    - 1 - draw tasks to their ASAP
%  Axis:
%    - [tmin tmax] set time interval for plot. Use NaN for automatic
%      setting values. (NaN is default value)
%  Prec:
%    - 0 - draw without precedens constrains
%    - 1 - draw with precedens constrains (default)
%  Period:
%    - 0 - period mark is ignored
%    - 1 - draw one period with period mark(s) (default)
%    - n - draw n periods witn n marks
%  Weight:
%    - 0 - draw tasks in current order
%    - 1 - draw tasks in order by weights
%  Reverse:
%    - 0 - draw tasks in order (top)1,2,3 .. n(bottom) (default)
%    - 1 - draw tasks in order (top)n,n-1,n-2,n-3 .. 1(bottom)
%  Axname:
%    - Cell with Y-axis name
%  Textin:
%    - show name of task inside the task. Boolean value which is defaultly
%    set automaticly by the type of plot.
%  Textins:
%    - Text-in setup, structure with 'fontsize' and 'textmovetop' fields
%  TimeOffset:
%    - time offset. Offset of task's time.
%  TimeMultiple
%    - time multiple. Task's time is multiple by this value.
%
%  PLOT returns a column vector of handles to objects, one handle per task. 
%
% See also TASKSET/TASKSET


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


%const
distance = 1.1;
height_of_block = 0.75;

ni = length(varargin);
if mod(ni,2) == 1
    error('Invalid count of input parameters.');
end

%defaut values
asapdraw = 0;
setcol = 1;
period_draw = 1;
period_number = 1;
prec_draw = 1;
axis_user = [NaN NaN];
weight_sort = 1;
reverse_order = 0;
textin = [];
textins = [];
timeMultiple = 1;
timeOffset = 0;
psgantt = 0; % Undocumneted switch to extent plot to call psgantt via gantlab (web servise call to psgantt)

i=1;
while i <= ni,
    switch lower(varargin{i})
        case 'maxtime'
            if ischar(varargin{i+1})
                max_time=str2double(varargin{i+1});
            else
                max_time=varargin{i+1};
            end
        case 'proc'
            if ischar(varargin{i+1})
                grouped=str2double(varargin{i+1});
            else
                grouped=varargin{i+1};
            end
        case 'color'
            if ischar(varargin{i+1})
                setcol=str2double(varargin{i+1});
            else
                setcol=varargin{i+1};
            end
        case 'asap'
            if ischar(varargin{i+1})
                asapdraw=str2double(varargin{i+1});
            else
                asapdraw=varargin{i+1};
            end
        case 'axis'
            if ischar(varargin{i+1})
                axis_user=str2double(varargin{i+1});
            else
                axis_user=varargin{i+1};
            end
        case 'prec'
            if ischar(varargin{i+1})
                prec_draw=str2double(varargin{i+1});
            else
                prec_draw=varargin{i+1};
            end
        case 'period'
            if ischar(varargin{i+1})
                period_number=str2double(varargin{i+1});
            else
                period_number=varargin{i+1};
            end
            period_draw = ~(period_number==0);
        case 'weight'
            if ischar(varargin{i+1})
                weight_sort=str2double(varargin{i+1});
            else
                weight_sort=varargin{i+1};
            end
        case 'reverse'
            if ischar(varargin{i+1})
                reverse_order=str2double(varargin{i+1});
            else
                reverse_order=varargin{i+1};
            end
        case 'axname'
            if ischar(varargin{i+1})
                axname=str2double(varargin{i+1});
            else
                axname=varargin{i+1};
            end
        case 'textin'
            if ischar(varargin{i+1})
                textin=str2double(varargin{i+1});
            else
                textin=varargin{i+1};
            end
        case 'textins'
            if ischar(varargin{i+1})
                textins=str2double(varargin{i+1});
            else
                textins=varargin{i+1};
            end
        case 'psgantt'
            if ischar(varargin{i+1})
                psgantt=str2double(varargin{i+1});
            else
                psgantt=varargin{i+1};
            end
        case 'timemultiple'
            if ischar(varargin{i+1})
                timeMultiple=str2double(varargin{i+1});
            else
                timeMultiple=varargin{i+1};
            end
        case 'timeoffset'
            if ischar(varargin{i+1})
                timeOffset=str2double(varargin{i+1});
            else
                timeOffset=varargin{i+1};
            end            
        otherwise
            error('Unknown parameter ''%s''',varargin{i});
    end
    i=i+2;
end

% coloring
if setcol == 0
    col = ones(length(T.tasks),3);
else
    %col = colorcube(length(T.tasks)+8);
    col = colorfromcolormap(length(T.tasks));
end
for i=1:length(T.tasks)
    taskforcolor = T.tasks{i};
    % Task defined color
    taskcolor = col(i,:);
    if setcol == 1
        taskdefininedcolor = get_graphic_param(taskforcolor,'color');
        if ~isempty(taskdefininedcolor) && iscolor(taskdefininedcolor)
            taskcolor = taskdefininedcolor;
        end
    end
    set_graphic_param(taskforcolor,'color',taskcolor)
    T.tasks{i} = taskforcolor;
end

% periodise tasks
if period_number >= 1
    period_length = schparam(T,'period');
    if length(period_length) > 1 % more than one period in taskset
        period_number = 0; %#ok<NASGU>
        period_draw = 0;
    elseif period_number > 1 && ~isempty(period_length)
        T = tsnup(T, period_number);
    end
end

if ~ishold,
    cla; %Changed from clf to cla for good work with subplot
end
holding = ishold;
hold on;

if ~exist('max_time','var')
    try % only for periodics tasks
        periods = get(T, 'Period');
        max_time = 1;
        for i=1:length(periods)
            max_time = lcm(max_time, periods(i));
        end
    catch
    end
end
if ~exist('grouped','var')
    grouped = T.schedule.is;
end

if weight_sort
    [w, ind] = sort(get(T, 'Weight'));           % draw sorted by weight
else
    ind=1:max(size(T));%for job to be able to use this function
end

% move top of task computing
mov_top{length(T.tasks)} = [];
for i=1:length(T.tasks)
    I=ind(i);
    task = T.tasks{I};
    task_struct = struct(task);

    if grouped
        if numel(task_struct.schProcessor)
            mov_top{I} = task_struct.schProcessor-1;
        else
            if numel(task_struct.Processor)
                mov_top{I} = task_struct.Processor-1;
            else
                mov_top{I} = 0;
            end
        end
    else
        mov_top{I} = (i-1);
    end
end

%TODO: Prepocitat otoceni rovnou nahore.
if (reverse_order)
    mov_top_max = 0;
    mov_top_max_rotation = 1;
else
    mov_top_max = zeros(1,length(mov_top)); %init
    for imov_top = 1:length(mov_top)
        mov_top_max(imov_top) = max(mov_top{imov_top});
    end
    mov_top_max = max(mov_top_max);
    mov_top_max_rotation = -1;
end

if isempty(textin)
    textin = grouped;
end

handleOut = zeros(length(T.tasks),1);
for i=1:length(T.tasks)
    I=ind(i);
    task = T.tasks{I};
    
    if isa(task, 'ptask')
        handleOut(i) = plot(task,'movtop',(mov_top_max+mov_top_max_rotation*mov_top{I})*distance,'texton',0,'maxtime', max_time,'textin',textin,'asap',asapdraw,'period',0,'textins',textins,'timeMultiple',timeMultiple,'timeOffset',timeOffset);
    else
        handleOut(i) = plot(task,'movtop',(mov_top_max+mov_top_max_rotation*mov_top{I})*distance,'texton',0,'textin',textin,'asap',asapdraw,'period',0,'textins',textins,'timeMultiple',timeMultiple,'timeOffset',timeOffset);
    end
end

% axis - dotted line - description
% range of axis x

axis auto;
ax = axis;

if isnan(axis_user(1))
    minx = ax(1)-1;
else
    minx = axis_user(1);
end
if isnan(axis_user(2))
    maxx = ax(2)+1;
else
    maxx = axis_user(2);
end
%axis([ax(1)-1 ax(2)+1 ax(3) ax(4)]);

if grouped
    maxy=1;
    for tasknum=1:length(T.tasks)
        [tmp_start, tmp_lenght, procnum] = get_scht(T.tasks{tasknum});
        procnum=max(procnum);
        maxy = max(maxy,procnum);
    end
else
    maxy = max(length(T.tasks),max(get(T, 'Processor')));
end

axis([minx maxx ax(3) distance*maxy]);

for I=1:maxy
    handle = plot([minx-1 maxx+1],[(I-1)*distance (I-1)*distance],'k:');
    %    t=struct(T.tasks{I});
    %    text(minx-2,0.5+(I-1)*distance,t.name);
end
set (get(handle,'Parent'),'YTickMode','manual');
set (get(handle,'Parent'),'YTick',(distance/2):distance:(distance*maxy));
if grouped
    procname{maxy}=[];
    for i = 1:maxy
        procname{i}=strcat('Processor ',num2str(i));
    end
else
    procname=schfeval('private/tex2mtex',get(T, 'Name'));
    procname=procname(ind);
end

if (exist('axname','var'))
    for ren_i = 1:min(length(axname),length(procname))
        procname{ren_i}=axname{ren_i};
    end
end

if (reverse_order==0)
    procname = rot90(rot90(procname));
end

set (get(handle,'Parent'),'YTickLabel',procname);

% Precedens constrains
if prec_draw
    if ~isempty(get(T,'prec'))
        [a,b]=find(get(T,'prec'));
        for I=1:size(a,1)
            task_from = T.tasks{a(I)};
            task_to = T.tasks{b(I)};
            task_from = struct(task_from);
            task_to = struct(task_to);
            if (size(task_from.schStart,2))
                [m,position]=max(task_from.schStart);
                x_from = max([m+task_from.schLength(position)-0.5 m+task_from.schLength(position)/2]);          %0.2
            else
                if (asapdraw) && ~isempty(task_from.ASAP)
                    x_from = max([task_from.ASAP+task_from.ProcTime-0.5 task_from.ASAP+task_from.ProcTime/2]);
                else
                    x_from = max([task_from.ReleaseTime+task_from.ProcTime-0.5 task_from.ReleaseTime+task_from.ProcTime/2]);
                end
            end
            if (size(task_to.schStart,2))
                [m,position]=min(task_to.schStart);
                x_to = min([m+0.5 m+task_to.schLength(position)/2]);
            else
                if (asapdraw) && ~isempty(task_from.ASAP)
                    x_to = min([task_to.ASAP+0.5 task_to.ASAP+task_to.ProcTime/2]);
                else
                    x_to = min([task_to.ReleaseTime+0.5 task_to.ReleaseTime+task_to.ProcTime/2]);
                end
            end
            mov_top_from=mov_top{a(I)};
            mov_top_to=mov_top{b(I)};
            y_from = distance*(mov_top_max+mov_top_max_rotation*mov_top_from(end))+height_of_block*(length(a)-I+2)/(length(a)+2);
            y_to = distance*(mov_top_max+mov_top_max_rotation*mov_top_to(1))+height_of_block*(length(a)-I+2)/(length(a)+2);

            [x,y]=schfeval('private/bezier.m',x_from,y_from,x_from+3,y_from,x_to-3,y_to,x_to,y_to);
            plot(x,y,'k',x_from,y_from,'k>',x_to,y_to,'k>');
        end
    end
end

% period mark draw
if period_draw && ~isempty(period_length)
    no_prvni_period = 0;
    for per_x=ceil(minx / period_length)*period_length:period_length:floor(maxx / period_length)*period_length
        if no_prvni_period
            plot([per_x per_x],[ax(3) distance*maxy],'r-'); % period
        else
            no_prvni_period = 1;
        end
    end
end


if (~holding)
    hold off;
end

% return value
if nargout > 0
    varargout{1} = handleOut;
end


% ----------------------------------------------------------
% psgantt
% ---------------------------------------------------------- 
if (psgantt == 1 && exist('createSoapMessage','file'))
    if (isempty(findobj('Tag','psganttmenu')))
        hpsganttmenu = uimenu('Label','&PSGantt','Tag','psganttmenu');
        uimenu(hpsganttmenu,'Label','&Classical view','Tag','psganttmenuclassical','enable','off','Callback',@psganttviewclassical);
        uimenu(hpsganttmenu,'Label','&PSGantt preview','Tag','psganttmenupreview','Callback',@psganttpreview);
        uimenu(hpsganttmenu,'Label','&Save as ...','Callback',@psganttsaveas);
        uimenu(hpsganttmenu,'Separator','On','Label','Selec&t CSS file ...','Callback',@psganttaddcss);
        uimenu(hpsganttmenu,'Label','Edit &CSS file ...','enable','off','Tag','psganttmenucssedit','Callback',@psgantteditcss);
        uimenu(hpsganttmenu,'Label','Edit &XML file ...','enable','on','Tag','psganttmenuxmledit','Callback',@psgantteditxml);
    else
        hpsganttmenu = findobj('Tag','psganttmenu');
        psganttviewclassical([],[]);
    end

    UserData.hFigure = get(findobj('Tag','psganttmenu'),'Parent');
    UserData.taskset = T;
    UserData.classicalAxes = get(UserData.hFigure,'CurrentAxes');
    UserData.classicalPosition = get(UserData.hFigure,'Position');
    UserData.pngWidth = UserData.classicalPosition(3);
    UserData.pngAxes = axes(...
        'Parent',UserData.hFigure,...
        'Tag','PNGAxes',...
        'Position',[0 0 1 1],...
        'TickLength',[0 0],...
        'XTick',[],...
        'YTick',[],...
        'Visible','off');
    UserData.css.file = '';
    UserData.xml.file = '';
    set(UserData.hFigure,'CurrentAxes',UserData.classicalAxes);
    set(UserData.hFigure,'toolbar','figure');
    set(hpsganttmenu,'UserData',UserData);
end

% ----------------------------------------------------------
function psganttviewclassical(hObject,eventData) %#ok<INUSD>
UserData = get(findobj('Tag','psganttmenu'),'UserData');
set(get(UserData.pngAxes,'Children'),'Visible','off')
set(UserData.pngAxes,'Visible','off');
set(UserData.classicalAxes,'Visible','on');
set(findobj('Tag','psganttmenuclassical'),'Enable','off');

position = get(UserData.hFigure,'Position');
UserData.classicalPosition(1) = position(1);
UserData.classicalPosition(2) = position(2) + position(4) - UserData.classicalPosition(4);
set(UserData.hFigure,'position',UserData.classicalPosition);

% ----------------------------------------------------------
function psganttpreview(hObject,eventData) %#ok<INUSD>
UserData = get(findobj('Tag','psganttmenu'),'UserData');
position = get(UserData.hFigure,'Position');
UserData.pngWidth = position(3);

% call ganttlab
try
    ganttlabResponse = callganttlab('png',num2str(UserData.pngWidth));
catch
    error_msg = lasterror;
    if (strcmp(error_msg.identifier,'TORSCHE:ganttlab:serverError'))
        error_msg = strread(error_msg.message,'%s','delimiter','');
        errordlg(char(error_msg{2:end}),'PSGantt plot: Server error');
        return;
    elseif(strcmp(error_msg.identifier,'MATLAB:Java:GenericException'))
        error_msg = strread(error_msg.message,'%s','delimiter','');
        errordlg(char(error_msg{1:end}),'PSGantt plot: XML file corrupted');
        return;
    elseif(strcmp(error_msg.identifier,'TORSCHE:MatlabXML:notinstalled'))
        error_msg = strread(error_msg.message,'%s','delimiter','');
        errordlg(char(error_msg{2:end}),'PSGantt plot: MatlabXML');
        return;
    else
        rethrow(error_msg);
    end
end

% img read
filename = tempname;
fid = fopen(filename, 'w');
fwrite(fid,ganttlabResponse);
fclose(fid);
pngimage = imread(filename);
image(pngimage,'Parent',UserData.pngAxes);

% axis change and menu enable
if strcmp(get(findobj('Tag','psganttmenuclassical'),'Enable'),'off')
    set(UserData.pngAxes,'Visible','on');
    set(UserData.classicalAxes,'Visible','off');
    set(findobj('Tag','psganttmenuclassical'),'Enable','on');
    UserData.classicalPosition = position;
end

% figure position
set(UserData.pngAxes,'xtick',[],'ytick',[],'Position',[0 0 1 1])
position(2) = position(2) + position(4) - size(pngimage,1);
position(3) = size(pngimage,2);
position(4) = size(pngimage,1);
set(UserData.hFigure,'position',position);

set(findobj('Tag','psganttmenu'),'UserData',UserData);

% ----------------------------------------------------------
function psganttsaveas(hObject,eventData) %#ok<INUSD>
try
    %server availables datatypes
    serverDataType = ganttlab('config','datatype');
catch
    % default data types if server return invalid responce
    serverDataType = {'png','png','Portable Network Graphics'};
end

% ui dialog
saveAsFilter{size(serverDataType,1),2} = [];
for i=1:size(serverDataType,1)
    saveAsFilter{i,1} = ['*.' serverDataType{i,2}];
    saveAsFilter{i,2} = [serverDataType{i,3} ' (*.' serverDataType{i,2} ')'];
end
[filename, filenamepath, filterindex] = uiputfile(saveAsFilter, 'Save as');

% call server and save
fullfilename = [filenamepath filename];
if filename
    UserData = get(findobj('Tag','psganttmenu'),'UserData');
    position = get(UserData.hFigure,'Position');
    UserData.pngWidth = position(3);

    fid = fopen(fullfilename, 'w');
    fwrite(fid,callganttlab(serverDataType{filterindex,1},num2str(UserData.pngWidth)));
    fclose(fid);
end

% ----------------------------------------------------------
function psganttaddcss(hObject,eventData) %#ok<INUSD>
[filename filenamepath] = uigetfile(...
    {'*.css','Cascading Style Sheets (*.css)';
     '*.*','All files (*.*)'}...
     ,'Select CSS');
if ~isequal(filename,0)
    filename = fullfile(filenamepath, filename);
    UserData = get(findobj('Tag','psganttmenu'),'UserData');
    UserData.css.file = filename;
    set(findobj('Tag','psganttmenu'),'UserData',UserData);
    set(findobj('Tag','psganttmenucssedit'),'Enable','on');
end

% ----------------------------------------------------------
function psgantteditcss(hObject,eventData) %#ok<INUSD>
UserData = get(findobj('Tag','psganttmenu'),'UserData');
if exist(UserData.css.file,'file')
    open(UserData.css.file);
end

% ----------------------------------------------------------
function psgantteditxml(hObject,eventData) %#ok<INUSD>
UserData = get(findobj('Tag','psganttmenu'),'UserData');
if ~exist(UserData.xml.file,'file')
    UserData.xml.file = [tempname '.xml'];
    xmlsave(UserData.xml.file,UserData.taskset);
end
if exist(UserData.xml.file,'file')
    open(UserData.xml.file);
    set(findobj('Tag','psganttmenu'),'UserData',UserData);
end

% ----------------------------------------------------------
function [ganttlabResponse] = callganttlab(datatype,width)
UserData = get(findobj('Tag','psganttmenu'),'UserData');
% Loading text
hloading=uicontrol('Style','Text','String','Loading ...','BackgroundColor',[1 0 0],'ForegroundColor',[1 1 1],'Units','Characters','Position',[0 0 11 1]);
set(hloading,'Units','Normalized');
position = get(hloading,'Position');
position(1) = 1-position(3);
position(2) = 1-position(4);
set(hloading,'Position',position);
drawnow;

% get xml
try
    if exist(UserData.xml.file,'file')
        xml_data_dom=xmlread(UserData.xml.file);
        xml_data=xmlwrite(xml_data_dom);
    else
        xml_data = xmlsave('',UserData.taskset);
    end
catch
    delete(hloading);
    rethrow(lasterror);
end

% get css
if exist(UserData.css.file,'file')
    css_data = textread(UserData.css.file,'%s','delimiter','\n','whitespace','');
    css_data = strcat(css_data{:});
else
    css_data = '';
end

% call server
try
    ganttlabResponse = ganttlab(xml_data,css_data,datatype,width);
catch
    delete(hloading);
    rethrow(lasterror);
end
delete(hloading);

%end .. @taskset/plot

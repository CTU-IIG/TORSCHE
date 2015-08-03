function noderange(varargin)

geh = graphedit;
if isempty(findobj(0,'Tag','grapheditnoderangeplugin'))
    createfigure(geh);
else
    figure(findobj(0,'Tag','grapheditnoderangeplugin'));
    return;
end

% existing node add
graphtab = findobj(geh,'Tag','grapheditgraph');
graphtab = graphtab(strcmp(get(graphtab,'Visible'),'on'));
nodes = findobj(graphtab,'Tag','grapheditnode');
for i=1:length(nodes)
     addrange(nodes(i));
end
editrange;

% new node call back
UserData = get(geh,'UserData');
UserData.('usercallbackhandlerstruct').('onnodecreate') = @cbonnodecreate;
UserData.('usercallbackhandlerstruct').('ontabchange') = @ontabchange;
UserData.('usercallbackhandlerstruct').('onclose') = @closenr;
set(geh,'UserData',UserData);

%save range
saverangesetting(findobj(0,'Tag','grapheditnoderangeplugin'));

%=================================================================        

function hFigure = createfigure(hGraphedit)
    monitor = get(0,'ScreenSize');
    grapheditPos = get(hGraphedit,'Position');
    if (grapheditPos(1)+grapheditPos(3)+140) < monitor(3)
        window = [grapheditPos(1)+grapheditPos(3)+8 grapheditPos(2) 140 grapheditPos(4)+20];
    else
        window = [monitor(3)-140 grapheditPos(2) 140 grapheditPos(4)+20];
    end
    
    hFigure = figure(...
        'Tag','grapheditnoderangeplugin',...
        'Units','Pixels',...
        'Name','Node Range',...
        'NumberTitle','off',...
        'Menubar','none',...
        'Toolbar','none',...
        'Position',window,...
        'DoubleBuffer','on',...  'Renderer','OpenGL',...
        'HandleVisibility','callback',...   'Color','white',...
        'CloseRequestFcn',@closenr,...
        'UserData',struct('geh',hGraphedit));

    hp = uipanel(...
        'Parent',hFigure,...
        'Title','Node Range',...
        'FontSize',12,...
        'Units','normalized',... 'BackgroundColor','white',...
        'Position',[.01 .01 0.98 0.98]);
    uicontrol(...
        'Parent',hp,...
        'Style','pushbutton',...
        'String','Close',...
        'Units','normalized',...
        'Position',[0 0 1 0.05],...
        'Callback',{@closenr});       
    uicontrol(...
        'Style','text',...
        'Parent',hp,...
        'Units','normalized',...
        'String','Range:',...
        'Position',[0 0.92 0.4 0.05]);
    uicontrol(...
        'Style','edit',...
        'Parent',hp,...
        'Tag','edit_range',...
        'Callback',@edit_range_Callback,...
        'Units','normalized',...
        'BackgroundColor','white',...
        'String','',...
        'Position',[0.4 0.92 0.4 0.05]);
    loadrangesetting(hFigure)
%=================================================================        
function closenr(hFigure,eventData) %#ok<INUSD>
while isempty(findobj(hFigure,'Tag','grapheditnoderangeplugin'))
    hFigure = get(hFigure,'Parent');
    if isempty(hFigure)
        return;
    end
end
hFigure=findobj(hFigure,'Tag','grapheditnoderangeplugin');
geh = graphedit;

% existing node remove
nodes = findobj(geh,'Tag','grapheditnode');
for i=1:length(nodes)
     removerange(nodes(i));
end

% new node callback
UserData = get(geh,'UserData');
UserData.('usercallbackhandlerstruct').('onnodecreate') = [];
set(geh,'UserData',UserData);

delete(hFigure);

%=================================================================        
function edit_range_Callback(hObject,eventdata) %#ok<INUSD>
user_entry = str2num(get(hObject,'string')); %#ok<ST2NM>
if isempty(user_entry)
 errordlg('You must enter a numeric value','Bad Input','modal')
 return
end
editrange;
saverangesetting(get(get(hObject,'Parent'),'Parent'));
 
    
%=================================================================        
%=================================================================        
% CB function for graph
function cbonnodecreate(geh)
UserData = get(geh,'UserData');

hnode = [];
for icanvas = 1:length(UserData.hcanvases)
  if strcmp(get(UserData.hcanvases(icanvas),'Visible'),'on')
      hnode = getfield(get(UserData.hcanvases(icanvas),'UserData'),'selected'); %#ok<GFLD>
      hnode = hnode(1);
      break;
  end
end
addrange(hnode)

function ontabchange(geh)
% existing node remove
nodes = findobj(geh,'Tag','grapheditnode');
for i=1:length(nodes)
     removerange(nodes(i));
end
% load setting
loadrangesetting(findobj(0,'Tag','grapheditnoderangeplugin'));
% existing node add
graphtab = findobj(geh,'Tag','grapheditgraph');
graphtab = graphtab(strcmp(get(graphtab,'Visible'),'on'));
nodes = findobj(graphtab,'Tag','grapheditnode');
for i=1:length(nodes)
     addrange(nodes(i));
end
editrange;


%=================================================================        

function addrange(hnode)
if ~isempty(hnode)
    % range add
    % number of nodes
    nodecount = length(findobj(get(hnode,'Parent'),'Tag','grapheditnoderange'))+1;
    range_pos = computerange(hnode,nodecount);
    if range_pos(4) == 0
        range_pos(3:4) = [1 1];
        vis = 'off';
    else
        vis = 'on';
    end
    
    rectangle(...
            'Parent',get(hnode,'Parent'),...
            'Tag','grapheditnoderange',...
            'SelectionHighlight','off',...
            'Position',range_pos,...
            'Curvature',[1 1],...
            'LineWidth',1,...
            'LineStyle','--',...
            'EdgeColor','red',... %            'UserData',struct('ParentNode',h)...
            'UserData',hnode,...
            'Visible',vis...
            );
    %callback add
    objectData = get(hnode,'UserData');
    objectData.usercallbackhandlerstruct.onmove =  @cbonnodemove;
    objectData.usercallbackhandlerstruct.onnodedelete =  @cbonnodedelete;
    set(hnode,'UserData',objectData);
end
%=================================================================
function removerange(hnode)
if ~isempty(hnode)
    % range remove
    delete(findobj('Tag','grapheditnoderange','UserData',hnode));
    
    %callback add
    objectData = get(hnode,'UserData');
    objectData.usercallbackhandlerstruct.onmove =  [];
    objectData.usercallbackhandlerstruct.onnodedelete =  [];
    set(hnode,'UserData',objectData);
end
%=================================================================        

function range_pos = computerange(hnode,nodeorder)
% node order = 0 don't change range
if nodeorder>0
    hedit_range = get(hnode,'Parent');
    while isempty(findobj(hedit_range,'Tag','edit_range'))
        hedit_range = get(hedit_range,'Parent');
    end
    edit_range = findobj(hedit_range,'Tag','edit_range');
    range = str2num(get(edit_range,'String')); %#ok<ST2NM>
    if mod(nodeorder,length(range))>0
        range = range(mod(nodeorder,length(range)));
    else
        range = range(end);
    end
else
    hrange = findobj(get(hnode,'Parent'),...
        'Tag','grapheditnoderange','UserData',hnode);
    range = get(hrange,'Position');
    range = range(4);
end

pos = get(hnode,'Position');
range_pos = pos(1:2) + pos(3:4)./2;
range_pos = range_pos-[range range]./2;
range_pos = round([range_pos  range range]);

%=================================================================        
function cbonnodemove(hnode)
set(...
    findobj('tag','grapheditnoderange','UserData',hnode),...
    'Position',computerange(hnode,0)...
    );

%=================================================================        
function cbonnodedelete(hnode)
delete(findobj('tag','grapheditnoderange','UserData',hnode));
editrange;

%=================================================================        
%=================================================================        
%=================================================================        
function editrange
graphtab = findobj(0,'Tag','grapheditgraph');
graphtab = graphtab(strcmp(get(graphtab,'Visible'),'on'));

nodes = getfield(get(graphtab,'UserData'),'nodes'); %#ok<GFLD>

for i=1:length(nodes)
    nodesr = findobj(graphtab,'Tag','grapheditnoderange','UserData',nodes(i));
    range_pos = computerange(nodesr,i);
    if range_pos(4) == 0
        set(nodesr,'Visible','off');
    else
        set(nodesr,'Visible','on');
        set(nodesr,'Position',range_pos);
    end
end

%=================================================================        
function saverangesetting(hFigure)
% save to axis
geh = getfield(get(hFigure,'UserData'),'geh'); %#ok<GFLD>

hcanvases = getfield(get(geh,'UserData'),'hcanvases'); %#ok<GFLD>
hcanvase = hcanvases(strcmp(get(hcanvases,'Visible'),'on'));
UserParam = getfield(getfield(get(hcanvase,'UserData'),'objectparams'),'UserParam'); %#ok<GFLD>
if isstruct(UserParam) || isempty(UserParam)
    UserParam.graphedit.plugin.noderange = ...
        get(findobj(hFigure,'Tag','edit_range'),'String');
    
    UserData = get(hcanvase,'UserData');
    UserData.objectparams.UserParam = UserParam;
    set(hcanvase,'UserData',UserData);
else
    error('Graph UserParam is not available for node range setting save!');
end

%=================================================================        
function loadrangesetting(hFigure)
% save to axis
geh = getfield(get(hFigure,'UserData'),'geh'); %#ok<GFLD>

hcanvases = getfield(get(geh,'UserData'),'hcanvases'); %#ok<GFLD>
hcanvase = hcanvases(strcmp(get(hcanvases,'Visible'),'on'));
UserParam = getfield(getfield(get(hcanvase,'UserData'),'objectparams'),'UserParam'); %#ok<GFLD>

try
    set(findobj(hFigure,'Tag','edit_range'),'String',...
        UserParam.graphedit.plugin.noderange);
catch
    set(findobj(hFigure,'Tag','edit_range'),'String',100);
end
   
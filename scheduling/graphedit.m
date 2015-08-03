function varargout = graphedit(varargin)
%GRAPHEDIT launch user-friendly editor of graphs able to export and import
%graphs between GUI and Matlab workspace.
%
% Synopsis
%         GRAPHEDIT(GRAPH)
%         GRAPHEDIT(GRAPH1,GRAPH2,...,GRAPHN)
%         GRAPHEDIT(sKeyWord)
%         GRAPHEDIT(KeyWord,value,...)
%     h = GRAPHEDIT(...)
%
%
% Description
%  Parameters:
%   GRAPH:
%     - object graph
%   sKeyWord:
%     - single Keyword
%         'fit'    - Fits graph to canvas;
%         'center' - Centres drown graph
%   KeyWord:
%     - Keyword
%   h:
%     - handle to the figure object (main Graphedit window)
%
% Available keywords:
%    zoom:
%      - Sets zoom to ordered value (1 == 100%)
%    viewedgesnames:
%      - Views/hides edges names (value: 'on','off')
%    viewnodesnames:
%      - Views/hides nodes names (value: 'on','off')
%    viewedgesuserparams:
%      - Views/hides edges user parameters (value: 'on','off')
%    viewnodesuserparams:
%      - Views/hides nodes user parameters (value: 'on','off')
%    viewparts:
%      - Views parts of graphedit (value: 'toolbar1','toolbar2','tabs',
%                                              'sliders','mainmenu','all')
%    hideparts:
%      - Hides parts of graphedit (value: 'toolbar1','toolbar2','tabs',
%                                              'sliders','mainmenu','all')
%    position:
%      - Sets position and size of graphedit window
%          (value: [x, y, width, height])
%    lockup:
%      - Disables any user interactions (value: 'on','off')
%    actualtab:
%      - Return index of actual tab
%    viewtab:
%      - Views graph with ordered tab (value: tab's ordinal number)
%    closetab:
%      - Closes canvas with ordered tab (value: tabs ordinal numbers)
%    createtab:
%      - Creates new canvas (value: graph object)
%    drawintab:
%      - Draws ordered graph in actual viewed tab (value: graph object)
%    importbackground:
%      - Imports picture and put it in canvas (value: picture name, cData)
%    fitbackground:
%      - Fits background image to height or width (value: 'height','widht')
%    removebackground:
%      - Removes last background image
%    propertyeditor:
%      - Views/hides property editor (value: 'on','off')
%    librarybrowser:
%      - Views/hides library browser (value: 'on','off')
%    nodedesigner:
%      - Views/hides node designer (value: 'on','off')
%    fontsizenames:
%      - Sets font size of texts Name (value: numeric value)
%    fontsizeuserparams:
%      - Sets font size of texts UsaerParam (value: numeric value)
%    arrowsvisibility:
%      - Views/hides arrows (value: 'on','off')
%    saveconfiguration:
%      - Saves actual graphedit configuration (value: '', 'filename')
%    movenode:
%      - Moves ordered nodes to required position (value: list of nodes and
%        positions (cell))
%    fit:
%      - Fits drown graph to visible canvas area
%    center:
%      - Sets drown graph to center of the visible area
%
% Example
% >>  graphedit(graph([4 3 inf; inf inf 5; 1 2 3],'Name','graph_1'))
% >>
% >>  graphedit('zoom',0.8,'viewedgesuserparams','off')
% >>
% >>  graphedit('movenode',{1, 100, 150; 2, 150, 150})
%             % moves node 1 to position [100,150] and node 2 to [150,150]
%
%
% See also GRAPH/GRAPH.


% Author: Vojtech Navratil <navrav1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2948 $  $Date:: 2009-06-02 22:00:48 +0200 #$


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



global HGRAPHEDITMAINFIGURE;
% Graphedit isn't open
if isempty(HGRAPHEDITMAINFIGURE) || ~ishandle(HGRAPHEDITMAINFIGURE)
    % task for close of nonopen graphedit graphedit
    if (nargin == 1) && (isa(varargin{1},'char')) && strcmpi(varargin{1},'close')
        return; 
    end
    % create figure
    [isOk,configurationFile] = testofworkdirectory('grapheditconfiguration.xml');
    if isOk
        HGRAPHEDITMAINFIGURE = createfigure(configurationFile,...
            launchpropertyeditor(varargin{:}));
    end
end

set(HGRAPHEDITMAINFIGURE,'handlevisibility','on');
currentFigure = get(0,'CurrentFigure');
set(0,'CurrentFigure',HGRAPHEDITMAINFIGURE);

returnValue = HGRAPHEDITMAINFIGURE;

for i = 1:nargin
    if isa(varargin{i},'graph')
        % draw graph
        set(HGRAPHEDITMAINFIGURE,'handlevisibility','on');
        hAxes = get(HGRAPHEDITMAINFIGURE,'CurrentAxes');
        if ~isempty(get(hAxes,'Children'))
            hAxes = createcanvas(HGRAPHEDITMAINFIGURE,[]);
            set(HGRAPHEDITMAINFIGURE,'CurrentAxes',hAxes);
        end
        drawobjectgraph(varargin{i},hAxes);
        set(HGRAPHEDITMAINFIGURE,'handlevisibility','callback')

    elseif isa(varargin{i},'char')
        try
            set(HGRAPHEDITMAINFIGURE,'handlevisibility','on');
            currentFigure = get(0,'CurrentFigure');
            set(0,'CurrentFigure',HGRAPHEDITMAINFIGURE);

            for j = i:2:nargin
                switch lower(varargin{j})
                    case {'pe','propertyeditor'}
                        viewpropertyeditor_command(HGRAPHEDITMAINFIGURE,varargin{j+1});
                    case {'lb','librarybrowser'}
                        viewlibrarybrowser_command(HGRAPHEDITMAINFIGURE,varargin{j+1});
                    case {'nd','nodedesigner'}
                        viewnodedesigner_command(HGRAPHEDITMAINFIGURE,varargin{j+1});

                    case {'handler'}
                        fileforhandler=fopen(varargin{j+1},'w');
                        fprintf(fileforhandler,'%d',HGRAPHEDITMAINFIGURE);
                        fclose(fileforhandler);

                    case {'center', 'graphtocenter', 'centergraph'}
                        setgraphtocenter([],[]);
                    case {'zoom','setzoom'}
                        setzoom(findobj('Tag','grapheditnewzoom'),[],varargin{j+1})
                    case {'fit','fitgraph','fitcanvas'}
                        fitgraph([],[]);
                    case {'viewedgesnames'}
                        viewtext(findobj('Tag','uimenu_viewnameedge'),[],'name','edge',findobj('Tag','contextmenu_viewnameedge'),varargin{j+1});
                    case {'viewedgesuserparams'}
                        viewtext(findobj('Tag','uimenu_viewuserparamedge'),[],'userparam','edge',findobj('Tag','contextmenu_viewuserparamedge'),varargin{j+1});
                    case {'viewnodesnames'}
                        viewtext(findobj('Tag','uimenu_viewnamenode'),[],'name','node',findobj('Tag','contextmenu_viewnamenode'),varargin{j+1});
                    case {'viewnodesuserparams'}
                        viewtext(findobj('Tag','uimenu_viewuserparamnode'),[],'userparam','node',findobj('Tag','contextmenu_viewuserparamnode'),varargin{j+1});

                    case {'viewparts'}
                        viewpartsfromcommandline(varargin{j+1},'on')
                    case {'hideparts'}
                        viewpartsfromcommandline(varargin{j+1},'off')

                    case {'position'}
                        set(gcf,'Position',varargin{j+1});
                        resizegraphedit(gcf,[]);

                    case {'lock', 'lockup'}
                        set(findobj('Tag','uimenu_lockup'),'Checked',varargin{j+1})

                    case {'viewtab','tab'}
                        try
                            selectoneflagfromcommandline(varargin{j+1});
                            returnValue = varargin{j+1};
                        catch
                            returnValue = getactualtab;
                        end
                    case {'closetab'}
                        closecanvases(varargin{j+1})
                    case {'createtab','newtab'}
                        createcanvas(gcf);
                    case {'actualtab'}
                        returnValue = getactualtab;
                    case {'drawintab'}
                        if isa(varargin{j+1},'graph'),
                            replacegraph(HGRAPHEDITMAINFIGURE,getactualtab,varargin{j+1});
                        else
                            error('The second parameter has to be graph class.');
                        end

                    case {'importbackground'},
                        if ischar(varargin{j+1}),
                            drawbackgroundimage(imread(varargin{j+1}),varargin{j+1});
                        else
                            drawbackgroundimage(varargin{j+1},'');
                        end
                    case {'fitbackground'},
                        fitbackground(varargin{j+1});
                    case {'removebackground'}
                        menu_deletebackground([],[],'lastone');

                    case {'fontsizenames', 'fontsizename'}
                        setcanvasfontsize_command(varargin{j+1},'name');
                        setfontsizecontrols('name');
                    case {'fontsizeuserparams', 'fontsizeuserparam'}
                        setcanvasfontsize_command(varargin{j+1},'userparam');
                        setfontsizecontrols('userparam');

                    case {'arrows', 'arrow', 'arrowvisibility', 'arrowsvisibility'}
                        viewedgesarrows([],[],varargin{j+1});

                    case {'saveconfiguration'}
                        saveactualconfiguration([],[],varargin{j+1});

                    case {'movenode', 'movenodes'}
                        movenodes(varargin{j+1});

                    case {'close'}
                        closegraphedit;
                        return;

                    otherwise
                        %                             text(10,10,'ahoj')
                        %                             text(0,0,'nula')
                        error('Invalid parameter.');
                end
            end
            set(HGRAPHEDITMAINFIGURE,'handlevisibility','callback');
            set(0,'CurrentFigure',currentFigure);
        catch
            set(HGRAPHEDITMAINFIGURE,'handlevisibility','callback');
            set(0,'CurrentFigure',currentFigure);
            rethrow(lasterror);
        end
        break;
    end
end
set(HGRAPHEDITMAINFIGURE,'handlevisibility','callback');
set(0,'CurrentFigure',currentFigure);

if nargout > 0,
    varargout{1} = returnValue;
end

%=================================================================
%=================================================================

function configuration = getdefaultconfigurationstructure
configuration = struct(...
    'version','1.1',...
    'viewparts',struct('toolbar1','on','toolbar2','on','tabs','on','sliders','on'),...
    'propertyeditorafterstart','off',...
    'propertyeditorwidth',180,...
    'propertyeditorfontsize',10,...
    'propertyeditoraxesheight',0.01,...2/6,...
    'propertyeditorpropertiesheight',0.99,...4/6,...
    'defaultnode',[],...
    'border',2,...
    'heighttoolbar',24,...
    'heightfigure',350,...
    'widthfigure',550,...
    'heightflag',18,...
    'widthflag',110,...
    'shapeflag',[-23 2],...
    'widthaxesbarrate',2/3,...
    'singleinstance',true,...
    'defaultgridx',20,...
    'defaultgridy',20,...
    'arrowsize',8,...
    'fontsize',struct('names',10,...
                      'userparams',10,...
                      'fontweight','bold'),...
    'textposition',struct('nodes',struct('names',[0 -15],'userparams',[0 -30]),...
                          'edges',struct('names',[0 9],'userparams',[0 -9])),...
    'edges',struct('linewidth',1,...
                   'linestyle','-',...
                   'color',[0 0 0],...
                   'viewarrows','on',...
                   'curvereduction',0.005),...
    'xmlpluginfilename',[prefdir filesep 'grapheditwork' filesep 'grapheditplugin.xml'],...
    'matlibraryfilename',[prefdir filesep 'grapheditwork' filesep 'grapheditlibrary.mat'],...
    'actualpaths',struct('pictures',pwd,...
                         'matfiles',pwd),...
    'askifreplace','on');
defaultNode = struct('x',0,'y',0,'width',30,'height',30,'curvature',[1 1],...
    'facecolor',[1 1 0],'edgecolor',[0 0 0],'linestyle','-','linewidth',1);
configuration.defaultnode = {defaultNode};

%=================================================================
%=================================================================

function launch = launchpropertyeditor(varargin)
launch = true;
for i = 1:length(varargin)-1
    if (strcmp(varargin{i},'propertyeditor') ||...
            strcmp(varargin{i},'pe')) &&...
            strcmp(varargin{i+1},'off'),
        launch = false;
        return;
    end
end

%=================================================================




%////////////////////////////////////////////////////////////////////
%/////////////////////////   Creation  //////////////////////////////
%////////////////////////////////////////////////////////////////////




%=================================================================

function hFigure = createfigure(configurationFileName,launchPropertyEditor)
% get values from configuration xml
[configuration,configurationFileName] = getgrapheditconfiguration(configurationFileName);
figureData = struct(...
    'actualnode',[],...
    'function',struct(...
        'actualnodereplace',@actualnodereplace,...
        'selectobject',@selectobject,...
        'selectoffallotherobjects',@selectoffallotherobjects),...
    'usercallbackhandlerstruct',struct(),...
    'hpropertyeditor',[],...
    'hlibrarybrowser',[],...
    'hnodedesigner',[],...
    'hcanvases',[],...
    'htabs',[],...    'Graphs',{[]},...'Toolbar',{[]},...
    'contextmenus',[],...
    'htoolbar2',[],...
    'hstatusbar',[],...
    'hsliders',[],...
    'box',[],...
    'xmlconfigurationfilename',configurationFileName,...
    'configuration',configuration);

figureData.('usercallbackhandlerstruct').('onnodecreate') = [];
figureData.('usercallbackhandlerstruct').('onactualnodechange') = []; % change node type from library
figureData.('usercallbackhandlerstruct').('onnodefocus') = [];

monitor = get(0,'ScreenSize');
%     window = [0.1*monitor(3) 0.2*monitor(4) 0.45*monitor(3) 0.5*monitor(4)];
window = [0.1*monitor(3), 0.2*monitor(4),...
    figureData.configuration.widthfigure,...
    figureData.configuration.heightfigure];

hFigure = figure(...
    'Tag','graphedit',...
    'Units','Pixels',...
    'Name','Graphedit',...
    'NumberTitle','off',...
    'Menubar','none',...
    'Toolbar','none',...
    'Position',window,...
    'DoubleBuffer','on',...  'Renderer','OpenGL',...
    'HandleVisibility','on',...
    'CreateFcn',{@createfcngraphedit},...
    'CloseRequestFcn',@closegraphedit,...
    'ResizeFcn',@resizegraphedit,...
    'KeyPressFcn',@keypressgraphedit,...
    'WindowButtonMotionFcn','',...
    'UserData',figureData);

%     if strcmp(figureData.configuration.propertyeditorafterstart,'on'),
viewpropertyeditor_command(hFigure,figureData.configuration.propertyeditorafterstart);
%     end

set(hFigure,'HandleVisibility','callback');

%=================================================================

function [configuration,fileName] = getgrapheditconfiguration(configurationFileName)
configuration = getdefaultconfigurationstructure;
if isempty(configurationFileName)
    %writing default configuration to xml file
    x = filesep;
    fileName = [prefdir x 'grapheditwork' x 'grapheditconfiguration.xml'];
    grapheditconfiguration2xml(configuration,fileName);
else
    % read configuration from configurationFileName
    fileName = configurationFileName;
    configuration = grapheditxml2configuration(configurationFileName,configuration);
    if isempty(configuration),
        %             h = warndlg(sprintf('Configuration file seems to be corrupted.\nDefault configuration will be loaded.'));
        %             set(h,'WindowStyle','modal');
        [configuration,fileName] = getgrapheditconfiguration('');
    end
end

%=================================================================






%////////////////////////////////////////////////////////////////////
%/////////////////   Graphedit callback functions ///////////////////
%////////////////////////////////////////////////////////////////////





%=================================================================

function keypressgraphedit(hFigure,eventdata)
currentCharacter = get(hFigure,'CurrentCharacter');
%    assignin('base','key',currentCharacter);
%    if isempty(eventData) || isempty(eventData.Modifier)
switch currentCharacter
    case ''  % Delete (Delete)
        structAxes = get(gca,'UserData');
        selected = structAxes.selected;
        structAxes.selected = [];
        set(gca,'UserData',structAxes);
        delete(selected);
    otherwise
end

%=================================================================

function resizegraphedit(hFigure,eventData,varargin)
figureData = get(hFigure,'UserData');
posFigure = get(hFigure,'Position');
if posFigure(3) < 200,
    posFigure(3) = 200;
end
if posFigure(4) < 80,
    posFigure(4) = 80;
end
set(hFigure,'Position',posFigure);

border = figureData.configuration.border;
height = figureData.configuration.heightflag;
heightToolbar = figureData.configuration.heighttoolbar;
widthaxesbar = figureData.configuration.widthaxesbarrate*posFigure(3);
gridx = figureData.configuration.defaultgridx;
gridy = figureData.configuration.defaultgridy;
canvasFromAbove = -2;%border;
canvasFromLeft = border-1;
canvasFromBottom = [height  height];
canvasFromRight = height-1;%+border-1;
slidersFromLeft = widthaxesbar;
tabsFromRight = posFigure(3)-widthaxesbar;

setpositiontoolbar2(figureData.htoolbar2,posFigure,heightToolbar);

if strcmp(figureData.configuration.viewparts.toolbar2,'on'),
    canvasFromAbove = heightToolbar;
end
if strcmp(figureData.configuration.viewparts.tabs,'off'),
    slidersFromLeft = border-1;
    canvasFromBottom(1) = 0;
end
if strcmp(figureData.configuration.viewparts.sliders,'off'),
    tabsFromRight = -1;
    canvasFromBottom(2) = 0;
    canvasFromRight = -2;%border-1;
end
slidersFromAbove = canvasFromAbove;

setpositionaxesbar(figureData.htabs,border,height,posFigure,canvasFromLeft,tabsFromRight);
setpositionsliders(figureData.hsliders,border,height,slidersFromAbove,slidersFromLeft,posFigure);

if nargin == 3,
    hAxes = varargin{1};
else
    hAxes = findobj('Tag','grapheditgraph','Visible','on');
end
setpositioncanvas(hAxes,border,canvasFromAbove,canvasFromLeft,...
    max(canvasFromBottom),canvasFromRight,posFigure,gridx,gridy);

%=================================================================

function closegraphedit(hFigure,eventData)
global HGRAPHEDITMAINFIGURE;
if ~exist('hFigure','var') || ~strcmp(get(hFigure,'Tag'),'graphedit')
    hFigure = findobj('Tag','graphedit');
end 
set(get(hFigure,'Children'),'DeleteFcn','');
figureData = get(hFigure,'UserData');
%     grapheditconfiguration2xml(figureData.configuration,figureData.xmlconfigurationfilename);
if ishandle(figureData.hlibrarybrowser)
    delete(figureData.hlibrarybrowser);
end
if ishandle(figureData.hnodedesigner)
    delete(figureData.hnodedesigner);
end
if ishandle(figureData.hpropertyeditor)
    delete(figureData.hpropertyeditor);
end
usercallbackcall(hFigure,'onclose');
%    set(get(findobj('Tag','grapheditgraph'),'Children'),'DeleteFcn','');
delete(hFigure);
HGRAPHEDITMAINFIGURE = [];

%=================================================================

function createfcngraphedit(hFigure,eventData)
figureData = get(hFigure,'UserData');
if ~figureData.configuration.singleinstance || closeallothergraphedits
    creategrapheditwork(hFigure);
    createmenu(hFigure,figureData.configuration);
    createtoolbar(hFigure,figureData.configuration);
    createtoolbar2(hFigure,figureData.configuration.viewparts.toolbar2);
    createcontextmenu(hFigure);
    createsliders(hFigure,figureData.configuration.viewparts.sliders);
    createtabs(hFigure,figureData.configuration.viewparts.tabs);
    createcanvas(hFigure);
end

%=================================================================

function status = closeallothergraphedits
hFigures = findobj('Tag','graphedit');
status = true;
if length(hFigures) > 1
    status = close(hFigures(2:end));
    if (status == false),  delete(hFigures(1));  end
end

%=================================================================

function creategrapheditwork(hFigure)
%     figureData = get(hFigure,'UserData');
%     if exist(figureData.configuration.matlibraryfilename,'file') ~= 2
%         workpath = [prefdir filesep 'grapheditwork'];
%         if exist(workpath,'dir') ~= 7
%             mkdir(workpath);
%             copyfile('myfun.m','d:/work/myfiles')
%         end
%
%     end

%=================================================================





%////////////////////////////////////////////////////////////////////
%//////////////////////    GUI Creation      ////////////////////////
%////////////////////////////////////////////////////////////////////





%=================================================================

function createmenu(hFigure,configuration)
file = uimenu(hFigure,'Label','&File','Tag','graphedit_menu');
uimenu(file, 'Label','&New', 'Tag','uimenu_new', 'Accelerator','N', 'Callback',{@createcanvas,hFigure});
uimenu(file, 'Label','&Open', 'Tag','uimenu_open', 'Accelerator','O', 'Callback',@opengraphfromfile);
uimenu(file, 'Label','&Save', 'Tag','uimenu_save', 'Accelerator','S', 'Callback',@savegraphtofile, 'Enable','on');
uimenu(file, 'Label','Save &As...', 'Tag','uimenu_saveas', 'Callback',@savegraphtofile, 'Enable','on');
uimenu(file, 'Label','Export to &picture...', 'Tag','uimenu_export', 'Callback',@exportcanvastopicture, 'Enable','on');
uimenu(file, 'Label','&Import from workspace', 'Tag','uimenu_import', 'Callback',@importobjectgraph, 'Separator','on');
uimenu(file, 'Label','&Export to workspace', 'Tag','uimenu_export', 'Callback',@exportobjectgraph, 'Enable','on');
uimenu(file, 'Label','&Close', 'Tag','uimenu_close', 'Callback',@closecanvas, 'Separator','on');
uimenu(file, 'Label','Close All', 'Tag','uimenu_closeall',  'Callback',@closeallcanvases);
uimenu(file, 'Label','&Quit', 'Tag','uimenu_quit',  'Accelerator','Q', 'Callback',@closegraphedit);

edit = uimenu(hFigure,'Label','&Edit','Tag','graphedit_menu');
%     uimenu(edit, 'Label','Undo', 'Callback',@undo, 'Enable','off', 'Tag','uimenu_grapheditundo','Accelerator','Z');
%     uimenu(edit, 'Label','Redo', 'Callback',@redo, 'Enable','off', 'Tag','uimenu_grapheditredo','Accelerator','Y');
%     uimenu(edit, 'Label','Cut', 'Tag','uimenu_cutcopy', 'Callback',@copynodefcn, 'Enable','off', 'Accelerator','X', 'Separator','on');
%     uimenu(edit, 'Label','Copy', 'Tag','uimenu_cutcopy', 'Callback',@copynodefcn, 'Accelerator','C', 'Enable','off');
%     uimenu(edit, 'Label','Paste', 'Tag','uimenu_paste',
%     'Callback',@pastenodefcn, 'Accelerator','V', 'Enable','off');
uimenu(edit, 'Label','Copy &Figure', 'Tag','uimenu_copyfigure', 'Callback',@copyfiguretoclipboard, 'Enable','on', 'Checked','off', 'Separator','off');
uimenu(edit, 'Label','Copy &Options ...', 'Tag','uimenu_copyfigureoptions', 'Callback',{@(h,e,c)preferences(c),'Figure Copy Template.Copy Options'}, 'Enable','on', 'Checked','off', 'Separator','off');
uimenu(edit, 'Label','&Lock up', 'Tag','uimenu_lockup', 'Callback',@lockupcanvases, 'Enable','on', 'Checked','off', 'Separator','on');

draw = uimenu(hFigure,'Label','&Draw','Tag','graphedit_menu');
uimenu(draw, 'Label','Tool &Arrow', 'Tag','uimenu_grapheditarrow', 'Callback',@drawingtype, 'Checked','on', 'Accelerator','A');
uimenu(draw, 'Label','Draw &Node', 'Tag','uimenu_grapheditdrawnode', 'Accelerator','R', 'Callback',@drawingtype, 'Checked','off', 'Separator','on');
uimenu(draw, 'Label','Draw &Edge', 'Tag','uimenu_grapheditdrawedge', 'Accelerator','E', 'Callback',@drawingtype, 'Checked','off');
uimenu(draw, 'Label','&Delete Mode', 'Tag','uimenu_grapheditdelete', 'Accelerator','D', 'Callback',@drawingtype, 'Checked','off', 'Separator','on');
%     uimenu(draw, 'Label','Layout', 'Tag','uimenu_layout', 'Callback',@newlayoutfornodes, 'Enable','on', 'Separator','on');
uimenu(draw, 'Label','Import &background', 'Tag','uimenu_background', 'Callback',@importbackgroundimage, 'Enable','on', 'Separator','on');

view = uimenu(hFigure,'Label','&View','Tag','graphedit_menu');
uimenu(view, 'Label','&Property Editor', 'Accelerator','P', 'Callback',{@viewpropertyeditor,hFigure}, 'Checked',configuration.propertyeditorafterstart,'Tag','uimenu_gepropertyeditor');
uimenu(view, 'Label','&Library Browser', 'Callback',{@viewlibrarybrowser,hFigure}, 'Checked','off','Tag','uimenu_gelibrarybrowser');
uimenu(view, 'Label','Node &Designer', 'Callback',{@viewnodedesigner,hFigure}, 'Checked','off','Tag','uimenu_genodedesigner');
uimenu(view, 'Label','View &Grid', 'Accelerator','G', 'Callback',@viewgrid2, 'Checked','off','Tag','uimenu_viewgrid', 'Separator','on');
uimenu(view, 'Label','&Attach to Grid', 'Callback',@attachtogrid2, 'Checked','off','Tag','uimenu_grapheditattachtogrid');
viewNodes = uimenu(view, 'Label','&Nodes', 'Separator','on');
uimenu(viewNodes, 'Label','View Nodes'' &Names', 'Tag','uimenu_viewnamenode', 'Callback',{@viewtext,'name','node',findobj('Tag','contextmenu_viewnamenode')}, 'Checked','on');
uimenu(viewNodes, 'Label','View Nodes'' User&Params', 'Tag','uimenu_viewuserparamnode', 'Callback',{@viewtext,'userparam','node',findobj('Tag','contextmenu_viewparamnode')}, 'Checked','off');
viewEdges = uimenu(view, 'Label','&Edges');
uimenu(viewEdges, 'Label','View Edges'' &Names', 'Tag','uimenu_viewnameedge', 'Callback',{@viewtext,'name','edge',findobj('Tag','contextmenu_viewnameedge')}, 'Checked','off');
uimenu(viewEdges, 'Label','View Edges'' User&Params', 'Tag','uimenu_viewuserparamedge', 'Callback',{@viewtext,'userparam','edge',findobj('Tag','contextmenu_viewparamedge')}, 'Checked','on');
uimenu(viewEdges, 'Label','View &arrows', 'Tag','uimenu_viewarrows', 'Callback',{@viewedgesarrows}, 'Separator', 'on', 'Checked',configuration.edges.viewarrows);
viewParts = uimenu(view, 'Label','View &Parts', 'Separator','on');
uimenu(viewParts, 'Label','View &Primary Toolbar', 'Tag','uimenu_viewtoolbar1', 'Callback',{@viewparts,'toolbar1'}, 'Checked',configuration.viewparts.toolbar1);
uimenu(viewParts, 'Label','View &Secondary Toolbar', 'Tag','uimenu_viewtoolbar2', 'Callback',{@viewparts,'toolbar2'}, 'Checked',configuration.viewparts.toolbar2);
uimenu(viewParts, 'Label','View &Tabs', 'Tag','uimenu_viewtabs', 'Callback',{@viewparts,'tabs'}, 'Checked',configuration.viewparts.tabs);
uimenu(viewParts, 'Label','View &Sliders', 'Tag','uimenu_viewsliders', 'Callback',{@viewparts,'sliders'}, 'Checked',configuration.viewparts.sliders);
uimenu(viewParts, 'Label','View &All', 'Tag','uimenu_viewall', 'Callback',{@viewparts,'viewall'}, 'Separator','on');
uimenu(viewParts, 'Label','&Hide All', 'Tag','uimenu_hideall', 'Callback',{@viewparts,'hideall'});

options = uimenu(hFigure,'Label','&Options','Enable','on','Tag','graphedit_menu');
uimenu(options, 'Label','&Unique Names', 'Tag','uimenu_uniquenames', 'Checked','off', 'Callback',@checkonoff, 'Enable', 'off');
uimenu(options, 'Label','Draw &multiedges', 'Tag','uimenu_multiedges', 'Checked','on', 'Callback',@checkonoff, 'Enable', 'off');
uimenu(options, 'Label','Save Actual Configuration', 'Tag','uimenu_saveconfiguration', 'Separator','on', 'Callback',@saveactualconfiguration);
uimenu(options, 'Label','&Settings', 'Tag','uimenu_settings', 'Separator','on', 'Callback',@editsettings);

methods = uimenu(hFigure,'Label','&Methods','Tag','graphedit_menu');
uimenu(methods, 'Label','edge2param', 'Callback',{@domethod,'edge2param'});
uimenu(methods, 'Label','node2param', 'Callback',{@domethod,'node2param'});

plugin = uimenu(hFigure, 'Label','&Plug-ins', 'CreateFcn',@loadplugins, 'Tag','uimenu_plugin');

help = uimenu(hFigure,'Label','&Help','Tag','graphedit_menu');
uimenu(help, 'Label','&Help', 'Callback',@helpcallback);
uimenu(help, 'Label','&About', 'Callback',{@grapheditaboutdialog,hFigure});

%=================================================================

function hToolbar = createtoolbar(hFigure,configuration)
hToolbar = uitoolbar(hFigure,'Tag','graphedit_toolbar1','Visible',configuration.viewparts.toolbar1);

uipushtool(hToolbar, 'TooltipString','New graph', 'ClickedCallback',{@createcanvas,hFigure}, 'CData',getcdata('private/grapheditnew.png'), 'Tag','toolbar_new');
uipushtool(hToolbar, 'TooltipString','Open graph from file', 'ClickedCallback',@opengraphfromfile, 'CData',getcdata('private/grapheditopen.png'), 'Tag','toolbar_open');
uipushtool(hToolbar, 'TooltipString','Save graph to file...', 'ClickedCallback',@savegraphtofile, 'CData',getcdata('private/grapheditsave.png'), 'Tag','toolbar_saveas');

uipushtool(hToolbar, 'TooltipString','Import from workspace', 'Tag','toolbar_Import', 'CData',getcdata('private/grapheditimport.png'), 'ClickedCallback',{@importobjectgraph}, 'Separator','on');
uipushtool(hToolbar, 'TooltipString','Export to workspace', 'CData',getcdata('private/grapheditexport.png'), 'ClickedCallback',@exportobjectgraph, 'Tag','toolbar_export');

%     uipushtool(hToolbar, 'TooltipString','Cut Node', 'ClickedCallback',@copynodefcn, 'CData',getcdata('private/grapheditcut.png'), 'Tag','pushtool_cut', 'Separator','on','Enable','on');
%     uipushtool(hToolbar, 'TooltipString','Copy Node', 'ClickedCallback',@copynodefcn, 'CData',getcdata('private/grapheditcopy.png'), 'Tag','pushtool_copy','Enable','on');
%     uipushtool(hToolbar, 'TooltipString','Paste Node', 'CData',getcdata('private/grapheditpaste.png'), 'ClickedCallback',@pastenodefcn, 'Tag','pushtool_Paste','Enable','on');
%
%     uipushtool(hToolbar, 'TooltipString','Undo last action (Ctrl+z)', 'ClickedCallback',@undo, 'CData',getcdata('private/grapheditundo.png'), 'Tag','toolbar_grapheditundo', 'Enable','on', 'Separator','on');
%     uipushtool(hToolbar, 'TooltipString','Redo action (Ctrl+y)', 'ClickedCallback',@redo, 'CData',getcdata('private/grapheditredo.png'), 'Tag','toolbar_grapheditredo', 'Enable','on');

uitoggletool(hToolbar, 'TooltipString','Tool arrow (Ctrl+a)', 'ClickedCallback',@drawingtype, 'CData',getcdata('private/grapheditarrow.png'), 'Tag','toolbar_grapheditarrow', 'Separator','on','State','on');
uitoggletool(hToolbar, 'TooltipString','Draw Node (Ctrl+r)', 'Separator','on', 'CData',getcdata('private/grapheditcircle.png'),  'ClickedCallback',@drawingtype, 'Tag','toolbar_grapheditdrawnode');
uitoggletool(hToolbar, 'TooltipString','Draw Edge (Ctrl+e)', 'CData',getcdata('private/grapheditline.png'), 'ClickedCallback',@drawingtype, 'Tag','toolbar_grapheditdrawedge');
uitoggletool(hToolbar, 'TooltipString','Delete Mode (Ctrl+d)', 'Separator','on', 'ClickedCallback',@drawingtype, 'Tag','toolbar_grapheditdelete', 'CData',getcdata('private/graphedittrash.png'));

uitoggletool(hToolbar, 'TooltipString','View/Hide Grid (Ctrl+g)', 'CData',getcdata('private/grapheditgrid.png'), 'ClickedCallback',@viewgrid, 'Tag','toolbar_viewgrid', 'Separator','on');
uitoggletool(hToolbar, 'TooltipString','Attach to grid', 'CData',getcdata('private/grapheditattach.png'), 'ClickedCallback',@attachtogrid, 'Tag','toolbar_grapheditattachtogrid');

uitoggletool(hToolbar, 'TooltipString','View/Hide Node Designer', 'Separator','on', 'CData',getcdata('private/grapheditdesigner.png'), 'ClickedCallback',{@viewnodedesigner,hFigure}, 'Tag','toolbar_genodedesigner');
uitoggletool(hToolbar, 'TooltipString','View/Hide Library Browser', 'CData',getcdata('private/grapheditlibrary.png'), 'ClickedCallback',{@viewlibrarybrowser,hFigure}, 'Tag','toolbar_gelibrarybrowser');
uitoggletool(hToolbar, 'TooltipString','View/Hide Property Editor', 'CData',getcdata('private/grapheditpropertyeditor.png'), 'ClickedCallback',{@viewpropertyeditor,hFigure}, 'Tag','toolbar_gepropertyeditor', 'State',configuration.propertyeditorafterstart);

uipushtool(hToolbar, 'TooltipString','Help', 'ClickedCallback',{@helpcallback}, 'CData',getcdata('private/graphedithelp.png'), 'Separator','on');
uipushtool(hToolbar, 'TooltipString','About', 'ClickedCallback',{@grapheditaboutdialog,hFigure}, 'CData',getcdata('private/grapheditabout.png'));

%--------------------------------------------------------------------

function im = getcdata(pictureName)
color = 255*get(0,'factoryUicontrolBackgroundColor');
im = imread(pictureName);
[height,width,colors] = size(im);
for i = 1:height
    for j = 1:width
        if (((im(i,j,1) <= 253) && (im(i,j,1) >= 248)) &&...
                ((im(i,j,2) <= 46) && (im(i,j,2) >= 38)) &&...
                ((im(i,j,3) <= 222) && (im(i,j,3) >= 217)))
            im(i,j,:) = color(:);
        end
    end
end

%=================================================================

function createtoolbar2(hFigure,visible)
figureData = get(hFigure,'UserData');
fontSizesCell = {'4' '6' '8' '9' '10' '11' '12' '14' '16' '18' '20' '22' '24' '28' '32'};
fontSizes = [4 6 8 9 10 11 12 14 16 18 20 22 24 28 32];
upValue = find(fontSizes == figureData.configuration.fontsize.userparams);
nValue = find(fontSizes == figureData.configuration.fontsize.names);

handles = [];
hFrame = uicontrol('Tag','toolbar2','Style','frame','Visible',visible);
handles(end+1) = uicontrol('Style','text','String','Grid x:  ','HorizontalAlignment','right','Visible',visible);
handles(end+1) = uicontrol('Tag','grapheditgridx','Style','edit','String',num2str(figureData.configuration.defaultgridx),'Callback',@setgridtick,'BackgroundColor',[1 1 1],'Visible',visible);
handles(end+1) = uicontrol('Style','text','String','Grid y:  ','HorizontalAlignment','right','Visible',visible);
handles(end+1) = uicontrol('Tag','grapheditgridy','Style','edit','String',num2str(figureData.configuration.defaultgridy),'Callback',@setgridtick,'BackgroundColor',[1 1 1],'Visible',visible);

handles(end+1) = uicontrol('Style','text','HorizontalAlignment','right','String','Names:  ','Visible',visible);
handles(end+1) = uicontrol('Tag','grapheditnamessize','Style','popup','String',fontSizesCell,'Visible',visible,'BackgroundColor',[1 1 1],'UserData',fontSizes,'TooltipString','Set font size for names','Value',nValue,'Callback',{@setcanvasfontsize,'name'});
handles(end+1) = uicontrol('Style','text','HorizontalAlignment','right','String','UserParams:  ','Visible',visible);
handles(end+1) = uicontrol('Tag','graphedituserparamssize','Style','popup','String',fontSizesCell,'Visible',visible,'BackgroundColor',[1 1 1],'UserData',fontSizes,'TooltipString','Set font size for user parameters','Value',upValue,'Callback',{@setcanvasfontsize,'userparam'});

handles(end+1) = uicontrol('Style','text','HorizontalAlignment','right','String','Zoom:  ','Visible',visible);
handles(end+1) = uicontrol('Tag','grapheditnewzoom','Style','popupmenu','String',{'500%' '300%' '200%' '150%' '125%' '100%' '80%' '65%' '50%' '25%' '10%'},'UserData',[500 300 200 150 125 100 80 65 50 25 10],'TooltipString','Set zoom of actual canvas','Value',6,'Callback',@setzoom,'BackgroundColor',[1 1 1],'Visible',visible);
handles(end+1) = uicontrol('Tag','grapheditfitgraph','Style','pushbutton','Callback',@fitgraph,'TooltipString','Fit graph','CData',getcdata('private/grapheditfit.png'),'Visible',visible);
handles(end+1) = uicontrol('Tag','grapheditcentergraph','Style','pushbutton','Callback',@setgraphtocenter,'TooltipString','Center graph','CData',getcdata('private/grapheditcenter.png'),'Visible',visible);

set(hFrame,'UserData',struct('handles',handles,...
    'forall',[1 8],...
    'forrectangle',[9 18],...
    'forpatch',[9 16],...
    'forimage',[19 26]));
figureData = get(hFigure,'UserData');
figureData.htoolbar2 = hFrame;
set(hFigure,'UserData',figureData);

%=================================================================

function setpositiontoolbar2(hFrame,posFigure,heightToolbar)
userData = get(hFrame,'UserData');
handles = userData.handles;
posFrame = [1,...
    posFigure(4)-heightToolbar,...
    posFigure(3),...
    heightToolbar+1];
endFrame = posFrame(1)+posFrame(3);
set(hFrame,'Position',posFrame);   i = 1;
set(handles(i),'position',[5     posFrame(2)+3   45  15]);  i = i + 1;
set(handles(i),'position',[48    posFrame(2)+3   30  18]);  i = i + 1;
set(handles(i),'position',[78    posFrame(2)+3   45  15]);  i = i + 1;
set(handles(i),'position',[121   posFrame(2)+3   30  18]);  i = i + 1;

set(handles(i),'position',[165   posFrame(2)+3   55  15]);  i = i + 1;
set(handles(i),'position',[218   posFrame(2)+8   40  15]);  i = i + 1;
set(handles(i),'position',[260   posFrame(2)+3   75  15]);  i = i + 1;
set(handles(i),'position',[333   posFrame(2)+8   40  15]);  i = i + 1;

set(handles(i),'position',[endFrame-165   posFrame(2)+3   45  15]);  i = i + 1;
set(handles(i),'position',[endFrame-120   posFrame(2)+8   50  15]);  i = i + 1;
set(handles(i),'position',[endFrame-60    posFrame(2)+2   20  20]);  i = i + 1;
set(handles(i),'position',[endFrame-35    posFrame(2)+2   20  20]);  %i = i + 1;

%=================================================================

function createcontextmenu(hFigure)
menuGraph = uicontextmenu;
%    uimenu(menuGraph, 'Label','Paste', 'Callback',@pastenodefcn, 'Enable','off');
uimenu(menuGraph, 'Label','Fit Graph', 'Callback',@fitgraph, 'Enable','on');
uimenu(menuGraph, 'Label','Center Graph', 'Callback',@setgraphtocenter, 'Enable','on');
uimenu(menuGraph, 'Label','Edit Background', 'Callback',{@editbackground,'off','on'}, 'Separator','on');

menuNode = uicontextmenu;
%    uimenu(menuNode, 'Label','View Names', 'Tag','contextmenu_viewnamenode', 'Callback',{@viewtext,'name','node',findobj('Tag','uimenu_viewnamenode')}, 'Checked','on');
%    uimenu(menuNode, 'Label','View UserParams', 'Tag','contextmenu_viewparamnode', 'Callback',{@viewtext,'userparam','node',findobj('Tag','uimenu_viewuserparamnode')}, 'Checked','off');
%    uimenu(menuNode, 'Label','Cut', 'Tag','uimenu_cutcopy', 'Callback',@copynodefcn, 'Separator','on');
%    uimenu(menuNode, 'Label','Copy', 'Tag','uimenu_cutcopy', 'Callback',@copynodefcn);
%    uimenu(menuNode, 'Label','Rename', 'Callback',@renamenode, 'Separator','on');
uimenu(menuNode, 'Label','Delete', 'Callback',@deleteselectedobject);

menuEdge = uicontextmenu;
uimenu(menuEdge, 'Label','Edit', 'Tag','uimenu_editedge', 'Checked','off', 'Callback',@menu_edit);
uimenu(menuEdge, 'Label','Add Point', 'Tag','uimenu_addpoint', 'Callback',@menu_addpoint);
%    uimenu(menuEdge, 'Label','View Names', 'Tag','contextmenu_viewnameedge', 'Callback',{@viewtext,'name','edge',findobj('Tag','uimenu_viewnameedge')}, 'Checked','off','Separator','on');
%    uimenu(menuEdge, 'Label','View UserParams', 'Tag','contextmenu_viewparamedge', 'Callback',{@viewtext,'userparam','edge',findobj('Tag','uimenu_viewuserparamedge')}, 'Checked','on');
%    uimenu(menuEdge, 'Label','Rename', 'Callback',@renameedge, 'Separator','on');
uimenu(menuEdge, 'Label','Delete', 'Callback',@deleteselectedobject, 'Separator','on');

menuLittlePoint = uicontextmenu;
uimenu(menuLittlePoint, 'Label','Plain', 'Tag','menu_geplain', 'Checked','off', 'Callback',{@menu_binding,'plain'});
uimenu(menuLittlePoint, 'Label','Straight', 'Tag','menu_gestraight', 'Checked','off', 'Callback',{@menu_binding,'straight'});
uimenu(menuLittlePoint, 'Label','Corner', 'Tag','menu_gecorner', 'Checked','off', 'Callback',{@menu_binding,'corner'});
uimenu(menuLittlePoint, 'Label','Delete', 'Callback',{@menu_deletepoint}, 'Separator','on');

menuFlag = uicontextmenu;
uimenu(menuFlag, 'Label','Close', 'Callback',@closecanvas);

figureData = get(hFigure,'UserData');
figureData.contextmenus = struct('graph',menuGraph,...
    'node',menuNode,...
    'edge',menuEdge,...
    'littlepoint',menuLittlePoint,...
    'flag',menuFlag);
set(hFigure,'UserData',figureData);

%=================================================================

function hAxesBar = createtabs(hFigure,visible)
figureData = get(hFigure,'UserData');
hAxesBar = axes(...
    'Parent',hFigure,...
    'Tag','grapheditaxesbar',...
    'Units','Pixels',...
    'XTickLabel',[],...
    'YTickLabel',[],...
    'XTickLabelMode','manual',...
    'YTickLabelMode','manual',...
    'SelectionHighlight','off',...
    'Color',get(hFigure,'Color'),...
    'XColor',get(hFigure,'Color'),...
    'YColor',get(hFigure,'Color'),...          'Box','on',...
    'HandleVisibility','callback',...
    'Visible',visible);

hSlider = uicontrol(hFigure,...
    'Style','slider',...
    'Tag','axesbar_slider',...
    'Enable','off',...
    'UserData',hAxesBar,...
    'Callback',@slideraxesbarchanged,...
    'Visible',visible);
hLineColor = line(...
    'Parent',hAxesBar,...
    'Tag','axesbarlinecolor',...
    'LineWidth',1.5,...
    'Color','white',...
    'XData',[0, 0],...
    'YData',[0, 0],...
    'Visible',visible);
hLineBlack = line(...
    'Parent',hAxesBar,...
    'Tag','axesbarlineblack',...
    'LineWidth',1.5,...
    'XData',[0, 0, 0, 0, 0, 0],...
    'YData',[0, 0, 0, 0, 0, 0],...
    'Visible',visible);

figureData.htabs = hAxesBar;
set(hFigure,'UserData',figureData);
saveStructure = struct(...
    'flags',[],...
    'slider',hSlider,...
    'linecolor',hLineColor,...
    'lineblack',hLineBlack);
set(hAxesBar,'UserData',saveStructure);

%=================================================================

function setpositionaxesbar(hAxesBar,border,height,posFigure,fromLeft,fromRight)
saveStructure = get(hAxesBar,'UserData');
widthSlider = 28;
if height+1 >= widthSlider,
    widthSlider = height + 1;
end
positionAxesBar = [fromLeft border posFigure(3)-fromRight-2 height];
positionSlider = [posFigure(3)-fromRight-widthSlider border-1 widthSlider height+1];
set(hAxesBar,...
    'Position',positionAxesBar,...
    'XLim',[0 positionAxesBar(3)+widthSlider],...
    'YLim',[0 positionAxesBar(4)],...
    'TickLength',[0 0],...
    'XTick',[],...
    'YTick',[]);
set(saveStructure.slider,...
    'Position',positionSlider);
resizelineforaxesbar([saveStructure.lineblack,saveStructure.linecolor], hAxesBar);
set(saveStructure.lineblack,'YData',[height-1, height-1, 0, 0, height-1, height-1]);
set(saveStructure.linecolor,'YData',[height-1, height-1]);
setsliderforaxesbar(hAxesBar);

%=================================================================

function resizelineforaxesbar(hLines,hAxesBar)
xLim = get(hAxesBar,'XLim');
for i = 1:length(hLines),
    xData = get(hLines(i),'XData');
    xData(1) = xLim(1)-5;
    xData(end) = xLim(2)+5;
    set(hLines(i),'XData',xData);
end

%=================================================================

function hAxes = createcanvas(hFigure,eventData,varargin) %#ok<INUSL>
if nargin == 3,
    if strcmp(get(findobj('Tag','uimenu_lockup'),'Checked'),'on') &&...
            (strcmp(get(hFigure,'Tag'),'uimenu_new') || strcmp(get(hFigure,'Tag'),'toolbar_new')),
        return;
    end
    hFigure = varargin{1};
end

figureData = get(hFigure,'UserData');
hAxes = createaxes(hFigure);
figureData.hcanvases(end+1) = hAxes;

hChildren = get(hFigure,'Children');
hChildren(hChildren == figureData.htabs) = [];
hChildren = [hChildren(1:find(hChildren==hAxes)-1); figureData.htabs; hChildren(find(hChildren==hAxes):end)];
set(hFigure,'Children',hChildren);

set(hFigure,'UserData',figureData);
hidecanvas;
resizegraphedit(hFigure,[]);
saveStruct = get(hAxes,'UserData');
saveStruct.flag = addflag(hAxes);
set(hAxes,'UserData',saveStruct,'Visible','on');
set(hFigure,'CurrentAxes',hAxes);

%=================================================================

function hAxes = createaxes(hFigure)
figureData = get(hFigure,'UserData');
hAxes = axes(...
    'Parent',hFigure,...
    'Visible','off',...
    'Tag','grapheditgraph',...
    'Units','Pixels',...
    'SelectionHighlight','off',...
    'Drawmode','fast',...        'EraseMode','xor',...
    'Color','white',...          'Box','on',...
    'XTickLabel',[],...
    'YTickLabel',[],...
    'XColor',get(hFigure,'Color'),...
    'YColor',get(hFigure,'Color'),...
    'XTickLabelMode','manual',...
    'YTickLabelMode','manual',...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'ButtonDownFcn',@buttondownoveraxes,...
    'DeleteFcn',@deletefcncallbackaxes,...%'HandleVisibility','callback',...
    'UIContextmenu',figureData.contextmenus.graph);
saveStruct = struct(...
    'nodes',[],...
    'eps',[],...
    'flag',[],...
    'toresize',0,...        'gridx',20,...        'gridy',20,...
    'viewgrid','off',...
    'attach','off',...
    'zoom',1,...
    'sliders',[createsliderparams('horizontal'), createsliderparams('vertical')],...
    'selected',[],...
    'variable','',...
    'file','',...
    'undo',[],...
    'redo',[],...
    'objectparams',struct('Name',['graph_{' int2str(length(figureData.hcanvases)+1) '}'],...
    'Notes','',...
    'UserParam',[],...
    'Color',[],...
    'DataTypes',struct('edges',[],...
    'nodes',[]),...
    'GridFreq',[figureData.configuration.defaultgridx,...
                figureData.configuration.defaultgridy]));
set(hAxes,'UserData',saveStruct);

%=================================================================

function setpositioncanvas(hAxes,border,fromAbove,fromLeft,fromBottom,fromRight,posFigure,gridx,gridy)
positionAxes = [fromLeft,...
    fromBottom,...posTabs(4)+posTabs(2),...
    posFigure(3)-fromLeft-fromRight,...
    posFigure(4)-fromBottom-fromAbove];
for i = 1:length(hAxes),
%     xLim = get(hAxes(i),'XLim');
%     yLim = get(hAxes(i),'YLim');
%     xLimMin = positionAxes(3) - (xLim(2) - xLim(1))/2;
    set(hAxes(i),...
        'Position',positionAxes,...
        'XLim',[0 positionAxes(3)],...
        'YLim',[0 positionAxes(4)],...
        'TickLength',[0 0],...
        'XTick',0:gridx:positionAxes(3),...
        'YTick',0:gridy:positionAxes(4));
    setlim(hAxes(i));
end
%     setlim(hAxes(end));

%=================================================================





%////////////////////////////////////////////////////////////////////
%/////////////////////////    Sliders      //////////////////////////
%////////////////////////////////////////////////////////////////////





%=================================================================

function createsliders(hFigure,visible)
figureData = get(hFigure,'UserData');
params = createsliderparams('horizontal');
hSliderH = uicontrol(hFigure,...
    'Style','slider',...
    'Tag','horizontal',...
    'Enable','on',...
    'Min',params.MainMin,...
    'Max',params.MainMax,...
    'SliderStep',params.Step,...
    'Visible',visible,...
    'UserData',params,...
    'Callback',@sliderchanged);
params.Type = 'vertical';
hSliderV = uicontrol(hFigure,...
    'Style','slider',...
    'Tag','vertical',...
    'Enable','on',...
    'Min',params.MainMin,...
    'Max',params.MainMax,...
    'SliderStep',params.Step,...
    'Visible',visible,...
    'UserData',params,...
    'Callback',@sliderchanged);
hButton = uicontrol(hFigure,...
    'Style','pushbutton',...
    'Callback',@setgraphtocenter,...
    'Visible',visible,...
    'TooltipString','Click for moving graph to center.');
figureData.hsliders = [hSliderH, hSliderV, hButton];
set(hFigure,'UserData',figureData);

%=================================================================

function  params = createsliderparams(type)
    params = struct('Min',-500,...
                    'Max',500,...
                    'MainMin',-500,...
                    'MainMax',500,...
                    'Value',0,...
                    'Step',[.05 .3],...
                    'Type',type);

%=================================================================

function setpositionsliders(hObjects,border,height,fromAbove,fromLeft,posFigure)
positionH = [fromLeft, border-1,...
    posFigure(3)-height+1-fromLeft, height-1];
positionV = [posFigure(3)-height+1, border-1+height-1,...
    height, posFigure(4)-height-fromAbove];
positionB = [positionH(1)+positionH(3), border-1,...
    height, height];
set(hObjects(1),'Position',positionH);
set(hObjects(2),'Position',positionV);
set(hObjects(3),'Position',positionB);

for i = 1:2,
    data = get(hObjects(i),'UserData');
    maxVal = max(abs(data.Min),abs(data.Max));
    if maxVal < posFigure(2+i),
        data.MainMin = -posFigure(2+i);
        data.Min = -posFigure(2+i);
        data.MainMax = posFigure(2+i);
        data.Max = posFigure(2+i);
    else
        data.MainMin = -maxVal;
        data.Min = -maxVal;
        data.MainMax = maxVal;
        data.Max = maxVal;        
    end
    set(hObjects(i),'UserData',data);
end

%=================================================================

function sliderchanged(hSlider,event,hAxes) %#ok<INUSD>
    if ~exist('hAxes','var'),
        hAxes = gca;
    end
    updateslider(hSlider);
    switch get(hSlider,'Tag'),
        case 'horizontal',
            LimCode = 'XLim';
        case 'vertical',
            LimCode = 'YLim';
        otherwise,
            return;
    end
    LimAxes = get(hAxes,LimCode);
    LimAxes = [0 LimAxes(2)-LimAxes(1)];
    set(hAxes,LimCode,LimAxes + get(hSlider,'Value'));
    settick(hAxes);

%=================================================================

function updateslider(hSlider)
    value = get(hSlider,'Value');
    data = get(hSlider,'UserData');
    max = get(hSlider,'Max');
    min = get(hSlider,'Min');
    if value > min + 30,
        if value > data.Value,
            if value == max,
                set(hSlider,'Max',max + 20);
            end
        elseif value < data.Value,
            if value < data.MainMax,
                set(hSlider,'Max',data.MainMax);
            else
                set(hSlider,'Max',value + 20);
            end
        end
    end
    if value < max - 30,
        if value < data.Value,
            if value == min,
                set(hSlider,'Min',min - 20);
            end
        elseif value > data.Value,
            if value > data.MainMin,
                set(hSlider,'Min',data.MainMin);
            else
                set(hSlider,'Min',value - 20);
            end
        end
    end
    data.Value = value;
    data.Min = get(hSlider,'Min');
    data.Max = get(hSlider,'Max');
    set(hSlider,'UserData',data);

%=================================================================

function setslidersparams(hAxes)
% params = struct('Min',-300,'Max',300,'MainMin',-300,'MainMax',300,'Value',0,'Step',[.05 .2]);
    axesData = get(hAxes,'UserData');
    figureData = get(get(hAxes,'Parent'),'UserData');
    for i = 1:numel(figureData.hsliders),
        if strcmp(get(figureData.hsliders(i),'Style'),'slider'),
            sliderData = get(figureData.hsliders(i),'UserData');
            switch sliderData.Type,
                case 'horizontal',
                    params = axesData.sliders(1);
                case 'vertical',
                    params = axesData.sliders(2);
                otherwise
            end
            set(figureData.hsliders(i),...
                'Min',params.Min,...
                'Max',params.Max,...
                'SliderStep',params.Step,...
                'Value',params.Value,...
                'UserData',params);
        end
    end
    
%=================================================================

function params = getslidersparams(hAxes)
    figureData = get(get(hAxes,'Parent'),'UserData');
    params = [get(figureData.hsliders(1),'UserData'),...
              get(figureData.hsliders(2),'UserData')];

%=================================================================          

function updatecanvaslimits(hAxes)
    figureData = get(get(hAxes,'Parent'),'UserData');
    for i = 1:numel(figureData.hsliders),
        if strcmp(get(figureData.hsliders(i),'Style'),'slider'),
            sliderchanged(figureData.hsliders(i),[],hAxes);
        end
    end

%=================================================================

function sliderReSet(varargin)
hAxes = findobj('Tag','grapheditgraph','visible','on');
if nargin == 0
    figureData = get(get(hAxes,'Parent'),'UserData');
    for i = 1:length(figureData.hsliders)
        sliderData = get(figureData.hsliders(i),'UserData');
        if isstruct(sliderData) && isfield(sliderData,'Type')
            sliderReSet(figureData.hsliders(i));
        end
    end
    return;
else
    hslider = varargin{1};
end

% canvasData = get(hAxes,'UserData');
% if ~isempty(canvasData.nodes)
%     if ~isempty(canvasData.eps)
%         [xLimGraph,yLimGraph] = getgraphlimits(canvasData.nodes,canvasData.eps(:,1));
%     else
%         [xLimGraph,yLimGraph] = getgraphlimits(canvasData.nodes,[]);
%     end   
    sliderUserData = get(hslider,'UserData');
%     switch sliderUserData.Type,
%         case 'horizontal',
%             LimGraph = xLimGraph;
%             LimCode = 'XLim';
%             deltaAxesCorrection = 115;
%         case 'vertical',
%             LimGraph = yLimGraph;
%             LimCode = 'YLim';
%             deltaAxesCorrection = 145;
%         otherwise,
%             return;
%     end
%     LimAxes = get(hAxes,LimCode);
%     deltaAxes = LimAxes(2) - LimAxes(1);
%     deltaAxes = deltaAxes - deltaAxesCorrection;
%     deltaGraph = LimGraph(2) - LimGraph(1);
    
    params = sliderUserData;
	set(hslider,...
    	'Min',params.MainMin,...
        'Max',params.MainMax,...
        'SliderStep',params.Step,...
        'Value',params.Value,...
        'UserData',params);
% end

%=================================================================

function setgraphtocenter(hButton,eventData)
hAxes = findobj('Parent',gcf,'Tag','grapheditgraph','visible','on');
canvasData = get(hAxes,'UserData');
if ~isempty(canvasData.nodes)
    %         [xLimGraph,yLimGraph] = getgraphlimitsovernodes(canvasData.nodes);
    if ~isempty(canvasData.eps)
        [xLimGraph,yLimGraph] = getgraphlimits(canvasData.nodes,canvasData.eps(:,1));
    else
        [xLimGraph,yLimGraph] = getgraphlimits(canvasData.nodes,[]);
    end
    xCenter = xLimGraph(1) + (xLimGraph(2)-xLimGraph(1))/2;
    yCenter = yLimGraph(1) + (yLimGraph(2)-yLimGraph(1))/2;
    xLimAxes = get(hAxes,'XLim');
    yLimAxes = get(hAxes,'YLim');
    xDelta = (xLimAxes(2)-xLimAxes(1))/2;
    yDelta = (yLimAxes(2)-yLimAxes(1))/2;
    pause(0.1);
    xOffset = xCenter - xDelta;
    yOffset = yCenter - yDelta;
    set(hAxes,'XLim',[xOffset, xCenter + xDelta],...
        'YLim',[yOffset, yCenter + yDelta]);
    settick;
    setsliderstovalue(xOffset,'horizontal');
    setsliderstovalue(yOffset,'vertical');
    
    axesData = get(hAxes,'UserData');
    axesData.sliders(1).Value = xOffset;
    axesData.sliders(2).Value = yOffset;
    set(hAxes,'UserData',axesData);
end

%=================================================================

function setsliderstovalue(value,type)
    figureData = get(gcf,'UserData');
    for i = 1:numel(figureData.hsliders),
        sliderData = get(figureData.hsliders(i),'UserData');
        if isstruct(sliderData) && isfield(sliderData,'Type') &&...
           strcmp(sliderData.Type,type),
            hslider = figureData.hsliders(i);
            break;
        end
    end
    sliderData.Value = value;
	set(hslider,'Value',value,'UserData',sliderData);
    
%=================================================================

function [xLim,yLim] = getgraphlimits(nodes,edges)
[xLimE,yLimE] = getgraphlimitsoveredges(edges);
[xLimN,yLimN] = getgraphlimitsovernodes(nodes);
xLim = [min(xLimE(1),xLimN(1)) max(xLimE(2),xLimN(2))];
yLim = [min(yLimE(1),yLimN(1)) max(yLimE(2),yLimN(2))];

%=================================================================

function [xLim,yLim] = getgraphlimitsoveredges(edges)
xLim = [500 -500];
yLim = [500 -500];
for i = 1:length(edges)
    xData = get(edges(i),'Xdata');
    if min(xData) < xLim(1), xLim(1) = min(xData); end
    if max(xData) > xLim(2), xLim(2) = max(xData); end
    yData = get(edges(i),'Ydata');
    if min(yData) < yLim(1), yLim(1) = min(yData); end
    if max(yData) > yLim(2), yLim(2) = max(yData); end
end

%=================================================================

function [xLim,yLim] = getgraphlimitsovernodes(nodes)
xLim = [500 -500];
yLim = [500 -500];
for i = 1:length(nodes)
    try
        position = get(nodes(i),'Position');
        if position(1) < xLim(1), xLim(1) = position(1)+position(3)/2; end
        if position(1)+position(3) > xLim(2), xLim(2) = position(1)+position(3)/2; end
        if position(2) < yLim(1), yLim(1) = position(2)+position(4)/2; end
        if position(2)+position(4) > yLim(2), yLim(2) = position(2)+position(4)/2; end
    catch
        xData = get(nodes(i),'XData');
        yData = get(nodes(i),'YData');
        if min(xData) < xLim(1), xLim(1) = min(xData); end
        if max(xData) > xLim(2), xLim(2) = max(xData); end
        if min(yData) < yLim(1), yLim(1) = min(yData); end
        if max(yData) > yLim(2), yLim(2) = max(yData); end
    end
end




%=================================================================





%////////////////////////////////////////////////////////////////////
%///////////////////////    Tab system      /////////////////////////
%////////////////////////////////////////////////////////////////////





%=================================================================

function hFlag = addflag(hAxes)
figureData = get(get(hAxes,'Parent'),'UserData');
canvasData = get(hAxes,'UserData');
canvasPosition = get(hAxes,'Position');
axesbarData = get(figureData.htabs,'UserData');
visible = get(figureData.htabs,'Visible');
positionAxesBar = get(figureData.htabs,'Position');
numberFlags = length(figureData.hcanvases)-1;
flagShape = figureData.configuration.shapeflag;

width = figureData.configuration.widthflag;
lengthFlags = numberFlags*(width-15);
xData = [lengthFlags; lengthFlags+width; lengthFlags-3+width+flagShape(1); lengthFlags+flagShape(2)];
yData = [positionAxesBar(4); positionAxesBar(4); 0; 0];

hFlag = patch(...
    'Parent',figureData.htabs,...        'EraseMode','xor',...
    'XData',xData,...
    'YData',yData,...
    'CreateFcn','',...@selectoffotherflags,...
    'SelectionHighlight','off',...
    'ButtonDownFcn',@buttondownoverflag,...
    'DeleteFcn','',...
    'Visible',visible,...        'Selected',[],...
    'EdgeColor',[.7 .7 .7],...get(hAxes,'Color'),...
    'FaceColor',get(hAxes,'Color'),...        'FaceAlpha',1,...
    'UIContextmenu',figureData.contextmenus.flag);
hText = text(...
    xData(end) + (xData(end-1)-xData(end))/2,...
    yData(1)/2,...        getgraphnameforflag(graphName,positionFlag(3)),...
    canvasData.objectparams.Name,...
    'FontUnits','Pixels',...
    'SelectionHighlight','off',...
    'FontSize',yData(1)-6,...
    'Parent',figureData.htabs,...
    'HorizontalAlignment','center',...
    'Tag','flagname',...        'Selected',[],...
    'Visible',visible,...
    'FontWeight','bold',...
    'ButtonDownFcn',{@buttondownoverflag,hFlag},...
    'UIContextmenu',figureData.contextmenus.flag);

flagStructure = struct('axes',hAxes,'text',hText,'canvasposition',canvasPosition);
textStructure = struct('axes',hAxes,'flag',hFlag);
set(hFlag,'UserData',flagStructure);
set(hText,'UserData',textStructure);
axesbarData.flags(end+1) = hFlag;
set(figureData.htabs,'UserData',axesbarData);
selectoneflag(hFlag);
setsliderforaxesbar(figureData.htabs);

%=================================================================

function buttondownoverflag(hObject,eventData,hFlag)
if strcmp(get(findobj('Tag','uimenu_lockup'),'Checked'),'on'), return; end
if nargin == 3,   hObject = hFlag;   end
selectoneflag(hObject);

%=================================================================

function hidecanvas(hFlag)
visibleCanvas = findobj('Tag','grapheditgraph','Visible','on');
if exist('hFlag','var'),
    flagData = get(hFlag,'UserData');
    visibleCanvas(visibleCanvas == flagData.axes) = [];
end
if ~isempty(visibleCanvas)
    position = get(visibleCanvas(1),'Position');
    position(1:2) = [-10 -10];
    position(3:4) = [1 1];
    data = get(visibleCanvas,'UserData');
    data.xlim = get(visibleCanvas,'XLim');
    data.ylim = get(visibleCanvas,'YLim');
    data.sliders = getslidersparams(visibleCanvas);
    set(visibleCanvas,'Position',position,'Visible','off','UserData',data);
end

%=================================================================

function restorecanvas(hFlag,hLineColor)
flagData = get(hFlag,'UserData');
if strcmp(get(flagData.axes,'Visible'),'off')
    set(flagData.axes,'Visible','on');
    %         figureData = get(get(flagData.axes,'Parent'),'UserData');
    %         posFigure = get(get(flagData.axes,'Parent'),'Position');
    %         border = figureData.configuration.border;
    %         height = figureData.configuration.heightflag;
    %         heightToolbar = figureData.configuration.heighttoolbar;
    %         gridx = figureData.configuration.defaultgridx;
    %         gridy = figureData.configuration.defaultgridy;
    %         posTabs = get(get(hFlag,'Parent'),'Position');
    %         setpositioncanvas(flagData.axes,border,heightToolbar,border-1,height,height,posFigure,gridx,gridy);
    set(flagData.text,'FontWeight','bold');
    %         set(hLineColor,'Color',get(flagData.axes,'Color'));
    
end
resizegraphedit(get(flagData.axes,'Parent'),[],flagData.axes)
setslidersparams(flagData.axes);
updatecanvaslimits(flagData.axes);

%=================================================================

function selectoneflagfromcommandline(numberOfFlag)
figureData = get(gcf,'UserData');
axesbarStruct = get(figureData.htabs,'UserData');
if numberOfFlag > length(axesbarStruct.flags),
    hFlag = axesbarStruct.flags(end);
else
    hFlag = axesbarStruct.flags(numberOfFlag);
end
selectoneflag(hFlag);

%=================================================================

function viewtabinaxesbar(hFlag)
hTabs = get(hFlag,'Parent');
axesbarStruct = get(hTabs,'UserData');
positionSlider = get(axesbarStruct.slider,'Position');
xLim = get(hTabs,'XLim');
width = xLim(2) - xLim(1);
xData = get(hFlag,'XData');
if max(xData) > xLim(2) - positionSlider(3),
    xLim(2) = max(xData) + positionSlider(3);
    xLim(1) = xLim(2) - width;
    value = max(xData) - width;
    set(hTabs,'XLim',xLim);
    repairaxesbarline(hFlag,axesbarStruct.lineblack,axesbarStruct.linecolor);
    set(axesbarStruct.slider,'Value',value);
end
if min(xData) < xLim(1),
    xLim(1) = min(xData);
    xLim(2) = xLim(1) + width;
    value = min(xData);
    set(hTabs,'XLim',xLim);
    repairaxesbarline(hFlag,axesbarStruct.lineblack,axesbarStruct.linecolor);
    set(axesbarStruct.slider,'Value',value);
end

%=================================================================

function repairaxesbarline(hFlag,hLineBlack,hLineColor)
xLim = get(get(hFlag,'Parent'),'XLim');
xDataF = get(hFlag,'XData');

xDataL = get(hLineBlack,'XData');
xDataL(1) = xLim(1);
xDataL(2) = xDataF(1);
xDataL(3) = xDataF(4);
xDataL(4) = xDataF(3);
xDataL(5) = xDataF(2);
xDataL(6) = xLim(2);
set(hLineBlack,'XData',xDataL);

set(hLineColor,'XData',[xLim(1) xLim(2)]);

%=================================================================

function selectoneflag(hFlag)
axesbarStruct = get(get(hFlag,'Parent'),'UserData');
flagStruct = get(hFlag,'UserData');
hidecanvas(hFlag);
restorecanvas(hFlag,axesbarStruct.linecolor);

hChildren = get(get(hFlag,'Parent'),'Children');
%     index = find(hChildren == hFlag);

hChildren(hChildren == axesbarStruct.lineblack) = [];
hChildren(hChildren == axesbarStruct.linecolor) = [];
hChildren(hChildren == flagStruct.text) = [];
hChildren(hChildren == hFlag) = [];
set(hChildren(1:2:length(hChildren)),'FontWeight','normal');
set(get(hFlag,'Parent'),'Children',[axesbarStruct.lineblack; axesbarStruct.linecolor; flagStruct.text; hFlag; hChildren]);

repairaxesbarline(hFlag,axesbarStruct.lineblack,axesbarStruct.linecolor);
set(axesbarStruct.linecolor,'Color',get(hFlag,'FaceColor'));

hCanvases = findobj('Tag','grapheditgraph');
hCanvases(hCanvases == flagStruct.axes) = [];
set(flagStruct.axes,'Visible','on');

set(hCanvases,'Visible','off');

set(get(flagStruct.axes,'Parent'),'CurrentAxes',flagStruct.axes);
canvasData = get(flagStruct.axes,'UserData');
set(findobj('Tag','uimenu_viewgrid'),'Checked',canvasData.viewgrid);
set(findobj('Tag','toolbar_viewgrid'),'State',canvasData.viewgrid);
set(findobj('Tag','grapheditgridx'),'String',num2str(canvasData.objectparams.GridFreq(1)));
set(findobj('Tag','grapheditgridy'),'String',num2str(canvasData.objectparams.GridFreq(2)));
setactualvalueforzoomsetting(findobj('Tag','grapheditnewzoom'),canvasData.zoom);
setfileandvariablename(flagStruct.axes);
%     try
%         set(flagStruct.axes,'XLim',canvasData.xlim,'YLim',canvasData.ylim);
%     catch
%     end
selectobject(flagStruct.axes);
viewtabinaxesbar(hFlag);
usercallbackcall(get(get(hFlag,'Parent'),'Parent'),'ontabchange');

%=================================================================

function removeflag(hFlag)
flagStructure = get(hFlag,'UserData');
hAxesbar = get(hFlag,'Parent');
delete(hFlag);
delete(flagStructure.text);
axesbarData = get(hAxesbar,'UserData');
index = find(axesbarData.flags == hFlag);
axesbarData.flags(index) = [];
set(hAxesbar,'UserData',axesbarData);
if ~isempty(axesbarData.flags)
    repositionflags(hAxesbar,axesbarData.flags,index);
end

%=================================================================

function repositionflags(hAxesBar,flags,index)
figureData = get(get(hAxesBar,'Parent'),'UserData');
shapeFlag = figureData.configuration.shapeflag;
width = figureData.configuration.widthflag;
for i = index:length(flags)
    lengthFlags = (i-1)*(width-15);
    xData = [lengthFlags; lengthFlags-3+width; lengthFlags-3+width+shapeFlag(1); lengthFlags+shapeFlag(2)];
    set(flags(i),'XData',xData);
    flagData = get(flags(i),'UserData');
    positionText = get(flagData.text,'Position');
    %        positionText(1) = xData(end)+4;
    positionText(1) = xData(end) + (xData(end-1)-xData(end))/2;
    set(flagData.text,'Position',positionText);
end
setsliderforaxesbar(hAxesBar);

%=================================================================

function graphName = getgraphnameforflag(graphName,lengthNameInPixels)
lengthName = lengthNameInPixels/6;
if length(graphName) > lengthName
    graphName = graphName(1:round(lengthName));
end

%=================================================================

function setsliderforaxesbar(hAxesBar)
%     positionAxesBar = get(hAxesBar,'Position');
xLim = get(hAxesBar,'XLim');
dataAxesBar = get(hAxesBar,'UserData');
figureData = get(get(hAxesBar,'Parent'),'UserData');
posSlider = get(dataAxesBar.slider,'Position');
width = figureData.configuration.widthflag;
lengthFlags = (length(dataAxesBar.flags)*(width-15) - (xLim(2)-xLim(1))) + posSlider(3);
hSlider = dataAxesBar.slider;
if lengthFlags > 0
    value = get(hSlider,'Value');
    if value >= lengthFlags
        value = lengthFlags;
    end
    max = lengthFlags + 20;
    set(hSlider,'Min',0,'Max',max,'Value',value,...
        'SliderStep',[20/max 40/max],'Enable','on');
else
    set(hSlider,'Min',0,'Max',10,'Value',0,'Enable','off');
end
slideraxesbarchanged(hSlider,[]);

%=================================================================

function slideraxesbarchanged(hObject,eventData)
hAxesBar = get(hObject,'UserData');
dataAxesBar = get(hAxesBar,'UserData');
position = get(hAxesBar,'Position');
set(hAxesBar,'XLim',[0 position(3)] + (get(hObject,'Value')));
resizelineforaxesbar([dataAxesBar.lineblack,dataAxesBar.linecolor], hAxesBar);

%=================================================================

function setfileandvariablename(hCanvas)
hGraphedit = get(hCanvas,'Parent');
canvasData = get(hCanvas,'UserData');
name = 'Graphedit';
if ~isempty(canvasData.variable),
    name = [canvasData.variable ' - ' name];
end
if ~isempty(canvasData.file),
    name = [canvasData.file ': ' name];
end
set(hGraphedit,'Name',[' ' name]);


%=================================================================
%=================================================================





%////////////////////////////////////////////////////////////////////
%//////////////////////    Canvas routins     ///////////////////////
%////////////////////////////////////////////////////////////////////





%=================================================================

function closecanvas(hObject,eventData)
if ~isempty(findobj('Tag','grapheditnode','Parent',gca))
    button = questdlg('Do you want to save changes?',...
        'Continue Operation','Yes','No','Cancel','Yes');
    if strcmp(button,'Yes')
        if ~savegraphtofile
            return;
        end
    elseif strcmp(button,'Cancel')
        return;
    end
end
delete(gca);

%=================================================================

function closecanvases(numbers)
figStructure = get(gcf,'UserData');
axesbarData = get(figStructure.htabs,'UserData');
for i = numbers,
    flagData = get(axesbarData.flags(i),'UserData');
    delete(flagData.axes);
end

%=================================================================

function closeallcanvases(hObject,eventData)
figStructure = get(gcf,'UserData');
for i = length(figStructure.hcanvases):-1:1
    set(gcf,'CurrentAxes',figStructure.hcanvases(i));
    closecanvas(hObject,eventData);
end

%=================================================================

function deletefcncallbackaxes(hAxes,eventData)
canvasData = get(hAxes,'UserData');
removeflag(canvasData.flag);
set(get(hAxes,'Children'),'DeleteFcn','');
delete(hAxes);

figureData = get(gcf,'UserData');
index = find(figureData.hcanvases == hAxes);
figureData.hcanvases(index) = [];
set(gcf,'UserData',figureData);
if isempty(figureData.hcanvases)
    createcanvas(gcf);
else
    if index > length(figureData.hcanvases),  index = index - 1;   end
    canvasData = get(figureData.hcanvases(index),'UserData');
    selectoneflag(canvasData.flag);
end

%=================================================================

function setcanvasfontsize(hControl,eventData,type)
values = get(hControl,'UserData');
index = get(hControl,'Value');
setcanvasfontsize_command(values(index),type);

%=================================================================

function setcanvasfontsize_command(value,type)
hTexts = [findobj('Parent',gca,'Tag',['text' type '_node']);...
    findobj('Parent',gca,'Tag',['text' type '_edge'])];
set(hTexts,'FontSize',value);
figureData = get(gcf,'UserData');
eval(['figureData.configuration.fontsize.' type 's = value;']);
set(gcf,'UserData',figureData);

%=================================================================

function setfontsizecontrols(type)
figureData = get(gcf,'UserData');
hControl = findobj('Tag',['graphedit' type 'ssize']);
userData = get(hControl,'UserData');
string = get(hControl,'String');
value = eval(['figureData.configuration.fontsize.' type 's']);
position = find(userData == value);
if isempty(position),
    string{end} = num2str(value);
    userData(end) = value;
    position = length(userData);
end
set(hControl,'String',string,'UserData',userData,'Value',position);

%=================================================================

function setgridtick(hObject,eventData)
number1 = round(str2double(get(hObject,'string')));
if ~isnan(number1)
    structAxes = get(gca,'UserData');
    if strcmp(get(hObject,'Tag'),'grapheditgridx')
        structAxes.objectparams.GridFreq(1) = number1;
    else
        structAxes.objectparams.GridFreq(2) = number1;
    end
    set(gca,'UserData',structAxes);
    settick;
else
    h = errordlg(['Invalid number "' get(hObject,'string') '" !'],' Invalid input');
    set(h,'WindowStyle','modal');
end

%=================================================================

function settick(varargin)
if nargin > 0,   hAxes = varargin{1};   else   hAxes = gca;  end
structAxes = get(hAxes,'UserData');
xLim = get(hAxes,'XLim');
yLim = get(hAxes,'YLim');
startX = xLim(1) - mod(xLim(1),structAxes.objectparams.GridFreq(1));
startY = yLim(1) - mod(yLim(1),structAxes.objectparams.GridFreq(2));
set(hAxes,'XTick',startX:structAxes.objectparams.GridFreq(1):xLim(2));
set(hAxes,'YTick',startY:structAxes.objectparams.GridFreq(2):yLim(2));
% sliderReSet;

%=================================================================

function viewgrid(hObject,eventData)
if strcmp(get(hObject,'state'),'on')
    setgridstate('on');
    set(findobj('Tag','uimenu_viewgrid'),'checked','on');
else
    setgridstate('off');
    set(findobj('Tag','uimenu_viewgrid'),'checked','off');
end

function viewgrid2(hObject,eventData)
if strcmp(get(hObject,'checked'),'on')
    set(hObject,'Checked','off');
    setgridstate('off');
    set(findobj('Tag','toolbar_viewgrid'),'state','off');
else
    set(hObject,'Checked','on');
    setgridstate('on');
    set(findobj('Tag','toolbar_viewgrid'),'state','on');
end


function setgridstate(value)
canvasData = get(gca,'UserData');
if strcmp(value,'on')
    set(gca,'XColor',[.7 .7 .7],'YColor',[.7 .7 .7]);
else
    set(gca,'XColor',get(gca,'Color'),'YColor',get(gca,'Color'));
end
canvasData.viewgrid = value;
set(gca,'UserData',canvasData);
set(gca,'XGrid',value,'YGrid',value);

%=================================================================

function attachtogrid(hObject,eventData)
if strcmp(get(hObject,'state'),'on')
    setattachtogridstate('on');
    set(findobj('Tag','uimenu_grapheditattachtogrid'),'checked','on');
else
    setattachtogridstate('off');
    set(findobj('Tag','uimenu_grapheditattachtogrid'),'checked','off');
end

function attachtogrid2(hObject,eventData)
if strcmp(get(hObject,'checked'),'on')
    set(hObject,'Checked','off');
    setattachtogridstate('off');
    set(findobj('Tag','toolbar_grapheditattachtogrid'),'state','off');
else
    set(hObject,'Checked','on');
    setattachtogridstate('on');
    set(findobj('Tag','toolbar_grapheditattachtogrid'),'state','on');
end

function setattachtogridstate(value)
canvasData = get(gca,'UserData');
canvasData.attach = value;
set(gca,'UserData',canvasData);

%=================================================================

function fitgraph(hObject,eventData)
hAxes = findobj('Parent',gcf,'Tag','grapheditgraph','visible','on');
border = 40;
drawnow;
canvasData = get(hAxes,'UserData');
if ~isempty(canvasData.nodes)
    position = get(hAxes,'Position');
    xLimAxes = get(hAxes,'XLim');
    yLimAxes = get(hAxes,'YLim');
    widthAxes = xLimAxes(2) - xLimAxes(1);
    heightAxes = yLimAxes(2) - yLimAxes(1);
    ratioAxes = widthAxes/heightAxes;
    if ~isempty(canvasData.eps)
        [xLimGraph,yLimGraph] = getgraphlimits(canvasData.nodes,canvasData.eps(:,1));
    else
        [xLimGraph,yLimGraph] = getgraphlimits(canvasData.nodes,[]);
    end
    widthGraph = xLimGraph(2) - xLimGraph(1);
    heightGraph = yLimGraph(2) - yLimGraph(1);
    if heightGraph == 0, heightGraph = 0.0001; end
    ratioGraph = widthGraph/heightGraph;

    if ratioGraph > ratioAxes       % fitting in width
        xLim = [xLimGraph(1) - border, xLimGraph(2) + border];
        yLim = xLim/ratioAxes;
        width = widthGraph + 2*border;
        yCenter = yLimGraph(1) + heightGraph/2;
        yDelta = (yLim(2) - yLim(1))/2;
        yLim = [yCenter - yDelta, yCenter + yDelta];
        zoom = position(3)/width;
    else                            % fitting in height
        yLim = [yLimGraph(1) - border, yLimGraph(2) + border];
        xLim = yLim*ratioAxes;
        height = heightGraph + 2*border;
        xCenter = xLimGraph(1) + widthGraph/2;
        xDelta = (xLim(2) - xLim(1))/2;
        xLim = [xCenter - xDelta, xCenter + xDelta];
        zoom = position(4)/height;
    end
    
    set(hAxes,'XLim',xLim,'YLim',yLim);
    setactualvalueforzoomsetting(findobj('Tag','grapheditnewzoom'),zoom)
    userData = get(hAxes,'UserData');
    userData.zoom = zoom;
    set(hAxes,'UserData',userData);
    settick;
    
    setsliderstovalue(xLim(1),'horizontal');
    setsliderstovalue(yLim(1),'vertical');
    axesData = get(hAxes,'UserData');
    axesData.sliders(1).Value = xLim(1);
    axesData.sliders(2).Value = yLim(1);
    set(hAxes,'UserData',axesData);

end

%=================================================================

function setzoom(hObject,eventData,varargin)
if nargin == 3
    value = varargin{1};
    setactualvalueforzoomsetting(hObject,value);
else
    cellOfValues = get(hObject,'String');
    str = cellOfValues{get(hObject,'Value')};
    value = str2double(str(1:(end-1)))/100;
end
userData = get(gca,'UserData');
userData.zoom = value;
set(gca,'UserData',userData);
setlim;

%=================================================================

function setactualvalueforzoomsetting(hObject,value)
str = [num2str(round(value*100)) '%'];
cellOfValues = get(hObject,'String');
index = strmatch(str,cellOfValues);
if isempty(index)
    cellOfValues{end+1} = str;
    index = length(cellOfValues);
end
set(hObject,'String',cellOfValues,'Value',index);

%=================================================================

function setlim(varargin)
if nargin > 0,   hAxes = varargin{1};   else   hAxes = gca;  end
position = get(hAxes,'Position');
structAxes = get(hAxes,'UserData');
xLim = get(hAxes,'XLim');
yLim = get(hAxes,'YLim');
deltaX = (position(3) - (xLim(2)-xLim(1)))/2;
deltaY = (position(4) - (yLim(2)-yLim(1)))/2;
set(hAxes,'XLim',[xLim(1)-deltaX xLim(2)+deltaX]./structAxes.zoom);
set(hAxes,'YLim',[yLim(1)-deltaY yLim(2)+deltaY]./structAxes.zoom);
settick(hAxes);

%=================================================================

function buttondownoveraxes(hAxes,eventData)
if strcmp(get(findobj('Tag','uimenu_lockup'),'Checked'),'on'), return; end
selectoffallotherobjects(hAxes);
[hRect,position] = createselectionrectangle;
set(gcf,...
    'WindowButtonMotionFcn',{@pullselectionrectangle,hRect,position(1:2),position},...
    'WindowButtonUpFcn',{@stoppullselectionrectangle,hRect});

%=================================================================

function [hRectangle,position] = createselectionrectangle
currentPoint = get(gca,'CurrentPoint');
position = [currentPoint(1,1) currentPoint(1,2) 1 1];
%     set(gca,'ButtonDownFcn','');
hRectangle = rectangle(...
    'Tag','selection',...
    'Parent',gca,...
    'Position',position,...
    'LineStyle','-.',...
    'DeleteFcn',@doselectobjects);

%=================================================================

function pullselectionrectangle(hFigure,eventData,hRectangle,point,position)
currentPoint = get(gca,'CurrentPoint');
if (currentPoint(1,1) > point(1))
    position(1) = point(1);
    position(3) = currentPoint(1,1) - point(1);
else
    position(1) = currentPoint(1,1);
    position(3) = point(1) - currentPoint(1,1);
end
if (currentPoint(1,2) > point(2))
    position(2) = point(2);
    position(4) = currentPoint(1,2) - point(2);
else
    position(2) = currentPoint(1,2);
    position(4) = point(2) - currentPoint(1,2);
end
position(find(-1 < position & position < 1)) = 1;
set(hRectangle,'Position',position);

%=================================================================

function stoppullselectionrectangle(hFigure,eventData,hRectangle)
stoppull(hFigure,eventData);
delete(hRectangle);

%=================================================================

function doselectobjects(hRect,eventData)
position = get(hRect,'Position');
if position(3) > 5 && position(4) > 5
    xLim = [position(1) position(1)+position(3)];
    yLim = [position(2) position(2)+position(4)];
    handles = get(get(hRect,'Parent'),'Children');
    handles(handles == hRect) = [];
    if ~isempty(handles)
        %number of objects which are in
        objectsIn = 0;
        for i = 1:length(handles)
            if isin(handles(i),xLim,yLim)
                objectsIn = objectsIn+1;
            end
        end
        % select in objects
        iobjectsIn = 0;
        for i = 1:length(handles)
            if isin(handles(i),xLim,yLim)
                iobjectsIn = iobjectsIn + 1;
                selectobject(handles(i),iobjectsIn==objectsIn);
            end
        end
    end
end
%    set(get(hRect,'Parent'),'ButtonDownFcn',@buttondownoveraxes);

%=================================================================

function is = isin(hObject,xLim,yLim)
is = false;
switch get(hObject,'Type')
    case 'rectangle'
        pos = get(hObject,'Position');
        pos(3) = pos(1) + pos(3);
        pos(4) = pos(2) + pos(4);
    case {'patch', 'image'}
        xData = get(hObject,'XData');
        yData = get(hObject,'YData');
        pos = [min(xData) min(yData) max(xData) max(yData)];
    otherwise
        return;
end
if (xLim(1) < pos(1)) && (xLim(2) > pos(3)) &&...
        (yLim(1) < pos(2)) && (yLim(2) > pos(4))
    is = true;
end

%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================






%=================================================================




%////////////////////////////////////////////////////////////////////
%/////////////////////////    Drawing     ///////////////////////////
%////////////////////////////////////////////////////////////////////




%=================================================================

function drawingtype(hObject,eventData)
figureData = get(gcf,'UserData');
switch lower(get(hObject,'Tag'))
    case {'toolbar_grapheditarrow','uimenu_grapheditarrow'}
        setstateandchecked('on','off','off','off');
        set(figureData.hcanvases,'ButtonDownFcn',@buttondownoveraxes);
    case {'toolbar_grapheditdrawnode','uimenu_grapheditdrawnode'}
        setstateandchecked('off','on','off','off');
        set(figureData.hcanvases,'ButtonDownFcn',@buttondownoveraxes_drawnode);
    case {'toolbar_grapheditdrawedge','uimenu_grapheditdrawedge'}
        setstateandchecked('off','off','on','off');
        set(figureData.hcanvases,'ButtonDownFcn',@buttondownoveraxes_drawedge);
    case {'toolbar_grapheditdelete','uimenu_grapheditdelete'}
        setstateandchecked('off','off','off','on');
        set(figureData.hcanvases,'ButtonDownFcn','');
    otherwise
        set(figureData.hcanvases,'ButtonDownFcn','');
end

%=================================================================

function setstateandchecked(arrow,drawNode,drawEdge,deleteMode)
set(findobj('Tag','toolbar_grapheditarrow'),'State',arrow);
set(findobj('Tag','toolbar_grapheditdrawnode'),'State',drawNode);
set(findobj('Tag','toolbar_grapheditdrawedge'),'State',drawEdge);
set(findobj('Tag','toolbar_grapheditdelete'),'State',deleteMode);
set(findobj('Tag','uimenu_grapheditarrow'),'Checked',arrow);
set(findobj('Tag','uimenu_grapheditdrawnode'),'Checked',drawNode);
set(findobj('Tag','uimenu_grapheditdrawedge'),'Checked',drawEdge);
set(findobj('Tag','uimenu_grapheditdelete'),'Checked',deleteMode);

%=================================================================




%////////////////////////////////////////////////////////////////////
%/////////////////////////   Draw node    ///////////////////////////
%////////////////////////////////////////////////////////////////////




%=================================================================

function buttondownoveraxes_drawnode(hAxes,eventData)
if strcmp(get(findobj('Tag','uimenu_lockup'),'Checked'),'on'), return; end

point = get(hAxes,'CurrentPoint');
figureData = get(get(hAxes,'Parent'),'UserData');

%     savecurrentstate;
if isempty(figureData.actualnode)
    drawnode(figureData.configuration.defaultnode,hAxes,point);
else
    drawnode(figureData.actualnode,hAxes,point);
end

%=================================================================

function hObject = drawnode(structure,hAxes,varargin)
hObject = []; mainPos.x = []; mainPos.y = [];

figureData = get(get(hAxes,'Parent'),'UserData');
if isempty(structure),
    structure = figureData.configuration.defaultnode;
end
if nargin >= 3 && ~isempty(varargin{1}),
    structure{1} = setmaintocenter(structure{1},varargin{1}(1,1:2));
else
    try
        fNames = fieldnames(structure{1});
    catch
        s{1} = structure;
        structure = s;
        fNames = fieldnames(structure{1});
    end
end
for i = 1:length(structure)
    s{1} = structure{i};
    fNames = fieldnames(s{1});
    if i > 1
        s{1}.x = structure{1}.x(1) + s{1}.x;
        s{1}.y = structure{1}.y(1) + s{1}.y;
    end
    if sum(strcmp('picture',fNames))        % image
        hObject(end+1) = createimage(s{1},hAxes);
    elseif sum(strcmp('curvature',fNames))  % rectangle
        hObject(end+1) = createrectangle(s{1},hAxes);
    else                                    % patch
        hObject(end+1) = createpatch(s{1},hAxes);
    end
    if i == 1
        objectData =  struct('allobjects',[],...
            'linewidth',[],...
            'edgecolor',[],...
            'structure',structure{i},...
            'hname',[],...
            'huserparam',[],...
            'usercallbackhandlerstruct',[],...
            'objectparams',struct('Name','',...
            'Notes','',...
            'UserParam',[],...
            'GraphicParam',[],...
            'TextParam',[]));

        objectData.usercallbackhandlerstruct.onnodecreate =  [];
        objectData.usercallbackhandlerstruct.onmove =  [];
        objectData.usercallbackhandlerstruct.onnodedelete = [];

        objectData.objectparams.GraphicParam = structure;
        objectData.objectparams.Name = getname(hAxes,'node','T');
    else
        objectData =  struct('allobjects',[],...
            'linewidth',[],...
            'edgecolor',[],...
            'structure',structure{i});
    end
    set(hObject(end),'UserData',objectData,'UIContextMenu',figureData.contextmenus.node);
end
for i = 1:length(hObject)
    objectData = get(hObject(i),'UserData');
    objectData.allobjects = hObject;
    set(hObject(i),'UserData',objectData);
end
canvasData = get(hAxes,'UserData');
canvasData.nodes(end+1) = hObject(1);
set(hAxes,'UserData',canvasData);
if nargin == 4
    copyobjectparams(hObject(1),varargin{2});
end
createtext(hObject(1),'node',figureData.configuration.textposition.nodes);
selectoffallotherobjects(hAxes);
selectobject(hObject(1));

usercallbackcall(hObject, 'onnodecreate');
usercallbackcall(get(hAxes,'Parent'), 'onnodecreate');



%=================================================================

function s = setmaintocenter(s,point)
fNames = fieldnames(s);
if sum(strcmp('picture',fNames))        % image
    deltaX = (s.x(2) - s.x(1))/2;
    deltaY = (s.y(2) - s.y(1))/2;
    s.x = point(1) + [-deltaX deltaX];
    s.y = point(2) + [-deltaY deltaY];
elseif sum(strcmp('curvature',fNames))  % rectangle
    s.x = point(1) - s.width/2;
    s.y = point(2) - s.height/2;
else                                    % patch
    deltaX = (max(s.x) - min(s.x))/2;
    deltaY = (max(s.y) - min(s.y))/2;
    s.x = point(1) + s.x + (deltaX - max(s.x));
    s.y = point(2) + s.y + (deltaY - max(s.y));
end

%=================================================================

function hRectangle = createrectangle(s,hAxes)
hRectangle = rectangle(...
    'Parent',hAxes,...
    'Tag','grapheditnode',...
    'SelectionHighlight','off',...
    'Position',[s.x,s.y,s.width,s.height],...
    'Curvature',s.curvature,...
    'FaceColor',s.facecolor,...
    'LineWidth',s.linewidth,...
    'LineStyle',s.linestyle,...
    'EdgeColor',s.edgecolor,...
    'DeleteFcn',@deletenode,...
    'ButtonDownFcn',@buttondownovernode);

function hPatch = createpatch(s,hAxes)
hPatch = patch(...
    'Parent',hAxes,...
    'Tag','grapheditnode',...
    'SelectionHighlight','off',...
    'XData',s.x,...
    'YData',s.y,...
    'LineWidth',s.linewidth,...
    'EdgeColor',s.edgecolor,...
    'FaceColor',s.facecolor,...
    'LineStyle',s.linestyle,...
    'DeleteFcn',@deletenode,...
    'ButtonDownFcn',@buttondownovernode);

function hImage = createimage(s,hAxes)
hImage = image(...
    'Parent',hAxes,...
    'Tag','grapheditnode',...
    'CData',s.cdata,...
    'XData',s.x,...
    'YData',s.y,...,...
    'UserData',s.picture,...
    'DeleteFcn',@deletenode,...
    'ButtonDownFcn',@buttondownovernode);



%=================================================================




%////////////////////////////////////////////////////////////////////
%////////////////////////   Node routins    /////////////////////////
%////////////////////////////////////////////////////////////////////




%=================================================================

function buttondownovernode(hObject,eventData)
if strcmp(get(findobj('Tag','uimenu_lockup'),'Checked'),'on'), return; end
objectData = get(hObject,'UserData');
hObject = objectData.allobjects(1);
selectionType = get(gcbf,'SelectionType');
canvasData = get(get(hObject,'Parent'),'UserData');
if strcmp(selectionType,'normal')
    %         savecurrentstate;
    if strcmp(get(findobj('Tag','uimenu_grapheditdrawedge'),'Checked'),'on')
        drawedge(hObject);
    else
        if isempty(find(canvasData.selected == hObject))
            selectoffallotherobjects(hObject);
        end
        selectobject(hObject);
        canvasData = get(get(hObject,'Parent'),'UserData');
        if strcmp(get(findobj('Tag','uimenu_grapheditdelete'),'Checked'),'on')
            delete(canvasData.selected);
            canvasData.selected = [];
            set(gca,'UserData',canvasData);
        else
            movegraphicobject(hObject,canvasData.selected);
        end
    end
elseif strcmp(selectionType,'alt')
    selectobject(hObject);
elseif strcmp(selectionType,'extend')
    if ~isempty(find(canvasData.selected == hObject))
        selectoffobject(hObject);
    else
        selectobject(hObject);
    end
elseif strcmp(selectionType,'open')
    %         selectobject(findobj('Type',get(hObject,'Type'),'Parent',gca));
end

%=================================================================

function selectobject(hObject,varargin)
% varargin{1} - callback call enabled
if isempty(varargin)
    callBackCallEnabled = 1;
else
    callBackCallEnabled = varargin{1};
end

if ~strcmp(get(hObject(1),'Type'),'axes')
    structAxes = get(get(hObject(1),'Parent'),'UserData');
    selectedBefore = structAxes.selected;
    if strcmp(get(hObject,'Type'),'line')
        structAxes.selected(end+1) = hObject;
        set(get(hObject(1),'Parent'),'UserData',structAxes);
        edgeData = get(hObject,'UserData');
        edgeData.linewidth = get(hObject,'LineWidth');
        %         edgeData.color = get(hObject,'Color');
        %         set(hObject,'UserData',edgeData,'LineWidth',3,'Color',[0 0 0],'Selected','on');
        set(hObject,'UserData',edgeData,'LineWidth',3,'Selected','on');
        set(edgeData.htips,'LineWidth',3);
        %             xData = get(hObject,'XData');
    else
        if isempty(find(structAxes.selected == hObject))
            structAxes.selected(end+1) = hObject;
            set(get(hObject(1),'Parent'),'UserData',structAxes);
            objectData = get(hObject,'UserData');
            if isfield(objectData,'allobjects')
                for i = 1:length(objectData.allobjects)
                    if strcmp(get(objectData.allobjects(i),'Type'),'rectangle') ||...
                            strcmp(get(objectData.allobjects(i),'Type'),'patch')
                        objectIData = get(objectData.allobjects(i),'UserData');
                        objectIData.linewidth = get(objectData.allobjects(i),'LineWidth');
                        objectIData.edgecolor = get(objectData.allobjects(i),'EdgeColor');
                        set(objectData.allobjects(i),'UserData',objectIData,'LineWidth',4,'EdgeColor',[0 0 0]);
                    elseif strcmp(get(objectData.allobjects(i),'Type'),'image')
                        set(objectData.allobjects(i),'Selected','on','SelectionHighlight','on');
                    end
                end
            end
        end
    end
end
grapheditpropertyeditor(hObject);
if callBackCallEnabled && exist('structAxes','var') && ...
        (length(structAxes.selected) == 1) && ...
        (length(selectedBefore)~=1 || (selectedBefore ~= structAxes.selected)) 
    usercallbackcall(hObject, 'onnodefocus')
    if strcmp(get(hObject(1),'Type'),'axes')
        usercallbackcall(get(hObject,'Parent'), {'onnodefocus',hObject})
    else
        usercallbackcall(get(get(hObject,'Parent'),'Parent'), {'onnodefocus',hObject})
    end    
end

%=================================================================

function selectoffobject(hObject)
if strcmp(get(hObject(1),'Type'),'axes')
    structAxes = get(hObject(1),'UserData');
else
    structAxes = get(get(hObject(1),'Parent'),'UserData');
end
if ~isempty(structAxes.selected)% && (hObject ~= gca)
    index = find(structAxes.selected == hObject);
    if ~isempty(index)
        structAxes.selected(index) = [];
        if strcmp(get(hObject(1),'Type'),'axes')
            set(hObject(1),'UserData',structAxes);
        else
            set(get(hObject(1),'Parent'),'UserData',structAxes);
        end
        selectoff(hObject);
    end
end
grapheditpropertyeditor(get(hObject(1),'Parent'));

%=================================================================

function selectoffallotherobjects(hObject)
if strcmp(get(hObject(1),'Type'),'axes')
    structAxes = get(hObject(1),'UserData');
else
    structAxes = get(get(hObject(1),'Parent'),'UserData');
end
selectedBefore = structAxes.selected;
if isfield(structAxes,'selected') && ~isempty(structAxes.selected)% && (hObject ~= gca)
    toRemove = 1:length(structAxes.selected);
    toRemove(structAxes.selected == hObject) = [];
    for i = toRemove,
        selectoff(structAxes.selected(i));
    end
    structAxes.selected(toRemove) = [];
    if strcmp(get(hObject(1),'Type'),'axes')
        set(hObject(1),'UserData',structAxes);
    else
        set(get(hObject(1),'Parent'),'UserData',structAxes);
    end
end

grapheditpropertyeditor(hObject);
if length(selectedBefore) == 1 && length(hObject) == 1 && ...
        hObject ~=  selectedBefore
    usercallbackcall(hObject, 'onnodeunfocus')
    if strcmp(get(hObject(1),'Type'),'axes')
        usercallbackcall(get(hObject,'Parent'), 'onnodeunfocus')
    else
        usercallbackcall(get(get(hObject,'Parent'),'Parent'), 'onnodeunfocus')
    end
end

%=================================================================

function selectoff(hObject)
objectData = get(hObject,'UserData');
if strcmp(get(hObject,'Type'),'line')
    edgeData = get(hObject,'UserData');
    %         set(hObject,'LineWidth',objectData.linewidth,'Color',objectData.color,'Selected','off');
    set(hObject,'LineWidth',objectData.linewidth,'Selected','off');
    set(edgeData.htips,'LineWidth',objectData.linewidth);
    deletelittlepoints;
    set(findobj('Tag','uimenu_editedge'),'Checked','off');
else
    if isfield(objectData,'allobjects')
        for j = 1:length(objectData.allobjects)
            if strcmp(get(objectData.allobjects(j),'Type'),'rectangle') ||...
                    strcmp(get(objectData.allobjects(j),'Type'),'patch')
                objectIData = get(objectData.allobjects(j),'UserData');
                set(objectData.allobjects(j),'LineWidth',objectIData.linewidth,'EdgeColor',objectIData.edgecolor);
            elseif strcmp(get(objectData.allobjects(j),'Type'),'image')
                set(objectData.allobjects(j),'Selected','off','SelectionHighlight','off');
            end
        end
    end
end

%=================================================================

function deleteselectedobject(hObject,eventData)
canvasData = get(gca,'UserData');
toRemove = canvasData.selected;
canvasData.selected = [];
set(gca,'UserData',canvasData);
delete(toRemove);

%=================================================================

function movegraphicobject(hObject,selected)
if ~isempty(selected)
    point = get(gca,'CurrentPoint');
    numObjects = length(selected);
    width = cell(numObjects,1);
    height = cell(numObjects,1);
    delta = cell(numObjects,1);
    xLimObjects = cell(numObjects,1);
    yLimObjects = cell(numObjects,1);
    for i = 1:numObjects
        xLim = get(gca,'XLim');
        yLim = get(gca,'YLim');
        switch get(selected(i),'Type')
            case 'rectangle'
                position = get(selected(i),'Position');
                xData = [position(1) position(1)+position(3)];
                yData = [position(2) position(2)+position(4)];
                xLim = [(xLim(1)-position(3)/2) (xLim(2)-position(3)/2)];
                yLim = [(yLim(1)-position(4)/2) (yLim(2)-position(4)/2)];
            case 'patch'
                xData = get(selected(i),'XData');
                yData = get(selected(i),'YData');
                xHalf = [xData(1)-min(xData) max(xData)-xData(1)]/2;
                yHalf = [yData(1)-min(yData) max(yData)-yData(1)]/2;
                xLim = [xLim(1) xLim(2)+xHalf(2)];
                yLim = [yLim(1)-yHalf(1) yLim(2)];
            case 'image'
                xData = get(selected(i),'XData');
                yData = get(selected(i),'YData');
                xLim(1) = xLim(1) - (xData(2)-xData(1))/2;
                xLim(2) = xLim(2) - (xData(2)-xData(1))/2;
                yLim(1) = yLim(1) - (yData(2)-yData(1))/2;
                yLim(2) = yLim(2) - (yData(2)-yData(1))/2;
            otherwise
                return;
        end
        width{i,:} = xData - xData(1);
        height{i,:} = yData - yData(1);
        delta{i,:} = [xData(1) - point(1,1)  yData(1) - point(1,2)];
        xLimObjects{i,:} = xLim;
        yLimObjects{i,:} = yLim;
    end

    if strcmp(get(findobj('Tag','toolbar_grapheditattachtogrid'),'State'),'on')
        attach = true;
    else
        attach = false;
    end

    %         canvasData = get(get(hObject,'Parent'),'UserData');
    %         hStart = []; hEnd = [];
    %         if ~isempty(canvasData.eps)
    %             hStart = canvasData.eps((canvasData.eps(:,2) == hObject),1);
    %             hEnd = canvasData.eps((canvasData.eps(:,3) == hObject),1);
    %         end
    %         [indicesStart,deltaVStart] = getmatrixindices(hStart,'start');
    %         [indicesEnd,deltaVEnd] = getmatrixindices(hEnd,'end');
    %
    %
    %         set(gcf,'WindowButtonMotionFcn',{@moving,selected,...
    %                     xLimObjects,yLimObjects,delta,width,height,attach,...
    %                     hStart,hEnd,indicesStart,indicesEnd,deltaVStart,deltaVEnd},...
    %                 'WindowButtonUpFcn',{@stopmovenode,selected});
    figureData = get(gcf,'UserData');
    reduction = figureData.configuration.edges.curvereduction;
    cellForMoving = createcellformoving(selected);
    set(gcf,'WindowButtonMotionFcn',{@moving,selected,...
        xLimObjects,yLimObjects,delta,width,height,attach,cellForMoving,reduction},...
        'WindowButtonUpFcn',{@stopmovenode,selected});
end

%=================================================================

function [indices,deltaV] = getmatrixindices(list,param)
indices = []; deltaV = [];
for i = 1:length(list)
    edgeData = get(list(i),'UserData');
    switch param
        case 'start'
            hVectorA = edgeData.vectors(1);
            hVectorB = edgeData.vectors(2);
        case 'end'
            hVectorA = edgeData.vectors(end);
            hVectorB = edgeData.vectors(end-1);
        otherwise
            hVectorA = edgeData.vectors(1);
            hVectorB = edgeData.vectors(1);
    end
    xDataA = get(hVectorA,'XData');
    yDataA = get(hVectorA,'YData');
    deltaV(i,:) = [(xDataA(2)-xDataA(1)) (yDataA(2)-yDataA(1))];
    indices(i,:) = getindices(edgeData,hVectorA,hVectorB);
end

%=================================================================

function cellForMoving = createcellformoving(handles)
cellForMoving = cell(length(handles),3);
canvasData = get(get(handles(1),'Parent'),'UserData');
for i = 1:length(handles)
    cellForMoving{i,1} = handles(i);
    if ~isempty(canvasData.eps)
        hStart = canvasData.eps((canvasData.eps(:,2) == handles(i)),1);
        hEnd = canvasData.eps((canvasData.eps(:,3) == handles(i)),1);
        [indicesStart,deltaVStart] = getmatrixindices(hStart,'start');
        [indicesEnd,deltaVEnd] = getmatrixindices(hEnd,'end');
        cellForMoving{i,2}{1} = hStart;
        cellForMoving{i,2}{2} = indicesStart;
        cellForMoving{i,2}{3} = deltaVStart;
        cellForMoving{i,3}{1} = hEnd;
        cellForMoving{i,3}{2} = indicesEnd;
        cellForMoving{i,3}{3} = deltaVEnd;
    end
end

%=================================================================

% function moving(hF,eD,handles,xLim,yLim,delta,width,height,attach,...
%                 hStart,hEnd,indicesStart,indicesEnd,deltaVStart,deltaVEnd)
function moving(hF,eD,handles,xLim,yLim,delta,width,height,attach,cellForMoving,reduction)
for i = 1:length(handles)
    point = testoflimits(getpoint(attach,delta{i,:}),xLim{i,:},yLim{i,:});
    %         canvasData = get(get(handles(i),'Parent'),'UserData');
    %         hStart = []; hEnd = [];
    %         if ~isempty(canvasData.eps)
    %             hStart = canvasData.eps((canvasData.eps(:,2) == handles(i)),1);
    %             hEnd = canvasData.eps((canvasData.eps(:,3) == handles(i)),1);
    %         end
    %         [indicesStart,deltaVStart] = getmatrixindices(hStart,'start');
    %         [indicesEnd,deltaVEnd] = getmatrixindices(hEnd,'end');
    if isempty(cellForMoving{i,2})
        hStart = []; indicesStart = []; deltaVStart = [];
        hEnd = [];   indicesEnd = [];   deltaVEnd = [];
    else
        hStart = cellForMoving{i,2}{1};
        indicesStart = cellForMoving{i,2}{2};
        deltaVStart = cellForMoving{i,2}{3};
        hEnd = cellForMoving{i,3}{1};
        indicesEnd = cellForMoving{i,3}{2};
        deltaVEnd = cellForMoving{i,3}{3};
    end
    try
        set(handles(i),'XData',point(1) + width{i,:},'YData',point(2) + height{i,:});
        [x,y] = getcenterofobject(handles(i));
        repairedges(hStart,hEnd,...
            [x,y],...
            indicesStart,indicesEnd,deltaVStart,deltaVEnd,reduction);
    catch
        set(handles(i),'Position',[point(1) point(2) width{i,:}(2) height{i,:}(2)]);
        repairedges(hStart,hEnd,...
            [point(1)+width{i,:}(2)/2 point(2)+height{i,:}(2)/2],...
            indicesStart,indicesEnd,deltaVStart,deltaVEnd,reduction);
    end
    objData = get(handles(i),'UserData');
    if isfield(objData,'allobjects')
        for j = 2:length(objData.allobjects)
            jData = get(objData.allobjects(j),'UserData');
            try
                set(objData.allobjects(j),...
                    'XData',point(1) + jData.structure.x,...
                    'YData',point(2) + jData.structure.y);
            catch
                set(objData.allobjects(j),...
                    'Position',[point(1)+jData.structure.x, point(2)+jData.structure.y,...
                    jData.structure.width, jData.structure.height]);
            end
        end
    end
    [x,y] = getcenterofobject(handles(i));
    if isfield(objData,'hname')
        set(objData.hname,'Position',[x-objData.objectparams.TextParam(1,1),...
            y-objData.objectparams.TextParam(1,2)]);
    end
    if isfield(objData,'huserparam')
        set(objData.huserparam,'Position',[x-objData.objectparams.TextParam(2,1),...
            y-objData.objectparams.TextParam(2,2)]);
    end

    usercallbackcall(handles(i), 'onmove');
end


%=================================================================

function stopmovenode(hFigure,eventData,handles)
set(gcf,...
    'WindowButtonMotionFcn','',...
    'WindowButtonDownFcn','',...
    'WindowButtonUpFcn','');
for i = 1:length(handles)
    objectData = get(handles(i),'UserData');
    if isfield(objectData,'objectparams')
        try
            objectData.objectparams.GraphicParam{1}.x = get(handles(i),'XData');
            objectData.objectparams.GraphicParam{1}.y = get(handles(i),'YData');
        catch
            position = get(handles(i),'Position');
            objectData.objectparams.GraphicParam{1}.x = position(1); %+ position(3)/2;
            objectData.objectparams.GraphicParam{1}.y = position(2);% + position(4)/2;
        end
        set(handles(i),'UserData',objectData);
    end
end

selectoffobject(handles(end));
selectobject(handles(end),0);


%=================================================================

function repairedges(hStart,hEnd,point,indicesStart,indicesEnd,deltaVStart,deltaVEnd,reduction)
if ~isempty(hStart)
    for i = 1:length(hStart)
        edgeData = get(hStart(i),'UserData');
        edgeData.mainpoints.x(1) = point(1,1);
        edgeData.mainpoints.y(1) = point(1,2);
        set(hStart(i),'UserData',edgeData);
        repairedges_repairvectors(edgeData.vectors(1),edgeData.vectors(2),point,deltaVStart(i,:));
        repairline(hStart(i),edgeData.vectors(2),edgeData.vectors(1),reduction);

    end
end
if ~isempty(hEnd)
    for i = 1:length(hEnd)
        edgeData = get(hEnd(i),'UserData');
        edgeData.mainpoints.x(end) = point(1,1);
        edgeData.mainpoints.y(end) = point(1,2);
        set(hEnd(i),'UserData',edgeData);
        repairedges_repairvectors(edgeData.vectors(end),edgeData.vectors(end-1),point,deltaVEnd(i,:));
        repairline(hEnd(i),edgeData.vectors(end),edgeData.vectors(end-1),reduction);

    end
end

%=================================================================

function repairedges_repairvectors(hVectorA,hVectorB,point,delta)
xA = get(hVectorA,'XData');
yA = get(hVectorA,'YData');
xB = get(hVectorB,'XData');
yB = get(hVectorB,'YData');
%     vectorAData = get(hVectorA,'UserData');
%     vectorBData = get(hVectorB,'UserData');

if xA(2) == xA(1),
    alphaA = pi/2;
else
    alphaA = atan(abs((yA(1)-yA(2))/(xA(1)-xA(2))));
end

if xB(1) == xB(2),
    alphaB = pi/2;
else
    alphaB = atan(abs((yB(1)-yB(2))/(xB(1)-xB(2))));
end

if xB(1) == xA(1),
    alphaC = pi/2;
else
    alphaC = atan(abs((yA(1)-yB(1))/(xB(1)-xA(1))));
end

%       [alphaA,alphaB,alphaC]
if alphaA <= (alphaB + 0.1) && alphaA >= (alphaB - 0.1) &&...
        alphaA <= (alphaC + 0.1) && alphaA >= (alphaC - 0.1),% &&...
    %  (isempty(vectorBData) || strcmp(vectorBData,'corner')),
    if point(1,1) == xB(1),
        alpha = pi/2;
    else
        alpha = atan(((point(1,2)-yB(1))/(point(1,1)-xB(1))));
    end
    deltaX = 50*cos(alpha);
    deltaY = 50*sin(alpha);
    if xB(1) < point(1,1),
        deltaX = -deltaX;      deltaY = -deltaY;
    end
    if xB(1) == point(1,1) && yB(1) < point(1,2),
        deltaY = -deltaY;
    end
    set(hVectorA,...
        'XData',[point(1,1) point(1,1)+deltaX],...
        'YData',[point(1,2) point(1,2)+deltaY]);
    set(hVectorB,...
        'XData',[xB(1) xB(1)-deltaX],...
        'YData',[yB(1) yB(1)-deltaY]);
else
    set(hVectorA,...
        'XData',[point(1,1) point(1,1)+delta(1)],...
        'YData',[point(1,2) point(1,2)+delta(2)]);
end

%=================================================================

function stoppull(hFigure,eventData)
set(hFigure,...
    'WindowButtonMotionFcn','',...
    'WindowButtonDownFcn','',...
    'WindowButtonUpFcn','');

%=================================================================

function point = getpoint(attach,varargin)
currentPoint = get(gca,'CurrentPoint');
if nargin == 2
    currentPoint(1,1) = currentPoint(1,1) + varargin{1}(1);
    currentPoint(1,2) = currentPoint(1,2) + varargin{1}(2);
end
if attach == 1
    point = [findnearest( get(gca,'XTick'), currentPoint(1,1) ),...
        findnearest( get(gca,'YTick'), currentPoint(1,2) )];
else
    point = [currentPoint(1,1) currentPoint(1,2)];
end

%=================================================================

function value = findnearest(list,value)
min = Inf;
for i = 1:length(list)
    delta = abs(list(i) - value);
    if delta <= min
        min = delta;
    else
        value = list(i-1);
        return;
    end
end

%=================================================================

function point = testoflimits(point,xLim,yLim)
if  (point(1) < xLim(1)),    point(1) = xLim(1);
elseif (point(1) > xLim(2)), point(1) = xLim(2);
end
if  (point(2) < yLim(1)),    point(2) = yLim(1);
elseif (point(2) > yLim(2)), point(2) = yLim(2);
end

%=================================================================

function deletenode(hObject,eventData)
grapheditpropertyeditor(get(hObject,'Parent'));
objectData = get(hObject,'UserData');
canvasData = get(get(hObject,'Parent'),'UserData');
canvasData.nodes(canvasData.nodes == objectData.allobjects(1)) = [];
set(get(hObject,'Parent'),'UserData',canvasData);
try
    if ishandle(objectData.hname),    delete(objectData.hname);   end
    if ishandle(objectData.huserparam),    delete(objectData.huserparam);   end
catch
end
allobjects = objectData.allobjects;
objectData.allobjects(objectData.allobjects == hObject) = [];
if ~isempty(objectData.allobjects)
    set(objectData.allobjects,'DeleteFcn','');
    delete(objectData.allobjects);
end
if ~isempty(canvasData.eps)
    edgeToDelete = [canvasData.eps((canvasData.eps(:,2) == allobjects(1)),1);...
        canvasData.eps((canvasData.eps(:,3) ==  allobjects(1)),1)];
    if ~isempty(edgeToDelete)
        delete(edgeToDelete);
    end
end
usercallbackcall(hObject, 'onnodedelete');
%=================================================================

function [x,y] = getcenterofobject(hObject)
try
    nodeData = get(hObject,'UserData');
    hNode = nodeData.allobjects(1);
catch
    hNode = hObject;
end
switch get(hNode,'Type')
    case 'rectangle'
        positionNode = get(hNode,'Position');
        x = positionNode(1) + positionNode(3)/2;
        y = positionNode(2) + positionNode(4)/2;
    case {'patch', 'image'}
        xData = get(hNode,'XData');
        yData = get(hNode,'YData');
        x = min(xData) + (max(xData) - min(xData))/2;
        y = min(yData) + (max(yData) - min(yData))/2;
    case 'line'
        xData = get(hNode,'XData');
        yData = get(hNode,'YData');
        %             index = round(length(xData)/2);
        %             x = round(xData(index-1) + (xData(index) - xData(index-1))/2);
        %             y = round(yData(index-1) + (yData(index) - yData(index-1))/2 - 16);
%         x = round(xData(1));
%         y = round(yData(1));
        index = floor(length(xData)/2);
        deltaX = xData(index+1) - xData(index);
        deltaY = yData(index+1) - yData(index);
        x = xData(index) + deltaX/2;
        y = yData(index) + deltaY/2;

    otherwise
end

%=================================================================
function actualnodereplace(h,node)
fuserd = get(h,'UserData');
fuserd.('actualnode') = node;
set(h,'UserData',fuserd);

usercallbackcall(h, 'onactualnodechange');

%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================


%=================================================================




%////////////////////////////////////////////////////////////////////
%/////////////////////////   Draw edge    ///////////////////////////
%////////////////////////////////////////////////////////////////////




%=================================================================

function drawedge(hStartNode,varargin)
[x,y] = getcenterofobject(hStartNode);
xData = [x x];
yData = [y y];
hEdge = createline(xData,yData,get(hStartNode,'Parent'),varargin{:});

edgeData = get(hEdge,'UserData');
edgeData.vectors = createvector(hEdge,[xData(1) xData(1)],[yData(1) yData(1)]);
edgeData.mainpoints.x = xData(1);
edgeData.mainpoints.y = yData(1);
edgeData.mainpoints.index = 1;
edgeData.objectparams.Name = getname(gca,'edge','e');
set(hEdge,'UserData',edgeData);

selectoffallotherobjects(gca);
selectobject(hEdge);

set(gcf,'WindowButtonMotionFcn',{@pulledge,hEdge});
set(hEdge,'ButtonDownFcn',{@createpoint,hEdge});
set(findobj('Tag','grapheditnode'),'ButtonDownFcn',{@finishedge,hEdge});

structAxes = get(gca,'UserData');
structAxes.eps(end+1,1) = hEdge;
structAxes.eps(end,2) = hStartNode;
set(gca,'UserData',structAxes);

%=================================================================

function hEdge = createline(xData,yData,hAxes,varargin)
userDataFigure = get(get(hAxes,'Parent'),'UserData');
hEdge = line(...
    'Parent',hAxes,...
    'Tag','grapheditedge',...
    'XData',xData,...
    'YData',yData,...
    'Selected','off',...        'EraseMode','xor',...
    'LineWidth',userDataFigure.configuration.edges.linewidth,...
    'LineStyle',userDataFigure.configuration.edges.linestyle,...
    'Color',userDataFigure.configuration.edges.color,...
    'SelectionHighlight','off',...
    'DeleteFcn',@deleteedge,...
    'UIContextMenu',userDataFigure.contextmenus.edge);
children = get(get(hEdge,'Parent'),'Children');
hBackground = findobj('Tag','grapheditbackground','Parent',get(hEdge,'Parent'));
%     children(children == hEdge) = [];
if ~isempty(hBackground),
    set(get(hEdge,'Parent'),'Children',[children(2:end-length(hBackground)); hEdge; children(end-length(hBackground)+1:end)]);
else
    set(get(hEdge,'Parent'),'Children',[children(2:end); hEdge]);
end
lineStructure = struct(...
    'linewidth',[],...
    'color',[],...
    'hname',[],...
    'huserparam',[],...
    'htips',[],...  % for arrow
    'arrowsize',userDataFigure.configuration.arrowsize,...
    'vectors',[],... % for handles of vectors
    'mainpoints',struct('x',[],'y',[],'index',[]),...
    'objectparams',struct('Name','',...
    'Notes','',...
    'UserParam',[],...
    'Color',get(hEdge,'Color'),...
    'LineStyle',get(hEdge,'LineStyle'),...
    'LineWidth',get(hEdge,'LineWidth'),...
    'Arrow',[],...
    'TextParam',[]));
set(hEdge,'UserData',lineStructure);
if nargin == 4
    copyobjectparams(hEdge,varargin{1});
    if iscolor(varargin{1}.Color)
        set(hEdge,'Color',varargin{1}.Color);
    end
    if isnumeric(varargin{1}.LineWidth)&&isscalar(varargin{1}.LineWidth)
        set(hEdge,'LineWidth',varargin{1}.LineWidth);
    end
    if ~isempty(varargin{1}.LineStyle)
        set(hEdge,'LineStyle',varargin{1}.LineStyle);
    end
end
makearrow(hEdge,userDataFigure.configuration.edges.viewarrows);


%=================================================================

function hEdge = drawedgeatonce(objEdge,hAxes,node1,node2,reduction)
xData = [];   yData = [];   vectors = [];
cellOfStructs = objEdge.Position;
[x1,y1] = getcenterofobject(node1);
if isempty(cellOfStructs)
    if isequal(node1,node2) % Self loop
        [x2,y2] = getcenterofgraph(hAxes);
        if x1 == x2,
            alpha = pi/2;
        else
            alpha = atan((y2 - y1)/(x2 - x1));
        end
        %             deltaX = x2 - x1;  if deltaX == 0,  deltaX = 0.0001; end
        %             deltaY = y2 - y1;
        %             alpha = atan(deltaY/deltaX);
        if x2 > x1,
            alpha = alpha + pi;
        end
        beta = alpha + pi/5;
        gama = alpha - pi/5;
        vectorAX = 40*cos(beta);          vectorAY = 40*sin(beta);
        vectorBX = 40*cos(gama);          vectorBY = 40*sin(gama);
        cellOfStructs{1}.x = x1;          cellOfStructs{1}.y = y1;
        cellOfStructs{1}.xIn = vectorAX;  cellOfStructs{1}.yIn = vectorAY;
        cellOfStructs{1}.xOut = vectorBX; cellOfStructs{1}.yOut = vectorBY;
        cellOfStructs{1}.pair = '';
    else
        [x2,y2] = getcenterofobject(node2);
        if x2 == x1,
            alpha = pi/2;%                 deltaX = 0.01;
        else
            alpha = atan((y2-y1)/(x2-x1));%                 deltaX = (x2-x1);
        end
        deltaX = 50*cos(alpha);
        deltaY = 50*sin(alpha);
        if (x1 > x2) && (y1 > y2) || (x1 > x2) && (y1 < y2),
            deltaX = -deltaX;
            deltaY = -deltaY;
        end
        cellOfStructs{1}.x = x1;        cellOfStructs{1}.y = y1;
        cellOfStructs{1}.xIn = -Inf;    cellOfStructs{1}.yIn = -Inf;
        cellOfStructs{1}.xOut = deltaX; cellOfStructs{1}.yOut = deltaY;
        cellOfStructs{1}.pair = '';
        cellOfStructs{2}.x = x2;        cellOfStructs{2}.y = y2;
        cellOfStructs{2}.xIn = -deltaX; cellOfStructs{2}.yIn = -deltaY;
        cellOfStructs{2}.xOut = -Inf;   cellOfStructs{2}.yOut = -Inf;
        cellOfStructs{2}.pair = '';
    end
else
    if isequal(node1,node2) % Self loop
        cellOfStructs{1}.x = x1;
        cellOfStructs{1}.y = y1;
        cellOfStructs{end}.x = x1;
        cellOfStructs{end}.y = y1;
    else
        [x2,y2] = getcenterofobject(node2);
        if cellOfStructs{1}.x ~= x1 || cellOfStructs{1}.y ~= y1 ||...
                cellOfStructs{end}.x ~= x2 || cellOfStructs{end}.y ~= y2,
            cellOfStructs = drawedgeatonce_repairvectors(cellOfStructs,x1,y1,x2,y2);
        end
    end
end
objEdge.Position = cellOfStructs;
for i = 1:length(cellOfStructs)
    xData(end+1) = cellOfStructs{i}.x;
    yData(end+1) = cellOfStructs{i}.y;
end
if length(xData) == 1, xData(end+1) = xData(end); end
if length(yData) == 1, yData(end+1) = yData(end); end
hEdge = createline(xData,yData,hAxes,objEdge);
set(hEdge,'ButtonDownFcn',@buttondownoveredge);
for i = 1:length(cellOfStructs)
    if cellOfStructs{i}.xIn ~= -Inf
        vectors(end+1) = createvector(hEdge,...
            [xData(i), xData(i)+cellOfStructs{i}.xIn],...
            [yData(i), yData(i)+cellOfStructs{i}.yIn],cellOfStructs{i}.pair);
    end
    if cellOfStructs{i}.xOut ~= -Inf
        vectors(end+1) = createvector(hEdge,...
            [xData(i), xData(i)+cellOfStructs{i}.xOut],...
            [yData(i), yData(i)+cellOfStructs{i}.yOut],cellOfStructs{i}.pair);
    end
end
edgeData = get(hEdge,'UserData');
edgeData.vectors = vectors;
edgeData.mainpoints.x = xData;
edgeData.mainpoints.y = yData;
edgeData.mainpoints.index = 1:length(xData);
set(hEdge,'UserData',edgeData);
drawedgeatonce_repairline(hEdge,node1,node2,reduction);
figureData = get(get(hAxes,'Parent'),'UserData');
createtext(hEdge,'edge',figureData.configuration.textposition.edges);

%=================================================================

function strs = drawedgeatonce_repairvectors(strs,x1,y1,x2,y2)
if length(strs) == 2,
    strs = drawedgeatonce_repairvectors_calculation(strs,x1,y1,x2,y2,[]);
else
    strs = drawedgeatonce_repairvectors_calculation(strs,x1,y1,1,2,'init');
    strs = drawedgeatonce_repairvectors_calculation(strs,x2,y2,length(strs)-1,length(strs),'term');
end
strs{1}.x = x1;
strs{1}.y = y1;
strs{end}.x = x2;
strs{end}.y = y2;

%=================================================================

function strs = drawedgeatonce_repairvectors_calculation(strs,x1,y1,i1,i2,type)
if isempty(type),
    x2 = i1;       y2 = i2;
    i1 = 1;        i2 = 2;
end

if strs{i1}.xOut ~= 0,
    k1 = strs{i1}.yOut/strs{i1}.xOut;
else
    k1 = inf;%sign(strs{i1}.yOut)*inf;
end
if strs{i1}.xOut ~= 0,
    k2 = strs{i2}.yIn/strs{i2}.xIn;
else
    k2 = inf;%sign(strs{i2}.yIn)*inf;
end
if (strs{i1}.x-strs{i2}.x) ~= 0,
    k3 = (strs{i1}.y-strs{i2}.y)/(strs{i1}.x-strs{i2}.x);
else
    k3 = inf;%sign(strs{i1}.y-strs{i2}.y)*inf;
end
%    [k1 k2 k3]
if round(100*k1)/100 == round(100*k2)/100 && round(100*k1)/100 == round(100*k3)/100,
    q1 = strs{i1}.y - k1*strs{i1}.x;
    q2 = strs{i2}.y - k2*strs{i2}.x;
    q3 = strs{i1}.y - k3*strs{i1}.x;
    %        [q1 q2 q3]
    if round(q1) == round(q2) && round(q1) == round(q3),
        if isempty(type),
            if x1 ~= x2,
                k = (y1-y2)/(x1-x2);
            else
                k = sign(y1-y2)*inf;
            end
        else
            if strcmp(type,'init'),
                k = (y1-strs{i2}.y)/(x1-strs{i2}.x);
            else
                k = (strs{i1}.y-y1)/(strs{i1}.x-x1);
            end
        end
        %             q = y1 - k*x1;

        if k ~= 0,
            strs{i1}.yOut = sqrt((strs{i1}.xOut^2 + strs{i1}.yOut^2) / (1+k^(-2)));
            strs{i1}.xOut = strs{i1}.yOut/k;
        else
            strs{i1}.xOut = -sqrt(strs{i1}.xOut^2 + strs{i1}.yOut^2);
            strs{i1}.yOut = 0;
        end

        if strs{i1}.x <= strs{i2}.x && strs{i1}.y >= strs{i2}.y,
            strs{i1}.yOut = -strs{i1}.yOut;
            strs{i1}.xOut = -strs{i1}.xOut;
        end
        if strs{i1}.x == strs{i2}.x && strs{i1}.y < strs{i2}.y,
            %                 strs{i1}.yOut = -strs{i1}.yOut;
        end

        strs{i2}.yIn = -strs{i1}.yOut;
        strs{i2}.xIn = -strs{i1}.xOut;
    end
end

%=================================================================

function [x,y] = getcenterofgraph(hAxes)
minX = inf; maxX = -inf; minY = inf; maxY = -inf;
hNodes = findobj('Parent',hAxes,'Tag','grapheditnode');
for i = 1:length(hNodes)
    try
        position = get(hNodes(i),'Position');
        center = [position(1)+position(3)/2, position(2)+position(4)/2];
    catch
        xData = get(hNodes(i),'XData');
        yData = get(hNodes(i),'YData');
        center = [min(xData)+(max(xData)-min(xData))/2,...
            min(yData)+(max(yData)-min(yData))/2];
    end
    if center(1) < minX,  minX = center(1);  end
    if center(1) > maxX,  maxX = center(1);  end
    if center(2) < minY,  minY = center(2);  end
    if center(2) > maxY,  maxY = center(2);  end
end
x = minX + (maxX - minX)/2;
y = minY + (maxY - minY)/2;

%=================================================================

function drawedgeatonce_repairline(hEdge,node1,node2,reduction)
edgeData = get(hEdge,'UserData');
for i = 1:2:(length(edgeData.vectors)-1)
    %         xDataA = get(edgeData.vectors(i),'XData');
    %         yDataA = get(edgeData.vectors(i),'YData');
    %         xDataB = get(edgeData.vectors(i+1),'XData');
    %         yDataB = get(edgeData.vectors(i+1),'YData');
    %         indices = getindices(hEdge,edgeData.vectors(i),edgeData.vectors(i+1));
    repairline(hEdge,edgeData.vectors(i),edgeData.vectors(i+1),reduction,node1,node2);
end

%=================================================================

function makearrow(hEdge,visible)
lineData = get(hEdge,'UserData');
hLine1 = line('Parent',get(hEdge,'Parent'),'Color',get(hEdge,'Color'),'LineWidth',get(hEdge,'LineWidth'),'Tag','graphedit_arrow','Visible',visible);
hLine2 = line('Parent',get(hEdge,'Parent'),'Color',get(hEdge,'Color'),'LineWidth',get(hEdge,'LineWidth'),'Tag','graphedit_arrow','Visible',visible);
lineData.htips = [hLine1 hLine2];
set(hEdge,'UserData',lineData);
%     setarrowposition(hEdge);

%=================================================================

function setarrowposition(hEdge,varargin)
if nargin == 3,
    hNode = varargin{2};
else
    canvasData = get(gca,'UserData');
    try
        hNode = canvasData.eps(canvasData.eps(:,1) == hEdge,3);
    catch
        hNode = [];
    end
end
lineData = get(hEdge,'UserData');
xData = get(hEdge,'XData');
yData = get(hEdge,'YData');

try                                               % rectangle
    nodePosition = get(hNode,'Position');
    %         if nodePosition(3) == nodePosition(4),          % square
    %             curvature = get(hNode,'Curvature');
    %             if curvature(1) == 1,                       % circle
    radius = nodePosition(3)/2;
    deltaXData = xData(1:end-1) - xData(end);
    deltaYData = yData(1:end-1) - yData(end);
    for i = (length(xData)-1):-1:1,
        if deltaXData(i)^2 + deltaYData(i)^2 > radius^2,
            break;
        end
    end
    dx = xData(i) - xData(i+1);
    dy = yData(i) - yData(i+1);
    partsLength = norm([dx dy]);
    dx = dx/partsLength;
    dy = dy/partsLength;
    xTip = xData(end) + radius*dx;
    yTip = yData(end) + radius*dy;
    k = lineData.arrowsize;
    x = xTip + dx*k;
    y = yTip + dy*k;
    set(lineData.htips(1),'XData',[xTip x-dy*k;],'YData',[yTip y+dx*k]);
    set(lineData.htips(2),'XData',[xTip x+dy*k;],'YData',[yTip y-dx*k]);
    %             else
    %                 radius = nodePosition(3)/2;
    %                 squareSize = radius - radius*curvature(1);
    %             end
    %         else
    %         end

catch
    index = 0;

    dx = xData(end-index) - xData(end-index-1);
    dy = yData(end-index) - yData(end-index-1);
    lengthh = norm([dx dy]);
    if(lengthh == 0), lengthh = 1; end
    dx = dx/lengthh;
    dy = dy/lengthh;
    %
    %     xData(1) = xData(1) + dx*radius;
    %     yData(1) = yData(1) + dy*radius;
    %     xData(2) = xData(2) - dx*radius;
    %     yData(2) = yData(2) - dy*radius;
    %     set(hEdge,'XData',xData,'YData',yData);
    %
    k = 8;%0.4 * radius;
    x = xData(end-index) - dx*k;
    y = yData(end-index) - dy*k;

    xData(1) = x - dy*k;
    yData(1) = y + dx*k;
    set(lineData.htips(1),'XData',[xData(end-index) xData(1)],'YData',[yData(end-index) yData(1)]);
    xData(1) = x + dy*k;
    yData(1) = y - dx*k;
    set(lineData.htips(2),'XData',[xData(end-index) xData(1)],'YData',[yData(end-index) yData(1)]);
end

%=================================================================

function deleteedge(hEdge,eventData)
stoppull(gcf,eventData);
set(findobj('Tag','grapheditnode'),'ButtonDownFcn',@buttondownovernode);
edgeData = get(hEdge,'UserData');
deletelittlepoints;
canvasData = get(get(hEdge,'Parent'),'UserData');
canvasData.eps(canvasData.eps(:,1) == hEdge,:) = [];
set(get(hEdge,'Parent'),'UserData',canvasData);
if ishandle(edgeData.hname),    delete(edgeData.hname);   end
if ishandle(edgeData.huserparam),    delete(edgeData.huserparam);   end
if ishandle(edgeData.htips(1)),    delete(edgeData.htips);   end
try
    delete(edgeData.vectors);
catch
end

%=================================================================

function deletelittlepoints
hLittlePoints = findobj('Tag','littlepoint');
if ~isempty(hLittlePoints)
    set(hLittlePoints,'DeleteFcn','');
    delete(hLittlePoints);
    set(findobj('Tag','vector'),'Visible','off');
end

%=================================================================

function hVector = createvector(hEdge,x,y,varargin)
pair = 'corner';
if nargin == 4,    pair = varargin{1};    end
hVector = line(...
    'Parent',get(hEdge,'Parent'),...
    'Tag','vector',...
    'XData',x,...
    'YData',y,...        'EraseMode','xor',...
    'LineWidth',0.5,...
    'Color','blue',...
    'SelectionHighlight','off',...
    'Marker','o',...
    'Visible','off',...
    'UserData',pair,...
    'ButtonDownFcn',{@buttondownovervector,hEdge});


%=================================================================

function pulledge(hFigure,eventData,hEdge)
point = get(gca,'CurrentPoint');
xData = get(hEdge,'XData');
yData = get(hEdge,'YData');
xData(end) = point(1,1);
yData(end) = point(1,2);
set(hEdge,'XData',xData,'YData',yData);

%=================================================================

function createpoint(hAxes,eventData,hEdge)
if strcmp(get(gcbf,'SelectionType'),'normal')
    point = get(gca,'CurrentPoint');
    edgeData = get(hEdge,'UserData');
    xData = get(hEdge,'XData');
    yData = get(hEdge,'YData');
    edgeData.mainpoints.x(end+1) = xData(end);
    edgeData.mainpoints.y(end+1) = yData(end);
    edgeData.mainpoints.index(end+1) = length(xData);
    set(hEdge,'UserData',edgeData);
    % create two inner vectors and repair the last vector
    createinnervectors(hEdge);
    edgeData = get(hEdge,'UserData');
    createpoint_repairline(hEdge,edgeData.vectors(end-1),edgeData.vectors(end-2));
    xData = get(hEdge,'XData');
    yData = get(hEdge,'YData');
    xData(end+1) = point(1,1);
    yData(end+1) = point(1,2);
    set(hEdge,'XData',xData,'YData',yData);
end

%=================================================================

function createinnervectors(hEdge)
edgeData = get(hEdge,'UserData');
x = edgeData.mainpoints.x;
y = edgeData.mainpoints.y;
edgeData.vectors = addvector(hEdge,edgeData.vectors,x,y);
hVectorOut = createvector(hEdge,[x(end) x(end)],[y(end) y(end)]);
edgeData.vectors = [edgeData.vectors hVectorOut];
set(hEdge,'UserData',edgeData);

%=================================================================

function vectors = addvector(hEdge,vectors,x,y)
if x(end) == x(end-1),
    alpha = pi/2;
else
    alpha = atan(((y(end)-y(end-1))/(x(end)-x(end-1))));
end
%     alpha = atan(abs((y(end)-y(end-1))/deltaX));
deltaX = 50*cos(alpha);
deltaY = 50*sin(alpha);

if x(end) == x(end-1) && y(end) > y(end-1),
    deltaY = -deltaY;
end

if (x(end-1) >= x(end))
    set(vectors(end),...
        'XData',[x(end-1) (x(end-1)-deltaX)],...
        'YData',[y(end-1) (y(end-1)-deltaY)]);
    newVector = createvector(hEdge,...
        [x(end) x(end)+deltaX],...
        [y(end) y(end)+deltaY]);
else
    set(vectors(end),...
        'XData',[x(end-1) (x(end-1)+deltaX)],...
        'YData',[y(end-1) (y(end-1)+deltaY)]);
    newVector = createvector(hEdge,...
        [x(end) x(end)-deltaX],...
        [y(end) y(end)-deltaY]);
end
vectors = [vectors newVector];

%=================================================================

function createpoint_repairline(hEdge,hVectorA,hVectorB)
%     xDataA = get(hVectorA,'XData');
%     yDataA = get(hVectorA,'YData');
%     xDataB = get(hVectorB,'XData');
%     yDataB = get(hVectorB,'YData');
%     indices = getindices(hEdge,[xDataA(1) yDataA(1)],[xDataB(1) yDataB(1)]);
%     indices = getindices(hEdge,hVectorA,hVectorB);
figureData = get(gcf,'UserData');
repairline(hEdge,hVectorA,hVectorB,figureData.configuration.edges.curvereduction);

%=================================================================

function indices = getindices(edgeData,hVectorA,hVectorB)
%     edgeData = get(hEdge,'UserData');
vectIndexA = findvector(edgeData.vectors,hVectorA);
vectIndexB = findvector(edgeData.vectors,hVectorB);
index1 = edgeData.mainpoints.index(vectIndexA);
try
    index2 = edgeData.mainpoints.index(vectIndexB);
catch
    index2 = index1;
end
indices = sort([index1 index2]);


function vectIndex = findvector(vectors,hVector)
vectIndex = find(vectors == hVector);
if mod(vectIndex,2) == 1
    vectIndex = (vectIndex+1)/2;
else
    vectIndex = (vectIndex+2)/2;
end


% function indices = getindices2(hEdge,values1,values2)
%     xDataE = get(hEdge,'XData');
%     yDataE = get(hEdge,'YData');
%     edgeData = get(hEdge,'UserData');
%     index1 = find((xDataE == values1(1)) & (yDataE == values1(2)));
%     if isempty(index1)
% %         xDataV = get(edgeData.vectors(1),'XData');
% %         yDataV = get(edgeData.vectors(1),'YData');
% %         xDataE = [xDataV(1) xDataE];
% %         yDataE = [yDataV(1) yDataE];
%         index1 = 1;
%     end
%     index2 = find((xDataE == values2(1)) & (yDataE == values2(2)));
%     if isempty(index2)
% %         xDataV = get(edgeData.vectors(end),'XData');
% %         yDataV = get(edgeData.vectors(end),'YData');
% %         xDataE = [xDataE xDataV(1)];
% %         yDataE = [yDataE yDataV(1)];
%         index2 = length(xDataE);
%     end
%     set(hEdge,'XData',xDataE,'YData',yDataE);
%     indices = sort([index1 index2]);

%=================================================================

function repairline(hEdge,hVectorA,hVectorB,reduction,varargin)
if hVectorA < hVectorB,
    tmp = hVectorB;
    hVectorB = hVectorA;
    hVectorA = tmp;
end
xDataE = get(hEdge,'XData');
yDataE = get(hEdge,'YData');
edgeData = get(hEdge,'UserData');
xDataA = get(hVectorA,'XData');
yDataA = get(hVectorA,'YData');
xDataB = get(hVectorB,'XData');
yDataB = get(hVectorB,'YData');
% edgeData.mainpoints.index
%     [x,y] = thisbezier(...
%             xDataA(1),yDataA(1),[(xDataA(2)-xDataA(1)) (yDataA(2)-yDataA(1))],...
%             xDataB(1),yDataB(1),[(xDataB(2)-xDataB(1)) (yDataB(2)-yDataB(1))]);

[x,y] = bezier(xDataA(1), yDataA(1),...
    2*(xDataA(2)-xDataA(1))+xDataA(1), 2*(yDataA(2)-yDataA(1))+yDataA(1),...
    2*(xDataB(2)-xDataB(1))+xDataB(1), 2*(yDataB(2)-yDataB(1))+yDataB(1),...
    xDataB(1), yDataB(1),...
    reduction);

indices = getindices(edgeData,hVectorA,hVectorB);
maxIndex = max(edgeData.mainpoints.index);
if length(xDataE) < maxIndex,
    maxIndex = length(xDataE);
end

if (x(1) ~= xDataE(indices(1)) || y(1) ~= yDataE(indices(1))) ||...
        (x(1) == x(end) && y(1) == y(end) && hVectorA > hVectorB),
    x = x(end:-1:1);
    y = y(end:-1:1);
end

xDataE = [xDataE(1:(indices(1)-1)) x xDataE((indices(2)+1):maxIndex)];
yDataE = [yDataE(1:(indices(1)-1)) y yDataE((indices(2)+1):maxIndex)];
%     [length(xDataE) max(edgeData.mainpoints.index)]
edgeData.mainpoints.index = reindex(edgeData.mainpoints.index,indices,length(x));
set(hEdge,'XData',xDataE,'YData',yDataE,'UserData',edgeData);
%      edgeData.mainpoints.index
repairlinetext(hEdge,xDataE,yDataE);
setarrowposition(hEdge,varargin{:});

%=================================================================

function indexField = reindex(indexField,indices,newLength)
delta = newLength - (indices(2) - indices(1));
index = find(indexField == indices(2));
indexField(index:end) = indexField(index:end) + delta - 1;

%=================================================================

function repairlinetext(hEdge,xDataE,yDataE)
edgeData = get(hEdge,'UserData');
% xCenter = round(xDataE(1));
% yCenter = round(yDataE(1));
index = floor(length(xDataE)/2);
deltaX = xDataE(index+1) - xDataE(index);
deltaY = yDataE(index+1) - yDataE(index);
% alpha = atan2(deltaY,deltaX);
xCenter = xDataE(index) + deltaX/2;
yCenter = yDataE(index) + deltaY/2;
if ~isempty(edgeData.hname)
    x = edgeData.objectparams.TextParam(1,1);
    y = edgeData.objectparams.TextParam(1,2);
    set(edgeData.hname,'Position',[xCenter - x, yCenter - y]);
end
if ~isempty(edgeData.huserparam)
    x = edgeData.objectparams.TextParam(2,1);
    y = edgeData.objectparams.TextParam(2,2);
    set(edgeData.huserparam,'Position',[xCenter - x, yCenter - y]);
%     set(edgeData.huserparam,'Position',[xCenter - x, yCenter - y]);
end
set(hEdge,'UserData',edgeData);

%=================================================================

function [x,y] = thisbezier(x1,y1,d1,x2,y2,d2)
%    http://www.moshplant.com/direct-or//
x0 = x1;   x1 = x1 + 2*d1(1);
y0 = y1;   y1 = y1 + 2*d1(2);

x3 = x2;   x2 = x2 + 2*d2(1);
y3 = y2;   y2 = y2 + 2*d2(2);

%     [ax,bx,cx] = getcoefficients(x0,x1,x2,x3);
%     [ay,by,cy] = getcoefficients(y0,y1,y2,y3);
%     t = 0:0.01:1;
%
%     x = ax*t.^3 + bx*t.^2 + cx*t + x0;
%     y = ay*t.^3 + by*t.^2 + cy*t + y0;

[x,y] = bezier(x0,y0,x1,y1,x2,y2,x3,y3);

%=================================================================

% function [a,b,c] = getcoefficients(x0,x1,x2,x3)
%     c = 3 * (x1 - x0);
%     b = 3 * (x2 - x1) - c;
%     a = x3 - x0 - c - b;

%=================================================================

function finishedge(hObject,eventData,hEdge)
objectData = get(hObject,'UserData');
hEndNode = objectData.allobjects(1);
[x,y] = getcenterofobject(hEndNode);
xData = get(hEdge,'XData');
yData = get(hEdge,'YData');
xData(end) = x;
yData(end) = y;
set(hEdge,'XData',xData,'YData',yData);

edgeData = get(hEdge,'UserData');
edgeData.mainpoints.x(end+1) = xData(end);
edgeData.mainpoints.y(end+1) = yData(end);
edgeData.mainpoints.index(end+1) = edgeData.mainpoints.index(end) + 1;
set(gcf,'WindowButtonMotionFcn','',...
    'WindowButtonDownFcn','',...
    'WindowButtonUpFcn',@setbuttondownfcnfornode);
set(hEdge,'ButtonDownFcn',@buttondownoveredge);
set(findobj('Tag','grapheditnode'),'ButtonDownFcn','');

structAxes = get(gca,'UserData');
if structAxes.eps(end,2) ~= hEndNode || length(edgeData.mainpoints.index) > 2
    edgeData.vectors = addvector(...
        hEdge,edgeData.vectors,...
        edgeData.mainpoints.x,edgeData.mainpoints.y);
else
    % Self loop
    [x1,y1] = getcenterofobject(hEndNode);
    [x2,y2] = getcenterofgraph(get(hEdge,'Parent'));
    deltaX = x2 - x1;  if deltaX == 0,  deltaX = 0.0001;  end
    deltaY = y2 - y1;
    alpha = atan(deltaY/deltaX);
    if deltaX > 0,  alpha = alpha + pi;  end
    beta = alpha + pi/5;
    gama = alpha - pi/5;
    vectorAX = 40*cos(beta);          vectorAY = 40*sin(beta);
    vectorBX = 40*cos(gama);          vectorBY = 40*sin(gama);
    set(edgeData.vectors(end),'XData',[x1, x1+vectorAX],'YData',[y1, y1+vectorAY]);
    edgeData.vectors(end+1) = createvector(hEdge,[x1, x1+vectorBX],[y1, y1+vectorBY],'');
end
set(hEdge,'UserData',edgeData);
structAxes.eps(end,3) = hEndNode;
set(gca,'UserData',structAxes);

createpoint_repairline(hEdge,edgeData.vectors(end-1),edgeData.vectors(end));

figureData = get(gcf,'UserData');
createtext(hEdge,'edge',figureData.configuration.textposition.edges);
selectoffobject(hEdge);
selectobject(hEdge);

%=================================================================

function setbuttondownfcnfornode(hFigure,eventData)
set(findobj('Tag','grapheditnode'),'ButtonDownFcn',@buttondownovernode);
set(hFigure,'WindowButtonUpFcn','');

%=================================================================

function buttondownoveredge(hEdge,eventData)
if strcmp(get(findobj('Tag','uimenu_lockup'),'Checked'),'on'), return; end
selectionType = get(gcbf,'SelectionType');
canvasData = get(gca,'UserData');
if strcmp(selectionType,'normal')
    if isempty(find(canvasData.selected == hEdge))
        selectoffallotherobjects(hEdge);
        selectobject(hEdge);
    end
    canvasData = get(gca,'UserData');
    if strcmp(get(findobj('Tag','uimenu_grapheditdelete'),'Checked'),'on')
        delete(canvasData.selected);
        canvasData.selected = [];
        set(gca,'UserData',canvasData);
    end
elseif strcmp(selectionType,'alt')
    if isempty(find(canvasData.selected == hEdge))
        selectobject(hEdge);
    end
elseif strcmp(selectionType,'extend')
    if ~isempty(find(canvasData.selected == hEdge))
        selectoffobject(hEdge);
    else
        selectobject(hEdge);
    end
elseif strcmp(selectionType,'open')
    %         selectobject(findobj('Type',get(hObject,'Type'),'Parent',gca));
end

%=================================================================

function menu_edit(hMenu,eventData)
%     hEdge = findobj('Type','line','Selected','on');
%     hEdge = hEdge(end);
hEdge = gco;
%    lineStructure = get(hEdge,'UserData');
if strcmp(get(hMenu,'Checked'),'off')
    set(hMenu,'Checked','on');
    createlittlepoints(hEdge);
    %        set(lineStructure.vectors,'Visible','on');
else
    set(hMenu,'Checked','off');
    turnoffeditmode(hMenu);
    %        set(lineStructure.vectors,'Visible','off');
end

function turnoffeditmode(hMenu)
set(hMenu,'Checked','off');
set(findobj('Tag','vector'),'Visible','off');
hPoints = findobj('Tag','littlepoint');
set(hPoints,'DeleteFcn','');
delete(hPoints);

%=================================================================

function createlittlepoints(hEdge)
edgeData = get(hEdge,'UserData');
x = edgeData.mainpoints.x;
y = edgeData.mainpoints.y;

if x(1) == x(end) && y(1) == y(end),
    createlittlepiont(hEdge,x(1),y(1),1,edgeData.vectors([1,end]));
else
    createlittlepiont(hEdge,x(1),y(1),1,edgeData.vectors(1));
    createlittlepiont(hEdge,x(end),y(end),length(x),edgeData.vectors(end));
end
vIndex = 0;
for i = 2:(length(x)-1)
    createlittlepiont(hEdge,x(i),y(i),i,...
        edgeData.vectors((i+vIndex):(i+vIndex+1)));
    vIndex = vIndex + 1;
end

%=================================================================

function createlittlepiont(hEdge,x,y,index,vectors)
figureData = get(gcf,'UserData');
hRect = rectangle(...
    'Tag','littlepoint',...
    'Selected','off',...        'EraseMode','xor',...
    'Position',[x-5 y-5 10 10],...
    'ButtonDownFcn',@buttondownoverlittlepoint,...
    'UserData',struct('edge',hEdge,'index',index,'vectors',vectors),...
    'UIContextMenu',figureData.contextmenus.littlepoint,...
    'DeleteFcn',{@deletelittlepoint,index});
if length(vectors) == 1
    set(hRect,'UIContextMenu','');
end

%=================================================================

function buttondownoverlittlepoint(hPoint,eventData)
if strcmp(get(findobj('Tag','uimenu_lockup'),'Checked'),'on'), return; end
pointData = get(hPoint,'UserData');

set(get(gca,'Children'),'Selected','off');
set(findobj('Tag','littlepoint'),'LineWidth',0.5,'Selected','off');
set(findobj('Tag','vector'),'Visible','off');
set(hPoint,'LineWidth',2.5,'Selected','on');
set(pointData.vectors,'Visible','on');

if strcmp(get(gcbf,'SelectionType'),'normal')
    %         savecurrentstate;
    edgeData = get(pointData.edge,'UserData');
    if length(pointData.vectors) == 2 &&...
            (edgeData.mainpoints.x(1) ~= edgeData.mainpoints.x(end) ||...
            edgeData.mainpoints.y(1) ~= edgeData.mainpoints.y(end)),
        hVectorA1 = pointData.vectors(1);
        hVectorA2 = pointData.vectors(2);
        hVectorB1 = getoppositevector(hVectorA1,edgeData.vectors);
        hVectorB2 = getoppositevector(hVectorA2,edgeData.vectors);

        %             xDataA1 = get(hVectorA1,'XData');
        %             yDataA1 = get(hVectorA1,'YData');
        %             xDataB1 = get(hVectorB1,'XData');
        %             yDataB1 = get(hVectorB1,'YData');
        %             xDataA2 = get(hVectorA2,'XData');
        %             yDataA2 = get(hVectorA2,'YData');
        %             xDataB2 = get(hVectorB2,'XData');
        %             yDataB2 = get(hVectorB2,'YData');
        %             indices1 = getindices(pointData.edge,[xDataA1(1) yDataA1(1)],[xDataB1(1) yDataB1(1)]);
        %             indices2 = getindices(pointData.edge,[xDataA2(1) yDataA2(1)],[xDataB2(1) yDataB2(1)]);
        %             indices1 = getindices(pointData.edge,hVectorA1,hVectorB1);
        %             indices2 = getindices(pointData.edge,hVectorA2,hVectorB2);
        figureData = get(gcf,'UserData');
        set(gcf,...
            'WindowButtonUpFcn',@stopmove,...
            'WindowButtonMotionFcn',{@movinglittlepoint,hPoint,pointData.edge,...
            hVectorA1,hVectorB1,hVectorA2,hVectorB2,[],[],...
            getdeltavector(hVectorA1),getdeltavector(hVectorA2),...
            figureData.configuration.edges.curvereduction});
    end
elseif strcmp(get(gcbf,'SelectionType'),'alt')
    setmenubinding(pointData);
end

%=================================================================

function stopmove(hFigure,eventData)
set(gcf,'WindowButtonMotionFcn','','WindowButtonUpFcn','');

%=================================================================

function movinglittlepoint(hFigure,eventData,hPoint,hEdge,...
    hVectorA1,hVectorB1,hVectorA2,hVectorB2,indices1,indices2,deltaV1,deltaV2,reduction)
point = get(gca,'CurrentPoint');
pointData = get(hPoint,'UserData');

pos = get(hPoint,'Position');
pos = [point(1,1)-pos(3)/2 point(1,2)-pos(4)/2 pos(3) pos(4)];
set(hPoint,'Position',pos);

%     set(hVectorA1,'XData',[point(1,1) point(1,1)+deltaV1(1)],...
%                   'YData',[point(1,2) point(1,2)+deltaV1(2)]);
%     set(hVectorA2,'XData',[point(1,1) point(1,1)+deltaV2(1)],...
%                   'YData',[point(1,2) point(1,2)+deltaV2(2)]);

edgeData = get(pointData.edge,'UserData');
edgeData.mainpoints.x(pointData.index) = point(1,1);
edgeData.mainpoints.y(pointData.index) = point(1,2);
set(pointData.edge,'UserData',edgeData);

repairedges_repairvectors(hVectorA1,hVectorB1,point,deltaV1);
repairedges_repairvectors(hVectorA2,hVectorB2,point,deltaV2);
repairline(hEdge,hVectorA1,hVectorB1,reduction);
repairline(hEdge,hVectorA2,hVectorB2,reduction);

%=================================================================

function deltaVector = getdeltavector(hVector)
xData = get(hVector,'XData');
yData = get(hVector,'YData');
deltaVector = [(xData(2)-xData(1)) (yData(2)-yData(1))];

%=================================================================

function setmenubinding(pointData)
parameter = get(pointData.vectors(1),'UserData');
switch parameter
    case 'plain'
        checkingmenubinding('on','off','off');
    case 'corner'
        checkingmenubinding('off','on','off');
    case 'straight'
        checkingmenubinding('off','off','on');
end

function checkingmenubinding(plain,corner,straight)
set(findobj('Tag','menu_geplain'),'Checked',plain);
set(findobj('Tag','menu_gecorner'),'Checked',corner);
set(findobj('Tag','menu_gestraight'),'Checked',straight);

%=================================================================

function hVector2 = getoppositevector(hVector1,vectors)
index1 = find(vectors == hVector1);
if mod(index1,2)
    hVector2 = vectors(index1 + 1);
else
    hVector2 = vectors(index1 - 1);
end

%=================================================================

function deletelittlepoint(hPoint,eventData,i)
pointData = get(hPoint,'UserData');
edgeData = get(pointData.edge,'UserData');

edgeData.mainpoints.x(pointData.index) = [];
edgeData.mainpoints.y(pointData.index) = [];
edgeData.mainpoints.index(pointData.index) = [];
%     try
%         edgeData.vectors([2*pointData.index - 1, 2*pointData.index - 2]) = [];
for j = 1:length(pointData.vectors),
    edgeData.vectors(edgeData.vectors == pointData.vectors(j)) = [];
end
%     catch
%     end
set(pointData.edge,'UserData',edgeData);
%     try
if length(edgeData.vectors) >= 2,
    hVectorA1 = edgeData.vectors(2*pointData.index-2);
    hVectorB1 = getoppositevector(hVectorA1,edgeData.vectors);
    %         xDataA = get(hVectorA1,'XData');
    %         yDataA = get(hVectorA1,'YData');
    %     catch
    %     end
    %     xDataB = get(hVectorB1,'XData');
    %     yDataB = get(hVectorB1,'YData');
    %     indices = getindices(pointData.edge,[xDataA(1) yDataA(1)],[xDataB(1) yDataB(1)]);
    %         indices = getindices(pointData.edge,hVectorA1,hVectorB1);
    figureData = get(gcf,'UserData');
    repairline(pointData.edge,hVectorA1,hVectorB1,figureData.configuration.edges.curvereduction);
end

delete(pointData.vectors);
%     set(gca,'Visible','off');
%     set(gca,'Visible','on');

renumberotherslittlepoints(pointData.index,-1);

%=================================================================

function renumberotherslittlepoints(index,value)
otherpoints = findobj('Tag','littlepoint');
for i = 1:length(otherpoints)
    anotherPointData = get(otherpoints(i),'UserData');
    if anotherPointData.index > index
        anotherPointData.index = anotherPointData.index + value;
    end
    set(otherpoints(i),'UserData',anotherPointData);
end

%=================================================================

function buttondownovervector(hVectorA1,eventData,hEdge)
if strcmp(get(findobj('Tag','uimenu_lockup'),'Checked'),'on'), return; end

edgeData = get(hEdge,'UserData');
hVectorB1 = getoppositevector(hVectorA1,edgeData.vectors);
hVectorA2 = getvectorinthesamepoint(hVectorA1,edgeData.vectors);

z2 = []; bind = []; hVectorB2 = []; indices2 = [];
if hVectorA2 ~= 0,
    hVectorB2 = getoppositevector(hVectorA2,edgeData.vectors);
    bind = get(hVectorA1,'UserData');
    xData2 = get(hVectorA2,'XData'); x2 = xData2(2) - xData2(1);
    yData2 = get(hVectorA2,'YData'); y2 = yData2(2) - yData2(1);
    if strcmp(bind,'straight')
        z2 = sqrt(x2^2 + y2^2);
    end
    if strcmp(bind,'straight') || strcmp(bind,'plain'),
        %             xDataA2 = get(hVectorA2,'XData');
        %             yDataA2 = get(hVectorA2,'YData');
        %             xDataB2 = get(hVectorB2,'XData');
        %             yDataB2 = get(hVectorB2,'YData');
        %             indices2 = getindices(hEdge,hVectorA2,hVectorB2);
    end
end

%     xDataA1 = get(hVectorA1,'XData');
%     yDataA1 = get(hVectorA1,'YData');
%     xDataB1 = get(hVectorB1,'XData');
%     yDataB1 = get(hVectorB1,'YData');
%     indices1 = getindices(hEdge,hVectorA1,hVectorB1);
figureData = get(gcf,'UserData');
set(gcf,'WindowButtonMotionFcn',{@pullvector,hEdge,...
    hVectorA1,hVectorB1,hVectorA2,hVectorB2,[],[],bind,z2,...
    figureData.configuration.edges.curvereduction});
set(gcf,'WindowButtonUpFcn',{@stoppullvector,hEdge,hVectorA1,...
    [edgeData.vectors(1) edgeData.vectors(end)]});

%=================================================================

function hVector2 = getvectorinthesamepoint(hVector1,vectors)
indexVector1 = find(vectors == hVector1);
if indexVector1 > 1 && indexVector1 < length(vectors)
    if mod(indexVector1,2)
        hVector2 = vectors(indexVector1 - 1);
    else
        hVector2 = vectors(indexVector1 + 1);
    end
else
    hVector2 = 0;
end

%=================================================================

function pullvector(hFigure,eventData,hEdge,hVectorA1,hVectorB1,...
    hVectorA2,hVectorB2,indices1,indices2,bind,z2,reduction)
point = get(gca,'CurrentPoint');
xDataA1 = get(hVectorA1,'XData');
yDataA1 = get(hVectorA1,'YData');
xDataA1(2) = point(1,1);
yDataA1(2) = point(1,2);
set(hVectorA1,'XData',xDataA1,'YData',yDataA1);
%     indices1 = getindices(hEdge,hVectorA1,hVectorB1);
repairline(hEdge,hVectorA1,hVectorB1,reduction);

if hVectorA2 ~= 0
    if strcmp(bind,'plain')
        xDataA2 = xDataA1; xDataA2(2) = xDataA2(1)-(xDataA2(2)-xDataA2(1));
        yDataA2 = yDataA1; yDataA2(2) = yDataA2(1)-(yDataA2(2)-yDataA2(1));
        set(hVectorA2,'XData',xDataA2,'YData',yDataA2);
        %             indices2 = getindices(hEdge,hVectorA2,hVectorB2);
        repairline(hEdge,hVectorA2,hVectorB2,reduction);
        %    elseif strcmp(bind,'corner')
    elseif strcmp(bind,'straight')
        xDataA2 = xDataA1; xDataA2(2) = xDataA2(1)-(xDataA2(2)-xDataA2(1));
        yDataA2 = yDataA1; yDataA2(2) = yDataA2(1)-(yDataA2(2)-yDataA2(1));
        x3 = xDataA2(2) - xDataA2(1);
        y3 = yDataA2(2) - yDataA2(1);
        z3 = sqrt(x3^2+y3^2);
        y2 = z2*y3/z3;
        x2 = z2*x3/z3;
        xDataA2(2) = xDataA2(1)+x2;
        yDataA2(2) = yDataA2(1)+y2;
        set(hVectorA2,'XData',xDataA2,'YData',yDataA2);
        %             indices2 = getindices(hEdge,hVectorA2,hVectorB2);
        repairline(hEdge,hVectorA2,hVectorB2,reduction);
    end
end

%=================================================================

function stoppullvector(hFigure,eventData,hEdge,hVector,vectors)
set(hFigure,'WindowButtonMotionFcn','','WindowButtonUpFcn','');

%=================================================================

function menu_binding(hMenu,eventData,parameter)
hPoint = findobj('Tag','littlepoint','Selected','on');
pointData = get(hPoint,'UserData');
switch parameter
    case 'plain'
        checkingmenubinding('on','off','off');
    case 'corner'
        checkingmenubinding('off','on','off');
    case 'straight'
        checkingmenubinding('off','off','on');
end
for i = 1:length(pointData.vectors)
    set(pointData.vectors(i),'UserData',parameter);
end

%=================================================================

function menu_addpoint(hMenu,eventData)
%     figureData = get(gcf,'UserData');
hEdge = gco;
%hEdge = findobj('Type','line','Tag','grapheditedge',...
%    'LineWidth',figureData.configuration.edges.linewidth,...
%    'LineStyle',figureData.configuration.edges.linestyle);
%     hEdge = hEdge(end);
point = get(gca,'CurrentPoint');
[index,indexMain] = findneighbours(hEdge,[point(1,1) point(1,2)]);
if isempty(index) || isempty(indexMain),   return;   end

xData = get(hEdge,'XData');
yData = get(hEdge,'YData');
edgeData = get(hEdge,'UserData');
x = edgeData.mainpoints.x;
y = edgeData.mainpoints.y;
i = edgeData.mainpoints.index;
edgeData.mainpoints.x = [x(1:indexMain) point(1,1) x(indexMain+1:end)];
edgeData.mainpoints.y = [y(1:indexMain) point(1,2) y(indexMain+1:end)];
edgeData.mainpoints.index = [i(1:indexMain) i(indexMain)+1 (i(indexMain+1:end)+1)];

a = (xData(index+1)-xData(index))/(yData(index+1)-yData(index));
deltaY = 30*sqrt(1/(a^2+1));
deltaX = a*deltaY;
xFlag = edgeData.mainpoints.x(indexMain) - edgeData.mainpoints.x(indexMain+1);
yFlag = edgeData.mainpoints.y(indexMain) - edgeData.mainpoints.y(indexMain+1);
if (xFlag < 0 && yFlag <= 0)
    deltaX = -deltaX;
    deltaY = -deltaY;
elseif (xFlag < 0 && yFlag > 0)
elseif (xFlag > 0 && yFlag < 0)
    deltaY = -deltaY;
    deltaX = -deltaX;
elseif (xFlag >= 0 && yFlag > 0)
end

hVector1 = createvector(hEdge,[point(1,1) point(1,1)+deltaX],...
    [point(1,2) point(1,2)+deltaY]);
hVector2 = createvector(hEdge,[point(1,1) point(1,1)-deltaX],...
    [point(1,2) point(1,2)-deltaY]);
edgeData.vectors = [edgeData.vectors(1:(2*indexMain-1)),...
    hVector1,...
    hVector2,...
    edgeData.vectors((2*indexMain):end)];
xData = [xData(1:index) point(1,1) xData(index+1:end)];
yData = [yData(1:index) point(1,2) yData(index+1:end)];
set(hEdge,'XData',xData,'YData',yData,'UserData',edgeData);

recreatelittlepoints(hEdge);
createpoint_repairline(hEdge,edgeData.vectors(2*indexMain-1),hVector1);
createpoint_repairline(hEdge,edgeData.vectors(2*indexMain+2),hVector2);

%=================================================================

function [index,indexMain] = findneighbours(hEdge,point)
xData = get(hEdge,'XData');
yData = get(hEdge,'YData');
edgeData = get(hEdge,'UserData');
min = Inf; index = 0;
for i = 1:(length(xData)-1)
    value = (xData(i) - point(1))^2 + (yData(i) - point(2))^2;
    if min > value
        min = value;
        index = i;
    end
end
for i = 1:length(edgeData.mainpoints.index)
    if edgeData.mainpoints.index(i) <= index &&...
            edgeData.mainpoints.index(i+1) > index,
        indexMain = i;
    end
end

%         mainIndex = find(i == edgeData.mainpoints.index);
%         if ~isempty(mainIndex)
%             j = mainIndex;
%         end
%         k = (yData(i+1) - yData(i)) / (xData(i+1) - xData(i));  % k = (y2-y1)/(x1-x2)
%         q = yData(i) - k*xData(i);                              % q = y1-k*x1
%         y = k*point(1) + q;                                     % y = k*x+q
%         if y > point(2)-3 && y < point(2)+3
%             index = [i i+1];
%             indexMain = [j j+1];
%             return;
%         end

%=================================================================

function recreatelittlepoints(hEdge)
hPoints = findobj('Tag','littlepoint');
set(hPoints,'DeleteFcn','');
delete(hPoints);
createlittlepoints(hEdge);

%=================================================================

function menu_deletepoint(hMenu,eventData)
hObject = findobj('Tag','littlepoint','Selected','on');
delete(hObject);

%=================================================================








function buttondownoveraxes_drawedge(hAxes,eventData)
if strcmp(get(findobj('Tag','uimenu_lockup'),'Checked'),'on'), return; end
selectoffallotherobjects(hAxes);




%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================


function name = getname(hCanvas,type,value)
canvasData = get(hCanvas,'UserData');
try
    switch type
        case 'node'
            number = length(canvasData.nodes);
        case 'edge'
            number = length(canvasData.eps(:,1));
        otherwise
    end
catch
    number = 0;
end
name = [value '_{' int2str(number+1) '}'];

%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================

function viewlibrarybrowser_command(hFigure,value)
figureData = get(hFigure,'UserData');
if strcmp(value,'off')
    if ishandle(figureData.hlibrarybrowser),
        close(figureData.hlibrarybrowser);
    end
    figureData.hlibrarybrowser = [];
else
    if isempty(figureData.hlibrarybrowser),
        hlibrarybrowser = grapheditlibrarybrowser(...
            figureData.configuration.matlibraryfilename,...
            hFigure,...
            figureData.configuration.defaultnode);
        figureData = get(hFigure,'UserData'); % neccessary because grapheditlibrarybrowser() modify figureData
        figureData.hlibrarybrowser =hlibrarybrowser;
    end
end
set(hFigure,'UserData',figureData);

%=================================================================

function viewlibrarybrowser(hObject,eventData,hFigure)
value = 'on';
switch lower(get(hObject,'Tag'))
    case 'uimenu_gelibrarybrowser'
        if strcmp(get(hObject,'Checked'),'off')
            set(findobj('Tag','toolbar_gelibrarybrowser'),'State','on');
            set(hObject,'Checked','on');
            value = 'on';
        else
            set(findobj('Tag','toolbar_gelibrarybrowser'),'State','off');
            set(hObject,'Checked','off');
            value = 'off';
        end
    case 'toolbar_gelibrarybrowser'
        value = get(hObject,'State');
        set(findobj('Tag','uimenu_gelibrarybrowser'),'Checked',value);
end
viewlibrarybrowser_command(hFigure,value);

%=================================================================

function viewnodedesigner_command(hFigure,value)
figureData = get(hFigure,'UserData');
if strcmp(value,'off')
    if ishandle(figureData.hnodedesigner),
        close(figureData.hnodedesigner);
    end
    figureData.hnodedesigner = [];
else
    if isempty(figureData.hnodedesigner),
        figureData.hnodedesigner = grapheditcreatenewnode(...
            figureData.configuration.matlibraryfilename);
    end
end
set(hFigure,'UserData',figureData);

%=================================================================

function viewnodedesigner(hObject,eventData,hFigure)
value = 'on';
switch lower(get(hObject,'Tag'))
    case 'uimenu_genodedesigner'
        if strcmp(get(hObject,'Checked'),'off')
            set(findobj('Tag','toolbar_genodedesigner'),'State','on');
            set(hObject,'Checked','on');
            value = 'on';
        else
            set(findobj('Tag','toolbar_genodedesigner'),'State','off');
            set(hObject,'Checked','off');
            value = 'off';
        end
    case 'toolbar_genodedesigner'
        value = get(hObject,'State');
        set(findobj('Tag','uimenu_genodedesigner'),'Checked',value);
end
viewnodedesigner_command(hFigure,value);

%=================================================================

% function launchpropertyeditor(hFigure)
%     hUImenu = findobj('Tag','uimenu_gepropertyeditor');
%     set(hUImenu,'Checked','off');
%     viewpropertyeditor(hUImenu,[],hFigure);

%=================================================================

function viewpropertyeditor_command(hFigure,value)
figureData = get(hFigure,'UserData');
if strcmp(value,'off')
    if ishandle(figureData.hpropertyeditor),
        close(figureData.hpropertyeditor);
    end
    figureData.hpropertyeditor = [];
    figureData.configuration.propertyeditorafterstart = 'off';
else
    canvasData = get(get(hFigure,'CurrentAxes'),'UserData');
    if isempty(figureData.hpropertyeditor) || ~ishandle(figureData.hpropertyeditor),
        figureData.hpropertyeditor = grapheditpropertyeditor(hFigure);
    end
    if ~isempty(canvasData.selected),
        grapheditpropertyeditor(canvasData.selected(end));
    else
        grapheditpropertyeditor(get(hFigure,'CurrentAxes'));
    end
    figureData.configuration.propertyeditorafterstart = 'on';
end
set(hFigure,'UserData',figureData);

%=================================================================

function viewpropertyeditor(hObject,eventData,hFigure)
value = 'on';
switch lower(get(hObject,'Tag'))
    case 'uimenu_gepropertyeditor'
        if strcmp(get(hObject,'Checked'),'off')
            set(findobj('Tag','toolbar_gepropertyeditor'),'State','on');
            set(hObject,'Checked','on');
            value = 'on';
        else
            set(findobj('Tag','toolbar_gepropertyeditor'),'State','off');
            set(hObject,'Checked','off');
            value = 'off';
        end
    case 'toolbar_gepropertyeditor'
        value = get(hObject,'State');
        set(findobj('Tag','uimenu_gepropertyeditor'),'Checked',value);
end
%     if strcmp(value,'off')
%         if ishandle(figureData.hpropertyeditor),
%             delete(figureData.hpropertyeditor);
%         end
%         figureData.hpropertyeditor = [];
%     else
%         canvasData = get(gca,'UserData');
%         figureData.hpropertyeditor = grapheditpropertyeditor(hFigure);
%         if ~isempty(canvasData.selected)
%             grapheditpropertyeditor(canvasData.selected(end));
%         end
%     end
viewpropertyeditor_command(hFigure,value)

%=================================================================

function isPE = ispropertyeditor
isPE = strcmp(get(findobj('Tag','uimenu_gepropertyeditor'),'Checked'),'on');

%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================





%////////////////////////////////////////////////////////////////////
%///////////////////////    Undo, redo    ///////////////////////////
%////////////////////////////////////////////////////////////////////




%=================================================================

function redo(hObject,eventData)
try
    objGraph = createobjectgraph(gca);
    canvasData = get(gca,'UserData');
    if isempty(canvasData.undo), canvasData.undo = {}; end
    canvasData.undo(end+1) = {objGraph};
    set(findobj('Tag','toolbar_grapheditundo'),'Enable','on');
    set(findobj('Tag','uimenu_grapheditundo'),'Enable','on');
    set(get(gca,'Children'),'DeleteFcn','');
    delete(get(gca,'Children'));
    canvasData.nodes = [];
    canvasData.eps = [];
    canvasData.selected = [];
    objGraph = canvasData.redo{end};
    canvasData.redo(end) = [];
    set(gca,'UserData',canvasData);
    drawobjectgraph(objGraph,gca);
catch
    set(findobj('Tag','toolbar_grapheditredo'),'Enable','off');
    set(findobj('Tag','uimenu_grapheditredo'),'Enable','off');
end

%=================================================================

function undo(hObject,eventData)
try
    objGraph = createobjectgraph(gca);
    canvasData = get(gca,'UserData');
    if isempty(canvasData.redo), canvasData.redo = {}; end
    canvasData.redo(end+1) = {objGraph};
    set(findobj('Tag','toolbar_grapheditredo'),'Enable','on');
    set(findobj('Tag','uimenu_grapheditredo'),'Enable','on');
    set(get(gca,'Children'),'DeleteFcn','');
    delete(get(gca,'Children'));
    canvasData.nodes = [];
    canvasData.eps = [];
    canvasData.selected = [];
    objGraph = canvasData.undo{end};
    canvasData.undo(end) = [];
    set(gca,'UserData',canvasData);
    drawobjectgraph(objGraph,gca);
catch
    set(findobj('Tag','toolbar_grapheditundo'),'Enable','off');
    set(findobj('Tag','uimenu_grapheditundo'),'Enable','off');
end

%=================================================================

function savecurrentstate(varargin)
objGraph = createobjectgraph(gca);
canvasData = get(gca,'UserData');
if isempty(canvasData.undo), canvasData.undo = {}; end
if length(canvasData.undo) >= 100
    canvasData.undo(1) = [];
end
canvasData.undo(end+1) = {objGraph};
set(gca,'UserData',canvasData);
set(findobj('Tag','toolbar_grapheditundo'),'Enable','on');
set(findobj('Tag','toolbar_grapheditredo'),'Enable','off');
set(findobj('Tag','uimenu_grapheditundo'),'Enable','on');
set(findobj('Tag','uimenu_grapheditredo'),'Enable','off');


%=================================================================
%
% function erasehistory
%     structFigure = get(findobj('Tag','createnewnodefigure'),'UserData');
%     structFigure.redo = {};
%     structFigure.undo = {};
%     set(findobj('Tag','toolbar_grapheditredo'),'Enable','off');
%     set(findobj('Tag','toolbar_grapheditundo'),'Enable','off');
%     set(findobj('Tag','createnewnodefigure'),'UserData',structFigure);

%=================================================================

%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================

%=================================================================





%////////////////////////////////////////////////////////////////////
%///////////////////////////    Text    /////////////////////////////
%////////////////////////////////////////////////////////////////////




%=================================================================

function createtext(hObject,param,textposition)
objectData = get(hObject,'UserData');
[xCenter,yCenter] = getcenterofobject(hObject);
if isempty(objectData.objectparams.TextParam)
    switch get(hObject,'Type')
        case 'rectangle'
            position = get(hObject,'Position');
            x1 = xCenter + textposition.names(1);
            y1 = position(2) + textposition.names(2);
            x2 = xCenter + textposition.userparams(1);
            y2 = position(2) + textposition.userparams(2);
        case {'patch', 'image'}
            yData = get(hObject,'YData');
            x1 = xCenter + textposition.names(1);
            y1 = min(yData) + textposition.names(2);
            x2 = xCenter + textposition.userparams(1);
            y2 = min(yData) + textposition.userparams(2);
        case 'line'
            [x,y] = getlinecenter(hObject);
            x1 = x + textposition.names(1);
            y1 = y + textposition.names(2);
            x2 = x + textposition.userparams(1);
            y2 = y + textposition.userparams(2);
        otherwise
    end
    objectData.objectparams.TextParam = [xCenter - x1, yCenter - y1;...
        xCenter - x2, yCenter - y2];
else
    x1 = xCenter - objectData.objectparams.TextParam(1,1);
    y1 = yCenter - objectData.objectparams.TextParam(1,2);
    x2 = xCenter - objectData.objectparams.TextParam(2,1);
    y2 = yCenter - objectData.objectparams.TextParam(2,2);
end
if strcmp(param,'node')
    visible1 = get(findobj('Tag','uimenu_viewnamenode'),'Checked');
    visible2 = get(findobj('Tag','uimenu_viewuserparamnode'),'Checked');
else
    visible1 = get(findobj('Tag','uimenu_viewnameedge'),'Checked');
    visible2 = get(findobj('Tag','uimenu_viewuserparamedge'),'Checked');
end
figureData = get(gcf,'UserData');
objectData.hname = text(...
    x1,...
    y1,...        getgraphnameforflag(graphName,positionFlag(3)),...
    objectData.objectparams.Name,...
    'FontUnits','Pixels',...
    'SelectionHighlight','off',...
    'FontSize',figureData.configuration.fontsize.names,...
    'FontWeight',figureData.configuration.fontsize.fontweight,...
    'Parent',get(hObject,'Parent'),...
    'HorizontalAlignment','center',...
    'Tag',['textname_' param],...        'Selected',[],...
    'ButtonDownFcn',@buttondownovertext,...
    'UserData',struct('hobject',hObject),...
    'Visible',visible1);
switch class(objectData.objectparams.UserParam)
    case 'cell'
        str = cell2str(objectData.objectparams.UserParam);
    case {'double', 'int'}
        str = matrix2str(objectData.objectparams.UserParam);
    case 'char'
        str = objectData.objectparams.UserParam;
    otherwise
        str = '';
end
objectData.huserparam = text(...
    x2,...
    y2,...        getgraphnameforflag(graphName,positionFlag(3)),...
    str,...
    'FontUnits','Pixels',...
    'SelectionHighlight','off',...
    'FontSize',figureData.configuration.fontsize.userparams,...
    'FontWeight',figureData.configuration.fontsize.fontweight,...
    'Parent',get(hObject,'Parent'),...
    'HorizontalAlignment','center',...
    'Tag',['textuserparam_' param],...        'Selected',[],...
    'ButtonDownFcn',@buttondownovertext,...
    'UserData',struct('hobject',hObject),...
    'Visible',visible2);
set(hObject,'UserData',objectData);

%=================================================================

function [x,y] = getlinecenter(hObject)
	xData = get(hObject,'XData');
    yData = get(hObject,'YData');
    index = floor(length(xData)/2);
    deltaX = xData(index+1) - xData(index);
    deltaY = yData(index+1) - yData(index);
    x = xData(index) + deltaX/2;
    y = yData(index) + deltaY/2;

%=================================================================

function out = matrix2str(in)
out = '[ ';
if isempty(in)
    out = '';
else
    for i = 1:size(in,1)
        for j = 1:size(in,2)
            out = [out num2str(in(i,j)) ' '];
        end
        out = [out '; '];
    end
    out = [out(1:(end-3)) ' ]'];
end

function out = cell2str(in)
out = '{ ';
for i = 1:length(in)
    switch class(in{i})
        case {'double','int'}
            out = [out num2str(in{i}) ', '];
        case 'struct'
            out = 'noneditable';
            return;
        case 'logical'
            if in{i} == true, out = [out 'true, '];
            else out = [out 'false, ']; end
        case 'cell'
            out = [out cell2str(in{i}) ', '];
        case 'char'
            out = [out '''' in{i} ''', '];
        otherwise
    end
end
out = [out(1:(end-2)) ' }'];

%=================================================================

function buttondownovertext(hText,eventData)
if strcmp(get(findobj('Tag','uimenu_lockup'),'Checked'),'on'), return; end
textData = get(hText,'UserData');
canvasData = get(get(hText,'Parent'),'UserData');
if isempty(find(canvasData.selected == textData.hobject))
    selectoffallotherobjects(textData.hobject);
    selectobject(textData.hobject);
end
grapheditpropertyeditor(textData.hobject);
[xCenter,yCenter] = getcenterofobject(textData.hobject);
set(gcf,...
    'WindowButtonMotionFcn',{@textmoving,hText,textData.hobject,[xCenter,yCenter]},...
    'WindowButtonUpFcn',@stoppull);

%=================================================================

function textmoving(hFigure,eventData,hText,hObject,center)
point = get(gca,'CurrentPoint');
set(hText,'Position',[point(1,1) point(1,2)]);
objectData = get(hObject,'UserData');
switch get(hText,'Tag')
    case {'textname_node', 'textname_edge'}
        set(findobj('Tag','ge_textname'),'Position',[point(1,1) point(1,2)]);
        objectData.objectparams.TextParam(1,:) = [center(1) - point(1,1),...
            center(2) - point(1,2)];
    case {'textuserparam_node', 'textuserparam_edge'}
        set(findobj('Tag','ge_textuserparam'),'Position',[point(1,1) point(1,2)]);
        objectData.objectparams.TextParam(2,:) = [center(1) - point(1,1),...
            center(2) - point(1,2)];
    otherwise
end
set(hObject,'UserData',objectData);

%=================================================================

function viewtext(hObject,eventData,textType,objectType,hObject2,varargin)
if nargin == 6
    visible = varargin{1};
else
    if strcmp(get(hObject,'Checked'),'off')
        visible = 'on';
    else
        visible = 'off';
    end
end
set(hObject,'Checked',visible);
tag = ['text' textType '_' objectType];
set(findobj('Tag',tag),'Visible',visible);





%=================================================================
%=================================================================




%////////////////////////////////////////////////////////////////////
%/////////////////    Create object Graph    ////////////////////////
%////////////////////////////////////////////////////////////////////




%=================================================================

function g = createobjectgraph(hAxes)
canvasData = get(hAxes,'UserData');
if ~isempty(canvasData.nodes),
    nodeList = num2cell((1:1:length(canvasData.nodes))');
    if ~isempty(canvasData.eps),
        edgeList = canvasData.eps(:,2:3);
        for i = 1:length(canvasData.nodes),
            edgeList(canvasData.nodes(i) == edgeList) = i;
        end
        edgeList = num2cell(edgeList);
    else
        edgeList = {};
    end
    g = graph('ndl',nodeList,'edl',edgeList);
    g.N = setobjectparams(g.N,canvasData.nodes);
    if ~isempty(canvasData.eps),
        g.E = setobjectparams(g.E,canvasData.eps(:,1)');
    end
else
    g = graph;
end
g = setobjectparams(g,gca);

%=================================================================

function list = setobjectparams(list,handles)
data = get(handles(1),'UserData');
fNames = fieldnames(data.objectparams);
for i = 1:length(handles),
    data = get(handles(i),'UserData');
    if isa(list,'graph')
        for j = 1:length(fNames)
            eval(['list.' fNames{j} ' = data.objectparams.' fNames{j} ';'])
        end
    else
        for j = 1:length(fNames)
            eval(['list{' num2str(i) '}.' fNames{j} ' = data.objectparams.' fNames{j} ';'])
        end
        %             try
        %                 list{i}.GraphicParam = getstructureposition(data.allobjects);
        %             catch
        if isa(list{1},'edge')
            try
                list{i}.Position = getstructurelittlepoints(data.vectors);
            catch
                list.Position = [1 2];
            end
        end
        %             end
    end
end

%=================================================================

function structures = getstructureposition(handles)
structures = cell(1,length(handles));
for i = 1:length(handles)
    objectData = get(handles(i),'UserData');
    structures{i} = objectData.structure;
end

%=================================================================

function structures = getstructurelittlepoints(handles)
xData1 = get(handles(1),'XData');
yData1 = get(handles(1),'YData');
xData2 = get(handles(end),'XData');
yData2 = get(handles(end),'YData');
if xData1(1) == xData2(1) && yData1(1) == yData2(1),
    structures = cell(1,length(handles)/2);
    structures{1} = struct(...
        'x',xData1(1),'y',yData1(1),...
        'xIn',(xData1(2)-xData1(1)),'yIn',(yData1(2)-yData1(1)),...
        'xOut',(xData2(2)-xData2(1)),'yOut',(yData2(2)-yData2(1)),...
        'pair','');
else
    structures = cell(1,length(handles)/2+1);
    structures{1} = struct(...
        'x',xData1(1),'y',yData1(1),...
        'xIn',-Inf,'yIn',-Inf,...
        'xOut',(xData1(2)-xData1(1)),'yOut',(yData1(2)-yData1(1)),...
        'pair','');
    structures{end} = struct(...
        'x',xData2(1),'y',yData2(1),...
        'xIn',(xData2(2)-xData2(1)),'yIn',(yData2(2)-yData2(1)),...
        'xOut',-Inf,'yOut',-Inf,...
        'pair','');
end
for i = 2:2:length(handles)-1
    xData1 = get(handles(i),'XData');
    yData1 = get(handles(i),'YData');
    xData2 = get(handles(i+1),'XData');
    yData2 = get(handles(i+1),'YData');
    structures{i/2+1} = struct(...
        'x',xData1(1),'y',yData1(1),...
        'xIn',(xData1(2)-xData1(1)),'yIn',(yData1(2)-yData1(1)),...
        'xOut',(xData2(2)-xData2(1)),'yOut',(yData2(2)-yData2(1)),...
        'pair',get(handles(i),'UserData'));
end

%=================================================================
%=================================================================
%=================================================================




%////////////////////////////////////////////////////////////////////
%///////////////////    Draw object Graph    ////////////////////////
%////////////////////////////////////////////////////////////////////




%=================================================================

function drawobjectgraph(objGraph,varargin)
if nargin == 2,    hAxes = varargin{1};    else    hAxes = gca;    end
canvasData = get(hAxes,'UserData');
figureData = get(get(hAxes,'Parent'),'UserData');
adjMatrix = get(objGraph,'adj');
% drawing of nodes
N = objGraph.N;
N = placenodes(hAxes,N);
nodes = zeros(1,length(N));
for i = 1:length(N)
    hObject = drawnode(N{i}.GraphicParam,hAxes,[],N{i});
    %        copyobjectparams(hObject(1),N{i});
    nodes(i) = hObject(1);
end
% drawing of edges
E = objGraph.E;
[in,fn,num] = find(adjMatrix);
eps = []; %zeros(sum(num),3);
for i = 1:length(in),
    numEdge = between(objGraph,in(i),fn(i));
    for j = 1:length(numEdge),
        %[x,y] = getcenterofobject(nodes(in(i)));
        hEdge = drawedgeatonce(E{numEdge(j)},hAxes,nodes(in(i)),nodes(fn(i)),...
            figureData.configuration.edges.curvereduction);
        %            copyobjectparams(hEdge,E{numEdge(j)});
        eps(end+1,:) = [hEdge, nodes(in(i)), nodes(fn(i))]; %#ok<AGROW>
    end
end
copyobjectparams(hAxes,objGraph);
canvasData = get(hAxes,'UserData');
canvasData.node = nodes;
canvasData.eps = eps;
canvasData.objectparams.GridFreq = [20 20];
color = canvasData.objectparams.Color;
if ~iscolor(color),
    color = [1 1 1];
end
canvasData = adjustsliders(canvasData);
set(hAxes,'UserData',canvasData,'Color',color,'XColor',color,'YColor',color);
set(canvasData.flag,'FaceColor',color);
selectoffallotherobjects(hAxes);
if ishandle(canvasData.flag)
    flagData = get(canvasData.flag,'UserData');
    set(flagData.text,'String',canvasData.objectparams.Name);
end
setslidersparams(hAxes);

%=================================================================

function data = adjustsliders(data)
    if ~isempty(data.eps)
        [xlim,ylim] = getgraphlimits(data.nodes,data.eps(:,1));
    else
        [xlim,ylim] = getgraphlimits(data.nodes,[]);
    end
    data = updateslidersparams(1,data,xlim);
    data = updateslidersparams(2,data,ylim);
    
%=================================================================

function data = updateslidersparams(index,data,lim)
    maxVal = max(abs(lim(1)),abs(lim(2)));
	if data.sliders(index).Max < maxVal + 20 || data.sliders(index).Min > maxVal - 20,
        data.sliders(index).Min = -maxVal - 30;
        data.sliders(index).MainMin = data.sliders(index).Min;
        data.sliders(index).Max = maxVal + 30;
        data.sliders(index).MainMax = data.sliders(index).Max;
	end

%=================================================================

function copyobjectparams(hObject,gObject)
data = get(hObject,'UserData');
fNames = fieldnames(data.objectparams);
for i = 1:length(fNames)
    eval(['data.objectparams.' fNames{i} '= gObject.' fNames{i} ';']);
end
set(hObject,'UserData',data);

%=================================================================

function N = placenodes(hAxes,N)
[radius,center] = getradiusandcenter(hAxes);
numNodes = length(N);
if numNodes > 0
    alpha = 2*pi/numNodes;
    for i = 1:numNodes
        if isempty(N{i}.GraphicParam(1).x) || isempty(N{i}.GraphicParam(1).y)
            x = radius*cos(pi-(i-1)*alpha);
            y = radius*sin(pi-(i-1)*alpha);
            N{i}.GraphicParam(1).x = center(1) + x;
            N{i}.GraphicParam(1).y = center(2) + y;
        end
    end
end

%=================================================================

function [r,center] = getradiusandcenter(hAxes)
xLim = get(hAxes,'XLim');
yLim = get(hAxes,'YLim');
center = [(xLim(2)-xLim(1))/2 (yLim(2)-yLim(1))/2];
xDiameter = sum(xLim - 70);
yDiameter = sum(yLim - 70);
if xDiameter > yDiameter
    r = yDiameter/2;
else
    r = xDiameter/2;
end

%=================================================================
%=================================================================
%=================================================================



%////////////////////////////////////////////////////////////////////
%//////   Save, Open, Export, Import - beginning   //////////////////
%////////////////////////////////////////////////////////////////////



%=================================================================

function exportcanvastopicture(hObject,eventData)
selectoffallotherobjects(gca);
actualWorkingDir = pwd;
cd(getactualpath('pictures'));
extensions = {'.bmp','.jpg','.pbm','.pgm','.png','.ppm','.ras','.tiff','.eps'};
[filename, pathname, filterindex] = uiputfile( ...
    {'*.bmp', 'Windows Bitmap (*.bmp)';
    '*.jpg','Joint Photographic Experts Group (*.jpg)'; ...
    '*.pbm','Portable bitmap (*.pbm)'; ...
    '*.pgm','Portable Graymap (*.pgm)'; ...
    '*.png','Portable Network Graphics (*.png)'; ...
    '*.ppm','Portable Pixmap (*.ppm)'; ...
    '*.ras','Sun Raster (*.ras)'; ...
    '*.tif','Tagged Image File Format (*.tif, *.tiff)'; ...
    '*.eps','Encapsulated Color PostScript (*.eps)'; ...
    },'Save canvas as');
cd(actualWorkingDir);
if filterindex>0
    [pathfile,name,ext] = fileparts(filename);
    if isempty(ext), filename = [filename extensions{filterindex}]; end
    if isempty(pathfile), filename = [pathname filename]; end   
    savegraphtopicture(filename);
end

%=================================================================
function savegraphtopicture(filename)
if (all(filename ~= 0) && (~isempty(filename)))
    [pathfile,name,ext] = fileparts(filename);
    if strcmp(ext,'.eps')
        actualset.prevPaperPosMode = get(gcf,'PaperPositionMode');
        actualset.toolbar1 = viewtoolbar1(findobj('Tag','uimenu_viewtoolbar1'),'off');
        actualset.toolbar2 = viewtoolbar2(findobj('Tag','uimenu_viewtoolbar2'),'off');
        actualset.tabs     = viewtabs(findobj('Tag','uimenu_viewtabs'),'off');
        actualset.slider   = viewsliders(findobj('Tag','uimenu_viewsliders'),'off');      

        set(gcf,'PaperPositionMode','auto');
        resizegraphedit(gcf,[]);        
        print(gcf,'-depsc2','-loose',[pathfile filesep name ext])
        set(gcf,'PaperPositionMode',actualset.prevPaperPosMode);
        viewtoolbar1(findobj('Tag','uimenu_viewtoolbar1'),actualset.toolbar1);
        viewtoolbar2(findobj('Tag','uimenu_viewtoolbar2'),actualset.toolbar2);
        viewtabs(findobj('Tag','uimenu_viewtabs'),actualset.tabs);
        viewsliders(findobj('Tag','uimenu_viewsliders'),actualset.slider);
        resizegraphedit(gcf,[]);        
    else
        apos = get(gca,'Position');
        frame = getframe(gca,[0,4,apos(3)-1,apos(4)-4]);
        frame.cdata = frame.cdata(:,2:end,:);
        imwrite(frame.cdata,[pathfile filesep name ext],ext(2:end));
        setactualpath('pictures',pathfile);
    end
end

%=================================================================

function saved = savegraphtofile(hObject,eventData)
global objGraph;
saved = 0;
listObjs = {};
listObjGraphs = {};
listEnable = 'off';

canvasData = get(gca,'UserData');
file = canvasData.file;
[path,name,ext] = fileparts(file);
if isempty(file) || strcmp(get(hObject,'Tag'),'uimenu_saveas')
    actualWorkingDir = pwd;
    cd(getactualpath('matfiles'));
    [filename,pathname] = uiputfile('*.mat','Save graph');
    cd(actualWorkingDir);
    if filename == 0,   return;   end
    setactualpath('matfiles',pathname);
    [path,name,ext] = fileparts(filename);
    if isempty(ext)
        ext = '.mat';
        filename = [filename ext];
    end
    file = [pathname filename];
    variableName = '';
else
    variableName = canvasData.variable;
    button = questdlg(sprintf('Save changes to existing file?'),...
        'Continue Operation','Yes','No','Cancel','Yes');
    if strcmp(button,'No') || strcmp(button,'Cancel')
        return;
    end
end
if strcmp(ext,'.mat')
    if isempty(variableName)
        if exist(file,'file')
            variables = struct(whos('-file',file));
            listObjs = {variables(:).name};
            variablesGraph = strmatch('graph',str2mat(variables.class),'exact');
            listObjGraphs = {variables(variablesGraph).name};
            listEnable = 'on';
        end
        figureData = get(gcf,'UserData');
        [variableName,isNewName] = grapheditlistdlg(...
            'parentfigure',gcbf,...
            'filename',filename,...
            'list1',listObjGraphs,...
            'list2',listObjs,...
            'listname','Variables in file:',...
            'okstring','Save',...
            'cancelstring','Cancel',...
            'editname','New variable: ',...
            'checktext','view only graphs',...
            'queststring','Do you want to replace this variable?',...
            'replaceable','on',...
            'askifreplace',figureData.configuration.askifreplace,...
            'listenable',listEnable,...
            'position','rightup');
        if isempty(variableName),     return;    end
    end
    objGraph = createobjectgraph(gca);
    eval('global objGraph;');
    eval([variableName ' = objGraph;']);
    if exist(file,'file')
        eval(['save ' '''' file '''' ' ' variableName ' -append;']);
    else
        eval(['save ' '''' file '''' ' ' variableName ';']);
    end
    eval(['clear ' variableName ';']);
    eval('clear objGraph;');
    saved = 1;
    canvasData.variable = variableName;
    canvasData.file = file;
    set(gca,'UserData',canvasData);
    setfileandvariablename(gca);
else
    h = errordlg('The file extension is not *.mat.','Wrong type of file');
    set(h,'WindowStyle','modal');
    return;
end

%=================================================================

function exportobjectgraph(hObject,eventData,hEdit)
variables = struct(evalin('base','whos'));
listObjs = {variables(:).name};
variablesGraph = strmatch('graph',str2mat(variables.class),'exact');
listObjGraphs = {variables(variablesGraph).name};
figureData = get(gcf,'UserData');
[name,isNewName] = grapheditlistdlg(...
    'parentfigure',gcbf,...
    'filename','Workspace',...
    'list1',listObjGraphs,...
    'list2',listObjs,...
    'listname','Variables in workspace:',...
    'okstring','Export',...
    'cancelstring','Cancel',...
    'editname','Export to: ',...
    'checktext','view only graphs',...
    'queststring','Do you want to replace variable?',...
    'askifreplace',figureData.configuration.askifreplace,...
    'position','rightup');
if (~isempty(name))
    objGraph = createobjectgraph(gca);
    assignin('base',name,objGraph);
    canvasData = get(gca,'UserData');
    if isempty(canvasData.file),
        canvasData.variable = name;
    end
    set(gca,'UserData',canvasData);
    setfileandvariablename(gca);
else
    return;
end

%=================================================================

function opengraphfromfile(hObject,eventData)
if strcmp(get(findobj('Tag','uimenu_lockup'),'Checked'),'on') &&...
        (strcmp(get(hObject,'Tag'),'uimenu_open') || strcmp(get(hObject,'Tag'),'toolbar_open')),
    return;
end
actualWorkingDirectory = pwd;
cd(getactualpath('matfiles'));
[filename,pathname] = uigetfile('*.mat','Load graph');
if isnumeric(filename)
    return;
end
cd(actualWorkingDirectory);
setactualpath('matfiles',pathname);
[path,name,ext] = fileparts(filename);
file = [pathname filename];
figureData = get(gcf,'UserData');
figureData.configuration.actualpaths.pictures = pathname;
set(gcf,'UserData',figureData);
if strcmp(ext,'.mat')
    objGraph = [];
    variables = struct(whos('-file',file));
    variablesGraph = strmatch('graph',str2mat(variables.class),'exact');
    if (isempty(variablesGraph))
        h = errordlg(['There is no graph in file ' filename '!'],'Variable not found');
        set(h,'WindowStyle','modal');
        return;
    elseif (length(variablesGraph) == 1)
        name = variables(variablesGraph).name;
        eval(['load ' '''' file '''' ' ' name]);
        objGraph = eval(name);
    elseif (length(variablesGraph) > 1)
        listObjGraphs = {variables(variablesGraph).name};
        [name,isNewName] = grapheditlistdlg(...
            'parentfigure',gcbf,...
            'filename',filename,...
            'list1',listObjGraphs,...
            'listname','Graphs in file:',...
            'okstring','Open',...
            'cancelstring','Cancel',...
            'editname','Open variable: ',...
            'checktext','view only graphs',...
            'checkenable','off',...
            'editenable','off',...
            'position','rightup',...
            'askifreplace',figureData.configuration.askifreplace);
        if ~isempty(name)
            eval(['load ' '''' file '''' ' ' name]);
            objGraph = eval(name);
        else
            return;
        end
    end
    if ~isempty(objGraph)
        canvasData = get(gca,'UserData');
        canvasData.variable = name;
        canvasData.file = file;
        set(gca,'UserData',canvasData);
        if ~isempty(get(gca,'Children'))
            hAxes = createcanvas(gcf,eventData);
            set(gcf,'CurrentAxes',hAxes);
        else
            hAxes = gca;
        end
        setfileandvariablename(hAxes);
        drawobjectgraph(objGraph);
    end
end

%=================================================================

function importobjectgraph(hObject,eventData)
objGraph = [];
variables = struct(evalin('base','whos'));
variablesGraph = strmatch('graph',str2mat(variables.class),'exact');
if (isempty(variablesGraph))
    h = errordlg(...
        ['There is no graph in the ' 'workspace' '!'],...
        'Variable not found');
    set(h,...
        'WindowStyle','modal');
elseif (length(variablesGraph) == 1)
    name = variables(variablesGraph).name;
    objGraph = evalin('base',name);
elseif (length(variablesGraph) > 1)
    listObjGraphs = {variables(variablesGraph).name};
    figureData = get(gcf,'UserData');
    [name,isNewName] = grapheditlistdlg(...
        'parentfigure',gcbf,...
        'filename','Workspace',...
        'list1',listObjGraphs,...
        'listname','Graphs in workspace:',...
        'okstring','Import',...
        'cancelstring','Cancel',...
        'editname','Import variable: ',...
        'checktext','view only graphs',...
        'checkenable','off',...
        'editenable','off',...
        'position','rightup',...
        'askifreplace',figureData.configuration.askifreplace);
    if (~isempty(name))
        objGraph = evalin('base',name);
    else
        return;
    end
end
if ~isempty(objGraph)
    if ~isempty(get(gca,'Children'))
        hAxes = createcanvas(gcf,eventData);
        set(gcf,'CurrentAxes',hAxes);
    end
    canvasData = get(gca,'UserData');
    canvasData.variable = name;
    set(gca,'UserData',canvasData);
    setfileandvariablename(gca);
    drawobjectgraph(objGraph);
end

%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================



%////////////////////////////////////////////////////////////////////
%//////////////////////       Plug-ins        ///////////////////////
%////////////////////////////////////////////////////////////////////



%=================================================================

%--------------------------------------------------------------------

function loadplugins(hObject,eventData)
figStructure = get(gcf,'UserData');
pluginlist = grapheditxml2struct('',figStructure.configuration.xmlpluginfilename);
%assignin('base','p',pluginlist);
set(hObject,'UserData',pluginlist);
createuimenuplugin(hObject,pluginlist);

%--------------------------------------------------------------------

function createuimenuplugin(hObject,pluginlist)
separator = 'off';
if ~isempty(pluginlist.group)
    for i = 1:length(pluginlist.group)
        separator = 'on';
        group = uimenu(hObject,'Label',pluginlist.group(i).name);
        if isempty(pluginlist.group(i).plugin)
            set(group,'Enable','off')
        end
        for j = 1:length(pluginlist.group(i).plugin)
            enable = 'off';
            x = filesep;
            [pathGraphEdit,command,ext] = fileparts(mfilename('fullpath'));
            [pathCommand,command,ext] = fileparts(pluginlist.group(i).plugin(j).command);
            if isempty(ext)
                ext = '.m';
            end

            if (exist([pathCommand x command ext]) == 2) % absolute path
                enable = 'on';
            elseif (exist([pathGraphEdit x 'plugin' x command ext]) == 2) % dir plugin
                pluginlist.group(i).plugin(j).command = [pathGraphEdit x 'plugin' x command ext];
                enable = 'on';
            elseif (exist([matlabroot x 'toolbox' x 'scheduling' x 'graph' x command ext]) == 2) % dir toolbox/scheduling/graph
                pluginlist.group(i).plugin(j).command = [matlabroot x 'toolbox' x 'scheduling' x 'graph' x command ext];
                enable = 'on';
            elseif (exist(command) == 2) % MATLAB paths
                pluginlist.group(i).plugin(j).command = command;
                enable = 'on';
            end

            uimenu(group,...
                'Label',pluginlist.group(i).plugin(j).name,...
                'UserData',pluginlist.group(i).plugin(j),...
                'Callback',@plugincallback,...
                'Enable',enable);
        end
    end
end
uimenu(hObject,...
    'Label','Add New Plug-in',...
    'Tag','uimenu_AddPlugin',...
    'Callback',@addnewplugin,...
    'Separator',separator);
uimenu(hObject,...
    'Label','Remove Plug-in',...
    'Tag','uimenu_RemovePlugin',...
    'Callback',@removeplugin);


%--------------------------------------------------------------------

function plugincallback(hObject,eventData)
global g;
try
    pathPWD = pwd;
    plugin = get(hObject,'UserData');
    saveStructure = get(gca,'UserData');
    objGraph = []; returnedObject = [];

    try
        objGraph = createobjectgraph(gca);
    catch
        objGraph = [];
    end

    if (str2double(plugin.gui) == 1)
        returnedObject = grapheditdialogdoplugin(plugin,objGraph);
    else
        [pathCommand,command,ext] = fileparts(plugin.command);
        g = objGraph;
        eval('global g;');
        if ~isempty(findstr(filesep,pathCommand))
            try
                cd(pathCommand);
            catch
                [pathDirect,direct] = fileparts(pathCommand);
                cd([pathDirect filesep '@' direct]);
            end
        end
        commandString = [command '( g );'];

        out = 0;
        try
            out = nargout([command '.m']);
        catch
            out = nargout([pathCommand filesep command '.m']);
        end

        if out > 0;
            returnedObject = eval(commandString);
        else
            eval(commandString);
            returnedObject = [];
        end

        eval('clear g;');
        cd(pathPWD);
    end

    if ~isempty(returnedObject)
        returnedobject(returnedObject);
    end
catch
    %         rethrow(lasterror)
    cd(pathPWD);
    err = lasterror;
    h = errordlg(['Plugin "' get(hObject,'Label') '" caused error.'],...
        'Plug-in Error');
    set(h,'WindowStyle','modal');
end

%--------------------------------------------------------------------

function returnedobject(returnedObject)
if isa(returnedObject,'graph')
    createcanvas(gcf);
    drawobjectgraph(returnedObject,gca);
elseif isa(returnedObject,'logical'),
    if returnedObject,
        answer = 'TRUE';
        mode = 'help';
        %             imName = 'grapheditgreencheck.png';
    else
        answer = 'FALSE';
        mode = 'error';
        %             imName = 'grapheditredcross.png';
    end
    %         im = imread(imName)
    %         [x,map] = imread(['private' filesep imName],'png');
    %         x(x(:,:,1) == 255/255 & x(:,:,2) == 89/255 & x(:,:,3) == 155/255) = get(gcf,'Color');
    h = msgbox(['The answer for your question is ' answer '.'],'Answer',mode);%,'custom',IconData,IconCMap);
    set(h,'Windowstyle','modal');
else
    button = questdlg(sprintf('Returned object isn''t graph.\nDo you want to save this object to workspace?'),...
        'Continue Operation','Yes','No','Cancel','Yes');
    if strcmp(button,'Yes')
        variables = struct(evalin('base','whos'));
        listObjs = {variables(:).name};
        listEnable = 'on';
        if isempty(listObjs)
            listEnable = 'off';
        end
        figureData = get(gcf,'UserData');
        [variableName,isNewName] = grapheditlistdlg(...
            'parentfigure',gcbf,...
            'filename','Save to workspace',...
            'list1',listObjs,...
            'listname','Variables in workspace:',...
            'okstring','Save',...
            'cancelstring','Cancel',...
            'editname','New variable: ',...
            'checkEnable','off',...
            'checktext','view only graphs',...
            'queststring','Do you want to replace variable?',...
            'listenable',listEnable,...
            'askifreplace',figureData.configuration.askifreplace,...
            'initialname','x');
        if ~isempty(variableName)
            assignin('base',variableName,returnedObject);
        end
    end
end

%--------------------------------------------------------------------

function addnewplugin(hObject,eventData)
try
    hUimenuPlugin = get(hObject,'Parent');
    pluginlist = get(hUimenuPlugin,'UserData');
    [groupName,groupDescription,plugin] = grapheditdialogaddplugin(pluginlist);
    if isempty(groupName) || isempty(plugin)
        return;
    else
        isAdded = 0;
        for i = 1:length(pluginlist.group)
            if strcmp(pluginlist.group(i).name,groupName)
                if isempty(pluginlist.group(i).plugin)
                    pluginlist.group(i).plugin = plugin;
                else
                    pluginlist.group(i).plugin(end+1) = plugin;
                end
                isAdded = 1;
            end
        end
        if isAdded == 0
            newGroup = struct('name',groupName,'description',groupDescription,'plugin',plugin);
            if isempty(pluginlist.group)
                pluginlist.group = newGroup;
            else
                pluginlist.group(length(pluginlist.group)+1) = newGroup;
            end
        end
    end
    set(hUimenuPlugin,'UserData',pluginlist);
    delete(get(hUimenuPlugin,'Children'));
    createuimenuplugin(hUimenuPlugin,pluginlist);
    savepluginlist;
catch
    h = errordlg(...
        'Adding new plugin caused error.',...
        'Plug-in error');
    set(h,'WindowStyle','modal');
end

%--------------------------------------------------------------------

function removeplugin(hObject,eventData)
hUimenuPlugin = get(hObject,'Parent');
pluginlist = get(hUimenuPlugin,'UserData');

pluginlist = grapheditdialogremoveplugin(pluginlist);

if ~isempty(pluginlist)
    set(hUimenuPlugin,'UserData',pluginlist);
    delete(get(hUimenuPlugin,'Children'));
    createuimenuplugin(hUimenuPlugin,pluginlist);
end
savepluginlist;

%--------------------------------------------------------------------

function saved = savepluginlist
figStructure = get(gcf,'UserData');
pluginlist = get(findobj('Type','uimenu','Tag','uimenu_plugin'),'UserData');
if grapheditplugstructure2xml(pluginlist, figStructure.configuration.xmlpluginfilename)
    saved = 1;
else
    button = questdlg(sprintf('Plug-inlist wasn''t saved.\nDo you want to continue without saving?'),...
        'Continue Operation','Yes','No','No');
    if strcmp(button,'Yes')
        saved = 1;
    else
        saved = 0;
    end
end

%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================

%=================================================================

function domethod(hMenu,eventData,functionName)
objGraph = createobjectgraph(gca);
try
    variable = eval([functionName '(objGraph)']);
    returnedobject(variable);
catch
    h = errordlg(['Method ''' functionName ''' wasn''t executed.'],' Execution failed');
    set(h,'WindowStyle','modal');
end


%=================================================================

%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================

function [isOk,configurationFile] = testofworkdirectory(configurationFileName)
%     [pathStr,name,ext] = fileparts(configurationFileName);
if exist(configurationFileName,'file') == 2,
    configurationFile = configurationFileName;
    isOk = true;
elseif exist([prefdir filesep 'grapheditwork' filesep configurationFileName],'file') == 2,
    configurationFile = [prefdir filesep 'grapheditwork' filesep configurationFileName];
    isOk = true;
else
    button = questdlg(sprintf('Configuration file was not found.\nDo you want continue with default settings?'),...
        'Continue Operation','Yes','No','Yes');
    if strcmp(button,'Yes')
        if exist([prefdir filesep 'grapheditwork'],'dir') ~= 7
            mkdir(prefdir,'grapheditwork');
        end
        configurationFile = '';
        isOk = true;
        return;
    else
        h = warndlg('Graphedit tool was terminated.','Bye-bye');
        set(h,'WindowStyle','modal');
        isOk = false;
        configurationFile = '';
        return;
    end
end

%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================

function viewparts(hMenu,eventData,type)
switch lower(type)
    case 'toolbar1',
        viewtoolbar1(hMenu);
    case 'toolbar2',
        viewtoolbar2(hMenu);
    case 'tabs',
        viewtabs(hMenu);
    case 'sliders',
        viewsliders(hMenu);
    otherwise
        switch lower(type)
            case 'viewall',
                value = 'on';
            case 'hideall',
                value = 'off';
            otherwise
        end
        viewtoolbar1(findobj('Tag','uimenu_viewtoolbar1'),value);
        viewtoolbar2(findobj('Tag','uimenu_viewtoolbar2'),value);
        viewtabs(findobj('Tag','uimenu_viewtabs'),value);
        viewsliders(findobj('Tag','uimenu_viewsliders'),value);
end
resizegraphedit(gcf,[]);

%=================================================================

function viewpartsfromcommandline(parts,value)
if ~iscell(parts),
    parts = {parts};
end
for i = 1:length(parts)
    switch lower(parts{i})
        case 'toolbar1',
            viewtoolbar1(findobj('Tag','uimenu_viewtoolbar1'),value);
        case 'toolbar2',
            viewtoolbar2(findobj('Tag','uimenu_viewtoolbar2'),value);
        case 'tabs',
            viewtabs(findobj('Tag','uimenu_viewtabs'),value);
        case 'sliders',
            viewsliders(findobj('Tag','uimenu_viewsliders'),value);
        case 'mainmenu'
            viewmainmenu([],value);
        case 'all'
            viewtoolbar1(findobj('Tag','uimenu_viewtoolbar1'),value);
            viewtoolbar2(findobj('Tag','uimenu_viewtoolbar2'),value);
            viewtabs(findobj('Tag','uimenu_viewtabs'),value);
            viewsliders(findobj('Tag','uimenu_viewsliders'),value);
            viewmainmenu([],value);
        otherwise
    end
end
resizegraphedit(gcf,[]);

%=================================================================

function value = switchmenuvalue(hMenu)
value = get(hMenu,'Checked');
if strcmp(value,'on'),
    value = 'off';
else
    value = 'on';
end

%=================================================================

function viewmainmenu(hMenu,varargin)
if nargin == 2,
    value = varargin{1};
    %     else
    %         value = switchmenuvalue(hMenu);
end
set(findobj('Tag','graphedit_menu'),'Visible',value);
set(findobj('Tag','uimenu_plugin'),'Visible',value);
%     set(gcf,'menubar','none')

%=================================================================

function [oldvalue] = viewtoolbar1(hMenu,varargin)
if nargin == 2,
    value = varargin{1};
else
    value = switchmenuvalue(hMenu);
end
set(hMenu,'Checked',value);
oldvalue = get(findobj('Tag','graphedit_toolbar1'),'Visible');
set(findobj('Tag','graphedit_toolbar1'),'Visible',value);
figureData = get(gcf,'UserData');
figureData.configuration.viewparts.toolbar1 = value;
set(gcf,'UserData',figureData);

%=================================================================

function [oldvalue] = viewtoolbar2(hMenu,varargin)
if nargin == 2,
    value = varargin{1};
else
    value = switchmenuvalue(hMenu);
end
set(hMenu,'Checked',value);
figureData = get(gcf,'UserData');
hFrame = findobj('Tag','toolbar2');
frameData = get(hFrame,'UserData');
oldvalue = get(hFrame,'Visible');
set(hFrame,'Visible',value);
for i = 1:length(frameData.handles),
    set(frameData.handles(i),'Visible',value);
end
figureData.configuration.viewparts.toolbar2 = value;
set(gcf,'UserData',figureData);


%=================================================================

function [oldvalue] = viewtabs(hMenu,varargin)
if nargin == 2,
    value = varargin{1};
else
    value = switchmenuvalue(hMenu);
end
set(hMenu,'Checked',value);
figureData = get(gcf,'UserData');
axesbarData = get(figureData.htabs,'UserData');
oldvalue = get(figureData.htabs,'Visible');
set(figureData.htabs,'Visible',value);
set(axesbarData.slider,'Visible',value);
set(axesbarData.lineblack,'Visible',value);
set(axesbarData.linecolor,'Visible',value);
for i = 1:length(axesbarData.flags),
    set(axesbarData.flags(i),'Visible',value);
    flagData = get(axesbarData.flags(i),'UserData');
    set(flagData.text,'Visible',value);
end
figureData.configuration.viewparts.tabs = value;
set(gcf,'UserData',figureData);

%=================================================================

function [oldvalue] = viewsliders(hMenu,varargin)
if nargin == 2,
    value = varargin{1};
else
    value = switchmenuvalue(hMenu);
end
oldvalue = get(hMenu,'Checked');
set(hMenu,'Checked',value);
figureData = get(gcf,'UserData');
set(figureData.hsliders,'Visible',value);
figureData.configuration.viewparts.sliders = value;
set(gcf,'UserData',figureData);

%=================================================================
%=================================================================

function copyfiguretoclipboard(hMenu,eventData)
actualset.prevPaperPosMode = get(gcf,'PaperPositionMode');
actualset.toolbar1 = viewtoolbar1(findobj('Tag','uimenu_viewtoolbar1'),'off');
actualset.toolbar2 = viewtoolbar2(findobj('Tag','uimenu_viewtoolbar2'),'off');
actualset.tabs     = viewtabs(findobj('Tag','uimenu_viewtabs'),'off');
actualset.slider   = viewsliders(findobj('Tag','uimenu_viewsliders'),'off');

set(gcf,'PaperPositionMode','auto');
resizegraphedit(gcf,[]);

FigureFormat = 1;
try
    FigureFormat = com.mathworks.services.Prefs.getIntegerPref('CopyOptions.FigureFormat');
catch
end

switch FigureFormat
    case 0
        print(gcf,'-dbitmap','-loose','-noui');
    otherwise
        print(gcf,'-dmeta','-loose','-noui');
end

set(gcf,'PaperPositionMode',actualset.prevPaperPosMode);
viewtoolbar1(findobj('Tag','uimenu_viewtoolbar1'),actualset.toolbar1);
viewtoolbar2(findobj('Tag','uimenu_viewtoolbar2'),actualset.toolbar2);
viewtabs(findobj('Tag','uimenu_viewtabs'),actualset.tabs);
viewsliders(findobj('Tag','uimenu_viewsliders'),actualset.slider);
resizegraphedit(gcf,[]);


%=================================================================
%=================================================================

function lockupcanvases(hMenu,eventData)
valueOld = get(hMenu,'Checked');
valueNew = switchmenuvalue(hMenu);
set(hMenu,'Checked',valueNew);

%     set(findobj('Tag','uimenu_grapheditdrawnode'),'Enable',valueOld);
%     set(findobj('Tag','uimenu_grapheditdrawedge'),'Enable',valueOld);
%     set(findobj('Tag','uimenu_grapheditdelete'),'Enable',valueOld);
%     set(findobj('Tag','uimenu_grapheditarrow'),'Enable',valueOld);
%
%     set(findobj('Tag','toolbar_grapheditdrawnode'),'Enable',valueOld);
%     set(findobj('Tag','toolbar_grapheditdrawedge'),'Enable',valueOld);
%     set(findobj('Tag','toolbar_grapheditdelete'),'Enable',valueOld);
%     set(findobj('Tag','toolbar_grapheditarrow'),'Enable',valueOld);

%=================================================================

function tab = getactualtab
figureData = get(gcf,'UserData');
axesbarData = get(figureData.htabs,'UserData');
hflags = axesbarData.flags;
hFlagsAx(length(hflags)) = 0;
for i = 1:length(hflags)
    flagData = get(hflags(i),'UserData');
    hFlagsAx(i) = flagData.axes;
end
tab = find(hFlagsAx == gca);


%=================================================================

function replacegraph(hFigure,flagNum,graphObj)
figureData = get(hFigure,'UserData');
axesbarData = get(figureData.htabs,'UserData');
flagData = get(axesbarData.flags(flagNum),'UserData');

hAxes = createaxes(hFigure);
set(hAxes,'UserData',get(flagData.axes,'UserData'),'Position',get(flagData.axes,'Position'),...
    'XLim',get(flagData.axes,'XLim'),'YLim',get(flagData.axes,'YLim'));
setlim(hAxes);

figureData.hcanvases(figureData.hcanvases == flagData.axes) = hAxes;
set(hFigure,'UserData',figureData);

drawobjectgraph(graphObj,hAxes);

set(hAxes,'Visible','on');
%     set(hAxes,'Children',get(flagData.axes,'Children'));
set(flagData.axes,'DeleteFcn','');
delete(flagData.axes);

resizegraphedit(hFigure,[]);

flagData.axes = hAxes;
set(axesbarData.flags(flagNum),'UserData',flagData);

%=================================================================

function newlayoutfornodes(hMenu,eventData)
g = createobjectgraph(gca);
g.N = placenodes(gca,g.N);
canvasData = get(gca,'UserData');
axesbarData = get(get(canvasData.flag,'Parent'),'UserData');
replacegraph(gcf,find(axesbarData.flags == canvasData.flag),g);

%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================

function importbackgroundimage(hMenu,eventData)
figureData = get(gcf,'UserData');
actualWorkingPath = pwd;
cd(figureData.configuration.actualpaths.pictures);
[filename, pathname, filterindex] = uigetfile( ...
    {'*.bmp;*.jpg;*.gif;*.png', 'Most Used Formats (*.bmp, *.jpg, *.gif, *.png)';...
    '*.bmp', 'Windows Bitmap (*.bmp)';
    '*.jpg','Joint Photographic Experts Group (*.jpg)'; ...
    '*.pbm','Portable bitmap (*.pbm)'; ...
    '*.pgm','Portable Graymap (*.pgm)'; ...
    '*.png','Portable Network Graphics (*.png)'; ...
    '*.ppm','Portable Pixmap (*.ppm)'; ...
    '*.ras','Sun Raster (*.ras)'; ...
    '*.tif','Tagged Image File Format (*.tif, *.tiff)'; ...
    '*.*','All files (*.*)'
    },'Save canvas as');
cd(actualWorkingPath);
if filename ~= 0,
    figureData.configuration.actualpaths.pictures = pathname;
    set(gcf,'UserData',figureData);
    cData = imread([pathname filename]);
    drawbackgroundimage(cData,[pathname filename]);
end

%=================================================================

function hImage = drawbackgroundimage(cData,filename)
[height,width,colors] = size(cData);
position = get(gca,'Position');
center = position(3:4)/2;
hContextMenu = getbackgroundcontextmenu;
hImage = image(...
    'Parent',gca,...
    'Tag','grapheditbackground',...
    'CData',cData,...
    'XData',[center(1)-width/2 center(1)+width/2],...
    'YData',[center(2)+height/2 center(2)-height/2],...
    'HitTest','off',...
    'Interruptible','off',...
    'UserData',filename,...
    'UIContextMenu',hContextMenu,...
    'DeleteFcn',{@editbackground,'on','off'},...
    'ButtonDownFcn',@buttondownoverbackground);
handles = get(gca,'Children');
handles = [handles(2:end); hImage];
set(gca,'Children',handles);

%=================================================================

function editbackground(hMenu,eventData,children,background)
hChildren = get(gca,'Children');
hBackground = findobj('Tag','grapheditbackground','Parent',gca);
if ~isempty(hBackground),
    set(hChildren,'HitTest',children,'Interruptible',children);
    set(hBackground,'HitTest',background,'Interruptible',background);
end

%=================================================================

function hMenu = getbackgroundcontextmenu
hMenu = uicontextmenu;
uimenu(hMenu, 'Label','Fit height', 'Callback',{@menu_fitbackground,'height'});
uimenu(hMenu, 'Label','Fit width', 'Callback',{@menu_fitbackground,'width'});
uimenu(hMenu, 'Label','End edit mode', 'Callback',{@editbackground,'on','off'}, 'Separator','on');
uimenu(hMenu, 'Label','Delete', 'Callback',{@menu_deletebackground}, 'Separator','on');

%=================================================================

function fitbackground(type)
children = get(gca,'Children');
if strcmp(get(children(end),'Tag'),'grapheditbackground'),
    menu_fitbackground([],[],type,children(end));
else
    error('There is no background image in current canvas of the Graphedit.');
end

%=================================================================

function menu_fitbackground(hMenu,eventData,type,varargin)
if nargin > 3,
    hObject = varargin{1};
else
    hObject = gco;
end
yLim = get(get(hObject,'Parent'),'YLim');
xLim = get(get(hObject,'Parent'),'XLim');
xData = get(hObject,'XData');
yData = get(hObject,'YData');
center = [(xLim(2)-xLim(1))/2, (yLim(2)-yLim(1))/2];
rate = (xData(2)-xData(1))/(yData(2)-yData(1));
switch lower(type),
    case 'height',
        newHeight = yLim(2)-yLim(1);
        newWidth = newHeight*rate;
        set(hObject,...
            'YData',[yLim(2) yLim(1)],...
            'XData',[center(1)+newWidth/2 center(1)-newWidth/2]);
    case 'width',
        newWidth = xLim(2)-xLim(1);
        newHeight = newWidth/rate;
        set(hObject,...
            'YData',[center(2)-newHeight/2 center(2)+newHeight/2],...
            'XData',[xLim(1) xLim(2)]);
    otherwise
end

%=================================================================

function menu_deletebackground(hMenu,eventData,varargin)
if nargin > 2,
    children = get(gca,'Children');
    hObject = children(end);
else
    hObject = gco;
end
delete(hObject);

%=================================================================

function buttondownoverbackground(hImage,eventData)
selectionType = get(gcbf,'SelectionType');
if strcmp(selectionType,'normal')
    point = get(gca,'CurrentPoint');
    xData = get(hImage,'XData');
    yData = get(hImage,'YData');
    xDelta = -[point(1,1)-xData(1), point(1,1)-xData(2)];
    yDelta = -[point(1,2)-yData(1), point(1,2)-yData(2)];
    set(gcf,'WindowButtonMotionFcn',{@movebackground,hImage,xDelta,yDelta},...
        'WindowButtonUpFcn',{@stopmovebackground,hImage});
end

%=================================================================

function movebackground(hFigure,eventData,hImage,xDelta,yDelta)
point = get(gca,'CurrentPoint');
set(hImage,'XData',round(xDelta+point(1,1)),'YData',round(yDelta+point(1,2)));

%=================================================================

function stopmovebackground(hFigure,eventData,hImage)
set(gcf,'WindowButtonMotionFcn','','WindowButtonUpFcn','');

%=================================================================

function setactualpath(type,pathname)
figureData = get(gcf,'UserData');
eval(['figureData.configuration.actualpaths.' type ' = pathname;']);
set(gcf,'UserData',figureData);

%=================================================================

function pathname = getactualpath(type)
pathname = '';
figureData = get(gcf,'UserData');
eval(['pathname = figureData.configuration.actualpaths.' type ';']);

%=================================================================

function viewedgesarrows(hMenu,eventData,varargin)
if nargin == 3,
    value = varargin{1};
    hMenu = findobj('Tag','uimenu_viewarrows');
else
    if strcmp(get(hMenu,'Checked'),'on'),
        value = 'off';
    else
        value = 'on';
    end
end
set(hMenu,'Checked',value);
figureData = get(gcf,'UserData');
figureData.configuration.edges.viewarrows = value;
set(gcf,'UserData',figureData);
set(findobj('Tag','graphedit_arrow'),'Visible',value);

%=================================================================

function saveactualconfiguration(hMenu,eventData,varargin)
try
    figureData = get(gcf,'UserData');
    fileName = figureData.xmlconfigurationfilename;
    if nargin == 3 && ~isempty(varargin{1}),
        fileName = varargin{1};
    end
    grapheditconfiguration2xml(figureData.configuration,fileName);
    if ishandle(hMenu),
        h = helpdlg('Configuration was saved succesfully.',' Configuration saving');
        set(h,'WindowStyle','modal');
    end
catch
    err = lasterror;
    h = errordlg(sprintf(['Configuration saving failed.\n' err.message]),' Saving failed');
    set(h,'WindowStyle','modal');
end

%=================================================================

function checkonoff(hMenu,evtnData)
if strcmp(get(hMenu,'Checked'),'on'),
    set(hMenu,'Checked','off');
else
    set(hMenu,'Checked','on');
end

%=================================================================

function movenodes(list)
canvasData = get(gca,'UserData');
figureData = get(gcf,'UserData');
% move nodes
handles = zeros(1,size(list,1));
for i = 1:size(list,1),
    if ishandle(list{i,1}) && strcmp(get(list{1,1},'Tag'),'grapheditnode'),
        handles(i) = list{i,1};
    else
        handles(i) = canvasData.nodes(list{i,1});
    end
    try
        xData = get(handles(i),'XData');
        yData = get(handles(i),'YData');
        [x,y] = getcenterofobject(handles(i));
        xData = list{i,2} + xData - x;
        yData = list{i,3} + yData - y;
        set(handles(i),'XData',xData);
        set(handles(i),'YData',yData);
    catch
        position = get(handles(i),'Position');
        position(1) = list{i,2} - position(3)/2;
        position(2) = list{i,3} - position(4)/2;
        set(handles(i),'Position',position);
    end

    objData = get(handles(i),'UserData');
    for j = 2:length(objData.allobjects)
        jData = get(objData.allobjects(j),'UserData');
        try
            set(objData.allobjects(j),...
                'XData',list{i,2} + jData.structure.x,...
                'YData',list{i,3} + jData.structure.y);
        catch
            set(objData.allobjects(j),...
                'Position',[list{i,2}+jData.structure.x, list{i,3}+jData.structure.y,...
                jData.structure.width, jData.structure.height]);
        end
    end

    % repair texts
    set(objData.hname,...
        'Position',[list{i,2}-objData.objectparams.TextParam(1,1),...
        list{i,3}-objData.objectparams.TextParam(1,2), 0]);
    set(objData.huserparam,...
        'Position',[list{i,2}-objData.objectparams.TextParam(2,1),...
        list{i,3}-objData.objectparams.TextParam(2,2), 0]);
end

% repair edges
cellForMoving = createcellformoving(handles);
hStart = []; indicesStart = []; deltaVStart = [];
hEnd = [];   indicesEnd = [];   deltaVEnd = [];
for i = 1:length(handles),
    point = [list{i,2}, list{i,3}];
    if ~isempty(cellForMoving{i,2}),
        hStart = cellForMoving{i,2}{1};
        indicesStart = cellForMoving{i,2}{2};
        deltaVStart = cellForMoving{i,2}{3};
    end
    if ~isempty(cellForMoving{i,3}),
        hEnd = cellForMoving{i,3}{1};
        indicesEnd = cellForMoving{i,3}{2};
        deltaVEnd = cellForMoving{i,3}{3};
    end
    repairedges(hStart,hEnd,point,indicesStart,indicesEnd,deltaVStart,deltaVEnd,...
        figureData.configuration.edges.curvereduction);
end

%=================================================================
%=================================================================
%=================================================================

function helpcallback(hObject,eventData)
disp('Help is not available yet.')

%=================================================================
% User Callback Call
%=================================================================
function usercallbackcall(hObject, calbackname)
% function call user defined calback functions

if iscell(calbackname)
    hObjectForCall = calbackname{2};
    calbackname = calbackname{1};
else
    hObjectForCall = hObject;
end

for i = 1:length(hObject)
    ObjUserData = get(hObject(i),'UserData');
    if isfield(ObjUserData,'usercallbackhandlerstruct')
        usercallback = ObjUserData.usercallbackhandlerstruct;
        if isfield(usercallback,calbackname) && ~isempty(usercallback.(calbackname))
            if iscell(usercallback.(calbackname))
                feval(usercallback.(calbackname){1},hObjectForCall(i),usercallback.(calbackname){2:end});
            else
                feval(usercallback.(calbackname),hObjectForCall(i));
            end
        end
    end
end

%=================================================================

function editsettings(hMenu,event) %#ok<INUSD>
    configurationFileName = 'grapheditconfiguration.xml';
	if exist([prefdir filesep 'grapheditwork' filesep configurationFileName],'file') == 2,
        configurationFile = [prefdir filesep 'grapheditwork' filesep configurationFileName];
        edit(configurationFile);
	else
        warndlg('Graphedit cannot find xml configuration file.','Missing grapheditconfiguration.xml');
	end

%=================================================================

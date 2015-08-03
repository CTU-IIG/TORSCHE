function hFigure = grapheditlibrarybrowser(fileName,hGraphedit,defaultNode)
%GRAPHEDITLIBRARYBROWSER   Tool for viewing designed patterns representing nodes.
%
%  See also NODE, GRAPHEDIT, GRAPHEDITCREATENEWNODE.


% Author: Vojtech Navratil <navrav1@fel.cvut.cz>
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


    hFigure = createfigure(hGraphedit,defaultNode,fileName);
    try
        data = importfromlibrary(fileName);
        if isempty(data)
            createaxes(hFigure,defaultNode);%createcellfromstruct(defaultNode));
        else
            for i = 1:length(data)
                createaxes(hFigure,data{i});
            end
        end
    catch
        createaxes(hFigure,defaultNode);%createcellfromstruct(defaultNode));
        doresize(hFigure,[]);
        err = lasterror;
        h = errordlg(err.message,'Load objects error');
        set(h,'WindowStyle','modal');
    end

    UserData = get(hFigure,'UserData');
    ax = UserData.('axes');
    SelectionTypeBK = get(gcf,'SelectionType');
    set(gcf,'SelectionType','open');
    buttondown(ax(1),[]);
    set(gcf,'SelectionType',SelectionTypeBK);
%=================================================================        

function hFigure = createfigure(hGraphedit,defaultNode,fileName)
    monitor = get(0,'ScreenSize');
    grapheditPos = get(hGraphedit,'Position');
    if (grapheditPos(1)+grapheditPos(3)+140) < monitor(3)
        window = [grapheditPos(1)+grapheditPos(3)+8 grapheditPos(2) 140 grapheditPos(4)+20];
    else
        window = [monitor(3)-140 grapheditPos(2) 140 grapheditPos(4)+20];
    end
    
    hFigure = figure(...
        'Tag','grapheditlibrarybrowser',...
        'Units','Pixels',...
        'Name','Library',...
        'NumberTitle','off',...
        'Menubar','none',...
        'Toolbar','none',...
        'Position',window,...        
        'DoubleBuffer','on',...  'Renderer','OpenGL',...
        'HandleVisibility','callback',...
        'CreateFcn',@createfcnlibrarybrowser,...
        'ResizeFcn',@doresize,...
        'CloseRequestFcn',@closelibrarybrowser,...
        'UserData',struct('zoomrate',1,...
                          'graphedit',hGraphedit,...
                          'defaultnode',defaultNode,...
                          'axes',[],...
                          'file',fileName));

    hToolbar = uitoolbar(hFigure);
    uipushtool(hToolbar,...
        'TooltipString','Load file',...        
        'ClickedCallback',@openfile,...
        'CData',getcdata('private/grapheditopen2.png'));
    uipushtool(hToolbar,...
        'Separator','on',...
        'TooltipString','Refresh',...
        'ClickedCallback',{@refreshlibrary,hFigure},...
        'CData',getcdata('private/grapheditrefresh.png'));

    uipushtool(hToolbar,...
        'Separator','on',...
        'TooltipString','Zoom In',...        
        'ClickedCallback',{@setzoom,10},...
        'CData',getcdata('private/grapheditzoomplus.png'));
    uipushtool(hToolbar,...
        'TooltipString','Zoom Out',...
        'ClickedCallback',{@setzoom,-10},...
        'CData',getcdata('private/grapheditzoomminus.png'));
    
    
    uicontrol(hFigure,...
        'Tag','librarybrowserslider',...
        'Callback',@sliderchanged,...
        'Max',1000,...
        'Min',0,... 
        'SliderStep',[0.1 100],...
        'Value',0,...
        'Enable','off',...
        'UserData',0,...
        'Style','slider');
    
%=================================================================        
    
function createfcnlibrarybrowser(hFigure,eventData)
    hMenu = findobj('Tag','uimenu_gelibrarybrowser');
    hToolbar = findobj('Tag','toolbar_gelibrarybrowser');
    set(hMenu,'Checked','on');
    set(hToolbar,'State','on');

%=================================================================        

function closelibrarybrowser(hFigure,eventData)
    delete(hFigure);
    set(findobj('Tag','uimenu_gelibrarybrowser'),'Checked','off');
    set(findobj('Tag','toolbar_gelibrarybrowser'),'State','off');
    grapheditData = get(findobj('Tag','graphedit'),'UserData');
    grapheditData.hlibrarybrowser = [];
    set(findobj('Tag','graphedit'),'UserData',grapheditData);
    
%=================================================================        

function doresize(hFigure,eventData)
    figureData = get(hFigure,'UserData');
    posFigure = get(hFigure,'Position');
    position = [5 posFigure(4) posFigure(3)-25 posFigure(3)-30];
    hSlider = findobj('Tag','librarybrowserslider');
    set(hSlider,'Position',[posFigure(3)-14 1 15 posFigure(4)]);
    if ~isempty(figureData.axes)
        for i = 1:length(figureData.axes)
            position(2) = position(2) - (posFigure(3)-30) - 5;
            set(figureData.axes(i),...
                'XLim',[-position(3)/figureData.zoomrate position(3)/figureData.zoomrate],...
                'YLim',[-position(4)/figureData.zoomrate position(4)/figureData.zoomrate],...
                'Position',position);
        end
        setslider(hSlider,figureData.axes(end));
    end
    
%=================================================================        
   
function setslider(hSlider,hAxes)
    positionLastAxes = get(hAxes,'Position');
    if positionLastAxes(2) < 5
        rate = abs(positionLastAxes(4)/positionLastAxes(2));
        set(hSlider,...
            'Enable','on',...
            'Value',0,...
            'Max',0,...
            'Min',positionLastAxes(2)-5,...
            'SliderStep',[0.1 rate]);
    else
        set(hSlider,'Enable','off');
    end
    
%=================================================================        
    
function sliderchanged(hSlider,eventData)
    value = get(hSlider,'Value');
    lastValue = get(hSlider,'UserData');
    figureData = get(gcf,'UserData');    
    for i = 1:length(figureData.axes)
        position = get(figureData.axes(i),'Position');
        position(2) = position(2) + (lastValue-value);
        set(figureData.axes(i),'Position',position);
    end
    set(hSlider,'UserData',value);

%=================================================================        
    
function setzoom(hButton,eventData,value)
    figureData = get(gcf,'UserData');
    xLim = get(figureData.axes(1),'XLim');
    yLim = get(figureData.axes(1),'YLim');
    zoomrate = (xLim(2)+value)/xLim(2);
    xLim = xLim/zoomrate;
    yLim = yLim/zoomrate;
    set(figureData.axes,'XLim',xLim,'YLim',yLim);
    figureData.zoomrate = zoomrate;
    set(gcf,'UserData',figureData);
    
%=================================================================        

function refreshlibrary(hObject,eventData,hFigure)
    figureData = get(hFigure,'UserData');
    delete(figureData.axes);
    figureData.axes = [];
    set(hFigure,'UserData',figureData);
    try
        data = importfromlibrary(figureData.file);
        createaxes(gcf,figureData.defaultnode);%createcellfromstruct(figureData.defaultnode));
        for i = 1:length(data)
            createaxes(gcf,data{i});
        end
        doresize(hFigure,eventData);
    catch
        createaxes(hFigure,figureData.defaultnode);%createcellfromstruct(figureData.defaultnode));       
        doresize(hFigure,eventData);
        err = lasterror;
        h = errordlg(err.message,'Load objects error');
        set(h,'WindowStyle','modal');        
    end

%=================================================================        

function openfile(hObject,eventData)
    try
        [fileName,pathName] = uigetfile('*.mat','Load graph');
        if (fileName == 0), return; end     % storno
        figureData = get(gcf,'UserData');
        figureData.file = [pathName fileName];
        data = importfromlibrary([pathName fileName]);
        if ~isempty(data)
            delete(figureData.axes);
            figureData.axes = [];
            set(gcf,'UserData',figureData);
            createaxes(gcf,figureData.defaultnode);%createcellfromstruct(figureData.defaultnode));
            for i = 1:length(data)
                createaxes(gcf,data{i});
            end
            doresize(gcf,eventData);
        else
            h = warndlg('Nothing was loaded','Loading objects');
            set(h,'WindowStyle','modal');    
        end
    catch
        err = lasterror;
        h = errordlg(err.message,'Load objects error');
        set(h,'WindowStyle','modal');
    end
        
%=================================================================        
    
function data = importfromlibrary(fileName)
    try
        data = [];
        variables = struct(whos('-file',fileName));
        variablesNode = strmatch('cell',str2mat(variables.class),'exact');
        names = {variables(variablesNode).name};
        data = cell(1,length(variablesNode));
        eval(['load ' '''' fileName '''']);
        for i = 1:length(variablesNode)
            data{i} = eval(names{i});
        end
    catch
%         rethrow('Plug-in configuration xml file seems to be corrupted.');
        messageStruct = lasterror;
        messageStruct.message = 'Plug-in configuration xml file seems to be corrupted.';
        rethrow(messageStruct);        
    end

%=================================================================        
    
function createaxes(hFigure,oneNode)
    oneNode = setmaintocenter(oneNode);
    hAxes = axes(...
        'Parent',hFigure,...
        'Tag','grapheditcanvas',...
        'Units','Pixels',...
        'SelectionHighlight','off',...
        'Drawmode','fast',...        'EraseMode','xor',...
        'Color','white',...
        'Box','on',...
        'HandleVisibility','off',...
        'XTickLabel',[],...
        'YTickLabel',[],...
        'XTickLabelMode','manual',...
        'YTickLabelMode','manual',...
        'TickLength',[0 0],...
        'ButtondownFcn',@buttondown,...
        'UserData',oneNode);
    figureData = get(hFigure,'UserData');
    figureData.axes(end+1) = hAxes;
    set(hFigure,'UserData',figureData);
    drawgraphicobjects(hAxes,oneNode);
    
%=================================================================        
    
function oneNode = setmaintocenter(oneNode)
    if iscell(oneNode), s = oneNode{1};
    else                s = oneNode; oneNode = [];
    end
    fNames = fieldnames(s);
    if sum(strcmp('picture',fNames))        % image
        deltaX = (s.x(2) - s.x(1))/2;
        deltaY = (s.y(2) - s.y(1))/2;
        s.x = [-deltaX deltaX];
        s.y = [-deltaY deltaY];
    elseif sum(strcmp('curvature',fNames))  % rectangle
        s.x = -s.width/2;
        s.y = -s.height/2;
    else                                    % patch
        deltaX = (max(s.x) - min(s.x))/2;
        deltaY = (max(s.y) - min(s.y))/2;
        s.x = s.x + (deltaX - max(s.x));
        s.y = s.y + (deltaY - max(s.y));
    end
    oneNode{1} = s;
    
%=================================================================        

function hObject = drawgraphicobjects(hAxes,cellOfObjects)
    hObject = [];
    try
        if ~isempty(cellOfObjects)
            for i = 2:length(cellOfObjects)
                cellOfObjects{i}.x = cellOfObjects{1}.x(1) + cellOfObjects{i}.x;
                cellOfObjects{i}.y = cellOfObjects{1}.y(1) + cellOfObjects{i}.y;
            end
            for i = 1:length(cellOfObjects)
                s = cellOfObjects{i};
                fNames = fieldnames(s);
                if sum(strcmp('picture',fNames))        % image
                    hObject(end+1) = createimage(hAxes,s);
                elseif sum(strcmp('curvature',fNames))  % rectangle
                    hObject(end+1) = createrectangle(hAxes,s);
                else                                    % patch
                    hObject(end+1) = createpatch(hAxes,s);
                end
            end
        end
    catch
        err = lasterror;
        h = errordlg(err.message,'Load error');
        set(h,'WindowStyle','modal');
    end
    
%=================================================================        

function hRectangle = createrectangle(hAxes,s)
    hRectangle = rectangle(...
        'Tag','node',...
        'Parent',hAxes,...
        'SelectionHighlight','off',...
        'Position',[s.x,s.y,s.width,s.height],...
        'Curvature',s.curvature,...
        'FaceColor',s.facecolor,...
        'LineWidth',s.linewidth,...
        'LineStyle',s.linestyle,...
        'EdgeColor',s.edgecolor,...
        'ButtondownFcn',@buttondown);
    
function hPatch = createpatch(hAxes,s)
    hPatch = patch(...
        'Tag','node',...
        'Parent',hAxes,...
        'XData',s.x,...
        'YData',s.y,...
        'SelectionHighlight','off',...
        'ButtondownFcn',@buttondown,...
        'LineWidth',s.linewidth,...
        'EdgeColor',s.edgecolor,...
        'FaceColor',s.facecolor,...
        'LineStyle',s.linestyle);
    
function hImage = createimage(hAxes,s)
    hImage = image(...
        'Tag','node',...
        'Parent',hAxes,...
        'CData',s.cdata,...
        'XData',s.x,...
        'YData',s.y,...
        'ButtondownFcn',@buttondown,...
        'UserData',s.picture);   
    
%=================================================================        

function im = getcdata(pictureName)
    color = 255*get(0,'factoryUicontrolBackgroundColor');
    im = imread(pictureName);
    [height,width,c] = size(im);    
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

function buttondown(hObject,eventData)
    if ~strcmp(get(hObject,'Type'),'axes')
        hObject = get(hObject,'Parent');
    end
    selectionType = get(gcf,'SelectionType');
    if strcmp(selectionType,'open')
        figureData = get(gcf,'UserData');
        set(figureData.axes,'LineWidth',1);
        set(hObject,'LineWidth',4);
        grapheditData = get(figureData.graphedit,'UserData');
        grapheditData.function.actualnodereplace(figureData.graphedit,get(hObject,'UserData'));
    end
    
%=================================================================        
%=================================================================        

function hFigure = grapheditcreatenewnode(library,varargin)
%GRAPHEDITCREATENEWNODE   Tool for creating patterns representing nodes.
%
%  See also NODE.


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



    drawbarWidth = 110;
    proportions = [550 320];
    grid = [20 20];
      
    hFigure = createfigure(proportions,drawbarWidth,grid,library);  
    
    if nargin > 1 && isa(varargin{1},'cell')
        drawgraphicobjects(varargin{1});
    end
    
    
    
%=================================================================   

function setdefaultdrawbar
    setbuttoncolor(findobj('Tag','createnewnodeface'),[1 1 1]);
    setbuttoncolor(findobj('Tag','createnewnodeline'),[0 0 0]);
    set(findobj('Tag','createnewnodelinewidth'),'Value',1);
    set(findobj('Tag','createnewnodelinestyle'),'Value',1);
    set(findobj('Tag','createnewnodecurvature'),'Value',1);

%=================================================================   

function copyformat(hObject,eventData)
    try
        structAxes = get(gca,'UserData');
        handles = get(gca,'Children');
        if ~isempty(structAxes.selected)
            if strcmp(get(hObject,'State'),'on')
                set(gcf,'Pointer','circle');
                cellObject = createstructurenode(structAxes.selected(1));
                selectoffallotherobjects(gca);
                set(handles,'ButtonDownFcn',{@setformat,cellObject{1}});
            end
        else
            set(gcf,'Pointer','arrow');
            set(hObject,'State','off');
            set(handles,'ButtonDownFcn',@buttondownoverobject);
        end
    catch
        set(gcf,'Pointer','arrow');
        return;
    end

%=================================================================   

function setformat(hObject,eventData,structure)
	fNames = fieldnames(structure);
    for i = 1:length(fNames)
        try
            if ~sum(strcmp(fNames{i},{'x','y','width','height','cdata','picture'}))
                set(hObject,fNames{i},eval(['structure.' fNames{i}]));
            end
        catch
        end
    end

%=================================================================   

function selectall(hObject,eventData)
    selectobject(get(gca,'Children'));

%=================================================================   
    
function cut(hObject,eventData)
    copy(hObject,eventData);
    structAxes = get(gca,'UserData');
    delete(structAxes.selected);

%=================================================================   

function copy(hObject,eventData)
    structAxes = get(gca,'UserData');
    structFigure = get(gcf,'UserData');
    if ~isempty(structAxes.selected)
        structFigure.box = createstructurenode(structAxes.selected);
    end
    set(gcf,'UserData',structFigure);

%=================================================================   
    
function paste(hObject,eventData)
    structFigure = get(gcf,'UserData');
    if ~isempty(structFigure.box)
        box = structFigure.box;
        if strcmp(get(hObject,'Type'),'uimenu')
            currentPoint = get(gca,'CurrentPoint');
            deltaX = currentPoint(1,1) - box{1}.x(1);
            deltaY = currentPoint(1,2) - box{1}.y(1);
            for i = 1:length(box)
                box{i}.x = box{i}.x + deltaX;
                box{i}.y = box{i}.y + deltaY;
            end
        else
            for i = 1:length(box)
                box{i}.x = box{i}.x + 10;
                box{i}.y = box{i}.y - 10;
            end
            structFigure.box = box;
            set(gcf,'UserData',structFigure); 
        end
        hObject = drawgraphicobjects(box);
        selectoffallotherobjects(hObject);
        selectobject(hObject);
    end        

%=================================================================   

function redo(hObject,eventData)
    try
        strF = get(findobj('Tag','createnewnodefigure'),'UserData');
        hRedo = findobj('Tag','toolbar_Redo');
        hUndo = findobj('Tag','toolbar_Undo');
        [strF.undo,strF.redo] = doundoredo(hUndo,strF.undo,hRedo,strF.redo);
        set(findobj('Tag','createnewnodefigure'),'UserData',strF);
    catch
        set(findobj('Tag','toolbar_Redo'),'Enable','off');
    end
    
%=================================================================      
    
function undo(hObject,eventData)
    try
        strF = get(findobj('Tag','createnewnodefigure'),'UserData');
        hRedo = findobj('Tag','toolbar_Redo');
        hUndo = findobj('Tag','toolbar_Undo');
        [strF.redo,strF.undo] = doundoredo(hRedo,strF.redo,hUndo,strF.undo);
        set(findobj('Tag','createnewnodefigure'),'UserData',strF);
    catch
        set(findobj('Tag','toolbar_Undo'),'Enable','off');
    end
    
%=================================================================   

function [undo,redo] = doundoredo(hUndo,undo,hRedo,redo)
    undo{end+1} = createstructurenode;
    delete(get(gca,'Children'));        
    drawgraphicobjects(redo{end});
    redo(end) = [];
    set(hUndo,'Enable','on');
    if isempty(redo)
        set(hRedo,'Enable','off');
    end

%=================================================================   
    
function savecurrentstate(varargin)
    structFigure = get(findobj('Tag','createnewnodefigure'),'UserData');
    structFigure.redo = [];
    structFigure.undo{end+1} = createstructurenode;
    if length(structFigure.undo) > 200
        structFigure.undo(1:(end-200)) = [];
    end
    set(findobj('Tag','toolbar_Undo'),'Enable','on');
    set(findobj('Tag','toolbar_Redo'),'Enable','off');
    set(findobj('Tag','createnewnodefigure'),'UserData',structFigure);
    
%=================================================================   
    
function erasehistory
    structFigure = get(findobj('Tag','createnewnodefigure'),'UserData');
    structFigure.redo = {};
    structFigure.undo = {};
    set(findobj('Tag','toolbar_Redo'),'Enable','off');
    set(findobj('Tag','toolbar_Undo'),'Enable','off');
    set(findobj('Tag','createnewnodefigure'),'UserData',structFigure);

%=================================================================   

function workwassaved
    hFigure = findobj('Tag','createnewnodefigure');
    name = get(hFigure,'Name');
    if name(end) == '*'
        name(end) = [];
        set(hFigure,'Name',name);
    end

%=================================================================   
    
function workwaschanged
    hFigure = findobj('Tag','createnewnodefigure');
    name = get(hFigure,'Name');
    if name(end) ~= '*'
        set(hFigure,'Name',[name '*']);
    end

%=================================================================   
    
function setfiguresname(pathname,filename,name)
    hFigure = findobj('Tag','createnewnodefigure');
    structFigure = get(hFigure,'UserData');
    structFigure.opened = {pathname filename name};
    set(hFigure,'UserData',structFigure);
    if isempty(name)
        set(hFigure,'Name',[filename]);
    else
        set(hFigure,'Name',[filename ': ' name]);
    end

%=================================================================  

function turnover(hMenu,eventData,type)
    savecurrentstate;
    structAxes = get(gca,'UserData');
    switch type
        case 'vert'
            doturnover(structAxes.selected,'YData');
        case 'horiz'
            doturnover(structAxes.selected,'XData');
        case 'right'
            doturnaround(structAxes.selected,'YData');
        case 'left'
            doturnaround(structAxes.selected,'XData');
        otherwise
            return;
    end

%=================================================================
    
function doturnover(hObject,param)
    for i = 1:length(hObject)
        try
            data = get(hObject(i),param);
            axe = (max(data) - min(data))/2 + min(data);
            set(hObject(i),param,2*axe-data);
        catch
            continue;
        end
    end
    
%=================================================================
    
function doturnaround(hObject,param)
    for i = 1:length(hObject)
        try % patch and image
            xData = get(hObject(i),'XData');
            yData = get(hObject(i),'YData');
            deltaX = (max(xData)-min(xData))/2 + min(xData);
            deltaY = (max(yData)-min(yData))/2 + min(yData);
            set(hObject(i),'XData',yData+(deltaX-deltaY),...
                'YData',xData-(deltaX-deltaY));
            doturnover(hObject(i),param);
        catch % rectangle
            pos = get(hObject(i),'Position');
            x = (pos(4)-pos(3))/2;
            set(hObject(i),'Position',[pos(1)-x pos(2)+x pos(4) pos(3)]);
        end
        try  % image
            cData = get(hObject(i),'CData');
            cData2(:,:,1) = cData(:,:,1)';
            cData2(:,:,2) = cData(:,:,2)';
            cData2(:,:,3) = cData(:,:,3)';
            set(hObject(i),'CData',cData2);
        catch %patch and rectangle
            return;
        end
    end

    
%=================================================================

function changesequence(hMenu,eventData,hObject,type)
    savecurrentstate;
    structAxes = get(gca,'UserData');
    for i = 1:length(structAxes.selected)
        hObject = structAxes.selected(i);
        handles = get(gca,'Children');
        index = find(handles == hObject);
        switch type
            case 'top'
                handles = [hObject; handles];
                index = index + 1;
            case 'above'
                try   handles = [handles(1:(index-2)); hObject; handles((index-1):end)];
                catch handles = [hObject; handles];
                end
                index = index + 1;
            case 'below'
                try   handles = [handles(1:(index+1)); hObject; handles((index+2):end)];
                catch handles = [handles; hObject];
                end
            case 'bottom'
                handles = [handles; hObject];
            otherwise
                return;
        end
        handles(index) = [];
        set(gca,'Children',handles);
    end

%=================================================================   

function doselectobjects(hRect,eventData)
    position = get(hRect,'Position');
    if position(3) > 10 && position(4) > 10
        xLim = [position(1) position(1)+position(3)];
        yLim = [position(2) position(2)+position(4)];    
        handles = get(gca,'Children');
        handles(handles == hRect) = [];
        if ~isempty(handles)
            for i = 1:length(handles)
                if isin(handles(i),xLim,yLim)
                    selectobject(handles(i));
                end
            end
        end
    end
    set(gca,'ButtonDownFcn',@buttondownoveraxes);
    
%=================================================================   
    
function is = isin(hObject,xLim,yLim)
    is = 0;
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
        is = 1;
    end

%=================================================================   

function [hRectangle,position] = createselectionrectangle
    currentPoint = get(gca,'CurrentPoint');
    position = [currentPoint(1,1) currentPoint(1,2) 1 1];
    set(gca,'ButtonDownFcn','');
    hRectangle = rectangle(...
        'Tag','selection',...
        'Parent',gca,...
        'Position',position,...
        'LineStyle','-.',...
        'DeleteFcn',@doselectobjects);
    
%=================================================================   

function stoppullselectionrectangle(hFigure,eventData,hRectangle)
    stoppull(hFigure,eventData);
    delete(hRectangle);

%=================================================================   

function changebuttonforsize(hObject,eventData)
    if get(hObject,'Value') == 1
        set(findobj('Tag','createnewnodesizebuttonxy'),'Visible','on');
        set(findobj('Tag','createnewnodesizebuttonx'),'Visible','off');
        set(findobj('Tag','createnewnodesizebuttony'),'Visible','off');
    else
        set(findobj('Tag','createnewnodesizebuttonxy'),'Visible','off');
        set(findobj('Tag','createnewnodesizebuttonx'),'Visible','on');
        set(findobj('Tag','createnewnodesizebuttony'),'Visible','on');
    end
    
%=================================================================   

function changesize(hObject,eventData,typeCell)
    savecurrentstate;
    for i = 1:length(typeCell)
        cellOfValues = get(findobj('Tag',['createnewnodesizepoup' typeCell{i}]),'String');
        str = cellOfValues{get(findobj('Tag',['createnewnodesizepoup' typeCell{i}]),'Value')};
        number = str2double(str);
        structAxes = get(gca,'UserData');
        for j = 1:length(structAxes.selected)
            dochangesize(structAxes.selected(j),number,typeCell{i});
        end
    end

%=================================================================   

function dochangesize(hObject,value,typeStr)
    switch get(hObject,'Type')
        case 'rectangle'
            position = get(hObject,'Position');
            if strcmp(typeStr,'x')
                position(3) = position(3) + value;
            else
                position(4) = position(4) + value;
            end
            set(hObject,'Position',position);
        case 'patch'
            data = get(hObject,[typeStr 'Data']);
            minimum = min(data);
            delta = max(data) - minimum;
            data2 = data - minimum;
            data = data + data2/delta*value;
            set(hObject,[typeStr 'Data'],data);
        case 'image'
            data = get(hObject,[typeStr 'Data']);
            index = find(data == max(data));
            data(index) = data(index) + value;
            set(hObject,[typeStr 'Data'],data);
        otherwise
            error('This object cannot be changed.');
    end

%=================================================================    

function dialogcolor(hObject,eventData,colorType)
    savecurrentstate;
    structAxes = get(gca,'UserData');
    color = uisetcolor(get(hObject,'Backgroundcolor'),'PropEditor - palette');
    if (length(color) ~= 1)
        setbuttoncolor(hObject,color);
        for i = 1:length(structAxes.selected)
            if ~strcmp(get(structAxes.selected(i),'Type'),'image')
                if strcmp(colorType,'FaceColor')
                    structObject = get(structAxes.selected(i),'UserData');
                    structObject{2} = color;
                    set(structAxes.selected(i),'UserData',structObject);
                end
                set(structAxes.selected(i),colorType,color);
            end
        end
    end

%================================================================= 

function setlinewidth(hObject,eventData)
    savecurrentstate;
    structAxes = get(gca,'UserData');
    for i = 1:length(structAxes.selected)
        if ~strcmp(get(structAxes.selected(i),'Type'),'image')
            structObject = get(structAxes.selected(i),'UserData');
            structObject{1} = get(hObject,'Value');
            set(structAxes.selected(i),'UserData',structObject);
            %set(structAxes.selected,'LineWidth',get(hObject,'Value'));
        end
    end

%=================================================================    

function setlinestyle(hObject,eventData)
    savecurrentstate;
    properties = get(hObject,'String');
    structAxes = get(gca,'UserData');
    set(structAxes.selected,'LineStyle',properties{get(hObject,'Value')});

%=================================================================    

function setcurvature(hObject,eventData)
    savecurrentstate;
    curvature = (get(hObject,'Value')-1)/10;
    structAxes = get(gca,'UserData');
    for i = 1:length(structAxes.selected)
        if strcmp(get(structAxes.selected(i),'Type'),'rectangle')
            set(structAxes.selected(i),'Curvature',[curvature curvature]);
        end
    end

%=================================================================

function moving(hF,eD,handles,xLim,yLim,delta,width,height,attach)
    for i = 1:length(handles)
        point = testoflimits(getpoint(attach,delta{i,:}),xLim{i,:},yLim{i,:});
        try
            set(handles(i),'XData',point(1)+width{i,:},'YData',point(2)+height{i,:});
        catch
            set(handles(i),'Position',[point(1) point(2) width{i,:}(2) height{i,:}(2)]);
        end
    end
    
%=================================================================    

function movegraphicobject(hObject)
    savecurrentstate;
    structAxes = get(gca,'UserData');
    handles = structAxes.selected;
    if ~isempty(handles)
        point = get(gca,'CurrentPoint');
        numObjects = length(handles);
        width = cell(numObjects,1);
        height = cell(numObjects,1);
        delta = cell(numObjects,1);
        xLimObjects = cell(numObjects,1);
        yLimObjects = cell(numObjects,1);
        for i = 1:numObjects
            xLim = get(gca,'XLim'); 
            yLim = get(gca,'YLim');    
            switch get(handles(i),'Type')
                case 'rectangle'
                    position = get(handles(i),'Position');
                    xData = [position(1) position(1)+position(3)];
                    yData = [position(2) position(2)+position(4)];
                    xLim = [(xLim(1)-position(3)/2) (xLim(2)-position(3)/2)];
                    yLim = [(yLim(1)-position(4)/2) (yLim(2)-position(4)/2)];            
                case 'patch'
                    xData = get(handles(i),'XData');
                    yData = get(handles(i),'YData');
                    xHalf = [xData(1)-min(xData) max(xData)-xData(1)]/2;
                    yHalf = [yData(1)-min(yData) max(yData)-yData(1)]/2;
                    xLim = [xLim(1) xLim(2)+xHalf(2)];
                    yLim = [yLim(1)-yHalf(1) yLim(2)];
                case 'image'
                    xData = get(handles(i),'XData');
                    yData = get(handles(i),'YData');
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
        attach = get(findobj('Tag','createnewnodeatachtogrid'),'value');
        set(gcf,'WindowButtonMotionFcn',{@moving,handles,...
                    xLimObjects,yLimObjects,delta,width,height,attach},...
                'WindowButtonUpFcn',@stoppull);
    end

%=================================================================

function selectobject(hObject)
    if ~isempty(hObject)
        structAxes = get(gca,'UserData');
        for i = 1:length(hObject)
            if isempty(find(structAxes.selected == hObject(i)))
                if strcmp(get(hObject(i),'Type'),'rectangle') ||...
                        strcmp(get(hObject(i),'Type'),'patch')
                    set(hObject(i),...
                        'UserData',{get(hObject(i),'LineWidth') get(hObject(i),'FaceColor')},...
                        'LineWidth',5);%,...   'FaceColor',[.5 1 .3]);
                elseif strcmp(get(hObject(i),'Type'),'image')
                    set(hObject(i),'Selected','on','SelectionHighlight','on');
                end
                structAxes.selected(end+1) = hObject(i);
            end
        end
        set(gca,'UserData',structAxes);
        copydatatodrawbar(hObject(end));
        setenabledrawbar(hObject(end));
    end
    
%=================================================================    
    
function copydatatodrawbar(hObject)
    switch get(hObject,'Type')
        case {'rectangle','patch'}
            structObject = get(hObject,'UserData');
            setbuttoncolor(findobj('Tag','createnewnodeface'),structObject{2});
            setbuttoncolor(findobj('Tag','createnewnodeline'),get(hObject,'EdgeColor'));
            set(findobj('Tag','createnewnodelinewidth'),'Value',structObject{1});
            lineProperties = get(findobj('Tag','createnewnodelinestyle'),'String');
            set(findobj('Tag','createnewnodelinestyle'),'Value',find(strcmpi(lineProperties,get(hObject,'LineStyle'))));
            if strcmp(get(hObject,'Type'),'rectangle');
                curv = get(hObject,'Curvature');
                set(findobj('Tag','createnewnodecurvature'),'Value',((10*curv(1))+1));
            end
        case 'image'
        otherwise
    end     

%=================================================================    

function selectoffobject(hObject)
    structAxes = get(gca,'UserData');
    if ~isempty(structAxes.selected)
        index = find(structAxes.selected == hObject);
        if ~isempty(index)
            if strcmp(get(hObject,'Type'),'rectangle') ||...
                    strcmp(get(hObject,'Type'),'patch')
                userData = get(hObject,'UserData');
                set(hObject,...
                    'LineWidth',userData{1},...
                    'FaceColor',userData{2});
            elseif strcmp(get(hObject,'Type'),'image')
                set(hObject,'Selected','off','SelectionHighlight','off');
            end
            structAxes.selected(index) = [];
            if isempty(structAxes.selected)
                setdefaultdrawbar;
            end    
        end
    end
    set(gca,'UserData',structAxes);

%=================================================================    

function selectoffallotherobjects(hObject)
    structAxes = get(gca,'UserData');
    handles = structAxes.selected;
    if ~isempty(handles)
        toRemove = [];
        for i = 1:length(handles)
            if handles(i) ~= hObject
                if strcmp(get(handles(i),'Type'),'rectangle') ||...
                        strcmp(get(handles(i),'Type'),'patch')
                    userData = get(handles(i),'UserData');
                    set(handles(i),...
                        'LineWidth',userData{1},...
                        'FaceColor',userData{2});
                elseif strcmp(get(handles(i),'Type'),'image')
                    set(handles(i),'Selected','off','SelectionHighlight','off');
                end
                toRemove(end+1) = i;
            end
        end
        structAxes.selected(toRemove) = [];
    end 
    set(gca,'UserData',structAxes);
    if hObject == gca
        setdefaultdrawbar;
    end

%=================================================================

function buttondownoverobject(hObject,eventData)
    workwaschanged;
    selectionType = get(gcbf,'SelectionType');
    structAxes = get(gca,'UserData');
    if strcmp(selectionType,'normal')
        if isempty(find(structAxes.selected == hObject))
            selectoffallotherobjects(hObject);
        end
        selectobject(hObject);
        structAxes = get(gca,'UserData');
        savecurrentstate;
        if strcmp(get(findobj('Tag','toolbar_DeleteMode'),'State'),'on')
            delete(structAxes.selected);
        else
            movegraphicobject(hObject);
        end
    elseif strcmp(selectionType,'alt')
        savecurrentstate;
        selectobject(hObject);
    elseif strcmp(selectionType,'extend')
        if ~isempty(find(structAxes.selected == hObject))
            selectoffobject(hObject);
        else
            selectobject(hObject);
        end
    elseif strcmp(selectionType,'open')
        selectobject(findobj('Type',get(hObject,'Type'),'Parent',gca));
    end

%=================================================================        

function buttondownoveraxes(hAxes,eventData)
    workwaschanged;
    setenabledrawbar(hAxes);
    selectoffallotherobjects(hAxes);
    selectionType = get(gcbf,'SelectionType');
    if strcmp(selectionType,'normal')
        if strcmp(get(findobj('Tag','toolbar_DrawRectangle'),'State'),'on')
            currentPoint = getpoint(...
                get(findobj('Tag','createnewnodeatachtogrid'),'value'));
            drawrectangle(currentPoint);
        elseif strcmp(get(findobj('Tag','toolbar_DrawPatch'),'State'),'on')
            currentPoint = getpoint(...
                get(findobj('Tag','createnewnodeatachtogrid'),'value'));
            drawpatch(currentPoint);
        else
           [hRect,position] = createselectionrectangle;
            xLim = get(gca,'XLim');
            yLim = get(gca,'YLim');
            set(gcf,...
                'WindowButtonMotionFcn',{@pullrectangle,hRect,xLim,yLim,position(1:2),0,position},...
                'WindowButtonUpFcn',{@stoppullselectionrectangle,hRect});
        end
    elseif strcmp(selectionType,'alt')
        %...
    elseif strcmp(selectionType,'extend')
        %...
    elseif strcmp(selectionType,'open')
        %...
    end

%================================================================= 

function drawrectangle(currentPoint)
    savecurrentstate;
    set(get(gca,'Children'),'ButtonDownFcn','');
    position = [currentPoint(1) currentPoint(2) 1 1];
    lineStyleProp = get(findobj('Tag','createnewnodelinestyle'),'String');
    lineStyle = lineStyleProp{get(findobj('Tag','createnewnodelinestyle'),'Value')};
    lineWidth = get(findobj('Tag','createnewnodelinewidth'),'Value');
    curvature = (get(findobj('Tag','createnewnodecurvature'),'Value')-1)/10;
    s = struct(...
           'x',currentPoint(1),...
           'y',currentPoint(2),...
           'width',1,...
           'height',1,...
           'linewidth',lineWidth,...
           'linestyle',lineStyle,...
           'edgecolor',get(findobj('Tag','createnewnodeline'),'BackgroundColor'),...
           'facecolor',get(findobj('Tag','createnewnodeface'),'BackgroundColor'),...
           'curvature',curvature);
    hRectangle = createrectangle(s);
       
    xLim = get(gca,'XLim');
    yLim = get(gca,'YLim');
    set(gca,'ButtonDownFcn',@stoppull);
    set(gcf,...
        'WindowButtonMotionFcn',{@pullrectangle,...
            hRectangle,...
            xLim,...
            yLim,...
            currentPoint,...
            get(findobj('Tag','createnewnodeatachtogrid'),'value'),...
            position},...
        'WindowButtonDownFcn','');
%     saveproportions(hRectangle);

%=================================================================    

function pullrectangle(hFigure,eventData,hRectangle,xLim,yLim,point,attach,position)
    currentPoint = testoflimits(getpoint(attach),xLim,yLim);
    
    if (currentPoint(1) > point(1))
        position(1) = point(1);
        position(3) = currentPoint(1) - point(1);
    else
        position(1) = currentPoint(1);
        position(3) = point(1) - currentPoint(1);
    end
    if (currentPoint(2) > point(2))
        position(2) = point(2);
        position(4) = currentPoint(2) - point(2);
    else
        position(2) = currentPoint(2);
        position(4) = point(2) - currentPoint(2);
    end

    position(find(-1 < position & position < 1)) = 1;
    set(hRectangle,'Position',position);
    
%=================================================================    

function stoppull(hFigure,eventData)
    set(gcf,...
        'WindowButtonMotionFcn','',...
        'WindowButtonDownFcn','',...
        'WindowButtonUpFcn','');
    set(gca,'ButtonDownFcn',@buttondownoveraxes);
    set(get(gca,'Children'),'ButtonDownFcn',@buttondownoverobject);
    resaveproportions;
        
%=================================================================    

function drawpatch(currentPoint)
    savecurrentstate;
    set(get(gca,'Children'),'ButtonDownFcn','');
    lineStyleProp = get(findobj('Tag','createnewnodelinestyle'),'String');
    lineStyle = lineStyleProp{get(findobj('Tag','createnewnodelinestyle'),'Value')};
    lineWidth = get(findobj('Tag','createnewnodelinewidth'),'Value');
    edgeColor = get(findobj('Tag','createnewnodeline'),'BackgroundColor');
    faceColor = get(findobj('Tag','createnewnodeface'),'BackgroundColor');
    delete(findobj('Type','line'));
    s = struct('x',[currentPoint(1); currentPoint(1)],...
               'y',[currentPoint(2); currentPoint(2)],...
               'linewidth',lineWidth,...
               'linestyle',lineStyle,...
               'edgecolor',edgeColor,...
               'facecolor',faceColor);
    hPatch = createpatch(s);
    set(hPatch,'ButtonDownFcn','');
    set(gca,'ButtonDownFcn','');
    xLim = get(gca,'XLim');
    yLim = get(gca,'YLim'); 
    set(gcf,'WindowButtonMotionFcn',{@pullpatch,hPatch,xLim,yLim,...
                get(findobj('Tag','createnewnodeatachtogrid'),'value')},...
            'WindowButtonDownFcn',{@createpoint,hPatch,xLim,yLim,...
                get(findobj('Tag','createnewnodeatachtogrid'),'value')});
    set(gca,'ButtonDownFcn',{@createpoint,hPatch,xLim,yLim,...
                 get(findobj('Tag','createnewnodeatachtogrid'),'value')});
    
%=================================================================

function pullpatch(hFigure,eventData,hPatch,xLim,yLim,attach)
    currentPoint = testoflimits(getpoint(attach),xLim,yLim);
    xData = get(hPatch,'XData');
    yData = get(hPatch,'YData');
    xData(end) = currentPoint(1);
    yData(end) = currentPoint(2);
    set(hPatch,'XData',xData,'YData',yData);

%================================================================= 

function createpoint(hFigure,eventData,hPatch,xLim,yLim,attach)
    selectionType = get(gcbf,'SelectionType');
    xData = get(hPatch,'XData');
    yData = get(hPatch,'YData');
    [xDataF,yDataF] = filterdata(xData(1:(end)),yData(1:(end)));
    xData = [xDataF; xData(end)];
    yData = [yDataF; yData(end)];
    if strcmp(selectionType,'open')
        set(hPatch,...
            'XData',xData,...
            'YData',yData);
        stoppull(hFigure,eventData);
        selectobject(hPatch);
        saveproportions(hPatch);
    elseif strcmp(selectionType,'normal')
        currentPoint = testoflimits(getpoint(attach),xLim,yLim);
        set(hPatch,...
            'XData',[xData; currentPoint(1)],...
            'YData',[yData; currentPoint(2)]);
    end
   
%=================================================================    

function [xData,yData] = filterdata(xData,yData)
    index = find(xData == xData(end) & yData == yData(end));
    j = length(index);
    if j > 2
        for i = length(xData):-1:index(1)
            if(index(j) ~= i)
                index = index(j+1:end);
                break;
            end
            j = j - 1;
        end
        xData(index) = [];
        yData(index) = [];
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

function openexisting(hObject,eventData)
    if newpicture(hObject,eventData);
        importfromfile(hObject,eventData);
    end
    
%=================================================================

function importfromlibrary(hObject,eventData)
    userData = get(gcf,'UserData');
    importfromfile(hObject,eventData,userData.library);

%=================================================================

function importfromfile(hObject,eventData,varargin)
    savecurrentstate;
    oldpath = pwd;
    try
        objNode = [];
        if nargin < 3
            [filename,pathname] = uigetfile('*.mat','Load graph');
            if (filename == 0), return; end     % storno
        else
            [pathname,filename,ext] = fileparts(varargin{1});
            filename = [filename ext];
            if isempty(pathname)
                [pathname,f] = fileparts(mfilename('fullpath'));
            end
        end
        oldpath = pwd;
        cd(pathname);
        variables = struct(whos('-file',filename));
        variablesNode = strmatch('cell',str2mat(variables.class),'exact');
        if (isempty(variablesNode))
            h = errordlg(...
                ['No valid variable was found in file ' filename '!'],...
                'Variable not found');
            set(h,'WindowStyle','modal');
            return;
        else
            if length(variablesNode) == 1
                name = variables(variablesNode).name;
            else
                listObjNodes = {variables(variablesNode).name};
                [name,isNewName] = grapheditlistdlg(...
                    'parentfigure',gcbf,...
                    'filename',filename,...
                    'list1',listObjNodes,...
                    'listname','Cells in file:',...
                    'okstring','Open',...
                    'cancelstring','Cancel',...
                    'editname','Open variable: ',...
                    'checktext','view only cells',...
                    'checkenable','off',...
                    'editenable','off',...
                    'position','rightup');
            end
            if (~isempty(name))
                eval(['load ' filename ' ' name]);
                objNode = eval(name);
                setfiguresname(pwd,filename,name); 
            else
                return;
            end
        end       
        cd(oldpath);
    catch
        cd(oldpath);
        err = lasterror;
        h = errordlg(err.message,'Load objects error');
        set(h,'WindowStyle','modal');
    end
    drawgraphicobjects(objNode);
    
%================================================================= 

function exporttolibrary(hObject,eventData)
    userData = get(gcf,'UserData');
    exporttofile(hObject,eventData,userData.library);

%=================================================================    

function wasExported = exporttofile(hObject,eventData,varargin)
    wasExported = 0;
    global objNode;
    oldpath = pwd;
    try
        if ~isempty(get(gca,'children'))
            [file,variableName] = getfilepathandvariablename(varargin{:});
            if isempty(variableName) || isempty(file),  return;    end    % storno
            objNode = createstructurenode;
            eval('global objNode;');
            eval([variableName ' = objNode;']);
            [pathname,filename,ext] = fileparts(file);
            if isempty(pathname)
                pathname = [matlabroot filesep 'work'];
            end           
            cd(pathname);
            if exist([pathname filesep filename ext])
                eval(['save ' '''' [pathname filesep filename ext] '''' ' ' variableName ' -append;']);
            else
                eval(['save ' '''' [pathname filesep filename ext] '''' ' ' variableName ';']);
            end %eval(['load ' '''' fileName '''']);
            cd(oldpath);
            workwassaved;
            setfiguresname(pathname,[filename ext],variableName);
        end 
        eval('clear objNode;');
        wasExported = 1;
    catch
        eval('clear objNode;');
        cd(oldpath);
        err = lasterror;
        h = errordlg(err.message,'Save objects error');
        set(h,'WindowStyle','modal');
    end

%=================================================================

function [file,variableName] = getfilepathandvariablename(varargin)
    listEnable = 'off';
    listObjNodes = {}; listObjs = {};
    if nargin == 0
        [filename,pathname] = uiputfile('*.mat','Save new node');
        if (filename == 0), file = []; variableName = ''; return;  end      % storno
        [name,ext] = fileparts(filename);
        if isempty(ext)
            filename = [filename '.mat'];
        end
        file = [pathname filename];
    else
        file = varargin{1};
        [pathname,filename,ext] = fileparts(file);
    end
    if exist(file,'file')
        variables = struct(whos('-file',file));
        listObjs = {variables(:).name};
        variablesNode = strmatch('cell',str2mat(variables.class),'exact');
        listObjNodes = {variables(variablesNode).name};
        listEnable = 'on';
    end
    [variableName,isNewName] = grapheditlistdlg(...
        'parentfigure',gcbf,...
        'filename',filename,...        
        'list1',listObjNodes,...        
        'list2',listObjs,...
        'listname','Variables in file:',...
        'okstring','Save',...
        'cancelstring','Cancel',...
        'editname','New variable: ',...
        'checktext','view only cells',...
        'checkenable','on',...
        'queststring','Do you want to replace this variable?',...
        'listenable',listEnable,...
        'position','rightup',...
        'initialname','myNode');

%=================================================================

function importfromworkspace(hObject,eventData)
    savecurrentstate;
    variables = struct(evalin('base','whos'));
    variablesNode = strmatch('cell',str2mat(variables.class),'exact');
    name = [];
    if (isempty(variablesNode))
        h = errordlg(...
            ['There is no cell in the ' 'workspace' '!'],...
            'Variable not found');
        set(h,...
            'WindowStyle','modal');
        return;
    elseif (length(variablesNode) == 1)
        name = variables(variablesNode).name;
        objNode = evalin('base',name);
    elseif (length(variablesNode) > 1)
        listObjNodes = {variables(variablesNode).name};
        [name,isNewName] = grapheditlistdlg(...
                'parentfigure',gcbf,...
                'filename','Workspace',...
                'list1',listObjNodes,...
                'listname','Cells in workspace:',...
                'okstring','Import',...
                'cancelstring','Cancel',...
                'editname','Import variable: ',...
                'checktext','view only cells',...
                'checkenable','off',...
                'editenable','off',...
                'position','rightup');
        if (~isempty(name))
            objNode = evalin('base',name);
        else
            return;
        end        
    end
    drawgraphicobjects(objNode);
    setfiguresname('','Workspace',name);
    
%=================================================================

function exporttoworkspace(hObject,eventData)
    if ~isempty(get(gca,'children'))
        variables = struct(evalin('base','whos'));
        listObjs = {variables(:).name};
        variablesNode = strmatch('cell',str2mat(variables.class),'exact');
        listObjNodes = {variables(variablesNode).name};
        [name,isNewName] = grapheditlistdlg(...
            'parentfigure',gcbf,...
            'filename','Workspace',...
            'list1',listObjNodes,...
            'list2',listObjs,...
            'listname','Variables in workspace:',...
            'okstring','Export',...
            'cancelstring','Cancel',...
            'editname','Export to: ',...
            'checktext','view only cells',...
            'queststring','Do you want to replace variable?',...
            'position','rightup',...
            'initialname','myNode');
        if (~isempty(name))
            objNode = createstructurenode;
            assignin('base',name,objNode);
        else
            return;
        end
    end

%=================================================================

function structure = createstructurenode(varargin)
    handles = get(gca,'Children');
    if nargin > 0
        handles = varargin{1};
    end
    structure = cell(1,length(handles)); i = 0;
    while ~isempty(handles)
        i = i + 1;
        s = [];
        userData = get(handles(end),'UserData');
        switch get(handles(end),'Type')
            case 'rectangle'
                position = get(handles(end),'Position');
                s.x = position(1);
                s.y = position(2);
                s.width = position(3);
                s.height = position(4);
                s.curvature = get(handles(end),'Curvature');
                s.facecolor = get(handles(end),'FaceColor');
                s.edgecolor = get(handles(end),'EdgeColor');
                s.linestyle = get(handles(end),'LineStyle');
                s.linewidth = userData{1}; %get(handles(end),'lineWidth');
            case 'patch'
                s.x = get(handles(end),'XData');
                s.y = get(handles(end),'YData');
                s.facecolor = get(handles(end),'FaceColor');
                s.edgecolor = get(handles(end),'EdgeColor');
                s.linestyle = get(handles(end),'LineStyle');
                s.linewidth = userData{1}; %get(handles(end),'lineWidth');
            case 'image'
                s.x = get(handles(end),'XData');
                s.y = get(handles(end),'YData');
                s.cdata = get(handles(end),'CData');
                s.picture = userData;
        end
        structure{i} = s;
        handles(end) = [];
    end
    structure = repairpositions1(structure);
    
%=================================================================   

function structure = repairpositions1(structure)
    for i = 2:length(structure)
        structure{i}.x = structure{i}.x - structure{1}.x(1);
        structure{i}.y = structure{i}.y - structure{1}.y(1);
    end

function structure = repairpositions2(structure)
    for i = 2:length(structure)
        structure{i}.x = structure{1}.x(1) + structure{i}.x;
        structure{i}.y = structure{1}.y(1) + structure{i}.y;
    end

%=================================================================   

function hObject = drawgraphicobjects(cellOfObjects)
    hObject = [];
    try
        if ~isempty(cellOfObjects)
            cellOfObjects = repairpositions2(cellOfObjects);
            for i = 1:length(cellOfObjects)
                s = cellOfObjects{i};
                fNames = fieldnames(s);
                if sum(strcmp('picture',fNames))        % image
                    hObject(end+1) = createimage(s.x,s.y,s.cdata,s.picture);
                elseif sum(strcmp('curvature',fNames))  % rectangle
                    hObject(end+1) = createrectangle(s);
                else                                    % patch
                    hObject(end+1) = createpatch(s);
                end
            end
            saveproportions(hObject);
        end
    catch
        err = lasterror;
        h = errordlg(err.message,'Load error');
        set(h,'WindowStyle','modal');
    end

%================================================================= 

function resaveproportions
    structAxes = get(gca,'UserData');  
    [structAxes.childreny,structAxes.childrenx] =...
        getproportions(get(gca,'Children'));
    set(gca,'UserData',structAxes);
    
%================================================================= 

function saveproportions(hObject)
    structAxes = get(gca,'UserData');  
    [height,width] = getproportions(hObject);
    if height(1) < structAxes.childreny(1)
        structAxes.childreny(1) = height(1);
    end
    if height(2) > structAxes.childreny(2)
        structAxes.childreny(2) = height(2);
    end
    if width(1) < structAxes.childrenx(1)
        structAxes.childrenx(1) = width(1);
    end
    if width(2) > structAxes.childreny(2)
        structAxes.childrenx(2) = width(2);
    end
    set(gca,'UserData',structAxes);

%================================================================= 

function [height,width] = getproportions(children)
    if ~isempty(children)
        stock = zeros(length(children),4);
        for i = 1:length(children)
            try
                pos = get(children(i),'position');
                stock(i,1) = pos(1);
                stock(i,2) = pos(1) + pos(3);
                stock(i,3) = pos(2);
                stock(i,4) = pos(2) + pos(4);
            catch
                xData = get(children(i),'XData');
                yData = get(children(i),'YData');
                stock(i,1) = min(xData);
                stock(i,2) = max(xData);
                stock(i,3) = min(yData);
                stock(i,4) = max(yData);
            end
        end
        height = [min(stock(:,3)) max(stock(:,4))];
        width = [min(stock(:,1)) max(stock(:,2))];
    else
        height = [-1 1];
        width = [-1 1];
    end
        
%=================================================================
    
function hImage = createimage(positionX,positionY,cData,picture)
        if isempty(cData)
            cData = imread(picture);
            cData = cData(end:-1:1,:,:);
        end
        hImage = image(cData);
        set(hImage,...
            'Tag','image',...
            'XData',positionX,...
            'YData',positionY,...
            'ButtonDownFcn',@buttondownoverobject,...
            'DeleteFcn',@objectdeleted,...
            'UserData',picture);
        setcontextmenu(hImage);

%=================================================================

function hRectangle = createrectangle(s)
    hRectangle = rectangle(...
        'Tag','rectangle',...
        'SelectionHighlight','off',...
        'Position',[s.x,s.y,s.width,s.height],...
        'Curvature',s.curvature,...
        'FaceColor',s.facecolor,...
        'LineWidth',s.linewidth,...
        'LineStyle',s.linestyle,...
        'EdgeColor',s.edgecolor,...
        'ButtonDownFcn',@buttondownoverobject,...
        'DeleteFcn',@objectdeleted,...
        'UserData',{s.linewidth s.facecolor});
    setcontextmenu(hRectangle);

%=================================================================

function hPatch = createpatch(s)
    hPatch = patch(...
        'Tag','patch',...
        'XData',s.x,...
        'YData',s.y,...
        'SelectionHighlight','off',...
        'LineWidth',s.linewidth,...
        'EdgeColor',s.edgecolor,...
        'FaceColor',s.facecolor,...
        'LineStyle',s.linestyle,...
        'ButtonDownFcn',@buttondownoverobject,...
        'DeleteFcn',@objectdeleted,...
        'UserData',{s.linewidth s.facecolor});
    setcontextmenu(hPatch);
    
%=================================================================   

function objectdeleted(hObject,eventData)
    structAxes = get(gca,'UserData');
    delete(structAxes.selected);
    structAxes.selected = [];
    setenabledrawbar(gca)
    set(gca,'UserData',structAxes);
    set(gcf,...
        'WindowButtonMotionFcn','',...
        'WindowButtonDownFcn','',...
        'WindowButtonUpFcn','');

%=================================================================

function isNew = newpicture(hObject,eventData)
    isNew = 0;
    if ~isempty(get(gca,'Children'))
        button = questdlg(...
            'Do you want to remove all drawn objects?',...
            'Continue Operation','Yes','No','No');
        if strcmp(button,'Yes')
            delete(get(gca,'Children'));
        end
        if strcmp(button,'No')
            return;
        end
    end
    setfiguresname('','New node','');
    isNew = 1;
    erasehistory;

%=================================================================    

function setgridtick(hObject,eventData)
    number1 = round(str2double(get(hObject,'string')));
    if ~isnan(number1)
        structAxes = get(gca,'UserData');
        if strcmp(get(hObject,'Tag'),'createnewnodegridx')
            structAxes.gridx = number1;
        else
            structAxes.gridy = number1;
        end
        set(gca,'UserData',structAxes);
        settick;
    else
        h = errordlg(...
            ['Invalid number "' get(hObject,'string') '" !'],...
            ' Invalid input');
        set(h,'WindowStyle','modal');
    end

%=================================================================    
    
function settick
    hAxes = findobj('Tag','createnewnodeaxes');
    structAxes = get(hAxes,'UserData');
    xLim = get(hAxes,'XLim');
    yLim = get(hAxes,'YLim');
    startX = xLim(1) - mod(xLim(1),structAxes.gridx);
    startY = yLim(1) - mod(yLim(1),structAxes.gridy);
    set(hAxes,'XTick',startX:structAxes.gridx:xLim(2));
    set(hAxes,'YTick',startY:structAxes.gridy:yLim(2));

%=================================================================     
    
function setlim
    hAxes = findobj('Tag','createnewnodeaxes');
    position = get(hAxes,'Position');
    structAxes = get(hAxes,'UserData');
	xLim = get(hAxes,'XLim');
    yLim = get(hAxes,'YLim');
    deltaX = (position(3) - (xLim(2)-xLim(1)))/2;
    deltaY = (position(4) - (yLim(2)-yLim(1)))/2;
    set(hAxes,'XLim',[xLim(1)-deltaX xLim(2)+deltaX]./structAxes.zoom +...
               get(findobj('Tag','createnewnodeviewsliderx'),'Value'));
    set(hAxes,'YLim',[yLim(1)-deltaY yLim(2)+deltaY]./structAxes.zoom +...
               get(findobj('Tag','createnewnodeviewslidery'),'Value'));
    settick;

%=================================================================    

function viewgrid(hObject,eventData)
    if get(hObject,'value') == 1
        set(gca,'XGrid','on','YGrid','on');
    else
        set(gca,'XGrid','off','YGrid','off');
    end

%=================================================================    

function openpicture(hObject,eventData)
    try
        [filename, pathname] = uigetfile( ...
            {'*.jpg','Joint Photographic Experts Group (*.jpg)';...
             '*.png','Portable Network Graphics (*.png)'; ...
             '*.bmp', 'Windows Bitmap (*.bmp)';...
             '*.*', 'All files (*.*)';...
            },'Open picture');
        if filename ~= 0
            im = imread([pathname filename]);
            im = im(end:-1:1,:,:);
            [height,width,c] = size(im);
            savecurrentstate;
            hImage = createimage(...
                [-width/2  width/2],...
                [-height/2 height/2],...
                im,...
                [pathname filename]);
            selectobject(hImage);
            selectoffallotherobjects(hImage);
            saveproportions(hImage);
        end
    catch
        err = lasterror;
        h = errordlg(err.message,'Load picture error');
        set(h,'WindowStyle','modal');
    end

%=================================================================

function setcontextmenu(handle)
    newContextMenu = uicontextmenu;
    uimenu(newContextMenu,...
            'Label','Cut',...
            'Callback',@cut,...
            'Accelerator','A');
    uimenu(newContextMenu,...
            'Label','Copy',...
            'Callback',@copy);
    hTurnOver = uimenu(newContextMenu,...
        'Label','Turn over',...
        'Separator','on');
    if ~strcmp(get(handle,'Type'),'rectangle')
        uimenu(hTurnOver,...
            'Label','Horizontally',...
            'Callback',{@turnover,'horiz'});
        uimenu(hTurnOver,...
            'Label','Vertically',...
            'Callback',{@turnover,'vert'});
    end
        uimenu(hTurnOver,...
            'Label','To left',...
            'Callback',{@turnover,'left'});
        uimenu(hTurnOver,...
            'Label','To right',...
            'Callback',{@turnover,'right'});        
    hSequence = uimenu(newContextMenu,...
        'Label','Sequence');
        uimenu(hSequence,...
            'Label','Move to the top',...
            'Callback',{@changesequence,handle,'top'});
        uimenu(hSequence,...
            'Label','Move above',...
            'Callback',{@changesequence,handle,'above'});
        uimenu(hSequence,...
            'Label','Move below',...
            'Callback',{@changesequence,handle,'below'});
        uimenu(hSequence,...
            'Label','Move to the bottom',...
            'Callback',{@changesequence,handle,'bottom'});
    uimenu(newContextMenu,...
        'Label','Delete',...
        'Callback',{@deleteobject,handle},...
        'Separator','on');
    set(handle,'UIContextMenu',newContextMenu);

%=================================================================

function deleteobject(hMenu,eventData,hObject)
    delete(hObject);

%=================================================================

function setenabledrawbar(hObject)
    f = get(findobj('Tag','createnewnodeframe'),'UserData');
    set(f.handles(f.forall(1):f.forall(2)),'enable','on');
    switch lower(get(hObject,'Type'))
        case 'rectangle'
            set(f.handles,'enable','on');
        case 'patch'
            set(f.handles( f.forpatch(1):f.forpatch(2)),'enable','on');
            set(f.handles((f.forpatch(2)+1):(f.forimage(1)-1)),'enable','off');
            set(f.handles( f.forimage(1):f.forimage(2)),'enable','on');
        case 'image'
            set(f.handles(f.forrectangle(1):f.forrectangle(2)),'enable','off');
            set(f.handles(f.forimage(1):f.forimage(2)),'enable','on');            
        otherwise
            set(f.handles(f.forrectangle(1):end),'enable','off');
    end

%=================================================================    

function drawingtype(hObject,eventData)
    switch(get(hObject,'Tag'))
        case('toolbar_Arrow')
            set(findobj('Tag','toolbar_DrawRectangle'),'State','off');
            set(findobj('Tag','toolbar_DrawPatch'),'State','off');
            set(findobj('Tag','toolbar_DeleteMode'),'State','off');
            if strcmp(get(hObject,'State'),'on')
                set(get(gca,'children'),'ButtondownFcn',@buttondownoverobject);
            else
                set(get(gca,'children'),'ButtondownFcn','');
            end
        case('toolbar_DrawRectangle')
            set(findobj('Tag','toolbar_Arrow'),'State','off');
            set(findobj('Tag','toolbar_DrawPatch'),'State','off');
            set(findobj('Tag','toolbar_DeleteMode'),'State','off');
        case('toolbar_DrawPatch')
            set(findobj('Tag','toolbar_Arrow'),'State','off');
            set(findobj('Tag','toolbar_DrawRectangle'),'State','off');
            set(findobj('Tag','toolbar_DeleteMode'),'State','off');
        case('toolbar_DeleteMode')
            set(findobj('Tag','toolbar_Arrow'),'State','off');
            set(findobj('Tag','toolbar_DrawRectangle'),'State','off');
            set(findobj('Tag','toolbar_DrawPatch'),'State','off');
        otherwise
            set(findobj('Tag','toolbar_DrawRectangle'),'State','off');
            set(findobj('Tag','toolbar_DrawPatch'),'State','off');
            set(findobj('Tag','toolbar_DeleteMode'),'State','off');
            openpicture(hObject,eventData);
    end

%=================================================================    

function keypress(hFigure,eventData)
    currentCharacter = get(hFigure,'CurrentCharacter');
%    assignin('base','key',currentCharacter);
%    if isempty(eventData) || isempty(eventData.Modifier)
        switch currentCharacter
            case ''  % Delete (Delete)
                structAxes = get(gca,'UserData');
                delete(structAxes.selected);
                delete(findobj('Type','line','Tag','patchline'));
                resaveproportions;
            case ''    % Cut (Ctrl + x)
                cut(hFigure,eventData);
            case ''    % Copy (Ctrl + c)
                copy(hFigure,eventData);
            case ''    % Paste (Ctrl + v)
                paste(hFigure,eventData);
            case ''    % Undo (Ctrl + z)
                undo(hFigure,eventData);
            case ''    % Redo (Ctrl + y)                
                redo(hFigure,eventData);
            case ''  % New (Ctrl + n)
                newpicture(hFigure,eventData);
            case ''  % Open (Ctrl + o)
                openexisting(hFigure,eventData);
            case ''  % Save (Ctrl + s)
                exporttofile(hFigure,eventData);
            case ''  % From library (Ctrl + f)
                importfromlibrary(hFigure,eventData);
            case ''  % To library (Ctrl + t)
                importtolibrary(hFigure,eventData);
            case ''  % Tool Arrow (Ctrl + a)
                hButton = findobj('Tag','toolbar_Arrow');
                setonofftogglebutton(hButton);
                drawingtype(hButton,eventData);                                
            case ''  % Rectangle (Ctrl + r)
                hButton = findobj('Tag','toolbar_DrawRectangle');
                setonofftogglebutton(hButton);
                drawingtype(hButton,eventData);                
            case ''  % Patch (Ctrl + p)
                hButton = findobj('Tag','toolbar_DrawPatch');
                setonofftogglebutton(hButton);
                drawingtype(hButton,eventData);                
            case '	'  % Image (Ctrl + i)
                hButton = findobj('Tag','toolbar_DrawPicture');
                drawingtype(hButton,eventData);
            case ''  % Delete Mode (Ctrl + d)
                hButton = findobj('Tag','toolbar_DeleteMode');
                setonofftogglebutton(hButton);
                drawingtype(hButton,eventData);                
            otherwise
        end
%    end

%=================================================================    
%=================================================================         
%=================================================================            
%=================================================================    

function setonofftogglebutton(hButton)
    if strcmp(get(hButton,'State'),'on')
        set(hButton,'State','off');
    else
        set(hButton,'State','on');
    end
           
%=================================================================    

function resize(hFigure,eventData,drawbarWidth)
    setpositiondrawbar(hFigure,drawbarWidth);
    setpositionsliders(hFigure,drawbarWidth);
    setpositionaxes(hFigure,drawbarWidth);
    slidersenable;
    
%=================================================================    

function setzoom(hObject,eventData)
    cellOfValues = get(hObject,'String');
    str = cellOfValues{get(hObject,'Value')};
    userData = get(gca,'UserData');
    userData.zoom = str2double(str(1:(end-1)))/100;
    set(gca,'UserData',userData);
    setlim;
    slidersenable;
%    settick;

%=================================================================  

function setbuttoncolor(hObject,color)
    set(hObject,'Backgroundcolor',color);
    set(hObject,'CData',getcdataforbutton(color,get(hObject,'Position')));

%=================================================================  

function cdata = getcdataforbutton(color,position)
    height = round(position(4))-4;
    width = round(position(3))-4;
    cdata(:,:,1) = repmat(color(1),height,width);
    cdata(:,:,2) = repmat(color(2),height,width);    
    cdata(:,:,3) = repmat(color(3),height,width); 

%=================================================================    

function quitcreatenewnode(hFigure,eventData)
    name = get(hFigure,'Name');
    if name(end) == '*' && ~isempty(get(gca,'Children'))
		button = questdlg('Do you want to save changes?',...
    		'Continue Operation','Yes','No','Cancel','Yes');
        if strcmp(button,'Cancel')
           return;
        elseif strcmp(button,'Yes')
            if ~exporttofile(hFigure,eventData);
                return;
            end
        end
    end
    set(get(gca,'Children'),'DeleteFcn','');
    delete(hFigure);
    set(findobj('Tag','uimenu_genodedesigner'),'Checked','off');
    set(findobj('Tag','toolbar_genodedesigner'),'State','off');
    grapheditData = get(findobj('Tag','graphedit'),'UserData');
    grapheditData.hnodedesigner = [];
    set(findobj('Tag','graphedit'),'UserData',grapheditData);

%=================================================================         
    
function createfcnfigure(hFigure,eventData,drawbarWidth,grid)
    closeallotherfigures(hFigure);
    createtoolbar(hFigure);
    createsliders(hFigure,drawbarWidth);
    createaxes(hFigure,drawbarWidth,grid);
    createdrawbar(hFigure,drawbarWidth,grid);

    hMenu = findobj('Tag','uimenu_genodedesigner');
    hToolbar = findobj('Tag','toolbar_genodedesigner');
    set(hMenu,'Checked','on');
    set(hToolbar,'State','on');


%=================================================================    

function closeallotherfigures(hFigure)
    figures = findobj('Tag','createnewnodefigure');
    figures(figures == hFigure) = [];
    if ~isempty(figures)
    	close(figures);
    end

%=================================================================    

function hFigure = createfigure(proportions,drawbarWidth,grid,library)
    monitor = get(0,'ScreenSize');
    window = [monitor(3)/2-proportions(1)/2,...
              monitor(4)/2-proportions(2)/2,...
              proportions(1),...
              proportions(2)];
    hFigure = figure(...
        'Tag','createnewnodefigure',...
        'Units','Pixels',...
        'Name','Node Designer',...
        'NumberTitle','off',...
        'Menubar','none',...
        'Toolbar','none',...
        'Position',window,...
        'DoubleBuffer','on',...  'Renderer','OpenGL',...
        'HandleVisibility','callback',... 
        'CreateFcn',{@createfcnfigure,drawbarWidth,grid},... 
        'CloseRequestFcn',@quitcreatenewnode,...        
        'ResizeFcn',{@resize,drawbarWidth},...
        'KeyPressFcn',@keypress,...
        'UserData',struct(...
            'library',library,...
            'opened',[],...
            'undo',[],...
            'redo',[],...
            'box',[]));

%=================================================================         
        
function sliderchanged(hSlider,eventData,type)
    value = get(hSlider,'Value');
    valueOld = get(hSlider,'UserData');
    set(hSlider,'UserData',value);
    set(gca,[type 'Lim'],get(gca,[type 'Lim']) + (value-valueOld));
%    setlim;
    settick;
    
%================================================================= 

function slidersenable
    hAxes = findobj('Tag','createnewnodeaxes');
    structAxes = get(hAxes,'UserData');
    setsliderparams('x',max(abs(structAxes.childrenx)));
 %   setsliderparams('y',max(abs(structAxes.childreny)));
    
%=================================================================

function setsliderparams(type,extrem)
%     hSlider = findobj('Tag',['createnewnodeviewslider' type]);
%     value = get(hSlider,'Value');
% % disp('------')
% % extrem    
%     lim = get(gca,[type 'Lim']);
%     if -extrem < lim(1) || extrem > lim(2)
%         newMin = -extrem - lim(1) - 20;
%     else
%         newMin = -1000;
%     end
%     newMax = -newMin;
%     if value > newMax || value < newMin
%         if value > newMax
%             newValue = newMax;
%         else
%             newValue = newMin;
%         end
%         set(hSlider,'Value',newValue,'UserData',value);
%         sliderchanged(hSlider,[],type);
%     end
%     
%     set(hSlider,'Min',newMin,'Max',newMax);
    
    
%=================================================================

function setpositionsliders(hFigure,drawbarWidth)
    position = get(hFigure,'position'); 
    positionHoriz = [drawbarWidth + 1,...
                1,...
                position(3) - drawbarWidth - 14,...
                15 ];
    positionVert = [position(3) - 14,...
                15,...
                15,...
                position(4) - 15 ]; 
    positionButton = [positionVert(1),...
                positionHoriz(2),...
                positionVert(3),...
                positionHoriz(4)];
                  
    positionVert(positionVert <= 0) = 1;
    positionHoriz(positionHoriz <= 0) = 1;
    positionButton(positionButton <= 0) = 1;
    
    set(findobj('Tag','createnewnodeviewslidery'),'Position',positionVert);
    set(findobj('Tag','createnewnodeviewsliderx'),'Position',positionHoriz);
    set(findobj('Tag','createnewnodeviewsliderbutton'),'Position',positionButton);
%    slidersenable;

%================================================================= 

function sliderstocenter(hButton,evnetData)
    hSliderY = findobj('Tag','createnewnodeviewslidery');
    set(hSliderY,'Value',0);
    sliderchanged(hSliderY,[],'y');
    hSliderX = findobj('Tag','createnewnodeviewsliderx');
    set(hSliderX,'Value',0);
    sliderchanged(hSliderX,[],'x');
    
%================================================================= 

function createsliders(hFigure,drawbarWidth)
    max = 1000;
    uicontrol(...
        'Tag','createnewnodeviewslidery',...
        'Style','slider',...
        'Callback',{@sliderchanged,'y'},...        'SliderStep',[10/max 100000/max],...
        'Max',max,...
        'Min',-max,... 
        'SliderStep',[0.1 1000],...
        'Value',0,...
        'UserData',0);
    uicontrol(...
        'Tag','createnewnodeviewsliderx',...
        'Style','slider',...
        'Callback',{@sliderchanged,'x'},...        'SliderStep',[10/max 100000/max],...
        'Max',max,...
        'Min',-max,...
        'SliderStep',[0.1 1000],...
        'Value',0,...
        'UserData',0);
    uicontrol(...
        'Tag','createnewnodeviewsliderbutton',...
        'Style','pushbutton',...
        'Callback',@sliderstocenter);

    setpositionsliders(hFigure,drawbarWidth);
    
%=================================================================    
    
function setpositionaxes(hFigure,drawbarWidth)
    position = get(hFigure,'position');
    position = [drawbarWidth + 1,...
                16,...
                position(3) - drawbarWidth - 14,...
                position(4) - 15];      
    position(position <= 0) = 1;
    set(findobj('Tag','createnewnodeaxes'),'Position',position);
    setlim;
%    settick;
        
%=================================================================    

function hAxes = createaxes(hFigure,drawbarWidth,grid)
    hAxes = axes(...
        'Tag','createnewnodeaxes',...
        'Units','Pixels',...
        'SelectionHighlight','off',...        'Drawmode','fast',...
        'Color','white',...
        'Box','on',...        'Position',position,...        'XLim',[0 position(3)],...        'YLim',[0 position(4)],...
        'XColor',[0.8 0.8 0.8],...
        'YColor',[0.8 0.8 0.8],...
        'TickLength',[0.008 0.005],...        'XTick',0:grid(1):position(3),...        'YTick',0:grid(2):position(4),...
        'ButtonDownFcn',@buttondownoveraxes,...
        'UserData',struct(...
            'gridx',grid(1),...
            'gridy',grid(2),...
            'zoom',1,...
            'selected',[],...
            'childrenx',[-1 1],...
            'childreny',[-1 1])...
         );
    hold on;
    
    newContextMenu = uicontextmenu;
	uimenu(newContextMenu,...
        'Label','Paste',...
        'Callback',@paste);
    uimenu(newContextMenu,...
        'Label','Select all',...
        'Callback',@selectall,...
        'Separator','on');
    set(hAxes,'UIContextMenu',newContextMenu);
    
    setpositionaxes(hFigure,drawbarWidth); 
    
%=================================================================    

function setpositiondrawbar(hFigure,width)
    position = get(hFigure,'position');
    hFrame = findobj('Tag','createnewnodeframe');
    vertPos = position(4) - 20;
    userData = get(hFrame,'UserData');
    handles = userData.handles;
    position(position < 1) = 1;
    
    set(hFrame,     'position',[1  1   width position(4)]);
    
    set(handles( 1),'position',[5      vertPos     100  15]);
    set(handles( 2),'position',[5      vertPos-17  100  15]);

    set(handles( 3),'position',[5      vertPos-42   50  15]);
    set(handles( 4),'position',[5+50   vertPos-42   50  18]);
    set(handles( 5),'position',[5      vertPos-62   50  15]);
    set(handles( 6),'position',[5+50   vertPos-62   50  18]); 
    
    set(handles( 7),'position',[5      vertPos-82   50  15]);
    set(handles( 8),'position',[5+50   vertPos-82   50  18]);

    set(handles( 9),'position',[5      vertPos-112  50  15]);
    set(handles(10),'position',[5+50   vertPos-111  50  17]);
    set(handles(11),'position',[5      vertPos-131  50  15]);
    set(handles(12),'position',[5+50   vertPos-130  50  17]);
    
    set(handles(13),'position',[5      vertPos-158  60  15]);
    set(handles(14),'position',[5+60   vertPos-157  40  18]);
    set(handles(15),'position',[5      vertPos-178  60  15]);
    set(handles(16),'position',[5+60   vertPos-177  40  18]);
    set(handles(17),'position',[5      vertPos-198  60  15]);
    set(handles(18),'position',[5+60   vertPos-197  40  18]);

    set(handles(19),'position',[5      vertPos-227  40  15]);
    set(handles(20),'position',[5+40   vertPos-226  40  18]);
    set(handles(21),'position',[5+82   vertPos-227  18  17]);
    set(handles(22),'position',[5      vertPos-247  40  15]);
    set(handles(23),'position',[5+40   vertPos-246  40  18]);
    set(handles(24),'position',[5+82   vertPos-247  18  17]);
    set(handles(25),'position',[5+82   vertPos-247  18  37]);
    set(handles(26),'position',[5      vertPos-268 100  15]);
    
%=================================================================    
    
function createdrawbar(hFigure,drawbarWidth,grid)
    handles = [];
    
    hFrame = uicontrol(...
        'Tag','createnewnodeframe',...
        'Style','frame',...
        'BackgroundColor',[.8 .8 .8]);
    
    handles(end+1) = uicontrol(...
        'Tag','createnewnodeviewgrid',...
        'Style','checkbox',...
        'String','View grid',...
        'Callback',@viewgrid,...
        'BackgroundColor',[.8 .8 .8],...
        'value',0);
    handles(end+1) = uicontrol(...
        'Tag','createnewnodeatachtogrid',...
        'Style','checkbox',...
        'String','Attach to grid',...
        'BackgroundColor',[.8 .8 .8],...
        'value',0);

    
    handles(end+1) = uicontrol(...
        'Style','text',...
        'String','Grid x:',...
        'BackgroundColor',[.8 .8 .8],...
        'HorizontalAlignment','left');
    handles(end+1) = uicontrol(...
        'Tag','createnewnodegridx',...
        'Style','edit',...
        'String',grid(1),...
        'Callback',@setgridtick);
    
    handles(end+1) = uicontrol(...
        'Style','text',...
        'String','Grid y:',...
        'BackgroundColor',[.8 .8 .8],...
        'HorizontalAlignment','left');
    handles(end+1) = uicontrol(...
        'Tag','createnewnodegridy',...
        'Style','edit',...
        'String',grid(2),...
        'Callback',@setgridtick);
    
    
    handles(end+1) = uicontrol(...
        'Style','text',...
        'HorizontalAlignment','left',...
        'String','Zoom:',...
        'BackgroundColor',[.8 .8 .8]);
    handles(end+1) = uicontrol(...
        'Tag','createnewnodezoom',...
        'Style','popupmenu',...
        'String',{'500%' '300%' '200%' '150%' '125%' '100%' '80%' '65%' '50%' '25%' '10%'},...
        'Value',6,...
        'Callback',@setzoom);
    
    
    handles(end+1) = uicontrol(...
        'Style','text',...
        'HorizontalAlignment','left',...
        'String','Face:',...
        'BackgroundColor',[.8 .8 .8]);
    handles(end+1) = uicontrol(...
        'Tag','createnewnodeface',...
        'Style','pushbutton',...
        'Callback',{@dialogcolor,'FaceColor'});
    setbuttoncolor(handles(end),[1 1 1]);
    
    handles(end+1) = uicontrol(...
        'Style','text',...
        'HorizontalAlignment','left',...
        'String','Line:',...
        'BackgroundColor',[.8 .8 .8]);
    handles(end+1) = uicontrol(...
        'Tag','createnewnodeline',...
        'Style','pushbutton',...
        'Callback',{@dialogcolor,'EdgeColor'});
    setbuttoncolor(handles(end),[0 0 0]);
    
    
    handles(end+1) = uicontrol(...
        'Style','text',...
        'HorizontalAlignment','left',...
        'String','Line width:',...
        'BackgroundColor',[.8 .8 .8]);
    handles(end+1) = uicontrol(...
        'Tag','createnewnodelinewidth',...
        'Style','popupmenu',...
        'String',1:1:10,...
        'Callback',@setlinewidth);
    
    handles(end+1) = uicontrol(...
        'Style','text',...
        'HorizontalAlignment','left',...        
        'String','Line style:',...
        'BackgroundColor',[.8 .8 .8]);
    handles(end+1) = uicontrol(...
        'Tag','createnewnodelinestyle',...
        'Style','popupmenu',...
        'String',{'-', '--', ':', '-.', 'none'},...
        'Callback',@setlinestyle);

    
    handles(end+1) = uicontrol(...
        'Style','text',...
        'HorizontalAlignment','left',...
        'String','Curvature:',...
        'BackgroundColor',[.8 .8 .8]);
    handles(end+1) = uicontrol(...
        'Tag','createnewnodecurvature',...
        'Style','popupmenu',...
        'String',0:0.1:1,...
        'Callback',@setcurvature);
    
    handles(end+1) = uicontrol(...
        'Style','text',...
        'HorizontalAlignment','left',...
        'String','Size x:',...
        'BackgroundColor',[.8 .8 .8]);
    handles(end+1) = uicontrol(...
        'Tag','createnewnodesizepoupx',...
        'Style','popupmenu',...
        'String',{'+20' '+10' '+5' '+2' '+1' ' 0' '-1' '-2' '-5' '-10' '-20'},...
        'Value',6);
    handles(end+1) = uicontrol(...
        'Tag','createnewnodesizebuttonx',...
        'Style','pushbutton',...
        'Callback',{@changesize,{'x'}},...
        'Visible','off');
    
    handles(end+1) = uicontrol(...
        'Style','text',...
        'HorizontalAlignment','left',...
        'String','Size y:',...
        'BackgroundColor',[.8 .8 .8]);
    handles(end+1) = uicontrol(...
        'Tag','createnewnodesizepoupy',...
        'Style','popupmenu',...
        'String',{'+20' '+10' '+5' '+2' '+1' ' 0' '-1' '-2' '-5' '-10' '-20'},...
        'Value',6);
    handles(end+1) = uicontrol(...
        'Tag','createnewnodesizebuttony',...
        'Style','pushbutton',...
        'Callback',{@changesize,{'y'}},...
        'Visible','off');
    
    handles(end+1) = uicontrol(...
        'Tag','createnewnodesizebuttonxy',...
        'Style','pushbutton',...
        'Callback',{@changesize,{'x','y'}});
    handles(end+1) = uicontrol(...
        'Tag','createnewnodelockresize',...
        'Style','checkbox',...
        'String','Lock together',...
        'Callback',@changebuttonforsize,...
        'BackgroundColor',[.8 .8 .8],...
        'value',1);
    
    set(hFrame,'UserData',struct('handles',handles,...
                                 'forall',[1 8],...
                                 'forrectangle',[9 18],...
                                 'forpatch',[9 16],...
                                 'forimage',[19 26]));
    setenabledrawbar(hFigure);
    setpositiondrawbar(hFigure,drawbarWidth);
    
%=================================================================   

function setmainobject(hObject,eventData)
    structAxes = get(gca,'UserData');
    if ~isempty(structAxes.selected)
        set(hObject,'UserData',structAxes.selected(end));
    end
    
%================================================================= 

function createtoolbar(hFigure)
    hToolbar = uitoolbar(hFigure);
    uipushtool(hToolbar,...
        'TooltipString','New picture (Ctrl+n)',...        
        'ClickedCallback',@newpicture,...
        'CData',getcdata('private/grapheditnew.png'));
    uipushtool(hToolbar,...
        'TooltipString','Open picture (Ctrl+o)',...
        'ClickedCallback',@openexisting,...
        'CData',getcdata('private/grapheditopen.png'));
    uipushtool(hToolbar,...
        'TooltipString','Import picture from file',...
        'ClickedCallback',@importfromfile,...
        'CData',getcdata('private/grapheditopen2.png'));
    uipushtool(hToolbar,...
        'TooltipString','Save picture (Ctrl+s)',...
        'ClickedCallback',@exporttofile,...
        'CData',getcdata('private/grapheditsave.png'),...
        'Tag','toolbar_Save');
    uipushtool(hToolbar,...
        'TooltipString','Import from library (Ctrl+f)',...        
        'ClickedCallback',@importfromlibrary,...
        'CData',getcdata('private/grapheditimportlibrary.png'),...
        'Separator','on');
    uipushtool(hToolbar,...
        'TooltipString','Export to library (Ctrl+t)',...
        'ClickedCallback',@exporttolibrary,...
        'CData',getcdata('private/grapheditexportlibrary.png'),...
        'Tag','toolbar_ExportToLibrary');
    uipushtool(hToolbar,...
        'TooltipString','Import from workspace',...        
        'ClickedCallback',@importfromworkspace,...
        'CData',getcdata('private/grapheditimport.png'),...
        'Separator','on');
    uipushtool(hToolbar,...
        'TooltipString','Export to workspace',...
        'ClickedCallback',@exporttoworkspace,...
        'CData',getcdata('private/grapheditexport.png'),...
        'Tag','toolbar_ExportToWorkspace');
    uipushtool(hToolbar,...
        'TooltipString','Cut (Ctrl+x)',...
        'ClickedCallback',@cut,...
        'CData',getcdata('private/grapheditcut.png'),...
        'Tag','toolbar_Cut',...
        'Separator','on');
    uipushtool(hToolbar,...
        'TooltipString','Copy (Ctrl+c)',...
        'ClickedCallback',@copy,...
        'CData',getcdata('private/grapheditcopy.png'),...
        'Tag','toolbar_Copy');
    uipushtool(hToolbar,...
        'TooltipString','Paste (Ctrl+v)',...
        'ClickedCallback',@paste,...
        'CData',getcdata('private/grapheditpaste.png'),...
        'Tag','toolbar_Paste');
    uitoggletool(hToolbar,...
        'TooltipString','Copy format',...
        'ClickedCallback',@copyformat,...
        'CData',getcdata('private/grapheditcopyformat.png'),...
        'Tag','toolbar_CopyFormat');
    uipushtool(hToolbar,...
        'TooltipString','Undo last action (Ctrl+z)',...
        'ClickedCallback',@undo,...
        'CData',getcdata('private/grapheditundo.png'),...
        'Tag','toolbar_Undo',...
        'Enable','off',...
        'Separator','on');
    uipushtool(hToolbar,...
        'TooltipString','Redo action (Ctrl+y)',...
        'ClickedCallback',@redo,...
        'CData',getcdata('private/grapheditredo.png'),...
        'Tag','toolbar_Redo',...
        'Enable','off');
    uitoggletool(hToolbar,...
        'TooltipString','Tool arrow (Ctrl+a)',...
        'ClickedCallback',@drawingtype,...
        'CData',getcdata('private/grapheditarrow.png'),...
        'Tag','toolbar_Arrow',...
        'Separator','on');
    uitoggletool(hToolbar,...
        'TooltipString','Draw rectangle (Ctrl+r)',...
        'ClickedCallback',@drawingtype,...
        'CData',getcdata('private/grapheditrectangle.png'),...
        'Tag','toolbar_DrawRectangle',...
        'Separator','on');
    uitoggletool(hToolbar,...
        'TooltipString','Draw patch (Ctrl+p)',...
        'ClickedCallback',@drawingtype,...
        'CData',getcdata('private/grapheditpatch.png'),...
        'Tag','toolbar_DrawPatch');
    uipushtool(hToolbar,...
        'TooltipString','Insert picture (Ctrl+i)',...
        'ClickedCallback',@drawingtype,...
        'CData',getcdata('private/grapheditpicture.png'),...
        'Tag','toolbar_DrawPicture');
    uitoggletool(hToolbar,...
        'TooltipString','Delete Mode (Ctrl+d)',...
        'ClickedCallback',@drawingtype,...
        'CData',getcdata('private/graphedittrash.png'),...
        'Tag','toolbar_DeleteMode',...
        'Separator','on');
    
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


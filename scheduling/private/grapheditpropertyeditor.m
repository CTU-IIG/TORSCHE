function hPropertyEditor = grapheditpropertyeditor(hObject)
%GRAPHEDITPROPERTYEDITOR creates property editor in Graphedit's figure. 
%
%  See also GRAPHEDIT, NODE, EDGE, GRAPH.


% Author: Vojtech Navratil <navrav1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2940 $  $Date:: 2009-05-12 13:28:08 +0200 #$


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


    hPropertyEditor = [];
    switch get(hObject,'Type'),
        case 'figure' % if Graphedti window
            hPropertyEditor = createfigure(hObject);
            hObject = get(hObject,'CurrentAxes');
            type = 'graph';
        case 'axes' % if canvas
            type = 'graph';
        case 'line' % if edge
            type = 'edge';
        case {'rectangle','patch','image'} % if node
            type = 'node';
        otherwise
    end
    
    if isempty(hPropertyEditor),
        hPropertyEditor = findobj('Tag','grapheditpropertyeditor');
    end
    
    if ~isempty(hPropertyEditor) && ishandle(hPropertyEditor),
        loaddatafromobject(hPropertyEditor,hObject,type);
        
        figureData = get(hPropertyEditor,'UserData');
        figureData.hselected = hObject;
        set(hPropertyEditor,'UserData',figureData);

        frameData = get(figureData.hframe,'UserData');
        frameData.selected = type;
        set(figureData.hframe,'UserData',frameData);

        resetpropertiesposition(figureData.hframe,figureData.hslider,15,90);
        resetpropertiesvisibility(type,figureData.hframe,figureData.hslider);
        
    end    

%=================================================================        
%=================================================================        
%=================================================================        

function hFigure = createfigure(hGraphedit)
    grapheditData = get(hGraphedit,'UserData');
    width = grapheditData.configuration.propertyeditorwidth;
    heights.fontsize = grapheditData.configuration.propertyeditorfontsize;
    heights.axes = grapheditData.configuration.propertyeditoraxesheight;
    heights.properties = grapheditData.configuration.propertyeditorpropertiesheight;
    
    monitor = get(0,'ScreenSize');
    grapheditPos = get(hGraphedit,'Position');
    if (grapheditPos(1)+grapheditPos(3)+width) < monitor(3)
        window = [grapheditPos(1)+grapheditPos(3)+8 grapheditPos(2) width grapheditPos(4)+48];
    else
        window = [monitor(3)-width grapheditPos(2) width grapheditPos(4)+20];
    end

    hFigure = figure(...
        'Tag','grapheditpropertyeditor',...
        'Units','Pixels',...
        'Name','Property Editor',...
        'NumberTitle','off',...
        'Menubar','none',...
        'Toolbar','none',...
        'Position',window,...        
        'DoubleBuffer','on',...  'Renderer','OpenGL',...
        'HandleVisibility','callback',...
        'CreateFcn',{@createpartsofpropertyeditor,grapheditData.configuration},...
        'CloseRequestFcn',@closepropertyeditor,...
        'ResizeFcn',{@doresize,heights},...
        'UserData',struct('hobject',[],...
                          'haxes',[],...
                          'hlabel',[],...
                          'hslider',[],...
                          'hframe',[],...
                          'hselected',[],...
                          'type','graph'));
    doresize(hFigure,[],heights);
    
    
%=================================================================      

function doresize(hFigure,eventData,heights)
    posFigure = get(hFigure,'Position');
    figureData = get(hFigure,'UserData');
    
    sliderWidth = 15;
    posLabel = [0 posFigure(4)-2*heights.fontsize posFigure(3)+2 1.7*heights.fontsize];
    propertiesHeight = heights.properties*posLabel(2);
    axesHeight = heights.axes*posLabel(2);
    if axesHeight == 0, axesHeight = 0.01; end
    tableHeight = posLabel(2) - propertiesHeight - axesHeight;
    posFrame = [1 axesHeight+tableHeight posFigure(3) propertiesHeight];
    
    set(figureData.hlabel,'Position',posLabel);
    set(figureData.hframe,'Position',posFrame);
    set(figureData.hslider,'Position',[posFrame(3)-sliderWidth+1 posFrame(2)+1 sliderWidth posFrame(4)-2]);
    set(figureData.haxes,'Position',[1 1 posFigure(3) axesHeight]);
    setsliderlimits(figureData.hframe,figureData.hslider);
%     repairbuttonscolor(hFigure);
    resetpropertiesposition(figureData.hframe,figureData.hslider,sliderWidth,90);
    
%=================================================================          
 
function repairbuttonscolor(hFigure)
    hButtons = findobj('Parent',hFigure,'Type','uicontrol','Style','pushbutton');
    for i = 1:length(hButtons),
        if ~isempty(get(hButtons(i),'CData')),
            set(hButtons(i),'CData',...
                getcdataforbutton(get(hButtons(i),'BackgroundColor'),...
                                  get(hButtons(i),'Position')));
        end
    end

%=================================================================

function resetpropertiesposition(hFrame,hSlider,sliderWidth,columnWidth)
    setgraphpropertiesposition(hFrame,sliderWidth,columnWidth);
    setnodepropertiesposition(hFrame,sliderWidth,columnWidth);
    setedgepropertiesposition(hFrame,sliderWidth,columnWidth);
    sliderchanged(hSlider,[],hFrame);

%=================================================================      

function setsliderlimits(hFrame,hSlider)
    frameData = get(hFrame,'UserData');
    hLabels = eval(['frameData.' frameData.selected '.hlabel']);
    pos1 = get(hLabels(1),'Position');
    pos2 = get(hLabels(end),'Position');
    heightAll = pos1(2) + pos1(4) - pos2(2);
    heightOne = fix(heightAll/length(hLabels));
    position = get(hSlider,'Position');
    deltaHeight = (ceil(length(hLabels) - ((position(4)-3)/heightOne)) * (heightOne));
    if deltaHeight == 0, deltaHeight = 10; end
    step = heightOne/deltaHeight;
    if deltaHeight > 0,
        set(hSlider,'Enable','on','Max',deltaHeight,'Min',0,...
            'SliderStep',[step, 5*step],'Value',deltaHeight,'UserData',deltaHeight);
    else
        set(hSlider,'Enable','off');
    end
    
%=================================================================    

function sliderchanged(hSlider,eventData,hFrame)
    value = get(hSlider,'Value');
    delta = round(get(hSlider,'UserData') - value);
    set(hSlider,'UserData',value);
    frameData = get(hFrame,'UserData');
    framePos = get(hFrame,'Position');
    hLabels = eval(['frameData.' frameData.selected '.hlabel']);
    hProperties = eval(['frameData.' frameData.selected '.hproperty']);
    for i = 1:length(hLabels)
        posLabel = get(hLabels(i),'Position');
        posProperty = get(hProperties(i),'Position');
%         posLabel(2) = posLabel(2) + delta;
        posProperty(2) = posProperty(2) + delta;
        posLabel(2) = posProperty(2) - 3;
        if framePos(2) > posProperty(2)-4 || framePos(2)+framePos(4) < posProperty(2)+posProperty(4)+2, %framePos(2) > posLabel(2)-2 || framePos(2)+framePos(4) < posLabel(2)+posLabel(4)+2 ||...
            set(hLabels(i),'Visible','off');
            set(hProperties(i),'Visible','off');
        else
            set(hLabels(i),'Visible','on');
            set(hProperties(i),'Visible','on');
        end
        set(hLabels(i),'Position',posLabel);
        set(hProperties(i),'Position',posProperty);
        handles2 = get(hProperties(i),'UserData');
        for j = 1:length(handles2),
            if ishandle(handles2(j)),
                set(handles2(j),'Visible',get(hProperties(i),'Visible'));
                thisPosition = get(handles2(j),'Position');
                thisPosition(2) = posProperty(2)+(j-1)*thisPosition(4);
                set(handles2(j),'Position',thisPosition);
            end
        end
    end

%=================================================================      

function closepropertyeditor(hFigure,eventData)
    delete(hFigure);
    set(findobj('Tag','uimenu_gepropertyeditor'),'Checked','off');
    set(findobj('Tag','toolbar_gepropertyeditor'),'State','off');
    grapheditData = get(findobj('Tag','graphedit'),'UserData');
    grapheditData.hpropertyeditor = [];
    set(findobj('Tag','graphedit'),'UserData',grapheditData);

    
%=================================================================        

function createpartsofpropertyeditor(hFigure,eventData,configuration)
    [hLabel,hFrame,hSlider,hAxes] = createmainparts(hFigure,configuration);
    createpropertiesforgraph(hFigure,configuration);
    createpropertiesfornode(hFigure,configuration);
    createpropertiesforedge(hFigure,configuration);

    resetpropertiesvisibility(hFigure,hFrame,hSlider);

%=================================================================      

function [hLabel,hFrame,hSlider,hAxes] = createmainparts(hFigure,configuration)
    figureData = get(hFigure,'UserData') ;
    hAxes = axes(...
        'Parent',hFigure,...
        'Units','Pixels',...
        'Box','on',...
        'SelectionHighlight','off',...
        'Drawmode','fast',...
        'Color','white',...
        'XTickLabel',[],...
        'YTickLabel',[],...
        'XColor',[.7 .7 .7],...
        'YColor',[.7 .7 .7],...      
        'TickLength',[0 0],...
        'XTickLabelMode','manual',...
        'YTickLabelMode','manual',...        
        'Tag','pe_textpositionaxes');
%     drawingobject(hAxes,hObject);
    frameData = struct('graph',struct('hlabel',[],'hproperty',[]),...
                       'node',struct('hlabel',[],'hproperty',[]),...
                       'edge',struct('hlabel',[],'hproperty',[]),...
                       'selected','graph');
    hFrame = uicontrol(hFigure,...
        'Tag','pe_mainframe',...
        'Style','frame',...
        'FontUnits','Pixels',...
        'Units','Pixels',...
        'UserData',frameData);
    hLabel = uicontrol(hFigure,...
        'Tag','pe_mainlabel',...
        'Style','text',...
        'HorizontalAlignment','center',...
        'FontUnits','Pixels',...
        'FontWeight','bold',...
        'FontSize',2+configuration.propertyeditorfontsize);
    hSlider = uicontrol(hFigure,...
        'Tag','pe_propertiesslider',...
        'Callback',{@sliderchanged,hFrame},...
        'Max',1000,...
        'Min',0,... 
        'SliderStep',[0.1 100],...
        'Value',0,...
        'Enable','off',...
        'UserData',0,...
        'Style','slider');
    figureData.haxes = hAxes;
    figureData.hframe = hFrame;
    figureData.hlabel = hLabel;
    figureData.hslider = hSlider;
    set(hFigure,'UserData',figureData,...
                'Color',get(figureData.hlabel,'BackgroundColor'));

%=================================================================      
%=================================================================      
%=================================================================      
%=================================================================      





%=================================================================      
%=================================================================      
%=================================================================      
%=================================================================      

function createpropertiesforgraph(hFigure,configuration)
    figureData = get(hFigure,'UserData');
    frameData = get(figureData.hframe,'UserData');
    posFrame = get(figureData.hframe,'Position');
    labelColor = get(figureData.hlabel,'BackgroundColor');
    fontSize = configuration.propertyeditorfontsize;
    
    posPropertyLabel = [posFrame(1)+3, 1, posFrame(3)/2-2, fontSize+11];
    posPropertyEdit = [posFrame(1)+posFrame(3)/2-3, 1, posFrame(3)/2, posPropertyLabel(4)];

    % Name
    frameData.graph.hlabel(end+1) = uicontrol(hFigure,'String','Name','Tag','pe_label_graph','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.graph.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_graph','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setnameproperty_callback);

    % Notes
    frameData.graph.hlabel(end+1) = uicontrol(hFigure,'String','Notes','Tag','pe_label_graph','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.graph.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_graph','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setnoteproperty_callback);

    % UserParam
    frameData.graph.hlabel(end+1) = uicontrol(hFigure,'String','UserParam','Tag','pe_label_graph','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    posPropertyEdit(3) = posPropertyEdit(3) - posPropertyEdit(4) - 1;    
    frameData.graph.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_graph','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setuserparamproperty_callback);
    posButton = [posPropertyEdit(1)+posPropertyEdit(3), posPropertyEdit(2), posPropertyEdit(4), posPropertyEdit(4)/2];    
    propertyData = uicontrol(hFigure,'String','','Tag','pe_edit_graph','Position',posButton,'Style','pushbutton','HorizontalAlignment','left','FontUnits','Pixels','FontSize',fontSize,'TooltipString','Save Data To Workspace','CData',getcdatapicture('private/grapheditrightarrow.png'),'Callback',@savedatatoworkspace_callback,'UserData',frameData.graph.hproperty(end));
    set(frameData.graph.hproperty(end),'UserData',propertyData);
    posButton = [posPropertyEdit(1)+posPropertyEdit(3), posPropertyEdit(2)+posPropertyEdit(4)/2, posPropertyEdit(4), posPropertyEdit(4)/2];
    propertyData(2) = uicontrol(hFigure,'String','','Tag','pe_edit_graph','Position',posButton,'Style','pushbutton','HorizontalAlignment','left','FontUnits','Pixels','FontSize',fontSize,'TooltipString','Load Data From Workspace','CData',getcdatapicture('private/grapheditleftarrow.png'),'Callback',@loaddatafromworkspace_callback,'UserData',frameData.graph.hproperty(end));
    set(frameData.graph.hproperty(end),'UserData',propertyData);

    % DataTypes
    frameData.graph.hlabel(end+1) = uicontrol(hFigure,'String','DataTypes','Tag','pe_label_graph','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.graph.hproperty(end+1) = uicontrol(hFigure,'String','structure','Tag','pe_edit_graph','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','enable','off','FontSize',fontSize);
    frameData.graph.hlabel(end+1)= uicontrol(hFigure,'String','Nodes','Tag','pe_label_graph','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.graph.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_graph','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',{@setdatatypesproperty_callback,'nodes'});
    frameData.graph.hlabel(end+1) = uicontrol(hFigure,'String','Edges','Tag','pe_label_graph','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.graph.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_graph','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',{@setdatatypesproperty_callback,'edges'});    
%     set(frameData.graph.hproperty(end),'UserData',propertyData); %propertyData = [];

    % Color
    frameData.graph.hlabel(end+1) = uicontrol(hFigure,'String','Color','Tag','pe_label_graph','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.graph.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_graph','Position',posPropertyEdit,'Style','pushbutton','HorizontalAlignment','left','FontUnits','Pixels','FontSize',fontSize,'Callback',@setcolorproperty_callback);

    % GridFreq
    frameData.graph.hlabel(end+1) = uicontrol(hFigure,'String','GridFreq','Tag','pe_label_graph','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.graph.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_graph','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setgridfreqproperty_callback);
    
    set(figureData.hframe,'UserData',frameData);
    
%=================================================================      
    
function setgraphpropertiesposition(hFrame,sliderWidth,columnWidth)
    framePos = get(hFrame,'Position');
    framePos(3) = framePos(3) - sliderWidth;
    frameData = get(hFrame,'UserData');

    height = framePos(2) + framePos(4) - 5;
    index = 0;
    
    % Name
    index = index + 1;
    labelPos = get(frameData.graph.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.graph.hlabel(index),'Position',labelPos);
    set(frameData.graph.hproperty(index),'Position',propertyPos);
    
    % Notes
    index = index + 1;
    labelPos = get(frameData.graph.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.graph.hlabel(index),'Position',labelPos);
    set(frameData.graph.hproperty(index),'Position',propertyPos);   
    
    % UserParam
    index = index + 1;
    labelPos = get(frameData.graph.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    propertyPos(3) = propertyPos(3) - propertyPos(4) - 1;
    set(frameData.graph.hlabel(index),'Position',labelPos);
    set(frameData.graph.hproperty(index),'Position',propertyPos);
    propertyData = get(frameData.graph.hproperty(index),'UserData');
    posButton = [propertyPos(1)+propertyPos(3)+1, propertyPos(2), propertyPos(4), propertyPos(4)/2];
    set(propertyData(1),'Position',posButton);
    posButton = [propertyPos(1)+propertyPos(3)+1, propertyPos(2)+propertyPos(4)/2, propertyPos(4), propertyPos(4)/2];
    set(propertyData(2),'Position',posButton);

    % DataTypes
    index = index + 1;
    labelPos = get(frameData.graph.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.graph.hlabel(index),'Position',labelPos);
    set(frameData.graph.hproperty(index),'Position',propertyPos);
%     propertyData = get(frameData.graph.hproperty(index),'UserData');
    index = index + 1;
    labelPos = get(frameData.graph.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    set(frameData.graph.hlabel(index),'Position',[framePos(1)+20, height, framePos(3)/2-2, labelPos(4)]);
    propertyPos(2) = height + 3;
    set(frameData.graph.hproperty(index),'Position',propertyPos);
    index = index + 1;
    labelPos = get(frameData.graph.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    set(frameData.graph.hlabel(index),'Position',[framePos(1)+20, height, framePos(3)/2-2, labelPos(4)]);
    propertyPos(2) = height + 3;
    set(frameData.graph.hproperty(index),'Position',propertyPos);

    % Color
    index = index + 1;
    labelPos = get(frameData.graph.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.graph.hlabel(index),'Position',labelPos);
    set(frameData.graph.hproperty(index),'Position',propertyPos);
    
    % GridFreq
    index = index + 1;
    labelPos = get(frameData.graph.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.graph.hlabel(index),'Position',labelPos);
    set(frameData.graph.hproperty(index),'Position',propertyPos);
    
    
%=================================================================      
%=================================================================      
%=================================================================     

function createpropertiesfornode(hFigure,configuration)
    figureData = get(hFigure,'UserData');
    frameData = get(figureData.hframe,'UserData');
    posFrame = get(figureData.hframe,'Position');
    labelColor = get(figureData.hlabel,'BackgroundColor');
    fontSize = configuration.propertyeditorfontsize;
    
    posPropertyLabel = [posFrame(1)+3, 1, posFrame(3)/2-2, fontSize+11];
    posPropertyEdit = [posFrame(1)+posFrame(3)/2, 1, posFrame(3)/2, posPropertyLabel(4)];

    % Name
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','Name','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setnameproperty_callback);

    % Notes
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','Notes','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setnoteproperty_callback);

    % UserParam
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','UserParam','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    posPropertyEdit(3) = posPropertyEdit(3) - posPropertyEdit(4) - 1;    
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setuserparamproperty_callback);
    posButton = [posPropertyEdit(1)+posPropertyEdit(3), posPropertyEdit(2), posPropertyEdit(4), posPropertyEdit(4)/2];    
    propertyData = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posButton,'Style','pushbutton','HorizontalAlignment','left','FontUnits','Pixels','FontSize',fontSize,'TooltipString','Save Data To Workspace','CData',getcdatapicture('private/grapheditrightarrow.png'),'Callback',@savedatatoworkspace_callback,'UserData',frameData.node.hproperty(end));
    set(frameData.node.hproperty(end),'UserData',propertyData);
    posButton = [posPropertyEdit(1)+posPropertyEdit(3), posPropertyEdit(2)+posPropertyEdit(4)/2, posPropertyEdit(4), posPropertyEdit(4)/2];
    propertyData(2) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posButton,'Style','pushbutton','HorizontalAlignment','left','FontUnits','Pixels','FontSize',fontSize,'TooltipString','Load Data From Workspace','CData',getcdatapicture('private/grapheditleftarrow.png'),'Callback',@loaddatafromworkspace_callback,'UserData',frameData.node.hproperty(end));
    set(frameData.node.hproperty(end),'UserData',propertyData);

%     % Color
%     frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','Color','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
%     frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posPropertyEdit,'Style','pushbutton','HorizontalAlignment','left','FontUnits','Pixels','FontSize',fontSize);
    
    % GraphicParam
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','GraphicParam','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    hPopUp = uicontrol(hFigure,'String',{'a' 'b'},'Tag','pe_edit_node','Position',posPropertyEdit,'Style','popup','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@graphicparamproperty_callback);
    frameData.node.hproperty(end+1) = hPopUp;
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','X','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',{@setxydataproperty_callback,hPopUp,'X'});
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','Y','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',{@setxydataproperty_callback,hPopUp,'Y'});
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','Width','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',{@setwidthheightproperty_callback,hPopUp,'Width'});
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','Height','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',{@setwidthheightproperty_callback,hPopUp,'Height'});
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','Curvature','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','-','Tag','pe_edit_node','Position',posPropertyEdit,'Style','popup','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',{@setcurvatureproperty_callback,hPopUp});
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','FaceColor','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posPropertyEdit,'Style','pushbutton','HorizontalAlignment','left','FontUnits','Pixels','FontSize',fontSize,'Callback',{@setcolorproperty_callback,'FaceColor',hPopUp});
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','LineWidth','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','-','Tag','pe_edit_node','Position',posPropertyEdit,'Style','popup','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',{@setlinewidthproperty_callback,hPopUp});
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','LineStyle','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','-','Tag','pe_edit_node','Position',posPropertyEdit,'Style','popup','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',{@setlinestyleproperty_callback,hPopUp});
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','EdgeColor','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posPropertyEdit,'Style','pushbutton','HorizontalAlignment','left','FontUnits','Pixels','FontSize',fontSize,'Callback',{@setcolorproperty_callback,'EdgeColor',hPopUp});

    % TextParam
    frameData.node.hlabel(end+1) = uicontrol(hFigure,'String','TextParam','Tag','pe_label_node','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.node.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_node','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@settextparamproperty_callback);
    
    set(figureData.hframe,'UserData',frameData);

%=================================================================      

function setnodepropertiesposition(hFrame,sliderWidth,columnWidth)
    framePos = get(hFrame,'Position');
    framePos(3) = framePos(3) - sliderWidth;
%     framePos(2) = framePos(2) + 2;
    frameData = get(hFrame,'UserData');

    height = framePos(2) + framePos(4) - 5;
    index = 0;
    
    % Name
    index = index + 1;
    labelPos = get(frameData.node.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.node.hlabel(index),'Position',labelPos);
    set(frameData.node.hproperty(index),'Position',propertyPos);
    
    % Notes
    index = index + 1;
    labelPos = get(frameData.node.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.node.hlabel(index),'Position',labelPos);
    set(frameData.node.hproperty(index),'Position',propertyPos);   
    
    % UserParam
    index = index + 1;
    labelPos = get(frameData.node.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    propertyPos(3) = propertyPos(3) - propertyPos(4) - 1;
    set(frameData.node.hlabel(index),'Position',labelPos);
    set(frameData.node.hproperty(index),'Position',propertyPos);
    propertyData = get(frameData.node.hproperty(index),'UserData');
    posButton = [propertyPos(1)+propertyPos(3)+1, propertyPos(2), propertyPos(4), propertyPos(4)/2];
    set(propertyData(1),'Position',posButton);
    posButton = [propertyPos(1)+propertyPos(3)+1, propertyPos(2)+propertyPos(4)/2, propertyPos(4), propertyPos(4)/2];
    set(propertyData(2),'Position',posButton);

   
%     % Color
%     index = index + 1;
%     labelPos = get(frameData.node.hlabel(index),'Position');
%     height = height - labelPos(4) - 2;
%     labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
%     propertyPos = [framePos(1)+framePos(3)/2-3, labelPos(2)+3, labelPos(3)+4, labelPos(4)];
%     set(frameData.node.hlabel(index),'Position',labelPos);
%     set(frameData.node.hproperty(index),'Position',propertyPos);
    
    % GraphicParam
    index = index + 1;
    labelPos = get(frameData.node.hlabel(index),'Position');
    height = height - labelPos(4) - 3;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.node.hlabel(index),'Position',labelPos);
    set(frameData.node.hproperty(index),'Position',propertyPos);
    for i = 1:9,
        index = index + 1;
        labelPos = get(frameData.node.hlabel(index),'Position');
        height = height - labelPos(4) - 3;
        labelPos = [framePos(1)+20, height, framePos(3)/2-2, labelPos(4)];
        if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
        propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
        set(frameData.node.hlabel(index),'Position',labelPos);
        propertyPos(2) = height + 3;
        set(frameData.node.hproperty(index),'Position',propertyPos);
    end
    
    % TextParam
    index = index + 1;
    labelPos = get(frameData.node.hlabel(index),'Position');
    height = height - labelPos(4) - 3;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.node.hlabel(index),'Position',labelPos);
    set(frameData.node.hproperty(index),'Position',propertyPos);

    
%=================================================================      
%=================================================================      
%=================================================================      

function createpropertiesforedge(hFigure,configuration)
    figureData = get(hFigure,'UserData');
    frameData = get(figureData.hframe,'UserData');
    posFrame = get(figureData.hframe,'Position');
    labelColor = get(figureData.hlabel,'BackgroundColor');
    fontSize = configuration.propertyeditorfontsize;
    
    posPropertyLabel = [posFrame(1)+3, 1, posFrame(3)/2-2, fontSize+11];
    posPropertyEdit = [posFrame(1)+posFrame(3)/2, 1, posFrame(3)/2, posPropertyLabel(4)];

    % Name
    frameData.edge.hlabel(end+1) = uicontrol(hFigure,'String','Name','Tag','pe_label_edge','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.edge.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_edge','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setnameproperty_callback);

    % Notes
    frameData.edge.hlabel(end+1) = uicontrol(hFigure,'String','Notes','Tag','pe_label_edge','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.edge.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_edge','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setnoteproperty_callback);

    % UserParam
    frameData.edge.hlabel(end+1) = uicontrol(hFigure,'String','UserParam','Tag','pe_label_edge','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    posPropertyEdit(3) = posPropertyEdit(3) - posPropertyEdit(4) - 1;    
    frameData.edge.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_edge','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setuserparamproperty_callback);
    posButton = [posPropertyEdit(1)+posPropertyEdit(3), posPropertyEdit(2), posPropertyEdit(4), posPropertyEdit(4)/2];    
    propertyData = uicontrol(hFigure,'String','','Tag','pe_edit_edge','Position',posButton,'Style','pushbutton','HorizontalAlignment','left','FontUnits','Pixels','FontSize',fontSize,'TooltipString','Save Data To Workspace','CData',getcdatapicture('private/grapheditrightarrow.png'),'Callback',@savedatatoworkspace_callback,'UserData',frameData.edge.hproperty(end));
    set(frameData.edge.hproperty(end),'UserData',propertyData);
    posButton = [posPropertyEdit(1)+posPropertyEdit(3), posPropertyEdit(2)+posPropertyEdit(4)/2, posPropertyEdit(4), posPropertyEdit(4)/2];
    propertyData(2) = uicontrol(hFigure,'String','','Tag','pe_edit_edge','Position',posButton,'Style','pushbutton','HorizontalAlignment','left','FontUnits','Pixels','FontSize',fontSize,'TooltipString','Load Data From Workspace','CData',getcdatapicture('private/grapheditleftarrow.png'),'Callback',@loaddatafromworkspace_callback,'UserData',frameData.edge.hproperty(end));
    set(frameData.edge.hproperty(end),'UserData',propertyData);

    % Color
    frameData.edge.hlabel(end+1) = uicontrol(hFigure,'String','Color','Tag','pe_label_edge','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.edge.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_edge','Position',posPropertyEdit,'Style','pushbutton','HorizontalAlignment','left','FontUnits','Pixels','FontSize',fontSize,'Callback',@setcolorproperty_callback);
    
%     % Position
%     frameData.edge.hlabel(end+1) = uicontrol(hFigure,'String','GraphicParam','Tag','pe_label_edge','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
%     frameData.edge.hproperty(end+1) = uicontrol(hFigure,'String',{'a' 'b'},'Tag','pe_edit_edge','Position',posPropertyEdit,'Style','popup','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize);
% 
    % LineStyle
    frameData.edge.hlabel(end+1) = uicontrol(hFigure,'String','LineStyle','Tag','pe_label_edge','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.edge.hproperty(end+1) = uicontrol(hFigure,'String',{'-'},'Tag','pe_edit_edge','Position',posPropertyEdit,'Style','popup','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setlinestyleproperty_callback);

    % LineWidth
    frameData.edge.hlabel(end+1) = uicontrol(hFigure,'String','LineWidth','Tag','pe_label_edge','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.edge.hproperty(end+1) = uicontrol(hFigure,'String',{'1'},'Tag','pe_edit_edge','Position',posPropertyEdit,'Style','popup','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize,'Callback',@setlinewidthproperty_callback);    
    
    % TextParam
    frameData.edge.hlabel(end+1) = uicontrol(hFigure,'String','TextParam','Tag','pe_label_edge','Position',posPropertyLabel,'Style','text','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor',labelColor,'FontSize',fontSize);
    frameData.edge.hproperty(end+1) = uicontrol(hFigure,'String','','Tag','pe_edit_edge','Position',posPropertyEdit,'Style','edit','HorizontalAlignment','left','FontUnits','Pixels','BackgroundColor','white','FontSize',fontSize);
    
    set(figureData.hframe,'UserData',frameData);

    
%=================================================================      

function setedgepropertiesposition(hFrame,sliderWidth,columnWidth)
    framePos = get(hFrame,'Position');
    framePos(3) = framePos(3) - sliderWidth;
%     framePos(2) = framePos(2) + 2;
    frameData = get(hFrame,'UserData');

    height = framePos(2) + framePos(4) - 5;
    index = 0;
    
    % Name
    index = index + 1;
    labelPos = get(frameData.edge.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.edge.hlabel(index),'Position',labelPos);
    set(frameData.edge.hproperty(index),'Position',propertyPos);
    
    % Notes
    index = index + 1;
    labelPos = get(frameData.edge.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.edge.hlabel(index),'Position',labelPos);
    set(frameData.edge.hproperty(index),'Position',propertyPos);   
    
    % UserParam
    index = index + 1;
    labelPos = get(frameData.edge.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    propertyPos(3) = propertyPos(3) - propertyPos(4) - 1;
    set(frameData.edge.hlabel(index),'Position',labelPos);
    set(frameData.edge.hproperty(index),'Position',propertyPos);
    propertyData = get(frameData.edge.hproperty(index),'UserData');
    posButton = [propertyPos(1)+propertyPos(3)+1, propertyPos(2), propertyPos(4), propertyPos(4)/2];
    set(propertyData(1),'Position',posButton);
    posButton = [propertyPos(1)+propertyPos(3)+1, propertyPos(2)+propertyPos(4)/2, propertyPos(4), propertyPos(4)/2];
    set(propertyData(2),'Position',posButton);

    % Color
    index = index + 1;
    labelPos = get(frameData.edge.hlabel(index),'Position');
    height = height - labelPos(4) - 2;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.edge.hlabel(index),'Position',labelPos);
    set(frameData.edge.hproperty(index),'Position',propertyPos);
      
    % LineStyle
    index = index + 1;
    labelPos = get(frameData.edge.hlabel(index),'Position');
    height = height - labelPos(4) - 3;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.edge.hlabel(index),'Position',labelPos);
    set(frameData.edge.hproperty(index),'Position',propertyPos);

    % LineWidth
    index = index + 1;
    labelPos = get(frameData.edge.hlabel(index),'Position');
    height = height - labelPos(4) - 3;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.edge.hlabel(index),'Position',labelPos);
    set(frameData.edge.hproperty(index),'Position',propertyPos);

    % TextParam
    index = index + 1;
    labelPos = get(frameData.edge.hlabel(index),'Position');
    height = height - labelPos(4) - 3;
    labelPos = [framePos(1)+5, height, framePos(3)/2-2, labelPos(4)];
    if labelPos(3) > columnWidth, labelPos(3) = columnWidth;   end
    propertyPos = [framePos(1)+labelPos(3), labelPos(2)+3, framePos(3)-labelPos(3)-1, labelPos(4)];
    set(frameData.edge.hlabel(index),'Position',labelPos);
    set(frameData.edge.hproperty(index),'Position',propertyPos);


    
%=================================================================      
%=================================================================      
%=================================================================      

function maxLength = maxstring(list)
    maxLength = 0;
    for i = 1:length(list)
        if maxLength < length(list{i}),
            maxLength = length(list{i});
        end
    end

%=================================================================      

function resetpropertiesvisibility(input,hFrame,hSlider)
    if ishandle(input),
%         figureData = get(input,'UserData');
        frameData = get(hFrame,'UserData');
        type = frameData.selected;
    else
        type = input;%    frameData = get(findobj('Tag','grapheditpropertyeditor'),'UserData');
    end
    switch type
        case 'graph'
            set([findobj('Tag','pe_label_node'); findobj('Tag','pe_edit_node')],'Visible','off');
            set([findobj('Tag','pe_label_edge'); findobj('Tag','pe_edit_edge')],'Visible','off');
        case 'node'
            set([findobj('Tag','pe_label_graph'); findobj('Tag','pe_edit_graph')],'Visible','off');
            set([findobj('Tag','pe_label_edge'); findobj('Tag','pe_edit_edge')],'Visible','off');
        case 'edge'
            set([findobj('Tag','pe_label_graph'); findobj('Tag','pe_edit_graph')],'Visible','off');
            set([findobj('Tag','pe_label_node'); findobj('Tag','pe_edit_node')],'Visible','off');
        otherwise
    end
    setsliderlimits(hFrame,hSlider);

%=================================================================      

%=================================================================      
%=================================================================      
%=================================================================      




%=================================================================      
%=================================================================      
%=================================================================      

function loaddatafromobject(hPropEditor,hObject,type)
    figureData = get(hPropEditor,'UserData');
    frameData = get(figureData.hframe,'UserData');
    objectData = get(hObject,'UserData');
    hLabels = eval(['frameData.' type '.hlabel']);
    hProperties = eval(['frameData.' type '.hproperty']);
    for i = 1:length(hLabels),
        property = get(hLabels(i),'String');
        if isfield(objectData.objectparams,property),
            value = eval(['objectData.objectparams.' property]);
        end
        switch lower(property)
            case {'name', 'notes', 'gridfreq', 'textparam'}
                set(hProperties(i),'String',value2str(value));
            case 'userparam'
                if isempty(value), value = {}; end
                set(hProperties(i),'String',value2str(value));
            case 'datatypes'
                if isempty(value.nodes), value.nodes = {}; end
                if isempty(value.edges), value.edges = {}; end
                set(hProperties(i+1),'String',value2str(value.nodes));
                set(hProperties(i+2),'String',value2str(value.edges));
            case 'color'
                if iscolor(value),
                    set(hProperties(i),'BackgroundColor',value,'CData',...
                        getcdataforbutton(value,get(hProperties(i),'Position')));
                else
                    set(hProperties(i),'BackgroundColor',[1 1 1],'CData',...
                        getcdataforbutton([1 1 1],get(hProperties(i),'Position')));
                end
            case 'graphicparam'
                if iscell(value),
                    loadgraphciparam(hLabels(i:i+9),hProperties(i:i+9),value);
                end
            case 'linestyle'
                if ~isfield(objectData.objectparams,'GraphicParam'),
                    strcell = {'-', '--', ':', '-.', 'none'};
                    set(hProperties(i),'String',strcell,'Value',find(strcmp(strcell,value)));
                end
            case 'linewidth'
                if ~isfield(objectData.objectparams,'GraphicParam'),
                    set(hProperties(i),'String',num2charcell(1:1:10),'Value',round(value));
                end
            otherwise
        end
    end
    set(figureData.hlabel,'String',[type ': ' objectData.objectparams.Name]);

%=================================================================      
%=================================================================   
%=================================================================   
%=================================================================   
%=================================================================

function loadgraphciparam(hLabels,hProperties,inputCell)
    set(hProperties(1),'String',num2charcell(1:1:length(inputCell)),'UserData',inputCell,'Value',1);
    changegraphicparams(hLabels,hProperties);
    
%=================================================================   

function changegraphicparams(hLabels,hProperties)
    inputCell = get(hProperties(1),'UserData');
    objectparams = inputCell{get(hProperties(1),'Value')};
    for j = 2:length(hLabels),
        property = lower(get(hLabels(j),'String'));
        set(hProperties(j),'Enable','off');
        if isfield(objectparams,property),
            value = eval(['objectparams.' property]);
            switch lower(property)
                case {'x', 'y', 'width', 'height'}
                    set(hProperties(j),'String',value2str(value),'Enable','on');
                case {'facecolor', 'edgecolor'}
                    if iscolor(value),
                        set(hProperties(j),'BackgroundColor',value,'CData',...
                            getcdataforbutton(value,get(hProperties(j),'Position')),'Enable','on');
                    else
                        set(hProperties(j),'BackgroundColor',[1 1 1],'CData',...
                            getcdataforbutton([1 1 1],get(hProperties(j),'Position')),'Enable','on');
                    end
                case 'curvature'
                    set(hProperties(j),'String',num2charcell(0:0.1:1),'Value',round(value(1)*10)+1,'Enable','on');
                case 'linestyle'
                    strcell = {'-', '--', ':', '-.', 'none'};
                    set(hProperties(j),'String',strcell,'Value',find(strcmp(strcell,value)),'Enable','on');
                case 'linewidth'
                    set(hProperties(j),'String',num2charcell(1:1:10),'Value',round(value),'Enable','on');
                otherwise
            end
        end
    end

%=================================================================   

function str = value2str(value)
    switch class(value)
        case 'char'
            str = value;
        case 'double'
            str = matrix2str(value);
        case 'cell'
            str = cell2str(value);
        case 'struct'
            str = 'structure';
        otherwise
            str = ['Type: ' class(value)];
    end
            
%=================================================================   

function out = matrix2str(in)
    if isempty(in),
        out = '[ ]';
    elseif isequal([1 1],size(in)),
        out = num2str(in);
    else
        out = '[ ';
        for i = 1:size(in,1)
            for j = 1:size(in,2)
                out = [out num2str(in(i,j)) ' '];
            end
            out = [out '; '];
        end
        out = [out(1:(end-3)) ' ]'];
    end
    
%=================================================================   
  
function out = cell2str(in)
    if isempty(in),
        out = '{ }';
    else
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
    end
    
%=================================================================   

function out = num2charcell(in)
    out = cell(size(in));
    for i = 1:length(in(:)),
        out{i} = num2str(in(i));
    end

%=================================================================   
    
function cdata = getcdataforbutton(color,position)
    height = round(position(4))-8;
    width = round(position(3))-8;
    color = color2rgb(color);
    cdata(:,:,1) = repmat(color(1),height,width);
    cdata(:,:,2) = repmat(color(2),height,width);    
    cdata(:,:,3) = repmat(color(3),height,width); 

%=================================================================   

function im = getcdatapicture(pictureName)
%     color = 255*get(0,'factoryUicontrolBackgroundColor');
    im = imread(pictureName);
%     [height,width,colors] = size(im);    
%     for i = 1:height
%         for j = 1:width
%             if (((im(i,j,1) <= 253) && (im(i,j,1) >= 248)) &&...
%                 ((im(i,j,2) <= 46) && (im(i,j,2) >= 38)) &&...
%                 ((im(i,j,3) <= 222) && (im(i,j,3) >= 217)))
%                 im(i,j,:) = color(:);
%             end
%         end
%     end

%=================================================================   
%=================================================================   

%=================================================================   

%=================================================================   
%=================================================================   

function data = evalwithdlg(dataStr,dataOld)
    if isempty(dataStr)
        dataStr = '[]';
    end
    try
        data = eval(dataStr);
    catch
        h = errordlg(...
            sprintf(['Undefined function or variable ''' dataStr '''.\nOriginal data stays unchanged.']),...
            'Error while saving UserParam');
        set(h,'WindowStyle','modal');
        data = dataOld;
        return;
    end

%=================================================================   

function graphicparamproperty_callback(hPopUp,eventData)
    figureData = get(get(hPopUp,'Parent'),'UserData');
    frameData = get(figureData.hframe,'UserData');
    index = find(frameData.node.hproperty == hPopUp);
    changegraphicparams(frameData.node.hlabel(index:index+9),...
                        frameData.node.hproperty(index:index+9));
                    
%=================================================================   

function setnameproperty_callback(hControl,eventData)
    newName = get(hControl,'String');
    figureData = get(get(hControl,'Parent'),'UserData');
    selectedData = get(figureData.hselected,'UserData');
    selectedData.objectparams.Name = newName;
    set(figureData.hselected,'UserData',selectedData);
    switch get(figureData.hselected,'Type'),
        case 'axes' % if canvas
            flagData = get(selectedData.flag,'UserData');
            set(flagData.text,'String',newName);
            type = 'graph';
        case 'line' % if edge
            set(selectedData.hname,'String',newName);
            type = 'edge';
        case {'rectangle','patch','image'} % if node
            set(selectedData.hname,'String',newName);
            type = 'node';
        otherwise
    end
    set(figureData.hlabel,'String',[type ': ' selectedData.objectparams.Name]);

%=================================================================   

function setnoteproperty_callback(hControl,eventData)
    newNote = get(hControl,'String');
    figureData = get(get(hControl,'Parent'),'UserData');
    selectedData = get(figureData.hselected,'UserData');
    selectedData.objectparams.Notes = newNote;
    set(figureData.hselected,'UserData',selectedData);

%=================================================================   

function setuserparamproperty_callback(hControl,eventData)
    newDataStr = get(hControl,'String');
    figureData = get(get(hControl,'Parent'),'UserData');
    selectedData = get(figureData.hselected,'UserData');
    newData = evalwithdlg(newDataStr,selectedData.objectparams.UserParam);
    selectedData.objectparams.UserParam = newData;
    set(figureData.hselected,'UserData',selectedData);
%     if ~isempty(newData),
        switch get(figureData.hselected,'Type'),
            case 'line' % if edge
                set(selectedData.huserparam,'String',newDataStr);
            case {'rectangle','patch','image'} % if node
                set(selectedData.huserparam,'String',newDataStr);
            otherwise
        end
%     end
    
%=================================================================   

function savedatatoworkspace_callback(hButton,eventData)
    figureData = get(findobj('Tag','graphedit'),'UserData');
    variables = struct(evalin('base','whos'));
    listObjs = {variables(:).name};
    [name,isNewName] = grapheditlistdlg(...
        'parentfigure',gcbf,...
        'filename','Workspace',...
        'list1',listObjs,...        'list2',listObjs,...
        'listname','Variables in workspace:',...
        'okstring','Export',...
        'cancelstring','Cancel',...
        'editname','Export to: ',...        
        'checktext','view only graphs',...
        'checkEnable','off',...
        'initialname','x',...
        'queststring','Do you want to replace variable?',...
        'askifreplace',figureData.configuration.askifreplace,...
        'position','leftdown');
    if ~isempty(name),
        figureData = get(get(hButton,'Parent'),'UserData');
        selectedData = get(figureData.hselected,'UserData');
        assignin('base',name,selectedData.objectparams.UserParam);
    else
        return;
    end
    
%=================================================================   

function loaddatafromworkspace_callback(hButton,eventData)
    figureData = get(findobj('Tag','graphedit'),'UserData');
    newData = [];
    variables = struct(evalin('base','whos'));
    if isempty(variables),
        h = errordlg(...
            ['There is no data in the ' 'workspace' '!'],...
            'Variable not found');
        set(h,'WindowStyle','modal');
    else
        listObjs = {variables.name};
        [name,isNewName] = grapheditlistdlg(...
                'parentfigure',gcbf,...
                'filename','Workspace',...
                'list1',listObjs,...
                'listname','Variables in workspace:',...
                'okstring','Import',...
                'cancelstring','Cancel',...
                'editname','Import variable: ',...
                'checktext','view only graphs',...
                'checkenable','off',...
                'editenable','off',...
                'position','leftdown',...
                'askifreplace',figureData.configuration.askifreplace);
        if ~isempty(name),
            newData = evalin('base',name);
        else
            return;
        end
    end
    if ~isempty(newData),
        newDataStr = value2str(newData);
        hProperty = get(hButton,'UserData');
        set(hProperty,'String',newDataStr);
        
        figureData = get(get(hProperty,'Parent'),'UserData');
        selectedData = get(figureData.hselected,'UserData');
        selectedData.objectparams.UserParam = newData;
        set(figureData.hselected,'UserData',selectedData);
        if ~isempty(newData),
            switch get(figureData.hselected,'Type'),
                case 'line' % if edge
                    set(selectedData.huserparam,'String',newDataStr);
                case {'rectangle','patch','image'} % if node
                    set(selectedData.huserparam,'String',newDataStr);
                otherwise
            end
        end
    end

%=================================================================   

function setdatatypesproperty_callback(hControl,eventData,type)
    dataStr = get(hControl,'String');
    figureData = get(get(hControl,'Parent'),'UserData');
    selectedData = get(figureData.hselected,'UserData');
    data = evalwithdlg(dataStr,eval(['selectedData.objectparams.DataTypes.' type]));
    errorrFlag = false;
    if iscell(data),
        for i = 1:length(data),
            if ~isempty(data{i}) && ~isa(eval([data{i} '([])']),data{i}),
                errorrFlag = true;
            end
        end
    else
        errorrFlag = true;
    end
    if errorrFlag,
        h = errordlg(...
            'Invalid ''DataTypes'' definition.',...
            'Error while saving DataTypes');
        set(h,'WindowStyle','modal');
        return;
    else
        eval(['selectedData.objectparams.DataTypes.' type '= data;']);
        set(figureData.hselected,'UserData',selectedData);
    end

%=================================================================   

function setcolorproperty_callback(hControl,eventData,varargin)
    color = uisetcolor(get(hControl,'Backgroundcolor'),'PropEditor - palette');
    if iscolor(color),
        set(hControl,'Backgroundcolor',color,...
                     'CData',getcdataforbutton(color,get(hControl,'Position')));
        figureData = get(get(hControl,'Parent'),'UserData');
        selectedData = get(figureData.hselected,'UserData');
        switch get(figureData.hselected,'Type'),
            case 'axes' % if canvas
                selectedData.objectparams.Color = color;
                set(figureData.hselected,'Color',color);%,'XColor',color,'YColor',color);
                set(selectedData.flag,'FaceColor',color);
                axesBaraData = get(get(selectedData.flag,'Parent'),'UserData');
                set(axesBaraData.linecolor,'Color',color);
            case 'line' % if edge
                selectedData.objectparams.Color = color;
                selectedData.color = color;
                set(figureData.hselected,'Color',color);
                set(selectedData.htips,'Color',color);
            case {'rectangle','patch','image'} % if node
                index = get(varargin{2},'Value');
                eval(['selectedData.objectparams.GraphicParam{index}.' lower(varargin{1}) ' = color;']);
                set(selectedData.allobjects(index),varargin{1},color);
                inputCell = selectedData.objectparams.GraphicParam;
                set(varargin{2},'UserData',inputCell);
                if strcmpi(varargin{1},'edgecolor'),
                    if index == 1,
                        selectedData.edgecolor = color;
                    else
                        selectedDataIndex = get(selectedData.allobjects(index),'UserData');
                        selectedDataIndex.edgecolor = color;
                        set(selectedData.allobjects(index),'UserData',selectedDataIndex);
                    end
                end
            otherwise
        end
        set(figureData.hselected,'UserData',selectedData);
    end

%=================================================================   

function setgridfreqproperty_callback(hControl,eventData)
    dataStr = get(hControl,'String');
    figureData = get(get(hControl,'Parent'),'UserData');
    selectedData = get(figureData.hselected,'UserData');
    data = evalwithdlg(dataStr,selectedData.objectparams.GridFreq);
    
    if ~isa(data,'double') || length(data) ~= 2,
        h = errordlg(...
            'Invalid ''GridFreq'' property value.',...
            'Error while saving GridFreq');
        set(h,'WindowStyle','modal');
        return;
    end
    
    selectedData.objectparams.GridFreq = data;
    set(figureData.hselected,'UserData',selectedData);
    
    set(findobj('Tag','grapheditcreatenewnodegridx'),'String',num2str(data(1)));
    set(findobj('Tag','grapheditcreatenewnodegridy'),'String',num2str(data(2)));
    xLim = get(figureData.hselected,'XLim');
    yLim = get(figureData.hselected,'YLim');
    startX = xLim(1) - mod(xLim(1),data(1));
    startY = yLim(1) - mod(yLim(1),data(2));
    set(figureData.hselected,'XTick',startX:data(1):xLim(2));
    set(figureData.hselected,'YTick',startY:data(2):yLim(2));

%=================================================================   

function setlinestyleproperty_callback(hControl,eventData,varargin)
    value = get(hControl,'Value');
    string = get(hControl,'String');
    figureData = get(get(hControl,'Parent'),'UserData');
    selectedData = get(figureData.hselected,'UserData');
    if nargin == 2,
        selectedData.objectparams.LineStyle = string{value};
        set(figureData.hselected,'UserData',selectedData,'LineStyle',string{value});
    else
        index = get(varargin{1},'Value');
        selectedData.objectparams.GraphicParam{index}.linestyle = string{value};
        set(selectedData.allobjects(index),'LineStyle',string{value});
    end
    set(figureData.hselected,'UserData',selectedData);

%=================================================================   

function setlinewidthproperty_callback(hControl,eventData,varargin)
    string = get(hControl,'String');
    value = str2double(string{get(hControl,'Value')});
    figureData = get(get(hControl,'Parent'),'UserData');
    selectedData = get(figureData.hselected,'UserData');
    if nargin == 2,
        selectedData.objectparams.LineWidth = value;
        selectedData.linewidth = value;
        set(figureData.hselected,'UserData',selectedData,'LineWidth',value);
        set(selectedData.htips,'LineWidth',value);
    else
        index = get(varargin{1},'Value');
        selectedData.objectparams.GraphicParam{index}.linewidth = value;
        set(selectedData.allobjects(index),'LineWidth',value);
        if index == 1,
            selectedData.linewidth = value;
        else
            selectedDataIndex = get(selectedData.allobjects(index),'UserData');
            selectedDataIndex.linewidth = value;
            set(selectedData.allobjects(index),'UserData',selectedDataIndex);
        end
    end
    set(figureData.hselected,'UserData',selectedData);

%=================================================================   

function setxydataproperty_callback(hControl,eventData,hPopUp,type)
%     try
        index = get(hPopUp,'Value');
        data = str2num(get(hControl,'String')); %#ok<ST2NM>
        figureData = get(get(hControl,'Parent'),'UserData');
        selectedData = get(figureData.hselected,'UserData');
        eval(['selectedData.objectparams.GraphicParam{index}.' lower(type) ' = data;']);
        set(figureData.hselected,'UserData',selectedData);
        try
%             set(selectedData.allobjects(index),[type 'data'],data);           
            position = min(data) + (max(data) - min(data))/2;
            if strcmpi(type,'x'),
                yData = get(figureData.hselected,'YData');
                position(2) = min(yData) + (max(yData) - min(yData))/2;
            else
                xData = get(figureData.hselected,'XData');
                position(2) = position(1);
                position(1) = min(xData) + (max(xData) - min(xData))/2;
            end
        catch
            position = get(selectedData.allobjects(index),'position');
            if strcmpi(type,'x'),
                position(1) = data + position(3)/2;
                position(2) = position(2) + position(4)/2;
            else
                position(2) = data + position(4)/2;
                position(1) = position(1) + position(3)/2;
            end
%             set(selectedData.allobjects(index),'position',position);
        end
        graphedit('movenode',{figureData.hselected,position(1),position(2)});
        loaddatafromobject(get(hControl,'Parent'),figureData.hselected,'node');
%     catch
%         h = errordlg(...
%             ['Invalid format of ''' type '''  property value.'],...
%             ['Error while saving ' type]);
%         set(h,'WindowStyle','modal');
%         return;
%     end
    
%=================================================================   

function setwidthheightproperty_callback(hControl,eventData,hPopUp,type)
    try
        index = get(hPopUp,'Value');
        data = str2double(get(hControl,'String'));
        figureData = get(get(hControl,'Parent'),'UserData');
        selectedData = get(figureData.hselected,'UserData');
        eval(['selectedData.objectparams.GraphicParam{index}.' lower(type) ' = data;']);
        set(figureData.hselected,'UserData',selectedData);
        if strcmpi(type,'width'),
            pos = 3;
        else
            pos = 4;
        end
        position = get(selectedData.allobjects(index),'position');
        position(pos) = data;
        set(selectedData.allobjects(index),'position',position);
    catch
        h = errordlg(...
            ['Invalid format of ''' type '''  property value.'],...
            ['Error while saving ' type]);
        set(h,'WindowStyle','modal');
        return;
    end

%=================================================================   

function setcurvatureproperty_callback(hControl,eventData,hPopUp)
    index = get(hPopUp,'Value');
    strChar = get(hControl,'String');
    data = str2double(strChar(get(hControl,'Value')));
    data = [data data];
    figureData = get(get(hControl,'Parent'),'UserData');
    selectedData = get(figureData.hselected,'UserData');
    selectedData.objectparams.GraphicParam{index}.curvature = data;
    set(figureData.hselected,'UserData',selectedData);
    set(selectedData.allobjects(index),'Curvature',data);

%=================================================================   

function settextparamproperty_callback(hControl,eventData)
    data = str2num(get(hControl,'String')); %#ok<ST2NM>
    figureData = get(get(hControl,'Parent'),'UserData');
    selectedData = get(figureData.hselected,'UserData');
    oldData = selectedData.objectparams.TextParam;
    selectedData.objectparams.TextParam = data;
    set(figureData.hselected,'UserData',selectedData);
    
    position = get(selectedData.hname,'Position');
    center = [position(1)+oldData(1,1) position(2)+oldData(1,2)];
    set(selectedData.hname,'Position',[center(1)-data(1,1) center(2)-data(1,2) 0]);
    set(selectedData.huserparam,'Position',[center(1)-data(2,1) center(2)-data(2,2) 0]);
    
%=================================================================   
%=================================================================   
%=================================================================   

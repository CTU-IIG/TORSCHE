function pluginlist = grapheditdialogremoveplugin(pluginlist)
%DIALOG Remove Plugin for Graphedit. 
%   This file is part of Scheduling Toolbox.
%
%   pluginlist - list fo all plugins - type struct
%


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


    hDialog = createdialog(pluginlist);
        
    try
        set(hDialog,'Visible','on');
        uiwait(hDialog);
    catch
        if ishandle(hDialog)
            delete(hDialog);
        end
    end
    
    if isappdata(0,'ListDialogAppData')
        pluginlist = getappdata(0,'ListDialogAppData');
        rmappdata(0,'ListDialogAppData');
    else
        pluginlist = [];
    end

    
%--------------------------------------------------------------------   

function hDialog = createdialog(pluginlist)

    setappdata(0,'ListDialogAppData',pluginlist);
    
    positionDialog = getposition(gcf,214,220);
    halfDialog = positionDialog(3)/2;

    hDialog = dialog('Visible','off','WindowStyle','modal','Name','Remove plugin',...
        'Position',positionDialog);
    
    groups = getgroupsnames;
    
    hList = uicontrol('Parent',hDialog,'Style','listbox','String',getpluginsnames(groups{1}),...
        'Position',[15 36 positionDialog(3)-30 positionDialog(4)-36-36],...
        'TooltipString','Double click for deleting plugin');
    
    uicontrol('Parent',hDialog,'Style','text','String','Group:',...
        'Position',[10 positionDialog(4)-28-2 55 18],'HorizontalAlignment','right',...
        'TooltipString','Select group');
    hGroup = uicontrol('Parent',hDialog,'Style','popupmenu','String',groups,...
        'Position',[70 positionDialog(4)-28 122 20],'Callback',{@groupchanged,hList},...
        'BackgroundColor','white','HorizontalAlignment','left',...
        'TooltipString','Select group');
    set(hList,'Callback',{@dolistclick,hGroup});
    
    uicontrol('Parent',hDialog,'Style','pushbutton','String','OK',...
        'Position',[halfDialog-31-4-62 8 62 22],...
        'Callback',{@dook},'TooltipString','Apply changes');
    uicontrol('Parent',hDialog,'Style','pushbutton','String','Cancel',...
        'Position',[halfDialog-31 8 62 22],...
        'Callback',@docancel,'TooltipString','Cancel changes');
    uicontrol('Parent',hDialog,'Style','pushbutton','String','Delete',...
        'Position',[halfDialog+31+4 8 62 22],...
        'Callback',{@dodelete,hGroup,hList},...
        'TooltipString','Delete selected plugin');
    
%--------------------------------------------------------------------   

function position = getposition(hParent,width,height)
    positionParent = get(hParent,'Position');
    position(3) = width;
    position(4) = height;
    position(1) = positionParent(1) + (positionParent(3) - position(3))/2;
    position(2) = positionParent(2) + (positionParent(4) - position(4))/2;

%--------------------------------------------------------------------   

function groups = getgroupsnames
    pluginlist = getappdata(0,'ListDialogAppData');
    groups = [];
    
    if ~isempty(pluginlist.group)
        for i = 1:length(pluginlist.group)
            groups{i} = pluginlist.group(i).name;
        end
    else
        groups = {'no group'};
    end
    
%--------------------------------------------------------------------   

function plugins = getpluginsnames(group)
    pluginlist = getappdata(0,'ListDialogAppData');
    plugins = {};
    for i = 1:length(pluginlist.group)
        if strcmp(pluginlist.group(i).name,group)
            if ~isempty(pluginlist.group(i).plugin)
                for j = 1:length(pluginlist.group(i).plugin)
                    plugins{j} = pluginlist.group(i).plugin(j).name;
                end
            end
        end
    end
    if ~isempty(pluginlist.group)
        plugins{length(plugins)+1} = '--- Whole group ---';
    end
      
%--------------------------------------------------------------------   

function groupchanged(hObject,eventData,hList)
    pluginlist = getappdata(0,'ListDialogAppData');
    groups = get(hObject,'String');
    if ~isempty(groups)
        value = get(hObject,'Value');
        plugins = getpluginsnames(groups{value});
    else
        plugins = {};
    end
    set(hList,'String',plugins,'Value',1);

%--------------------------------------------------------------------   

function dook(hObject,eventData)
    delete(gcbf);

%--------------------------------------------------------------------   

function docancel(hObject,eventData)
    setappdata(0,'ListDialogAppData',[]);
    delete(gcbf);
    
%--------------------------------------------------------------------   

function dolistclick(hList,eventData,hGroup)
    if ~isempty(get(hList,'String'))
        if strcmp(get(gcbf,'SelectionType'),'open')
            dodelete([],[],hGroup,hList);
        end
    end

%--------------------------------------------------------------------   

function dodelete(hObject,eventData,hGroup,hList)
    pluginlist = getappdata(0,'ListDialogAppData');
    groups = get(hGroup,'String');
    group = groups{get(hGroup,'Value')};
    plugins = get(hList,'String');
    plugin = plugins{get(hList,'Value')};
    newPluginlist.version = pluginlist.version;
    newPluginlist.application = pluginlist.application;
    newPluginlist.group = [];
    value = 1;
    if strcmp(plugin,'--- Whole group ---')
        isDeleted = 0;
        for i = 1:(length(pluginlist.group)-1)
            if strcmp(pluginlist.group(i).name,group)
                isDeleted = 1;
            end
            if (isDeleted == 0)
                if isempty(newPluginlist.group)
                    newPluginlist.group = pluginlist.group(i);
                else
                    newPluginlist.group(i) = pluginlist.group(i);
                end
            else
                if isempty(newPluginlist.group)
                    newPluginlist.group = pluginlist.group(i+1);
                else
                    newPluginlist.group(i) = pluginlist.group(i+1);
                end
            end
        end
        pluginlist = newPluginlist;
    else
        plugins = [];
        for i = 1:length(pluginlist.group)
            if strcmp(pluginlist.group(i).name,group)
                value = i;
                isDeleted = 0;
                for j = 1:(length(pluginlist.group(i).plugin)-1)
                    if strcmp(pluginlist.group(i).plugin(j).name,plugin)
                        isDeleted = 1;
                    end
                    if (isDeleted == 0)
                        if isempty(plugins)
                            plugins = pluginlist.group(i).plugin(j);
                        else
                            plugins(j) = pluginlist.group(i).plugin(j);
                        end
                    else
                        if isempty(plugins)
                            plugins = pluginlist.group(i).plugin(j+1);
                        else
                            plugins(j) = pluginlist.group(i).plugin(j+1);
                        end
                    end
                end
                pluginlist.group(i).plugin = plugins;
            end
        end
    end
    setappdata(0,'ListDialogAppData',pluginlist);
    set(hGroup,'String',getgroupsnames,'Value',value);
    groupchanged(hGroup,[],hList);

%--------------------------------------------------------------------

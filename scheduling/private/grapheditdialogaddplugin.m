function [groupName,groupDescription,plugin] = grapheditdialogaddplugin(pluginlist)
%DIALOG Add Plugin for Graphedit. 
%   This file is part of Scheduling Toolbox.
%
%   pluginlist - list of all plugins - type struct
%   groupName - name of group of plugins - type string
%   groupDescription - brief description - type string
%   plugin - new plugin - type struct
%
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
        data = getappdata(0,'ListDialogAppData');
        groupName = data.groupName;
        groupDescription = data.groupDescription;
        plugin = data.plugin;
        rmappdata(0,'ListDialogAppData');
    else
        groupName = '';
        groupDescription = '';
        plugin = [];
    end

%--------------------------------------------------------------------   

function hDialog = createdialog(pluginlist)
    
    positionDialog = getposition(gcf,340,155);
    halfDialog = positionDialog(3)/2;

    hDialog = dialog('Visible','off','WindowStyle','modal','Name','Add plugin',...
        'Position',positionDialog);
    
    uicontrol('Parent',hDialog,'Style','text','String','Group Name:',...
        'Position',[10 40+3*26-2 100 18],'HorizontalAlignment','right',...
        'TooltipString','Select group name');
    uicontrol('Parent',hDialog,'Style','text','String','Plugin Name:',...
        'Position',[10 40+2*26-2 100 18],'HorizontalAlignment','right',...
        'TooltipString','Write some name');
    uicontrol('Parent',hDialog,'Style','text','String','Description:',...
        'Position',[10 40+26-2 100 18],'HorizontalAlignment','right',...
        'TooltipString','Write some description of function');
    uicontrol('Parent',hDialog,'Style','text','String','Path or command:',...
        'Position',[10 40-2 100 18],'HorizontalAlignment','right',...
        'TooltipString','Select mfile path or order command');
    
    hGroup = uicontrol('Parent',hDialog,'Style','popupmenu','String',getgroups(pluginlist),...
        'Position',[115 40+3*26 117 20],'BackgroundColor','white','HorizontalAlignment','left',...
        'TooltipString','Select group name');
    hName = uicontrol('Parent',hDialog,'Style','edit','String','',...
        'Position',[115 40+2*26 115 20],'BackgroundColor','white','HorizontalAlignment','left',...
        'TooltipString','Write some name');
    hDesc = uicontrol('Parent',hDialog,'Style','edit','String','',...
        'Position',[115 40+26 205 20],'BackgroundColor','white','HorizontalAlignment','left',...
        'TooltipString','Write some description of function');
    hPath = uicontrol('Parent',hDialog,'Style','edit','String','',...
        'Position',[115 40 151 20],'BackgroundColor','white','HorizontalAlignment','left',...
        'TooltipString','Select mfile path or order command');
    
    uicontrol('Parent',hDialog,'Style','pushbutton','String','Create Group',...
        'Position',[234 40+3*26-1 86 22],'Callback',{@newnametopopupdialog,hGroup},...
        'TooltipString','Create new group');
    uicontrol('Parent',hDialog,'Style','text','String','Gui:',...
        'Position',[234 40+2*26-2 30 18],'HorizontalAlignment','right',...
        'TooltipString','Select ''Yes'' for using default gui for this plugin');
    hGui = uicontrol('Parent',hDialog,'Style','popupmenu','String',{'No','Yes'},...
        'Position',[270 40+2*26 50 20],'BackgroundColor','white','HorizontalAlignment','left',...
        'TooltipString','Select ''Yes'' for using default gui for this plugin');
    uicontrol('Parent',hDialog,'Style','pushbutton','String','Browse',...
        'Position',[267 40-1 53 22],'Callback',{@findcommand,hPath},...
        'TooltipString','Select mfile path');

    uicontrol('Parent',hDialog,'Style','pushbutton','String','OK',...
        'Position',[halfDialog-4-62 8 62 22],...
        'Callback',{@dook,hGroup,hName,hDesc,hPath,hGui});
    uicontrol('Parent',hDialog,'Style','pushbutton','String','Cancel',...
        'Position',[halfDialog+4 8 62 22],...
        'Callback',@docancel);

    
%--------------------------------------------------------------------   
    
function dook(hObject,eventData,hGroup,hName,hDesc,hPath,hGui)
    try
        plugin = struct('name','','gui','','description','','command','');
        groups = get(hGroup,'String');
        data.groupDescription = '';
        data.groupName = groups{get(hGroup,'Value')};
        if isempty(data.groupName)
            h = errordlg('Some group is necessary.','Wrong Group');
            set(h,'WindowStyle','modal');
            return;
        end
        name = get(hName,'String');
        if ~isempty(name) && isletter(name(1))
            plugin.name = name;
        else
            h = errordlg('Some name is necessary.','Wrong Name');
            set(h,'WindowStyle','modal');
            return;
        end
        plugin.gui = num2str((get(hGui,'Value') - 1));
        description = get(hDesc,'String');
        if ~isempty(description)
            plugin.description = sprintf([description '\n']);
        else
            plugin.description = '';
        end
        commandPath = get(hPath,'String');
        if ~isempty(commandPath)
            plugin.command = commandPath;
        else
            h = errordlg('Command or path is necessary.','Wrong Command');
            set(h,'WindowStyle','modal');
            return;
        end
        data.plugin = plugin;
        setappdata(0,'ListDialogAppData',data);
        delete(gcbf);
    catch
        h = errordlg('Something is wrong.','Error');
        set(h,'WindowStyle','modal');
        return;
    end

%--------------------------------------------------------------------   

function docancel(hObject,eventData)
    data.groupName = [];
    data.groupDescription = '';
    data.plugin = [];
    setappdata(0,'ListDialogAppData',data);
    delete(gcbf);
    
%--------------------------------------------------------------------   
    
function groups = getgroups(pluginlist)
    groups = {''};
    if ~isempty(pluginlist.group)
        for i = 1:length(pluginlist.group)
            groups{i} = pluginlist.group(i).name;
        end
    end
    
%--------------------------------------------------------------------   

function position = getposition(hParent,width,height)
    positionParent = get(hParent,'Position');
    position(3) = width;
    position(4) = height;
    position(1) = positionParent(1) + (positionParent(3) - position(3))/2;
    position(2) = positionParent(2) + (positionParent(4) - position(4))/2;
   
%--------------------------------------------------------------------   

function newnametopopupdialog(hObject,eventData,hGroup)
    positionDialog = getposition(get(hObject,'Parent'),200,70);
    hDialog = dialog('WindowStyle','modal','Name','Group Name',...
        'Position',positionDialog);
    uicontrol('Parent',hDialog,'Style','text','String','New Name:',...
        'Position',[10 40-1 62 18],'HorizontalAlignment','right');
    hEdit = uicontrol('Parent',hDialog,'Style','edit','BackgroundColor','white',...
        'Position',[76 40 110 20],'HorizontalAlignment','left',...
        'TooltipString','Write some name');
    uicontrol('Parent',hDialog,'Style','pushbutton','String','OK',...
        'Position',[positionDialog(3)/2-4-62 8 62 22],...
        'Callback',{@addgroup,hGroup,hEdit});
    uicontrol('Parent',hDialog,'Style','pushbutton','String','Cancel',...
        'Position',[positionDialog(3)/2+4 8 62 22],...
        'Callback','delete(gcbf);');

%--------------------------------------------------------------------   

function addgroup(hObject,eventData,hGroup,hEdit)
    name = get(hEdit,'String');
    groups = get(hGroup,'String');
    if ~isempty(name) && isletter(name(1)) && ~sum(strcmp(groups(:),name))
        groups{length(groups)+1} = name;
        set(hGroup,'String',groups,'Value',length(groups));
    else
        h = errordlg('This name unusable.','Wrong Name');
        set(h,'WindowStyle','modal');
        return;
    end
    delete(gcbf);
        
%--------------------------------------------------------------------   

function findcommand(hObject,eventData,hPath)
    [filename,pathname] = uigetfile('*.m','Add Plugin');
    if filename == 0
        filename = '';
    end
    if pathname == 0
        pathname = '';
    end
    if isempty(pathname) && isempty(filename)
        set(hPath,'String','');
    else
        set(hPath,'String',[pathname filename]);
    end
    
%--------------------------------------------------------------------   


function out = grapheditdialogdoplugin(plugin,objGraph)
%DIALOG Do Plugin for Graphedit. 
%   This file is part of Scheduling Toolbox.
%
%   plugin - info about plugin - type struct
%   objGraph - graph created in Graphedit - type graph
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

   
    hDialog = createdialog(plugin,objGraph);
        
    try
        set(hDialog,'Visible','on');
        uiwait(hDialog);
    catch
        if ishandle(hDialog)
            delete(hDialog);
        end
    end
    
    if isappdata(0,'ListDialogAppData')
        out = getappdata(0,'ListDialogAppData');
        rmappdata(0,'ListDialogAppData');
    else
        out = [];
    end
    
    
%--------------------------------------------------------------------   

function hDialog = createdialog(plugin,objGraph)
    helpText = help(plugin.command);
    [pathCommand,command,ext] = fileparts(plugin.command);
    enableCheck = 'on';
    if isempty(helpText)
        enableCheck = 'off';
    end
    
    commandString = [command ' ( g, '];
    
    hDialog = dialog('Visible','off','WindowStyle','modal','Name',plugin.name);
    [hDescription,positionDescription] = createtextfield(hDialog,plugin.description,'on','center');
    [hHelp,positionHelp] = createtextfield(hDialog,helpText,'off','left');
    
    hCheck = uicontrol('Parent',hDialog,'Units','Characters','Position',[1 1 16 1],...
        'Style','checkbox','String','View Help','HorizontalAlignment','left',...
        'Callback',{@docheck,hDialog,hHelp,hDescription},'Value',0,'Enable',enableCheck);
    set(hCheck,'Units','Pixels');
    positionCheck = get(hCheck,'Position');
    hLabel = uicontrol('Parent',hDialog,'FontWeight','bold','Units','Characters','Position',[1 1 (length(commandString) + 4) 1],...
        'Style','text','String',commandString,'HorizontalAlignment','right');
    set(hLabel,'Units','Pixels');
    hLabel2 = uicontrol('Parent',hDialog,'FontWeight','bold','Units','Characters','Position',[1 1 3 1],...
        'Style','text','String',' );','HorizontalAlignment','left');
    set(hLabel,'Units','Pixels');
    set(hLabel2,'Units','Pixels');
    positionLabel2 = get(hLabel2,'Position');
    positionLabel = get(hLabel,'Position');
    hEdit = uicontrol('Parent',hDialog,'Units','Characters','Position',[1 1 17 1.5],...
        'Style','edit','String','','BackgroundColor','white','HorizontalAlignment','left');
    set(hEdit,'Units','Pixels');
    positionEdit = get(hEdit,'Position');    
    widthButtons = 2*80 + 40;
    heightButtons  = 24;
    widthLabelEdit = (positionLabel(3) + 4 + positionEdit(3) + 4 + positionLabel2(3));
    
    positionFigure = get(gcf,'Position');
    
    positionDialog(3) = max([positionDescription(3),positionHelp(3),...
            (widthLabelEdit + widthButtons)]) + 30;
    positionDialog(4) = 10 + positionDescription(4) + 8 +...
            positionLabel(4) + 8 + heightButtons + 8;
    positionDialog(1) = positionFigure(1) + (positionFigure(3)-positionDialog(3))/2;
    positionDialog(2) = positionFigure(2) + (positionFigure(4)-positionDialog(4))/2;
    set(hDialog,'Position',positionDialog);
    halfDialog = positionDialog(3)/2;

    xPositionOK = positionDialog(3)-170-4;
    uicontrol('Parent',hDialog,'Style','pushbutton','String','OK',...
        'Position',[xPositionOK 10 80 heightButtons],...
        'Callback',{@dook,plugin.command,objGraph,hEdit});
    uicontrol('Parent',hDialog,'Style','pushbutton','String','Cancel',...
        'Position',[positionDialog(3)-90 10 80 heightButtons],'Callback',@docancel);
  
    positionLabel(2) = 10 + 5;
    positionEdit(2) = positionLabel(2) - 3;
    positionLabel2(2) = positionLabel(2);
    positionCheck(2) = positionEdit(2) + positionEdit(4) + 10;
    positionDescription(2) = positionCheck(2) + positionCheck(4) + 10;
    positionHelp(2) = positionCheck(2) + 4;
    
    positionLabel(1) = (xPositionOK - widthLabelEdit)/2;
    positionEdit(1) = positionLabel(1) + positionLabel(3) + 4;
    positionLabel2(1) = positionEdit(1) + positionEdit(3) + 4;
    positionCheck(1) = 15;
    positionDescription(1) = halfDialog - positionDescription(3)/2;
    positionHelp(1) = halfDialog - positionHelp(3)/2;

    set(hEdit,'Position',positionEdit);
    set(hLabel,'Position',positionLabel);
    set(hLabel2,'Position',positionLabel2);
    set(hCheck,'Position',positionCheck);
    set(hDescription,'Position',positionDescription);
    set(hHelp,'Position',positionHelp);
    
%--------------------------------------------------------------------   
    
function docheck(hCheck,eventData,hDialog,hHelp,hDescription)
    if ~isempty(hHelp)
        if get(hCheck,'Value') == get(hCheck,'Max')
            set(hHelp,'Visible','on');
            positionHelp = get(hHelp,'Position');
            positionDialog = get(hDialog,'Position');
            positionDialog(2) = positionDialog(2) - positionHelp(4) - 8;
            positionDialog(4) = positionDialog(4) + positionHelp(4) + 8;
            set(hDialog,'Position',positionDialog);
            positionCheck = get(hCheck,'Position');
            positionCheck(2) = positionCheck(2) + positionHelp(4) + 8;
            set(hCheck,'Position',positionCheck);
            if ~isempty(hDescription)
                positionDescription = get(hDescription,'Position');
                positionDescription(2) = positionDescription(2) + positionHelp(4) + 8;
                set(hDescription,'Position',positionDescription);
            end
        else
            set(hHelp,'Visible','off');
            positionHelp = get(hHelp,'Position');
            positionDialog = get(hDialog,'Position');
            positionDialog(2) = positionDialog(2) + positionHelp(4) + 8;
            positionDialog(4) = positionDialog(4) - positionHelp(4) - 8;
            set(hDialog,'Position',positionDialog);
            positionCheck = get(hCheck,'Position');
            positionCheck(2) = positionCheck(2) - positionHelp(4) - 8;
            set(hCheck,'Position',positionCheck);
            if ~isempty(hDescription)
                positionDescription = get(hDescription,'Position');
                positionDescription(2) = positionDescription(2) - positionHelp(4) - 8;
                set(hDescription,'Position',positionDescription);
            end
        end
    end

%--------------------------------------------------------------------   
    
function [hObject,position] = createtextfield(parent,text,visible,alignment)
    endLines = regexp(text,'\n');
    if ~isempty(endLines)
        width = getmaxdiffernce([0 endLines]);
        height = length(endLines) + 1;
        hObject = uicontrol('Parent',parent,'Style','text',...
            'Units','Characters','Position',[1 1 width height],...
            'String',text,'HorizontalAlignment',alignment,'Visible',visible);
        set(hObject,'Units','Pixels');
        position = get(hObject,'Position');
    else
        hObject = [];
        position = [0 0 0 0];
    end
    
%--------------------------------------------------------------------   
    
function max = getmaxdiffernce(endLines)
    try
        max = 0;
        for i = 2:length(endLines)
            difference = (endLines(i) - endLines(i-1));
            if (difference > max)
                max = difference;
            end
        end
    catch
        max = 0;
    end
   
%--------------------------------------------------------------------   
    
function dook(hObject,eventData,command,objGraph,hEdit)
    parameters = get(hEdit,'String');
    [pathCommand,command,ext] = fileparts(command);
    pathPWD = pwd;
    global g;   
    g = objGraph;
    eval('global g;');
    
    try   
        if ~isempty(findstr(filesep,pathCommand))
            try
                cd(pathCommand);
            catch
                [pathDirect,direct] = fileparts(pathCommand);
                cd([pathDirect filesep '@' direct]);
            end
        end
    
        if isempty(parameters)
            commandString = [command '( g );'];
        else
            commandString = [command '( g , ' parameters ' );'];
        end
    
        out = 0;
        try
            out = nargout([command '.m']);
        catch
            out = nargout([pathCommand '/' command '.m']);
        end
    
        if out > 0
            objGraph = eval(commandString);
        else
            eval(commandString);
            objGraph = [];
        end
    catch
        err = lasterror;
        h = errordlg(...  %            ['Plugin "' command '" caused error. XX'],...
            err.message,...
            'Plugin Error');
        set(h,'WindowStyle','modal');
        objGraph = [];
    end
    
    eval('clear g;');
    cd(pathPWD);
    setappdata(0,'ListDialogAppData',objGraph);
    delete(gcbf);        

%--------------------------------------------------------------------   
    
function docancel(hObject,eventData)
    setappdata(0,'ListDialogAppData',[]);
    delete(gcbf);
    
%--------------------------------------------------------------------   

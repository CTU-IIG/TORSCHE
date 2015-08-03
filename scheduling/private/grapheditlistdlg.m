function [name,isNewName] = grapheditlistdlg(varargin)
%GRAPHEDITLISTDLG List selection dialog box for Graphedit. 
%   This file is part of Scheduling Toolbox.
%
%   name - string selected in list or set in edit - type string
%   isNewName - 1 is new name, 0 is selected name - type int
%
%   Parameter       Description
%   'parentFigure'  handle of parent figure - numeric
%   'list1'         primary list of two lists of names - cell of strings
%   'list2'         secondary list of two lists of names - cell of strings
%   'initialValue'  selected item - int
%   'okString'      string on ok button - string
%   'cancelString'  string on cancel button - string
%   'fileName'      name of dialog - string
%   'editName'      label of editbox - string
%   'listName'      label of listbox - string
%   'checkText'     label of check button - string
%   'questString'   question for rewriting - string
%   'checkEnable'   enable/disable of switching lists list1, list2 - 'on','off'
%   'editEnable'    enable/disable of editbox - 'on','off'
%   'listenbale'    enable/disable of listbox - 'on','off'
%   'replaceable'   enable/disable rewriting of name - 'on','off'
%   'askifreplace'  enable/disable asking when rewriting should be executed
%   'uniqueName'    name must/mustn't be unique - 'on','off'
%   'listHandles1'  list of handles - array of nums
%   'listHandles2'  list of handles - array of nums
%   'currentAxes'   handle of axes - numeric
%   'windowStyle'   'modal','normal'
%   'position'      'leftup','leftdown','center','rightup','rightdown'
%   'initialName'   string viewed in editbox - string
%
%
%   Example:
%       [name,isNewName] = grapheditlistdlg(...
%            'parentfigure',gcbf,...
%            'filename','Name list',...
%            'list1',listNamesNodes,...
%            'list2',listNamesAll,...
%            'listname','Used names:',...
%            'okstring','OK',...
%            'cancelstring','Cancel',...
%            'editname','New name: ',...
%            'checktext','view only nodes',...
%            'checkenable','on',...
%            'editenable','on',...
%            'replaceable','off',...
%            'queststring','This name is used.',...
%            'uniquename',get(findobj('Tag','uimenu_UniqueNames'),'Checked'),...
%            'listHandles1',listHandlesNodes,...
%            'listHandles2',listHandlesAll',...
%            'currentaxes',gca,...
%            'initialvalue',initialValue,...
%            'position','leftdown');
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
    
  
    error(nargchk(1,inf,nargin))
    
    parentFigure = [];
    listData1 = {};
    listData2 = {};
    initialValue = 1;
    okstring = 'Ok';
    cancelstring = 'Cancel';
    filename = '';
    editname = '';
    listname = '';
    checktext = '';
    questString = 'Do you want to replace this name?';
    checkEnable = 'on';
    editEnable = 'on';
    listEnable = 'on';
    initialName = 'g';
    replaceable = 'on';
    askifreplace = 'on';
    uniquename = 'on';
    listHandle1 = [];
    listHandle2 = [];
    hAxes = [];
    windowStyle = 'modal';
    position = 'center';
    
    if mod(length(varargin),2) ~= 0
        % input args have not com in pairs, woe is me
        error('Arguments to LISTDLG must come param/value in pairs.')
    end
    for i=1:2:length(varargin)
        switch lower(varargin{i})
            case 'parentfigure'
                parentFigure = varargin{i+1};
             case 'list1'                    
                listData1 = varargin{i+1};
                if ~isempty(listData1)
                    initialName = listData1(initialValue);
                end
             case 'list2'
                listData2 = varargin{i+1};
            case 'initialvalue'
                initialValue = varargin{i+1};
                initialName = listData1(initialValue);
            case 'okstring'
                okstring = varargin{i+1};
            case 'cancelstring'
                cancelstring = varargin{i+1};
            case 'filename'
                filename = varargin{i+1};
            case 'editname'
                editname = varargin{i+1};
            case 'listname'
                listname = varargin{i+1};
            case 'checktext'
                checktext = varargin{i+1};
            case 'queststring'
                questString = varargin{i+1};
            case 'checkenable'
                checkEnable = varargin{i+1};
            case 'editenable'
                editEnable = varargin{i+1};
            case 'listenable'
                listEnable = varargin{i+1};
                if strcmp(listEnable,'off')
                    checkEnable = 'off';
                end
            case 'replaceable'
                replaceable = varargin{i+1};
            case 'uniquename'
                uniquename = varargin{i+1};
            case 'listhandles1'
                listHandle1 = varargin{i+1};
            case 'listhandles2'
                listHandle2 = varargin{i+1};
            case 'currentaxes'
                hAxes = varargin{i+1};
            case 'windowstyle'
                windowStyle = varargin{i+1};
            case 'position'
                position = varargin{i+1};
            case 'initialname'
                initialName = varargin{i+1};
            case 'askifreplace'
                askifreplace = varargin{i+1};
            otherwise
              error(['Unknown parameter name passed to LISTDLG.  Name was ' varargin{i}])
        end
    end

    
    positionDialog = getpositiondialog(parentFigure,position);
                
    hDialog = dialog('Position',positionDialog,'Visible','off','Name',filename,'WindowStyle',windowStyle);
    
    uicontrol('Parent',hDialog,'Style','text','String',editname,...
        'Position',[15 44 80 18],'HorizontalAlignment','right');
    hEdit = uicontrol('Parent',hDialog,'Style','edit','String',initialName,'HorizontalAlignment','left',...
        'Position',[95 44 positionDialog(3)-100-15 20],'BackgroundColor','white','Enable',editEnable);
                
    uicontrol('Parent',hDialog,'Style','text','String',listname,...
        'Position',[15 positionDialog(4)-28 positionDialog(3)-30 18],'HorizontalAlignment','left');
    hList = uicontrol('Parent',hDialog,'Style','listbox','String',listData1,'Enable',listEnable,...
        'Position',[15 88 positionDialog(3)-30 positionDialog(4)-88-28],'Value',initialValue,...
        'Callback',{@doListboxClick,hEdit,questString,listData1,listData2,replaceable,askifreplace,uniquename,listHandle1,listHandle2,hAxes,parentFigure});
    
    hCheck = uicontrol('Parent',hDialog,'Style','checkbox','String',checktext,'Value',1,...
        'Position',[positionDialog(3)/2-60 66 120 20],'HorizontalAlignment','right',...
        'Callback',{@doCheckedBoxClick,hList,hEdit,listData1,listData2},'Enable',checkEnable);
   
    uicontrol('Parent',hDialog,'Style','pushbutton','String',okstring,...
        'Position',[positionDialog(3)/2-4-80 10 80 24],...
        'Callback',{@doOK,listData1,listData2,hEdit,questString,replaceable,askifreplace,uniquename,listHandle1,listHandle2,hAxes});
    uicontrol('Parent',hDialog,'Style','pushbutton','String',cancelstring,...
        'Position',[positionDialog(3)/2+4 10 80 24],'Callback',{@doCancel,hList});
    
    set(hDialog,'Visible','on'); 
           
    
    try
        set(hDialog, 'visible','on');
        uiwait(hDialog);
    catch
        if ishandle(hDialog)
            delete(hDialog);
        end
    end
    
    if isappdata(0,'ListDialogAppData')
        ad = getappdata(0,'ListDialogAppData');
        name = ad.name;
        isNewName = ad.isNewName;
        rmappdata(0,'ListDialogAppData');
    else
        name = '';
        isNewName = 1;
    end
   
    
function doOK(ok_btn, evd, listData1, listData2, editbox, queststring,...
              replaceable, askifreplace, uniquename, listHandle1, listHandle2, hAxes)
    ad.name = get(editbox,'String');
    if iscell(ad.name)
        ad.name = ad.name{1};
    end
    ad.isNewName = 1;
    if (((sum(strcmp(listData1(:),ad.name)) ~= 0) || (sum(strcmp(listData2(:),ad.name)) ~= 0)) &&...
             (strcmp(get(editbox,'Enable'),'on') == 1))
        ad.isNewName = 0;
        if (strcmp(uniquename,'on') == 1)
            if (strcmp(askifreplace,'on') == 1)
                if (strcmp(replaceable,'on') == 1)
                    button = questdlg(queststring,...
                        'Continue Operation','Yes','No','No');
                    if strcmp(button,'No')
                        return;
                    end
                else
                    h = errordlg(queststring,'Wrong name');
                    set(h,'WindowStyle','modal');
                    return;
                end
            end
        end
    end
    if ~isempty(ad.name) && ~isletter(ad.name(1))
        return;
    end
    setappdata(0,'ListDialogAppData',ad);
    delete(gcbf);


function doCancel(cancel_btn, evd, listbox)
    ad.name = '';
    ad.isNewName = 1;
    setappdata(0,'ListDialogAppData',ad)
    delete(gcbf);
    
    
function doListboxClick(listbox, evd, editbox, queststring,...
        listData1, listData2, replaceable, askifreplace, uniquename,...
        listHandle1, listHandle2, hAxes, parentFigure)
    % if this is a doubleclick, doOK
    list = get(listbox,'String');
    if ~isempty(list)
        if strcmp(get(gcbf,'SelectionType'),'open')
            if strcmp(replaceable,'on')
                doOK([],[],listData1,listData2,editbox,queststring,...
                     replaceable,askifreplace,uniquename,listHandle1,listHandle2,hAxes);
            else
                index = get(listbox,'value');
                name = list(index);
                if ~isempty(listHandle1)
                    graphedit('selectononeobject',listHandle2(index),hAxes,parentFigure);
                end
                set(editbox,'String',name);
            end
        else
            index = get(listbox,'value');
            name = list(index);
            if ~isempty(listHandle1)
                graphedit('selectononeobject',listHandle2(index),hAxes,parentFigure);
            end
            set(editbox,'String',name);
        end
    end
    

function doCheckedBoxClick(checkbox, evd, listbox, editbox, listData1, listData2)    
    if  get(checkbox,'Value') == get(checkbox,'Max')
        set(listbox,'String',listData1);
        if isempty(get(editbox,'String'))
            if ~isempty(listData1)
                set(editbox,'String',listData1(1));
            else
                set(editbox,'String','');
            end
        end
    elseif get(checkbox,'Value') == get(checkbox,'Min')
        set(listbox,'String',listData2);
        if isempty(get(editbox,'String'))
            if ~isempty(listData2)
                set(editbox,'String',listData2(1));
            else
                set(editbox,'String','');
            end
        end
    end

    
    
function positionDialog = getpositiondialog(parentFigure,position)
    positionFigure = get(parentFigure,'Position');
    positionDialog(3) = 220;
    positionDialog(4) = 260;
    switch lower(position)
        case 'center'
            positionDialog(1) = positionFigure(1) + (positionFigure(3)-positionDialog(3))/2;
            positionDialog(2) = positionFigure(2) + (positionFigure(4)-positionDialog(4))/2;
        case 'rightup'
            positionDialog(1) = positionFigure(1) + 20;
            positionDialog(2) = positionFigure(2) + positionFigure(4) - (positionDialog(4) + 45);
        case 'rightdown'
            positionDialog(1) = positionFigure(1) + 20;
            positionDialog(2) = positionFigure(2) + 20;
        case 'leftup'
            positionDialog(1) = positionFigure(1) + positionFigure(3) - (positionDialog(3) + 20);
            positionDialog(2) = positionFigure(2) + positionFigure(4) - (positionDialog(4) + 45);
        case 'leftdown'
            positionDialog(1) = positionFigure(1) + positionFigure(3) - (positionDialog(3) + 20);
            positionDialog(2) = positionFigure(2) + 20;
    end

    
    

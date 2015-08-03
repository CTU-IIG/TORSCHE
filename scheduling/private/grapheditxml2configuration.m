function configuration = grapheditxml2configuration(configurationFileName,defaultConfiguration)
%GRAPHEDITXML2CONFIGURATION converts xml file to structure conteins
%configuraton of graphedit. 
%
%   This file is part of Scheduling Toolbox.
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


    try
        xml = xmlread(configurationFileName);
        children = xml.getChildNodes;
        for i = 1:children.getLength
            outStruct(i) = xmlplugins2struct(children.item(i-1));
        end
        configuration = transformstructure(outStruct.children);
        configuration = testofconfiguration(configuration,defaultConfiguration,configurationFileName);
    catch
        configuration = defaultConfiguration;
    end

%=========================================================================

function s = xmlplugins2struct(node)
    s.name = char(node.getNodeName);
    if node.hasAttributes
        attributes = node.getAttributes;
        nattr = attributes.getLength;
        for i = 1:nattr
            attr = attributes.item(i-1);
            s.attributes(i).name = char(attr.getName);
            s.attributes(i).value = char(attr.getValue);
        end
    else
        s.attributes = [];
    end
    try
        s.data = char(node.getData);
    catch
    end
    if node.hasChildNodes
        children = node.getChildNodes;
        nchildren = children.getLength;
        s.children = [];
        for i = 1:nchildren
            child = children.item(i-1);
            struct = xmlplugins2struct(child);
            s.children{end+1} = struct;
        end
    else
        s.children = []; 
    end 

%=========================================================================

function configuration = transformstructure(inputCell)
    for i = 1:length(inputCell),
        if iscell(inputCell),
            thisStruct = inputCell{i};
        else
            thisStruct = inputCell;
        end
        if ~strcmp(thisStruct.name,'#text'),
            value = retype(thisStruct.attributes(end).value,thisStruct.children{1}.data);
            if strcmp(thisStruct.attributes(end).value,'struct'),
                value = transformstructure(thisStruct.children); %#ok<NASGU>
            elseif strcmp(thisStruct.attributes.value,'cell'),
                value{str2double(thisStruct.children{2}.attributes(1).value)} = transformstructure(thisStruct.children{2});
                value{1} = value{1}.cell;
            end
            eval(['configuration.' thisStruct.name ' = value;']);
        end
    end

%=========================================================================

function value = retype(type,string)
    switch type
        case 'char'
            value = string;
        case 'struct'
            value = [];
        case {'double','int','int16','int08'}
            value = str2num(string);
        case 'cell'
            value = [];
        case 'logical'
            value = logical(str2double(string));
        otherwise
            error('Invalid data type.');
    end
    
%=========================================================================

function configuration = testofconfiguration(configuration,defaultConfiguration,configurationFileName)
    [configuration,replaced,save] = dotest(configuration,defaultConfiguration,'',false);
    if ~isempty(replaced),
        h = warndlg(['Invalid data types in configuration xml file have appeared. The values ' replaced(3:end) ' were replaced by default ones.']);
        set(h,'WindowStyle','modal');
    end
    if save,
        grapheditconfiguration2xml(configuration,configurationFileName);
    end

%=========================================================================

function [configuration,replaced,save] = dotest(configuration,defaultConfiguration,replaced,save)
    defConfNames = fieldnames(defaultConfiguration);
    for i = 1:length(defConfNames),
        if isfield(configuration,defConfNames{i})
            value = eval(['configuration.' defConfNames{i}]);
            if isstruct(value),
                [newValue,replaced,save] = dotest(value,eval(['defaultConfiguration.' defConfNames{i}]),replaced,save);
                eval(['configuration.' defConfNames{i} ' = newValue;']);
            elseif iscell(value),
%                 for j = 1:length(value),
%                     [newValue,replaced,save] = dotest(value{j},eval(['defaultConfiguration.' defConfNames{i} '{j}']),replaced,save);
%                     eval(['configuration.' defConfNames{i} '{j} = newValue;']);
%                 end
            else
                if ~isa(value,class(eval(['defaultConfiguration.' defConfNames{i}]))),
                    replaced = [replaced, ', ''' defConfNames{i} ''''];
                    eval(['configuration.' defConfNames{i},...
                          ' = defaultConfiguration.' defConfNames{i} ';']);
                    save = true;
                end
            end
        else
            eval(['configuration.' defConfNames{i},...
                  ' = defaultConfiguration.' defConfNames{i} ';']);
            save = true;
        end
    end
    
%=========================================================================
%=========================================================================

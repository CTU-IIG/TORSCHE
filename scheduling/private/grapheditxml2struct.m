function out = grapheditxml2struct(pathName, fileName, varargin)
%GRAPHEDITXML2STRUCT converts content of xml file to structure conteins list of plugins. 
%   This file is part of Scheduling Toolbox.
%
%   [pathName filesep fileName] - path of xml file - string
%   out - structure of plugins
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

    
    if nargin == 0
        [fileName,pathName] = uigetfile('*.xml','Load xml');
    end
    if isempty(pathName)
        [pathName,mFile] = fileparts(mfilename('fullpath'));
    end
    try
        %xml = xmlread([pathName filesep fileName]);
        xml = xmlread(fileName);
        children = xml.getChildNodes;
        for i = 1:children.getLength
            outStruct(i) = xmlplugins2struct(children.item(i-1));
        end
        out = getpluginlist(outStruct);
    catch
        out = struct('version','','application','','group',[]);
    end

%----------------------------------------------------------------    
    
function s = xmlplugins2struct(node)

    s.name = char(node.getNodeName);
     
    if node.hasAttributes
        attributes = node.getAttributes;
        nattr = attributes.getLength;
        s.attributes = struct('name',cell(1,nattr),'value',cell(1,nattr));
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
        s.data = '';
    end
    if node.hasChildNodes
        children = node.getChildNodes;
        nchildren = children.getLength;
        c = cell(1,nchildren);
        s.children = struct('name',c,'attributes',c,'data',c,'children',c);
        for i = 1:nchildren
            child = children.item(i-1);
            s.children(i) = xmlplugins2struct(child);
        end
    else
        s.children = [];
    end 
   
%----------------------------------------------------------------    
    
function out = getpluginlist(in)
    out = struct('version','','application','','group',[]);
    out.application = getparam(in.attributes,'application');
    out.version = getparam(in.attributes,'ver');
    for i = 1:length(in.children)
        switch lower(in.children(i).name)
            case 'group'
                if isempty(out.group)
                    out.group = getgroup(in.children(i));
                else
                    out.group(length(out.group)+1) = getgroup(in.children(i));
                end
            otherwise
        end
    end
    
%----------------------------------------------------------------  

function out = getgroup(in)
    out = struct('name','','description','','plugin',[]);
    out.name = getparam(in.attributes,'name');
    for i = 1:length(in.children)
        switch lower(in.children(i).name)
            case 'description'
                if ~isempty(in.children(i).children)
                    out.description = in.children(i).children.data;
                else
                    out.description = '';
                end
            case 'plugin'
                if isempty(out.plugin)
                    out.plugin = getplugin(in.children(i));
                else
                    out.plugin(length(out.plugin)+1) = getplugin(in.children(i));
                end
            otherwise
        end
    end  

%----------------------------------------------------------------    
    
function out = getplugin(in)
    out = struct('name','','gui','','description','','command','');
    out.name = getparam(in.attributes,'name');
    out.gui = getparam(in.attributes,'gui');
    for i = 1:length(in.children)
        switch lower(in.children(i).name)
            case 'description'
                if ~isempty(in.children(i).children)
                    out.description = in.children(i).children.data;
                end
                %out.description = sprintf([out.description '\n']);
            case 'command'
                out.command = in.children(i).children.data;
            otherwise
        end
    end
    
%----------------------------------------------------------------    

function out = getparam(in,param)
    for i = 1:length(in)
        switch lower(in(i).name)
            case param
                out = in(i).value;
            otherwise
        end
    end
    
%----------------------------------------------------------------    


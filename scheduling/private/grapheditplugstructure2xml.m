function saved = grapheditplugstructure2xml(pluginlist, pluginFileName)
%GRAPHEDITPLUGSTRUCT2XML converts structure conteins list of plugins to xml file. 
%   This file is part of Scheduling Toolbox.
%
%   pluginlist - plugins structure - struct
%   pluginFileName - name of xml file - string
%   saved - 1 is saved, 0 is not saved - int
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


    %assignin('base','p',pluginlist)
    saved = 1;
    try
        [pathGraphEdit,command,ext,ver] = fileparts(mfilename('fullpath'));
        savexml([pathGraphEdit filesep],pluginFileName,pluginlist);
    catch
        saved = 0;
    end
    


function savexml(pathname, filename, pluginlist, varargin)

    if nargin == 0
        [filename,pathname] = uiputfile('*.xml','Save graph');
    end

    if ~isempty(filename) && ~isempty(pluginlist)
          
        docNode = com.mathworks.xml.XMLUtils.createDocument('pluginlist');
        
        docRootNode = docNode.getDocumentElement;
        docRootNode.setAttribute('application','Graphedit');
        docRootNode.setAttribute('ver',pluginlist.version);
        
        for i = 1:length(pluginlist.group)
            thisElement = docNode.createElement('group');
            docGroupNode = docRootNode.appendChild(thisElement);
            docGroupNode.setAttribute('name',pluginlist.group(i).name);
            
            thisElement = docNode.createElement('description');
            thisElement.appendChild(docNode.createTextNode(pluginlist.group(i).description));
            docGroupNode.appendChild(thisElement);
            
            for j = 1:length(pluginlist.group(i).plugin)
                thisElement = docNode.createElement('plugin');
                docPluginNode = docRootNode.appendChild(thisElement);
                docPluginNode.setAttribute('name',pluginlist.group(i).plugin(j).name);
                docPluginNode.setAttribute('gui',pluginlist.group(i).plugin(j).gui);
                docGroupNode.appendChild(thisElement);
                
                if ~isempty(pluginlist.group(i).plugin(j).description)
                    thisElement = docNode.createElement('description');
                    thisElement.appendChild(docNode.createTextNode(pluginlist.group(i).plugin(j).description));
                    docPluginNode.appendChild(thisElement);
                end
                
                thisElement = docNode.createElement('command');
                thisElement.appendChild(docNode.createTextNode(pluginlist.group(i).plugin(j).command));
                docPluginNode.appendChild(thisElement);
            end
        end
        % Save the XML document.
        [path,name,ext] = fileparts(filename);
        xmlFileName = filename;
        xmlwrite(xmlFileName,docNode);
    end

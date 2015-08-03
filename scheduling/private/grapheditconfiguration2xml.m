function grapheditconfiguration2xml(struct,filename)
%GRAPHEDITCONFIGURATION2XML converts configuration structure to xml and
%saves it as a file named filename.
%
%   See also grapheditplugstructure2xml


% Author: Vojtech Navratil <navrav1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2946 $  $Date:: 2009-05-18 20:16:21 +0200 #$


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
        docNode = com.mathworks.xml.XMLUtils.createDocument('configuration');
        docRootNode = docNode.getDocumentElement;
        docRootNode.setAttribute('application','Graphedit');
        docRootNode.setAttribute('ver',struct.version);
        docRootNode = struct2xml(docNode,docRootNode,struct);

        emptyfn = 0;
        if (isempty(filename))
            emptyfn = 1;
            filename = [tempname,'.xml'];
        end
        xmlwrite(filename,docRootNode);
        if (emptyfn)
            edit(filename);
        end
    catch
        rethrow(lasterror);
    end
        
%=========================================================================

function docRootNode = struct2xml(docNode,docRootNode,struct)
    names = fieldnames(struct);
    for i = 1:length(names),
        data = eval(['struct.' names{i}]);
        thisElement = docNode.createElement(names{i});
%         thisElement.setAttribute('name',names{i});
        thisElement = setchildren(docNode,thisElement,data);
        docRootNode.appendChild(thisElement);   
    end

%=========================================================================

function thisElement = setchildren(docNode,thisElement,data)
    if isstruct(data),
        thisElement.setAttribute('type','struct');
        thisElement = struct2xml(docNode,thisElement,data);
    elseif ischar(data),
        thisElement.setAttribute('type','char');
        thisElement.appendChild(docNode.createTextNode(data));
    elseif isnumeric(data),
        thisElement.setAttribute('type',class(data));
        thisElement.appendChild(docNode.createTextNode(num2str(data)));
    elseif iscell(data),
        thisElement.setAttribute('type','cell');
        thisElement = cell2xml(docNode,thisElement,data);
    elseif islogical(data),
        thisElement.setAttribute('type','logical');
        thisElement.appendChild(docNode.createTextNode(logical2str(data)));
    else
        error ('Invalid data structure!');
    end

%=========================================================================

function strVariable = logical2str(variable)
    if variable,
        strVariable = '1';
    else
        strVariable = '0';
    end
    
%=========================================================================

function docRootNode = cell2xml(docNode,docRootNode,data)
    for i = 1:length(data),
        thisElement = docNode.createElement('cell');
        thisElement.setAttribute('number',num2str(i));
        thisElement = setchildren(docNode,thisElement,data{i});
        docRootNode.appendChild(thisElement);   
    end

%=========================================================================    

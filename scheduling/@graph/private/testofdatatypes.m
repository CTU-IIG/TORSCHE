function [out,list] = testofdatatypes(list,dataTypes)
% Test data types used in graph object
% out - status 1 - OK; 0 - fault
% list - list of user params. Cell where each row is one UserParam item and
%        each collumn one param.
% dataType - cell vector of dataType example: {'double','edge'}

% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2896 $  $Date:: 2009-03-18 12:20:12 +0100 #$

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


out = 1;
try
    if ~isempty(dataTypes) && ~isempty(list)
        % test for cell of objects NODE or EDGE
        if isa(list(1),'node') || isa(list(1),'edge')
            emptyValues = getemptyvalues(dataTypes);
            for i = 1:length(list)
                if isempty(list(i).UserParam)
                    list(i).UserParam = emptyValues;
                else
                    for j = 1:length(dataTypes)
                        if ~isempty(dataTypes{j}) && ~isa(list(i).UserParam{j},dataTypes{j})
                            out = 0;
                            return;
                        end
                    end
                end
            end
            % test for edgeList or nodeList
        else
            [rowsNum] = size(list,1);
            typesNum = length(dataTypes);
            for i = 1:rowsNum
                for j = 1:typesNum
                    if ~isempty(dataTypes{j}) && ~isa(list{i,j},dataTypes{j})
                        out = 0;
                        return;
                    end
                end
            end
        end
    end
catch
    out = 0;
    return;
end

function nodeout = loadobj(nodein)
% LOADOBJ for node class


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


if isa(nodein, 'node')
    nodeout = nodein;
else %nodein is old version
    num = length(nodein);
%    nodeout = cell(1,num);
    for i = 1:num
        nodetorepair = nodein(i);
        switch nodetorepair.version
            case 0.01
                schedobjolddata = struct(nodein(i).schedobj);
                nodetorepair.GraphicParam{1}.x = schedobjolddata.GrParam.position(1);
                nodetorepair.GraphicParam{1}.y = schedobjolddata.GrParam.position(2);
                nodetorepair.GraphicParam{1}.width  = 30;
                nodetorepair.GraphicParam{1}.height = 30;
                nodetorepair.GraphicParam{1}.curvature = [1 1];
                nodetorepair.GraphicParam{1}.facecolor = schedobjolddata.GrParam.color;
                nodetorepair.GraphicParam{1}.linewidth = 1;
                nodetorepair.GraphicParam{1}.linestyle = '-';
                nodetorepair.GraphicParam{1}.edgecolor = [0 0 0];             
                nodetorepair.TextParam = [];
            otherwise
                error('Wrong version');
        end
        nodetorepair.version = 0.02;
        schedobj_back = nodetorepair.schedobj;
        nodetorepair = rmfield(nodetorepair, 'schedobj'); 
        parent = schedobj;
        nodetorepair = class(nodetorepair, 'node', parent);
        nodetorepair.schedobj = schedobj_back;
        nodeout(i) = nodetorepair;
    end
    if num == 1
        nodeout = nodeout(1);
    end
end

%end .. @node/loadobj

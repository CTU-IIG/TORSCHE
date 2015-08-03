function UserParam = edges2param(g,varargin)
%EDGES2PARAM  return taskset's user parameter describing edges' user parameter.
%
%    userparam = EDGES2PARAM(graph)
%      graph     - object graph
%      userparam - output user param
%
%    userparam = EDGES2PARAM(graph,n)
%      graph     - object graph
%      n         - number (or array of numbers) of wanted user param. All
%                  params are return if 0 is used.
%      userparam - output user param
%
%  See also TASKSET, GRAPH.


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


n = 0;
if nargin > 1
    n = varargin{1};
    if isempty(n)
        n = 0;
    end
end

numNodes = length(adj(g));
UserParamCount = zeros(numNodes);
UserParam{numNodes,numNodes} = [];

try
    if n==0
        for i = 1:size(g.eps,1)
            param = g.E(i).UserParam;
            UserParamCount(g.eps(i,1),g.eps(i,2)) = UserParamCount(g.eps(i,1),g.eps(i,2))+1;
            UserParam{g.eps(i,1),g.eps(i,2)}{UserParamCount(g.eps(i,1),g.eps(i,2))} = param(1:end);
        end
    else
        for i = 1:size(g.eps,1)
            param = g.E(i).UserParam;
            UserParamCount(g.eps(i,1),g.eps(i,2)) = UserParamCount(g.eps(i,1),g.eps(i,2))+1;
            UserParam{g.eps(i,1),g.eps(i,2)}{UserParamCount(g.eps(i,1),g.eps(i,2))} = param(n);
        end
    end
catch
    error('Invalid param format!');
end

%end .. @graph/edges2param

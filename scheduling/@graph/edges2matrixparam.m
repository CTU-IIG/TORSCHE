function UserParam = edges2matrixparam(g,varargin)
%EDGES2MATRIXPARAM returns user parameters of edges in graph
%   USERPARAM = EDGES2MATRIXPARAM(G) returns first user parameter on
%   edges in graph G. If there is not an edge between two nodes, the
%   corresponding user parameter is considered to be INF. If there
%   are parallel edges the algorithm returns error message.
%
%   USERPARAM = EDGES2MATRIXPARAM(G,N) returns N-th user parameter on
%   edges in graph G.
%
%   USERPARAM = EDGES2MATRIXPARAM(G,N,NOTEDGEPARAM) defines value of
%   user parameter for missing edges (default is INF).
%
%   See also EDGES2PARAM, GRAPH, MATRIXPARAM2EDGES.


% Author: Premysl Sucha <suchap@fel.cvut.cz>
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


notEdgeParam = inf;
if (nargin >= 2)
    paramCat = varargin{1};
else
    paramCat = 1;
end

if (nargin >= 3)
    notEdgeParam = varargin{2};
end

n=length(adj(g));
UserParamCount = zeros(n);
UserParam = notEdgeParam*ones(n);

for i = 1:size(g.eps,1)
    if(length(g.E(i).UserParam)>=paramCat)
        param = g.E(i).UserParam{paramCat};
    else
        param = notEdgeParam;
    end
    if(~isa(param,'numeric'))
        error('A parametr on an edge is not number.');
    end
    if(UserParamCount(g.eps(i,1),g.eps(i,2))>0)
        error('Input graph contains parallel edges.');
    end
    UserParamCount(g.eps(i,1),g.eps(i,2)) = 1;
    UserParam(g.eps(i,1),g.eps(i,2)) = param;
end

%end .. @graph/edges2matrixparam

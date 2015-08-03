function g = addedge(g, varargin)
%ADDEDGE  Add edge to the graph.
%
% Synopsis
%   graph = ADDEDGE(graph, from, to[, param])
%   graph = ADDEDGE(graph, from, to[, edge])
%   graph = ADDEDGE(graph, edgeList)
%
% Description
%  Add edge to the graph.
%
%  Parameters:
%   graph:
%     - Instance of Graph object
%   from:
%     - Vector of initials nodes.
%   to:
%     - Vector of conditions nodes.
%   param:
%     - Cell matrix or any vector of users params.
%       Each row includes params for one edge.
%   edge:
%     - Vector of edge objects.
%   edgeList:
%     - List of edges (cell): initial node, terminal node, user parameters.
%       see also [guide:ref-GRAPH_GRAPH]
%
% See also GRAPH/REMOVEEDGE.


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


switch nargin
    case 1
        error('TORSCHE:graph:InvalidNumberOfInputs','Input param missing.'); 
    case 2
        edgeList = varargin{1};
        if ~iscell(edgeList)
            error('TORSCHE:graph:InvalidInput','Invalid edgeList.');
        end
        try 
            from = cell2mat(edgeList(:,1));
            to = cell2mat(edgeList(:,2));
            param = edgeList(:,3:end);
        catch
            error('TORSCHE:graph:InvalidInput','Invalid edgeList.');
        end
    case 3
        from = varargin{1};
        to   = varargin{2};
    case 4
        from = varargin{1};
        to   = varargin{2};
        if isa(varargin{3},'edge')
                edgevector = varargin{3};
        else
                param = varargin{3};
        end
    otherwise
        error('TORSCHE:graph:InvalidNumberOfInputs','Too many input param.');
end

if (~isa(from,'double'))
    error('TORSCHE:graph:InvalidInput','Parameter From must be integer.');
end
if (~isa(to,'double'))
    error('TORSCHE:graph:InvalidInput','Parameter To must be integer.');
end
if (all(size(from)~=size(to))) || min(size(to))>1
    error('TORSCHE:graph:InvalidSize','Vector From and To must be the same size.')
end
if (any(from<1) || any(from > length(g.N)))
    error('TORSCHE:graph:InvalidInput','Invalid node number.');
end
if (any(to<1) || any(to > length(g.N)))
    error('TORSCHE:graph:InvalidInput','Invalid node number.');
end

% param to edge
if ~exist('edgevector','var')
    edgevector(length(from)) = edge;
    for i = 1:length(from)-1
        edgevector(i) = edge();
    end
end
if exist('param','var')
    if (min(size(param))==1)
        if length(from)~=length(param)
            error('TORSCHE:graph:InvalidSize','Invalid number of parameters.')
        end
        for i = 1:length(from)
            edgevector(i).UserParam = param(i);
        end
    else
        if length(from)~=size(param,1)
            error('TORSCHE:graph:InvalidSize','Invalid number of parameters.')
        end
        for i = 1:length(from)
            edgevector(i).UserParam = param(i,:);
        end
    end
end

% add edges
try
    % adding to the empty edge list fixed
    if isempty(g.E) && length(from) >= 1
        g.E = edgevector(1);
        g.eps(1,:) = [from(1) to(1)];
        from(1) = [];
        to(1) = [];
    end

    for i=1:length(from)
        g.E(end+1) = edgevector(i);
        g.eps(end+1,:) = [from(i) to(i)];
    end
catch
  error('TORSCHE:graph:addedgeerror', 'Unexpected error.');
end

% data type check
try
    if ~isempty(g.DataTypes.edges)
        edl = get(g,'edl');
        isOK = testofdatatypes(edl(:,3:end),g.DataTypes.edges);
    else
        isOK = 1;
    end
catch
    isOK = 0;
end
if ~isOK
    error('TORSCHE:graph:invalidDataTypes', 'Parameters does not match datatypes.');
end

%end .. @graph/addedge

function g = edgesrearrange(g,param,varargin)
%EDGESREARRANGE assigns user parameters to graph.
%    G = EDGESREARRANGE(G,USERPARAM) assigns to user param
%    (UserParam) of edges in graph G data from matrix USERPARAM.
%
%    G = EDGESREARRANGE(G,USERPARAM,N) assigns the data to 
%    N-th position in UserParam.
%
%    G = EDGESREARRANGE(G,USERPARAM,N,NOTEDGEPARAM) defines value of
%    user parameter for missing edges. This value is used for checking 
%    consistence between graph G and matrix USERPARAM (default is INF).
%
%    G = EDGESREARRANGE(G,USERPARAM,N,NOTEDGEPARAM,PERMITACTION)
%    defines permited action with graph. Default is denied of inserting and
%    deleting edges. For allowing inserting edges parameter value is 'i',
%    for allowing deleting is 'd', for allowing both then 'a'
%
%  See also EDGES2PARAM, PARAM2EDGES, GRAPH, EDGES2MATRIXPARAM.


% Author: Pavel Mezera <Pavel.Mezera@Seznam.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2896 $  $Date:: 2009-03-18 12:20:12 +0100 #$


% This file is part of Scheduling Toolbox.
% 
% Scheduling Toolbox is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.
% 
% Scheduling Toolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with Scheduling Toolbox; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
% USA


notEdgeParam = inf;
allowedAction=' ';
if(nargin>=3)
    paramCat = varargin{1};     %Order of the input data in UserParam
    else
    paramCat = 1;
    end;
if(nargin>=4)
    notEdgeParam = varargin{2};
    end;
if(nargin>=5 & length(varargin{3})==1)
    allowedAction = varargin{3};
    end;
for from = 1 : size(param,1)
    for to = 1 : size(param,2)
        edges = between(g,from,to);
        if(length(edges)==0 & param(from,to)~=notEdgeParam) % inserting edge
            if(allowedAction=='a' | allowedAction=='i')
                g.eps=[g.eps;[from,to]];
                g.E(length(g.E)+1)=g.E(length(g.E));
                g.E(length(g.E)).UserParam{paramCat}=param(from,to);
                else
                error('Matrix of parameters ''param'' doesn match with the input graph.');
                end;
            end;
        if(length(edges)>1)
            error('Input graph contains parallel edges.');
            end;
        if(length(edges)==1 & param(from,to)~=notEdgeParam) % modification edge
            edgeUserParam=g.E(edges(1)).UserParam;
            edgeUserParam{paramCat}=param(from,to);
            g.E(edges(1)).UserParam=edgeUserParam;
            end;
        if(length(edges)==1 & param(from,to)==notEdgeParam) % deleting edge
            if(allowedAction=='a' | allowedAction=='d')
                index=find(g.eps(:,1)==from & g.eps(:,2)==to);
                g.eps=[g.eps(1:index-1,:);g.eps(index+1:size(g.eps,1),:)];
                g.E=[g.E(1:index-1),g.E(index+1:length(g.E))];
                else
                error('Matrix of parameters ''param'' doesn match with the input graph.');
                end;
            end;
        end
    end
    if length(g.E) == 0
        g.E = [];
    end
    
%end .. @graph/edgesRearrange

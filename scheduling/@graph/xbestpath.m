function [gxbp numberOfFlows] = xbestpath(g,s,t,k,varargin)
% ALLPATH is function, which finds the path by the graph.
%
% Synopsis
%   GXBP = XBESTPATH(G,S,T,K)
%   GXBP = XBESTPATH(G,S,T,K,CI)
%   GXBP = XBESTPATH(G,S,T,K,CI,NUMPATH)
%   GXBP = XBESTPATH(G,S,T,K,CI,NUMPATH,USERPARAMPOSITION)
%   GXBP = XBESTPATH(G,S,T,K,CI,NUMPATH,USERPARAMPOSITION,CAP)
%   [GXBP NUMBEROFFLOWS] = XBESTPATH(G,S,T,K,...)
%
% Description
% This function finds path by the graph G, from source to sink nodes.
% You can choice, hou many path you need.
% Is possible to use it only for graphs, which not contains a cycle or
% is set parameter CI, for ignoring cycle.
% This function has four necessary inputs parameters, graph G, source nodes S,
% sink nodes T, K - kind of the path.
% parameter K
% K = 1 - algorithm looks for the biggest paths by the aspect of
% amplitude flows - capability (For this selection is necessary to fill
% parameter CAP, if it is saved capbility of edges to another userParamPos,
% as is the fourth.)
% K = 2, algorithm looks for the quickest paths.
% And four unnecessary input parameters.
% First input parameter is CI - Cycle Ignore. Second is NUMPATH,
% if you do not fill this parameter, algotihm finding 3 path.
% The third is number of parameter, on which weigths of edges are saved.
% As a fourth parameter is CAP - Capability of edges. If you want to set up
% another parameter of edges you can choice the number of userParamPos for
% saving.

% First output is a graph GNBP with a cycles, save as a userParamPos.
% Second output parameter is a NUMBEROFFLOWS, numbers of separate flows from
% source to sink nodes.
%
% Example
% >> edgeList= {1 3,3;2 3,1;3 4,4;4 3,2;4 5,4;4 6,5};
% >> g = graph('edl',edgeList,'edgeDatatype',{'double'});
% >> s = [1 2];
% >> t = [5 4];
% >> k = 1;
% >> gxbp = xbestpath(g,s,t,k,1)
%
% See also GRAPH, ALLPATH, GRAPH/MULTICOMMODITYFLOW, GRAPH/MAXMULTICOMMODITYFLOW


% Author: Elvira  Hanakova <hanake1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009
% $Revision: 2908 $  $Date:: 2009-04-14 11:36:04 +0200 #$


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


% check of the input parameters
if nargin > 4
    if isnumeric(varargin{1})
        ci = varargin{1};
        ci = round(ci(1));
    else
        error ('TORSCHE:graph:wrongparamtype',...
            'Fourth parameter must be numerical!');
    end
else
    ci = 0;
end
if nargin > 5
    if isnumeric(varargin{2})
        numPath = round(varargin{2});
    end
else
    numPath = 3;
end
if nargin > 6
    if isnumeric(varargin{3})
        userParamPos = varargin{3};
        userParamPos = round(userParamPos(1));
    else
        userParamPos = 1;
    end
end
if nargin > 7
    if isnumeric(varargin{4})
        cap = varargin{4};
        cap = round(cap(1));
        biggerParam = max([userParamPos cap]);
        if cap == userParamPos
            disp ('TORSCHE:graph:sameParam',...
                'Capability and weigth are the same parameter!');
        end
    end
elseif userParamPos ~=2
    biggerParam = userParamPos;
    for i = 1:length(g.E)
        if ~empty(g.E(i).userParamPos(2))
            cap = 2;
            biggerParam = max([userParamPos cap]);
            break;
        end
    end
else
    biggerParam = userParamPos;
end
if iscyclic(g) && ci==0
    error ('TORSCHE:graph:wronggraph',...
        'Graph contains cycle!');
end
if k==1 || k==2
else
    error ('TORSCHE:graph:wrongparamtype',...
        'Fourth parameter must be <1,2>!');
end
edgeList = get(g,'edl');
edgeList = cell2mat(edgeList);
n = max(max(edgeList(:, 1:2)));
E = cell(1, n);
for i = 1:n
    index = find(edgeList(:, 1) == i);
    E{i} = (index);
end
edgeways = zeros(50,length(g.E));
nodeways = zeros(50,length(g.N));
line = 1;
thruePath = zeros(50,2);
for i = 1:size(s,2)
    if line>=length(edgeways)
        edgeways = [edgeways;zeros(50,length(g.E))];
        nodeways = [nodeways;zeros(50,length(g.N))];
        thruePath = [thruePath;zeros(50,2)];
    end
    lifo = lifoPush([],(E{s(i)})');
    [lifo next] = lifoPop(lifo);
    nodeways(line,find(nodeways(line,:)==0,1,'first')) = edgeList(next,1);
    if k ==2
        while 1
            if ~any(next == edgeways(line,:)) && ~any(edgeList(next,2) == nodeways(line,:))...
                    && nodeways(line,find(nodeways(line,:)~=0,1,'last'))==edgeList(next,1)
                edgeways(line,find(edgeways(line,:)==0,1,'first')) = next;
                nodeways(line,find(nodeways(line,:)==0,1,'first')) = edgeList(next,2);
                % edge ends in t and number of path < numPath
                %(copy line,remeber sum of edgeways, step back)
                if edgeList(next,2) == t(i) && length(find(thruePath(:,1)==i)) < numPath
                    thruePath(line,1) = i;
                    thruePath(line,2) = sum(edgeList(edgeways(line,1:find(edgeways(line,:)~=0,1,'last')),2+userParamPos));
                    % edge ends in t, number of path > numPath+1, new way is better
                    % (copy line,remeber sum of edgeways, replace new way, step back)
                elseif edgeList(next,2) == t(i) && sum(edgeList(edgeways(line,1:find(edgeways(line,:)~=0,1,'last')),2+userParamPos)) <...
                        max(thruePath(find(thruePath(:,1)==i),2))
                    [temp theWorstWay] = max(thruePath(find(thruePath(:,1)==i),2));
                    xWays = find(thruePath(:,1)==i);
                    thruePath(xWays(theWorstWay),1) = 0;
                    thruePath(xWays(theWorstWay),2) = 0;
                    thruePath(line,1) = i;
                    thruePath(line,2) = sum(edgeList(edgeways(line,1:find(edgeways(line,:)~=0,1,'last')),2+userParamPos));
                end
                % from node, where edge ends, takes another edge and number
                % of flow does not turn finded path or not enough path
                % (using next edge)
                if ~isempty(E{edgeList(next,2)}) && edgeList(next,2) ~= t(i) ...
                        && (any(sum(edgeList(edgeways(line,1:find(edgeways(line,:)~=0,1,'last')),2+userParamPos)) < ...
                        max(thruePath(find(thruePath(:,1)==i),2))) || length(find(thruePath(:,1)==i)) < numPath)
                    lifo = lifoPush(lifo,(E{edgeList(next,2)})');
                    % from node, where edge ends, doesn't take another edge(copy line, step back)
                elseif find(nodeways(line,:)~=0,1,'last')~=1
                    edgeways(line+1,1:(find(edgeways(line,:)~=0,1,'last'))-1)...
                        = edgeways(line,1:(find(edgeways(line,:)~=0,1,'last'))-1);
                    nodeways(line+1,1:(find(nodeways(line,:)~=0,1,'last'))-1)...
                        = nodeways(line,1:(find(nodeways(line,:)~=0,1,'last'))-1);
                    line = line + 1;
                else
                    break;
                end
                % edge or node were already used (copy line, using the next edge
                % from the same node or step back)
            elseif nodeways(line,find(nodeways(line,:)~=0,1,'last'))~=edgeList(next,1)...
                    && find(nodeways(line,:)~=0,1,'last')~=1
                edgeways(line+1,1:(find(edgeways(line,:)~=0,1,'last'))-1)...
                    = edgeways(line,1:(find(edgeways(line,:)~=0,1,'last'))-1);
                nodeways(line+1,1:(find(nodeways(line,:)~=0,1,'last'))-1)...
                    = nodeways(line,1:(find(nodeways(line,:)~=0,1,'last'))-1);
                line = line + 1;
                lifo = lifoPush(lifo,next);
            end
            if ~isempty(lifo)
                [lifo next] = lifoPop(lifo);
            else
                line = line + 1;
                break;
            end
        end
    else
        while 1
            if ~any(next == edgeways(line,:)) && ~any(edgeList(next,2) == nodeways(line,:))...
                    && nodeways(line,find(nodeways(line,:)~=0,1,'last'))==edgeList(next,1)
                edgeways(line,find(edgeways(line,:)==0,1,'first')) = next;
                nodeways(line,find(nodeways(line,:)==0,1,'first')) = edgeList(next,2);
                % edge ends in t and number of path < numPath
                %(copy line,remeber sum of edgeways, step back)
                if edgeList(next,2) == t(i) && length(find(thruePath(:,1)==i)) < numPath
                    thruePath(line,1) = i;
                    thruePath(line,2) = min(edgeList(edgeways(line,1:find(edgeways(line,:)~=0,1,'last')),2+cap));
                    % edge ends in t, number of path > numPath+1, new way is better
                    % (copy line,remeber sum of edgeways, replace new way, step back)
                elseif edgeList(next,2) == t(i) && min(edgeList(edgeways(line,1:find(edgeways(line,:)~=0,1,'last')),2+cap)) >...
                        min(thruePath(find(thruePath(:,1)==i),2))
                    [temp theWorstWay] = min(thruePath(find(thruePath(:,1)==i),2));
                    xWays = find(thruePath(:,1)==i);
                    thruePath(xWays(theWorstWay),1) = 0;
                    thruePath(xWays(theWorstWay),2) = 0;
                    thruePath(line,1) = i;
                    thruePath(line,2) = min(edgeList(edgeways(line,1:find(edgeways(line,:)~=0,1,'last')),2+cap));
                end
                % from node, where edge ends, takes another edge and number
                % of flow does not turn finded path or not enough path
                % (using next edge)
                if ~isempty(E{edgeList(next,2)}) && edgeList(next,2) ~= t(i) ...
                        && (any(min(edgeList(edgeways(line,1:find(edgeways(line,:)~=0,1,'last')),2+cap)) > ...
                        min(thruePath(find(thruePath(:,1)==i),2))) || length(find(thruePath(:,1)==i)) < numPath)
                    lifo = lifoPush(lifo,(E{edgeList(next,2)})');
                    % from node, where edge ends, doesn't take another edge(copy line, step back)
                elseif find(nodeways(line,:)~=0,1,'last')~=1
                    edgeways(line+1,1:(find(edgeways(line,:)~=0,1,'last'))-1)...
                        = edgeways(line,1:(find(edgeways(line,:)~=0,1,'last'))-1);
                    nodeways(line+1,1:(find(nodeways(line,:)~=0,1,'last'))-1)...
                        = nodeways(line,1:(find(nodeways(line,:)~=0,1,'last'))-1);
                    line = line + 1;
                else
                    break;
                end
                % edge or node were already used (copy line, using the next edge
                % from the same node or step back)
            elseif nodeways(line,find(nodeways(line,:)~=0,1,'last'))~=edgeList(next,1)...
                    && find(nodeways(line,:)~=0,1,'last')~=1
                edgeways(line+1,1:(find(edgeways(line,:)~=0,1,'last'))-1)...
                    = edgeways(line,1:(find(edgeways(line,:)~=0,1,'last'))-1);
                nodeways(line+1,1:(find(nodeways(line,:)~=0,1,'last'))-1)...
                    = nodeways(line,1:(find(nodeways(line,:)~=0,1,'last'))-1);
                line = line + 1;
                lifo = lifoPush(lifo,next);
            end
            if ~isempty(lifo)
                [lifo next] = lifoPop(lifo);
            else
                line = line + 1;
                break;
            end
        end
    end
end
numberOfFlows = zeros(1,size(s,2));
for i = 1:size(s,2)
    numberOfFlows(i) = sum(thruePath(:,1) == i);
end
sumOfFlows = sum(numberOfFlows);

% complete graph gxbp by flows
gxbp = g;
for i = 1:size(edgeList,1)
    for j = 1:sumOfFlows
        gxbp.E(i).userParam{j+biggerParam} = 0;
    end
end
column =  find(thruePath~=0);
for i = 1:sumOfFlows
    lineOfEdges = edgeways(column(i),edgeways(column(i),:)~=0);
    for j = 1:size(lineOfEdges,2)
        gxbp.E(lineOfEdges(j)).userParam{i+biggerParam} = 1;
    end
end

end

function [lifo value] = lifoPop(lifo)
value = lifo(end);
lifo = lifo(1:end-1);
end

function lifo = lifoPush(lifo, value)
lifo = [lifo value];
end

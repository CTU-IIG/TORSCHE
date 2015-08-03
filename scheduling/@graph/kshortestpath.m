function [gksp numberOfFlows] = kshortestpath(g,s,t,pathFilter,varargin)
% KSHORTESTPATH is function, which finds the shortest path by the graph.
%
% Synopsis
%   GKSP = KSHORTESTPATH(G,S,T,PATHFILTER)
%   GKSP = KSHORTESTPATH(G,S,T,PATHFILTER,CI)
%   GKSP = KSHORTESTPATH(G,S,T,PATHFILTER,CI,NUMPATH)
%   GKSP = KSHORTESTPATH(G,S,T,PATHFILTER,CI,NUMPATH,CAP)
%   GKSP = KSHORTESTPATH(G,S,T,PATHFILTER,CI,NUMPATH,CAP,COST)
%   [GKSP NUMBEROFFLOWS] = KSHORTESTPATH(G,S,T,PATHFILTER,...)
%
% Description
% This function finds path by the graph G, from source to sink nodes.
% You can choice, hou many path you need.
% Is possible to use it only for graphs, which not contains a cycle or
% is set parameter CI, for ignoring cycle.
% This function has four necessary inputs parameters, graph G, source nodes S,
% sink nodes T, PATHFILTER - kind of the path.
% parameter PATHFILTER
%  'KShortest' - function looking for the shortest
%  path by the graph, in line with costs of edges.
%  'KMosteCap' - function looking for the most
%  capacity of edges, in line with capacity.
% LIMITATION is a first unnecessary input parametr, mean number of path,
% which are used in MMCF. If it is not set up, default is 3. 
% And four unnecessary input parameters.
% First input parameter is CI - Cycle Ignore. Second is NUMPATH,
% if you do not fill this parameter, algorithm finding 3 path.
% The third is CAP number of parameter, on which capability of edges are saved.
% As a fourth parameter is COST - cost of edges. If you want to set up
% another parameter of edges you can choice the number of userParamPos for
% saving.

% First output is a graph GKSP with a cycles, save as a userParamPos.
% Second output parameter is a NUMBEROFFLOWS, numbers of separate flows from
% source to sink nodes.
%
% Example
% >> edgeList= {1 3,3;2 3,1;3 4,4;4 3,2;4 5,4;4 6,5};
% >> g = graph('edl',edgeList,'edgeDatatype',{'double'});
% >> s = [1 2];
% >> t = [5 4];
% >> k = 1;
% >> gksp = kshortestpath(g,s,t,k,1)
%
% See also GRAPH, ALLPATH, GRAPH/MULTICOMMODITYFLOW, GRAPH/MAXMULTICOMMODITYFLOW


% Author: Elvira  Hanakova <hanake1@fel.cvut.cz>
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
        cap = varargin{3};
        cap = round(cap(1));
    end
else
    cap = 1;
end
maxUserParam = max(cellfun(@(x)length(x.UserParam),get(g,'E')));
biggerParam = maxUserParam;
if nargin > 7
    if isnumeric(varargin{4})
        userParamPos = varargin{4};
        userParamPos = round(userParamPos(1));
        if userParamPos == cap
            warning ('TORSCHE:graph:sameParam',...
                'Cost and capability are the same parameter!');
        end
    end
elseif cap ~= 2 && maxUserParam > 1
       userParamPos = 2;
elseif strcmpi(pathFilter,'kShortest') 
    error ('TORSCHE:graph:sameParam',...
            'Cost is absent!');
end
if iscyclic(g) && ci==0
    error ('TORSCHE:graph:wronggraph',...
        'Graph contains cycle!');
end

if strcmpi(pathFilter,'kShortest') 
    k = 2;
elseif strcmpi(pathFilter,'kMosteCap')
    k = 1;
else
    error ('TORSCHE:graph:wrongparamtype',...
        'Wrong input parametr pathFilter!');
end


edgeList = get(g,'edl');
edgeList = cell2mat(edgeList);
n = max(max(edgeList(:, 1:2)));
if length(s)~=length(t)
    error ('TORSCHE:graph:wrongparam',...
              'Matrix s and t have to be same length!');
end
E = cell(1, n);
for i = 1:n
    index = find(edgeList(:, 1) == i);
    E{i} = (index);
end
for i = 1:length(s)
    if isempty(E{s(i)}) 
       error ('TORSCHE:graph:wrongparam',...
              'Input parameter s is wrong!Way does not exist!');
    end
end
for i = 1: length(t)
   if ~any(edgeList(:,2)==t(i))
       error ('TORSCHE:graph:wrongparam',...
              'Input parameter t is wrong!Way does not exist!');
   end
end
edgeways = zeros(100,length(g.E));
nodeways = zeros(100,length(g.N));
line = 1;
thruePath = zeros(100,2);
for i = 1:size(s,2)
    if line>=length(edgeways)
        edgeways = [edgeways;zeros(100,length(g.E))];
        nodeways = [nodeways;zeros(100,length(g.N))];
        thruePath = [thruePath;zeros(100,2)];
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
                elseif edgeList(next,2) == t(i) && any(sum(edgeList(edgeways(line,1:find(edgeways(line,:)~=0,1,'last')),2+userParamPos)) <...
                        max(thruePath(find(thruePath(:,1)==i),2)))
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
                elseif edgeList(next,2) == t(i) && any(min(edgeList(edgeways(line,1:find(edgeways(line,:)~=0,1,'last')),2+cap)) >...
                        min(thruePath(find(thruePath(:,1)==i),2)))
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

% complete graph gksp by flows
gksp = g;
for i = 1:size(edgeList,1)
    for j = 1:sumOfFlows
        gksp.E(i).userParam{j+biggerParam} = 0;
    end
end
column =  find(thruePath~=0);
for i = 1:sumOfFlows
    lineOfEdges = edgeways(column(i),edgeways(column(i),:)~=0);
    for j = 1:size(lineOfEdges,2)
        gksp.E(lineOfEdges(j)).userParam{i+biggerParam} = 1;
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

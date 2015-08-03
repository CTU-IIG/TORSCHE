function [gap numberOfFlows amplFlows] = allpath(g,s,t,varargin)
% ALLPATH is function, which finds the path by the graph.
%
% Synopsis
%   GAP = ALLPATH(G,S,T)
%   GAP = ALLPATH(G,S,T,CI)
%   GAP = ALLPATH(G,S,T,CI,CAP)
%   [GAP NUMBEROFFLOWS] = ALLPATH(G,S,T,...)
%   [GAP NUMBEROFFLOWS AMPLFLOWS] = ALLPATH(G,S,T,...)
%
% Description
% This function finds all path by the graph G, from source to sink nodes.
% Is possible to use it only for graphs, which not contains a cycle or
% is set parameter CI, for ignoring cycle. 
% This function has five inputs parameters, graph G, source nodes S,
% sink nodes T and two unnecessary parameters.
% First input parameter is CI - Cycle Ignore. Second is number of
% parameter, on which capacity of edges are saved, default is 1. 
% First output is a graph GAP with a path, save as a userParamPos.
% Second output parameter is a NUMBEROFFLOWS, numbers of separate flows from
% source to sink nodes. Third output parameter is AMPLFLOWS, it is
% amplitude of found flows.
%
% Example
% >> edgeList = {1 2,3;1 3,4;1 7,5;1 10,3;2 13,1;2 15,3;2 18,2;3 4,3;4 5,4;
% >> 5 6,3;6 9,4;6 12,5;7 8,5;8 9,5;9 12,9;10 12,2;10 14,5;11 12,3;13 14 1;...
% >> 14 22,2;15 16,4;16 17,5;17 22,3;18 19,1;19 15,3;19 20,5;20 21,8;21 22,3};
% >> g = graph('edl',edgeList,'edgeDatatype',{'double'});
% >> s = [1 2];
% >> t = [12 22];
% >> gap = allpath(g,s,t)
%
% See also GRAPH, GRAPH/MULTICOMMODITYFLOW, GRAPH/MAXMULTICOMMODITYFLOW,
% GRAPH/KSHORTESTPATH


% Author: Elvira  Hanakova <hanake1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2920 $  $Date:: 2009-05-05 22:46:22 +0200 #$


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
if nargin > 3
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
if nargin > 4
    if isnumeric(varargin{2})
        cap = varargin{2};
        cap = round(cap(1)); 
    end
else
    cap = 1;
end
if iscyclic(g) && ci==0
       error ('TORSCHE:graph:wronggraph',...
              'Graph contains cycle!');
end
edgeList = get(g,'edl');
edgeList = cell2mat(edgeList);
maxUserParam = max(cellfun(@(x)length(x.UserParam),get(g,'E')));
biggerParam = maxUserParam;
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
    while 1
        if ~any(next == edgeways(line,:)) && ~any(edgeList(next,2) == nodeways(line,:))...
            && nodeways(line,find(nodeways(line,:)~=0,1,'last'))==edgeList(next,1)
            edgeways(line,find(edgeways(line,:)==0,1,'first')) = next;
            nodeways(line,find(nodeways(line,:)==0,1,'first')) = edgeList(next,2);
            % edge ends in t(copy line, step back)
            if edgeList(next,2) == t(i)
                thruePath(line,1) = i;
                thruePath(line,2) = sum(edgeList(edgeways(line,1:find(edgeways(line,:)~=0,1,'last')),2+cap));
            end
            % from node, where edge ends, takes another edge(using next edge)
            if ~isempty(E{edgeList(next,2)}) && edgeList(next,2) ~= t(i)
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
            % edge or node were already used (copy line, using the next edge from the same node or step back)
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
numberOfFlows = zeros(1,size(s,2));
for i = 1:size(s,2)
     numberOfFlows(i) = sum(thruePath(:,1)==i);
end
sumOfFlows = sum(numberOfFlows);   

% complete graph gap by flows
gap = g;
for i = 1:size(edgeList,1)
    for j = 1:sumOfFlows
        gap.E(i).userParam{j+biggerParam} = 0; 
    end
end
column =  find(thruePath(:,1)~=0);
for i = 1:sumOfFlows
    lineOfEdges = edgeways(column(i),edgeways(column(i),:)~=0);
    for j = 1:size(lineOfEdges,2)
        gap.E(lineOfEdges(j)).userParam{i+biggerParam} = 1;
    end
end
amplFlows = thruePath(column,2);
end

function [lifo value] = lifoPop(lifo)
    value = lifo(end);
    lifo = lifo(1:end-1);
end

function lifo = lifoPush(lifo, value)
    lifo = [lifo value];
end

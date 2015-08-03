function [TSP g] = christofides(g,varargin)
% CHRISTOFIDES is a function, which solves TSP(travelling salesman problem)
% of the graph.
%
%Synopsis
%         TSP = CHRISTOFIDES(G)
%        TSP = CHRISTOFIDES(G,USERPARAMPOSITION)
%        [TSP G] = CHRISTOFIDES(G)
%Description
% The function have two input and two outputs. First inputs,necessary, is a
% graph - G. Second input parameter is unnecessary and it is number of
% parameter, on which weigths of edges are saved. 
% The first output is TSP - list of edges, which includes order of graph's 
% edges as were used.
% The second output is a graph G, the TSP solution in form of graph object.
%  
%Example
% >> edgeList= {1 2,1;1 3,2;1 4,2;1 5,3;2 3,2;2 4,2;2 5,3;3 4,3;3 5,4;4 5,3};
% >> g = graph('edl',edgeList,'edgeDatatype',{'double'});
% >> [TSP g] = christofides(g)
%
% See also GRAPH, GRAPH/EULER, GRAPH/KRUSKAL, GRAPH/DISTANCE, GRAPH/MWPM,
% GRAPH/COMPLETE


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
if nargin > 1
    if isnumeric(varargin{1})
        userParamPos = varargin{1};
        userParamPos = round(userParamPos(1));
    else
        error ('TORSCHE:graph:wrongparamtype',...
            'Second parameter must be numerical!');
    end
else
    userParamPos = 1;
end

edgeListG = get(g,'edl');
if size(edgeListG,2) < (userParamPos + 2) ||...
    ~all(cellfun(@length, {edgeListG{:,(userParamPos + 2)}}, 'UniformOutput', true)==1)
    error ('TORSCHE:graph:weightsOfGraphAreMissing','Weights of edges are missing!');
end
dataType = get(g,'edgeDatatype');
if size(dataType,1) == 0 || strcmp(dataType(1),'double') == 0
    if isa(edgeListG{1, (userParamPos + 2)}, 'double')
        set(g,'edl',edgeListG,'edgeDatatype',{'double'});
        warning('TORSCHE:graph:weightsOfGraphAreMissing',...
                'Edge data type missing, set to "double"');
    else
        error ('TORSCHE:graph:weightsOfGraphAreMissing',...
               'Weights of edges are missing!');
    end
end
edgeListG = cell2mat(edgeListG(:,[1:2 userParamPos + 2]));
n = max(max(edgeListG(:, 1:2)));
C = edges2matrixparam(g,1,0);
if issimple(g)==0
    warning('TORSCHE:graph:unsimplegraph',...
        'Graph is not simple.');
end
for i=1:n
    for j=i+1:n
        if C(i,j)==0 && C(j,i)==0
            error('TORSCHE:graph:uncompletegraph',...
                'Graph is not complete!See to complete function');
        end
    end
end
for i = 1:n
    for j = 1:n
        for k = 1:n
            if C(i,j)~=0 && C(j,k)~=0 && C(i,k)~=0 && i~=k && k~=j && i~=j
                if C(i,j)+C(j,k)<C(i,k)
                    error('TORSCHE:graph:triangleinequality',...
                        'Triangle inequality in graph was not keeped!');
                end
            end
        end
    end
end
%% ALGORITHM
% Christofides's algorithm
% Input: An instance $(K_n,c)$ of the Metric $TSP$
% Output: A tour and graph $G$
% Ref: lit-Korte 
%% 1 Find a minimum weight spanning tree $T$ in $K_n$ with respect $c$.
[spanningTree numberOfEdges restOfGraph] = kruskal(g);
%% 2 Let $W$ be a set of vertices having odd degree in $T$
oddNodes = find(mod(degree(spanningTree),2)==1);
%% Find a minimum weight $W$-join $J$ in $K_n$ with respect to $c$.
% looking for the mwpm
lb = zeros(size(edgeListG,1),1);
Ub = ones(size(edgeListG,1),1);
E = char('E'*ones(size(oddNodes,2),1));
I = char('I'*ones(size(edgeListG,1),1));
f = edgeListG(:,3);
A = zeros(size(oddNodes,2),size(edgeListG,1));
b = ones(size(oddNodes,2),1);
for i = 1:size(oddNodes,2)
    numberOfEdges = ...
        ([(between(g,oddNodes(i),oddNodes))' (between(g,oddNodes,oddNodes(i)))']);
    if isempty(numberOfEdges)
        continue
    end
    for k = 1:size(numberOfEdges,2)
        A(i,numberOfEdges(k)) = 1;
    end
end
xmin = ilinprog(schoptionsset(),1,f,A,b,E,lb,Ub,I); %#ok<NASGU>

% adding the mwpm edges to spanning tree
newEdges = find(xmin==1);
for i=1:size(newEdges,1)
    spanningTree=addedge(spanningTree,g.eps(newEdges(i),1),g.eps(newEdges(i),2),g.E(newEdges(i)));
end

% remake from eulerwalk(list of edges) to walkeuler(list of node)
eulerwalk = euler(spanningTree);
walkeuler = zeros(1,size(eulerwalk,2)+1);
for i=1:size(eulerwalk,2)
    if i ~=1
        if spanningTree.eps(eulerwalk(i),1)~= walkeuler(i)
            walkeuler(i+1) = spanningTree.eps(eulerwalk(i),1);
        else walkeuler(i+1) = spanningTree.eps(eulerwalk(i),2);
        end
    else walkeuler(i) = spanningTree.eps(eulerwalk(i),1);
        walkeuler(i+1) = spanningTree.eps(eulerwalk(i),2);
    end
end
n=length(g.N);
EdgesFrequent = cell(1, n);
for i = 1:n
    index = find(walkeuler == i);
    if isempty(index) || size(index,2)== 1
        EdgesFrequent{i} = [];
    else
        EdgesFrequent{i} = index;
    end
end
outsideNodes = EdgesFrequent{walkeuler(1)};
outsideNodes = outsideNodes(2:end-1);
EdgesFrequent{walkeuler(1)} = outsideNodes;
EdgesFrequentnz = zeros(1,size(EdgesFrequent,2));
for i = 1:size(EdgesFrequent,2)
    EdgesFrequentnz(i) = isempty(EdgesFrequent{i});
end
EF = find(EdgesFrequentnz==0);
edlST = get(spanningTree,'edl');
edlST = cell2mat(edlST);
edlROG = get(restOfGraph,'edl');
edlROG = cell2mat(edlROG);
delTSP = [];
% find an hamilton tour(unnecessary, if is it cheaper go throw the same node)
if ~isempty(EF)
    add = [];
    rem = [];
    edgmax = zeros(1,size(EF,2));
    for j = 1:size(EF,2)
        nextEdges = EdgesFrequent{EF(j)};
        edg = zeros(3,size(nextEdges,2));
        for i = 1:size(nextEdges,2)
            E11 = ([(between(restOfGraph,walkeuler(nextEdges(i)-1),walkeuler(nextEdges(i)+1)))';...
                (between(restOfGraph,walkeuler(nextEdges(i)+1),walkeuler(nextEdges(i)-1)))']);
            E11cost = edlROG(E11,3);
            [tempE E11sort] = sort(E11cost,'descend');
            E1 = edlST(eulerwalk(nextEdges(i)-1),3);
            E2 = edlST(eulerwalk(nextEdges(i)),3);
            edg(2,i) = eulerwalk(nextEdges(i)-1);
            edg(3,i)= eulerwalk(nextEdges(i));
            edg(1,i) = (E11(E11sort));
            edgmax(i) = E1 + E2;
            if i > 1 && edgmax(i) > edgmax(i-1)
                delTSP = [delTSP nextEdges(i)];
                add = [add edg(1,i)]; %#ok<AGROW>
                rem = [rem edg(2,i) edg(3,i)]; %#ok<AGROW>
                edgmax(i) = edgmax(i-1);
                edg(2,i) = edg(2,i-1);
                edg(3,i) = edg(3,i-1);
                edg(1,i) = edg(1,i-1);
            elseif i > 1 && edgmax(i) <= edgmax(i-1)
                delTSP = [delTSP nextEdges(i-1)];
                add = [add edg(1,i-1)]; %#ok<AGROW>
                rem = [rem edg(2,i-1) edg(3,i-1)]; %#ok<AGROW>
            elseif size(nextEdges,2)==1
                delTSP = nextEdges;
                add = [add edg(1,i)]; %#ok<AGROW>
                rem = [rem edg(2,i) edg(3,i)]; %#ok<AGROW>
            end
        end
    end
    spanningTree = removeedge(spanningTree,rem); %#ok<FNDSB>
    edgesTemp = get( spanningTree,'edl');
    edl = cell2mat(edgesTemp(:,1:3));
    numAdd = find(add~=0);
    for i = 1:size(numAdd,2)
        edl(size(edl,1)+1,:) = edlROG(add(numAdd(i)),:);
    end
    edl = mat2cell(edl,[ones(1,size(edl,1))],[ones(1,size(edl,2))]);
    g = graph('edl',edl);
    TSP = walkeuler;
    delTSPs = sort(delTSP);
    j = 0;
    for i = 1:size(delTSP,2)
        TSP = TSP(:,[1:delTSPs(i)-1-j delTSPs(i)+1-j:end]);
        j = j+1;
    end

% walkeuler unused the same node
else TSP = walkeuler;
    g = spanningTree;
end
end

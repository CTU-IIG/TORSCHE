function [usedSubject,varargout] = knapsack(weight,cost,maxWeight)
% KNAPSACK is a function, which solves a knapsack problem.
%
%Synopsis
%         USEDSUBJECT = KNAPSACK(WEIGHT,COST,MAXWEIGHT)
% [USEDSUBJECT G] = KNAPSACK(WEIGHT,COST,MAXWEIGHT)
%Description
% Inputs are weight, which are a weights of all the subjects and cost are their prices. MaxWeight is a maximum weight, which is a possible to infill to the knapsack .
% You have to fill all the parameters.
%
%Example
% >> weight = [7 6 4 3];
% >> cost = [2 3 4 5];
% >> maxWeight = 15;
% >> usedSubject = knapsack(weight,cost,maxWeight)
%
% See also FLOYD


% Author: Elvira  Hanakova <hanake1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2895 $  $Date:: 2009-03-18 11:24:58 +0100 #$


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


if nargin ~= 3
    error ('TORSCHE:graph:wrongNumberOfParameter',...
        'Function knapsack has 3 inputs parameters!');
end
if length(weight)~=length(cost)
    error ('TORSCHE:graph:wrongInputsParameters',...
        'Inputs parameters cost and weight has to be of same length!');
end
edgeList = [];
%% ALGORITHM
% V is a first vertex
V = [0 0];
% path is list with information about infill knapsack in each vertex
path = zeros(1,length(cost));
maxCost = max(cost);
for i=1:length(cost)
    index = find(V(:,1)==(i-1));
    if i == length(cost)
        V = [V; [length(cost) + 2, length(cost)/2]];
        path = [path; zeros(1,length(cost))];
        finalVertex = size(V,1);
    end
    for j = 1:length(index)
        existingVertex = find(V(:,2) == V(index(j),2));
        existingVertex = existingVertex(find(V(existingVertex,1) == i));
        if isempty(existingVertex)
            V = [V; [i V(index(j),2)]];
            targetVertex = size(V,1);
            path = [path;path(index(j),:)];
            if i ==length(cost)
                edgeList = [edgeList; targetVertex finalVertex  maxCost];
            end
        else
            targetVertex = existingVertex(1);
        end
        edgeList = [edgeList; index(j) targetVertex maxCost];

        if V(index(j),2)+weight(i)<=maxWeight
            existingVertex = find(V(:,2) == V(index(j),2)+weight(i));
            existingVertex = existingVertex(find(V(existingVertex,1) == i));
            if isempty(existingVertex)
                V = [V; [i V(index(j), 2)+weight(i)]];
                targetVertex = size(V,1);
                path = [path;path(index(j),:)];
                path(size(path,1),i)=1;
                if i ==length(cost)
                    edgeList = [edgeList; targetVertex finalVertex  maxCost];
                end
            else
                targetVertex = existingVertex(1);
            end
            edgeList = [edgeList; index(j) targetVertex maxCost-cost(i)];

        end

    end
end

% Creation of the graph object
edgeListCell = mat2cell(edgeList,[ones(1,size(edgeList,1))],[ones(1,size(edgeList,2))]);
g = graph('edl',edgeListCell,'edgeDatatype',{'double'}, 'name', 'Knapsack');

% Setting up the position of verteces in the graphedit pane
for i = 1:length(g.N),
    g.N(i).GraphicParam{1}.x = 100+100*V(i,1);
    g.N(i).GraphicParam{1}.y = 100+40*V(i,2);
    g.N(i).UserParam = V(i,:);
    g.N(i).TextParam = [0 0; 30 -10];
    g.N(i).TextParam = [0 0; 0 0];
end

% graphedit(g,'viewnodesnames','off','viewnodesuserparams','on','fontsizeuserparams',8,'position',[100, 100, 800, 600]);
% graphedit('fit');

% floyd algorithm for searching the shortes path of the graph
[U P M] = floyd(g);
[temp lastVertex] = min(U(1, finalVertex+1:length(U)));
lastVertex = lastVertex + finalVertex;
usedSubject = find(path(lastVertex,:) == 1);
%% END ALGORITHM
if nargout > 1
    for i = 1:size(edgeList,1)
        edgeList(i,3) = maxCost - edgeList(i,3);
    end
% Creation of the output graph object
    edgeListCell = mat2cell(edgeList,[ones(1,size(edgeList,1))],[ones(1,size(edgeList,2))]);
    set(g, 'edl', edgeListCell);
    varargout(1) = {g};
end

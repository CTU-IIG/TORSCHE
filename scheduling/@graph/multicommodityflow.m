function [gmcf numberOfFlows] = multicommodityflow(g,s,t,b,pathFilter,varargin)
% MULTICOMMODITYFLOW is a function, which solves network problem with 
% multiple commodities flowing through the network(graph g).
%
%Synopsis
%         GMCF = MULTICOMMODITYFLOW(G,S,T,B,PATHFILTER)
%         GMCF = MULTICOMMODITYFLOW(G,S,T,B,PATHFILTER,LIMITATION)
%         GMCF = MULTICOMMODITYFLOW(G,S,T,B,PATHFILTER,LIMITATION,CAP)
%         GMCF = MULTICOMMODITYFLOW(G,S,T,B,PATHFILTER,LIMITATION,CAP,COST)
%         [GMCF NUMBEROFFLOWS] = MULTICOMMODITYFLOW(G,S,T,B,PATHFILTER,...)
%
%Description
% The function has eight inputs and one output parameters.
% First five inputs are necessary, graph - G,source nodes - S,
% sink nodes - T, B - quantity flows and PATHFILTER.
% Paramater pathFilter
% This parameter is select of function, which finds path thrue the graf,
% choice from strings:
%  'all' - function allpath, function looked for all the path in the
%  graph, without any limitation.
%  'allShortest' - function allpath, additionaly looked also for information
%  about the shortest path in the graph(minimum cost mcf problem).
%  'kShortest' - function kshortestpath, function looked for the shortest
%  path in the graph, in line with costs of edges.
%  'kMosteCap' - function kshortestpath, function looked for the most
%  capacity of edges, in line with capacity.
% Three unnecessary input parameter. 
% LIMITATION is a first unnecessary input parametr for choices pathReduced -
% KShortest and KMosteCap, mean number of path, which are used in MMCF. If
% it is not set up, default is 3. 
% CAP - Capability of edges.
% If you want to set up another parameter of edges you can choice
% the number of userParamPos for saving, default is 1.  
% COST is number of parameter, on which cost of edges are
% saved, default is 2.
% Outputs are GMCF -  graph object, which has saved, on userParamPosition,
% flows with theirs quantity and NUMBEROFFLOWS - number of found flows.
 
%  
%Example
% >> edgeList = {1 2,3;1 3,4;1 7,5;1 10,3;2 13,1;2 15,3;2 18,2;3 4,3;4 5,4;
% >> 5 6,3;6 9,4;6 12,5;7 8,5;8 9,5;9 12,9;10 12,2;10 14,5;11 12,3;13 14 1;...
% >> 14 22,2;15 16,4;16 17,5;17 22,3;18 19,1;19 15,3;19 20,5;20 21,8;21 22,3};
% >> g = graph('edl',edgeList,'edgeDatatype',{'double'});
% >> s = [1 2];
% >> t = [12 22];
% >> b = [3;3];
% >> limitation = 2;
% >> gmcf = multicommodityflow(g,s,t,b,'kMosteCap',limitation)
%
% See also GRAPH, GRAPH/ALLPATH, GRAPH/EDMONDSKARP, GRAPH/DINIC,
% GRAPH/KSHORTESTPATH, GRAPH/MAXMULTICOMMODITYFLOW


% Author: Elvira  Hanakova <hanake1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2938 $  $Date:: 2009-05-12 13:00:57 +0200 #$


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


maxUserParam = max(cellfun(@(x)length(x.UserParam),get(g,'E')));
biggerParam = maxUserParam;
if nargin > 5
    if isnumeric(varargin{1})
        limitation = varargin{1};
        limitation = round(limitation(1)); 
    end
else
      limitation = 3;
end 

if nargin > 6
    if isnumeric(varargin{1})
        cap = varargin{1};
        cap = round(cap(1)); 
    end
else
      cap = 1;
end

if nargin > 7
    if isnumeric(varargin{2})
        userParamPos = varargin{2};
        userParamPos = round(userParamPos(1));
        if userParamPos == cap
            disp ('TORSCHE:graph:sameParam',...
                'Capability and cost are the same parameter!');
        end
    end
elseif cap ~= 2 && maxUserParam > 1
       userParamPos = 2;
elseif strcmpi( pathFilter,'kShortest')||strcmpi( pathFilter,'allShortest')
    error ('TORSCHE:graph:sameParam',...
            'Cost is absent!');
else
    userParamPos = [];
end

f = 0;
if strcmpi( pathFilter,'all')
   [gap numberOfFlows amplFlows] = allpath(g,s,t,1);
elseif strcmpi( pathFilter,'allShortest') 
     f = 1;
     [gap numberOfFlows amplFlows] = allpath(g,s,t,1,userParamPos);
elseif strcmpi( pathFilter,'kShortest') 
    [gap numberOfFlows] = kshortestpath(g,s,t,'kShortest',1,limitation);
elseif strcmpi( pathFilter,'kMosteCap')
    [gap numberOfFlows] = kshortestpath(g,s,t,'kMosteCap',1,limitation);
else
    error ('TORSCHE:graph:wrongParam',...
            'input parameter pathReduced is wrong!');
end

edgeList = get(g,'edl');
edgeList = cell2mat(edgeList);
edgeNumber = length(g.E);
    
M = zeros(edgeNumber,sum(numberOfFlows));
for i = 1:size(M,1)
    for j = 1:size(M,2)
        M(i,j) = gap.E(i).userParam(j+biggerParam);
    end
end
           
N = zeros(size(t,2),size(M,2));
for i = 1:size(t,2)
    if i==1
       N(i,1:numberOfFlows(i))=1;
    else
       N(i,sum(numberOfFlows(1:i-1))+1:sum(numberOfFlows(1:i)))=1;
    end
end
if f == 0
   f = ones(size(M,2),1);
elseif f == 1
    f = amplFlows;
end
    
u = edgeList(:,2 + cap);
LB = zeros(size(M,2),1);
[y,fval,exitflag] = linprog(f,M,u,N,b,LB);

gmcf = gap;
if exitflag==1
    for i = 1:size(M,1)
        for j = 1:size(M,2)
            if gmcf.E(i).userParam(j+biggerParam) == 1
                gmcf.E(i).userParam{j+biggerParam} = y(j);
            end
        end
    end
else
    error('TORSCHE:graph:solutionnotexist',...
            'Solution not exist for required flows!');
end
end

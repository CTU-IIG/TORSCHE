function g=randdfg(n,m,degMax,ne,varargin)
%RANDDFG random Data Flow Graph (DFG) generator. 
%
% Synopsis
%   DFG=RANDDFG(N,M,DEGMAX,NE)
%   G=RANDDFG(N,M,DEGMAX,NE,NEH,HMAX)
%
% Description
%   DFG=RANDDFG(N,M,DEGMAX,NE) generates DFG, where N is the number
%   of nodes in the graph DFG, M is the number of dedicated
%   processors. Relation of node to a processor is stored in
%   'G.N(i).UserParam'. Parameter DEGMAX restricts upper bound
%   of outdegree of vertices. NE is number of edges. Resultant
%   graph is Direct Acyclic Graph (DAG).
%
%   G=RANDDFG(N,M,DEGMAX,NE,NEH,HMAX) generates cyclic DFG (CDFG),
%   where NEH is number of edges with parameter
%   '0 < G.E(i).UserParam <= HMAX'. Other edges has user parameter
%   'G.E(i).UserParam=0'.
%
% See also GRAPH/GRAPH, CYCSCH.

% Author: Premysl Sucha <suchap@fel.cvut.cz>
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


if(nargin==6)
    neh = varargin{1};
    hMax = varargin{2};
elseif(nargin==4)
    neh = 0;
    hMax = 0;
else
    error('Incorrectu number of parameters.');
end;

nodeProcessor=zeros(1,n);
graphEdge=zeros(n,n);
graphEdgeHeight=zeros(n,n);
nodeNames={};


%%%%%%%%%%%%%%% Generate names of nodes %%%%%%%%%%%%%%%
nodeNames={};
for(i=1:n)
   nodeNames{i}=sprintf('T_{%d}',i);
end;

initialVertexCounter=zeros(1,n);

%%%%%%%%%%%%%%% Generate edges with h=0 %%%%%%%%%%%%%%%
%Create set of candidates
edges=[];
for(i=1:n)
	for(j=1:n)
      if(j>i)
         edges=[edges [i;j]];         
      end;
   end;
end;

%Place edges
for(ne=1:ne)

   if(isempty(edges))
      error('Constraint ''degMax'' is too small.');
   end;
   
   k=ceil(size(edges,2)*rand(1));
   i=edges(1,k);   j=edges(2,k);
   graphEdge(i,j)=1;
   
   initialVertexCounter(i)=initialVertexCounter(i)+1;
   edges=edges(:,[1:(k-1) (k+1):size(edges,2)]);
   if(initialVertexCounter(i)>=degMax)
      edges=edges(:,setdiff(1:size(edges,2),find(edges(1,:)==i)));
   end;
   
end;


%%%%%%%%%%%%%%% Generate position of nodes %%%%%%%%%%%%%%%
% gLimited=graph('adj',graphEdge);
% for(i=1:length(gLimited.E))
%     gLimited.E(i).UserParam={-1};
% end;
% graphLP=min(floyd(gLimited),[],1);
% nodeXPos=-min(graphLP,0);
% nodeXPosition=40+nodeXPos*70;       %position x
% 
% histogram=zeros(1,n);
% nodeYPos=zeros(1,n);
% nodeYPosition=zeros(1,n);
% for(i=1:n)
%     xPos=nodeXPos(i)+1;
%     nodeYPos(i)=0;%histogram(xPos);
%     nodeYPosition(i)=40+nodeYPos(i)*70+mod(nodeXPos(i),2)*32;   %position y
% %    histogram(xPos)=histogram(xPos)+1;
% end;


%%%%%%%%%%%%%%% Generate edges with h>0 %%%%%%%%%%%%%%%
%Create set of candidates
for(i=1:n)
	for(j=1:n)
      if(j~=i & graphEdge(i,j)==0)
         edges=[edges [i;j]];        
      end;
   end;
end;

%Place edges  
for(ne=1:neh)
  
   if(isempty(edges))
      error('Constraint ''degMax'' is too small.');
   end;
   
   k=ceil(size(edges,2)*rand(1));
   i=edges(1,k);   j=edges(2,k);
   graphEdge(i,j)=1;
   graphEdgeHeight(i,j)=ceil(hMax*rand+0.00001);

   initialVertexCounter(i)=initialVertexCounter(i)+1;
   edges=edges(:,[1:(k-1) (k+1):size(edges,2)]);
   if(initialVertexCounter(i)>=degMax)
      edges=edges(:,setdiff(1:size(edges,2),find(edges(1,:)==i)));
   end;
   
end;

%%%%%%%%%%%%%%% Generate dedication of processors to tasks %%%%%%%%%%%%%%%
nodeProcessor=ceil(m*rand(1,n));
nodeProcessor=max(nodeProcessor,1);

%%%%%%%%%%%%%%% Create object GRAPH %%%%%%%%%%%%%%%
g=graph('adj',graphEdge);
g.Name='Graph automatically generated by function RANDDFG.';
g.UserParam.graphedit.nodeparams={'Processor'};


for(i=1:n)
    g.N(i).Name=nodeNames{i};
    g.N(i).UserParam={nodeProcessor(i)};
    
    tmp_node = g.N(i);
    tmp_node.Name = nodeNames{i};
    tmp_node.UserParam={nodeProcessor(i)};
%    set_graphic_param(tmp_node,'color',[0 1 0],'x',nodeXPosition(i),'y',nodeYPosition(i));
    g.N(i) = tmp_node;
end;
%TADY JE PROBLEM, JAKMILE SAHNU NA NEJAKY FIELD, UDELA SE Z NEJ
%CELL!!! - tyhle radky to vraci zpet
nodesArr=g.N;
nodesArr=[nodesArr{:}];
g.N=nodesArr;

%Add UserParam to edges
[k,l,foo]=find(graphEdge==1);
for(i=1:length(k))
    edgeNum = between(g,k(i),l(i));
    g.E(edgeNum).UserParam={graphEdgeHeight(k(i),l(i))};
end;
%TADY JE PROBLEM, JAKMILE SAHNU NA NEJAKY FIELD, UDELA SE Z NEJ
%CELL!!! - tyhle radky to vraci zpet
edgesArr=g.E;
edgesArr=[edgesArr{:}];
g.E=edgesArr;



% end .. randdfg

function [w]=criticalcircuitratio(varargin)
%CRITICALCIRCUITRATIO finds the minimal circuit ratio of the input graph.
%
% Synopsis
%   [w]=CRITICALCIRCUITRATIO(G)
%   [w]=CRITICALCIRCUITRATIO(L,H)
%
% Description
%   Minimal circuit ratio of the graph is defined as
%   w=min(L(C)/H(C)), where C is a circuit of graph G.
%   L(C) is sum of lengths L of the circuit C and H(C) is sum
%   of heights H of the circuit C.
%
%   [w]=CRITICALCIRCUITRATIO(G) finds minimal cycle ratio in graph G.
%   where length and height are specified in first and second user
%   parameter on edges (UserParam).
%
%   [w]=CRITICALCIRCUITRATIO(L,H) finds minimal circuit ratio in graph
%   where length and height of edges is specified in matrices L and H.
%     
%   See also GRAPH/GRAPH, GRAPH/FLOYD, GRAPH/DIJKSTRA.


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


na = nargin;
if na==1 && isa(varargin{1},'graph')
   g = varargin{1};
   n=size(g.N,2);                       %Number of graph nodes
   L = zeros(n);                        %Matrix of lengths
   H = zeros(n);                        %Matrix of heights
   adjng=adj(g);
   [x,y] = find(adjng==1);
   for i = 1: length(x)
       edge = g.E(between(g,x(i),y(i)));
       if(length(edge)~=1)
           error('Graph with parallel edges is not supported.');
       end;
       cost = edge(1).UserParam;
       if(length(cost)==0)
           l = 0;
           h = 0;
       end
       if(length(cost)==1)
           l= cost{1};
           h = 0;
       end
       if(length(cost)==2)
           l= cost{1};
           h = cost{2};
       end
       L(x(i),y(i)) = l;
       H(x(i),y(i)) = h;
   end
elseif(na==2 && isnumeric(varargin{1}) && isnumeric(varargin{2}))
   L=varargin{1};
   H=varargin{2};
   n=size(L,1);
   if(size(L,2)~=n | size(H,1)~=n | size(H,2)~=n)
       error('Matrices L and H must be N-by-N of the same size.');
   end;
else
    error('Input graph must by specified by object GRAPH or by matrices L and H.');
end


A=[];
b=[];
critEdges=[];
[k l]=find(L~=0);
for(i=1:length(k))
   aAct=zeros(1,n+1);
   aAct(k(i))=1;
%   aAct(l(i))=-1;	
   aAct(l(i))=aAct(l(i))-1;	
   aAct(1,n+1)=H(k(i),l(i));
   A=[A;-aAct];
   b=[b,(-L(k(i),l(i)))];
end;

%A solution using ilinprog from TORSCHE
f=zeros(1,n+1);	f(1,n+1)=1;         %Objective function
schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',0);
CTYPE(1:size(A,1))='L';
LB=-inf*ones(1,size(A,2));
UB=inf*ones(1,size(A,2));
VARTYPE(1:size(A,2))='C';
x=ilinprog(schoptions,1,f',A,b',CTYPE',LB',UB',VARTYPE');

%A solution using Optimization toolbox for Matlab
%x=linprog(f',A,b,[],[],[],[],[],options);

if(isempty(x))
    w=-inf;
else
    w=x(n+1);
end;

return;

%end .. @graph/criticalcircuitratio


function [G_FLOW, fmin] = mincostflow(varargin)
%MINCOSTFLOW finds the least cost flow in graph G.
%
% Synopsis
%   [G_FLOW, FMIN] = MINCOSTFLOW(G)
%   [G_FLOW, FMIN] = MINCOSTFLOW(U,C,D,N)
%
% Description
%   [G_FLOW, FMIN] = MINCOSTFLOW(G) finds the cheapest flow in graph G.
%   Prices in graph G, lower and upper bounds of flows are specified
%   in first, second and third user parameter on edges (UserParam).
%   The function returns graph G_FLOW, i.e. graph G enlarged with fourth user
%   parameter which contains amount of flow in every edge. FMIN contains
%   total cost.
%
%   [G_FLOW, FMIN] = MINCOSTFLOW(C,L,U,B) finds the same, but everything
%   without using graph, only matrixes. L is matrix of lower bounds, U means 
%   upper bounds of flows and C represents costs. Vector B is associated with nodes
%   and indicates whether it is supply or demand in each node to the network.
%   The function returns G_FLOW, matrix of minimal flows.
%
% See also GRAPH/GRAPH, ILINPROG, EDGES2MATRIXPARAM, MATRIXPARAM2EDGES.

% Author: Jindrich Jindra
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2905 $  $Date:: 2009-04-06 14:51:06 +0200 #$


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
if (na == 1 && isa(varargin{1},'graph'))
   g = varargin{1};
   n = size(g.N,2);                       %Number of graph nodes
   adj_g = adj(g);
   
   b=[];                                  %Create vector b (Ax=b)
   for(i=1:n)
       fixFlow=g.N(i).UserParam;
       b(i,1)=-fixFlow{1};
   end;
      
   A = zeros(size(inc(g)));
   
   price = [];
   cb = [];
   db = [];
   
   F = Inf*ones(size(adj_g,1),size(adj_g,2));
         
   [x,y] = find(adj_g == 1);
   
   for i = 1:length(x)
       
       edge = g.E(between(g,x(i),y(i)));
       if(length(edge)~=1)
           error('Graph with parallel edges is not supported.');
       end;
       params = edge(1).UserParam;
       
       if(length(params) == 3)
           price = [price params{1}];
           % check input parameters
           if (params{2} > params{3}) 
               error('Lower bound is higher than upper bound!');
           end;
           cb = [cb params{2}];
           db = [db params{3}];
           F(x(i),y(i)) = -1;
           A(x(i),i) = -1;
           A(y(i),i) = 1;
       else
           error('Not enough/too many params of edges.');
       end;
   end

else
   C = varargin{2};
   L = varargin{3};
   U = varargin{4};
   B = varargin{5};
   
   n = size(C,1);                       %Number of graph nodes
   if n ~= size(C,2) || ...
      n ~= size(L,1) || n ~= size(L,2) || ...
      n ~= size(U,1) || n ~= size(U,2) || ...
      n ~= size(B,1) || 1 ~= size(B,2)
      error('Size of input matrices is incorrect!');
   end
   
   b=-B;                                  %Create vector b (Ax=b)

   adjMatrix = double((C~=0 | L~=0 | U~=0) == 1);
   m = length(find(adjMatrix));
   
   A = zeros(n, m);
   
   g=graph(adjMatrix,0);
   
   price = [];
   cb = [];
   db = [];
   
   F = Inf*ones(size(adjMatrix,1),size(adjMatrix,2));
         
   [x,y] = find(adjMatrix == 1);
   
   for i = 1:length(x)       
       price = [price C(x(i),y(i))];
       % check input parameters
       if (L(x(i),y(i)) > U(x(i),y(i)))
           error('Lower bound is higher than upper bound!');
       end;
       cb = [cb L(x(i),y(i))];
       db = [db U(x(i),y(i))];
       F(x(i),y(i)) = -1;
       A(x(i),i) = -1;
       A(y(i),i) = 1;
   end
end


%%% Solution by ILP (LP) %%%
price = price';
cb = cb';
db = db';
sense = 1;    %type of optimalization: 1=minimalization, -1=maximalization
ctype=''; ctype(1:size(b,1),1)='E';
vartype=''; vartype(1:size(price,1),1) = 'C';

schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',0);
[xmin,fmin,status,extra] = ilinprog (schoptions,sense,price,A,b,ctype,cb,db,vartype);

if(status==1)
    %disp('Successful.');
	for i=1:size(F,1)
        for j=1:size(F,2)
            if (F(j,i) < 0) 
                F(j,i) = xmin(1);
                xmin = xmin(2:end);
            end;
        end;
	end;
    if (na == 1) 
        G_FLOW = matrixparam2edges(g,F,4);
    else
        G_FLOW = F;
    end;
else
    G_FLOW = [];
    fmin = [];
    %disp('Problem has not solution.');
end;

%end .. @graph/mincostflow

function g=hamiltoncircuit(g,varargin)
%HAMILTONCIRCUIT finds Hamilton circuit in graph
%
% Synopsis
%   G_HAM=HAMILTONCIRCUIT(G)
%   G_HAM=HAMILTONCIRCUIT(G,EDGESDIRECTION)
%
% Description
%   G_HAM=HAMILTONCIRCUIT(G) solves the problem for directed graph G.
%   Both G and G_HAM are Graph objects.
%   Route cost is stored in Graph_out.UserParam.RouteCost
%
%   G_HAM=HAMILTONCIRCUIT(G,EDGESDIRECTION) defines direction of edges, if
%   parameter EDGESDIRECTION is 'u' then the input graph is considered as
%   undirected graph. When the parametr is 'd' the input graph is considered as
%   directed graph (default).
% 
%   See also EDGES2PARAM, PARAM2EDGES, GRAPH/GRAPH, EDGES2MATRIXPARAM.


% Author: Pavel Mezera <Pavel.Mezera@Seznam.cz>
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


Edges = edges2matrixparam(g);
if(nargin==2 & length(varargin{1})==1 & varargin{1}=='u')
    % making all edges bidirectional
    Edges=min(Edges,Edges');
end;

% number of nodes
n = size(Edges,1);
% number of edges
e = length(find(Edges(:)~=Inf));
% delete loop edges - they are never in solution
Edges(sub2ind(size(Edges),1:size(Edges,2),1:size(Edges,2)))=Inf;
% find edges with finite cost and store their position in E_mat_index
Edges_index=find(Edges(:)~=Inf);
E_mat_index=zeros(n);
E_mat_index(Edges_index)=1:length(Edges_index);
E_mat_index_mod=E_mat_index(:,2:size(E_mat_index,2));
Et_mat_index=E_mat_index';
% number of edges ending diferent as in first node
m=length(find(E_mat_index_mod~=0));

% creating conditions matrix At and b vector
% LP conditions is x = min(c*x | x>lm and x<ly)
% where        At'*x = b
At=zeros(e+n,2*n+m);% is transponed
b=[ones(2*n,1);(n-1)*ones(m,1)];
% creating edge's weight and LP support vector
c=[Edges(Edges_index);zeros(n,1)];
% values of 1.part x vector(edges) must be Equal with coresponding part of b vector
% values of 2.part x vector(nodes) must be Less  than coresponding part of b vector
ctype=char([ones(2*n,1)*'E';ones(m,1)*'L']);
% all element of x vector are Integral numbers
vartype=char(ones(e+n,1)*'I');
lb=zeros(e+n,1);
ub=[ones(e,1);n*ones(n,1)];

% % % % % % % % % %
% constructing conditions matrix At
At(sub2ind(size(At),E_mat_index(find(E_mat_index(:)~=0)),mod(find(E_mat_index(:)~=0)-1,n)+1))                   = 1;
At(sub2ind(size(At),Et_mat_index(find(Et_mat_index(:)~=0)),mod(find(Et_mat_index(:)~=0)-1,n)+n+1))              = 1;
At(sub2ind(size(At),E_mat_index_mod(find(E_mat_index_mod(:)~=0))',(1:length(find(E_mat_index_mod(:)~=0)))+2*n)) = n;
[from,to]=ind2sub(size(E_mat_index),find(E_mat_index_mod));
At(sub2ind(size(At),from'+e,(1:m)+2*n))= 1;
At(sub2ind(size(At),to'+e+1,(1:m)+2*n))=-1;

% solving with LP solver
sense=1; %minimalize
schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',1);
[xmin,fmin,status,extra] = ilinprog (schoptions,sense,c,At',b,ctype,lb,ub,vartype);

% process result
if(status==1)
    Edges(Edges_index(find(xmin(1:e)==0)))=Inf;
else
    Edges=Inf*ones(n);
    fmin=Inf;
end;
% export solution
g=edgesrearrange(g,Edges,1,Inf,'a');
g.UserParam.RouteCost=[fmin];

%end .. HAMILTONCIRCUIT

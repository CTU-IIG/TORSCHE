function [U,varargout]=floyd(varargin)
%FLOYD finds a matrix of shortest paths for given digraph
%
%Synopsis
% [U[,P[,M]]]=FLOYD(G) 
%
%Description
% The lengths of edges are set as UserParam in object edge included in G.
% If UserParam is empty, length is Inf. 
% 
% Parameters:
%  G:
%    - object graph
%  U:
%    - matrix of shortest paths; if U(i,i)<0 then the digraph contains a
%      cycle of negative length!
%  P:
%    - matrix of the vertex predecessors in the shortest path
%  M:
%    - Adjacency Matrix of lengths
%  
%  Note: All matrices have the size nxn, where n is a number of vertices.
%     
%  See also GRAPH/GRAPH, GRAPH/DIJKSTRA, GRAPH/CRITICALCIRCUITRATIO.

%TODO: Matrix on input. Corrected code for floyd_original(A).

% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Author: Zdenek Hanzalek
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
   graph = varargin{1};
   v_adj = adj(graph);
   M = inf*ones(size(v_adj));
   %TODO: test that graph is a simple "prosty" 
   [x,y] = find(v_adj==1);
   for i = 1: length(x)
       edge = graph.E(between(graph,x(i),y(i)));
       cost = edge.UserParam;
       if isempty(cost), cost = inf; end
       if iscell(cost), cost = cost{1}; end
       if ~isnumeric(cost), error('Lenght of edges must be numeric.'); end
       M(x(i),y(i)) = cost;
   end
elseif na==1 && isnumeric(varargin{1})
   M = varargin{1};
else
    error('Invalid input');
end

[U,P] = floyd_original(M);
varargout(1) = {P};
varargout(2) = {v_adj};



function [U,P] = floyd_original(A)
% [U,P] = floyd(A)
% function floyd finds a matrix of shortests paths for given digraph 
% (see Jiri Demel, Grafy, page 69) 
% A - 	Adjacency Matrix of lengths (A(i,j) means length of the 
% oriented arc from vertex i to vertex j; A(i,i)=0; A(i,j) is in 
% (-Inf,Inf); A(i,j)=Inf if there is no arc from vertex i to vertex j)
% U - 	matrix of shortest paths (if U(i,i)<0 then the digraph contains a cycle of negative length)
% P - 	matrix of the vertex predecessors in the shortest path
% all matrices have the size nxn
% hanzalek@fel.cvut.cz
[n,nofc]=size(A);
M=A;
error=0;
if (n~=nofc) 
	sprintf('!!!! Input matrix is not square')
	error=1;
end

if (error==0)
    %initialize matrix of predcessors
    P=zeros(n,n);
    for i=1:n
        for j=1:n
            if ((i~=j) & (M(i,j)~=inf))
                P(i,j)=i;
            end
        end
    end

    %calculate shortest paths
    for k=1:n                   %take in consideration the k-th vertex
        for i=1:n 				%for all rows
            for j=1:n 			%for all columns
                if (M(i,j)>M(i,k)+M(k,j))       %compare length of exsiting path with the length of the path over k-th vertex
                    M(i,j)=M(i,k)+M(k,j);		%change the length
                    P(i,j)=P(k,j);              %change the predcessor
                end
            end
        end
    end
end;        %endif
U=M;

%end of file

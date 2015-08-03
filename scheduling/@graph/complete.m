function gcomplete = complete(g,varargin)
% COMPLETE is a function, which extends graph to complete graph.
%
% Synopsis
%   GCOMPLETE = COMPLETE(G)
%   GCOMPLETE = COMPLETE(G,PRESERVEEDGE)
%
% Description
% This function makes a complete graph. Makes edges from every node to
% every node.
% Function complete has two inputs a one output. First inputs,necessary,
% is a graph - G. Second input parameter is unnecessary and it is a list of
% edges, which we want to keep. Output GCOMPLETE is a graph G with a new
% edges.  
%
% Example
% >> adjmat = diag(ones(1,6));
% >> adjmat = [adjmat(:,end) adjmat(:,1:end-1)];
% >> g = graph('adj',adjmat,'name','graph');
% >> g.E(1:2:end).color = 'r';
% >> g.E(2:2:end).color = 'g';
% >> g.E(:).LineWidth = 3;
% >> gc = complete(g,[1 2 4 5]);
% >> gc.Name = 'complete gr.';
% >> graphedit(g,gc)
%
% See also GRAPH/GRAPH, GRAPH/DISTANCE, GRAPH/CHRISTOFIDES


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


gcomplete = g;
edgeList = get(gcomplete,'edl');
edgeList = cell2mat(edgeList);
if nargin==1
    gcomplete = removeedge(gcomplete,1:length(gcomplete.E));
    adj = triu(ones(length(gcomplete.N)),1);
elseif nargin==2
    preservedEdges = varargin{1};
    maxPreservedEdges = max(preservedEdges);
    if maxPreservedEdges > size(edgeList,1)
       error('TORSCHE:graph:wronginputparam',...
            'Wrong second input parameter!');
    end
    edgeindex = zeros(1,size(edgeList,1));
    edgeindex(preservedEdges) = 1;
    delEdges = find(edgeindex==0);
    gcomplete = removeedge(gcomplete,delEdges);
    adj = get(gcomplete,'adj');
    adj = ((adj+adj').*triu(ones(length(adj)),1)==0).*triu(ones(length(adj)),1);
else
    error('TORSCHE:graph:wronginputparam',...
            'Input parameters can be maximum 2!');
end
[from,to]=find(adj);
gcomplete = addedge(gcomplete,from,to);
end

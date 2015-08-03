function isSimple = issimple(g,varargin)
%ISSIMPLE   True for simple graph (graph without parallel edges)
%
%       ISSIMPLE(G) returns 1 if G is a simple graph and 0 otherwise.
%       Graph G can be represented by object GRAPH or adjacency matrix.
%
%       ISSIMPLE(graph,ADJ) returns logical 1 if ADJ represents graph
%       without parallel edges and logical 0 otherwise. ADJ is adjacency
%       matrix of graph.
%
%
%   See also GRAPH, ISSELFLOOP, ISCYCLIC.


% Author: Vojtech Navratil <navrav1@fel.cvut.cz>
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


    if nargin == 1 && isa(g,'graph')
        adjMatrix = get(g,'adj');       % getting of adjacency matrix    
    elseif nargin == 2 && isa(varargin{1},'double')
        adjMatrix = varargin{1};    
    else
        error('Input graph must be specified by object GRAPH or by adjacency matrix.');
    end

    isSimple = true;
    if find(adjMatrix > 1)
        isSimple = false;
    end
    
%end .. @graph/issimple

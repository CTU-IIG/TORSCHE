function varargout = between(G,varargin)
%BETWEEN   Return number of edges between initial and terminal nodes of
%graph or number of initial and terminal node of the edge
%
%Synopsis
%    edge = BETWEEN(G,IN,TN)
%    [IN,TN] = BETWEEN(G,edge)
%
%Description
% Parameters:
%  G:
%    - object graph
%  IN:
%    - vector of initial node indices or char arraye of initial node name
%  TN:
%    - vector of terminal node indices or char arraye of terminal node name
%  edge:
%    - edge indices
%
%Example
% >> g = graph('adj',[0 0 1 0;1 0 0 1;0 1 0 0;0 0 1 0]);
% >> edges = between(g,[1 4],[3])
% >> [from,to] = between(g,edges)
%    from =
%         1
%         4
%    to =
%         3
%         3
%
% See also GRAPH/GRAPH, GRAPHEDIT


% Author: Vojtech Navratil <navrav1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2902 $  $Date:: 2009-03-26 13:51:56 +0100 #$


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


if nargin == 3,
    IN = varargin{1};
    TN = varargin{2};
    if ischar(IN)
        if length(get(G,'N')) > 1
            GNames = char(cellfun(@(x)x.Name,get(G,'N'),'UniformOutput',false));
        else
            GNames = G.N(1).Name;
        end
        INp = [];
        for i = 1:size(IN,1)
            INp = [INp strmatch(IN(i,:), GNames, 'exact')]; %#ok<AGROW>
        end
        IN = INp;
        TNp = [];
        for i = 1:size(TN,1)
            TNp = [TNp strmatch(TN(i,:), GNames, 'exact')]; %#ok<AGROW>
        end
        TN = TNp;
    end
    
    INn = zeros(size(G.eps,1),1);
    for nIN = 1:length(IN)
        INn = INn | G.eps(:,1) == IN(nIN);
    end
    TNn = zeros(size(G.eps,1),1);
    for nTN = 1:length(TN)
        TNn = TNn | G.eps(:,2) == TN(nTN);
    end
    varargout{1} = intersect(find(INn),find(TNn));
elseif nargin == 2,
    edge = varargin{1};
    IN = G.eps(edge,1);
    TN = G.eps(edge,2);
    varargout{1} = IN;
    varargout{2} = TN;
end

%end .. @graph/between

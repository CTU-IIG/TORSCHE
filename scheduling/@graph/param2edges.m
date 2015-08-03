function g = param2edges(g,param,varargin)
%PARAM2EDGES  adds user parameters to graph edges from an input cell matrix.
%
%  g = PARAM2EDGES(graph,userparam)
%    g         - object graph
%    userparam - cell matrix with user params of edges. If there is an
%                edge e(i,j) in 'g' the 'UserParam{1}' of the edge will
%                be set to the first element of userparam{i,j}. See an
%                example below.
%
%  g = PARAM2EDGES(graph,userparam,N)
%    g         - object graph
%    userparam - cell matrix with user params of edges. If there is an
%                edge e(i,j) in 'g' the 'UserParam{N}' of the edge will
%                be set to the first element of userparam{i,j}.
%    N         - position in UserParam of edge e(i,j).
%
%Example:
%  g = graph('inc',[1 1;-1 -1])
%  userparam = {[] {'a' 2};[] []}
%  g = param2edges(g, userparam)
%  g = param2edges(g, userparam, 2)
%
%  See also TASKSET, GRAPH.


% Author: Michal Kutil <kutilm@fel.cvut.cz>
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


try
    paramCat = 1;
    if nargin >= 3
        paramCat = varargin{1};
        if isempty(paramCat)
            paramCat = 1;
        end
    end

    for from = 1 : size(param,1)
        for to = 1 : size(param,2)
            edges = between(g,from,to);                                 %get edges between node 'from' and 'to'
            for n = 1 : min(length(param{from,to}),length(edges))       %for all parallel edges between node 'from' and 'to'
                param_items = param{from,to};
                if iscell(param_items)
                    param_tmp = param_items{n};
                    for m = 1:length(param_tmp)                         %fill succeding positions in 'UserParam' also
                        if iscell(param_tmp)
                            g.E(edges(n)).UserParam{paramCat+m-1} = param_tmp{m};
                        else
                            g.E(edges(n)).UserParam{paramCat+m-1} = param_tmp;
                        end
                    end
                else
                    g.E(edges(n)).UserParam{paramCat} = param_items;
                end
            end
        end
    end
catch
    %rethrow(lasterror);
    error('Invalid param format!');
end


%end .. @graph/param2edges

function g = distance(g,varargin)
% DISTANCE is function, which complete the weight of edges to the graph.
%
% Synopsis
%   G = DISTANCE(G)
%   G = DISTANCE(G,USERPARAMPOSITION)
%   G = DISTANCE(G,USERPARAMPOSITION,PRESERVEUSERPARAM)
%
% Description
% Function distance completes graph by the weights of edges. This weights
% of edges are computed from the x and y possition both of nodes, which 
% edge connects. Is possible to use it only for graphs, which have set this
% position.
% This function has three inputs parameters, graph G and two unnecessary
% parameters. First input is graph G. Second input parameter is number of
% parameter, on which weigths of edges are saved. 
% Third input is a list of edges, for which is not necessary to count
% a weigth. Output is a graph G with a new weigths.
%
% Example
% >> g = graph('adj',[0 1 1;0 0 1;0 0 0],'name','graph');
% >> position = 100+40*[0 0; 3 0; 3 4];
% >> for i = 1:length(g.N)
% >>     g.N(i).GraphicParam(1).x = position(i,1);
% >>     g.N(i).GraphicParam(1).y = position(i,2);
% >> end
% >> g.E(3).UserParam(1)=180;
% >> gd=distance(g,1,3);
% >> gd.Name = 'distance gr.';
% >> graphedit(gd)
%
% See also GRAPH, GRAPH/COMPLETE, GRAPH/CHRISTOFIDES, GRAPH/MWPM


% Author: Elvira  Hanakova <hanake1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2904 $  $Date:: 2009-03-30 17:05:26 +0200 #$


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


% check of the input parameters
if nargin > 1
    if isnumeric(varargin{1})
        userParamPos = varargin{1};
        userParamPos = round(userParamPos(1));
    else
        error ('TORSCHE:graph:wrongparamtype',...
            'Second parameter must be numerical!');
    end
else
    userParamPos = 1;
end
if nargin > 2
    preserveuserparam = varargin{2};
else
    preserveuserparam = [];
end 

edges = g.eps;
for i = 1:length(g.E)
    if ~any(preserveuserparam == i)
        x1 = g.N(edges(i,1)).GraphicParam(1).x;
        y1 = g.N(edges(i,1)).GraphicParam(1).y;
        x2 = g.N(edges(i,2)).GraphicParam(1).x;
        y2 = g.N(edges(i,2)).GraphicParam(1).y;
        if isempty(x1)||isempty(x2)||isempty(y1)||isempty(y2)
            error('TORSCHE:graph:noposition',...
                'This functions is not possible to use, graph does not has satisfactory parameters!');
        end
        weight = sqrt(((x1-x2)^2)+((y1-y2)^2));
        if isnumeric(g.E(i).userParam)
            g.E(i).userParam(userParamPos) = weight;
        elseif iscell(g.E(i).userParam)
            g.E(i).userParam{userParamPos} = weight;
        else
            error('TORSCHE:graph:datatypeincorect',...
                'Incorrect datatype of UserParam for edge weight setting!');
        end
    end
end

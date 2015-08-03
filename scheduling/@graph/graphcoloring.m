function g = graphcoloring(g,varargin)
%GRAPHCOLORING  algorithm for coloring graph by minimal number of colors.
%
% Synopsis
%    G2 = GRAPHCOLORING(G1,USERPARAMPOSITION)
%
% Description
%    The function returns coloured graph. Algortihm sets color (RGB) of
%    every node for graphic view and save it to UserParam of nodes as appropriate
%    value representing the color. Input parameters are:
%      G1:
%               - input graph
%      USERPARAMPOSITION:
%               - position in UserParam of Nodes where number
%                 representative color will be saved. This parameter is
%                 optional. Default is 1.
%
%  See also GRAPH/GRAPH, GRAPHEDIT.


% Author: Z. Prokupek
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

 

    if ~isa(g,'graph'),
        error('Graph object is required as input parameter.');
    end

    if isselfloop(g),
        error('There is a loop in graph. Coloring is not possible.');
    end
    
    if nargin > 1
        userParamPosition = varargin{1};
    else
        userParamPosition = 1;
    end
    n = size(g.N,2);
    allColors = 1:n;

    matrix = directed2undirected(get(g,'adj'));
    list = prepairlist(matrix);

%------------------- start GraphColoring -------------------------------

    % 1st: coloring of the first node
    k = 1;
    list(1).Color = 1;
    restrict = n + 1;
    goto = 2;
    colorList = zeros(1,n);
    
    while (goto ~= 6)    
        % 2nd: trying to colour next node
        while (goto == 2)
            k = k + 1;
            if k > n 
                goto = 3;
                break;
            else
                list(k).Color = getthismincolor(k,list,allColors);        
            end
            if list(k).Color >= restrict
                y = k;
                goto = 4;
                break;
            else
                goto = 2;
            end    
        end   
        % 3rd: assigning of colours
        if (goto == 3)   
            for i = 1:n
                colorList(i) = list(i).Color;
            end
            restrict = max(colorList);
            i = 1;
            while ~(restrict == list(i).Color)
                i = i + 1;
            end
            y = i;
            goto = 4;
        end    
        % 4th: attempt to lower color
        if (goto == 4)
            if isempty(list(y).Predecessors)
                k = 1;
            else
                k = list(y).Predecessors(1,end);
            end
            goto = 5;
        end
        % 5th: attempt to heighten color
        if (goto == 5)
           if k ~= 1
               b = getnextmincolor(k,list,allColors);           
               if (b < restrict) && (b <= k)
                   list(k).Color = b;
                   goto = 2;
               else
                   k = k - 1;
                   goto = 5;
               end
           else
              goto = 6; 
           end         
        end    
    end

%--------------------- end GraphColoring -------------------------------        

    clrRGB = colorfromcolormap(max(colorList))';

    % output to graph object
    for i = 1:n,
        tmp_node = g.N(i);
        
        tmp_node.UserParam = cell(1);
        tmp_node.UserParam{userParamPosition} = colorList(i);
        tmp_node.Color = clrRGB(:,colorList(i))';
                              
        g.N(i) = tmp_node;
    end
       
%end .. graphcoloring

%================================================================       

    function minColor = getthismincolor(index,list,allColors)
        for i = 1:length(list(index).Predecessors),
            indexPred = list(index).Predecessors(i);
            allColors(list(indexPred).Color) = Inf;
        end
        minColor = min(allColors);
        
%================================================================   
        
    function minColor = getnextmincolor(index,list,allColors)
        allColors(allColors <= list(index).Color) = Inf;
        minColor = getthismincolor(index,list,allColors);
        
%================================================================   

    function adjMatrix = directed2undirected(adjMatrix)
        n = size(adjMatrix,1);
        for i = 1:n,
            for j = 1:n,
                if (adjMatrix(i,j) ~= 0) &&...
                   (adjMatrix(i,j) ~= adjMatrix(j,i))
                    adjMatrix(j,i) = adjMatrix(i,j);
                end               
            end
        end
           
%================================================================   

    function list = prepairlist(adjMatrix)
        n = size(adjMatrix,1);
        list(n) = struct('Color',0,'Predecessors',[]);
        for i = 1:n,
            list(i).Predecessors = find(adjMatrix(i,1:i));
        end

function g = param2edge(g,param,varargin)
%PARAM2EDGE  add to graph's user parameters datas from cell or matrix.
%
% Synopsis
%    graph = PARAM2EDGE(graph,userparam)
%    graph = PARAM2EDGE(graph,userparam,i)
%    graph = PARAM2EDGE(graph,userparam,i,notedgeparam)
%
% Description
%    graph = PARAM2EDGE(graph,userparam)
%      graph        - object graph
%      userparam    - matrix (simple graph and just 1 parameter in matrix) or
%                     cell (parallel edges or several parameters) with user
%                     params for edges.
%
%    graph = PARAM2EDGE(graph,userparam,i)
%      graph        - object graph
%      userparam    - matrix or cell with user params for edges
%      i            - i-th position of 1st value cell of new params (new
%                     UserParams replace original UserParams).
%
%    graph = PARAM2EDGE(graph,userparam,i,notedgeparam)
%      graph        - object graph
%      userparam    - matrix or cell with user params for edges
%      i            - i-th position of 1st value cell of new params (new
%                     UserParams replace original UserParams).
%      notedgeparam - defines value of user parameter for missing edges.
%                     This value is used for checking consistence between 
%                     graph and matrix userparam (default is INF).
%
%  See also GRAPH/EDGE2PARAM, GRAPH/GRAPH.


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


    if(nargin>=3)
        paramCat = varargin{1};     %Order of the input data in UserParam
    else
        paramCat = 1;
    end;

	try
	
        if iscell(param)
	
            g = param2edges(g,param,varargin{:});   
            
            % test of data types
            dataTypes = g.DataTypes.edges;
            edges = g.E;
            for i = 1:length(edges)
                for j = 1:length(dataTypes)
                    if ~isempty(dataTypes{j}) && ~isa(edges(i).UserParam{j},dataTypes{j})
                        error('Value of parameter doesn''t match data type.');
                    end
                end
            end
            
        else
        
            g = matrixparam2edges(g,param,varargin{:});
            g.DataTypes.edges{paramCat} = 'double';
            
        end
        
	catch
        rethrow(lasterror);
	end

%end .. @graph/param2edge    

function g = param2node(g,param,varargin)
%PARAM2NODE  add to user parameters to graph nodes from a cell or a matrix.
%
% Synopsis
%    g = PARAM2NODE(g,param)
%    g = PARAM2EDGE(g,param,N)
%
% Description
%    g = PARAM2NODE(g,param)
%      g         - object graph 
%      userparam - array (a matrix or a cell) with user params for nodes.
%                  For more detail see example below.
%
%    g = PARAM2EDGE(g,param,N)
%      g         - object graph
%      userparam - array (a matrix or a cell) with user params for nodes.
%                  For more detail see example below.
%      N         - position in UserParam of graph nodes.
%
%Example
%  g = graph([Inf 1; Inf Inf])
%  g2 = param2node(g,{[1 2] [3 4]})
%  g2 = param2node(g2,[10 20],2)
%  g2.N(1).UserParam
%  
%
%  See also GRAPH/NODE2PARAM, GRAPH/GRAPH, GRAPH/EDGE2PARAM, GRAPH/PARAM2EDGE.


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


if nargin > 2
    n = varargin{1};
    if length(n) > 1
        n = n(1);
    end
else
    n = 1;
end

try

    if length(g.N) ~= length(param)
        error('Number of parameters doesn''t match number of nodes in the graph.');
    end

    dataTypes = g.DataTypes.nodes;

    if iscell(param)

        [g.N,dataTypes] = setcellparams(g.N,param,dataTypes,n);

    else

        [g.N,dataTypes] = setarrayparams(g.N,param,dataTypes,n);
        g.DataTypes.nodes{n} = 'double';

    end

catch
    rethrow(lasterror);
end


%end .. @graph/param2node


%=======================================================================

function [nodes,dataTypes] = setarrayparams(nodes,param,dataTypes,n)

    if isempty(dataTypes) || isempty(dataTypes{n}) || dataTypes{n} == 'double' 
        
        for i = 1:length(nodes)
            nodes(i).UserParam{n} = param(i);
        end
        
    else
        error('Data type of parameter doesn''t match with value.');
    end

%=======================================================================

function [nodes,dataTypes] = setcellparams(nodes,param,dataTypes,n)
   
    numDataTypes = length(dataTypes);
    for i = 1:length(nodes)
        param_tmp = param{i};
        if iscell(param_tmp)
            for j = 1:length(param_tmp)
                if isempty(dataTypes) || numDataTypes < (n+length(param_tmp)-1) ||...
                   isempty(dataTypes{n+j-1}) || isa(param_tmp{j},dataTypes{n+j-1})
                    nodes(i).UserParam{n+j-1} = param_tmp{j};
                else
                    nodes(i).UserParam{n+j-1} = paramconversion(param_tmp{j},dataTypes{n+j-1});
                    warning('TORSCHE:graph:conversionDataTypesPermformed',...
                        'Value of parameters doesn''t match witch data type. Conversion was performed.');               
                end
            end
        else
            if isempty(dataTypes) || numDataTypes < n ||...
               isempty(dataTypes{n}) || isa(param_tmp,dataTypes{n})
                nodes(i).UserParam{n} = param_tmp;
            else
                nodes(i).UserParam{n} = paramconversion(param_tmp,dataTypes{n});
                warning('TORSCHE:graph:conversionDataTypesPermformed',...
                        'Value of parameters doesn''t match witch data type. Conversion was performed.');               
            end
        end
    end

%=======================================================================

function value = paramconversion(value,dataType)
	switch dataType
        case 'double'
            value = double(value);
        case 'logical'
            value = logical(value);
        case 'cell'
            value = cell(value);
        case 'struct'
            value = struct(value);
        case 'char'
            value = char(value);
        otherwise
            value = eval([dataType '([])']);
	end

%=======================================================================
    

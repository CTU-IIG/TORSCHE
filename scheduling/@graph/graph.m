function graph = graph(varargin)
%GRAPH  creates the graph object.
%
% Synopsis
%   G = GRAPH(Aw[[,noEdge],'Property name',value,...])
%   G = GRAPH('adj',A[,'Property name',value,...])
%   G = GRAPH('inc',I[,'Property name',value,...])
%   G = GRAPH('edl',edgeList[,'edgeDatatype',dataTypes][,'Property name',value,...])
%   G = GRAPH('ndl',nodeList[,'nodeDatatype',dataTypes][,'Property name',value,...])
%   G = GRAPH('ndl',nodeList,'edl',edgeList[,'nodeDatatype',dataTypes]
%             [,'edgeDatatype',dataTypes][,'Property name',value,...])
%   G = GRAPH(TASKSET[,KW,TransformFunction[,Parameters]])
%   G = GRAPH(GRAPH[,'edl',edgeList][,'ndl',nodeList])
%
%
% Description
%  G = GRAPH(...) creates the graph from ordered data structures.
%
%  Parameters:
%   Aw:
%     - Matrix of edges weigths (just for simple graph) 
%   noEdge:
%     - Value of weigth in place without edge. Default is inf. 
%   A:
%     - Adjacency matrix
%   I:
%     - Incidency matrix
%   edgeList:
%     - List of edges (cell): initial node, terminal node, user parameters 
%   nodeList:
%     - List of nodes (cell): number of node, user parameters 
%   dataTypes:
%     - Cell of data types
%   Name:
%     - Name of the graph - class char
%   UserParam: 
%     - User-specified data
%   Color:
%     - Background color of graph in graphical projection
%   GridFreq:
%     - Sets the grid of graph in graphical projection - [x y]
%
%   G = GRAPH(TASKSET[,KW,TransformFunction[,Parameters]]) creates a graph
%   from precedence constrains matrix of set of tasks:
%    TASKSET:
%      - Set of tasks 
%    KW:
%      - Keyword - define type of TransformFunction: 
%                    't2n' - task to node transfer function;
%                    'p2e' - taskset's TSuserparams to edge's userparam
%    TransformFunction:
%      - Handler to a transform function, which transform tasks to nodes
%        (resp. TSuserparam to userparam). If the variable is empty,
%        standart function 'task/task2node' and 'graph/param2edge' are
%        used.
%    Parameters:
%      - Parameters for transform function, frequently used for users
%        selecting and sorting tasks parameters for setting userparameters
%        of nodes. Parameters are colected to one parameter as cell before
%        calling the transform function.
%
%   G = GRAPH(GRAPH[,'edl',edgeList][,'ndl',nodeList]) adds edges or/and
%   nodes to existing graph:
%    GRAPH:
%      - Existing graph object 
%    edgeList:
%      - List of edges: initial node, terminal node, user parameters
%    nodeList:
%      - List of nodes: number of node, user parameters
%       
% Example
%   >> Aw = [4 3 0; 0 0 5; 1 2 3]
%   >> g = graph(Aw,0,'Name','g1')
%   >> dataTypes = {'double','double','char'}
%   >> edgeList = {1,2, 35,[5 8],'edge1'; 2,3, 68,[2 7],'edge2'}
%   >> g = graph('edl',edgeList,'edgeDatatype',dataTypes)
%   >>
%   >> g = graph(T,'t2n',@task2node,'proctime','name','p2e',@param2edges) 
%
% See also TASKSET/TASKSET, TASK/TASK2NODE, TASK/TASK2USERPARAM, GRAPH/PARAM2EDGE.
%

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

    

    E = [];    N = [];    eps = [];
    edgeList = [];    nodeList = [];
    cellOfEdgeDataTypes = [];    cellOfNodeDataTypes = [];
       
    name = '';
    userparam = [];
    color = [];
    gridfreq = [];

    nodeListWords = {'ndl','nodelist','nodeslist'};
    edgeListWords = {'edl','edgelist','edgeslist'};
    nodeDataTypesWords = {'nodeuserparamdatatype','nodesuserparamdatatype','nodesdatatype','nodedatatype','nodedatatypes','nodesdatatypes','ndt'};
    edgeDataTypesWords = {'edgeuserparamdatatype','edgesuserparamdatatype','edgesdatatype','edgedatatype','edgedatatypes','edgesdatatypes','edt'};
    
%--------------------------------------------------------------------------
    % from graph
    if nargin==3
    	if isa(varargin{1},'graph') && ischar(varargin{2}) 
        	graph = set_helper(varargin{:});
        	return;
    	end
    end
    
    if nargin >= 1 && isa(varargin{1},'graph'),
        
        graph = varargin{1};
        if nargin > 1,
            % odd number of arguments
            if mod(length(varargin),2) ~= 1
            % input args have not com in pairs, woe is me
            error('Arguments must come param/value in pairs.');
                    
            % adding edges or nodes from edgeList or nodeList
            else
                dataTypes = graph.DataTypes;
                for i = 2:2:length(varargin)                
                    if ~isempty(varargin{i+1}) && ~iscell(varargin{i+1})
                        error('Invalid data type was ordered.');
                    end
                    switch lower(varargin{i})
                        
                        case edgeListWords
                            edgeList = varargin{i+1};
                            [isOK,eL] = testofdatatypes(edgeList(:,3:end),dataTypes.edges);
                            if ~isOK
                                error('TORSCHE:graph:invalidDataTypes', 'Parameters in list does not match datatypes.');
                            end
                            graph = addedges(graph,edgeList);
                            
                        case nodeListWords       
                            nodeList = varargin{i+1};
                            if (min([nodeList{:,1}]) < length(graph.N))
                                error('It''s not possible re-write nodes in existing graph.');
                            end
                            [isOK,nL] = testofdatatypes(nodeList(:,2:end),dataTypes.nodes);
                            if ~isOK
                                error('TORSCHE:graph:invalidDataTypes', 'Parameters in list does not match datatypes.');
                            end
                            graph = addnodes(graph,nodeList);
                            
                        case edgeDataTypesWords
                            [isOK,E] = testofdatatypes(graph.E,varargin{i+1});
                            if isOK
                                graph.DataTypes.edges = varargin{i+1};
                            else
                                error('Parameters in list do not match datatypes.');
                            end

                        case nodeDataTypesWords
                            [isOK,N] = testofdatatypes(graph.N,varargin{i+1});
                            if isOK
                                graph.DataTypes.nodes = varargin{i+1};
                            else
                                error('Parameters in list do not match datatypes.');
                            end
                            
                        otherwise
                            error(['Unknown parameter name passed to GRAPH.  Name was ' varargin{i} '.']);
                    end
                end
            end
        end
        % name nodes
        graph.N = setnames(graph.N,'T');
        return;
    end    
    
%--------------------------------------------------------------------------
    % from taskset
    if nargin >= 1 && isa(varargin{1},'taskset')

        [E,N,eps,T,...
         conversion_function1,conversion_param1,...
         conversion_function2,conversion_param2] = fromtaskset(varargin{:});
 
%--------------------------------------------------------------------------  
    % from weighted adjecency matrix
    elseif nargin >= 1 && isa(varargin{1},'double')
        start = nargin + 1;
        
        if nargin >= 2 && isa(varargin{2},'double')
            emptyValue = varargin{2};
            if nargin > 2,
                if mod(nargin,2) ~= 0,    % input args have not com in pairs, woe is me
                    error('Arguments must come param/value in pairs.');            
                else
                    start = 3;
                end
            end
        else
            emptyValue = Inf;
            if nargin > 1,
                if mod(nargin,2) ~= 1,    % input args have not com in pairs, woe is me
                    error('Arguments must come param/value in pairs.');            
                else
                    start = 2;
                end
            end
        end

        for i = start:2:length(varargin)
            switch lower(varargin{i})
                case 'name'
                    if ischar(varargin{i+1}),
                        name = varargin{i+1};
                    else
                        error('Invalid data for parameter ''Name''.');
                    end

                case 'userparam'
                    userparam = varargin{i+1};

                case 'color'
                    if iscolor(varargin{i+1}),
                        color = varargin{i+1};
                    else
                        error('Invalid data for parameter ''Color''.');
                    end

                case 'gridfreq'
                    if isnumeric(varargin{i+1}) &&...
                       size(varargin{i+1},1) == 1 && size(varargin{i+1},2) == 2,
                        gridfreq = varargin{i+1};
                    else
                        error('Invalid data for parameter ''GridFreq''.');
                    end

                otherwise
                    error(['Unknown parameter name passed to GRAPH.  Name was ' varargin{i} '.']);
            end
        end
        
        [E,N,eps] = fromweightedadjmatrix(testadjmatrix(varargin{1},emptyValue),emptyValue);
        cellOfEdgeDataTypes = {'double'};

%--------------------------------------------------------------------------  
    % from adjecency and incidency matrix          
    % from edgeList or nodeList  
    else
        % odd number of arguments
        if mod(length(varargin),2) ~= 0
            % input args have not com in pairs, woe is me
            error('Arguments must come param/value in pairs.')
        
        else
            for i = 1:2:length(varargin)                
                switch lower(varargin{i})
                    case 'adj'
                        [E,N,eps] = fromadjmatrix(testadjmatrix(varargin{i+1}));
                        
                    case 'inc'
                        [E,N,eps] = fromincmatrix(testincmatrix(varargin{i+1}));
                        
                    case edgeListWords
                        edgeList = varargin{i+1};
                        
                    case nodeListWords
                        nodeList = varargin{i+1};
                        
                    case edgeDataTypesWords
                        cellOfEdgeDataTypes = varargin{i+1};
                        
                    case nodeDataTypesWords
                        cellOfNodeDataTypes = varargin{i+1};
                        
                    case 'name'
                        if ischar(varargin{i+1}),
                            name = varargin{i+1};
                        else
                            error('Invalid data for parameter ''Name''.');
                        end
                        
                    case 'userparam'
                        userparam = varargin{i+1};
                        
                    case 'color'
                        if iscolor(varargin{i+1}),
                            color = varargin{i+1};
                        else
                            error('Invalid data for parameter ''Color''.');
                        end
                        
                    case 'gridfreq'
                        if isnumeric(varargin{i+1}) && size(varargin{i+1}) == [1, 2],
                            gridfreq = varargin{i+1};
                        else
                            error('Invalid data for parameter ''GridFreq''.');
                        end
                        
                    otherwise
                        error(['Unknown parameter name passed to GRAPH.  Name was ' varargin{i} '.']);
                end
            end
            if ~isempty(edgeList) || ~isempty(nodeList)
                [E,N,eps] = fromedgeandnodelist(edgeList,nodeList);
                [isOK1,E] = testofdatatypes(E,cellOfEdgeDataTypes);
                [isOK2,N] = testofdatatypes(N,cellOfNodeDataTypes);
                if ~isOK1 || ~isOK2
                    error('TORSCHE:graph:invalidDataTypes', 'Parameters in list do not match datatypes.');
                end
            end
        end
        
    end

%--------------------------------------------------------------------------  
    
    % name nodes
    N = setnames(N,'T');

    % Create the structure
    graph = struct(...
            'parent', 'schedobj',...
            'Name',name,...
            'E',E,...
            'N',N,...
            'eps',eps,...
            'version',0.02,...
            'UserParam',userparam,...
            'DataTypes',struct('edges',{cellOfEdgeDataTypes},...
                               'nodes',{cellOfNodeDataTypes}),...
            'Color',color,...
            'GridFreq',gridfreq);
    % UserParam is user paramters vector
    
    % Create a parent object
    parent = schedobj;

    % Label graph as an object of class GRAPH
    graph = class(graph,'graph', parent); 
   
%--------------------------------------------------------------------------        
    % Add parameters for edge (used in conversion taskset to graph)
    if exist('T','var')
        try
            graph = feval(conversion_function2,graph,T.TSUserParam.EdgesParam,conversion_param2);
        catch
            rethrow(lasterror)
        end
    end
    
    % Add to graph orter user param for tasks:    
    try
        graph.UserParam{end+1}.graphedit.nodeparams = conversion_param1;
    catch
    end
    
%end .. @graph/graph
    
    
%==============================================================================        
    
     % from edgeList or nodeList

function [E,N,eps] = fromedgeandnodelist(edgeList,nodeList)
    wrongList = '';

    % from edgeList
    if ~isempty(edgeList) && isempty(nodeList)
        try
            N(1:max([edgeList{:,1:2}])) = node;
            [E,eps] = createedges(edgeList);
            return;
        catch
            wrongList = 'of edges';
        end

    % from nodeList
    elseif isempty(edgeList) && ~isempty(nodeList)
        try
            N = createnodes(nodeList);
            E = []; eps = [];                % no edges
            return;
        catch
            wrongList = 'of nodes';
        end
      
    % from edgeList and nodeList
    elseif ~isempty(edgeList) && ~isempty(nodeList)        
        try
            N = createnodes(nodeList, max([edgeList{:,1:2}]));
            [E,eps] = createedges(edgeList);
            return;
        catch
            wrongList = 'of edges or nodes';
        end
    
    else
        N = [];
        E = []; eps = [];
        return;
    end
     
    error('TORSCHE:graph:invalidList', ['Probably invalid list ' wrongList ' was ordered.']);
     
%==============================================================================    

     % creates edges for function fromedgeandnodelist

function [E,eps] = createedges(edgeList)
    [num_edges, num_paramsEdgePlusTwo] = size(edgeList);
    E(1:num_edges) = edge;        % creating edges
    for i = 1 : num_edges
        E(i).UserParam = edgeList(i,3:num_paramsEdgePlusTwo);           
        eps(i,:) = [edgeList{i,1:2}];
    end

%==============================================================================    

     % creates nodes for function fromedgeandnodelist
    
function N = createnodes(nodeList, varargin)
    [num_nodes, num_paramsNodePlusOne] = size(nodeList);
    num_nodes2 = max([nodeList{:,1}]);
    if (nargin > 1) && (varargin{1} > num_nodes2)
        num_nodes2 = varargin{1};
    end
    N(1:num_nodes2) = node;        % creating nodes
    for i = 1 : num_nodes
        num = nodeList(i,1);       % setting userparams
        N(num{1}).UserParam = nodeList(i,2:num_paramsNodePlusOne);
    end

%==============================================================================    

    % from incidency matrix

function [E,N,eps] = fromincmatrix(I)  
    [numNodes,numEdges] = size(I);
    if numNodes < 1
        N = [];
        E = [];
        eps = [];
    else
        N(1:numNodes) = node;
        eps = zeros(numEdges,2);
        for i = 1:numEdges
            initNode = find(I(:,i) == 1);
            finalNode = find(I(:,i) == -1);
            if ~isempty(initNode) && ~isempty(finalNode)
                eps(i,:) = [initNode(1),finalNode(1)];
            elseif ~isempty(initNode) && isempty(finalNode)
                warning('TORSCHE:graph:noFinalNode',...
                    ['There wasn''t found final node for edge n.' num2str(i) ' in ordered matrix. Initial node of this edge is used as final.'])
                eps(i,:) = [initNode(1),initNode(1)];
            elseif isempty(initNode) && ~isempty(finalNode)
                warning('TORSCHE:graph:noInitialNode',...
                    ['There wasn''t found initial node for edge n.' num2str(i) ' in ordered matrix. Final node of this edge is used as initial.'])
                eps(i,:) = [finalNode(1),finalNode(1)];                    
            end
        end
        eps(eps(:,1) == 0,:) = [];
        E(1:length(eps(:,1))) = edge;
    end

%==============================================================================    

    % from adjecency matrix

function [E,N,eps] = fromadjmatrix(A)   
    [x,y,z] = find(A);
    numNodes = max(size(A));
    if numNodes < 1
        N = [];
    else
        N(1:numNodes) = node;
%         for i = 1 : numNodes
%             N(i) = node;
%         end
    end
    num_edges = sum(z);
    if (num_edges > 0)
        E(1:num_edges) = edge;
%         for i = 1 : num_edges
%             E(i) = edge;         
%         end
        eps(num_edges,:) = [0 0];
        index = 1;
        for i = 1 : length(x)
            for ii = 1:z(i)
                 eps(index,:) = [x(i), y(i)];
                 index = index + 1;
            end
        end
    else
        E = [];
        eps = [];  
    end
    
%==============================================================================

    % from weighted adjecency matrix

function [E,N,eps] = fromweightedadjmatrix(Aw,emptyValue)
    [x,y] = find(Aw ~= emptyValue);
    numNodes = max(size(Aw));
    if numNodes < 1
        N = [];
    else
        N(1:numNodes) = node;
%         for i = 1 : numNodes
%             N(i) = node;
%         end
    end
    num_edges = length(x);
    if (num_edges > 0)
        E(1:num_edges) = edge;
        for i = 1 : num_edges
%              E(i) = edge;
             E(i).UserParam = {Aw(x(i),y(i))};
        end
        eps = [x y];
    else
        E = [];
        eps = [];  
    end
   
%==============================================================================

       % from taskset

function [E,N,eps,T,...
          conversion_function1,conversion_param1,...
          conversion_function2,conversion_param2] = fromtaskset(varargin)
    na = nargin;
    T = varargin{1};
    [E,N,eps] = fromadjmatrix(testadjmatrix(T.Prec));
    
%     Example:
%      graph=graph(T,'t2n',@task2node,'proctime','name','p2e',@param2edges)    
    conversion_function1 = @task2node; %default function for transform data from task to node
    conversion_param1 = {'ProcTime','ReleaseTime','Deadline','DueDate','Weight','Processor','UserParam'}; 
    conversion_function2 = @param2edges; %default function for transform TSUserparam to data edges node 
    conversion_param2 = {};
    switch_convf = '';
    function_set = 0;
    for i=2:na
        if ischar(varargin{i})
            if strcmpi(varargin{i},'t2n')
                switch_convf = 't2n';
                function_set = 1;
                continue;
            elseif strcmpi(varargin{i},'p2e')
                switch_convf = 'p2e';
                function_set = 1;
                continue;
            end
        end
        if function_set == 1
            if strcmpi(switch_convf,'t2n')
                conversion_function1 = varargin{i};
                conversion_param1 = {};
            elseif strcmpi(switch_convf,'p2e')
                conversion_function2 = varargin{i};
                conversion_param2 = {};
            end
            function_set = 0;
        else
            if strcmpi(switch_convf,'t2n')
                if iscell(varargin{i})
                    conversion_param1 = [conversion_param1 varargin{i}];
                else
                    conversion_param1 = [conversion_param1 {varargin{i}}];
                end
            elseif strcmpi(switch_convf,'p2e')
                if iscell(varargin{i})
                    conversion_param2 = [conversion_param2 varargin{i}];
                else
                    conversion_param2 = [conversion_param2 {varargin{i}}];
                end
            end
        end
    end
    for i = 1:length(N)
        try
            N(i) = feval(conversion_function1,T.tasks(i),conversion_param1);
        catch
            rethrow(lasterror)
        end
    end



%==============================================================================
    
      % add nodes ordered by nodeList

function g = addnodes(g,nodeList)
    newNodes = [];
    nodeEmptyValues = getemptyvalues(g.DataTypes.nodes);    

    % from nodeList
    if ~isempty(nodeList)
        numNodesInGraph = length(g.N);
        [num_nodes] = size(nodeList,1);
        for i = 1:num_nodes
            nodeList{i,1} = nodeList{i,1} - numNodesInGraph;
        end
        newNodes = createnodes(nodeList);
        newNodes = addemptyparams(newNodes,[nodeList{:,1}],nodeEmptyValues);
    end

    % ...add to graph
    if ~isempty(g.N)
        g.N((end+1):(end+length(newNodes))) = newNodes;
    else
        g.N = newNodes;
    end

%==============================================================================    

      % add edges ordered by edgeList

function g = addedges(g,edgeList)
    newNodes = []; newEdges = []; newEps = [];
    numNodesInGraph = length(g.N);
    dataTypes = g.DataTypes;  
       
    % from edgeList
    if ~isempty(edgeList)
        maxNode = max([edgeList{:,1:2}]);
        if maxNode > numNodesInGraph
            nodeEmptyValues = getemptyvalues(dataTypes.nodes);
            newNodes(1:(maxNode-numNodesInGraph)) = node;
            newNodes = addemptyparams(newNodes,[],nodeEmptyValues);
        else
            newNodes = [];
        end
        [newEdges,newEps] = createedges(edgeList);
    end

    % ...add to graph
    if isempty(g.N)
        g.N = newNodes;
    else
        g.N((end+1):(end+length(newNodes))) = newNodes;
    end
    if isempty(g.E)
        g.E = newEdges;
    else
        g.E((end+1):(end+length(newEdges))) = newEdges;
    end
    g.eps = [g.eps; newEps];

%==============================================================================    

function newList = addemptyparams(newList,list,emptyParams)
    for i = 1:length(newList)
        if isempty(find(list == i))
            newList(i).UserParam = emptyParams;
        end
    end

%==============================================================================    

     % tests if input matrix is square

function mOut = testadjmatrix(mIn,varargin)
    [x,y] = size(mIn);
    if x == y
        mOut = mIn;
    else
        mOut = zeros(max(x,y));
        if nargin > 1
            mOut(mOut == 0) = varargin{1};
        end
        mOut(1:x,1:y) = mIn;
        warning('TORSCHE:graph:notSquareMatrix', 'Ordered matrix was filled on square matrix.')
    end

%==============================================================================    
    
    % tests if input matrix contains just 1, -1 or 0

function mOut = testincmatrix(mIn)
    if isempty(find(mIn ~= 1 & mIn ~= -1 & mIn ~= 0))
        mOut = mIn;
    else
        error('TORSCHE:graph:notIncMatrix', 'Ordered matrix is not incidency matrix.')
    end

%==============================================================================    

function list = setnames(list,name)
    for i = 1:length(list)
        if isempty(list(i).Name)
            list(i).Name = [name '_{' int2str(i) '}'];
        end
    end

%==========================================================================

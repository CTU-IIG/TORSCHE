function varargout = taskset(varargin)
%TASKSET creates a set of TASKs
%
%Synopsis
% setoftasks = TASKSET(T[,prec])
% setoftasks = TASKSET(ProcTimeMatrix[,prec]) 
% setoftasks = TASKSET(Graph[,Keyword,TransformFunction[,Parameters]...])
%
%Description
% creates a set of tasks with parameters:
%  T:
%    - an array or cell array of tasks ([T1 T2 ...] or {T1 T2 ...})
%  prec:
%    - precedence constraints
%  ProcTimeMatrix:
%    - an array of Processing times, for tasks which will be created inside
%      the taskset. 
%  Graph:
%    - Graph object
%  Keyword:
%    - Keyword - define type of TransformFunction;
%                 'n2t' - node to task transfer function,
%                 'e2p' - edges' userparams to taskset userparam
%  TransformFunction:
%    - Handler to a transform function, which transform node to task or
%      edges' userparams to taskset userparam. If the variable is empty,
%      standart functions 'node/node2task' and 'graph/edges2param' is used.
%  Parameters:
%    - Parameters passed to transform functions specified by
%    TransformFunction. It defines assignment of userparameters in the
%    input graph to task properties. 
%    The transfer function will be called with one input parameter of cell,
%    containing all the input parameters. Default value is: 
%      'ProcTime','ReleaseTime','Deadline','DueDate',
%      'Weight','Processor','UserParam' 
%
% The output 'setoftasks' is a TASKSET object.
%
% Example
% >> T=taskset(Gr,'n2t',@node2task,'proctime','name','e2p',@edges2param)
%
%  See also TASK/TASK, GRAPH/GRAPH, NODE/NODE2TASK, GRAPH/EDGE2PARAM


% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2897 $  $Date:: 2009-03-18 15:17:31 +0100 #$


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


if nargin==3
	if isa(varargin{1},'taskset') && ischar(varargin{2}) 
		varargout{1} = set_helper(varargin{:});
		return;
	end
end

if nargin==2 && nargout == 2
	if isa(varargin{1},'taskset') && ischar(varargin{2}) 
		[varargout{1} varargout{2}] = get_helper(varargin{:});
		return;
	end
end

ni = length(varargin);
prec=[];

% We need cell array because we need to have tasks of different types in a
% TaskSet
tasks={};
TSUserParam = [];
if ni >= 1
    % input is a taskset type
    if isa(varargin{1},'taskset') 
        tasks{1} = varargin{1}.tasks;
        % Precedencs constrains
        if (ni > 1)
            prec = varargin{length(varargin)};
        else
            prec = varargin{1}.Prec;    
        end
    % input is a cell of tasks {t1 t2 ... } or [t1 t2 ... ]
    elseif iscell(varargin{1}) 
        if size(varargin{1},1) == 1
            for i = 1:length(varargin{1})
                if ~isa(varargin{1}{i},'task')
                    error('Object #%d is not the task type!', i);
                end
            end
            tasks{1} = varargin{1};
            % Precedencs constrains
            if (ni > 1)
                prec = varargin{length(varargin)};
            end
        else
            error('Set of tasks must be only a row vector!');
        end
    %input is only number vector
    elseif isnumeric(varargin{1}) 
        ProcTime = varargin{1};
        if size(ProcTime,1) == 1
            nts = 'tasks{1} = {';
            for i = 1:length(ProcTime)
                nts=[nts ' task(' int2str(ProcTime(i)) ')'];
            end
            nts=[nts ' };'];
            eval(nts);
            % Precedencs constrains
            if (ni > 1)
                prec = varargin{length(varargin)};
            end
        else
            error('Matrix of processings time must be only a row vector!');
        end
    % input is graph    
    elseif(isa(varargin{1},'graph'))
        % conversion functions and their parameters selected
        %     Example: T=taskset(Gr,'n2t',@node2task,'proctime','name','e2p',@edges2param)
        conversion_function1 = @node2task; %default function for transform data from node to task
        conversion_param1 = {'ProcTime','ReleaseTime','Deadline','DueDate','Weight','Processor','UserParam'};
        try
            %Back compatibility (parameters were loaded from the input graph)
            conversion_param1_tmp = varargin{1}.UserParam.graphedit.nodeparams;
            if iscell(conversion_param1_tmp)
                conversion_param1 = conversion_param1_tmp;
            end
        catch
        end
        conversion_function2 = @edges2param; %default function for transform data edges node to TSUserparam
        conversion_param2 = {};
        switch_convf = '';
        function_set = 0;
        for i=2:ni
            if ischar(varargin{i})
                if strcmpi(varargin{i},'n2t')
                    switch_convf = 'n2t';
                    function_set = 1;
                    continue;
                elseif strcmpi(varargin{i},'e2p')
                    switch_convf = 'e2p';
                    function_set = 1;
                    continue;
                end
            end
            if function_set == 1
                if strcmpi(switch_convf,'n2t')
                    conversion_function1 = varargin{i};
                    conversion_param1 = {};
                elseif strcmpi(switch_convf,'e2p') % redundant control for taskset(g,'anything','n2t'...
                    conversion_function2 = varargin{i};
                    conversion_param2 = {};
                end
                function_set = 0;
            else
                if strcmpi(switch_convf,'n2t')
                    if iscell(varargin{i})
                        conversion_param1 = [conversion_param1 varargin{i}];
                    else
                        conversion_param1 = [conversion_param1 {varargin{i}}];
                    end
                elseif strcmpi(switch_convf,'e2p') % redundant control for taskset(g,'anything','n2t'...
                    if iscell(varargin{i})
                        conversion_param2 = [conversion_param2 varargin{i}];
                    else
                        conversion_param2 = [conversion_param2 {varargin{i}}];
                    end
                end
            end
        end
        % Precedence constrains
        prec=adj(varargin{1});        
        try
            %node to task conversion 
            for i=1:length(prec)
                taskscell{i} = feval(conversion_function1,varargin{1}.N(i),conversion_param1);
            end
        catch
            rethrow(lasterror)
        end
        tasks{1}=taskscell;
        % edge userparam to TSUserParam
        try
            TSUserParam.EdgesParam = feval(conversion_function2,varargin{1},conversion_param2);
        catch
            rethrow(lasterror)
        end
    else
        error('Unsupported input parametter!');
    end
else
    tasks{1} = {};
end % if ni >= 1


% convert prec to square sparse matrix
prec = full(prec);
prec = prec(1:min(length(tasks{1}),size(prec,1)), 1:min(length(tasks{1}),size(prec,2)));
[i,j,s] = find(prec);
m = max(length(prec), length(tasks{1}));
prec = sparse(i,j,s,m,m);

% Create free the structure for schedule
schedule = schstruct; %schedule struct

% Create the structure
setoftasks = struct(...
        'parent','schedobj',...
        'tasks',tasks,...
        'Prec',prec,...
        'schedule',schedule,...
        'Version',0.3,...
        'TSUserParam',TSUserParam);

parent = schedobj;

% Label taskset as an object of class taskset
setoftasks = class(setoftasks,'taskset', parent);  
varargout{1}=setoftasks;

%end .. @taskset/taskset

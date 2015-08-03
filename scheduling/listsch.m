function [T] = listsch (T, prob, m, varargin)
% LISTSCH  Computes schedule by algorithm described by Graham 1966
%
% Synopsis
%   taskset = LISTSCH(taskset, problem, m [,strategy] [,verbose]) 
%   taskset = LISTSCH(taskset, problem, m [,options])
%
% Description
%   Function is a list scheduling algorithm for parallel prllel processors.
%   The parameters are:
%      taskset:
%                - set of tasks, 
%      problem:
%                - description of scheduling problem (object PROBLEM), 
%      m:
%                - number of processors, 
%      strategy:
%                - 'EST', 'ECT', 'LPT', 'SPT' or any handler of function, 
%      verbose:
%                - level of verbosity 0 - default, 1 - brief info, 
%                  2- tell me anything, 
%      options:
%                - global scheduling toolbox variables (SCHOPTIONSSET)
%
% See also PROBLEM/PROBLEM, TASKSET/TASKSET, SORT_ECT, SORT_EST, SCHOPTIONSSET.


% Author: M. Stibor
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2895 $  $Date:: 2009-03-18 11:24:58 +0100 #$


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



% default value of verbose MOD
verbose = 0;

%Decision
if nargin>3

    if isa(varargin{1},'function_handle')
        strategy=varargin{1};
        [T order]=feval(strategy,T); % call strategy for the first time

    elseif isa(varargin{1},'struct')
        verbose = varargin{1}.verbose;
        if ~isempty(varargin{1}.strategy)
            strategy = varargin{1}.strategy;
        end

    elseif isa(varargin{1},'char')
        strategy = varargin{1};
        if nargin>4
            if isa(varargin{2},'double')
                verbose = varargin{2};
            end
        end

    elseif isa(varargin{1},'double')
        verbose = varargin{1};
    end

    if exist('strategy')
        switch lower(strategy)
            case 'est' % EST
                if (is(prob,'alpha','P') || is(prob,'alpha','Q') || is(prob,'alpha','R'))...
                        & (is(prob,'betha','rj') | is(prob,'betha','prec') | is(prob,'betha','rj,prec'))...
                        & (is(prob,'gamma','sumCj') | is(prob,'gamma','sumwCj'))
                    strategy=@sort_est;
                else
                    error('This problem can''t be solved by EST.');
                end
            case 'ect' % ECT
                if (is(prob,'alpha','P') | is(prob,'alpha','Q') | is(prob,'alpha','R'))...
                        & (is(prob,'betha','rj') | is(prob,'betha','prec') | is(prob,'betha','rj,prec'))...
                        & (is(prob,'gamma','sumCj') | is(prob,'gamma','sumwCj'))
                    strategy=@sort_ect;
                else
                    error('This problem can''t be solved by ECT.');
                end
            case 'spt' % SPT
                if (is(prob,'alpha','P') | is(prob,'alpha','Q') | is(prob,'alpha','R'))...
                        & (is(prob,'betha','rj') | is(prob,'betha','prec') | is(prob,'betha','rj,prec'))...
                        & (is(prob,'gamma','Cmax'))
                    strategy=@sort_spt;
                else
                    error('This problem can''t be solved by SPT.');
                end
            case 'lpt' % LPT
                if (is(prob,'alpha','P') | is(prob,'alpha','Q') | is(prob,'alpha','R'))...
                        & (is(prob,'betha','rj') | is(prob,'betha','prec') | is(prob,'betha','rj,prec'))...
                        & (is(prob,'gamma','Cmax'))
                    strategy=@sort_lpt;
                else
                    error('This problem can''t be solved by LPT.');
                end
            otherwise % OTHER strategy
                strategy = varargin{1};

        end
    end
end

if (nargin<=3) | ~exist('strategy') % simple ListScheduling check problem 
    if ~((is(prob,'alpha','P')|is(prob,'alpha','Q')|is(prob,'alpha','R')) ...
            & (is(prob,'betha','prec')|is(prob,'betha','rj')|is(prob,'betha','rj,prec')) ...
            & (is(prob,'gamma','Cmax')))
        error('This problem can''t be solved by List Scheduling.');
    else
        %T = sort(T,'Weight','dec')    % sort taskset along weight if exist
    end
end


% call strategy for the first time
if exist('strategy')
    [T orca] = feval(strategy,T); % save original order to "orca"
else
    orca = 1 : size(T); % save original order to "orca"
end



% Inicialization
T_work=T;
pr = T.prec;                % precedens constrains
n = count(T);               % number of tasks
nonassign = ones(1,n);      % nonassigned tasks
start = zeros(1,n);         % start times in final schedule
processor = zeros(1,n);     % processor awarded to task
release = T.releasetime;    % release times
si = zeros(1,m);            % time on each processor
iteration = 0;              % iteration of main loop
realproctime = zeros(1,n);

% verbose introduction
verbosePosition = 'start';
listsch_verbose;


% List Scheduling main loop
time = cputime;                     % time measuring - start
while sum(nonassign)                % until unassigned task left

    iteration = iteration + 1;      % inc iteration
    [sk,pk] = min(si);              % select processor with minimal time

    % get right processing time vector for this processor
    if size(T.ProcTime,1)>1    % in case different proctime for each processor
        procestime = T.ProcTime(pk,:);
    else                       % identical processors
        procestime = T.ProcTime;
    end



    timecondition = max(repmat(((~nonassign).*(realproctime+start))',1,n).*pr) <= sk; % predecessor is finnished or isn't started or is without preddecessor
    withoutpr = ~(nonassign*pr) ; % without predecessor or preddecesor is scheduled
    nawp = find(nonassign.*withoutpr.*timecondition); % Non-Assigned Without Predecessor or preddecessor is finished

    % verbose in the begining of each iteration
    verbosePosition = 'beforeH';
    listsch_verbose;


    % strategy
    if exist('strategy') & (length(nawp)>1)
        release(find(release<sk))=sk; % compute new release times
        set(T_work,'ReleaseTime',release); % set new releasetimes to taskset
        [T_heuristic order]=feval(strategy,T_work(nawp),iteration,pk); % call strategy inside main loop
        nawp=nawp(order); % reorder nawp

        % verbose in strategy
        verbosePosition = 'strategy';
        listsch_verbose;

    end
    % end of strategy


    try
        nawp=nawp(1); % choose first of possible tasks
        realproctime(nawp) = procestime(nawp);
    catch
        % If nawp is empty, move si(pk) to first posible time.
        minstarttimes = max(repmat(((~nonassign).*(realproctime+start))',1,n).*pr);
        si(pk)=min(minstarttimes(find(minstarttimes>sk)));
        % report it if vebrose
        verbosePosition = 'waiting';
        listsch_verbose;
        continue
    end

    % add to schedule
    start(nawp) = max(sk,release(nawp));                        % starting time of task
    processor(nawp) = pk;                                       % remove task to processor
    si(pk) = max(si(pk),release(nawp)) + procestime(nawp);      % update time on processor
    nonassign(nawp) = 0;                                        % take out task from the list

    % verbose in the end of each iteration
    verbosePosition = 'afterH';
    listsch_verbose;

end
% end of List Sheduling main loop


% create schedule
add_schedule(T,'time',cputime - time);
add_schedule(T,'List Scheduling',start,realproctime,processor);

% sort task in schedule in original order
[temp,backOrca]=sort(orca);
T = T(backOrca);

% verbose info in the end
verbosePosition = 'end';
listsch_verbose;


% end .. LISTSCH

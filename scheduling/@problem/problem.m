function prob = problem(varargin)
%PROBLEM  creation of object problem.
%
% Synopsis
%     PROB = PROBLEM(NOTATION)
%     PROB = PROBLEM(SPECIALPROBLEM)
%
% Description
%     The function creates object (PROB) describing a scheduling problem.
%     The input parameter - NOTATION is composed of three fields alpha|betha|gamma.
%
%       alpha - describes the processor enviroment, alpha = alpha1 and alpha2
%
%         alpha1 characterizes the type of processor used:
%           nothing:
%                    - single procesor
%           P:
%                   - identical procesors
%           Q:
%                   - uniform procesors
%           R:
%                   - unrelated procesors
%           O:
%                   - dedicated procesors: open shop system
%           F:
%                   - dedicated procesors: flow shop system
%           J:
%                   - dedicated procesors: job shop system
%
%         alpha2 denotes the number of processors in the problem
%
%       betha - describes task and resource characteristic:
%         pmtn:
%                 - preemptions are allowed
%         prec:
%                 - precedence constrains
%         rj:
%                 - ready times differ per task
%         ~dj:
%                 - deadlines
%         in-tree:
%                 - In-tree precedence constrains
%         pj=x:
%                 - processing time equal x (x must be non-negative number)
%         nj<=N:
%                 - Each job has maximal N tasks
%
%       gamma - denotes optimality criterion
%         Cmax, sumCj, sumwCj, Lmax, sumDj, sumwjDj, sumUj
%
%      Special scheduling problems (not covered by the notation) can be
%      described by a string SPECIALPROBLEM. Permitted strings are:
%       'SPNTL' and 'CSCH';
%
% Example
%   >> prob=PROBLEM('P3|pmtn,rj|Cmax')
%   >> prob=PROBLEM('SPNTL')
%
%    See also TASKSET/TASKSET


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


% TODO: Convert to new object model. (MS)

if nargin==3
	if isa(varargin{1},'problem') && ischar(varargin{2}) 
		prob = set_helper(varargin{:});
		return;
	end
else
    notation = varargin{1};
    na = nargin;

    % Special notations
    specialNotationDefinition = {'SPNTL','CSCH'};
    if any(strcmp(notation,specialNotationDefinition))
        notation = notation;
        machines_type = '';
        machines_quantity = Inf;
        betha.rj = 0;
        betha.pmtn=0;
        betha.dj_=0;    %corresponds to ~dj
        betha.intree=0;
        criterion = '';
    else
        % ALPHA
        if na >= 1
            [alpha,bethagamma]=strtok(notation,'|');
            if '|' == notation(1)
                bethagamma = strcat('|',alpha,bethagamma);
                if '|' == notation(2)
                    bethagamma = strcat('|',bethagamma);
                end
                alpha='';
            end


            if length(alpha) < 1
                machines_type='1';
                machines_quantity = 1;
            end
            if length(alpha) > 1
                if (~isempty(str2num(alpha(2:length(alpha)))))
                    machines_quantity = str2num(alpha(2:length(alpha)));
                else
                    error('Count of machines must be a number!');
                end
            else
                machines_quantity = inf;
            end
            if length(alpha) > 0
                if sum(strcmpi(alpha(1),{'1','P','Q','R','O','F','J'}))
                    machines_type=upper(alpha(1));
                    if strcmpi(alpha(1),'1')
                        machines_quantity = 1;
                    end
                else
                    error('Unknow machine typ!');
                    return
                end
            end

            %BETHA
            bethagamma=bethagamma(2:length(bethagamma));
            if isempty(bethagamma)
                error('Betha must be defined');
            end
            [betha_notation,gamma]=strtok(bethagamma,'|');
            if '|' == bethagamma(1)
                gamma = strcat('|',betha_notation,gamma);
                betha_notation='';
            end
            betha.pmtn=0;
            betha.rj=0;
            betha.dj_=0;    %corresponds to ~dj
            betha.prec=0;
            betha.intree=0;
            betha.pj=-1;
            betha.nj=inf;

            while length(betha_notation)
                [betha_notation,bethanext]=strtok(betha_notation,',');

                if (~sum(strcmpi(betha_notation,{'pmtn','rj','~dj','prec','in-tree'}))) & (isempty(regexpi(betha_notation,'^pj=\d+$'))) & (isempty(regexpi(betha_notation,'^nj<=\d+$')))
                    warning('Unknow describes task and resource characteristic!');
                end

                betha.pmtn=betha.pmtn|strcmpi(betha_notation,'pmtn');
                betha.rj=betha.rj|strcmpi(betha_notation,'rj');
                betha.dj_=betha.dj_|strcmpi(betha_notation,'~dj');
                betha.prec=betha.prec|strcmpi(betha_notation,'prec');
                betha.intree=betha.intree|strcmpi(betha_notation,'in-tree');
                if regexpi(betha_notation,'^pj=\d+$')
                    [st,fi,tok]=regexpi(betha_notation,'^pj=(\d+)$');
                    betha.pj=str2num(betha_notation(tok{1}(1):tok{1}(2)));
                end
                if regexpi(betha_notation,'^nj<=\d+$')
                    [st,fi,tok]=regexpi(betha_notation,'^nj<=(\d+)$');
                    betha.nj=str2num(betha_notation(tok{1}(1):tok{1}(2)));
                end

                betha_notation = bethanext(2:length(bethanext));
            end

            %GAMMA
            gamma=gamma(2:length(gamma));
            if length(gamma) < 1
                error('Criterion must be set!');
                return
            end
            if strcmpi(gamma,'Cmax')
                criterion='Cmax';
            elseif strcmpi(gamma,'wCmax')
                criterion='wCmax';
            elseif strcmpi(gamma,'sumCj')
                criterion='sumCj';
            elseif strcmpi(gamma,'sumwCj')
                criterion='sumwCj';
            elseif strcmpi(gamma,'Lmax')
                criterion='Lmax';
            elseif strcmpi(gamma,'sumDj')
                criterion='sumDj';
            elseif strcmpi(gamma,'sumwjDj')
                criterion='sumwjDj';
            elseif strcmpi(gamma,'sumUj')
                criterion='sumUj';
            elseif strcmpi(gamma,'sumTi')
                criterion='sumTi';
            else
                error('Criterion is incorect!');
                return
            end
        else
            notation = '';
            machines_type = '';
            machines_quantity = Inf;
            betha.rj = 0;
            criterion = '';
        end
    end

    % Create the structure
    prob = struct(...
        'notation',notation,...
        'machines_type',machines_type,...
        'machines_quantity',machines_quantity,...
        'betha',betha,...
        'criterion',criterion,...
        'Notes',{{}},...
        'Version',0.1);

    % Label task as an object of class PROBLEM
    prob = class(prob,'problem');
end
%end .. @problem/problem

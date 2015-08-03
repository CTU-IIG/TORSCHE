function schoptions=schoptionsset(varargin)
%SCHOPTIONSSET Creates/alters SCHEDULING TOOLBOX OPTIONS structure.
%
% Synopsis
%    SCHOPTIONS = SCHOPTIONSSET('PARAM1',VALUE1,'PARAM2',VALUE2,...)
%    SCHOPTIONS = OPTIMSET(OLDSCHOPTIONS,'PARAM1',VALUE1,...)
%
% Description
%    SCHOPTIONS = SCHOPTIONSSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) creates an
%    optimization options structure SCHOPTIONS in which the named parameters have
%    the specified values.
%
%    SCHOPTIONS = SCHOPTIONSSET(OLDSCHOPTIONS,'PARAM1',VALUE1,...) creates a copy of
%    OLDSCHOPTIONS with the named parameters altered with the specified
%    values. Supported parameters are summarized below.
%
% GENERAL:
% maxIter:
%                - Maximum number of iterations allowed. (positive integer)
% verbose:
%                - Verbosity level. (0 = be silent, 1 = display only critical messages
%                2 = display everything)
% logfile:
%                - Create a log file. (0 = disable, 1 = enable)
% logfileName:
%                - Specifies logfile name. (character array)
% strategy:
%                - Specifies strategy of algorithm.
%
% ILP,MIQP:
% ilpSolver:
%                - Specify ILP solver ('glpk' or 'lp_solve' or 'external')
% extIlinprog:
%                - Specifies external ILP solver interface. Specified function must
%                have the same parameters as function ILINPROG. (function handle)
% miqpSolver:
%                - Specify MIQP solver ('miqp' or 'external')
% extIquadprog:
%                - Specifies external MIQP solver interface. Specified function must
%                have the same parameters as function IQUADPROG. (function handle)
% solverVerbosity:
%                - Verbosity level. (0 = be silent, 1 = display only critical messages,
%                2 = display everything)
% solverTiLim:
%                - Sets the maximum time, in seconds, for a call to an optimizer.
%                When solverTiLim<=0, the time limit is ignored. Default value is 0.
%                (double)
%
% CYCLIC SCHEDULING:
% cycSchMethod:
%                - Specifies an method for Cyclic Scheduling algorithm
%                  ('integer' or 'binary')
% varElim:
%                - Enables elimination of redundant binary decision variables
%                in ILP model (0 = disable, 1 = enable).
% varElimILPSolver
%                - Specifies another ILP solver for elimination of redundant binary
%                decision variables.
% secondaryObjective:
%                - Enables minimization of iteration overlap as secondary objective
%                function (0 = disable, 1 = enable).
% qmax:
%                - Maximal overlap of iterations qmax>=0 (default [] - undefined).
%
%
% SCHEDULING WITH POSITIVE AND NEGATIVE TIME-LAGS:
% spntlMethod:
%                - Specifies an method for SPNTL algorithm
%                ('BaB' - Branch and Bound algorithm;
%                'BruckerBaB' - Brucker's Branch and Bound algorithm;
%                'ILP' - Integer Linear Programming)
%
%
% See also ILINPROG, CYCSCH, SPNTL


% Author: Premysl Sucha <suchap@fel.cvut.cz>
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


%Default values
schoptions=[];
paramCounter=1;
if(nargin>=1)
    if(isa(varargin{1},'struct'))
        schoptions=varargin{1};
        paramCounter=2;
    end;
end;

if(isempty(schoptions))
    schoptions.maxIter=inf;
    schoptions.verbose=0;
    schoptions.logfile=0;
    schoptions.logfileName='';
    schoptions.strategy='';

    schoptions.ilpSolver='glpk';
    schoptions.extIlinprog=[];
    schoptions.miqpSolver='miqp';
    schoptions.extIquadprog=[];
    schoptions.solverVerbosity=0;
    schoptions.solverTiLim=0;
    schoptions.cycSchMethod='integer';
    schoptions.varElim=1;
    schoptions.varElimILPSolver='glpk';
    schoptions.secondaryObjective=1;
    schoptions.qmax=[];
    schoptions.spntlMethod='ILP';
end;

while(paramCounter<=nargin)
    if ~isa(varargin{paramCounter},'char')
        error('Input argument %d must be a string with the parameter name.',paramCounter);
    end
    if (paramCounter+1) > nargin
        error('Value of input parameter "%s" was not specified.',varargin{paramCounter});
    end

    value=varargin{paramCounter+1};

    switch(varargin{paramCounter})
        case 'maxIter'
            if(~isa(value,'numeric'))
                error('Invalid value for options parameter ''maxIter'': must be a real positive number.');
            end
            schoptions.maxIter=round(value);

        case 'verbose'
            if(~isa(value,'numeric'))
                error('Invalid value for options parameter ''verbose'': must be 0,1 or 2.');
            end
            if(value~=0 && value~=1 && value~=2)
                error('Invalid value for options parameter ''verbose'': must be 0,1 or 2.');
            end
            schoptions.verbose=value;

        case 'logfile'
            if(~isa(value,'numeric'))
                error('Invalid value for options parameter ''logfile'': must be 0 or 1.');
            end
            if(value~=0 && value~=1)
                error('Invalid value for options parameter ''logfile'': must be 0 or 1.');
            end
            schoptions.logfile=value;

        case 'logfileName'
            if(~isa(value,'char'))
                error('Invalid value for options parameter ''logfileName'': must be a real positive number.');
            end
            schoptions.logfileName=varargin{paramCounter+1};

        case 'strategy'
            if ~((isa(value,'char'))||(isa(value,'function_handle')))
                error('Invalid value for options parameter ''strategy'': must be a string or function handle.');
            end
            schoptions.strategy=value;

        case 'ilpSolver'
            if(~isa(value,'char'))
                error('Invalid value for options parameter ''ilpSolver'': must be a string ''glpk'',''lp_solve'',''cplex'',''cplex2'' or ''external''.');
            end
            availableSolvers={'glpk','lp_solve','cplex','cplex2','external'};
            if(~ismember({value},availableSolvers))
                error('Invalid value for options parameter ''ilpSolver'': must be a string ''glpk'',''lp_solve'',''cplex'',''cplex2'' or ''external''.');
            end
            schoptions.ilpSolver=value;

        case 'extIlinprog'
            if(~isa(value,'function_handle'))
                error('Invalid value for options parameter ''extIlinprog'': must be a function handle.');
            end
            schoptions.extIlinprog=varargin{paramCounter+1};

        case 'miqpSolver'
            if(~isa(value,'char'))
                error('Invalid value for options parameter ''miqpSolver'': must be a string ''miqp'',''cplex'' or ''external''.');
            end
            availableSolvers={'miqp','cplex','external'};
            if(~ismember({value},availableSolvers))
                error('Invalid value for options parameter ''miqpSolver'': must be a string ''miqp'',''cplex'' or ''external''.');
            end
            schoptions.miqpSolver=value;

        case 'extIquadprog'
            if(~isa(value,'function_handle'))
                error('Invalid value for options parameter ''extIquadprog'': must be a function handle.');
            end
            schoptions.extIquadprog=varargin{paramCounter+1};

        case 'solverVerbosity'
            if(~isa(value,'numeric'))
                error('Invalid value for options parameter ''solverVerbosity'': must be 0,1 or 2.');
            end
            if(value~=0 && value~=1 && value~=2)
                error('Invalid value for options parameter ''solverVerbosity'': must be 0,1 or 2.');
            end
            schoptions.solverVerbosity=value;

        case 'solverTiLim'
            if(~isa(value,'numeric'))
                error('Invalid value for options parameter ''solverTiLim'': must be a real positive number.');
            end
            schoptions.solverTiLim=varargin{paramCounter+1};

        case 'cycSchMethod'
            if(~isa(value,'char'))
                error('Invalid value for options parameter ''cycSchMethod'': must be a string ''integer'' or ''binary''.');
            end;
            availableMethods={'integer','binary','ims'};
            if(~ismember({value},availableMethods))
                error('Invalid value for options parameter ''cycSchMethod'': must be a string ''integer'' or ''binary''.');
            end
            schoptions.cycSchMethod=value;

        case 'varElim'
            if(~isa(value,'numeric'))
                error('Invalid value for options parameter ''varElim'': must be 0 or 1.');
            end
            if(value~=0 && value~=1)
                error('Invalid value for options parameter ''varElim'': must be 0 or 1.');
            end
            schoptions.varElim=value;

        case 'varElimILPSolver'
            if(~isa(value,'char'))
                error('Invalid value for options parameter ''varElimILPSolver'': must be a string ''glpk'',''lp_solve'',''cplex'',''cplex2'' or ''external''.');
            end
            availableSolvers={'glpk','lp_solve','cplex','cplex2','external'};
            if(~ismember({value},availableSolvers))
                error('Invalid value for options parameter ''varElimILPSolver'': must be a string ''glpk'',''lp_solve'',''cplex'',''cplex2'' or ''external''.');
            end
            schoptions.varElimILPSolver=value;

        case 'secondaryObjective'
            if(~isa(value,'numeric'))
                error('Invalid value for options parameter ''secondaryObjective'': must be 0 or 1.');
            end
            if(value~=0 && value~=1)
                error('Invalid value for options parameter ''secondaryObjective'': must be 0 or 1.');
            end
            schoptions.secondaryObjective=value;

        case 'qmax'
            if(~isa(value,'numeric'))
                error('Invalid value for options parameter ''qmax'': must be greather or equal to 0 or [].');
            end
            if(~isempty(value))
                if(value<0)
                    error('Invalid value for options parameter ''qmax'': must be greather or equal to 0 or [].');
                end
            end
            schoptions.qmax=value;

        case 'spntlMethod'
            if(~isa(value,'char'))
                error('Invalid value for options parameter ''spntlMethod'': must be a string ''BaB'', ''BruckerBaB'' or ''ILP''.');
            end;
            availableSolvers={'BaB','BruckerBaB','ILP'};
            if(~ismember({value},availableSolvers))
                error('Invalid value for options parameter ''spntlMethod'': must be a string ''BaB'', ''BruckerBaB'' or ''ILP''.');
            end;
            schoptions.spntlMethod=value;


        otherwise
            error('Unrecognized parameter name ''%s''.',varargin{paramCounter});
    end

    paramCounter=paramCounter+2;

end

% end .. SCHOPTIONSSET

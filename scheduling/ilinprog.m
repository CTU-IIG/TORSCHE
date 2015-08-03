function [xmin,fmin,status,extra] = ilinprog (varargin)
%ILINPROG universal interface for integer linear programming.
% Synopsis
%    [XMIN,FMIN,STATUS,EXTRA] = ILINPROG([OPTIONS],SENSE,C,A,B,[CTYPE,[LB,[UB,[VARTYPE]]]])
%
% Description
%    Parameters:
%      OPTIONS:
%               - optimization options (see SCHOPTIONSSET)
%      SENSE:
%               - indicates whether the problem is a minimization=1 or
%                 maximization=-1
%      C:
%               - column vector containing the objective function 
%                 coefficients
%      A:
%               - matrix representing linear constraints
%      B:
%               - column vector of right sides for the inequality constraints
%      CTYPE:   - column vector that determines the sense of the inequalities
%                    (CTYPE(i) = 'L'  less or equal;  
%                     CTYPE(i) = 'E'  equal;
%                     CTYPE(i) = 'G'  greater or equal)  
%      LB:
%               - column vector of lower bounds
%      UB:
%               - column vector of upper bounds
%      VARTYPE:
%               - column vector containing the types of the variables
%                    (VARTYPE(i) = 'C' continuous variable;
%                     VARTYPE(i) = 'I' integer variable)
%
%    A nonempty output is returned if a solution is found:
%      XMIN:
%               - optimal values of decision variables
%      FMIN:
%               - optimal value of the objective function
%      STATUS:
%               - status of the optimization (1-solution is optimal)
%      EXTRA:
%               - data structure containing the following fields
%                   (TIME    - time (in seconds) used for solving;
%                    LAMBDA  - dual variables)
%
%    See also SCHOPTIONSSET, MAKE.

% Author: Premysl Sucha <suchap@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2947 $  $Date:: 2009-05-22 11:32:56 +0200 #$


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


%Check input parameters.
if (isa(varargin{1},'struct') && nargin<5) || ...
        (~isa(varargin{1},'struct') && nargin<4)
    error('Not enaught parameters!');
end

if nargin>9
    error('Too many input parameters!');
end

if isa(varargin{1},'struct')
    schoptions = varargin{1};
    sense = varargin{2};
    c = varargin{3};
    A = varargin{4};
    b = varargin{5};
    if nargin >= 6
        ctype = varargin{6};
    else
        ctype(1:length(b),1) = 'L';     %generate default values
    end
    if nargin >= 7
        lb = varargin{7};
    else
        lb = zeros(length(c),1);
    end
    if nargin >= 8
        ub = varargin{8};
    else
        ub = Inf*ones(length(c),1);
    end
    if nargin >= 9
        vartype = varargin{9};
    else
        vartype(1:length(c),1) = 'C';
    end
else
    schoptions = schoptionsset;
    sense = varargin{1};
    c = varargin{2};
    A = varargin{3};
    b = varargin{4};
    if nargin >= 5
        ctype = varargin{5};
    else
        ctype(1:length(b),1) = 'L';     %generate default values
    end
    if nargin >= 6
        lb = varargin{6};
    else
        lb = zeros(length(c),1);
    end
    if nargin >= 7
        ub = varargin{7};
    else
        ub = Inf*ones(length(c),1);
    end
    if nargin >= 8
        vartype = varargin{8};
    else
        vartype(1:length(c),1) = 'C';
    end
end

%check vectors 'lb' a 'ub'
if size(lb,2)>1
    error('Vector ''lb'' must be a column vector.');
end;

if size(ub,2)>1
    error('Vector ''ub'' must be a column vector.');
end;

if any((ub-lb)<0)
    error('Incorrect variables bound in ILP model.');
end;


%Eliminate strictly bounded variables forim ILP model (some solvers has problems with it)
% strictBounds=find((ub-lb)==0);
% if(~isempty(strictBounds))
%     
%     strictBoundedVarValue=lb(strictBounds);
%     remainVar=1:size(A,2);
%     remainVar=setdiff(remainVar,strictBounds);
%     
%     b=b-A(:,remainVar)*lb(remainVar);
%     A=A(:,remainVar);
%     cOld=c;
%     c=c(remainVar);
%     vartype=vartype(remainVar);
%     lb=lb(remainVar);
%     ub=ub(remainVar);
% end;

if( ~isempty(find(vartype=='I')) )
    integerProblem=1;
else
    integerProblem=0;
end;    

%Start solving ILP
switch(schoptions.ilpSolver)

    case 'external'
        [xmin,fmin,status,extra] = feval(schoptions.extIlinprog,schoptions,sense,c,A,b,ctype,lb,ub,vartype);
        
    case 'cplex'
        if(schoptions.solverTiLim~=0)
            param.double=[1039 schoptions.solverTiLim];         %CPLEX time limit
        else
            param=[];
        end;            
        options.verbose=schoptions.solverVerbosity;
        invertInequality=find(ctype=='G');
        A(invertInequality,:)=-A(invertInequality,:);
        b(invertInequality)=-b(invertInequality);
        indeq=find(ctype=='E');
        c=sense*c;
        
        clear cplexint;
        CPUTime=cputime;
        [xmin,fmin,solstat,details]=cplexint([],c,A,b,indeq,[],lb,ub,vartype,param,options);
        extra.time=cputime-CPUTime;
        clear cplexint;

        
        if( (integerProblem==1 & solstat==101) | (integerProblem==0 & solstat==1) )
            status=1;
            fmin=sense*fmin;
            integers=find(vartype=='I');
            xmin(integers)=round(xmin(integers));
        elseif( (integerProblem==1 & solstat==107) | (integerProblem==0 & solstat==11) )
            status=0;
            fmin=sense*fmin;
            integers=find(vartype=='I');
            xmin(integers)=round(xmin(integers));
        else
            status=0;
            fmin=[];
            xmin=[];
        end;
        extra.lambda=details.dual;
        
        
    case 'glpk'
        ctype(find(ctype=='L'))='U';
        ctype(find(ctype=='E'))='S';
        ctype(find(ctype=='G'))='L';
        vartype(find(vartype=='B'))='I';    
        
        param.msglev=schoptions.solverVerbosity;
        if(schoptions.solverTiLim~=0)
            param.tmlim=schoptions.solverTiLim;
        end;
        clear glpkmex;
        
        CPUTime=cputime;
        [xmin,fmin,status,glpk_extra]=glpkmex(sense,c,A,b,ctype,lb,ub,vartype,param);        
        extra.time=cputime-CPUTime;

        if(status==5)
            status=1;           %Optimal solution was found
        elseif(status==2)
            status=0;           %Time limit exhausted
        else
            status=0;
            fmin=[];
            xmin=[];
        end;
                    
    case 'lp_solve'
        e=inf*ones(1,length(b));
        e(find(ctype=='L'))=-1;
        e(find(ctype=='E'))=0;
        e(find(ctype=='G'))=1;
        xint=find(vartype=='I');
        
        clear mxlpsolve;
        try;
        
        CPUTime=cputime;
        [fmin,xmin,duals]=lp_solve(-sense*c,A,b,e,lb,ub,xint);
        extra.time=cputime-CPUTime;
        extra.lambda=duals;
        
        catch
            [errmsg errid]=lasterr;
            if(isempty(findstr(errmsg,'arguments not assigned')))   %Ignore error 'One or more output arguments not assigned ...'
                error(lasterr);
            end;
            fmin=[];
            duals=[];
        end;
        
        if(~isempty(fmin))
            status=1;
        else
            status=0;
            fmin=[];
            xmin=[];
        end;
        extra.lambda=duals;
        
    otherwise
        error(sprintf('Unrecognized ILP solver ''%s''.',schoptions.ilpSolver));
end

extra.time=round(1000*extra.time)/1000;

% if(~isempty(strictBounds) & ~isempty(xmin))
%     xmin(remainVar)=xmin;
%     xmin(strictBounds)=strictBoundedVarValue;
%     fmin=xmin'*cOld;
%     extra.lambda=[];
% end;



% end .. ILINPROG

function [xmin, fmin, flag, Extendedflag] = ...
   miqp(H, f, A, b, Aeq, beq, vartype, lb, ub, x0, Options)
%===============================================================================
% function [xmin, fmin, flag, Extendedflag] = ...
%           miqp(H, f, A, b, Aeq, beq, vartype, lb, ub, x0, Options)
%
% Title:   miqp.m
%
% Version: 1.07
% 
% Project: Development of a Mixed Integer Quadratic Program (MIQP) solver
%          for Matlab 
%
% Purpose: Solves the following MIQP
% 
%             min         0.5*x'H x + f' x
%             subject to  A   x <= b
%                         Aeq x  = beq
%              
%          if lb, ub are supplied, then the additional constraint
%
%             lb <= x <= ub
%
%          is imposed. If x0 is supplied, then x0 is taken as initial condition
%          for the search of the optimum xmin.
%          The variables indexed by vartype are binary, or more precisely
%
%             x(vartype) in {0,1} 
%
%          where {0,1} is understood as subset of the real numbers
%
% Requires:This function requires the availability of solvers for linear
%          programs (LP) and quadratic programs (QP). The following solvers are
%          supported:
%          
%          QP
%          --
%          quadprog.m : QP solver from matlab's optimization toolbox
%          qp.m       : Old version of quadprog.m
%          e04naf.m   : QP solver from NAG foundation toolbox
%          dantzgmp.m : QP solver from MPC toolbox
%
%          LP
%          --
%          linprog.m  : LP solver from matlab's optimization toolbox 
%          lp.m       : Old version of linprog.m
%          e04mbf.m   : LP solver from NAG foundation toolbox
%
%          Using e04naf.m requires also the presence of an m-function 
%          perfomring the simple matrix vector product H*x. Use for instance
%          the function qphess.m contained in the package.
%
%          If one or more solvers for LP and QP are not available, it is
%          recommended to force the use of the available solvers with the
%          parameter Options explained below.
%
% Authors: Alberto Bemporad   
%          Domenico Mignone  
%              
% History: 
% version  date         subject    
%              
% 0.1      1998.05.03   Preliminary Version 0.1, codename: miqp3_naf.m
% 1.02     2000.09.28   Public Beta Version 1.0
% 1.03     2000.10.27   Default initialization has been set to -inf instead of 0
% 1.04     2000.10.30   The options parameter for linprog and quadprog has been
%                       set as a field in the structure Options, namely
%                       Options.optimset. This variable can be set using the
%                       optimization toolbox routine "optimset"
% 1.05     2001.05.08   Systematic rounding of binary variables introduced
%                       according to the Flag Options.round 
%                       Routine qphess.m is not required anymore since it is
%                       created and deleted on the fly. To avoid deletion, see
%                           Options.deletefile
% 1.06     2001.05.09   Solver option qp_dantz added
% 1.07     2004.04.30   Pure integer problems and pure eq. constr. handled
% Inputs:  mandatory arguments:
%
%          H, f    : parameters of the cost function     
%          A, b    : parameters defining the inequality constraints    
%
%          optional arguments:
%
%          Aeq, beq: parameters defining the equality constraints
%
%          vartype : vector specifying indices of binary variables 
%                    miqp.m supports 2 notations for this parameter:
%                    1.) vartype is a vector of positive integers
%                        the entries in vartype are the indices of those 
%                        variables constrained to be binary 
%                        the length is from 0 to size(H,1) (default [])
%                    2.) vartype is a vector of characters of length size(H,1)
%                        vartype(i) = 'C'  i-th variable is continuous
%                        vartype(i) = 'B'  i-th variable is binary: 0,1
%                        vartype(i) = 'I'  i-th variable is integer
%                    the option 'I' is not supported and is included for
%                    compatibility
%          lb      : Lower bounds on x (default -infinity)
%          ub      : Upper bounds on x (default +infinity) 
%          x0      : Initial condition (default 0)
%          Options : Variable in matlab's structure format, allowing to set
%                    various options for the solution algorithm. The following
%                    fields are considered. For detailed explanation of the
%                    various options see the documentation mentioned below.
%                    The mentioned default values are assumed either if Options
%                    is not defined, or if the fields below are not defined.
%          
%          Options.solver {'lp'|'linprog'|'lpnag'|'qp'|'quadprog'|'qpnag'|
%                          'qp_dantz'}
%
%                    'lp'       : LP solver from matlab's optimization toolbox
%                    'linprog'  : LP solver from matlab's optimization toolbox
%                    'lpnag'    : LP solver from matlab's NAG foundation toolbox
%                    'qp'       : QP solver from matlab's optimization toolbox
%                    'quadprog' : QP solver from matlab's optimization toolbox
%                    'qpnag'    : QP solver from matlab's NAG foundation toolbox
%                    'qp_dantz' : QP solver from matlab's MPC toolbox
%                    (default   : 'quadprog')
%                    see also Options.matrixtol below
%
%          Options.method {'depth'|'breadth'|'best'|'bestdepth'}
% 
%                    'depth'    : depth first tree exploring strategy
%                    'breadth'  : breadth first tree exploring strategy
%                    'best'     : best first tree exploring strategy
%                    'bestdepth': best first tree exploring strategy, norm. cost
%                    (default   : 'depth')
%
%          Options.branchrule {'first'|'max'|'min'}
%   
%                    'first'    : first free variable
%                    'max'      : variable, where the relaxed solution has the
%                                 largest distance to the next integer in {0,1}
%                    'min'      : variable, where the relaxed solution has the
%                                 smallest distance to the next integer in {0,1}
%                    (default   : 'first')
%          
%          Options.order {0|1}
%
%                    0          : problem, where the binary variable has been
%                                 set to 0 is solved first
%                    1          : problem, where the binary variable has been
%                                 set to 1 is solved first
%                    (default   : 0)
%                     
%          Options.verbose {0|1|2}
%
%                    0          : quiet
%                    1          : medium number of messages
%                    2          : high number of messages
%                    (default   : 0)
%
%          Options.maxqp {positive integer}
%
%                    maximum number of relaxed QPs (LPs) allowed to be solved
%                    (default   : inf)
%
%          Options.inftol {positive real}
%                    
%                    large number to be considered as infinity in constraints
%                    this is only used with the solvers from the NAG toolbox
%                    (default   : 1e8)
%
%          Options.matrixtol {nonnegative real}
%
%                    tolerance for recognizing that the MIQP is actually an MILP
%                    this option is only utilizable, if Options.solver is un-
%                    defined, the default solver for LPs is 'linprog'
%                    a problem is considered an MILP if
%                        max(svd(H)) <= matrixtol
%                    Set this parameter to inf in order to always ignore the 
%                    matrix H and always treat the problem as an MILP
%                    This parameter is also used to determine, whether the 
%                    problem can be solved with qp_dantz.m
%                    (default   : 1e-6)
%
%          Options.postol {nonnegative real}
%
%                    tolerance for recognizing H > 0, if any relaxed QP has
%                        cond(H) <= Options.postol
%                    then a warning message is produced for verbose >= 1
%                    to avoid the computation of the condition number for each
%                    relaxed QP, leave this field undefined
%                    (default   : no check, otherwise 1e-6 for values out of
%                                 range)
%
%          Options.integtol {nonnegative real}
%   
%                    tolerance to recognize integers
%                    (default   : 1e-4)
%
%          Options.maxQPiter {positive integer}
%          
%                    maximum number of iterations within each QP or LP 
%                    (default   : 1000)
%
%          Options.optimset {structure}
%                    
%                    optional arguments to be passed to linprog or quadprog
%                    (default   : optlinprog, where
%                                 optlinprog =optimset('LargeScale','off', ...
%                                                      'Display','off', ...
%                                                      'MaxIter',maxQPiter);   )
%          
%          Options.deletefile {0|1}
%
%                    if the auxiliary routine qphess.m had to be generated by
%                    miqp.m (only for the solver 'qpnag'), then this flag
%                    determines, whether the file is deleted at the end of the
%                    execution of miqp.m
%
%                    0: qphess.m is left in the current directory
%                    1: qphess.m is deleted
%                    (default : 1)
%
%          Options.round {0|1}
%
%                    0: relaxed variables, that fulfill the integer tolerances
%                       are not rounded to integer values
%                    1: as soon as a variable satisfies the integer tolerance
%                       it is rounded to the next integer value
%                    (default : 1)
%
%          Calling miqp.m without input arguments reports the version number
%
% Outputs: xmin:  minimizer of the MIQP
%          fmin:  minimum value of the cost function
%          flag:  characterization of solution according to the following list
%                   1 : integer feasible
%                   5 : feasible, but not integer feasible
%                   7 : infeasible, i.e. relaxed problem is infeasible
%                  11 : integer feasible, the limit maxqp of QPs has been
%                       reached, i.e. the solution might be suboptimal
%                  15 : feasible, but not integer feasible, the limit maxqp of
%                       QPs has been reached, i.e. did not search long enough
%                  -1 : the solution is unbounded
%
%          Extendedflag: Variable in matlab's structure format, which contains
%                        other informations about the MIQP or MILP. The
%                        following fields can be accessed in Extendedflag:
%
%          Extendedflag.QPiter: Number of relaxed QPs or LPs solved in the
%                               branch and bound tree
%          Extendedflag.time  : Time elapsed for running miqp.m
%          Extendedflag.optQP : Number of relaxed QP at which the optimal
%                               has been found
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Legal note:
%          This library is free software; you can redistribute it and/or
%          modify it under the terms of the GNU Lesser General Public
%          License as published by the Free Software Foundation; either
%          version 2.1 of the License, or (at your option) any later version.
%
%          This library is distributed in the hope that it will be useful,
%          but WITHOUT ANY WARRANTY; without even the implied warranty of
%          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%          Lesser General Public License for more details.
% 
%          You should have received a copy of the GNU Lesser General Public
%          License along with this library; if not, write to the 
%          Free Software Foundation, Inc., 
%          59 Temple Place, Suite 330, 
%          Boston, MA  02111-1307  USA
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%                               
% Documentation: A technical report presenting all the features and the main
%                implementation ideas of this solver can be found at:
%
%                http://www.aut.ee.ethz.ch/~hybrid/miqp/ 
%
% Contact:       Alberto Bemporad
%                Automatic Control Laboratory
%                ETH Zentrum
%                Zurich, Switzerland
%                bemporad@aut.ee.ethz.ch
%
%                Domenico Mignone
%                Automatic Control Laboratory
%                ETH Zentrum
%                Zurich, Switzerland
%                mignone@aut.ee.ethz.ch
%
%                Comments and bug reports are highly appreciated
%
% (C) 1998-2000  Alberto Bemporad, Domenico Mignone
%                                    
%===============================================================================

tic; % for timing purposes

% ==============================================================================
% Argument verifications                                           
% ==============================================================================

if nargin == 0
   disp('Version 1.06')
   return
end   

error(nargchk(4,11,nargin));

% define optional arguments
% -------------------------

if nargin <= 10
   Options = [];
end      
if nargin <= 9
   x0 = [];
end
if nargin <= 8
   ub = [];
end
if nargin <= 7
   lb = [];
end
if nargin <= 6
   vartype = [];
end
if nargin <= 5
   beq = [];
end
if nargin <= 4
   Aeq = [];
end         

% specify defaults for all undefined parameters in Options
% --------------------------------------------------------

default_solver     = 'quadprog'; % specify here the default solver for QPs
default_method     = 'depth';    % specify here the default method
default_branchrule = 'first';    % specify here the default branchrule
default_order      = 0;          % specify here the default order
default_verbose    = 0;          % specify here the default verbose
default_maxqp      = inf;        % specify here the default maxqp
default_inftol     = 1e8;        % specify here the default inftol
default_matrixtol  = 1e-6;       % specify here the default matrixtol
default_postol     = 1e-6;       % specify here the default postol
default_integtol   = 1e-4;       % specify here the default integtol
default_maxQPiter  = 1000;       % specify here the default maxQPiter
default_solverlp   = 'linprog';  % specify here the default solver for LPs
default_deletefile = 1;          % specify here the default deletefile-flag
default_round      = 1;          % specify here the default round-flag
default_xxmax      = 1e7;        % specify here the default xmax for qp_dantz

% handle the different fields of 'Options'
% ----------------------------------------

if isfield(Options,'solver')
   switch Options.solver
   case {'lp','linprog','lpnag','qp','quadprog','qpnag','qp_dantz'}
      solver = Options.solver;
   otherwise
      warning('solver is not implemented: will take default solver')
      solver = default_solver;
   end   
else
   solver = default_solver;   
end

if isfield(Options,'method')
   switch Options.method
   case {'depth','breadth','best','bestdepth'}
      method = Options.method;
   otherwise
      warning('method is not implemented: will take default method')
      method = default_method;
   end   
else
   method = default_method;   
end

if isfield(Options,'branchrule')
   switch Options.branchrule
   case {'first','max','min'}
      branchrule = Options.branchrule;
   otherwise
      warning('branchrule is not implemented: will take default branchrule')
      branchrule = default_branchrule;
   end   
else
   branchrule = default_branchrule;   
end

if isfield(Options,'order')
   switch Options.order
   case {0,1}
      order = Options.order;
   case {'0','1'}
      order = str2num(Options.order); 
   otherwise
      warning('order is not implemented: will take default order')
      order = default_order;
   end   
else
   order = default_order;   
end

if isfield(Options,'verbose')
   switch Options.verbose
   case {0,1,2}
      verbose = Options.verbose;
   case {'0','1','2'}
      verbose = str2num(Options.verbose); 
   otherwise
      warning('verbose is not implemented: will take default verbose')
      verbose = default_verbose;
   end   
else
   verbose = default_verbose;   
end

if isfield(Options,'maxqp')
   if Options.maxqp >= 1
      maxqp = floor(Options.maxqp);
   else
      warning('maxqp is negative or 0: will take default maxqp')
      maxqp = default_maxqp;
   end   
else
   maxqp = default_maxqp;   
end

if isfield(Options,'inftol')
   if Options.inftol > 0
      inftol = Options.inftol;
   else
      warning('inftol is negative or 0: will take default inftol')
      inftol = default_inftol;
   end   
else
   inftol = default_inftol;   
end

if isfield(Options,'matrixtol')
   if Options.matrixtol >= 0
      matrixtol = Options.matrixtol;
   else
      warning('matrixtol is negative: will take default matrixtol')
      matrixtol = default_matrixtol;
   end   
else
   matrixtol = default_matrixtol;   
end

if isfield(Options,'postol')
   if Options.postol >= 0
      postol = Options.postol;
   else
      warning('postol is negative: will take default postol')
      postol = default_postol;
   end   
else
   postol = default_postol;   
end

if isfield(Options,'integtol')
   if Options.integtol >= 0
      integtol = Options.integtol;
   else
      warning('integtol is negative: will take default integtol')
      integtol = default_integtol;
   end   
else
   integtol = default_integtol;   
end

if isfield(Options,'maxQPiter')
   if Options.maxQPiter >= 1
      maxQPiter = floor(Options.maxQPiter);
   else
      warning('maxQPiter is negative or 0: will take default maxQPiter')
      maxQPiter = default_maxQPiter;
   end   
else
   maxQPiter = default_maxQPiter;   
end

if isfield(Options,'deletefile')
   if Options.deletefile == 1
      deletefile = 1;
   elseif Options.deletefile == 0
      deletefile = 0;
   else
      warning('unallowed value for deletefile: will take default')  
      deletefile = default_deletefile;
   end   
else
   deletefile = default_deletefile;  
end

if isfield(Options,'round')
   if Options.round == 1
      rounding = 1;
   elseif Options.round == 0
      rounding = 0;
   else
      warning('unallowed value for round: will take default')  
      rounding = default_round;
   end   
else
   rounding = default_round;  
end

% checking dimensions  
% -------------------

if size(H,1) ~= size(H,2)
   error('H is not square')
end

if ~isfield(Options,'solver') 
   if max(svd(H)) < matrixtol
      if verbose >= 1
         warning('This is a MILP')
      end
      solver = default_solverlp;  % default solver for LPs
   end
elseif strcmp(Options.solver,'qp_dantz')
   if max(svd(H)) < matrixtol
      error('MILPs cannot be solved with qp_dantz')
   end
end      
if ~(max(max(abs(H-H'))) <= eps^(2/3)*max(max(abs(H)))),
   H=0.5*(H+H');
   if verbose >= 1
      warning('H is not symmetric: replaced by its symmetric part')
   end   
end

if (size(f,1) ~= 1) & (size(f,2) ~= 1)
   error('f must be a vector')
end

if ~isempty(b) & (size(b,1) ~= 1) & (size(b,2) ~= 1)
   error('b must be a vector')
end

f = f(:);   % f and b are column vectors
b = b(:);

nx = size(H,1);
if isempty(b),
    b=zeros(0,1);
end
if isempty(A),
    A=zeros(0,nx);
end

if size(A,1) ~= size(b,1)
   error('A and b have incompatible dimensions')
end

if size(A,2) ~= nx
   error('A and H have incompatible dimensions')
end

if size(Aeq,1) ~= size(beq,1)
   error('Aeq and beq have incompatible dimensions')
end

if (size(Aeq,2) ~= nx)&(~isempty(Aeq))
   error('Aeq and H have incompatible dimensions')
end

lb      = lb(:);
ub      = ub(:);
x0      = x0(:);      
vartype = vartype(:);

if ischar(vartype)
   if length(vartype) ~= nx
      error('wrong dimension of vartype as character array')
   end      
   Ccons = find(vartype=='C');
   Bcons = find(vartype=='B');
   Icons = find(vartype=='I');
   if length([Ccons(:); Bcons(:); Icons(:)]) ~=  nx;
      error('wrong entries in vartype')
   end   
   if ~isempty(Icons)
      error('specifications for integer variables are not supported')
   end
   % deletes the variable in character syntax and uses the syntax with vector
   % of indices instead
   vartype = Bcons(:);
end   

if size(lb,1)~=nx & ~isempty(lb)
   error('lb has wrong dimensions')
end
if size(ub,1)~=nx & ~isempty(ub)
   error('ub has wrong dimensions')
end
if size(x0,1)~=nx & ~isempty(x0)
   error('x0 has wrong dimensions')
end
if max(vartype) > nx
   error('largest index in vartype is out of range')
end
if min(vartype) < 1
   error('smallest index in vartype is out of range')
end
if find(diff(sort(vartype)) == 0)
   error('binary variables are multiply defined')
end   
if length(vartype) > nx
   error('too many entries in vartype') 
end 
if floor(vartype) ~= vartype
   error('fractional number in vartype not allowed')
end     

% Define default values for lb,ub,x0
% ------------------------------------

if isempty(lb),
   lb =-inf*ones(nx,1);
end
if isempty(ub),
   ub = inf*ones(nx,1);
end
if isempty(x0),
   x0  = zeros(nx,1);
end
if find(ub-lb < 0)
   error('infeasible constraints specified in ub and lb')
end   

cont          = (1:nx)';
cont(vartype) = [];       % Indices of continuous variables

% zstar    denotes the best value for the cost function so far          
% QPiter   counts how many times the QP or LP algorithm is invoked            
% nivar    is the total number of integer variables                     
% xstar    denotes the current optimal vector

zstar   = inf;        
xstar   = NaN*ones(nx,1); 
QPiter  = 0;
nivar   = length(vartype);
flag    = 7;		  % by default it is infeasible
optQP   = 0;		  % number of QP where optimum is found

% Initialize parameters for the QP routines
% -----------------------------------------

if strcmp(solver,'qpnag')
   cold   = 1;
   wu     = sqrt(eps);
   orthog = 1;
   lpf    = 0;
   if ~exist('qphess.m')
      fid = fopen('qphess.m','w');
      fprintf(fid,'function [hx] = qphess(n,nrowh,ncolh,jthcol,hess,x)\n' );
      fprintf(fid,'hx=hess*x;\n' );
      term = fclose(fid);
      justcreated = 1;
   else
      justcreated = 0;
   end      
end   

if strcmp(solver,'qp_dantz')
   if (min(lb) > -inf) & (max(ub) < inf)
      xxmax = abs(max(min(lb),max(ub)))*ones(nx,1);
   else
      xxmax = default_xxmax*ones(nx,1);  
   end 
   
   if ~exist('dantzgmp')
      error('the option qp_dantz requires the MPC toolbox')
   end
else
   xxmax = default_xxmax*ones(nx,1);
end   

if strcmp(solver,'lpnag')
   % no parameters
end

if strcmp(solver,'linprog')
   if isfield(Options,'optimset')
      optlinprog = Options.optimset;
   else
      optlinprog = optimset('LargeScale','off','Display','off', ...
         'MaxIter',maxQPiter);
   end			    
end

if strcmp(solver,'quadprog')
   if isfield(Options,'optimset')
      optquadprog = Options.optimset;
   else      
      optquadprog = optimset('LargeScale','off','Display','off', ...
         'MaxIter',maxQPiter);
   end			     
end

% checking whether the bounds 0,1 on the binary variables are already present in
% the problem constraints, if not, add them

aux1         = lb(vartype);
index1       = find(aux1<0);
aux1(index1) = 0;
lb(vartype)  = aux1;

aux2         = ub(vartype);
index2       = find(aux2>1);
aux2(index2) = 1;
ub(vartype)  = aux2;

% The variable STACK is used to store the relaxed QP problems, that are
% generated during the Branch and Bound algorithm. 
% It's global to allow the subroutines at the end of the m-file to access it.
% STACKSIZE denotes the number of subproblems on the stack.          
% For almost all braching 
% strategies STACK has indeed the purpose of a stack (last in, first out).
% For the breadth first strategy however it turns out, that a data structure
% of a queue (first in, first out) is taken on. 

global STACK
global STACKSIZE
global STACKCOST

% Initialization of STACK with the MIQP                                

STACKSIZE = 1;
STACK     = struct('H',H, 'f',f,   'A',A,   'b',b,   'Aeq',Aeq, 'beq',beq, ...
   'e',0, 'lb',lb, 'ub',ub, 'x0',x0, 'vartype',vartype, ...
   'ivalues',-ones(nivar,1), 'level',0, 'xxmax', xxmax );

% the parameters in the structure STACK are:
% H,f         : parameters of the cost function
% A,b,Aeq,beq : parameters of the constraints
% e           : parameter to determine the cost of the optimization problem
% lb,ub,x0,vartype : parameters of the problem as in the original problem
% ivalues : values of the integer variables (vector of length length(vartype) )
% level   : depth of the node in the tree

STACKCOST = 0;    % Array storing the cost of the father problem, ordered in
% decreasing fashion (STACKCOST(1)=largest value)

% ==============================================================================
% Main Loop
% ==============================================================================

while (STACKSIZE > 0)&(QPiter < maxqp)&(flag ~= -1)
   
   % Get the next subproblem from the STACK                            
   subprob = pop;
   
   % Solve the relaxed qp or lp
   if size(subprob.H,1)>0
      
      switch solver
         
      case 'lp'
         % collects all constraints in one matrix and one vector such that
         % the first constraints are equality constraints. Calling lp the
         % first rows of the constraints are declared as equality constraints
         
         swarn = warning;
         warning off;
         [x,lambda,how] = lp(subprob.f, [subprob.Aeq; subprob.A], ...
            [subprob.beq; subprob.b], subprob.lb, subprob.ub, subprob.x0, ...
            size(subprob.Aeq,1));
         warning(swarn); 
         
      case 'linprog'
         
         swarn = warning;
         warning off;
         [x, fval, exitflag, outpu, lambda] = linprog(subprob.f, ...
            subprob.A, subprob.b, subprob.Aeq, subprob.beq, subprob.lb,...
            subprob.ub, subprob.x0, optlinprog);        
         warning(swarn); 
         if exitflag > 0
            how = 'ok'; 
         elseif exitflag == 0
            warning('maximum number of iterations occurred')
            how = 'ok';  
         else
            how = 'infeasible';
            if verbose >= 2
               warning('no distinction whether unbounded or infeasible') 
            end	  
         end 
         
      case 'lpnag'
         if ~isempty(Aeq)
            warning('Equality constraints are not explicitly supported')
            warning('Will switch to Aeq x <= beq, -Aeq x <= -beq')
         end
         blpnag = [ subprob.b; subprob.beq; -subprob.beq ];
         Alpnag = [ subprob.A; subprob.Aeq; -subprob.Aeq ];
         ifail  = 1;
         bl     = [subprob.lb; -inftol*ones(length(blpnag),1)];  
         bu     = [subprob.ub;  blpnag]; 
         
         swarn = warning;
         warning off;
         [x, istate, objlp, clamda, ifail] = e04mbf(bl, bu, subprob.x0, ...
            subprob.f, Alpnag, verbose-1, maxQPiter, ifail);
         warning(swarn); 
         
         switch ifail
         case {-1,0}
            how = 'ok';
         case {2}
            how = 'unbounded';
         case {3,4}
            % might also be considered as infeasible 
            warning('QP is cycling or too few iterations')
            how = 'ok';
         case {1}
            how = 'infeasible';
         otherwise
            error('other error code in ifail from e04mbf')
         end	     
         
      case 'qp'
         if isfield(Options,'postol')
            if verbose >= 1
               if cond(H) <= postol
                  warning('H is close to singularity')
               end   
            end
         end
         % collects all constraints in one matrix and one vector such that
         % the first constraints are equality constraints. Calling lp the
         % first rows of the constraints are declared as equality constraints
         
         swarn = warning;
         warning off;
         [x,lambda,how] = qp(subprob.H, subprob.f, ...
            [subprob.Aeq; subprob.A], [subprob.beq; subprob.b], ...
            subprob.lb, subprob.ub, subprob.x0, size(subprob.Aeq,1));
         warning(swarn); 
         
      case 'quadprog'
         if isfield(Options,'postol')
            if verbose >= 1
               if cond(H) <= postol
                  warning('H is close to singularity')
               end   
            end
         end
         
         swarn = warning;
         warning off;
         [x,fval,exitflag,outpu,lambda] = quadprog(subprob.H, subprob.f, ...
            subprob.A, subprob.b, subprob.Aeq, subprob.beq, subprob.lb, ...
            subprob.ub, subprob.x0, optquadprog);        
         warning(swarn); 
         
         if exitflag > 0
            how = 'ok'; 
         elseif exitflag == 0
            warning('maximum number of iterations occurred')
            how = 'ok';  
         else
            how = 'infeasible';
            if verbose >= 2
               warning('no distinction whether unbounded or infeasible')
            end	  		  
         end
         
      case 'qpnag'
         if isfield(Options,'postol')
            if verbose >= 1
               if cond(H) <= postol
                  warning('H is close to singularity')
               end   
            end
         end
         if ~isempty(Aeq)
            warning('Equality constraints are not explicitly supported')
            warning('Will switch to Aeq x <= beq, -Aeq x <= -beq')
         end
         bqpnag = [ subprob.b; subprob.beq; -subprob.beq ];
         Aqpnag = [ subprob.A; subprob.Aeq; -subprob.Aeq ];	  	    
         bl     = [subprob.lb; -inftol*ones(length(bqpnag),1)];  
         bu     = [subprob.ub;  bqpnag];            
         istate = zeros(length(bu),1);
         featol = wu*ones(length(bu),1);
         ifail  = 1;
         
         swarn = warning;
         warning off;
         [x, iter, obj, clamda, istate, ifail] = ...
            e04naf(bl, bu, 'qphess', subprob.x0, subprob.f, Aqpnag, ...
            subprob.H, lpf, cold,istate, featol, verbose-1, maxQPiter, ...
            inftol, orthog, ifail); 
         warning(swarn); 
         
         switch ifail
         case {0,1,3}
            how = 'ok';
         case 2
            how = 'unbounded';
         case {4,5}
            % might also be considered as infeasible 
            warning('QP is cycling or too few iterations')
            how = 'ok';
         case {6,7,8}
            how = 'infeasible';
         otherwise
            error('other error code in ifail from e04naf')
         end
         
      case 'qp_dantz'
         
         if ~isempty(subprob.Aeq)
            error('this solver does not support equality constraints')
         end   
         
         [x, how] = qp_dantz( subprob.H,   subprob.f, ...
            [subprob.A; eye(length(subprob.f));-eye(length(subprob.f))], ...
            [subprob.b; subprob.ub(:);         -subprob.lb(:)], ...
            subprob.xxmax(:));
         
         if strcmp(how,'feasible')
            how = 'ok';
         end             
         
      otherwise
         error('unknown solver')
         
      end
      QPiter = QPiter + 1;
   else
      x=[];
      if all(subprob.b>=0),
         how = 'ok';
      else
         how = 'infeasible';
      end
   end
   
   if strcmp(how,'unbounded')
      % If the relaxed problem is unbounded, so is the original problem 
      xmin = [];
      fmin = -inf;
      flag = -1;      
      warning('unbounded cost function')
      return
   elseif strcmp(how,'infeasible')
      % subproblem fathomed                                       
   else   
      % subproblem feasible                                      
      
      if ~isempty(x), 
         zpi=.5*x'*subprob.H*x+x'*subprob.f+subprob.e;
      else
         zpi=subprob.e;
      end
      if flag~= 1   % if no integer feasible solution has been found yet,
         flag = 5;  % the problem is now at least feasible
      end
      
      % Check if value function is better than the value so far    
      if zpi<=zstar
         
         xi               = x(subprob.vartype); % integer variables
         xc               = x;
         xc(subprob.vartype) = [];              % continuous variables
         
         % Test whether the relaxed integer variables are feasible,  
         % i.e. whether they are integral. Note that this condition  
         % is always satisfied, if there are no free integer variables,     
         % i.e if vartype is empty  
         
         if norm( round(xi) - xi,inf) < integtol
            % subproblem solved                                   
            % update the value of the cost function              
            zstar             = zpi;
            ifree             = find(subprob.ivalues==-1);
            iset              = find(subprob.ivalues>-1);
            absi              = 1:nx;
            absi(cont)        = [];
            if rounding
               xstar(absi(ifree))= round(xi);
               xstar(absi(iset)) = round(subprob.ivalues(iset));
            else
               xstar(absi(ifree))= xi;
               xstar(absi(iset)) = subprob.ivalues(iset);
            end 
            xstar(cont)       = xc;
            flag              = 1;
            optQP             = QPiter;
         else
            % separate subproblem, if there are still free integer   
            % variables. Note that no further test is required,      
            % whether there are still integer variables, since ixrel 
            % is nonempty                                            
            % branchvar denotes the position of the branching        
            %           integer variable within the set of integer 
            %           variables in the present subproblem          
            branchvar            = decision(x, subprob.vartype, branchrule);
            [p0,p1,zeroOK,oneOK] = separate(subprob, branchvar);
            switch method
            case 'depth'
               cost = 1/(subprob.level+1); 
            case 'breadth'
               cost = subprob.level+1;
            case 'best'
               cost = zpi; % Best-first. This tends to go breadth-first
            case 'bestdepth' 
               cost = zpi/(subprob.level+1); % This privilegiates deep nodes
            end
            if order == 0
               if oneOK
                  push(p1,cost);
               end
               if zeroOK   
                  push(p0,cost);
               end
            else
               if zeroOK
                  push(p0,cost);
               end
               if oneOK
                  push(p1,cost);
               end   
            end  %if order ...
         end  %if norm ... 
      end  %if zpi<=zpstar ...
   end  %if strcmp ...
   
   if (QPiter>=maxqp)
      if (flag == 1) | (flag == 5)
         flag = flag+10; % update flag in case of limit of QPs reached
      end
   end   
   
   % Display present status of the MIQP                               
   if verbose >= 1
      disp('QPiter = ') , disp(QPiter)
      disp('zstar  = ') , disp(zstar)
      disp('xstar  = ') , disp(xstar')
   end
   
end  % while

% final results                                               
xmin   = xstar;
fmin   = zstar;

Extendedflag.QPiter = QPiter;
Extendedflag.optQP  = optQP;
Extendedflag.time   = toc;  

if exist('justcreated')
   if justcreated & deletefile
      delete('qphess.m')
   end   
end   

% ------------------------------------------------------------------------------
% Subroutines                                                           
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
%
% push: puts a subproblem onto the STACK and increases the STACKSIZE    
%       input:  element = record containing the subproblem   
%               cost    = cost of the subproblem, according to this value the
%                         problem will be put on the appropriate place on the
%                         stack 
%       output: none                                                    
%       modifies global variables                                       

function push(element,cost)
global STACK
global STACKSIZE
global STACKCOST

% Determine position in STACK where problem is inserted, according to a best
% first strategy

ii = find(STACKCOST>=cost);  % EX: STACKCOST=[100 80 33 22 ^ 5 3 2], cost=10
if ~isempty(ii),
      % i=ii(end);   
      i=ii(end)+1;  % Corrected. Thanks to D. Axehill 
else
   i=1;
end

for j = STACKSIZE:-1:i
   STACK(j+1)     = STACK(j);
      %STACKCOST(j+1) = cost; 
      STACKCOST(j+1) = STACKCOST(j);    % Corrected. Thanks to D. Axehill 
end
STACK(i)     = element;
STACKSIZE    = STACKSIZE+1;
STACKCOST(i) = cost;

% ------------------------------------------------------------------------------
%
% pop: returns top element of the STACK and decreases the STACKSIZE,    
%      eliminating the element from the stack                           
%      input:  none                                                     
%      output: record containing the top-subproblem                     
%      modifies global variables                                        

function subprob = pop
global STACK
global STACKSIZE
global STACKCOST

subprob        = STACK(STACKSIZE);
STACKSIZE      = STACKSIZE-1;
STACKCOST(end) = [];

% ------------------------------------------------------------------------------
%
% separate: generates 2 new suproblems from a given problem by       
%           branching on an arbitrary variable                       
%           input:  prob=problem to separate                                 
%                   branchvar=branching variable index. The variable 
%                   is x(vartype(branchvar)) in the coordinates of subproblem
%           output: the 2 subproblems in record format        
%                 zeroOK,    if set to one, this flags denote that setting 
%                 oneOK:     the current branching variable to zero (to one)
%                            is compatible with the box constraints lb and ub
%                            of the current relaxed QP. If set to zero, these 
%                            flags denote that the correponding problem should
%                            not be pushed onto the stack, since it is
%                            infeasible in terms of the original constraints

function [p0, p1, zeroOK, oneOK] = separate(prob, branchvar)
if (length(prob.vartype) >= 1)
   nx    = size(prob.H,1);
   this  = prob.vartype(branchvar);
   others= [1:this-1, this+1:nx];
   
   % extract the values of the box bounds for the binary branching variable
   % this is used, to check, whether there are box bounds that do not allow 
   % to set one variable to a particular value
   
   lbbranch = prob.lb(this);
   ubbranch = prob.ub(this);
   
   if (lbbranch <= 0) & (ubbranch >= 0)
      zeroOK = 1;
   else
      zeroOK = 0;
   end
   
   if (lbbranch <= 1) & (ubbranch >= 1)
      oneOK = 1;
   else
      oneOK = 0;
   end   
   
   if (zeroOK == 0) & (oneOK == 0)
      error('box constraints on the binary variables are infeasible')
   end    
   
   % Generate new H                                                  
   % Partition old H into 4 blocks, some of which are possibly empty 
   % Note that the old H itself is not empty                         
   
   H11 = prob.H(others, others);
   H12 = prob.H(others, this);
   H22 = prob.H(this, this);
   
   p0.H = H11;
   p1.H = H11;
   
   % Generate new f                                                  
   % Partition old f into 2 blocks, some of which are possibly empty 
   % Note that a contribution from the partitioning of H is present  
   
   b1  = prob.f(others);
   b2  = prob.f(this);
   
   p0.f = b1;
   p1.f = b1(:)+H12(:);
   
   % Generate new A                                                  
   
   A = prob.A(:,others);
   
   p0.A = A;
   p1.A = A;
   
   % Generate new b                                                  
   % The only modification is a contribution from the matrix A       
   
   p0.b = prob.b;
   p1.b = prob.b - prob.A(:,this);
   
   % Generate new Aeq                                                  
   
   if size(prob.Aeq,2) > 0      
      Aeq    = prob.Aeq(:,others);
      p0.Aeq = Aeq;
      p1.Aeq = Aeq;
   else
      p0.Aeq	= prob.Aeq;
      p1.Aeq = prob.Aeq;
   end	 
   
   % Generate new beq                                                 
   % The only modification is a contribution from the matrix A       
   
   if ~isempty(prob.beq)
      p0.beq = prob.beq;
      p1.beq = prob.beq - prob.Aeq(:,this);
   else
      p0.beq = prob.beq;
      p1.beq = prob.beq;	 
   end
   
   % Generate new e                                                  
   % The only modification is a contribution from H22, b2            
   
   p0.e = prob.e;
   p1.e = prob.e+ .5*H22 + b2;
   
   % Generate new lb,ub,x0                                         
   
   if ~isempty(prob.lb),
      lb = prob.lb(others);
   else
      lb = [];
   end
   p0.lb = lb;
   p1.lb = lb;
   
   if ~isempty(prob.ub),
      ub = prob.ub(others);
   else
      ub = [];
   end
   p0.ub = ub;
   p1.ub = ub;
   
   if ~isempty(prob.x0),
      x0 = prob.x0(others);
   else
      x0 = [];
   end
   p0.x0 = x0;
   p1.x0 = x0;
   
   % Generate new vartype
   
   %EX:              1 2 3 4 5 6 7 8 9 
   %       old_vartype=[    3 4 5     8]'
   %       branchvar=5
   %       newvartype= [    3 4     7]'
   
   vartype = [prob.vartype(1:branchvar-1); ...
         prob.vartype(branchvar+1:length(prob.vartype))-1];
   
   % Collect the terms for the new subproblems                     
   
   p0.vartype = vartype;
   p1.vartype = vartype;
   
   % Find the absolute index of the branching variable
   ifree   = find(prob.ivalues==-1); % Collect free integer variables
   ibranch = ifree(branchvar);       % Pick up the branch variable 
   
   aux         = prob.ivalues;
   aux(ibranch)= 0;
   p0.ivalues  = aux;   
   aux(ibranch)= 1;
   p1.ivalues  = aux;
   
   p0.level = prob.level+1;
   p1.level = prob.level+1;
   
   if ~isempty(prob.xxmax),
      xxmax = prob.xxmax(others);
   else
      xxmax = [];
   end
   p0.xxmax = xxmax;
   p1.xxmax = xxmax;      
   
else
   error('no more integer variables to branch on')
end

% ------------------------------------------------------------------------------
%
% decision: when a problem has to be separated, this function decides   
%           which will be the next branching variable                   
%           input: x       = present value of the solution of the qp            
%                  vartype = indices of the free integer variables relative to x
%                  br      = parameter denoting the branching rule that has to  
%                            be adopted     
%          output: branchvar = next branching variable position within vartype

function branchvar = decision(x,vartype,br);
switch br
case 'first'
   % first free variable is chosen as branching variable        
   branchvar = 1;
case 'max'
   % integer free variable with maximal frac part is 
   % chosen as branching variable          
   xi          = x(vartype);
   [aux1,aux2] = max(abs(xi-round(xi)));
   branchvar   = aux2(1); % pick the first of the variables with max value
case 'min'
   % integer free variable with minimal frac part is 
   % chosen as branching variable          
   xi          = x(vartype);
   [aux1,aux2] = min(abs(xi-round(xi)));
   branchvar   = aux2(1); % pick the first of the variables with max value
otherwise
   % decision not implemented                                   
   warning('decision not implemented: switch to first free');
   branchvar = 1;
end

% ------------------------------------------------------------------------------
%
% isymm: checks symmetry of matrices  
%       input:  Matrix M     
%       output: 1 if symmetric
%               0 otherwise

function [b] = isymm(M)

if size(M,1)~=size(M,2),
   b = 0; 
   return
else
   if max(max(abs(M-M'))) <= eps*max(max(abs(M)))
      b = 1;
   else
      b = 0;   
   end
end   

% ------------------------------------------------------------------------------
%
% QP_DANTZ Quadratic programming 
%         [X,how]=QP(H,f,A,b,xmax) solves the quadratic programming problem:
% 
%                 min 0.5*x'Hx + f'x   subject to:  Ax <= b, -xmax<=x<=xmax
%                  x    
%
%         by using DANTZGMP.M routine of the MPC Toolbox
%
% (C) 1998 by Alberto Bemporad, Z\"urich, 11/2/1998

function [xopt,how] = qp_dantz(H,f,A,b,xmax)

mnu=length(f);
nc =length(b);

% H must be symmetric. Otherwise set H=(H+H')/2
if norm(H-H') > eps
   warning('Your Hessian is not symmetric.  Resetting H=(H+H'')/2')
   H = (H+H')*0.5;
end

a=H*xmax;    % This is a constant term that adds to the initial basis
% in each QP.
H=H\eye(mnu);

rhsc=b+A*xmax;
rhsa=a-f;
TAB=[-H H*A';A*H -A*H*A'];
basisi=[H*rhsa;
   rhsc-A*H*rhsa];
ibi=-[1:mnu+nc]';
ili=-ibi;
[basis,ib,il,iter]=dantzgmp(TAB,basisi,ibi,ili);
if iter < 0
   how='infeasible';
   warning('The constraints are overly stringent. No feasible solution')
else
   how='feasible';
end

xopt=zeros(mnu,1);
for j=1:mnu
   if il(j) <= 0
      xopt(j)=-xmax(j);
   else
      xopt(j)=basis(il(j))-xmax(j);
   end
end

function [taskset] = cycsch(taskset, prob, m, schoptions)
%CYCSCH solves general cyclic scheduling problem.
%
% Synopsis
%    TASKSET = CYCSCH(TASKSET,PROB,M,SCHOPTIONS)
%
% Description
%    Function returns optimal schedule for cyclic scheduling problem
%    defined by parameters:
%      TASKSET:
%               - set of tasks (see CDFG2LHGRAPH)
%      PROB:
%               - description of scheduling problem (object PROBLEM)
%      M:
%               - vector with number of processors
%      SCHOPTIONS:
%               - optimization options (see SCHOPTIONSSET)
%
%    See also GRAPH/CRITICALCIRCUITRATIO, TASKSET/TASKSET, ALGPRJDEADLINEPRECCMAX.


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



if(~is(prob,'notation','CSCH'))
    error('This algorithm solves only ''CSCH'' problem.');
end

if(schoptions.verbose>=1)
    disp(sprintf('ILP based solver of cyclic scheduling problem:'));
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters of tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n=size(taskset);
L=get_tsuserparam(taskset,1,0);
H=get_tsuserparam(taskset,2,inf);
p=taskset.ProcTime;
processors=taskset.Processor;
%Test parameters
if(~isempty(find(~isfinite(processors))))
    processors=ones(1,size(taskset));
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Period (iteration interval) bounds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% (integer) lover bound - "w_lower" %%%
LH_graph=graph('adj',(L~=0)*1);
LHgraph=matrixparam2edges(LH_graph,L,1,0);
LHgraph=matrixparam2edges(LHgraph,H,2);

%%% Lower bound given by critical circuit %%%
w_lower_temp=criticalcircuitratio(LHgraph);
w_lower_temp=round(w_lower_temp*10000)/10000;
w_lower_cycle=ceil(w_lower_temp);

%%% Lower bound given by max. proc time %%%
w_lower_p=0;
for(i=1:max(processors))
    w_lower_p=max(w_lower_p, ceil(sum((processors==i).*p/m(i))) );
end;
w_lower=max(w_lower_cycle,w_lower_p);

%%% (integer) upper bound - "w_upper" %%%
% Earliest start time first strategy
ampl=L-w_lower*H;
scheduled=[];
s=zeros(n,1);
w_upper=0;
for(i=1:n)
    notscheduled=setdiff([1:n],scheduled);              %Set of not scheduled tasks
    jmin=Inf;                                           %Task with earliest possible start time
    sjmin=Inf;                                          %Earliest possible start time
    for(indexj=1:length(notscheduled))
        j=notscheduled(indexj);
        if(isempty(setdiff(find(ampl(:,j)>0),[scheduled j])))
            minStartTime=(s*ones(1,n)+ampl);
            sj=max(w_upper,max(minStartTime(:,j)));    
            if(sj<sjmin)                                %Find a task with earliest possible start time
                sjmin=sj;
                jmin=j;
            end
        end
    end
    if(jmin==Inf)
        error('The input graph contains positive cicle');
    end
    s(jmin)=sjmin;
    w_upper=s(jmin)+p(jmin);
    scheduled=[scheduled jmin];
end

w_upper = max(w_upper,max(max(L,[],2)+s));

if(schoptions.verbose==2)
    disp(sprintf('Period bound w = <%d,%d>',w_lower,w_upper));
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Upper bound of qmax
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

qmax=schoptions.qmax;

if(isempty(qmax))
    qmax=round(2*w_upper/w_lower);
end;
cLb=0;
if(schoptions.verbose==2)
    disp(sprintf('Maximal period overlap q_max=%d',qmax));
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solution by interval bisection method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w=w_lower;
w_low=w_lower-1; w_high=w_upper+1;
iterCounter=0;
totalCompTime=0;
startTime=[];
scheduledProc=[];

while(w>w_low & w<w_high)
    iterCounter=iterCounter+1;
    if(schoptions.verbose>=1)
        disp(sprintf('========== Iteration: %d (w=%d) ==========',iterCounter,w));
    end;
    %One ILP iteration
    switch(schoptions.cycSchMethod)
        case 'integer'
            [sch_res,schProc,extra,cLbNew]=cyc_sch_ilp_int(p,processors,m,L,H,w,qmax,cLb,schoptions);
            
        case 'binary'
            [sch_res,schProc,extra,cLbNew]=cyc_sch_ilp_bin(p,processors,m,L,H,w,qmax,cLb,schoptions);
            
        case 'ims'
            [sch_res,schProc,extra,cLbNew]=cycsch_ims(p,processors,m,L,H,w,qmax,cLb,schoptions);
            
        otherwise
            error(['Unsupported scheduling method ''', schoptions.cycSchMethod , '''.']);
            
    end;
    
    totalCompTime=totalCompTime+extra.time;
    pause(0);
    
    if(isempty(sch_res))
        w_low=w;
        w=ceil((w_low+w_high)/2);
        if(schoptions.verbose>=2)
            disp('Solution: not feasible');
        end;        
    else
        startTime=sch_res;
        scheduledProc=schProc;
        w_high=w;
        cLb=cLbNew;
        w=floor((w_low+w_high)/2);
        if(schoptions.verbose>=2)
            disp('Solution: feasible');
        end;
    end;
end;

if(~isempty(startTime))
    description = ['General cyclic scheduling algorithm (method:' schoptions.cycSchMethod ')'];    
    startTime=round(startTime);
    add_schedule(taskset,description,startTime,p,scheduledProc);
    add_schedule(taskset,'time',totalCompTime,'iteration',iterCounter,'period',w_high);
else
    add_schedule(taskset,'time',totalCompTime);
    if(schoptions.verbose>=1)
        fprintf('There is not a feasible solution.');
    end;
end;


if(schoptions.verbose==2)
    disp('==========================================');
    disp(sprintf('Total computation time: %d, in %d iterations.',totalCompTime,iterCounter));
end;

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function:get_tsuserparam (return n-th parameter from 'taskset.TSUserParam' as a matrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function matrix=get_tsuserparam(taskset,n,default_val)

matrix = default_val*ones(size(taskset));
[i j]=find(taskset.Prec==1);
for k = 1:length(i)
    param=taskset.TSUserParam.EdgesParam(i(k),j(k));
    if(~isa(param,'cell'))
        error('Parameters L,H of precedence constraints are incorrect!');
    end
    if(length(param{:})<n)
        error('Parameters L,H of precedence constraints are incorrect!');
    end
    matrix(i(k),j(k))=param{:}{n};
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function:cyc_sch_ilp_int (Compute cyclic schedule by 'integer' method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [startTime,schProc,extra,fmin]=cyc_sch_ilp_int(p,processors,m,L,H,w,qmax,cLb,schoptions)

n=size(L,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%   Constraints given by graph   %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constr={};             %{:,1}=b(i); {:,2}='<=', '=', '>='; {:,3...}=[id coef]
var={};

% Create variables 's' and 'q'
for(i=1:n)
     var=addvariable(var,'s',i,[],processors(i),0,w-1,'I');     %id of 's' variable is 1:n
end;
for(i=1:n)
     var=addvariable(var,'q',i,[],processors(i),0,qmax,'I');    %id of 'q' variable is n+1:2*n
end;

% Add precedence constraints
A1=[]; A1Right=[];
[k l]=find(L~=0);
for(i=1:length(k))
    constr=addconstraint(constr,(w*H(k(i),l(i))-L(k(i),l(i))),'L',[k(i),l(i),k(i)+n,l(i)+n],[1 -1 w -w]);
    A1Act=zeros(1,n+n);
    A1Act(k(i))=1;   A1Act(k(i)+n)=w;
    A1Act(l(i))=A1Act(l(i))-1;	A1Act(l(i)+n)=A1Act(l(i)+n)-w;
    A1=[A1;A1Act];
    A1Right=[A1Right,(w*H(k(i),l(i))-L(k(i),l(i)))];    
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Restrict multiprocessor solutions %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
varElim=0;
A2Cell={};
 
if(schoptions.varElim==1 & schoptions.verbose>=1)
    fprintf('Optimizing ILP model:');
    drawnow;
end;
 
for(proc=1:length(m))    
    
    %Choice mode of constraints
    tasksOnProc = find(processors==proc);
    if(m(proc)==1)
        mode=1;
    elseif(p(tasksOnProc)==1)
        mode=2;
    else
        mode=3;
    end
    
    for(i=1:n)
        if(schoptions.varElim==1 & schoptions.verbose>=1) 
            fprintf('*');
            drawnow;
        end;
        
        for(j=(i+1):n)
            if(processors(i)==proc & processors(j)==proc)
                
                %%% Test monoprocessor constraint necessity %%%
                testLine=zeros(1,n+1);
                testLine(1,i)=1;
                testLine(1,j)=-1;
                testLine(1,end)=w;
                
                %%% Create ILP model %%%
                if(schoptions.varElim==1)
                    A = sparse([A1(:,1:n) zeros(size(A1,1),1); testLine; -testLine]);
                    lb = zeros(n+1,1); lb(end)=-qmax;
                    ub = [w*(1+qmax)+p, qmax]';
                    vartype=''; vartype(1:n,1) = 'C'; vartype(n+1,1) = 'I';
                    ctype=''; ctype(1:size(A,1),1)='L';
                    b = [A1Right, p(j)-1, p(i)-1]';
                    c = [zeros(1,n), 1]';
                    
                    regularSolver=schoptions.ilpSolver;
                    schoptions.ilpSolver=schoptions.varElimILPSolver;
                    [xmin,fmin,status,extra] = ilinprog(schoptions,1,c,A,b,ctype,lb,ub,vartype);
                    schoptions.ilpSolver=regularSolver;
                else
                    status=1;
                end
                
                if(status==1)
                    
                    if(mode==1)
                        [var id]=addvariable(var,'x',i,j,proc,0,1,'I');                 %Add 'x' variable
                        constr=addconstraint(constr,w-p(i),'L',[j,i,id],[-1 1 w]);      %Add constraints (2) and (3)
                        constr=addconstraint(constr,-p(j),'L',[j,i,id],[1 -1 -w]);                        
                    elseif(mode==2)
                        [var idx]=addvariable(var,'x',i,j,proc,0,1,'I');                %Add 'x' variable
                        [var idy]=addvariable(var,'y',i,j,proc,0,1,'I');                %Add 'y' variable
                        constr=addconstraint(constr,w-p(i),'L',[j,i,idx,idy],[-1 1 w -1]);      %Add constraints (3) and (2)
                        constr=addconstraint(constr,-p(j),'L',[j,i,idx,idy],[1 -1 -w -(1-w)]);                        
                        constr=addconstraint(constr,0,'L',[idx,idy],[-1 1]);            %Add constraint (4)
                    else
                        [var idx]=addvariable(var,'x',i,j,proc,0,1,'I');                %Add 'x' variable
                        [var idy]=addvariable(var,'y',i,j,proc,0,1,'I');                %Add 'y' variable
                        constr=addconstraint(constr,w-p(i),'L',[j,i,idx,idy],[-1 1 w (-p(i)-p(j)+1)]);      %Add constraints (3) and (2)
                        constr=addconstraint(constr,-p(j),'L',[j,i,idx,idy],[1 -1 -w (p(j)-w+p(i)-1)]);                        
                        constr=addconstraint(constr,0,'L',[idx,idy],[-1 1]);            %Add constraint (4)
                    end;
                                        
                else
                    if(mode==1)
                        varElim=varElim+1;
                    else
                        varElim=varElim+2;
                    end;
                end;
                
            end;
        end;
    end;
        
    
    %Bibary variables constraints and relations
    if(mode==2)
        for(i=1:(n-m(proc)))
            ids=findvaringroupwithi(var,'y',proc,i);
            if(~isempty(ids))
                constr=addconstraint(constr,m(proc)-1,'L',ids,ones(1,length(ids)));      %Add constraints (6)
            end
        end;
    end;
    
    
    if(mode==3)
        idy=findvaringroup(var,'y',proc);
        for(yindex=1:length(idy))
            i=var{idy(yindex)}.i;
            j=var{idy(yindex)}.j;
            
            %Create variable z_i,k if not exist jet
            idz1=findvar(var,'z',i,1);
            if(isempty(idz1))
                for(k=1:m(proc))
                    [var idz]=addvariable(var,'z',i,k,proc,0,1,'I');
                end
            end
            
            %Create variable z_k,j if not exist jet
            idz2=findvar(var,'z',j,1);
            if(isempty(idz2))
                for(k=1:m(proc))
                    [var idz]=addvariable(var,'z',j,k,proc,0,1,'I');
                end
            end
            
            for(k=1:m(proc))
                idy1=findvar(var,'y',i,j);
                idz1=findvar(var,'z',i,k);
                idz2=findvar(var,'z',j,k);
                if(isempty(idz1) | isempty(idz2))
                    error('cycsch: Internal error - variable ''z'' does not exist!');
                end
                constr=addconstraint(constr,2,'L',[idy1 idz1 idz2],[1 1 1]);      %Add constraints (5)
            end
            
        end;
        
        for(i=1:n)
            ids=findvaringroupwithi(var,'z',proc,i);
            if(~isempty(ids))
                constr=addconstraint(constr,1,'E',ids,ones(1,length(ids)));      %Add constraints (6)
            end;
        end;
        
    end;
    
    
end;

if(schoptions.varElim==1 & schoptions.verbose>=1)
    fprintf('\n');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Restrict multiprocessor solutions %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constr=addconstraint(constr,cLb,'G',n+1:2*n,ones(1,n));      %Add objective function constraint


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Prepare parameters and solv it   %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=[]; b=[]; ctype=''; lb=[]; ub=[]; vartype=''; c=[];

for(i=1:length(constr))
    for(j=1:length(constr{i}.variables))
        A(i,constr{i}.variables(j))=constr{i}.coef(j);
    end
    ctype(i,1)=constr{i}.type;
    b(i,1)=constr{i}.b;
end

for(i=1:length(var))
    lb(i,1)=var{i}.min;
    ub(i,1)=var{i}.max;
    vartype(i,1)=var{i}.type;
end

c = [zeros(1,n), ones(1,n), zeros(1,size(A,2)-2*n)]';

if(schoptions.verbose==2)
    disp(sprintf('Current ILP model contains %d variables and %d constraints.',size(A,2),size(A,1)));
    if(schoptions.varElim==1)
        disp(sprintf('Number of eliminated variables: %d',varElim));
    end;
end;

[xmin,fmin,status,extra] = ilinprog(schoptions,1,c,A,b,ctype,lb,ub,vartype);
if(status==1)
    startTime=xmin(1:n)'+w*xmin((n+1):2*n)';
    
    schProcessor=1;
    schProc=zeros(1,n);
    for(proc=1:length(m))
        
        %Choice mode of constraints
        tasksOnProc = find(processors==proc);
        if(m(proc)==1)
            mode=1;
        elseif(p(tasksOnProc)==1)
            mode=2;
        else
            mode=3;
        end    
        
        %Assign tasks to processor accordin to scheduling results
        scheduleCapacity=zeros(1,w);            %Schedule capacity
        for(i=1:length(tasksOnProc))
            Ti=tasksOnProc(i);
            if(mode==1)
                schProc(Ti)=schProcessor;
            elseif(mode==2)
                schProc(Ti)=schProcessor+scheduleCapacity(xmin(Ti)+1);
                scheduleCapacity(xmin(Ti)+1)=scheduleCapacity(xmin(Ti)+1)+1;            %Increase schedule capacity
                if(scheduleCapacity(xmin(Ti)+1)>m(proc))
                    error('cycsch: Internal error - resource capacity volation!!!');
                end
            else
                for(k=1:m(proc))
                    id=findvar(var,'z',Ti,k);
                    if(xmin(id)==1)
                        schProc(Ti)=k-1+schProcessor;
                    end;
                end;
            end;
        end;
        
        schProcessor=schProcessor+m(proc);      %Increase id of processor
    end

    %Assign rest of tasks
    scheduleUtilization=zeros(sum(m),w);
    %Assign assigned tasks
    for(i=1:n)
        if(schProc(i)~=0)
            for(procCount=1:p(i))
                scheduleUtilization(schProc(i),mod(startTime(i)+procCount,w)+1)=1;
            end;
        end;
    end;
            
    %Assign tasks without assignement
    for(i=1:n)
        if(schProc(i)==0)
            lastProc=sum(m(1:processors(i)));
            firstProc=lastProc-processors(i);
            for(procCount=0:p(i)-1)
                scheduleUtilizationIndeces(procCount+1)=mod(startTime(i)+procCount,w)+1;
            end;
            for(procIndex=firstProc:lastProc)
                if(scheduleUtilization(procIndex,scheduleUtilizationIndeces)==0)
                    schProc(i)=procIndex;
                    scheduleUtilization(schProc(i),scheduleUtilizationIndeces)=1;
                    break;
                end;
            end;
        end;
    end;
    
    
    if(schoptions.verbose==2)
        disp(sprintf('Feasible solution has been found (fmin=%d).',fmin));
    end;
else
    startTime=[];
    schProc=[];
end;

if(schoptions.verbose==2)
    disp(sprintf('Computation time of the iteration: %d',extra.time));
end;


return;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                     Auxiliary functions                   %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Add new variable
function [var,id]=addvariable(var,name,i,j,group,min,max,type)
% struct variables
% {
%     char name;        /*name of variable*/
%     int i,j;          /*indices*/
%     int min,max;      /*range*/
%     int group;        /*group of processors*/
%     char type;        /**/
% }
var={var{:} struct('name',name,'i',i,'j',j,'group',group,'min',min,'max',max,'type',type)};
id=length(var);

return

%Find one variable
function id=findvar(var,name,indexi,indexj)
id=[];
for(i=1:length(var))
    if(var{i}.name==name & var{i}.i==indexi & var{i}.j==indexj)
        id=i;
        break;
    end;
end;
return;

%Find one kind of variables from specified group
function id=findvaringroup(var,name,group)
id=[];
for(i=1:length(var))
    if(var{i}.name==name & var{i}.group==group)
        id=[id i];
    end;
end;
return;


%Find one kind of variables from specified group (with one specific index i)
function id=findvaringroupwithi(var,name,group,indexi)
id=[];
for(i=1:length(var))
    if(var{i}.name==name & var{i}.group==group & var{i}.i==indexi)
        id=[id i];
    end;
end;
return;


%Find one kind of variables from specified group (with one specific index j)
function id=findvaringroupwithj(var,name,group,indexj)
id=[];
for(i=1:length(var))
    if(var{i}.name==name & var{i}.group==group & var{i}.j==indexj)
        id=[id i];
    end;
end;
return;

%Add new constraint
function [constr]=addconstraint(constr,b,type,variables,coef)
%{:,1}=b(i); {:,2}='<=', '=', '>='; {:,3...}=[id coef]
constr={constr{:} struct('b',b,'type',type,'variables',variables,'coef',coef)};
return








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function:cyc_sch_ilp_bin (Compute cyclic schedule by 'binary' method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sch_res,schProc,extra,cLbNew]=cyc_sch_ilp_bin(p,processors,m,L,H,w,qmax,cLb,schoptions)

n=size(L,1);
mode = [];
constr={};             %{:,1}=b(i); {:,2}='<=', '=', '>='; {:,3...}=[id coef]
var={};

for(proc=1:length(m))    
    
    %Choice mode of constraints
    tasksOnProc = find(processors==proc);
    if(m(proc)==1)
        mode=[mode 1];
    elseif(p(tasksOnProc)==1)
        mode=[mode 2];
    else
        mode=[mode 3];
    end
end

mode = max(mode);


if(mode<3)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Model x_{i,j}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constraints given by graph
    % sj+qj-si-qi <= l_ij - w.h_ij
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A1=[]; A1Right=[];
    
    [k l]=find(L~=0);
    
    for(i=1:length(k))
        A1Line=zeros(1,n*w+n);
        A1Line((1:w)+(k(i)-1)*w)=0:(w-1);
        A1Line((1:w)+(l(i)-1)*w)=-(0:(w-1));	
        A1Line(n*w+k(i))=w;
        A1Line(n*w+l(i))=-w;
        
        A1=[A1;A1Line];
        A1Right=[A1Right,(w*H(k(i),l(i))-L(k(i),l(i)))];
    end;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Task constraint
    % sum(x_ij)=1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A2=[]; A2Right=[];
    
    for(i=1:n)
        A2Line=zeros(1,n*w+n);
        A2Line((1:w)+(i-1)*w)=1;
        A2Right=[A2Right 1];
        A2=[A2;A2Line];
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Processor constraint
    % sum(x_ij)<=m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A3=[]; A3Right=[];
    
    rotation=[2:w 1];
    rotationMatrix=ones(n,1)*rotation;
    
    for(k=1:length(m))
        
        A3Rot=zeros(n,w);
        
        for(j=1:n)
            if(processors(j)==k)
                A3Rot(j,(end+1-p(j):end))=1;
            end;
        end;
        
        for(i=1:(w+1))
            A3Line=zeros(1,n*w+n);
            for(j=1:n)
                A3Rot(j,rotationMatrix(j,:))=A3Rot(j,:);
            end;
            A3RotTrans=A3Rot';
            A3Line(1:n*w)=A3RotTrans(:);
            A3Right=[A3Right m(k)];     %First machine
            A3=[A3;A3Line];
        end;
    end;
    
    numVarX=n*w;
    
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Model x_{i,j,k}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numVarX=0;          %number of variables x
    varXindeces = {};    %start index of variables x
    tmp=1;
    for(i=1:n)
        varXindeces{i} = tmp:(tmp+m(processors(i))-1);
        tmp = tmp + m(processors(i));
        numVarX = numVarX + m(processors(i))*w;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constraints given by graph
    % sj+qj-si-qi <= l_ij - w.h_ij
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A1=[]; A1Right=[];
    [k l]=find(L~=0);
    
    for(i=1:length(k))
        kk=k(i);
        ll=l(i);
        A1Line=zeros(1,numVarX+n);
        for(j=varXindeces{kk})
            A1Line((1:w)+(j-1)*w)=0:(w-1);
        end

        for(j=varXindeces{ll})
            A1Line((1:w)+(j-1)*w)=-(0:(w-1));
        end
        
        A1Line(numVarX+k(i))=w;
        A1Line(numVarX+l(i))=-w;
        
        A1=[A1;A1Line];
        A1Right=[A1Right,(w*H(kk,ll)-L(kk,ll))];
    end;
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Task constraint
    % sum(x_ijk)=1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A2=[]; A2Right=[];
    
    for(i=1:n)
        A2Line=zeros(1,numVarX+n);
        for(j=varXindeces{i})
            A2Line((1:w)+(j-1)*w)=ones(1,w);
        end        
        %A2Line((1:w)+(i-1)*w)=1;
        A2Right=[A2Right 1];
        A2=[A2;A2Line];
    end;
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Processor constraint
    % sum(x_ijk)<=1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A3=[]; A3Right=[];
    
    rotation=[2:w 1];
    rotationMatrix=ones(numVarX/w,1)*rotation;
    
    for(k=1:length(m))
        
        A3Rot=zeros(numVarX/w,w);
        A3Temp=[]; A3RightTemp=[];
        
        for(j=1:n)
            if(processors(j)==k)
                %for(i=varXindeces{j})
                i=varXindeces{j}(1);
                A3Rot(i,(end+1-p(j):end))=1;
                %end        
            end;
        end;
        
        for(i=1:(w+1))
            A3Line=zeros(1,numVarX+n);
            for(j=1:numVarX/w)
                A3Rot(j,rotationMatrix(j,:))=A3Rot(j,:);
            end
            A3RotTrans=A3Rot';
            A3Line(1:numVarX)=A3RotTrans(:);
            
            A3RightTemp=[A3RightTemp 1];
            A3Temp=[A3Temp;A3Line];
        end;
        
        %Shift constraint over processors
        for(j=1:m(k))     
            A3Right=[A3Right A3RightTemp];
            A3=[A3;A3Temp];
            A3Temp=A3Temp(:,mod(-1-w+(1:size(A3Temp,2)),size(A3Temp,2))+1);
        end
        
    end;
    
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare parameters ILP representation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A = sparse([A1;A2;A3]);
lb = zeros(size(A,2),1);
ub = ones(size(A,2),1);
ub(numVarX+1:numVarX+n)=qmax;
vartype(1:size(A,2),1)='I';
b = [A1Right, A2Right, A3Right]';
ctype(1:size(A,1),1)='L';
ctype(size(A1,1)+1:size(A1,1)+size(A2,1),1)='E';

c = zeros(1,size(A,2))';
c(numVarX+1:numVarX+n)=1;


if(schoptions.verbose==2)
    disp(sprintf('Current ILP model contains %d variables and %d constraints.',size(A,2),size(A,1)));
end;

[xmin,fmin,status,extra] = ilinprog(schoptions,1,c,A,b,ctype,lb,ub,vartype);
if(status==1)
    
    if(mode<3)
        for(i=1:n)
            sHat(i)=(0:(w-1))*xmin((1:w)+w*(i-1));
        end;
        qHat=xmin((numVarX+1):(numVarX+n))';
        
        sch_res=(sHat+qHat*w);    
        
        scheduleUtilization=zeros(sum(m),w);
        schProc=zeros(1,n);
        
        %ListScheduling algorithm
        %     for(i=1:n)
        %         for(j=i+1:n)
        % TAK TED OPRAVDu NEVIL:-(            
        %         end;
        %     end;
        
    else
        for(i=1:n)
            varXindecesI = varXindeces{i};
            sHat(i)=-inf;
            procCounter=sum(m(1:(processors(i))))-m(processors(i))+1;
            for(j=varXindecesI)
                if(any(xmin((1:w)+w*(j-1))))
                    sHat(i)=(0:(w-1))*xmin((1:w)+w*(j-1));
                    schProc(i)=procCounter;
                end
                procCounter=procCounter+1;
            end
        end
        qHat = xmin((numVarX+1):(numVarX+n))';
        
        sch_res=(sHat+qHat*w);
    end
    
    cLbNew=sum(qHat);
    
    if(schoptions.verbose==2)
        disp(sprintf('Feasible solution has been found (fmin=%d).',fmin));
    end;
    
else
    sch_res=[];
    schProc=[];
    cLbNew=[];
end;



return

% end .. CYCSCH

function [taskset] = spntl (taskset, prob, schoptions)
% SPNTL computes schedule with Positive and Negative Time-Lags
%
% Synopsis
%           TS = SPNTL(T,PROB,SCHOPTIONS)
%
% Description
%	TS = SPNTL(T,PROB,SCHOPTIONS) returns the optimal schedule TS of set
%   of tasks defined in T for scheduling problem 'SPNTL' defined in PROB
%   (object PROBLEM). Parameter SCHOPTIONS specifies an extra optimization
%   options.
%
% See also ILINPROG, SCHOPTIONSSET, BRATLEY, CYCSCH.


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


if ~(is(prob,'notation','SPNTL'))
    error('This algorithm solves only ''SPNTL'' problem.');
end

W=get_tsuserparam(taskset,1);
p=taskset.ProcTime;
m=taskset.Processor;
%Test parameters
if(~isempty(find(~isfinite(m))))
    m=ones(1,size(taskset));
end;

%Cmax Upper bound
Wpos=(W>0).*W;
CMAXINF=sum(max(max(W'),p));
if(schoptions.verbose==2)
    disp(sprintf('Upper bound of Cmax is %d.',CMAXINF));
end;

switch(schoptions.spntlMethod)
    case 'BaB'
        [startTime CPUTime]=spntl_bab(p,m,W,CMAXINF,schoptions.verbose);
        description = 'SPNTL - BaB algorithm';
        if(all(startTime<0))
            startTime = [];     %No feasible schedule has been found.
        end

    case 'BruckerBaB'
        for i=1:size(W,1)
            for j=1:size(W,1)
                if(i~=j && W(i,j)==0)
                    W(i,j)=-inf;
                end
            end
        end
        startTime=spntlbrucker(p,W,schoptions.verbose);
        description = 'SPNTL - Brucker''s BaB algorithm';
        time=[];            %TODO: Dodelat mereni casu v Bruckerove alg.

    case 'ILP'
        [startTime CPUTime]=spntl_ilp(p,m,W,CMAXINF,schoptions);
        description = 'SPNTL - ILP based algorithm';

    otherwise
        error('Unknown method!');
end

if(~isempty(startTime))
    add_schedule(taskset,description,startTime,p);
    add_schedule(taskset,'time',CPUTime);
end





%function:get_tsuserparam (return n-th parameter from 'taskset.TSUserParam' as a matrix)
function matrix=get_tsuserparam(taskset,n)

matrix = zeros(size(taskset));
[i j]=find(taskset.Prec==1);
for k = 1:length(i)
    param=taskset.TSUserParam.EdgesParam(i(k),j(k));
    matrix(i(k),j(k))=param{n}{:};
end






%function:spntl_ilp (Compute schedule with Positive and Negative Time-Lags by ILP)
function [startTime,CPUTime]=spntl_ilp(p,m,W,CMAXINF,schoptions)

n=size(W,1);
WPos=W.*(W>0);
WLong=floyd(graph('adj',WPos));


%%%%%% Constraints given by graph %%%%%
A1=[];
A1Right=[];

[k l]=find(W~=0);
for i=1:length(k)
    A1Act=zeros(1,n);
    A1Act(k(i))=1;
    A1Act(l(i))=-1;
    A1=[A1;A1Act];
    A1Right=[A1Right,(-W(k(i),l(i)))];
end;



%%%%% Restrict multiprocessor solutions %%%%%
A2=[];
A2aRight=[];
A2bRight=[];
restr=0;						%Number of monoprocessor restrictions

for i=1:n
    for j=(i+1):n
        if(~isfinite(WLong(i,j)) && ~isfinite(WLong(j,i)) && m(i)==m(j))
            A2Act=zeros(1,n);
            A2Act(1,i)=1;
            A2Act(1,j)=-1;
            A2=[A2;A2Act];
            A2aRight=[A2aRight CMAXINF-p(i)];
            A2bRight=[A2bRight -p(j)];
            restr=restr+1;
        end;
    end;
end;

A1=[A1, zeros(size(A1,1),restr),zeros(size(A1,1),1)];		%Add zeros for variables 'x' and 'Cmax' (resize matrix A1)
A2=[A2, diag(CMAXINF*ones(1,restr)),zeros(restr,1)];		%Add variable 'x' and 'Cmax' to restriction


%%%%% Cmax %%%%%

last=find(sum(WPos,2)==0);
A3=[zeros(length(last),n+restr),-ones(length(last),1)];

for i=1:length(last)
    A3(i,last(i))=1;
end;

A3Right=-p(last);


%%%%% Prepare parameters and solv it %%%%%
A = sparse([A1;A2;-A2;A3]);
lb = zeros(n+restr+1,1);
ub = [(CMAXINF-1)*ones(1,n), ones(1,restr), CMAXINF]';
vartype=''; vartype(1:(n+restr+1),1) = 'I';
ctype=''; ctype(1:size(A,1),1)='L';
b = [A1Right, A2aRight, A2bRight, A3Right]';

%%% Objective function %%%
c = [zeros(1,n),zeros(1,restr),1]';				%Minimize Cmax

if(schoptions.verbose>=1)
    disp(sprintf('Current ILP model contains %d variables and %d constraints.',size(A,2),size(A,1)));
end;

[xmin,fmin,status,extra] = ilinprog (schoptions,1,c,A,b,ctype,lb,ub,vartype);
if(~isempty(xmin))
    startTime=xmin(1:n)';
    startTime=round(startTime*1000)/1000;
else
    startTime = [];
end
CPUTime=extra.time;

return;


% end .. SPNTL

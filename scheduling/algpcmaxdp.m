function [TS] = algpcmaxdp(T, prob, No_Proc)

% ALGPCMAXDP  computes schedule for 'P||Cmax'problem using dynamic
% programming
%
% Synopsis
%   TS = algpcmaxdp(T, problem, No_Proc)
%
% Description
%	TS = algpcmaxdp(T, problem, No_Proc) finds schedule of scheduling problem 'P||Cmax'.
%    Parameters:
%     T:
%       - input set of tasks
%     TS:
%       - set of tasks with a schedule
%     PROBLEM:
%       - description of scheduling problem (object PROBLEM) - 'P||Cmax', 
%     No_Proc:
%       - number of processors for scheduling  
%
% See also ALGPRJDEADLINEPRECCMAX, MCNAUGHTONRULE, HU, LISTSCH.

% Author: S. Privara
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


%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 m = No_Proc;  %number of processors
 n = size(T); %number of tasks
 p=T.ProcTime; %processing times
 x=zeros(1,m); 
 indexer=zeros(1,length(p)+1); 
 C = schparam(listsch(T,problem('P|prec|Cmax'),No_Proc),'Cmax');      %Calculate Upper bound of Cmax
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
if ~(is(prob,'alpha','P') && is(prob,'betha','') && is(prob,'gamma','Cmax') && (m > 0))
    error('This problem can''t be solved by this algorithm or number of processors is smaller than zero');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indexer(1)=1;
memory=0;

for i=1:n
    [temp,mem]=expand(x(indexer(i):end,:),p(i),indexer(i),C);
    indexer(i+1)=size(x,1)+1;
    [coordinates,Cmax]=findC(temp);
    memory=[memory,mem]; %#ok<AGROW>
    x=[x;temp]; %#ok<AGROW>
end;
coordinates=coordinates-1+indexer(end); 
schedule=findSchedule(x,indexer,coordinates,memory);
[startTime,procTime,processorSchedule]=planSchedule(schedule);
add_schedule(T,'Dynamic Programming for P||Cmax',startTime,procTime,processorSchedule);
TS=T;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function [expanded,memory] = expand(toExpand,jump,ind,C)
expanded=[];
memory=[];
for i=1:size(toExpand,1);
    temp=zeros(size(toExpand,2),size(toExpand,2));
    mem=zeros(1,size(temp,1));
    feasible = [];
    for j=1:size(temp,1)
        temp(j,:)=toExpand(i,:);
        temp(j,j)=temp(j,j)+jump;
        if(temp(j,j) <= C)
            feasible(end+1) = j;
        end
        mem(j)=ind-1+i;
    end
    %Add new points to space of solutions with Cmax <=C
    memory=[memory,mem(feasible)];          %Indices to previous partial solution
    expanded=[expanded;temp(feasible,:)];   %A partial solutions
end;
%<<<<<<<<<<<<<<<<<<<<<Alternative, but slower!!!!>>>>>>>>>>>>>>>>>>>>>>>>>>>
% function [expanded,memory] = expand(toExpand,jump,ind)
% expanded=[];
% memory=[];
% 
% for i=1:size(toExpand,1);
% temp=repmat(toExpand(i,:),size(toExpand(i,:),2),1);
% temp=temp+jump*eye(size(toExpand(i,:),2));
% expanded=[expanded;temp]; %#ok<AGROW>
% memory=[memory, (ind-1+i)*ones(1,size(temp,2))];%#ok<AGROW>
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function [coordinates,Cmax]=findC(matrix)
vector=max(matrix,[],2);
[Cmax,coordinates]=min(vector);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function schedule = findSchedule(matrix,indexer,coord,mem)
schedule=[];
temp=zeros(1,length(indexer));
temp(1)=coord;
for i=1:length(indexer)-1,
   temp(i+1)=mem(temp(i));
   schedule=[matrix(temp(i),:);schedule]; %#ok<AGROW>
end 
schedule=[matrix(temp(end),:);schedule]; %#ok<AGROW>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function [startTime,procTime,processorSchedule] = planSchedule(matrix)
proc=zeros(size(matrix,2),size(matrix,1)-1);
schedCPU=zeros(size(matrix,2),size(matrix,1)-1);
start=zeros(size(matrix,2),size(matrix,1)-1);

for i=1:size(matrix,2)
    proc(i,:)=diff(matrix(:,i));
    schedCPU(i,(proc(i,:))>0)=i;
    temp=matrix(1:end-1,i)';
    start(i,schedCPU(i,:)==i)=temp(schedCPU(i,:)==i);
end
procTime=sum(proc,1);
processorSchedule=sum(schedCPU,1);
startTime=sum(start,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

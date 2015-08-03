function [TS] = alg1sumwjdj(T, prob)
% ALG1SUMWJDJ  computes schedule for 'P||sum(wj.Dj)'problem
%
% Synopsis
%   TS = alg1sumwjdj(T, problem)
%
% Description
%	TS = alg1sumwjdj(T, problem) finds schedule of scheduling problem 'P||sum(wj.Dj)'.
%    Parameters:
%     T:
%       - input set of tasks
%     TS:
%       - set of tasks with a schedule
%     PROBLEM:
%       - description of scheduling problem (object PROBLEM) - 'P||sum(wj.Dj)', 
%
% See also ALG1RJCMAX, ALG1SUMUJ, SPNTL.


% Author: Jan Zahradnik <zahraj1@fel.cvut.cz>
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
if ~(is(prob,'alpha','1') && is(prob,'betha','') && is(prob,'gamma','sumwjDj'))
    error('This problem can''t be solved by alg1sumwjdj algorithm.');
end

n = length(T.ProcTime);
TT = [T.ProcTime; T.DueDate; T.Weight; 1:n];
[TT] = sequence(0, TT);

TS = T;
s = zeros(1,n);
t = 0;
for i=1:n
    s(TT(4,i)) = t;
    t = t + TT(1,i);
end
description = 'alg1sumwjdj algorithm for 1||sumwjDj';
add_schedule(TS,description,s,T.ProcTime);      %Add schedule into taskset

return



%%
function [ Smin ] = sequence( t, T)

%Return empty set if the input set is empty.
if isempty(T)
    Smin=[];
    return;
end

minDw=Inf;      %Value of the objective function of the best sub-schedule found.

%Find a task with maximum processing time.
[maxValue,indexK]=max(T(1,:));

for ro=indexK:size(T,2)
    %Solve sub-schedule T1
    t1=t;
    T1=T(:,[1:(indexK-1) (indexK+1):ro]);
    S1= sequence(t1,T1);

    %Solve sub-schedule T2
    t2=t+sum(T(1,1:ro));
    T2=T(:,ro+1:size(T,2));
    S2= sequence(t2,T2 );

    %Construct sub-schedule
    S = [S1 T(:,indexK) S2];

    %compute value of objective function Dw
    Dw=0;
    endTime=t;
    for i=1:size(S,2)
        endTime=endTime+ S(1,i);
        if(endTime > S(2,i))
            Dw=Dw+((endTime-S(2,i))*S(3,i));
        end
    end

    %vyber Smin
    if Dw<minDw
        minDw=Dw;
        Smin=S;
    end
end

return;

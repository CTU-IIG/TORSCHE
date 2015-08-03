function usedSubject = knapsackDP(weight,cost,maxWeight)
% KNAPSACK is a function, which solves a knapsack problem.
%
%Synopsis
%         USEDSUBJECT = KNAPSACK(WEIGHT,COST,MAXWEIGHT)
%Description
% Inputs are weight, which are a weights of all the subjects and cost are their prices. MaxWeight is a maximum weight, which is a possible to infill to the knapsack .
% You have to fill all the parameters.
%
%Example
% >> weight = [7 6 4 3];
% >> cost = [2 3 4 5];
% >> maxWeight = 15;
% >> usedSubject = knapsack(weight,cost,maxWeight)
%
% See also FLOYD


% Author: Elvira  Hanakova <hanake1@fel.cvut.cz>
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


if nargin ~= 3
    error ('TORSCHE:graph:wrongNumberOfParameter',...
        'Function knapsack has 3 inputs parameters!');
end
if length(weight)~=length(cost)
    error ('TORSCHE:graph:wrongInputsParameters',...
        'Inputs parameters cost and weight has to be of same length!');
end
%% ALGORITHM
% knapsack algorithm
% Input: Nonnegative integers n, c_1,...,c_n, w_1,...,w_n and W.
% Output: A subset S \subseteq (1,...,n)such that \sum_{j\inS}w_i \leq W
% and \sum_{j\inS}c_i is maximum.
% Ref: lit-Korte, page 419
%% 1 Let C be any upper bound on the value of the optimum solution, e.g. C:=\sum_{j=1}^{n}{c_j}
C = sum(cost);
%% 2 Set x(0,0):=0 and x(0,k):=\infty for k:=1,...,C
x =inf([length(cost)+1,C]);
x(1,1)=0;
x(1,2:C)=inf;
%%
s = inf([length(cost)+1,C]);
%% 3 For j:=1 to n do:
for j=2:(length(cost)+1)
%%  For k:=0 to C do:
    for k=1:C
%% Set s(j,k):=0 and x(j,k):=x(j-1,k).
        if j>1 && s(j-1,k)==1
           s(j,k)=1;
        else s(j,k)=0;
        end
        if k>1
            x(j,k)= x(j-1,k);
        else
            x(j,k)= 0;
        end
    end
%% For k:=c_j to C do:    
    for k=cost(j-1):C
%% If x(j-1,k-c_f)+w_f\leqmin\{W, x(j,k)} then:        
        if k-cost(j-1)>0 && x(j-1,k-cost(j-1))+weight(j-1)<=min([maxWeight (min(min(x(j-1,k))))])
%% Set x(j,k):=x(j-1,k-c_j)+w_j and s(j,k):=1.            
            s(j,k) = 1;
            x(j,k) = (x(j-1,k-cost(j-1))+weight(j-1));
%%
        end
    end
end
zeros=find(x(length(cost)+1,:) == inf);
x(length(cost)+1, zeros) = 0 
%% Let k=max\{i\in\{0,...,C}:x(n,i)\lt\infty}.Set S:=\varnothing.
[val i] = max(x(length(cost)+1,:));
usedSubject=[];
%% for j:=n downto 1 do:
j=(length(cost)+1);
while j>=1 && i>=1
%% If s(j,k)=1 then set S:=S\cup\{j} and k:=k-c_j    
    if s(j,i)==1
        usedSubject = [usedSubject j-1];
        i = i-cost(j-1);
    end
    j = j-1;
end


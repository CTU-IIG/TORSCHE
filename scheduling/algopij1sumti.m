function sh = algopij1sumti (sh, problem)
%ALGOPIJ1SUMTI computation of schedule for problem 'O|pi=1|SumTi' described
% in P. Brucker, Scheduling Algorithms, Springer, 4.Edition, p:171-174, 2004.
% (A slight modification on line 6 (in Brucker, ...) have been made 
% (see (*) in code below).
%
% Synopsis
%	sh = ALGOPIJ1SUMTI(s, p)
%
% Description
%  Compute schedule for input shop s and problem p. The output is also shop
%  object with schedule.
%
% Example
%  >>DueDates = [3 2 4 3 2];%Due dates for each job
%  >>S = shop(ones(5,3),ones(5,3));
%  >>%Processing time and dedicated processor is redundant information in this case
%  >>pr = problem('O|pij=1|SumTi');
%  >>S.DueDate = DueDates;
%  >>S = algopij1sumti(S,pr);
%  >>plot(S);
%
% See also SHOP/SHOP SHOP/PLOT PROBLEM/PROBLEM.


% Author: Jiri Cigler <ciglej1@fel.cvut.cz>
% Author: Marek Vachule
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


if ~isa(sh,'shop')
	error('TORSCHE:algopij1sumti:invalidParam','First parameter should be shop object')
end

di = zeros(size(sh.jobs));
for i=1:size(di,2)
	di(i)=sh.jobs(i).DueDate;
end
if ~issquare(sh)
	error('TORSCHE:algopij1sumti:invalidParam','Input shop object must have same lenght of job ')
end
m = size(sh.jobs(1),2);

n = length(di);             %n number of jobs

processor = [];
startTimes = [];
procTime = ones(n,m);

[d reindex] = sort(di);     %sort tasks according their duedates

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

h = zeros(1,m + n - 1);     %initialize "frequency values"

for i=1:n
    if  d(i) < m + i -1
        z = 0;
        for t=1:d(i)
            if h(t)< m             %z is number of time slots with h(t) < m (t=1:d(i))
                z = z+1;              %calculate the number z
            end
        end
        if z >=m
            Ti=d(i);
        else
            %(*) In thic case Ti is evaluated in different way (originaly Ti=d(i)+m-z).
            for t=d(i)+1:length(h)
                if h(t)< m         %find interval <1,t> where job i can be placed
                    z = z+1;
                end
                if(z==m)
                    break
                end
            end
            Ti=t;                   %(it neads revision!!!)
        end
    else
        Ti=m+i-1;
    end

    [foo,t] = sort(h(1:Ti));        %find first m time slots with smallest h(t)
    t = (t(1:m));

    %schedule job i (reindex(i))
    for j=1:m
        startTimes(reindex(i),j) = (t(j)-1);
        h(t(j))=h(t(j))+1;
    end
end

%Assign tasks of jobs to processors
A=zeros(n,n+m+1);
for i=1:n
    A(i,startTimes(i,:)+1)=1;
end
colors = edgecoloring(A);

for i=1:n
    processor(i,:)= colors(i,startTimes(i,:)+1);
end


%Create shop object
description = 'Schedule for open shop ';
%sh = shop(procTime,processor);
sh.Processor = processor;
sh.Type = 'O';
add_schedule(sh,description,startTimes,procTime,processor);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [colors] = edgecoloring(A)
%Edge coloring of bipartite graphs
%Input parameter is a bipartite graph G = (V union W,A) given by a matrix A,
%where a_{v_i,w_j}=1 iff there is an edge between v_i in V and w_j in W.
%
%Taken from P. Brucker: Scheduling Algorithms, Springer, 4.edition, 2004.


colors = zeros(size(A));    %resulting edge

n=size(A,1);                %size(V)
m=size(A,2);                %size(W)

for i=1:n
    for j=1:m
        if(A(i,j)~=1)
            continue;
        end
        notAssignedColors = setdiff(1:m,colors(:,j));
        c = notAssignedColors(1);       %c is firs not assigned color in column j
        if(~isempty(find(colors(i,:)==c)))
            colors(i,j) = c;            %Assign color c to A(i,j)
            notAssignedColors = setdiff(1:n,colors(i,:));        
            c2 = notAssignedColors(1);  %c2 is first not assigned color in row i
            colors = conflicts(colors,i,j,c,c2);
        else
            colors(i,j) = c;            %Assign color c to A(i,j)
        end
    end
end

return


%conflicts resolution procedure (recursive)
function [colors] = conflicts(colors,i,j,c,c2)

cInI = find(colors(i,:)==c);
jStar = setdiff(cInI,j);
if(~isempty(jStar))
    colors(i,jStar) = c2;           %Assign color c2 to A(i,jStar)
    cInJStar = find(colors(:,jStar)==c2);
    iStar = setdiff(cInJStar,i);
    if(~isempty(iStar))
        colors(iStar,jStar) = c;    %Assign color c to A(iStar,jStar)
        colors = conflicts(colors,iStar,jStar,c,c2);
    end 
end

return

%end of file


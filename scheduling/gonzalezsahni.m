function [Sh]=gonzalezsahni(Sh,p) 
%GONZALEZSAHNI computation of schedule of shop using Gonzalez-sahni's algorithm.
%
% Synopsis
%	sh = GONZALEZSAHNI(s, p)
%
% Description
%  Compute schedule for input shop s and problem p. The output is also shop
%  object with schedule.
%
% Example
%  >>PT = [1 3; 4 2] P=[1 2; 1 2]%Matrixes of processing times and dedicated processors
%  >>s = shop(PT,P); %Creation of object shop
%  >>p = problem('O2||Cmax');
%  >>s = gonzalezSahni(s,p); %Computation of schedule
%  >>plot(s); %show gantt chart of the shop.
%
% See also SHOP/SHOP SHOP/PLOT PROBLEM/PROBLEM.


% Author: Jiri Cigler <ciglej1@fel.cvut.cz>
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


if ~isa(Sh,'shop') || ~isa(p,'problem')
	error('TORSCHE:shop:invalidParam','Invalid parameters - see help!')
end;
if ~is(p,'alpha','O')
	error('TORSCHE:shop:invalidProblemType','Invalid parameters, Problem must be O2||Cmax - see help!')
end;



%%Initialization of variables
n = max(size(Sh.jobs));
T1 = 0;
T2 = 0;
a (1) = 0;
b (1) = 0;
for i=2:(n+1)
    if Sh.jobs(i-1).Processor(1)==1 &&Sh.jobs(i-1).Processor(2)==2
    	a(i)= Sh.jobs(i-1).ProcTime(1); 
        b(i)= Sh.jobs(i-1).ProcTime(2);
    elseif Sh.jobs(i-1).Processor(1)==2 &&Sh.jobs(i-1).Processor(2)==1
        a(i) = Sh.jobs(i-1).ProcTime(2);
        b(i) = Sh.jobs(i-1).ProcTime(1); 
    else
       error('TORSCHE:gonzalezSahni:invalidShop','Invalid shop - tasks should be processed on different processors'); 
    end
end
l = 1;
r = 1;
S = '';

%%Solving
for i=2:(n+1)
    T1 = T1 + a(i);
    T2 = T2 + b(i);
    if a(i)>=b(i)
       if  a(i)>=b(r)
           S = [S int2str(r)];
           r = i;
       else
           S = [S int2str(i)];
       end
           
    else
        if b(i)>=a(l)
            S = [int2str(l) S];
            l = i;
        else
            S = [int2str(i) S];
        end
    end
end
S1 = '';
S2 = '';
if T1 - a(l) < T2 - b(r)
    S1 = [S int2str(r) int2str(l)];
    S2 = [int2str(l) S int2str(r)];
else
    S1 = [int2str(l) S int2str(r)];
    S2 = [int2str(r) int2str(l) S];
end

S1=str2double(regexp(S1,'([2-9])','match'))-1;
S2=str2double(regexp(S2,'([2-9])','match'))-1;

rt1 = 0;
rt2 = 0;
start=[];
for i=1:n
    
    if   Sh.jobs(S1(i)).Processor(1) == 1
        start(S1(i),1)=rt1;
        rt1 = rt1 + Sh.jobs(S1(i)).ProcTime(1);
    else
        start(S1(i),2)=rt1;
        rt1 = rt1 + Sh.jobs(S1(i)).ProcTime(2);
    end
    

   
   if Sh.jobs(S2(i)).Processor(2)==2
       start(S2(i),2)=rt2;
       rt2 = rt2 + Sh.jobs(S2(i)).ProcTime(2);
   else
       start(S2(i),1)=rt2;
       rt2 = rt2 +Sh.jobs(S2(i)).ProcTime(1);
   end
   
   
end

add_schedule(Sh, 'Schedule for Open-shop', start,get(Sh,'ProcTime'), get(Sh,'Processor'));
Sh.type = 'O';
Sh.Schedule = 1;

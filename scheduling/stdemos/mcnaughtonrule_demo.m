% MCNAUGHTON_DEMO Demo application of the scheduling with 'P|pmtn|Cmax' notation
%
%   This demo file shows how to solve a P|pmtn|Cmax problem using
%   McNaughton rule. The tasks in taskset T are assigned to 4 identical
%   processors in order minimizing Cmax. 
%
%   see also mcnaughtonrule

% Author: M. Silar
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2897 $  $Date:: 2009-03-18 15:17:31 +0100 #$


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


clc;
disp('Demo of Mc''Naughton''s algorithm for problem ''P|pmtn|Cmax''.');
disp('------------------------------------------------------');


%definition of taskset
T=taskset([11 23 9 4 9 33 12 22 25 20]);
T.Name={'t_1' 't_2' 't_3' 't_4' 't_5' 't_6' 't_7' 't_8' 't_9' 't_1_0' };

disp(' ');
disp('An instance of the scheduling problem:');
get(T)


%definition of problem to be solved 
p = problem('P|pmtn|Cmax');

%McNaughton algorithm
T = mcnaughtonrule(T,p,4);

%plot of the final schedule
plot(T,'proc',1); 

%end of file


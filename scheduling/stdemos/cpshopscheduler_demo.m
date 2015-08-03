function varargout = cpshopscheduler_demo
%CPSHOPSCHEDULER_DEMO Demo application of the scheduling with 'J||Cmax' notation
%
% Synopsis
%  CPSHOPSCHEDULER_DEMO
%  [PT, P, SH] = CPSHOPSCHEDULER_DEMO
%
% Description
%  Demo shows how to solve shop problems. If 3 output arguments are
%  mentioned no figure is shown. Only 3 objects are returned. PT - input
%  processing time matrix, P - input processor matrix, SH - output shop.
%
%    See also CPSHOPSCHEDULER.


% Author: Jiri Cigler <ciglej1@fel.cvut.cz>
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



PJS = [1 2 3 ; 3 2 1; 2 3 1];
PTJS = [6 3 1; 2 4 6 ;4 4 4];
sh = shop(PTJS,PJS);
sh.type = 'J';
ts = shop2taskset(sh);
yax = {};
for i=1:size(ts)
	[e r t] = regexpi(ts(i).name,'^T_\{(\d+)\}_\{(\d+)\}$');
	n = char(ts(i).name);
    yax{i} = ['T' n(t{1}{1}(1,1):t{1}{1}(1,2)) n(t{1}{1}(2,1):t{1}{1}(2,2))];
end

pr = problem('J||Cmax');
sh = cpshopscheduler(sh,pr);
if nargout == 3
	varargout{1}=PTJS;
	varargout{2}=PJS;
	varargout{3}=sh;
else
	figure;
	subplot(2,1,1);
	plot(ts,'Axname',yax);
	title('Unscheduled shop');
	subplot(2,1,2);
	plot(sh);
	title('Scheduled Job-shop using constraint programming technique ')

end



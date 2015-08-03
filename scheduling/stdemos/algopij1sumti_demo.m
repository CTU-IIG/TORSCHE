function varargout = algopij1sumti_demo
%ALGOPIJ1SUMTI_DEMO Demo application of the scheduling with
%'O|pij=1|SumTi' notation
%
% Synopsis
%  ALGOPIJ1SUMTI_DEMO
%  [DueDates, SH] = ALGOPIJ1SUMTI_DEMO
%
% Description
%  Demo shows how to solve open-shop problems with unit processing time.
%  Optimizing criteria is sum Ti. If 2 output arguments are
%  mentioned no figure is shown and processed data are returned.
%    See also ALGOPIJ1SUMTI.


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


DueDates = [3 2 4 3 2];
S = shop(ones(5,3),ones(5,3));
S.DueDate = DueDates;

pr = problem('O|pij=1|SumTi');
S.type = 'O';
ts = taskset(shop2taskset(S));
yax = {};
for i=1:size(ts)
	[e r t] = regexpi(ts(i).name,'^T_\{(\d+)\}_\{(\d+)\}$');
	n = char(ts(i).name);
    yax{i} = ['T' n(t{1}{1}(1,1):t{1}{1}(1,2)) n(t{1}{1}(2,1):t{1}{1}(2,2))];
end

S = algopij1sumti(S,pr);
if nargout == 2
	varargout{1}=DueDates;
	varargout{2}=S;
else
	figure;
	subplot(2,1,1);
	plot(S,'Proc',0);
	title('Scheduled Open-shop by algopij1sumti - jobs in lines');
	subplot(2,1,2);
	plot(S);
	title('Scheduled Open-shop by algopij1sumti');

end



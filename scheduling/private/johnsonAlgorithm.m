function jobs = johnsonAlgorithm(jobs)
%JOHNSONALGORITHM Kernel of Johnson algorithm


% Author: Jiri Cigler <ciglerj1@fel.cvut.cz>
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


	if isempty(jobs)
		return;
	end
	%Create lists S1 and S2 and sort them.
	S1 = [];
	S2 = [];
	index1 = 1;
	index2 = 1;

	for i=1:size(jobs,2)
		if jobs(1,i) > jobs(2,i)
			S2(:,index2) = jobs(:,i);
       			index2 = index2 + 1;	
		else 
			S1(:,index1) = jobs(:,i);
			index1 = index1 + 1;
		end
    end
    if ~isempty(S1)
        S1 = sortrows(S1',[1 2])';
    end
    if ~isempty(S2)
    	S2 = -1*sortrows(-1*S2',[2 1])';
    end
	jobs = [S1, S2];

end

function [out] = sat_ind2sub (index, J, K)
%SAT_SUB2IND convert marking of boolean variable in from
%            Xm to Xijk
%
%    [i j k] = SAT_IND2SUB(index, J, K) return index of boolean variable.
%      i - task index
%      j - time
%      k - procesor index
%      m - order of boolean variable
%      J - max time
%      K - number of procesors
%
%    Index m is computed as m = (i-1)KJ+(k-1)J+j + K*(i-1)+k
%    Topology order of index m is: 1 0 1, 1 1 1, ..., 1 J 1, 1 0 2,
%      1 1 2, ..., 1 J 2, ..., 1 J K, 2 0 1, ..., 2 J 1, ..., 2 J K, ...
%
%    See also SAT_SUB2IND


% Author: Michal Kutil <kutilm@fel.cvut.cz>
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

 
if (index <= 0)
    error('Index is less or equal zero!');
end

i = fix((index-1) / ((J+1)*K)) + 1;
k = fix(((index-1) - (i-1)*(J+1)*K) / (J+1))+1;
j = index - (i-1)*(J+1)*K - (k-1)*(J+1) -1;

out = [i j k];
% end .. sat/sat_ind2sub

function [out] = sat_ind2subaa (index, asap, alap, K)
%SAT_SUB2IND convert marking of boolean variable in from
%            Xm to Xijk. Time line is compoud only from asap to alap.
%
%    [i j k] = SAT_IND2SUBAA(index, ASAP, ALAP, K) return index of boolean variable.
%      i     - task index
%      j     - time
%      k     - procesor index
%      index - order of boolean variable
%      ASAP  - array with asap
%      ALAP  - array with alap
%      K     - number of procesors
%
%    See also SAT_SUB2IND, SAT_IND2SUB


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

J = alap - asap;

%i = fix((index-1) / ((J+1)*K)) + 1;
i = 1;
while (index-K*i) > sum(K*J(1:min(i,length(J))))
    i = i + 1;
end

k = fix(((index-1) - (sum(J(1:(i-1)))+(i-1))*K) / (J(i)+1)) + 1 ;
j = index - (sum(J(1:(i-1)))+(i-1))*K - (k-1)*(J(i)+1) - 1 + asap(i);

out = [i j k];
% end .. sat/sat_ind2subaa

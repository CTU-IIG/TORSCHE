function [index] = sat_sub2indaa (ijk, asap,alap, K)
%SAT_SUB2IND convert marking of boolean variable in from
%            Xijk to Xm. Time line is compoud only from asap to alap
%
%    m = SAT_SUB2IND([i j k], ASAP, ALAP, K) return index of boolean variable.
%      i    - task index
%      asap - array with asap
%      alap - array with alap
%      k    - procesor index
%      m    - order of boolean variable
%      J    - max time
%      K    - number of procesors
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
 

i = ijk(1);
j = ijk(2);
k = ijk(3);
if ((j > alap(i))||(k > K))
    error('Index is bigger than maximum!');
end
if (j<asap(i))
    error('Index is less than minimum!');
end
if ((i*k)==0)
    error('Index is zero!');
end
if ((i<0)||(j<0)||(k<0))
    error('Index is nagativ!');
end

J = alap - asap;
index = K*sum(J(1:(i-1))) + ...
        (k-1)*J(i) + ...
        j - asap(i) + ...
        K*(i-1)+k; % K*(i-1)+k - zeros number in time

% end .. sat/sat_sub2indaa

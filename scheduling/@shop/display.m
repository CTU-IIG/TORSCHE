function display (S)
% DISPLAY Display properties of object shop.
% 
% Synopsis
%    DISPLAY(s)
%
% Description
%  Text display of properties of shop s.
%
% See also JOB/JOB LIMITEDBUFFERS/LIMITEDBUFFERS, TRANSPORTROBOTS/TRANSPORTROBOTS.


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


disp(['Shop with ' int2str(size(S.Jobs,2)) ' jobs']);
if ~isempty(S.TransportRobots)
	disp([' Robots: ' int2str(max(size(S.TransportRobots.transportationTimes)))]);
end;
if ~isempty(S.LimitedBuffers)
	disp([' Limited buffers: ' S.LimitedBuffers.Model]);
end;
if S.Schedule
	disp(' Schedule: Yes');
end;

	disp([' Shop type: ' S.Type]);







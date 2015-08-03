function plot(t, varargin)
%PLOT   Graphics display of transport robots schedule
%
% Description
%    PLOT(T[,C1,V1,C2,V2...])
%
%    Parameters:
%      T: - transport robots object
%      Cx:
%         - configuration parameters for plot style
%      Vx:
%         - configuration value
%
%     Properties:
%       Color:
%         - 0 - Black & White
%         - 1 - Generate colors only for tasks without color
%         - 2 - Generate colors for all tasks 
%         - default value is 1)
%       ASAP:
%         - 0 - normal draw (default)
%         - 1 - draw tasks to their ASAP
%       Axis:
%         - [tmin tmax] set time interval for plot. Use NaN for automatic
%           setting values. (NaN is default value)
%       Prec:
%         - 0 - draw without precedens constrains
%         - 1 - draw with precedens constrains (default)
%       Reverse:
%         - 0 - draw tasks in order (top)1,2,3 .. n(bottom) (default)
%         - 1 - draw tasks in order (top)n,n-1,n-2,n-3 .. 1(bottom)
%       Textins:
%         - Text-in setup, structure with 'fontsize' and 'textmovetop'
%           fields
%
% See also TRANSPORTROBOTS/TRANSPORTROBOTS SHOP/SHOP, LIMITEDBUFFERS/LIMITEDBUFFERS. 


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


if ~t.Schedule
    error('TORSCHE:TransportRobots:NoSchedule','Cant draw plot without schedule, first compute schedule');
end
na = nargin;
if ~mod(na, 2)
	error('TORSCHE:TransportRobots:invalidParameter','Arguments must come param/value in pairs.');
end

out = [];
for  i=1:size(t.Schedule,1)
	from = t.Schedule(i,1);
	to = t.Schedule(i,2);
	startTime = t.Schedule(i,3);
    procID = t.Schedule(i,4);
	processingTime =[];
    if t.Schedule(i,5)
        processingTime = t.TransportationTimes{procID}(from,to);
    else
        processingTime = t.EmptyMovingTimes{procID}(from,to);
    end
	t1 = task(sprintf('%s \\rightarrow %s',int2str(from), int2str(to)), processingTime,0);
	t1.Processor = procID;
	if isempty(out)
		out = t1;
	else
		out = [out t1];
	end;

end;
if ~isempty(t.Schedule)
    add_schedule(out,['Schedule for transport robots '],t.Schedule(:,3)', out.ProcTime,out.Processor	);
    plot(out,'Proc',1)
end



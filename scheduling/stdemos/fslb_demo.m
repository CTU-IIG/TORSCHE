function varargout = fslb_demo
%FSLB_DEMO Demo application of the scheduling of flow-shop with limited
%buffers
%
% Synopsis
%  FSLB_DEMO
%  [Fs, Bf, Start, Utilization] = FSLB_DEMO
%
% Description
%  Demo shows how to solve flow-shop problems with limited buffers.
%  If 4 output arguments are mentioned no figure is shown. Only 4
%  matrices are returned. Fs - input
%  processing time matrix, Bf - input limited buffers capacity, Start 
%  -Start times of the tasks, Utilization - utilization of buffers.
%
%    See also CPSHOPSCHEDULER.


% Author: K. Bocek
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


  Fs=[1 2 5 12;1 2 5 12;1 2 5 12;1 2 5 12];
  Proc = [1 2 3 4; 1 2 3 4; 1 2 3 4; 1 2 3 4];
  Bf=[1 1 1 1];
  s = shop(Fs, Proc);%Create shop object 
  l = limitedbuffers('input',Bf);%Create limitedBuffers object
  s.limitedBuffers = l;
  p = problem('F||Cmax');
  fs=fslb(s,p);
  if nargout==0
  	  disp('Flow-shop with limited buffers');
	  disp('Processing time:')
	  disp(Fs)
	  disp('Buffers capacity:')
	  disp(Bf)
	  plot(fs)%plot resulting schedule for jobs
	  plot(fs.limitedBuffers) %plot utilization of buffers
  elseif nargout==4
	Utilization = fs.limitedBuffers.utilization;
	Start = get_schedule(fs);
	varargout{1}=Fs;
	varargout{2}=Bf;
	varargout{3}=Start;
	varargout{4}=Utilization;
  else
  	error('TORSCHE:stdemos:fslb','Undefined number of parameters');
  end
end

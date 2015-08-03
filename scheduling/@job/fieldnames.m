function varargout = fieldnames(this, varargin)
%FIELDNAMES   Return cell of job visible properties 
%
% Synopsis
%   PROPS = FIELDNAMES(J)  
%   [PROPS, DEFVALS] = FIELDNAMES(J)	
%   [PROPS, DEFVALS, DESC] = FIELDNAMES(J)	
%
% Description
%  Return list of public properties PROPS, list of default values
%  DEFVALS and list with description DESC.
%
% See also  JOB/GET, JOB/SET.


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

 
    %property names
    varargout{1} = {'Name','ProcTime','Processor','ReleaseTime','DeadLine','DueDate','Weight','Notes','JobUserParam','Tasks', 'Prec'};
    
    if nargout>1 %property description
        varargout{2} = {'Name of job', ...
                        'Processing times of the job', ...
                        'Dedicated processors', ...
                        'Release time of the job (scalar value)', ...
                        'Deadline of the job (scalar value)', ...
                        'Due date of the job (scalar value)', ...
                        'Weight of the job (scalar value)', ...
                        'User notes for the job', ...
                        'Other user parameters', 'Cell of tasks',...
                        'Precedence constrains between tasks in job' };
    end
    if nargout==3 % return default values
        varargout{3} ={'', 1,1,0,NaN,NaN,1,'',[],{},[]}; 
    end 
end 
%end .. @job/fieldnames

function object = set_helper(object, propertyName, value)
%SET_HELPER Internal function for property setting.
%
%    SET_HELPER(OBJECT, PROPERTY, VALUE) sets PROPERTY of an OBJECT to
%    the VALUE.
%    
%    This function has to be copied to every descendant of SCHEDOBJ
%    class. Matlab's OOP behavior is very limited and object function
%    allows us to overcome some of these limations.
%
%    See also: SET


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

 
if (isfield(struct(object), propertyName))
	eval(['object.' propertyName '=value;']);  
else
    try
	switch lower(propertyName)
		case 'proctime'
			for i=1:size(object.Jobs,2)
				object.Jobs{i}.ProcTime = value(i,:);
			end
	    case 'processor'
			for i=1:size(object.Jobs,2)
				object.Jobs{i}.Processor = value(i,:);
			end
	
	    case 'releasetime'
	     
			for i=1:size(object.Jobs,2)
				object.Jobs{i}.ReleaseTime = value(i);
			end
	       
	    case 'deadline'
	       
			for i=1:size(object.Jobs,2)
				object.Jobs{i}.DeadLine = value(i);
			end
	     
	    case 'duedate'
			for i=1:size(object.Jobs,2)
				object.Jobs{i}.DueDate = value(i);
			end
	          
	    case 'weight'
			for i=1:size(object.Jobs,2)
				object.Jobs{i}.Weight = value(i);
			end

	 
        otherwise
         	    eval(['object.' object.parent ' = ' object.parent '(object.' object.parent ', propertyName, value);']);
	end
    catch
  	            error('TORSCHE:Job:InvalidParam','Invalid Parameter, see help!');
    end
end    





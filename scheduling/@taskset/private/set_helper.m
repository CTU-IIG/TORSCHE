function object = set_helper(object, property, value)
%SET_HELPER Internal function for property setting.
%
%    SET_HELPER(OBJECT, PROPERTY, VALUE) sets PROPERTY of an OBJECT to
%    the VALUE.
%    
%    This function has to be copied to every descendant of SCHEDOBJ
%    class. Matlab's OOP behavior is very limited and this function
%    allows us to overcome some of these limations.
%
%    See also: SET


% Author: Michal Sojka <sojkam1@fel.cvut.cz>
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

 
if (isfield(struct(object), property))
    eval(['object.' property '=value;']);    
else
    try
 

Success = true;
switch lower(property)
  case 'schedule_desc'  % lower case
    object.schedule.desc = value;
    return;
  case 'tasks'  % lower case
    if (iscell(value))
        for i=1:length(value)
            if (~isa(value{i},'task')) error ('Invalid data type!');end;
        end
        object.tasks = value; %valid that it is class tasks
    elseif isa(value,'task')
        object.tasks = {value};
    else
        error ('Invalid data type!');
    end
    return;
end
    
% Try to set properties of all tasks
Success = false;
if any(size(object.tasks) ~= size(value))
    error('value has different size than Tasks');
end
for i=1:size(object.tasks, 1)
    for j=1:size(object.tasks, 2)
        try
            if iscell(value)
                object.tasks{i,j} = set_helper(object.tasks{i,j}, property, value{i, j});
                eval(['object.tasks{i,j} =' class(object.tasks{i,j}) '(object.tasks{i,j}, property, value{i, j});']);
            else
                object.tasks{i,j} = set_helper(object.tasks{i,j}, property, value(i, j));
                %eval(['object.tasks{i,j} =' class(object.tasks{i,j}) '(object.tasks{i,j}, property, value{i, j});']);
            end
            Success = true;
        catch
            % Not every task must have this property
        end
    end
end


    catch
	    eval(['object.' object.parent ' = ' object.parent '(object.' object.parent ', property, value);']);
    end
end    



% *************
% funtion for get properties from task
function prop = get_prop(object,property)
for i=1:1:size(object.tasks,2)
    tmp = get(object.tasks(i),property);
    if sum(strcmpi(property,{'name','machine'}))
        prop{i} = tmp;
    else
        prop(i) = tmp;
    end
end
%end .. get_prop

% *************
% funtion for remove non public property
function val = rm_field(val,AllProps)
prop = fieldnames(val);
for i=1:length(prop),
    if ~sum(strcmpi(AllProps,prop{i}))
        val = rmfield(val,prop{i});
    end
end




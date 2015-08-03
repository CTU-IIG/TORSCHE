function [Value, found] = get_helper(this, Property)
%GET_HELPER Internal function for virtual property retrieval.
%
%    [VALUE, found] = GET_HELPER(OBJECT, PROPERTY) returns PROPERTY VALUE.
%       found is true if the virtual PROPERTY exist othewise is found false. 
%    
%    See also: GET


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


found = true;
switch lower(Property)
  case 'scheduledesc'  % lower case
    Value = this.schedule.desc;
    return;
  case 'count'  % lower case
    Value = size(this);
    return;
  case 'tasks'  % lower case
    Value = this.tasks;
    return;   
end
    
% Try to collect properties of all tasks
found = false;
Value = [];
outputDimension = 0;
for i=1:size(this.tasks, 1)
    for j=1:size(this.tasks, 2)
        try
            V = get(this.tasks{i,j}, Property);
            found = true;
        catch
            V = NaN;
        end
        if ischar(V)
            Value{i,j} = V;
        elseif isempty(V)
            Value(i,j) = NaN;
        else
            if (size(this.tasks, 1) == 1) % Klasikl this with 1xn task
                if (size(V,1) == 1) & (size(V,2) > 1) & (outputDimension == size(V,2) | outputDimension == 0) % Multi parameter
                    Value(:,j) = V';
                    outputDimension = size(V,2);
                elseif (length(V)==1) & (outputDimension == size(V,2) | outputDimension == 0)
                    Value(i,j) = V;
                    outputDimension = 1;
                else
                    error(['Dimension mismatch in ' Property ' property.']);
                end
            else %Prepare for Shops
                error('Remove this error message from get_vprop.m file, this is for Shops');
                Value(i,j) = V;
            end
        end
    end
end


% *************
% funtion for get properties from task
function prop = get_prop(this,property)
for i=1:1:size(this.tasks,2)
    tmp = get(this.tasks(i),property);
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


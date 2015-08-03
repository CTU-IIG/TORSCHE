function [Props,AsgnVals,DefVal] = fieldnames(taskset, varargin)
%FIELDNAMES  All public properties and their assignable values and default
%           value
%
%   [PROPS,ASGNVALS,DEFVAL] = FIELDNAMES(TASKSET[,virtualprop])
%     PROPS       - list of public properties of the object TASKSET (a cell vector)
%     ASGNVALS    - assignable values for these properties (a cell vector)
%     DEFVAL      - default values
%     virtualprop - if is set to 1 than returned values includes a virtual
%                   property
%
%   See also  SCHEDOBJ/GET, SCHEDOBJ/SET.


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
 

% Get parent object properties
[Props,AsgnVals,DefVal] = fieldnames(getfield(struct(taskset), taskset.parent));

% TASKSET properties
Props = {'Prec' 'ScheduleDesc' 'tasks' 'TSUserParam'  Props{:}}; 
% There are also dynamic properties.  See GET_VPROP.

% Get virtual properties
%if ~isempty(varargin) & varargin{1} == 1
    [VProps,VAsgnVals,VDefVal] = fieldnames(task(1));
    i = 1;
    while (i <= length(VProps))
        if ~isempty(find(strcmp(VProps(i),Props), 1))
            VProps = [VProps(1:i-1) VProps(i+1:length(VProps))];
            VAsgnVals = [VAsgnVals(1:i-1) VAsgnVals(i+1:length(VAsgnVals))];
            VDefVal = [VDefVal(1:i-1) VDefVal(i+1:length(VDefVal))];
        end
        i = i + 1;
    end
%else
%    VProps = {}; VAsgnVals = {}; VDefVal ={};
%end

Props = {Props{:} VProps{:}};


% Also return assignable values if needed
if nargout>1,
    AsgnVals = {'precedens constrains' ...
                'schedule description'...
                'tasks cell'...
                'taskset user parameters'...
                AsgnVals{:} VAsgnVals{:}};

    if nargout>2,
        DefVal = {[] '' [] DefVal{:} VDefVal{:}};
    end
end


%end .. @taskset/fieldnames

function this = subsasgn(this,index,val,thiscell)
%SUBSASGN  SUBSASGN property management in referencing operation.
%
%   Syntax
%     subsasgn(this,index, val)
%     subsasgn(this,index, val, thiscell)
%
%   Description
%     this.property = VALUE sets a value of the property.
%     This is equivalent to calling SET method with shorter syntax.
% 
%     If thiscell is set than will be used instead of this. All Cell items 
%     must be schedobj type.
% 
%   See also SUBSASGN, SET.

% Author: Michal Kutil <kutilm@fel.cvut.cz>
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


if exist('thiscell','var')
    this = thiscell;
end

switch index(1).type
    case '.'
        if length(index) == 1
            if iscell(this)
                for i = 1:numel(this)
                    data = this{i};
                    if isstruct(data)
                        data.(index.subs)= val;
                    else
                        set(data, index.subs, val);
                    end
                    this{i} = data;
                end
            else
                set(this, index.subs, val);
            end
        else
            if iscell(this)
                for i = 1:numel(this)
                    this{i} = subsasgn_cell(this{i}, index(1:end), val);
                end
            else
                data = get(this,index(1).subs);
                data = subsasgn_cell(data, index(2:end), val);
                set(this,index(1).subs, data);
            end
        end
    case '()'    
        %for case where N is empty: N(1:5) = node();
        if isempty(this)
            if isa(val,'task') % tasks are stored to cell
                this = {eval(class(val))}; 
            else
                this = eval(class(val));
            end
        end
        if length(index) == 1
            if iscell(this) && ~iscell(val) && ~isempty(val)
                val = {val};
            end
            this(index(1).subs{:}) = val;
        else
            this(index(1).subs{:}) = ...
                subsasgn_cell(this(index(1).subs{:}), index(2:end), val);
        end
    otherwise
        error('TORSCHE:schedobj:unknownIndexingMethod',...
            'Unknown indexing method');
end

function this = subsasgn_cell(this, index, val)
% Help function which call schedobj/subsasign function for cell data type
% too.
if iscell(this) && ~strcmp(index(1).type,'{}')
    this = subsasgn(schedobj(), index, val, this);
else
    this = subsasgn(this, index, val);
end

%end .. @schedobj/subsasgn

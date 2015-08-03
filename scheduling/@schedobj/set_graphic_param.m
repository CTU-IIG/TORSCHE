function set_graphic_param(obj, varargin)
%SET_GRAPHIC_PARAM set graphics params for drawing
%
% Synopsis
%    SET_GRAPHIC_PARAM(object[,keyword1,value1[,keyword2,value2[...]]]) 
% Description
%  Set graphics params for drawing where:
%   object:
%     - object
%   keyword:
%     - name of parameter
%   value:
%     - value
%      
%  Available keywords:
%   color:
%     - color
%   x:
%     - X coordinate
%   y:
%     - Y coordinate
%
% See also SCHEDOBJ/GET_GRAPHIC_PARAM


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


objectname = inputname(1);
if isfield(struct(obj),'parent')
    objs = struct(obj);
    objparent = getfield(objs,objs.parent);
    set_graphic_param(objparent, varargin{:});
  %  obj = set_helper(obj,objs.parent,objparent);
   eval(['obj = ' class(obj) '(obj,objs.parent, objparent);']);

else
    ni = length(varargin);

    if mod(ni,2) == 1
        error('Invalid count of input parameters.');
    end 
    i=1;
    while i <= ni,
        switch lower(varargin{i})
            case 'color'
                obj.GrParam.color=varargin{i+1};
            case 'x'
                obj.GrParam.position(1)=varargin{i+1};
            case 'y'
                obj.GrParam.position(2)=varargin{i+1};
            otherwise
                error('Unknown parameters');
        end
        i=i+2;
    end
end
assignin('caller',objectname,obj);
%end .. @schedobj/set_graphic_param

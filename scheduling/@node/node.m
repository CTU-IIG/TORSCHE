function node = node(varargin)
%NODE  Creation of object node of graph.
%
%  Creation:
%    node = NODE()
%    The output node is a NODE object.
%
%  See also EDGE, GRAPH.


% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2896 $  $Date:: 2009-03-18 12:20:12 +0100 #$


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

 
if nargin==3
	if isa(varargin{1},'node') && ischar(varargin{2}) 
		node = set_helper(varargin{:});
		return;
	end
end

na = nargin;
if na>=1 && isa(varargin{1},'node'),
    node = varargin{1};
    if na > 1,
     % TODO modify for more parameters.
    end;
    return;
elseif na == 1 && isa(varargin{1},'struct')
    node = varargin{1};

    return;
end;

% Create the structure
node = struct(...
        'parent', 'schedobj',...
        'Name','',...
        'version',0.01,...
        'UserParam',[],...
        'GraphicParam',[],...
        'TextParam',[]);
% UserParam is user paramters vector
    
% Create a parent object
parent = schedobj;
    
% Label task as an object of class TASK
node = class(node,'node', parent); 

node.GraphicParam = {getdefaultnode};

%end .. @node/node


function defaultnode = getdefaultnode
% returns default graphic shape
    defaultnode.x = [];
    defaultnode.y = [];
    defaultnode.width  = 30;
    defaultnode.height = 30;
    defaultnode.curvature = [1 1];  % circle
    defaultnode.facecolor = [1 1 0]; % yellow
    defaultnode.linewidth = 1;
    defaultnode.linestyle = '-';  % solid line
    defaultnode.edgecolor = [0 0 0]; % black

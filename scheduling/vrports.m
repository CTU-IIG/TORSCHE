function VRin = vrports(varargin)
%VRPORTS sets input and output names of S-Function block ports
%
%Synopsis
% ports = vrports(Node, Variable[,Node2,Variable2...])
%
%Description
%  ports:
%    - structure with included information about VR inputs and
%      outputs
%  Node:
%    - name of node in Virtual Reality
%  Variable:
%    - node parameter


% Author: Roman Capek <capekr1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2957 $  $Date:: 2009-07-14 13:07:04 +0200 #$


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


VRin = struct('Node',{},'Variable',{});
cnt = 1;

i = 1;
if mod(nargin,2) == 0
    while i < nargin;
        if ischar(varargin{i}) && ischar(varargin{i+1})
            VRin(cnt).Node = varargin{i};
            VRin(cnt).Variable = varargin{i+1};
            i = i+2;
            cnt = cnt+1;
        else
            err = 'TORSCHE:VISIS:invalidParameter';
            error('%s\n%s', err,'Parameters must be of type string!')
        end
    end
else
    err = 'TORSCHE:VISIS:invalidParameter';
    error('%s\n%s', err,'Parameters must be in pairs!')
end
    

function par = vrgetpar(file, name, var)
%VRGETPAR returns specified parameter of node in Virtual Reality
%
%Synopsis
%  par = vrgetpar(file, name, var)
%
%Description
%  par:
%    - numerical field with specified parameter
%  file:
%    - name of Virtual Reality file
%  name:
%    - name of node to get parameter from
%  var:
%    - name of parameter to achieve


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


try
    world = vrworld(file);
    open(world);
    node = vrnode(world, name); %#ok - used in eval
    par = [];
    if strcmp(var, 'time')
        par = 0;
    else
        eval(['par = node.' var ';'])
    end
catch le
    err = 'TORSCHE:VISIS:invalidParameter';
    err = sprintf('%s\n%s', err,['Parameter ''' var ''' for node ''' name ''' not available.']);
    error('%s\n%s', err, le.message) %#ok<SPERR>
end

function varargout = schfeval(varargin)
%SCHFEVAL   Scheduling internal feval (schfeval) is same as feval function,
%           but moreover you can call a functions with relativ path from
%           scheduling toolbox path.
%
%  out = schfeval(function,x1,....,xn)
%
%  example: out=schfeval('@taskset/private/base64encode.m','text')
%
%  See also feval.
%
%  This file is meant for scheduling toolbox's developers only!


% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2895 $  $Date:: 2009-03-18 11:24:58 +0100 #$


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


if ~isa(varargin{1}, 'function_handle')
    path_save = pwd;
    schroot = fileparts(mfilename('fullpath'));
    [fcepath, fcename] = fileparts(varargin{1});
    eval(['cd ' '''' [schroot filesep fcepath] ''''])
    eval(['varargin{1} = @' fcename ';']);
    eval(['cd ' '''' path_save '''']);
end

if nargout >= 1
    [varargout{1:nargout}]=feval(varargin{1},varargin{2:end});
else
    clear ans;
    feval(varargin{1},varargin{2:end});
    if exist('ans','var')
        varargout{1} = ans; %#ok<NOANS>
    end
end
%end .. schfeval

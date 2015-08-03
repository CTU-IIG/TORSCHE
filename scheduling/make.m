function make
%MAKE Scheduling Toolbox general makefile
%
%Use this m-file to compile Scheduling Toolbox mex-files
%

% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Author: Premysl Sucha <suchap@fel.cvut.cz>
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


% TODO  - First call contrib directory
%       - Path check -> ask -> Set ( scheduling, scheduling/stdemos, ...? )
%       - Compilation option - SAT, ILP, ...

%clear all;
clc;
clear mex;
d=dir;

for(i=1:length(d))
    if(d(i).isdir==1)
        if(exist(['.' filesep d(i).name filesep 'make.m'],'file') & ~strcmp(d(i).name,'.') & ~strcmp(d(i).name,'..'))
            fprintf('\nEntering directory ''%s''.\n',d(i).name);
            for idash=1:length(d(i).name) fprintf('-'); end
            fprintf('----------------------\n');
            cd(d(i).name);
            try
                runmake;
            catch
                errorsend=lasterror;
                disp(errorsend.message);
            end
            cd('..');
        end;
    end;
end;

% Local make
% ----------

% P-CODE
%pcode graphedit.m
%pcode private/ge_*.m

% end .. MAKE

function runmake
make;

function make
%MAKE makefile for external algorithms  
%
%This m-file makes external algorithms of Scheduling Toolbox. For more
%information about the external algorithms see individual documentains
%and license files. This m-file is called from main makefile (make.m)
%in Scheduling Toolbox main dirrectory.
%


% Author: Premysl Sucha <suchap@fel.cvut.cz>
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


fprintf('Compiling external utilities/solvers.\n');

[str,maxsize,endian] = computer;
switch(str)
    case {'PCWIN','PCWIN64'}
        operatingSystem='win';
    otherwise
        operatingSystem='linux';
end;
fprintf('Current system is: %s.\n',operatingSystem);

schTBContribPath=pwd;
mexFileDestination = regexprep(schTBContribPath,'contrib$','');
mexFileDestination = mexFileDestination(1:end-1);
mexFileDestination = [mexFileDestination filesep 'private'];

%Make GLPK ILP solver
make_glpk_ilp(mexFileDestination,schTBContribPath,operatingSystem);

%Make CPLEX ILP solver Matlab interface
%make_cplex_ilp(mexFileDestination,schTBContribPath,operatingSystem);

%Make MATLABXML interface
make_matlabxml(mexFileDestination,schTBContribPath,operatingSystem);

% end .. MAKE

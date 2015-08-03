%COMPILEDIR compiles selected files into mex-file.  
%
%COMPILEDIR(source,include,output,libFiles,extraParam) compiles files
%in path defined by cell of strings 'source' to mex-file 'output'.
%Ceil of strings 'include' specifies directories to search for #include files.
%String 'libFiles' specifies libraries for linking and string 'extraParam'
%specifies MEX compiler extra parameters.
%
%    See also SCHEDULING/MAKE
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


function compileDir(source,include,output,libFiles,extraParam)

riginalPath=pwd;
sourceFiles=[];

if(~isa(source,'cell'))
    source={source};
end;

for(j=1:length(source))
	files=dir(source{j});
	
	for(i=1:length(files))
        [start,finish] = regexpi(files(i).name,'\.((c)|(cpp))$');
        if(~isempty(start))
            if(j==1)
                sourceFiles=[sourceFiles ' ' files(i).name];
            else
                sourceFullParh=[source{j} filesep files(i).name];
                sourceFiles=[sourceFiles ' ' '''' sourceFullParh  ''''];
            end;
        end;
	end;
end;
%disp(sprintf('Compiled files: %s',sourceFiles));
    
    
if(~isa(include,'cell'))
    include={include};
end;

incPaths=[];
for(i=1:length(include))
    incPaths=[incPaths ' -I' '''' include{i} '''' ];
end;

eval(['cd ' '''' source{1} '''']);
cmd=[extraParam ' -outdir ' '''' source{1} '''' ' ' incPaths ' '  sourceFiles ' ' libFiles  ' -output ' output];
eval(['mex ' cmd]);
%eval(['mduild ' cmd]);

eval(['cd ' '''' riginalPath '''']);
%end of compileDir

function make
%MAKE SAT scheduler compile
%
% Use this m-file to compile SAT scheduler
%


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


% configuration
zchaff_path = ['..' filesep 'contrib' filesep 'zchaff' filesep];
zipfile_path_without_sep = ['..' filesep 'contrib'];
zipfile_path = [zipfile_path_without_sep filesep];
filetomove = {['satsch_mex.' mexext],'sat_ind2subaa.m','sat_prepare_clause.m'};
dbg_mode = 1;

% test for exist distribution of zChaff
i=1;
zipfile_distribution{i} = 'zchaff.2007.3.12.zip';i=i+1;
zipfile_distribution{i} = 'zchaff.2004.11.15.zip';i=i+1;
zipfile = [];

for i = 1:size(zipfile_distribution,2)
    if ~isempty(dir([zipfile_path zipfile_distribution{i}]))
        zipfile = dir([zipfile_path zipfile_distribution{i}]);
        disp([zipfile_distribution{i} ' version found.']);
        break;
    end
end

[str,maxsize,endian] = computer;
switch(str)
    case {'PCWIN','PCWIN64'}
        operatingSystem='win';
    otherwise
        operatingSystem='linux';
end;

if ~exist(zchaff_path,'dir') && ~isempty(zipfile)
    fprintf('Extracting zChaff SAT solver: ');
    if(strcmp(operatingSystem,'win'))
        system([zipfile_path 'unzip -qo -d ' zipfile_path_without_sep ' ' zipfile_path zipfile.name]);
    else
        unzip([zipfile_path zipfile.name],zipfile_path);
    end;
    fprintf('done.\n');
end

% dir exist test
if ~exist(zchaff_path,'dir')
    disp('Warning: Zchaff solver don''t found. See documentation to install instructions.');
    return;
end

% WIN: patching
if(strcmp(operatingSystem,'win')&&(~exist([zchaff_path 'unistd.h'],'file')))
    % new: unist.h
    fid = fopen([zchaff_path 'unistd.h'],'w');
    fclose(fid);
    % call patch
    system('..\contrib\patch --binary -d ..\contrib\zchaff -i ..\..\sat\zchaff_to_win.patch');
end


% compiling
fprintf('SAT solver compiling: ');
if dbg_mode && exist([zchaff_path 'libsat.a'],'file')
    % from compiled library
    eval(['mex -I' zchaff_path ' satsch_mex.cpp ' zchaff_path 'libsat.a']);
else
    % from source code
    copyfile ([zchaff_path 'zchaff_wrapper.wrp'],[zchaff_path 'zchaff_cpp_wrapper_st.cpp']);
    libs = [zchaff_path 'zchaff_utils.cpp ' ...
        zchaff_path 'zchaff_solver.cpp ' ...
        zchaff_path 'zchaff_base.cpp ' ...
        zchaff_path 'zchaff_dbase.cpp ' ...
        zchaff_path 'zchaff_cpp_wrapper_st.cpp'];
    eval(['mex -DEXTERN# -I' zchaff_path ' satsch_mex.cpp ' libs]);
    delete([zchaff_path 'zchaff_cpp_wrapper_st.cpp']);
end
fprintf('done.\n');

% moving files
fprintf('SAT solver files moving: ');
for i=1:length(filetomove)
    copyfile(filetomove{i},['..' filesep 'private' filesep filetomove{i}]);
end
fprintf('done.\n');

fprintf('SAT solver successful instaled.\n');

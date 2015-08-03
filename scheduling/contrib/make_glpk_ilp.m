function make_glpk_ilp(mexFileDestination,schTBContribPath,operatingSystem)
%MAKE_GLPK_ILP makefile for external GLPK ILP solver
%
%This m-file makes external algorithms of Scheduling Toolbox. For more
%information about the external algorithms see individual documentains
%and license files. This m-file is called from main makefile (make.m)
%in Scheduling Toolbox main dirrectory.
%

%   Author(s): P. Sucha, M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 564 $  $Date: 2006-11-01 19:06:24 +0100 (st, 01 XI 2006) $

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

fprintf('Extracting GLPK 4.6 ILP solver: ');
skipThisCompilation=0;

%Unzip file
try
	if(exist('gunzip','builtin') & exist('untar','builtin'))
        gunzip('glpk-4.6.tar.gz');
        untar('glpk-4.6.tar.gz');
	else    
        stat=system('gzip -dc glpk-4.6.tar.gz > glpk-4.6.tar');
        if(stat~=0) error('Can not unzip GLPK.'); end;
        stat=system('tar -x < glpk-4.6.tar');
        if(stat~=0) error('Can not untar GLPK.'); end;
	end;
    delete('glpk-4.6.tar');
	fprintf('done.\n');
catch
    skipThisCompilation=1;
    disp(lasterr);
    disp('Can not extract GLPK.');
end;

%Compile file
if(skipThisCompilation==0)
	fprintf('Compiling GLPK 4.6 ILP solver: ');
	GLPKpath=[pwd filesep 'glpk-4.6'];
	
	GLPKSrcDir=[GLPKpath filesep 'src'];
	GLPKIncDir=[GLPKpath filesep 'include'];
	GLPKMexSrcDir=[GLPKpath filesep 'contrib' filesep 'glpkmex' filesep 'src'];
	GLPKMexIncDir=[GLPKpath filesep 'contrib' filesep 'glpkmex' filesep 'src'];
	mexFileName='glpkmex';
	
    try
    	compileDir({GLPKSrcDir,GLPKMexSrcDir},{GLPKIncDir,GLPKMexIncDir},mexFileName,[],'-DNULL#0');
    	fprintf('done.\n');
    catch
        skipThisCompilation=1;
        disp(lasterr);
        disp('Can not compile GLPK.');
    end;
        
    %copy compiled files
    if(skipThisCompilation==0)
        copyfile([GLPKpath filesep 'src' filesep 'glpkmex.' mexext], mexFileDestination);
    	copyfile([GLPKpath filesep 'contrib' filesep 'glpkmex' filesep 'doc' filesep 'glpkmex.m'], mexFileDestination);
    	copyfile([GLPKpath filesep 'contrib' filesep 'glpkmex' filesep 'doc' filesep 'glpkparams.m'], mexFileDestination);
    end;
        
end;

eval(['cd ' '''' schTBContribPath '''']);


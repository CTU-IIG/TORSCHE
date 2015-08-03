%CSSIM_DEMO Demo application of Cyclic Scheduling Simulator.
%
%    See also CSSIMIN, CSSIMOUT.


% Author: Premysl Sucha <suchap@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2962 $  $Date:: 2009-12-04 16:01:17 +0100 #$


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


clc;
schDemoRoot = fileparts(mfilename('fullpath'));
benchmarkDir=[schDemoRoot filesep 'benchmarks' filesep 'cssim'];

disp('Demo application of Cyclic Scheduling Simulator');
disp('-----------------------------------------------');
disp('1: dsvf.m');
disp('2: psd.m');
disp('3: lwdf.m');
disp('0: exit');
alg=input('Choice an algorithm:');

switch(alg)
    case 0
        return
    case 1
       dsvffile=[benchmarkDir filesep 'dsvf.m'];
       schoptions=schoptionsset('verbose',1,'cycSchMethod','integer','qmax',1);
    case 2
       dsvffile=[benchmarkDir filesep 'psd.m'];
       schoptions=schoptionsset('verbose',1,'cycSchMethod','integer','qmax',0);
    case 3
       dsvffile=[benchmarkDir filesep 'lwdf.m'];
       schoptions=schoptionsset('verbose',1,'cycSchMethod','integer','qmax',2);
    otherwise
       error('Incorrect choice.')
end


%Parse input file
disp(' ');
disp(['Processing input file:' dsvffile]);
[T,m]=cssimin(dsvffile,schoptions);

%Schedule generated taskset
disp(' ');
disp('Scheduling the loop');
prob=problem('CSCH');
TS=cycsch(T, prob, m, schoptions);

plot(TS);

%Pass data to True-Time simulator
disp(' ');
disp('Generating output file for TrueTime simulation.');
delete('simple_init.m');
delete('code.m');
cssimout(TS,'simple_init.m','code.m');

disp(' ');
disp('Starting the simulation.');
if exist('ttInitKernel')
    switch(alg)
        case 1
            open cssim_dsvf_demo;
            sim('cssim_dsvf_demo');
        case 2
            open cssim_pds_demo;
            sim('cssim_pds_demo');
        case 3
            open cssim_lwdf_demo;
            sim('cssim_lwdf_demo');
    end
else
    error('TrueTime is not instaled!')
end
% end .. CSSIM_DEMO

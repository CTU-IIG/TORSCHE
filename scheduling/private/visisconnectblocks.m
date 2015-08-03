function visisconnectblocks(simModel, ctrlBlock, vrBlock, n)
%VISISCONNECTBLOCKS generates connections between control and VR block in Simulink
%
%Synopsis
% visisConnectBlocks(simModel, ctrlBlock, vrBlock, n)
%
%Description
%  simModel:
%    - simulink model file
%  n:
%    - number of ports to connect


% Author: Roman Capek <capekr1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009
% $Revision: 2951 $  $Date:: 2009-07-14 13:07:04 +0200 #$


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
    fid = fopen(simModel);
    str = '';
    while 1
        tline = fgets(fid);
        str = sprintf('%s%s', str, tline);
        if ~isempty(strfind(tline, 'FigureProperties'))
            while 1
                tline = fgets(fid);
                str = sprintf('%s%s', str, tline);
                if ~isempty(strfind(tline, '}'))
                    str = addLines(str, ctrlBlock, vrBlock, n);
                    break;
                end
            end
            while 1
                tline = fgets(fid);
                if ~ischar(tline)
                    break;
                end
                str = sprintf('%s%s', str, tline);
            end
            break;
        end
    end
    fclose(fid);
    fid = fopen(simModel, 'w');
    fprintf(fid, '%s', str);
    fclose(fid);
catch le
    err = 'TORSCHE:VISIS:parseError';
    error('%s\n%s', err, le.message);
end

end

%%
function str = addLines(str, ctrlBlock, vrBlock, n)
    for i = 1:n
        str = sprintf('%s\n\tLine {\n\t SrcBlock\t\t"%s"', str, ctrlBlock);
        str = sprintf('%s\n\t SrcPort\t\t%d', str, i);
        str = sprintf('%s\n\t DstBlock\t\t"%s"', str, vrBlock);
        str = sprintf('%s\n\t DstPort\t\t%d\n\t}', str, i);
    end
end
function display(prob)
%DISPLAY   Display Problem
%
% Syntax
%    DISPLAY(prob)


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

 

if (prob.machines_quantity == inf) | ((prob.machines_quantity == 1) & (prob.machines_type == '1'))
    quatity = '';
else
    quatity = int2str(prob.machines_quantity);
end
alphatext = [prob.machines_type quatity];

betha=fieldnames(prob.betha);
bethatext = '';
conjunction ='';
for i = 1 : length(betha);
    if getfield(prob.betha,betha{i})>0 | (strcmp(betha{i},'pj') & getfield(prob.betha,betha{i})>=0)
        if strcmp(betha{i},'intree')
            betha{i} = 'in-tree';
        elseif strcmp(betha{i},'pj')
            betha{i} = ['pj=' num2str(getfield(prob.betha,betha{i}))];
       elseif strcmp(betha{i},'nj')
            if getfield(prob.betha,betha{i})==inf
                continue;
            end
            betha{i} = ['nj<=' num2str(getfield(prob.betha,betha{i}))];
        end
                

        bethatext=strcat(bethatext,conjunction,betha{i});
        conjunction = ', ';
    end
end

gammatext = prob.criterion;

if isempty(alphatext) & isempty(bethatext) & isempty(gammatext) & ~isempty(prob.notation)
    disp(prob.notation);
else
    disp([prob.machines_type quatity '|' bethatext '|' prob.criterion]);
end

%end .. @problem/display

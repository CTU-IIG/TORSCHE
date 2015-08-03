function [form] = sat_load_prepared_clause (file)
%SAT_LOAD_PREPARED_CLAUSE nacte CNF klausule
%
%    [form]=SAT_LOAD_PREPARE_CLAUSE(T) 
%      file - file


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


%TODO sikovne zachazet se souborem

fid = fopen('./input.cnf','r');  

cnf_p = fscanf(fid,'%s',2);
cnf_tmp = fscanf(fid,'%d',2);
cnf_var = cnf_tmp(1);
cnf_form = cnf_tmp(2)


form = sparse(cnf_var,cnf_form);
form_index = 1;

%form_file = fscanf(fid,'%d');
form = fscanf(fid,'%d',[3,5]);

% for i = 1:min(length(form_file),1000)
%     pos=form_file(i);
%     if pos == 0
%         form_index = form_index + 1;
%         if ~mod(form_index,100)
%             disp(form_index);
%         end
%     else
%         kam = abs(pos);
%         co = sign(pos);
%         form(form_index, kam) = co;
%     end
% end
    

% while ~feof(fid)
%     pos = fscanf(fid,'%d',1);
%     if pos == 0
%         form_index = form_index + 1;
%         if ~mod(form_index,10000)
%             disp(form_index);
%         end
%     else
%         form(form_index, abs(pos)) = sign(pos);
%     end
% end     

fclose(fid);

% end .. sat/sat_load_prepare_clause

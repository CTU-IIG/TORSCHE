function [struct] = sat_prepare_clause (T, K)
%SAT_PREPARE_CLAUSE pripravy vystup pro vyrobu CNF klausuli
%
%    struct = SAT_PREPARE_CLAUSE(T, K) 
%      T      - set of task
%      K      - number of procesors
%      struct - struct with informations for sat schedulers


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


struct.count = T.count; % task's number
struct.K = K; % procesors
struct.ProcTime = T.ProcTime;
struct.asap = asap(T,'asap');
struct.alap = alap(T,'alap');

% Edges
fprintf('Edges preparing: ');
[u,v]=find(T.Prec);
for edge=1:length(u)
    struct.edges(edge,:) = [u(edge) v(edge)];
end
fprintf('done.\n');

% no-family
fprintf('No-family preparing: ');
g = graph('adj',T.Prec);
nevrodine=[];
for v = 1:size(T)
    fprintf('.');
    task_v=T.tasks(v);
    pocetnevrodine = 0;
    for u=1:size(T)
        task_u=T.tasks(u);            
        if sum([pred(g,v) v succ(g,v)] == u)==0 % sloucit s predchozim forem dohromady              
            pocetnevrodine = pocetnevrodine +1;
            nevrodine(pocetnevrodine) = u;
        end
    end
    struct.nofam{v}=nevrodine(1:pocetnevrodine);
end
fprintf('done\n')
% end .. sat/sat_prepare_clause

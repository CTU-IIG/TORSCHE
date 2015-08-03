% This private script is verbose MOD for List Scheduling algorithm.
%
%    see also LISTSCH


% Author: M. Stibor
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



switch verbosePosition
    case 'start'
        if verbose
            disp(' ');
            disp(['----------------- List Scheduling  ------------------']);
            disp(' ');
            disp(['List of tasks:        ' num2str(1:size(T))]);
            % verbtasks = 1:size(T);
            p = struct(prob);
            disp(['Problem:              ' p.notation]);
            disp(['Number of processors: ' num2str(m)]);

            if exist('strategy')
                disp(['Strategy:             ' func2str(strategy)]);
            end

            disp(['Verbose MOD:          ' num2str(verbose)]);
            disp(' ');
        end


    case 'beforeH'
        if verbose
            disp(['---------- ' num2str(iteration) '. iteration of List Scheduing. ----------']);
            disp(' ');
            if verbose >=2
                disp(['Step 1: Select processor with minimal time.']);
                disp(['Time on processors:        ' num2str(si)]);
                disp(['Selected processor:        ' num2str(pk)]);
                disp(' ');
                disp(['Step 2: Select first available task from list.']);


                [temp backorder]=sort(orca);
                disp(['Tasks on the list:         ' num2str(find(nonassign(backorder)))]);
                disp(['Available tasks:           ' num2str(find(nonassign(backorder).*withoutpr(backorder).*timecondition(backorder))) ]);
            end
        end


    case 'strategy'
        if verbose >= 2
            disp(['Reordered available tasks: ' num2str(orca(nawp))]); %cell2mat(T(nawp).name)]);
        end

    case 'waiting'
        if verbose
            if verbose >= 2
                disp(' ');
            end;
            disp(['Waiting for completion of predecessor...']);
            disp(['Time on processor' num2str(pk) ' will be matched with completion time of predecessor.']);
            disp(' ');
        end


    case 'afterH'
        if verbose
            if verbose >=2
                disp(['Selected task:             ' num2str(orca(nawp))]);
                disp(' ');
                disp(['Step 3: Remove task from list to processor']);
            end


            if isempty(cell2mat(T(nawp).name))
                disp(['Task no.' num2str(orca(nawp)) ' has been removed to processor' num2str(pk)]);
            else
                disp(['Task no.' num2str(orca(nawp)) ' named ''' cell2mat(T(nawp).name) ''' has been removed to processor' num2str(pk)]);
            end

            disp(['with starting time ' num2str(start(nawp)) ' and completion time ' num2str(si(pk)) '.']);
            disp(' ');
        end


    case 'end'
        if verbose
            disp('There is no task in the list. Shedule is done.');
            disp('-------------- End of List Scheduling ---------------');
            disp(' ');
            disp(['List Scheduling terminates after ' num2str(cputime-time) ' sec.']);
        end

end



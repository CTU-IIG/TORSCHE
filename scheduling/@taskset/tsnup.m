function TSOut = tsnup(TSIn, nuIter, varargin)
%TSNUP unrolls iteration of taskset
%    TSOUT = TSNUP(TSIN,NUITER) unrolls NUITER times the input schedule
%    TSIN according to period of the task in TSIN.
%
%    TSOUT = TSNUP(TSIN,NUITER,ITERCOLOR) specifies in addition color of
%    single iterations. It is given by cell e.g. {'r','m','y'} or
%    {'red','magenta','yellow'} or {[1 0 0],[1 0 1],[1 1 0]}. See also
%    COLOR2RGB. If ITERCOLOR={}, colors are chosen automatically.
%
%    See also CYCSCH


% Author: Premysl Sucha <suchap@fel.cvut.cz>
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


if(TSIn.schedule.is ~= 1)
    error('There is not schedule in ''TSIN''.');
end;

colorOfIter=[];

if(nargin>=3)
    %Generate colors of iterations
    if(isa(varargin{1},'cell'))
        colorIterSpec=varargin{1};
        if(isempty(colorIterSpec))
            colorOfIter=colorcube(nuIter+8);
        elseif(length(colorIterSpec)==nuIter)
            for(i=1:length(colorIterSpec))
                colorOfIter(i,1:3)= color2rgb(colorIterSpec{i});
            end;
        else
            error('Length of parametr ''ITERCOLOR'' must specifi color exactly for ''NUITER'' iterations.');
        end;
    else
        error('Incorrect input patameter ''ITERCOLOR''.');
    end;
end;

TSNext = TSIn;
TSOut = TSIn;
if(~isempty(colorOfIter))
    TSOut = colour(TSNext,ones(count(TSNext),1)*colorOfIter(1,:));
end;

%Unroll iterations
for(i=1:(nuIter-1))
    [sch_start, sch_length, sch_processor] = get_schedule(TSNext);
    period = schparam(TSNext,'period');
    sch_start = sch_start + period;
    add_schedule(TSNext,TSNext.schedule.desc,sch_start,sch_length,sch_processor);
    if(~isempty(colorOfIter))
        TSNext = colour(TSNext,ones(count(TSNext),1)*colorOfIter(i+1,:));
    end;
    TSOut = [TSOut TSNext];
end;

% end .. tsnup

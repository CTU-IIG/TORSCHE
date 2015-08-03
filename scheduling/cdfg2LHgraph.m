function LHgraph = cdfg2LHgraph(cdfg,UnitProcTime,UnitLattency)
%CDFG2LHGRAPH converts CDFG to LH graph.
%    LH = CDFG2LHGRAPH(CDFG,UNITPROCTIME,UNITLATTENCY) converts Cyclic
%    Data Flow Graph CDFG to a graph LH weighted by lengths and heights.
%    Parameter UNITPROCTIME is a vector defining time to feed processors
%    (arithm. units), UNITLATTENCY is a vector specifying input-output
%    latency of processors (arithm. units).
%
%  See also CYCSCH.


% Author: Premysl Sucha
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2895 $  $Date:: 2009-03-18 11:24:58 +0100 #$


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


if(~isa(cdfg,'graph'))
    error('Input parametr must be a graph');
end;

%[tf,loc] = ismember('Processor',cdfg.UserParam.graphedit.nodeparams);
%if(loc==0)
%    error('Parametr ''Processor'' is not defined in the input graph.')
%end;
%cdfg.UserParam.graphedit.nodeparams={'ProcTime' 'Processor'};

n=length(cdfg.N);
dedicProc=zeros(1,n);
for(i=1:n)
   dedicProc(i)=cdfg.N(i).UserParam{1};
   if(length(UnitProcTime)<dedicProc(i))
       error(sprintf('Processing time of unit %d is not defined in parametr ''UnitProcTime''.',dedicProc(i)));
   end;
   if(length(UnitLattency)<dedicProc(i))
       error(sprintf('Input-output latency of unit %d is not defined in parametr ''UnitLattency''.',dedicProc(i)));
   end;
   cdfg.N(i).UserParam={UnitProcTime(dedicProc(i)) dedicProc(i)};
end;

H=edges2matrixparam(cdfg,1,inf);
cdfgEdges=(H~=inf);
ioLat=UnitLattency(dedicProc)'*ones(1,n);
L=cdfgEdges.*ioLat;
LHgraph=matrixparam2edges(cdfg,L,1,0);
LHgraph=matrixparam2edges(LHgraph,H,2);

%end .. cdfg2LHgraph

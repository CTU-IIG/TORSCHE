function buffers = limitedbuffers (varargin)
% LIMITEDBUFFERS Creation of object limited buffers
% 
% Synopsis
%  lb = LIMITEDBUFFERS(Model, Capacity)
%
% Description
%  To create limited buffers you have to specify Model and capacity. There
%  is several types  of model: 
%  	- general
%	- job-dependend
%	- pair-wise
%	- input
%   - output
%
%  Capacity	matrix for these models are: 
%           - general        1xQ
%           - job-dependend  1xN
%           - pair-wise      MxM
%           - input          1xM
%           - output         1xM
%
%  where Q means number buffers, N number of jobs and M number of processors.
%  
%
% See also SHOP/SHOP, TRANSPORTROBOTS/TRANSPORTROBOTS.


% Author: Jiri Cigler <ciglej1@fel.cvut.cz>
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


if nargin==3
	if isa(varargin{1},'limitedbuffers') && ischar(varargin{2}) 
		buffers = set_helper(varargin{:});
		return;
	end
end

na = nargin;

%Model
general ='general';
jobDependend = 'job-dependend';
pairWise = 'pair-wise';
output = 'output';
input = 'input';


%initializing struct
buffers = struct(...
        'parent', 'schedobj',...
        'Model',[],...
        'Capacity',[],...
        'Utilization',[]);
    
parent = schedobj;

buffers = class(buffers,'limitedbuffers',parent);


if na == 2 
	Model = lower(varargin{1});
	Capacity = varargin{2};
	buffers.Model = Model;

	switch Model
		case {general, jobDependend, input, output }

			if checkCapacityMatrix(Capacity)
				buffers.Capacity = Capacity;	
			end;


		case pairWise		%Pair-wise Model -- Capacity should be matrix of dim. NxN.
			if checkPairWiseCapacityMatrix(Capacity)		
				buffers.Capacity = Capacity;
			end;
		otherwise
			error('TORSCHE:limitedBuffers:invalidParam','Unknown limited buffer Model, see help!');
	end;


else
	error('TORSCHE:limitedBuffers:invalidParam','Constructor has 2 arguments, see help!')

end;


buffers.Utilization = [];
	



%end .. @limitedbuffers/limitedbuffers
%

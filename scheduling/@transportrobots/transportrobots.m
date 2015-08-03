function robots = transportrobots (varargin)
% TRANSPORTROBOTS Creation of object transport robots
% 
% Synopsis
%  tr = TRANSPORTROBOTS(TransportationTimes[, EmptyMovingTimes])
%
% Description
%  Transportation times must be specify to create object. It is cell of 
%  transportation times matrixes. One matrix  is for one processor. Values
%  in the matrix mean transportation times between processors. Use value inf
%  for unreachable processor. Optional parameter EmptyMovingTimes 
%  - transportation times for the way back with empty cart. Description 
%  is same as in previous case. The output tr is a TRANSPORTROBOTS object.
%
% Example
%  >>tr = transportrobots( {[inf 1; 2 inf],[0 inf; inf 0]}, {[inf 1; 1 inf],[0 inf; inf 0]})
%  %Creates object TRANSPORTROBOTS with 2 robots, with defined back times
%
% See also SHOP/SHOP, LIMITEDBUFFERS/LIMITEDBUFFERS.


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
	if isa(varargin{1},'transportrobots') && ischar(varargin{2}) 
		robots = set_helper(varargin{:});
		return;
	end
end




na = nargin;

%initialization of output struct
robots.TransportationTimes = {};
robots.EmptyMovingTimes = {};
robots.Schedule = [];
robots.parent = 'schedobj';

if na == 1 || na == 2
	
	TransportationTimes = varargin{1};


	if iscell(TransportationTimes) 

        
		for ii=1:size(TransportationTimes,2)
            [x, y] = size(TransportationTimes{ii});
    		if x==y
            	robots.TransportationTimes{ii} = TransportationTimes{ii};
            else
        		error('TORSCHE:TransportRobots:invalidParameter','Transportation times must be cell of MxM matrixes!');
            end;
        end
		
		if na==2 
			
		
			emt = varargin{2};
			if iscell(emt)     
                for ii=1:size(emt,2)
                    [x, y] = size(emt{ii});
                    if x==y
                        robots.EmptyMovingTimes{ii} = emt{ii};
                    else
                		error('TORSCHE:TransportRobots:invalidParameter','Empty moving times must be cell of MxM matrixes!');
                    end;
                end
            else
                error('TORSCHE:TransportRobots:invalidParameter','Empty moving times must be cell of MxM matrixes!');
            end
		
		end
		
	else
		error('TORSCHE:TransportRobots:invalidParameter','Parameters must be numbers or array of numbers!');
	end;

else
	error('TORSCHE:TransportRobots:invalidParameter','Constructor has 2 or 3 arguments. See help!')

end;
parent = schedobj;
robots = class(robots,'transportrobots',parent);


%end .. @transportrobots/transportrobots

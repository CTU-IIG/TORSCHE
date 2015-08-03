function plot(buffers, varargin)
%PLOT   Graphics display of limited buffers utilization
%
% Synopsis
%	PLOT(LB)
%	PLOT(LB, C1, V1, C2, V2 ... )
%
% Description
%  Plotting has several arguments:
%       LB:
%           - Limited buffers object
%       Cx:
%           - Configuration parameters for plot style
%       Vx:
%           - Configuration value
%
% Parameters:
%   period:
%       - period between frames (used only in case of pair-wise model)[s]. Default 0.5s
%   video:
%       - Video output. Configuration value is filename
%   width:
%       - Width of each bar. Default 0.5
%   time:
%       - Detail of utilization of buffers in a given instant of time. Configuration value is a vector of several instants of time.
%
% Example
%  >>LB = limitedbuffers('pair-wise',[0 1; 5 0]); %creating limited buffers object - model is pair-wise
%  >>%then compute schedule using appropriate algorithm
%  >>plot(LB) %plot utilization in time with default values
%  >>plot(LB,'period',0.1 ,'video','example.avi','width',1); %plot utilization in time and save frames to file example.avi (distance between frames is 0.1s). Width of bars is 1. 
%  >>plot(LB,'time',[1 3 5]) %plot static view on utilization of buffers in times 1, 3 and 5
%  >>LB = limitedbuffers('general',[1 3 1]);% creating limitedbuffers buffers object - model is general
%  >>%then compute schedule using appropriate algorithm
%  >>plot(LB, 'time',[12 1 3]) %plot utilization of buffers in times 12, 1 and 3.
%   	
% See also LIMITEDBUFFERS/LIMITEDBUFFERS, SHOP/SHOP.


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

 
na = nargin;
i=1;
period = 0.5;
filename=[];
width = 0.5;
time = [];

if ~mod(na, 2)
	error('TORSCHE:limitedBuffers:invalidParameter','Arguments must come param/value in pairs.');
end

while i<na
	switch lower(varargin{i})
		case 'period' 
			period = varargin{i+1};
		case 'video'
			filename = varargin{i+1};
		case 'width'
			width = varargin{i+1};	
		case 'time'
			time = varargin{i+1};
			if ~isvector(time)
				error('TORSCHE:limitedBuffers:invalidParameter','Invalid parameter for time');
			end
		otherwise
		        error('TORSCHE:limitedBuffers:invalidParameter',['Unknown parameter: ',varargin{i}]);
	end
	i=i+2;
end
if isempty(buffers.Utilization)
	error('TORSCHE:limitedBuffers:emptySchedule','Schedule not computed. First compute it.!');
else
	switch buffers.Model

		case {'input', 'output', 'general', 'job-dependend'}
			if ~isempty(filename)
					warning('TORSCHE:limitedBuffers:unusedParameter','Parameter video not used - video can be recorded only	without	parameter time, see help!')
			end



			if isempty(time)
				figure
				bar3(buffers.Utilization,width);
				xlabel('Buffer');
				ylabel('t');
				zlabel('Utilization');
			else
				if max(time)>max(size(buffers.Utilization(:,1)))
					error('TORSCHE:limitedBuffers:invalidParameter','Time exceeds max time of schedule.');
				end
				m = max(size(time));
				
				figure;	
				for index=1:m
						
							if m==1
								subplot(1,1,1)
							elseif m>1 && m <7
								subplot(ceil(m/2),2,index)
							elseif m>6 && m <13
								subplot(ceil(m/3),3,index)
							else
								subplot(ceil(m/4),4,index)
							end
							h = bar(buffers.Utilization(time(index),:), width);	
							axis([0	1+max(size(buffers.Utilization(1,:)))	0 	max(max(buffers.Utilization(time,:)))])
							title(['Time ',	int2str(time(index))]);
							xlabel('Buffer');
							ylabel('Utilization');
							grid
				end

			end	
		case 'pair-wise'
			if isempty(time)
				if ~isempty(filename)
					fig= figure;
					set(fig,'DoubleBuffer','on');
					set(gca,'xlim',[-80 80],'ylim',[-80 80],...
    'NextPlot','replace','Visible','off')
					mov = avifile(filename,'fps',round(1/period));
				end
	
				for i=1:size(buffers.Utilization,3)
				
       					h=bar3(buffers.Utilization(:,:,i),width);
	
					for u = 1:length(h)
					    zdata = ones(6*length(h),4);
					    k = 1;
					    for j = 0:6:(6*length(h)-6)
				        	zdata(j+1:j+6,:) = buffers.Utilization(k,u,i);
					        k = k+1;
					    end
					    set(h(u),'Cdata',zdata)
					end
					title(['Time ',int2str(i)])
					xlabel('Processors');
					ylabel('Processors');
					zlabel('Utilization');
					dim = size(buffers.Utilization,1)+1;
					axis([0 dim 0 dim 0	max(buffers.Utilization(:))]);
 			
					if ~isempty(filename)
						F = getframe(gca);
						mov = addframe(mov,F);
					end
			       		pause(period);
				end	
	
				if ~isempty(filename)
					mov = close(mov);
				end
			%time is set up
			else
				if ~isempty(filename)
					warning('TORSCHE:limitedBuffers:unusedParameter','Parameter video not used - video can be recorded only	without	parameter time, see help!')
					end
				if max(time)>max(size(buffers.Utilization,3))
					error('TORSCHE:limitedBuffers:invalidParameter','Time exceeds max time of schedule.');
				end
				m = max(size(time));
				for i=1:max(size(time))
					if m==1
						subplot(1,1,1)
					elseif m>1 && m <7
						subplot(ceil(m/2),2,i)
					elseif m>6 && m <13
						subplot(ceil(m/3),3,i)
					else
						subplot(ceil(m/4),4,i)
					end

					h=bar3(buffers.Utilization(:,:,i),width);
	
					for u = 1:length(h)
					    zdata = ones(6*length(h),4);
					    k = 1;
					    for j = 0:6:(6*length(h)-6)
				       		zdata(j+1:j+6,:) = buffers.Utilization(k,u,i);
				        	k = k+1;
					    end
					    set(h(u),'Cdata',zdata)
					end
					xlabel('Processors');
					ylabel('Processors');
					zlabel('Utilization');
					dim = size(buffers.Utilization,1)+1;
					axis([0 dim 0 dim 0	max(buffers.Utilization(:))]);


				end
			end

		otherwise
			error('TORSCHE:limitedBuffers:unconsistentData','Unknown error - data of the object are unconsistent!');
	end	
end

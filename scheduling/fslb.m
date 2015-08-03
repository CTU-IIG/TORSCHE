function shop = fslb(FS, pr)
%FSLB computation of schedule of flow-shop with limited buffers using branch and bound algorithm.
%
% Synopsis
%	sh = FSLB(fs, p)
%
% Description
%  Compute schedule for input flow-shop fs and problem p (expected to be
%  F||Cmax). The output is also shop object with schedule.
%
% Example
%  >>Fs=[1 2 5 12;1 2 5 12;1 2 5 12;1 2 5 12];
%  >>Proc = [1 2 3 4; 1 2 3 4; 1 2 3 4; 1 2 3 4];
%  >>Bf=[1 1 1 1];
%  >>s = shop(Fs, Proc);%Create shop object 
%  >>l = limitedbuffers('input',Bf);%Create limitedBuffers object
%  >>s.limitedBuffers = l;
%  >>p = problem('F||Cmax')
%  >>fs=fslb(s,p);
%  >>plot(fs)%plot resulting schedule for jobs
%  >>plot(fs.limitedBuffers) %plot utilization of buffers
%
% See also SHOP/SHOP SHOP/PLOT PROBLEM/PROBLEM.


% Author: K. Bocek
% Author: Jiri Cigler <ciglej1@fel.cvut.cz>
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



if isa(FS,'shop') && isa(pr,'problem')
	if isempty(FS.LimitedBuffers)
		error('TORSCHE:shop:invalidParam','Invalid parameters - shop must contain limited an buffers object!')
	else
		Fs = FS.proctimeasmatrix;
		Bf = FS.LimitedBuffers.capacity;
		start_time = fslb_kernel(Fs,Bf);
		desc = 'Schedule for Flow-Shop with Limited Buffers';
		proc = FS.processorsasmatrix;
		add_schedule(FS,desc,start_time,Fs, proc);
		FS.type = 'F';
		Bffs_max = Bf;	

		n=size(Fs,1);                   %pocet Jobu
		m=size(Fs,2);                   %pocet procesoru=pocet tasku v jobu
		%definovani na kterem procesoru bezi ktery task
		P=ones(1,m);
		for j=2:1:m
		    P(1,j)=P(1,j-1)+1;          %jeden radek (flow shop, takze vzdy postupne rostouci)
		end
		Proc=repmat(P,n,1);             %vyplneni na matici pozadovane velikosti

		Cmax=max(max(start_time+Fs));   %doba reseni
		P_first=min(start_time);        %doba spusteni prvniho tasku na jednotlivych procesorech
		Bffs=[min(n,Bffs_max(1,1)) zeros(1,m-1)];            %vyuziti bufferu na pocatku


		%% vykresleni vytizeni bufferu
		Bff=zeros(Cmax+2,m);
		Bff(1,:)=Bffs(1,:);
		cnt_cek=n-Bffs_max(1,1);    %pocet jobu cekajicich na uvolneni bufferu u prvniho procesoru
		Ts=start_time';
		for j=2:1:Cmax+2
		    t=j-2;
		    Bff(j,:)=Bff(j-1,:);
		    if find(t==Ts)>0    %cas kdy zacina nejaky task
		        pom=mod(find(Ts==t),m);
		        pom(0==pom)=m;
		        pom=sort(pom);
		        for i=1:1:size(pom,1)
			    for k=1:1:m-1
		                if pom(i)==k          %cislo proceseoru
                		    if t==P_first(1,k)
		                        %je-li prvni na procesoru nedelej nic
                		    else
			                Bff(j,k+1)=Bff(j,k+1)+1;
                        		%break;
		                    end
                		    if Bff(j,k)>0
		                        Bff(j,k)=Bff(j,k)-1;
                		        if k==1 && cnt_cek>0
		                            Bff(j,1)=Bff(j,1)+1;
                		            cnt_cek=cnt_cek-1;
		                        end
                		        %break;
		                    end
                		elseif pom(i)==m && Bff(j,m)>0    %posledni processor
		                    Bff(j,m)=Bff(j,m)-1;
                		    break;
		                end
		            end
		        end
		    end
		end
	lb = FS.limitedBuffers;
	set(lb,'Utilization',Bff);
	FS.limitedBuffers= lb;

	shop = FS;


	end
	
else
	error('TORSCHE:shop:invalidParam','Invalid parameters - see help!')
end

end%function



function [start_time]=fslb_kernel(Fs,Bffs_max)
% FSLB_KERNEL is function solving problem Flow Shop with limited buffers
% type input buffers, minimizing Cmax
% 
% Synopsis
% 	schedule=fslb_kernel(Fs,Bffs_max)
%
% Description
%	The function has folowing parameters:
%       Fs:
%		- matrix describing the Flow shop problem
%       Bffs_max:
%		- is vector of maximum capacity of buffers
%	       schedule is matrix of start times of each task
%       
% Example
% >> Fs=[1 2 3;2 4 1];
% >> Bffs_max=[1 1 1];
% >> schedule=flow_buff(Fs,Bffs_max);
%	       
% See also SHOP/SHOP PROBLEM/PROBLEM


% Author: K. Bocek
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


n=size(Fs,1);                   %pocet Jobu
m=size(Fs,2);                   %pocet procesoru=pocet tasku v jobu

%% prealokace
Cmax=m*sum(sum(Fs));              %zatim nejlepsi vysledek
D=[ones(n,1) zeros(n,m-1)];     %pole s indikaci pripravenych tasku
Td=zeros(n,m);                  %pole s casy dokonceni tasku
Done=zeros(n,m);                %pole s bity hotovo nehotovo

%% vytvoreni pocatecniho stavu
for i=1:1:n
    next(1,i)=i;                %cislo Jobu
    next(2,i)=find(D(i,:)==1);  %cislo tasku
end
start=struct('a',[0;0],'n',{next},'T',zeros(1,m),'b',zeros(1,m));
cesta(1)=start;

%% vlastni prohledavani (do dhloubky s prorezavanim)
i=2;
while 1
    %expand
    if size(cesta(i-1).n,2)>0   %ma-li nasledovnika
       akt=cesta(i-1).n(:,1);
       next=[];
       D(akt(1,1),akt(2,1))=0;
       if akt(2,1)<m
           D(akt(1,1),akt(2,1)+1)=1;
       end
       for h=1:1:n
           if sum(D(h,:))>0    
               next=[next [h;find(D(h,:)==1)]];       %cislo Jobu ; cislo tasku
           end
       end
       cesta(i)=struct('a',{akt},'n',{next},'T',[],'b',[]);
       exps=1;                   %jen info, ze probihala expanze  
     %cast pocitajici dobu vytizeni procesoru
       cesta(i).T=cesta(i-1).T;
       if akt(2,1)>1
           pom = max([cesta(i).T(1,akt(2,1)) Td(akt(1,1),akt(2,1)-1)]);
       else
           pom = cesta(i).T(1,akt(2,1));
       end
       cesta(i).T(1,akt(2,1))=pom+Fs(akt(1,1),akt(2,1));
       Td(akt(1,1),akt(2,1))=cesta(i).T(1,akt(2,1));
     %cast pocitajici vytizeni bufferu
       cesta(i).b=cesta(i-1).b;
       if akt(2,1)<m
           if cesta(i).T(1,akt(2,1)) < cesta(i).T(1,akt(2,1)+1);
               if cesta(i).b(1,akt(2,1)+1)<Bffs_max(1,akt(2,1)+1)
                   cesta(i).b(1,akt(2,1)+1)=cesta(i).b(1,akt(2,1)+1)+1;
               else
                   cesta(i).T(1,akt(2,1))=cesta(i).T(1,akt(2,1)+1);
               end
            end
       end

     %prorezani, zastavi expanzi, zaroven neni brano jako vrchol
       if mean(cesta(i).T)+sum(sum((1-Done).*Fs)) >= Cmax       %+sum(sum((1-D).*Fs))
           cesta(i).n=[];
           exps=0;
       end
       Done(akt(1,1),akt(2,1))=1;   %ukladani, ktere tasky jsou jiz hotove
       i=i+1;
       
    %backtrack     
    else
        if exps==1
            %vola se jen ve vrcholech (listech) (kde se otaci beh z expanze
            %do backtracingu)
            pom=max(max(Td));
            if pom<Cmax
                Cmax=pom;
                T=Td;
            end
        end
        exps=0;            
        %backtrack
        if cesta(i-1).a==zeros(2,1)
            break;               %navrat do startu, ==> prohledano
        end
        i=i-1;
        l_akt=akt;              %odlozeni posledniho vybraneho stavu
        akt=cesta(i-1).a;
        if i>2
            Done(akt(1,1),akt(2,1))=0;
        end
        D(l_akt(1),l_akt(2))=1;
        for j=1:1:n
           pom=find(D(j,:)==1,1);
           if pom<m
               D(j,pom+1)=0;
           end
        end
        for j=1:1:size(cesta(i-1).n,2)
            if cesta(i-1).n(:,j)==l_akt
                cesta(i-1).n(:,j)=[];
                break;
            end
        end

    end
end

%% vystup
if ~exist('T','var')
    disp('reseni nenalezeno');
else
    start_time=T-Fs;
end

end

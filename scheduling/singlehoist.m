function [TS, xmin] = singlehoist(T,schoptions,plot)
%SINGLEHOIST solves single hoist scheduling problem.
%
% Synopsis
%    TS = SINGLEHOIST(T,SCHOPTIONS,PLOT)
%
% Description
%    Function solves hoist scheduling problem with single hoist. The problem
%    is described by processing time representing the minimum time required
%    for the hoist to move a carrier from tank s_{i} to tank s_{i+1}, the
%    minimum processing time in stage (in T.TSUserParam.minDistance), the
%    maximum processing time in stage (in T.TSUserParam.maxDistance) and
%    the minimum time required for the hoist to move a carrier from tank
%    s_{i} to tank s_{i+1} (T.TSUserParam.SetupTime).
%    Input parameters are:
%      T:
%               - set of tasks (see CDFG2LHGRAPH)
%      SCHOPTIONS:
%               - optimization options (see SCHOPTIONSSET)
%      PLOT:
%               - description of scheduling problem (object PROBLEM)
%
%    See also CYCSCH.


% Author: Michal Smola <smolam1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2951 $  $Date:: 2009-07-10 09:21:29 +0200 #$


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


if(~exist('plot','var'))
    plot = 0;
end

if(~exist('schoptions','var'))
    schoptions = schoptionsset();
end

d = T.ProcTime;
C = T.TSUserParam.SetupTime;
a = T.TSUserParam.minDistance;
b = T.TSUserParam.maxDistance;

TS = T;

[xmin,extra] = hoistschedulingILP(a,b,C,d,schoptions);
%period of resulting schedule
period = xmin(1);
%time points (start times) of hoist moves
startTime = [0 xmin(2:length(d))];

%Add results to the input taskset
add_schedule(TS,'single hoist scheduling algorithm',startTime,d,ones(1,length(d)));
add_schedule(TS,'time',extra.time,'period',period);

%Plot resulting hoist trajectory
if(plot==1)
    plotSingleHoist(xmin,a,b,C,d);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xmin,extra] = hoistschedulingILP(A,B,C,D,schoptions)
%Hoist scheduling - rozvrhovani cinnosti prepravniku materialu
%
%Vstupem skriptu jsou vektory a matice obsahujici minimalni a maximalni cas 
%upravy materialu na jednotlivych stanovistich a casy presunu zatizeneho 
%i nezatizeneho prepravniku mezi jednotlivymi stanovisti.
%Vystupem je graf pohybu prepravniku po lince.
%
%
%pozn.: Algoritmus prevzat z prace: 
%   Cyclic scheduling of a single hoist in extended electroplating lines: 
%       a comprehensive integer programming solution
%   JIYIN LIU1*, YUN JIANG1 and ZHILI ZHOU2

N = 100000;                 %velke kladne cislo

n = length(A)-1;            %pocet stanovist

pocetProm = (n*n+3*n+4)/2;  %pocet promennych (T+ti+wi+yij mimo t0 a y0x)

lb = zeros(pocetProm,1);    %spodni limity hodnot promennych (vse 0)

ub = zeros(pocetProm,1);    %horni limity hodnot promennych
ub(1:(2*n+2)) = inf;        %nastaveni na "nekonecno" (T,ti,wi)
ub((2*n+3):end) = 1;        %nastaveni na 1 (yij)

vartype(1:(2*n+2)) = 'C';   %typy promennych; realna cisla (T,ti,wi)
vartype((2*n+3):pocetProm) = 'I';   %cela cisla (yij)
vartype=(vartype)';         %transformace vektoru na sloupec

c=zeros(pocetProm,1);       %cilova funkce
c(1)=1;                     %pozice 1 v c(x) predstavuje T, ktere chceme minimalizovat

%struktura vektoru promennych:
%[T,t1,..,tn,w0,..,wn,y12,..,y1n,y23,..,y2n,..,..,yn-1n]


%nerovnice (1)
%realizovana cilovou funkci c


%%nerovnice (2)
  %leva nerovnost
    M=zeros(1,pocetProm);   %prvni radek matice M; M reprezentuje linearni omezeni
    M(1)=1;                 % T
    M(n+1)=-1;              % - tn
    M(2*n+2)=-1;            % - wn
    ctype=['G'];            % => 
    b=[(A(1)+D(n+1))];      % ao + dn
%%nerovnice (2)
   %prava nerovnost
    new=zeros(1,pocetProm);
    new(1)=1;               % T
    new(n+1)=-1;            % - tn
    new(2*n+2)=-1;          % - wn
    M=[M;new];              %pridani radku k matici M
    ctype=[ctype;'L'];      % <=
    b=[b;(B(1)+D(n+1))];    % b0 + dn

    
%%nerovnice (3) 
  %leva nerovnost
   %pro i=0;
    new=zeros(1,pocetProm);
    %t(i) ~ t(0) = 0
    new(2)=-1;          % - t(i+1) ~ - t1
    new(n+2)=1;         % + w0
    %y01 je vzdy jedna (cyklus zacina pohybem 0), zkraceno s N na prave strane
    M=[M;new];
    ctype=[ctype;'L'];  % <=
    b=[b;(-A(2)-D(1))]; % - a1 - d0 (N zkraceno)
   %pro i=1..n-1
    yii1=2*n+3;                 %inicializacni hodnota: index y12
    for i = 1:(n-1)
        new=zeros(1,pocetProm);
        new(i+1)=1;             % ti
        new(i+2)=-1;            % - t(i+1)
        new(i+n+2)=1;           % + wi
        new(yii1)=N;            % + N * y(i,i+1)
        M=[M;new];
        ctype=[ctype;'L'];      % <=
        b=[b;(N-D(i+1)-A(i+2))]; % N - di - a(i+1)
        yii1=yii1+n-i;          % priprava hodnoty pro pristi pruchod cyklem
    end
%%nerovnice (3) 
  %prava nerovnost
   %pro i = 0;
    new=zeros(1,pocetProm);
    % t(i) ~ t(0) = 0
    new(2)=1;               % t(i+1) ~ t1
    new(n+2)=-1;            % - w0
    % y(0,1) je vzdy jedna, zkraceno s N na prave strane
    M=[M;new];
    ctype=[ctype;'L'];      % <=
    b=[b;(D(1)+B(2))];      % d0 + b1
   % pro i=1..n-1
    yii1=2*n+3;                 %inicializacni hodnota: index y12
    for i = 1:(n-1)
        new=zeros(1,pocetProm);
        new(i+1)=-1;            % - ti
        new(i+2)=1;             % + t(i+1)
        new(i+n+2)=-1;          % - wi
        new(yii1)=N;            % + N * y(i,i+1)
        M=[M;new];
        ctype=[ctype;'L'];      % <=
        b=[b;(D(i+1)+B(i+2)+N)]; % di + b(i+1) + N
        yii1=yii1+n-i;          % priprava nove hodnoty pro pristi pruchod cyklem
    end

    
%%nerovnice (4) 
  %leva nerovnost
   %pro i=1..n-1
    yii1=2*n+3;                 %inicializacni hodnota: index y12
    for i = 1:(n-1)
        new=zeros(1,pocetProm);
        new(1)=1;               % T
        new(i+1)=-1;            % - ti
        new(i+2)=1;             % + t(i+1)
        new(i+n+2)=-1;          % - wi
        new(yii1)=N;            % + N * y(i,i+1)
        M=[M;new];
        ctype=[ctype;'G'];      % =>
        b=[b;(D(i+1)+A(i+2))];  % di + a(i+1)
        yii1=yii1+n-i;          %priprava hodnoty pro pristi pruchod cyklem
    end
  %prava nerovnost
   %pro i=1..n-1
    yii1=2*n+3;                 %inicializacni hodnota: index y12
    for i = 1:(n-1)
        new=zeros(1,pocetProm);
        new(1)=1;               % T
        new(i+1)=-1;            % - ti
        new(i+2)=1;             % + t(i+1)
        new(i+n+2)=-1;          % - wi
        new(yii1)=-N;           % - N * y(i,i+1)
        M=[M;new];
        ctype=[ctype;'L'];      % =>
        b=[b;(D(i+1)+B(i+2))];  % di + b(i+1)
        yii1=yii1+n-i;          %priprava hodnoty pro pristi pruchod cyklem
    end

    
%%nerovnice (5) 
    for i = 1:n
        new=zeros(1,pocetProm);
        new(i+1)=1;             % ti
        new(n+2)=-1;            % - w0
        M=[M;new];
        ctype=[ctype;'G'];      % =>
        b=[b;(D(1)+C(2,(i+1)))]; % d0 + C(1,i)
    end

%%nerovnice (6) 
    yii1 = n+3;         %index y(i,i+1), inicializacni hodnota je na zacatku 
                        %cyklu zmenena na index y(1,2)
    for i = 1:(n-1)        
        yii1=yii1+n-i+1;            %vypocet indexu dalsiho yi,(i+1) (y12->y23, y23->y34, ...)
        for j = (i+1):n
            new=zeros(1,pocetProm);
            new(j+1)=1;             % tj
            new(i+1)=-1;            % - ti
            new(n+2+i)=-1;          % - wi
            new((yii1+j-i-1))=-N;   % - N * y(i,j)
            M=[M;new];
            ctype=[ctype;'G'];      % =>
            b=[b;(D(i+1)+C((i+2),(j+1))-N)];  % di + C(i+1,j) - N
        end
    end

%%nerovnice (7) 
    yii1 = n+3;         %index yi,(i+1), inicializacni hodnota je na zacatku 
                        %cyklu zmenena na index y(1,2)
    for i = 1:(n-1)
        yii1=yii1+n-i+1;    %vypocet indexu dalsiho yi,(i+1) (y12->y23, y23->y34, ...)
        for j = (i+1):n
            new=zeros(1,pocetProm);
            new(i+1)=1;             % ti
            new(j+1)=-1;            % - tj
            new(n+2+j)=-1;          % - wj
            new((yii1+j-i-1))=N;    % + N * yij
            M=[M;new];
            ctype=[ctype;'G'];      % =>
            if j==n %stanoviste n+1 je totozne se stanovistem 0
                    %C(n+1,x) neexistuje, odpovida mu C(1,x)
                b=[b;(D(1+j)+C(1,(i+1)))];      % d(j) + C(j+1,i)
            else
                b=[b;(D(1+j)+C((j+2),(i+1)))];  % d(j) + C(j+1,i)
            end
        end
    end

%%nerovnice (8) 
    for i = 1:n
        new=zeros(1,pocetProm);
        new(1)=1;               % T
        new(i+1)=-1;            % - ti
        new(n+2+i)=-1;          % - wi
        M=[M;new];
        ctype=[ctype;'G'];      % =>
        if i==n %stanoviste n+1 je totozne se stanovistem 0
                %C(n+1,1) neexistuje, odpovida mu C(1,1) = 0
            b=[b;D(1+i)];       % d(n) (+ C(n+1,0))
        else
            b=[b;(D(1+i)+C((i+2),1))]; % d(i) + C(i+1,0)
        end
    end

    
%%nerovnice (9) a (10) 
    %realizovane dolnim limitem hodnot promennych (vektor lb)

    
%%nerovnice (11) 
    %realizovana typem promenne (vektor vartype) a omezenim hodnot
    %promennych (lb, ub)

%spusteni vlastniho algoritmu
[xmin,fmin,status,extra] = ilinprog(schoptions,1,c,M,b,ctype,lb,ub,vartype);

if(status==1)
    xmin=(xmin)';
else
    xmin = [];
end

return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotSingleHoist(xmin,A,B,C,D)

n = length(A)-1;

Tn = [0,xmin(2:(n+1))]; %casy zacatku presunu (doplneno t0)
Xmax = xmin(1);         %rozsah osy X ~ T
Ymax = n;               %rozsah osy Y ~ n

akt = 0;     %akt pohyb

figure;
axes1 = axes('YTick',[0:1:n]);
axis(axes1,[0,Xmax*1.15,0,Ymax+1]);
xlabel('t(sec)');
ylabel('stanoviste');
title(sprintf('T = %u',xmin(1)));

hold on;

%svisla cara- konec cyklu
line([xmin(1); xmin(1)], [0; (n+0.2)],'LineStyle','-','color','k','LineWidth',2);
text(0.97 * Xmax, n+0.4, sprintf('T = %u',xmin(1)),'color','k');

%%zpracovani pohybu nalozeneho prepravniku
%vsechny pohyby mimo posledniho
while akt ~= (n)

    %vykresli pohyb ze stanoviste "akt" do "akt+1"
    line([Tn(akt+1); Tn(akt+1)+D(akt+1)], [(akt); (akt+1)],'LineStyle','-','color','r');

    %napis casy k zacatku a konci pohybu
    text(Tn(akt+1),akt+0.1,num2str(Tn(akt+1)),'color','k');
    text(Tn(akt+1)+D(akt+1),akt+1.1,num2str(Tn(akt+1)+D(akt+1)),'color','k');

    %pokud pohyb z nasledujiciho stanoviste zacina po tomto
    if Tn(akt+1) < Tn(akt+2)
        %nakresli setrvani ve stanovisti do pristiho pohybu
        line([Tn(akt+1)+D(akt+1); Tn(akt+2)], [(akt+1); (akt+1)],'LineStyle','-','LineWidth',2,'color','b');

        %pokud pohyb z nasledujiciho stanoviste zacina pred timto
    else
        %nakresli setrvani ve stanovisti do konce cyklu
        line([Tn(akt+1)+D(akt+1); Xmax], [(akt+1); (akt+1)],'LineStyle','-','LineWidth',2,'color','b');
        %nakresli setrvani v nasledujicim stanovisti od zacatku cyklu
        line([0; Tn(akt+2)], [(akt+1); (akt+1)],'LineStyle','-','LineWidth',2,'color','b');
    end
    akt=akt+1;
end

%posledni pohyb - navrat prepravniku do load/unload stanoviste
line([Tn(akt+1); Tn(akt+1)+D(akt+1)], [(akt); 0],'LineStyle','-','color','r');
%casy zacatku a konce navratu do l/u stanoviste
text(Tn(akt+1),akt+0.1,num2str(Tn(akt+1)),'color','k');
text(Tn(akt+1)+D(akt+1),0.1,num2str(Tn(akt+1)+D(akt+1)),'color','k');
%cekani prepravniku v load/unload stanovisti
line([Tn(akt+1)+D(akt+1); Xmax], [0; 0],'LineStyle','-','LineWidth',2,'color','b');

%%vykresleni presunu prazdneho prepravniku
[S I] = sort(Tn);       %serazenene zacatky pohybu pro kresleni presunu
%prazdneho prepravniku
for i=1:(n)
    %pokud nasledujici pohyb zacina z jineho stanoviste, nez ve
    %kterem soucasny konci a zaroven soucasny pohyb neni navrat do
    %u/l stanoviste
    if ((I(i)+1) ~= I(i+1)) || (I(i) > I(i+1))
        if I(i) ~= n+1
            line([Tn(I(i))+D(I(i)); Tn(I(i))+D(I(i))+C(I(i)+1,I(i+1))], [I(i); I(i+1)-1],'LineStyle',':','color','r');
            text(Tn(I(i))+D(I(i))+C(I(i)+1,I(i+1)),I(i+1)-0.9,num2str(Tn(I(i))+D(I(i))+C(I(i)+1,I(i+1))),'color','k');
        else
            line([Tn(I(i))+D(I(i)); Tn(I(i))+D(I(i))+C(1,I(i+1))], [0; I(i+1)-1],'LineStyle',':','color','r');
            text(Tn(I(i))+D(I(i))+C(1,I(i+1)),I(i+1)-0.9,num2str(Tn(I(i))+D(I(i))+C(1,I(i+1))),'color','k');
        end
    end
end
if I(n+1) ~= n+1    %pokud navrat do l/u stanice neni poslednim pohybem
    line([Tn(I(n+1))+D(I(n+1)); Tn(I(n+1))+D(I(n+1))+C(1,I(n+1)+1)], [I(n+1); 0],'LineStyle',':','color','r');
end
for i = 1:n
    if Tn(i+1) < Tn(i)      %pokud cas opusteni nadrze je mensi nez cas prijezdu do nadrze
        u = Xmax - Tn(i) - D(i) - xmin(n+1+i) + Tn(i+1);    % T - t(i-1) - d(i-1) - w(i-1) + t(i)
    else
        u = Tn(i+1) - Tn(i) - D(i) - xmin(n+1+i);       % t(i) - t(i-1) - d(i-1) - w(i-1)
    end
    text(Xmax + 0.02 * Xmax, i, num2str(u),'color','b');    %cas ve stanici "i"
end
u = Xmax - Tn(n+1) - D(n+1) - xmin(2*n+2);  %cas v l/u stanici
text(Xmax + 0.02 * Xmax, 0.1, num2str(u),'color','b');




%end of file

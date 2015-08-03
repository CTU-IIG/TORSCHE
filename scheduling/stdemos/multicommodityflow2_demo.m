% MULTICOMMODITYFLOW_DEMO2 Demo of multicommodityflow
%
% Demo aplication multicommodityflow problem 
%
% See also 


% Author: Elvira  Hanakova <hanake1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2897 $  $Date:: 2009-04-20 15:17:31 +0100 #$


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

clear all;
clc;
disp('Demo of multicommodityflow algorithm');
alg = input('Choice [1] multicommodityflow, [2] maxmulticommodityflow: ');
if alg == 1
   b = input('Choice [1] b=[4.7;10;10], [2] b=[4.7;7143;15.7143], [3] b=[11;10;10]: ');
else
    b= 0;
end
disp('-------------------------------------------');

close(graphedit);

picturePath = [fileparts(mfilename('fullpath')) filesep];
cDataClean = imread([picturePath 'mapaDemo.png']);
[height,width,colors] = size(cDataClean);
monitor = get(0,'ScreenSize');
height = 440;
width = 820;
colors = 1;
graphedit('position',[(monitor(3)-width)/2, (monitor(4)-height)/2 width height],...
   'hideparts','all','viewnodesnames','off','propertyeditor','off','viewnodesuserparams','on');


%==========================================================================

% slide 1
graphedit('importbackground',cDataClean,'fitbackground','width')


%  slide 2
g = load('graphMCF_demo.mat');
g = struct2cell(g);
g = g{1}(1);
CapAndCost =  [6.2857,36.0000;6.2857,174.0000;...
    6.2857,152.6000;11.0000,180.0000;...
    15.7143,55.0000;15.7143,30.0000;...
    15.7143,22.0000;4.7143,5.0000;...
    15.7143,41.0000;15.7143,65.3000;...
    6.2857,118.7000;9.4286,64.0000;...
   4.7143,38.2000;14.1429,7.0000];
for i =1:length(g.E)
    g.E(i).userParam{1} = CapAndCost(i,1);
    g.E(i).userParam{2} = CapAndCost(i,2);
end
for i = 1:length(g.N)
    g.N(i).Color = [0.20 0.75 0.75];
    g.N(i).GraphicParam{1}.x = g.N(i).GraphicParam(1).x + 7;
    g.N(i).GraphicParam{1}.y = g.N(i).GraphicParam(1).y + 21;
end
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)


% slide 3
s = [1 5 7];
t = [11 6 12];
g.N(s(1)).Color = [0.8 0.42 0.2];
g.N(s(1)).userParam{1} = 1;
g.N(t(1)).Color = [0.8 0.42 0.2]; 
g.N(t(1)).userParam{1} = 11;
g.N(s(2)).Color = [0.20 0.25 0.75];
g.N(s(2)).userParam{1} = 5;
g.N(t(2)).Color = [0.20 0.25 0.75]; 
g.N(t(2)).userParam{1} = 6;
g.N(s(3)).Color = [0.20 0.75 0.25];
g.N(s(3)).userParam{1} = 7;
g.N(t(3)).Color = [0.20 0.75 0.25]; 
g.N(t(3)).userParam{1} = 12;

graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)


% slide 4
legerova = [5 7];
for i = 1:length(legerova)
    g.E(legerova(i)).Color = [0.20 0.25 0.75];
    g.E(legerova(i)).lineWidth = 2.5;
end
sokolska = [9 10];
for i = 1:length(sokolska)
    g.E(sokolska(i)).Color = [0.20 0.75 0.25];
    g.E(sokolska(i)).lineWidth = 2.5;
end
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% slide 5
if b == 1
    b=[4.7;10;10];
     gmcf = multicommodityflow(g,s,t,b,'allShortest');
    disp('Demo of multicommodityflow algorithm');
    disp('g;s = [1 5 7];t = [11 6 12];b = [4.7;10;10];');
    disp('gmcf = multicommodityflow(g,s,t,b,''allShortest'');');
elseif b == 2
    b=[4.7;15.7143;15.7143];
     gmcf = multicommodityflow(g,s,t,b,'allShortest');
    disp('Demo of multicommodityflow algorithm');
    disp('g;s = [1 5 7];t = [11 6 12];b = [4.7;7143;15.7143];');
    disp('gmcf = multicommodityflow(g,s,t,b,''allShortest'');');
elseif b == 3
    b=[11;10;10];
    gmcf = multicommodityflow(g,s,t,b,'allShortest');
    disp('Demo of multicommodityflow algorithm');
    disp('g;s = [1 5 7];t = [11 6 12];b = [11;10;10];');
    disp('gmcf = multicommodityflow(g,s,t,b,''allShortest'');');
elseif alg == 1
     close(graphedit);
     error ('TORSCHE:graph:wrongparamtype',...
            'Input parameter must be {1,2,3}!');
end
if alg == 2
    gmcf = maxmulticommodityflow(g,s,t,'allShortest');
    disp('Demo of maxmulticommodityflow algorithm');
    disp('g;s = [1 5 7];t = [11 6 12];');
    disp('gmcf = maxmulticommodityflow(g,s,t,''allShortest'');');
elseif alg ~= 2 && alg ~= 1
    close(graphedit);
    error ('TORSCHE:graph:wrongparamtype',...
            'Input parameter must be {1,2}!');
end

% slide 6
edl = cell2mat(get(gmcf,'edl'));
unusedEdges = [];
%unusedNodes = [];
usedEdges = [];
%usedNodes = [];
maxUserParam = max(cellfun(@(x)length(x.UserParam),gmcf.E));
for j = 3:maxUserParam
   for i = 1:length(g.E)
    if(gmcf.E(i).userParam(j)>0.1)&&(gmcf.E(i).userParam(j)<9);
        %usedNodes = [usedNodes edl(i,1) edl(i,2)];
        usedEdges = [usedEdges i];
        gmcf.E(i).Color = [0.8 0.42 0.2];
        gmcf.E(i).LineWidth = 2.5;
    elseif gmcf.E(i).userParam(j)>9
    else
        gmcf.E(i).UserParam{j} = [];
    end
   end
end
graphedit(gmcf,'importbackground',cDataClean,'fitbackground','width','viewtab',1)


%==========================================================================

% slideshow
for i =1:6,
    graphedit('viewtab',i);
    pause(3.0);
end
for i = 1,
    graphedit('viewtab',4); pause(2);
    graphedit('viewtab',6); pause(1);
end

graphedit('viewtab',6);
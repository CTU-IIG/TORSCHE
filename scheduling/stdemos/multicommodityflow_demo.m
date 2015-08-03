% MULTICOMMODITYFLOW_DEMO1 Demo of multicommodityflow
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


clc;
disp('Demo of multicommodityflow algorithm');
alg = input('Choice multicommodityflow(1),maxmulticommodityflow(2): ');
disp('-------------------------------------------');

close(graphedit);
picturePath = [fileparts(mfilename('fullpath')) filesep];
cDataClean = imread([picturePath 'mapa2.png']);
[height,width,colors] = size(cDataClean);
monitor = get(0,'ScreenSize');
height = 450;
width = 800;
colors = 1;
%graphedit('importbackground',cDataClean,);
graphedit('position',[(monitor(3)-width)/2, (monitor(4)-height)/2 width height],...
   'hideparts','all','viewnodesnames','off','propertyeditor','off');

%======================================================================

% slide 1
graphedit('importbackground',cDataClean,'fitbackground','width')

%  slide 2
g = graph('adj',zeros(29));

x = [599.5000 703.5000 721.5000 743.5000 764.5000 678.5000 658.5000...
    639.5000 620.5000 523.5000 554.5000 573.5000 598.5000 461.5000...
    443.5000 360.5000 431.5000 406.5000 371.5000 306.5000 217.5000...
    321.5000 210.5000 96.5000 153.5000 74.5000 101.5000 10.5000 -12.0000]+4;

y = [364.5000 299.5000 217.5000 137.5000 46.5000 33.5000 119.5000...
    198.5000 278.5000 311.5000 174.5000 101.5000 21.5000 -1.5000...
    74.5000 63.5000 145.5000 226.5000 208.5000 165.5000 117.5000...
    325.5000 352.5000 301.5000 231.5000 210.5000 83.5000 65.5000 183.5000]+10;
for i = 1:length(g.N)
    g.N(i).GraphicParam{1}.x = x(i);
    g.N(i).GraphicParam{1}.y = y(i);
end
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)


% slide 2
edgeList =  {4 5,93.3916;6 7,88.2950;3 4,82.9699;2 3,83.9524;2 9,85.6154;...
             8 9,82.2253;9 1,88.5268;7 8,81.2527;12.0000 13.0000,83.8153;...
            14 13,138.9172;5 6,86.9770;6 5,86.9770;6 5,86.9770;7 4,86.8850;...
            4 7,86.8850;3 8,84.1724;8 3,84.1724;8 11,88.3233;11 8,88.3233;...
            7 12,86.8850;12 7,86.8850;6 13,80.8950;13 6,80.8950;11 12,75.4321;...
            1 10,92.6553;10 1,92.6553;10 11,140.4635;11 17,126.3725;17 11,126.3725;...
            12 15,132.7742;15 12,132.7742;14 15,78.1025;15 14,78.1025;...
            15 17,72.0069;17 15,72.0069;17 18,83; 18 17,83;15 16,83.7257;...
            16 20,115.4123;10 18,144.6167;18 10,144.6167;18 19,39.3573;...
            19 18,39.3573;19 22,127.2360;22 19,127.2360;19 20,77.9359;...
            20 19,77.9359;20 25,166.6283;22 25,192.5097;23 25,133.7535;...
            23 24,124.8879;24 23,124.8879;24 25,90.2718;25 24,90.2718;...
            20 21,101.1187;21 20,101.1187;21 25,130.7364;25 21,130.7364;...
            21 27,120.8801;26 27,129.8384;27 28,89.8220;28 29,120.1260;...
            29 26,87.7568;26 25,81.7435};
g = graph(g,'edl',edgeList,'edgeDatatype',{'double'});
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% slide 3
for i=1:length(g.E)
    g.E(i).UserParam = {[]};
end
g = distance(g);
s = [2 29];
t = [29 5];
l = 1;
b = [39;30];
col = [2 5 29];
for i = 1:size(col,2)
    g.N(col(i)).Color = [0 0.75 0.75];
end
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% slide 4
if alg == 1
    g = multicommodityflow(g,s,t,b,'kMosteCap',l);
    disp('Demo of multicommodityflow algorithm');
    disp('g;s = [2 29];t = [29 5];b = [39;30];l = 1;');
    disp('g = multicommodityflow(g,s,t,b,''kMosteCap'',l);');
end
if alg == 2
    g = maxmulticommodityflow(g,s,t,'kMosteCap',l);
    disp('Demo of maxmulticommodityflow algorithm');
    disp('g;s = [2 29];t = [29 5];l = 1;');
    disp('g = maxmulticommodityflow(g,s,t,''kMosteCap'',l);');
end

maxUserParam = max(cellfun(@(x)length(x.UserParam),g.E));
add = 0;
edl = cell2mat(get(g,'edl'));
unusedEdges = [];
unusedNodes = [];
usedEdges = [];
usedNodes = [];
for j = 2:maxUserParam
   for i = 1:length(g.E)
    new = find((g.E(i).userParam(j))~=0);
    if ~isempty(new)
        usedNodes = [usedNodes edl(i,1) edl(i,2)];
        usedEdges = [usedEdges i];
        g.E(i).Color = [0 0.75+add 0.75];
        g.E(i).LineWidth = 2.5;
    end
   end
   add = add+0.25;
end
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% slide 5
for  i =1:length(g.N)
    if isempty(find(i==usedNodes))
        unusedNodes = [unusedNodes i];
    end
end
for i = 1:length(g.E)
    ed = find(i==usedEdges);
    if isempty(ed)
       unusedEdges = [unusedEdges i];
    end
end
g = removeedge(g, unusedEdges);
g = removenode(g, unusedNodes);
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

     


 
%======================================================================
% slideshow
for i =1:5,
    graphedit('viewtab',i);
    pause(3.0);
end
for i = 1,
    graphedit('viewtab',5); pause(2);
    graphedit('viewtab',6); pause(2);
end

graphedit('viewtab',6);




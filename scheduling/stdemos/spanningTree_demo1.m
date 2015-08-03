% SPANNINGTREE_DEMO1 Demo of spanningTree
%
% Demo aplication spannigTree of graph with choice from prim's, kruskal's
% and boruvka's algorithm.
%
% See also KRUSKAL, PRIM, BORUVKA


% Author: Elvira  Hanakova <hanake1@fel.cvut.cz>
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


clc;
disp('Demo of spanningTree algorithm.');
alg = input('Choice kruskal(1),prim(2),boruvka(3): ');
disp('-------------------------------------------');

close(graphedit);
monitor = get(0,'ScreenSize');
height = 497;
width = 827;
colors = 1;
graphedit('position',[(monitor(3)-width)/2, (monitor(4)-height)/2 width height],...
    'hideparts','all','viewnodesnames','off','propertyeditor','off')

%======================================================================


%  slide 1
g = graph('adj',zeros(9));
x = [510; 361; 172; 376; 521; 113; 730; 561; 686];
y = [458; 75; 205; 365; 320; 376; 374; 163; 154];
for i = 1:length(g.N),
    g.N(i).GraphicParam{1}.x = x(i);
    g.N(i).GraphicParam{1}.y = y(i);
end
graphedit(g,'viewtab',1, 'arrowsvisibility','off');
%g.N(i).Color = [1 0.5 0];

% slide 2
% edgeList = {1 4;1 7;2 3;3 4;4 5;4 7;6 8;5 9;6 1;3 6;3 8;7 8;7 9};
edgeList ={1 4,2;1 7,1;2 3,5;3 4,4;4 5,3;6 1,15;4 7,7;6 8,6;5 9,9;3 6,8;...
    3 8,10;7 8,14;7 9,11};
g = graph(g,'edl',edgeList,'edgeDatatype',{'double'});
graphedit(g,'viewtab',1)

if alg == 1
    [spanningTree usedEdges] = kruskal(g);
    disp('Demo of kruskal''s algorithm');
end
if alg == 2
    [spanningTree usedEdges] = prim(g);
    disp('Demo of prim''s algorithm');
end
if alg == 3
    [spanningTree usedEdges] = boruvka(g);
    disp('Demo of boruvka''s algorithm');

    % slide 3
    one = find(usedEdges(2,:)==1);
    for i=1:length(one)
        g.E(usedEdges(1, one(i))).Color=[1 0 0];
        g.E(usedEdges(1, one(i))).LineWidth=2;
    end
    graphedit(g,'viewtab',1)
    % slide 4
    two = find(usedEdges(2,:)==2);
    for i=1:length(two)
        g.E(usedEdges(1, two(i))).Color=[1 0 0];
        g.E(usedEdges(1, two(i))).LineWidth=2;
    end
    graphedit(g,'viewtab',1)


else

    % slide 3
    e = g.E(usedEdges(1,1));
    set(e,'Color',[1 0 0]);
    g.E(usedEdges(1,1)) = e;
    g.E(usedEdges(1, 1)).LineWidth=2;
    graphedit(g,'viewtab',1)

    % slide 4
    e = g.E(usedEdges(1,2));
    set(e,'Color',[1 0 0]);
    g.E(usedEdges(1,2)) = e;
    g.E(usedEdges(1, 2)).LineWidth=2;
    graphedit(g,'viewtab',1)

    % slide 5
    e = g.E(usedEdges(1,3));
    set(e,'Color',[1 0 0]);
    g.E(usedEdges(1,3)) = e;
    g.E(usedEdges(1, 3)).LineWidth=2;
    graphedit(g,'viewtab',1)

    % slide 6
    e = g.E(usedEdges(1,4));
    set(e,'Color',[1 0 0]);
    g.E(usedEdges(1,4)) = e;
    g.E(usedEdges(1, 4)).LineWidth=2;
    graphedit(g,'viewtab',1)

    % slide 7
    e = g.E(usedEdges(1,5));
    set(e,'Color',[1 0 0]);
    g.E(usedEdges(1,5)) = e;
    g.E(usedEdges(1, 5)).LineWidth=2;
    graphedit(g,'viewtab',1)

    % slide 8
    e = g.E(usedEdges(1,6));
    set(e,'Color',[1 0 0]);
    g.E(usedEdges(1,6)) = e;
    g.E(usedEdges(1, 6)).LineWidth=2;
    graphedit(g,'viewtab',1)

    % slide 9
    e = g.E(usedEdges(1,7));
    set(e,'Color',[1 0 0]);
    g.E(usedEdges(1,7)) = e;
    g.E(usedEdges(1, 7)).LineWidth=2;
    graphedit(g,'viewtab',1)

    % slide 10
    e = g.E(usedEdges(1,8));
    set(e,'Color',[1 0 0]);
    g.E(usedEdges(1,8)) = e;
    g.E(usedEdges(1, 8)).LineWidth=2;
    graphedit(g,'viewtab',1)
end

% slide 11
u = [6 7 11 12 13];
for i =1:length(u)
    e = g.E(u(i));
    set(e,'Color',[1 1 0]);
    set(e,'UserParam',{});
    g.E(u(i)) = e;
end
graphedit(g,'viewtab',1)

% slide 12
u = [6 7 11 12 13];
for i =1:length(u)
    e = g.E(u(i));
    set(e,'Color',[1 1 1]);
    g.E(u(i)) = e;
end
graphedit(g,'viewtab',1)

% slide 13
%graphedit(g,'viewtab',1)





%======================================================================
% slideshow
for i =1:13,
    graphedit('viewtab',i);
    pause(3.0);
end
for i = 1,
    graphedit('viewtab',11); pause(1);
    graphedit('viewtab',12); pause(1);
end

graphedit(g)

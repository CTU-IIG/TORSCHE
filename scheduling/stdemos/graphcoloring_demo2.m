% GRAPHCOLORING_DEMO2 Demo application of the graph coloring
%
%    See also GRAPHCOLORING


% Author: Vojtech Navratil <navrav1@fel.cvut.cz>
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
disp('Demo of graph coloring algorithm.');
disp('-------------------------------------------');


close(graphedit);

picturePath = [fileparts(mfilename('fullpath')) filesep];
cDataClean = imread([picturePath 'czech_regions.png']);
cDataColor = imread([picturePath 'czech_regions_colored.png']);
[height,width,colors] = size(cDataClean);
monitor = get(0,'ScreenSize');
graphedit('position',[(monitor(3)-width)/2, (monitor(4)-height)/2 width height],...
          'hideparts','all','viewnodesnames','off','propertyeditor','off')

%======================================================================

% Slide 1
graphedit('importbackground',cDataClean,'fitbackground','width')

% Slide 2
g = graph('adj',zeros(14));
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% Slide 3
x = [124;  66; 189; 338; 328; 424; 479; 579; 692; 650; 527; 272; 414; 264];
y = [198; 301; 358; 401; 288; 344; 253; 215; 246; 137; 107; 286; 168;  93];
for i = 1:length(g.N),
    g.N(i).GraphicParam{1}.x = x(i);
    g.N(i).GraphicParam{1}.y = y(i);
end
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% Slide 4
edgeList = {1,2; 1,3; 1,5; 1,14; 2,3; 3,4; 3,5; 4,5; 4,6; 5,6; 5,7;...
            5,13; 5,14; 5,12; 6,7; 7,8; 7,11; 7,13; 8,9; 8,10; 8,11;...
            9,10; 10,11; 11,13; 11,14; 13,14};
g = graph(g,'edl',edgeList);
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% Slide 5
g = graphcoloring(g);
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% Slide 6
graphedit(g,'importbackground',cDataColor,'fitbackground','width','viewtab',1)

% Slide 7
graphedit('createtab',[],'importbackground',cDataColor,'fitbackground','width','viewtab',1)

%======================================================================

% Slideshow
for i = 1:7,
    graphedit('viewtab',i); pause(2.0);
end
for i = 1:4,
    graphedit('viewtab',1); pause(0.5);
    graphedit('viewtab',7); pause(0.5);
end

%end of file

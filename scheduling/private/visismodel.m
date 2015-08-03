function visismodel(file, stopTime, sampleTime, ports, VRin, dispVR, destDir)
%VISISMODEL generates simulink model with specified atributes
%
% Synopsis
% visismodel(file, stopTime, sampleTime, ports, VRin, dispVR, destDir)
%
% Description
%  Function has following parameters:
%  file:
%    - name of Virtual Reality file or implicit name if Virtual Reality is
%    not needed
%  stopTime:
%    - stop time of simulink simulation
%  sampleTime:
%    - sample time for simulink simulation
%  ports:
%    - structure with names of S-Function block ports
%  VRin:
%    - structure with inputs to Virtual Reality
%  dispVR:
%    - 1 - display VR block
%    - 0 - don't display VR block
%  destDir:
%    - directory to store generated files


% Author: Roman Capek <capekr1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2958 $  $Date:: 2009-07-15 11:03:10 +0200 #$


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


nOutputs = 0;
nInputs = 0;
totalOutputSignals = 0;
totalInputSignals = 0;
for i = 1:size(ports,2)
    if ~isempty(ports(i).Output)
        nOutputs = nOutputs+1;
        totalOutputSignals = totalOutputSignals + ports(i).no;
    end
    if ~isempty(ports(i).Input)
        nInputs = nInputs+1;
        totalInputSignals = totalInputSignals + ports(i).ni;
    end    
end

screen = get(0,'ScreenSize');

%Open predefined mdl file to copy mandatory lines
fid = fopen('visismodelsubsystem.mdl', 'r');
model = '';
endOfModification = 0;

while ~endOfModification
    tline = fgets(fid);
    line = num2str(tline(1:end-2));
    if ~ischar(tline)
        break
    end
    switch line
       %Set the stopTime time
       case'	  StopTime		  "100"'
            model = sprintf('%s\t%s%s%s\n', model, 'StopTime		  "', num2str(stopTime), '"');       
       %Change name
       case '  Name			  "visismodelbase"'
            model = sprintf('%s%s%s%s\n', model, '  Name			  "', file(1:end-4), '"');       
       %Modify system
       case '  System {'
            %Set location and name for Simulink main window
            model = sprintf('%s%c', model, tline);
            model = sprintf('%s\t%s%s%s\n', model, 'Name			  "', file(1:end-4), '"');
            Location = ['[' num2str(screen(3)/2+10) ',' num2str(0) ',' num2str(screen(3)-15) ',' num2str(min(0.83*screen(4),150+nOutputs*30)) ']'];
            model = sprintf('%s\t%s%s\n', model, 'Location     ', Location);
            tline = fgets(fid);  %#ok - jumps over one row
            tline = fgets(fid);  %#ok - jumps over one row
            %Set location, name and ports for Subsystem block
            while 1
                tline = fgets(fid);
                line = tline(1:end-2);
                if strcmp(line, '      Name		      "Subsystem"')
                    model = sprintf('%s\t%s\n', model,['  Name           "' file(1:end-4) '_Subsystem"']);
                    tline = fgets(fid); %#ok - jumps over one row
                    str = ['  Ports             [' num2str(nInputs) ', ' num2str(nOutputs) ']'];
                    model = sprintf('%s\t%s\n', model, str);
                    tline = fgets(fid); %#ok - jumps over one row
                    str = ['  Position		      [150, 50, 250, ', num2str(100+max(nOutputs,nInputs)*25), ']'];
                    model = sprintf('%s\t%s\n', model, str);
                else
                    if strcmp(line, '      System {')
                        model = sprintf('%s%s\n', model, '  System {');
                        break
                    else
                        model = sprintf('%s%c', model, tline);
                    end
                end
            end
            tline = fgets(fid); %#ok - jumps over one row
            tline = fgets(fid); %#ok - jumps over one row
            %Set name and location of subsystem simulink window
            str = ['Name			"' file(1:end-4) '_Subsystem"'];
            model = sprintf('%s\t%s\n', model, str);
            str = 'Location		      [750, 400, 1170, 600]';
            model = sprintf('%s\t%s\n', model, str);
            %Create subsystem blocks
            while 1
                tline = fgets(fid);
                line = tline(1:end-2);
                if strcmp(line, '	ZoomFactor		"100"')
                    model = sprintf('%s%c', model, tline);
                    %WRITE SUBSYSTEM BLOCKS HERE
                    %Create Demux block
                    str = Demux(totalOutputSignals, [295, 59, 300, 146]', '"Demux"');
                    model = sprintf('%s%s\n', model, str);
                    %Create Mux block
                    str = Mux(totalInputSignals, [95, 59, 100, 146]', '"Mux"');
                    model = sprintf('%s%s', model, str);
                    %Create S-Function block
                    str = SFunction(file, dispVR, destDir);
                    model = sprintf('%s%s\n', model, str);
                    %Connect Mux with S-Function input
                    str = Line('Mux', 1, ['S-Function ' file(1:end-4)], 1);
                    model = sprintf('%s%s\n', model, str);
                    str = Line(['S-Function ' file(1:end-4)], 1,'Demux', 1);
                    model = sprintf('%s%s\n', model, str);                    
                    %Connect inports with Mux or create Ground and connect with Mux
                    if nInputs == 0
                        str = Ground([15, 96, 35, 116]);
                        model = sprintf('%s%s\n', model, str);
                        str = Line('Ground', 1, 'Mux', 1);
                        model = sprintf('%s%s\n', model, str);                                 
                    else
                        usedPorts = 0;
                        for i = 1:nInputs
                            par = i-nInputs/2;
                            str = Inport(ports(i).Input, [0, floor(75+par*35), 20, floor(95+par*35)]);
                            model = sprintf('%s%s\n', model, str);
                            str = Demux(ports(i).ni, [45, floor(75+par*50), 50, floor(95+par*50)]', ['"Demux' num2str(i) '"']);
                            model = sprintf('%s%s\n', model, str);
                            str = Line(ports(i).Input, 1, ['Demux' num2str(i)], 1);
                            model = sprintf('%s%s\n', model, str);
                            for j = 1:ports(i).ni
                                str = Line(['Demux' num2str(i)], j, 'Mux', usedPorts+j);
                                model = sprintf('%s%s\n', model, str);
                            end
                            usedPorts = usedPorts + ports(i).ni;
                        end
                    end
                    %Connect outports with Demux or create Termminator and connect with Demux
                    if nOutputs == 0
                        str = Terminator([375, 95, 395, 115]);
                        model = sprintf('%s%s\n', model, str);
                        str = Line('Demux', 1, 'Terminator', 1);
                        model = sprintf('%s%s\n', model, str);                                 
                    else
                        usedPorts = 0;
                        for i = 1:nOutputs
                            par = i-nOutputs/2;
                            str = Outport(ports(i).Output, [395, floor(75+par*35), 415, floor(95+par*35)]);
                            model = sprintf('%s%s\n', model, str);
                            str = Mux(ports(i).no, [345, floor(75+par*50), 350, floor(95+par*50)]', ['"Mux' num2str(i) '"']);
                            model = sprintf('%s%s\n', model, str);
                            str = Line(['Mux' num2str(i)], 1, ports(i).Output, 1);
                            model = sprintf('%s%s\n', model, str);
                            for j = 1:ports(i).no
                                str = Line('Demux', usedPorts+j, ['Mux' num2str(i)], j);
                                model = sprintf('%s%s\n', model, str);
                            end
                            usedPorts = usedPorts + ports(i).no;
                        end
                    end
                    break
                end
            end
            model = sprintf('%s%s\n', model, '    }');
            model = sprintf('%s%s\n', model, '  }');
            %WRITE ALL OTHER BLOCKS HERE
            if dispVR
                str = BlockVR(file, VRin, [350, 50, 500, 100+size(VRin,2)*25], sampleTime, nOutputs);
                model = sprintf('%s%s\n', model, str);
            end
            model = sprintf('%s%s\n', model, '}');
            model = sprintf('%s%s\n', model, '}');
%             endOfModification = 1;
            break
       %Otherwise copy text
       otherwise
            model = sprintf('%s%c', model, tline);
    end
end
fclose(fid);

%Insert acquired string in new file
try
    fileToOpen = [destDir '\' file(1:end-4) '.mdl'];
    fid = fopen(fileToOpen, 'w+');
    fprintf(fid, '%s', model);
catch le
    err = 'TORSCHE:VISIS:parseError';
    err = sprintf('%s\n%s', err,['Simulink model ''' file(1:end-4) '.mdl'' not generated!']);
    error('%s\n%s', err, le.message) %#ok
end
fclose(fid);
display(['Simulink file ''' file(1:end-4) '.mdl'' created.']);

end

%%
%Generates text for VR block
function str = BlockVR(file, VRin, Pos, sampleTime, nOutputs)
    str = ' Block {';
    str = sprintf('%s\n%s', str, '  BlockType     Reference');
    str = sprintf('%s\n%s\t\t\t%s%s%s', str, '  Name', '"', file(1:end-4), '"');
	str = sprintf('%s\n%s%s%s', str, '  Ports         [', num2str(nOutputs), ']');
    Position = ['[' num2str(Pos(1)) ',' num2str(Pos(2)) ',' num2str(Pos(3)) ',' num2str(Pos(4)) ']'];
    str = sprintf('%s\n%s\t\t%s', str, '  Position', Position);
    str = sprintf('%s\n%s', str, '  SourceBlock	"vrlib/VR Sink"');
    str = sprintf('%s\n%s', str, '  SourceType    "Virtual Reality Sink"');
	str = sprintf('%s\n%s%s%s', str, '  SampleTime    "', num2str(sampleTime), '"');
    str = sprintf('%s\n%s', str, '  ViewEnable    on');
    str = sprintf('%s\n%s', str, '  RemoteChange  off');
	str = sprintf('%s\n%s', str, '  RemoteView    on');
    if size(VRin,2)>0
        str = sprintf('%s\n%s', str, '  FieldsWritten ');
    end
    for i = 1:size(VRin,2)
        switch VRin(i).Variable
            case 'translation'
                str = sprintf('%s%s%s%s\n', str, '   "', VRin(i).Node, '.translation.3.1.double#"');
            case 'size'
                str = sprintf('%s%s%s%s\n', str, '   "', VRin(i).Node, '.size.3.1.double#"');
            case 'rotation'
                str = sprintf('%s%s%s%s\n', str, '   "', VRin(i).Node, '.rotation.4.1.double#"');
            case 'diffuseColor'
                str = sprintf('%s%s%s%s\n', str, '   "', VRin(i).Node, '.diffuseColor.3.1.double#"');
            case 'height'
                str = sprintf('%s%s%s%s\n', str, '   "', VRin(i).Node, '.height.1.1.double#"');
            case 'radius'
                str = sprintf('%s%s%s%s\n', str, '   "', VRin(i).Node, '.radius.1.1.double#"');
            otherwise
                err = 'TORSCHE:VISIS:parseError';
                error('%s\n%s', err,['Simulink model ''' file(1:end-4) '.mdl'' not generated!'])
        end
    end
	str = sprintf('%s\n%s%s%s', str, '  WorldFileName "', file, '"');
	str = sprintf('%s\n%s', str, '  AutoView      on');
    screen = get(0,'ScreenSize');
    Location = [num2str(5) ',' num2str(75) ',' num2str(screen(3)/2-10) ',' num2str(350)]';
	str = sprintf('%s\n%s%s%s', str, '  FigureProperties  "{''Position'', ''Record2DFileName''; [', Location, '], ''%f_anim_%n.avi''}"');  
    str = sprintf('%s\n%s', str, '  }');
end

%%
%Generates text for S-Function
function str = SFunction(file, dispVR, destDir)
    str = ' Block{';
    str = sprintf('\n\t%s\n\t%s', str, '  BlockType     "S-Function"');
    str = sprintf('%s\n\t%s', str, ['  Name              "S-Function ' file(1:end-4) '"']);
    str = sprintf('%s\n\t%s', str, '  Ports		      [1, 1]');
    str = sprintf('%s\n\t%s', str, '  Position		      [150, 80, 250, 130]');
    str = sprintf('%s\n\t%s', str, ['  FunctionName	      "S_' file(1:end-4) '"']);
    if dispVR
        str = sprintf('%s\n\t%s', str, '  Parameters	      "file(1:end-4),sampleTime,TS,period"');
    else
        str = sprintf('%s\n\t%s', str, '  Parameters	      "sampleTime,TS,period"');
    end
    str = sprintf('%s\n\t%s', str, '  }');        
end

%%
%Generates text for Line block
function str = Line(SrcBlock, SrcPort, DstBlock, DstPort)
    str = '	Line {';
    str = sprintf('%s\n\t%s\t\t%s%s%s', str, ' SrcBlock', '"', SrcBlock, '"');
    str = sprintf('%s\n\t%s\t\t%s', str, ' SrcPort', num2str(SrcPort));
    str = sprintf('%s\n\t%s\t\t%s%s%s', str, ' DstBlock', '"', DstBlock, '"');
    str = sprintf('%s\n\t%s\t\t%s', str, ' DstPort', num2str(DstPort));
    str = sprintf('%s\n\t%s', str, '}');
end

%%
%Generates text for Outport
function str = Outport(Name, Position)
    str = '	Block {';
    str = sprintf('%s\n\t%s', str, 'BlockType      Outport');
    str = sprintf('%s\n\t%s\t%s', str, 'Name', Name);
    pos = ['[' num2str(Position(1)) ', ' num2str(Position(2)) ', ' num2str(Position(3)) ', ' num2str(Position(4)) ']'];
    str = sprintf('%s\n\t%s\t\t%s%s%s', str, ' Position', pos);
    str = sprintf('%s\n\t%s', str, ' IconDisplay		  "Port number"');
    str = sprintf('%s\n\t%s', str, ' BusOutputAsStruct	  off');    
    str = sprintf('%s\n\t%s', str, '}');
end

%%
%Generates text for Inport
function str = Inport(Name, Position)
    str = '	Block {';
    str = sprintf('%s\n\t%s', str, 'BlockType      Inport');
    str = sprintf('%s\n\t%s\t%s', str, 'Name', Name);
    pos = ['[' num2str(Position(1)) ', ' num2str(Position(2)) ', ' num2str(Position(3)) ', ' num2str(Position(4)) ']'];
    str = sprintf('%s\n\t%s\t\t%s%s%s', str, ' Position', pos);
    str = sprintf('%s\n\t%s', str, ' IconDisplay		  "Port number"');
    str = sprintf('%s\n\t%s', str, '}');
end

%%
%Generates text for Terminator
function str = Terminator(Position)
    str = '	Block {';
    str = sprintf('%s\n\t%s', str, 'BlockType      Terminator');
    str = sprintf('%s\n\t%s', str, 'Name         Terminator');
    pos = ['[' num2str(Position(1)) ', ' num2str(Position(2)) ', ' num2str(Position(3)) ', ' num2str(Position(4)) ']'];
    str = sprintf('%s\n\t%s\t\t%s%s%s', str, ' Position', pos);
    str = sprintf('%s\n\t%s', str, '}');
end

%%
%Generates text for Ground
function str = Ground(Position)
    str = '	Block {';
    str = sprintf('%s\n\t%s', str, 'BlockType      Ground');
    str = sprintf('%s\n\t%s', str, 'Name         Ground');
    pos = ['[' num2str(Position(1)) ', ' num2str(Position(2)) ', ' num2str(Position(3)) ', ' num2str(Position(4)) ']'];
    str = sprintf('%s\n\t%s\t\t%s%s%s', str, ' Position', pos);
    str = sprintf('%s\n\t%s', str, '}');
end

%%
%Generates text for Mux block
function str = Mux(nInputs, Position, Name)
    str = '    Block {';
    str = sprintf('%s\n%s\n', str,'      BlockType		  Mux');
    str = sprintf('%s\t%s\t%s\n', str, '  Name', Name);
    str = sprintf('%s%s\n', str,['      Ports          [' num2str(max(1,nInputs)) ', 1]']);
    pos = ['[' num2str(Position(1)) ', ' num2str(Position(2)) ', ' num2str(Position(3)) ', ' num2str(Position(4)) ']'];
    str = sprintf('%s\t%s\t\t%s%s%s', str, '  Position', pos);    
    str = sprintf('%s\n%s\n', str,'      ShowName		  off');
    str = sprintf('%s%s\n', str,['      Inputs        "' num2str(max(1,nInputs)) '"']);
    str = sprintf('%s%s\n', str,'      DisplayOption		  "bar"');
    str = sprintf('%s%s', str,'    }');
end

%%
%Generates text for Demux block
function str = Demux(nOutputs, Position, Name)
    str = '    Block {';
    str = sprintf('%s\n%s\n', str,'      BlockType		  Demux');
    str = sprintf('%s\t%s\t%s\n', str, '  Name', Name);
    str = sprintf('%s%s\n', str,['      Ports          [1, ' num2str(max(1,nOutputs)) ']']);
    pos = ['[' num2str(Position(1)) ', ' num2str(Position(2)) ', ' num2str(Position(3)) ', ' num2str(Position(4)) ']'];
    str = sprintf('%s\t%s\t\t%s%s%s', str, '  Position', pos);     
    str = sprintf('%s\n%s\n', str,'      ShowName		  off');
    str = sprintf('%s%s\n', str,['      Outputs        "' num2str(max(1,nOutputs)) '"']);
    str = sprintf('%s%s\n', str,'      DisplayOption		  "bar"');
    str = sprintf('%s%s', str,'    }');
end

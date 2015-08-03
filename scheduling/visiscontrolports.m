function ports = visiscontrolports(varargin)
%VISISCONTROLPORTS sets input and output names of S-Function block ports
%
%Synopsis
% ports = visiscontrolports('Input', Name, Count[,Name2,Count2...], 'Output', Name, Count[,Name2,Count2...])
%
%Description
%  ports:
%    - structure with included information about S-Function inputs and
%      outputs
%  Input:
%    - keyword
%  Output:
%    - keyword
%  Name:
%    - string name of input/output
%  Count:
%    - vector size for each port


% Author: Roman Capek <capekr1@fel.cvut.cz>
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2957 $  $Date:: 2009-07-14 13:07:04 +0200 #$


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


ports = struct('Input',{},'ni',{},'Output',{},'no',{});
cnt = 1;

if isempty(varargin)
    return
end

switch varargin{1}
    case 'Input'
        i = 0;
        while i<nargin-1
            if ischar(varargin{2+i}) 
                if ~strcmp(varargin{2+i},'Output')
                    if nargin>= 3+i && isa(varargin{3+i},'double')
                        ports(cnt).Input = varargin{2+i};
                        ports(cnt).ni = varargin{3+i};
                        cnt = cnt+1;
                    else
                        err = 'TORSCHE:VISIS:invalidParameter';
                        error('%s\n%s', err,'Requested format: visiscontrolports(''Input'',''Name1'',count1,''Name2'',count2...)')
                    end
                else
                    cnt = 1;
                    i = i+1;
                    while  i<nargin-1
                        if ischar(varargin{2+i}) 
                            if nargin>= 3+i && isa(varargin{3+i},'double')
                                ports(cnt).Output = varargin{2+i};
                                ports(cnt).no = varargin{3+i};
                                cnt = cnt+1;
                            else
                                err = 'TORSCHE:VISIS:invalidParameter';
                                error('%s\n%s', err,'Requested format: visiscontrolports(''Output'',''Name1'',count1,''Name2'',count2...)')
                            end
                        else
                            err = 'TORSCHE:VISIS:invalidParameter';
                            error('%s\n%s', err,'Requested format: visiscontrolports(''Output'',''Name1'',count1,''Name2'',count2...)')
                        end
                        i = i+2;
                    end
                end
            else
                err = 'TORSCHE:VISIS:invalidParameter';
                error('%s\n%s', err,'Requested format: visiscontrolports(''Input'',''Name1'',count1,''Name2'',count2...)')
            end
            i = i+2;
        end
    case 'Output'
        i = 0;
        while i<nargin-1
            if ischar(varargin{2+i}) 
                if ~strcmp(varargin{2+i},'Input')
                    if nargin>= 3+i && isa(varargin{3+i},'double')
                        ports(cnt).Output = varargin{2+i};
                        ports(cnt).no = varargin{3+i};
                        cnt = cnt+1;
                    else
                        err = 'TORSCHE:VISIS:invalidParameter';
                        error('%s\n%s', err,'Requested format: visiscontrolports(''Output'',''Name1'',count1,''Name2'',count2...)')
                    end
                else
                    cnt = 1;
                    i = i+1;
                    while  i<nargin-1
                        if ischar(varargin{2+i}) 
                            if nargin>= 3+i && isa(varargin{3+i},'double')
                                ports(cnt).Input = varargin{2+i};
                                ports(cnt).ni = varargin{3+i};
                                cnt = cnt+1;
                            else
                                err = 'TORSCHE:VISIS:invalidParameter';
                                error('%s\n%s', err,'Requested format: visiscontrolports(''Input'',''Name1'',count1,''Name2'',count2...)')
                            end
                        else
                            err = 'TORSCHE:VISIS:invalidParameter';
                            error('%s\n%s', err,'Requested format: visiscontrolports(''Input'',''Name1'',count1,''Name2'',count2...)') 
                        end
                        i = i+2;
                    end
                end
            else
                err = 'TORSCHE:VISIS:invalidParameter';
                error('%s\n%s', err,'Requested format: visiscontrolports(''Output'',''Name1'',count1,''Name2'',count2...)')
            end
            i = i+2;
        end            
    otherwise
        err = 'TORSCHE:VISIS:invalidParameter';
        error('%s\n%s', err,['Unknown keyword ''' varargin{1} '''.'])
end

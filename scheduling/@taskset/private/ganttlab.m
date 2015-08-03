function [ganttResponse] = ganttlab(varargin)
%GANTTLAB Interface to psgantt
%
% gantt = ganttlab(xml,css,datatype,width)
%   gantt    - gantt chart in requested datatype
%   xml, css - xml and css string in char data type
%   datatype - requested datatype of gantt chart
%   width    - width of image
%
% config = ganttlab('config','datatype')
%   config   - return available datatypes in cell matrix


% Author: Michal Kutil <kutilm@fel.cvut.cz>
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


cnf.serverurl = 'http://rtime.felk.cvut.cz/psgantt/service/index.php';

ni = nargin;
switch ni
    case 4,
        % call psgantt from server

        xmlE=base64encode(varargin{1});
        cssE=base64encode(varargin{2});
        %xmlE     = varargin{1};
        %cssE     = varargin{2};
        datatype = varargin{3};
        width    = varargin{4};

        values = {xmlE,cssE,datatype,width};
        names =  {'XML','CSS','datatype','width'};
        types =  {'string','string','string','int'};

        % Create the message, make the call, and convert the response into a variable.
        soapMessage = createSoapMessage( ...
            'urn:psGanttService', ...
            'psgantt', ...
            values,names,types,'rpc');
        try
            response = callSoapService( ...
                cnf.serverurl, ...
                'urn:psGanttService#psGanttService#psgantt', ...
                soapMessage);
        catch
            msgstruct = lasterror;
            error_msg = strread(msgstruct.message,'%s','whitespace','\n');
            msgstruct.message=error_msg{2:end};
            msgstruct.identifier = 'TORSCHE:ganttlab:serverError';
            error(msgstruct.identifier, '%s', msgstruct.message);            
        end
        outputInt = parseSoapResponse(response);
        outputStatus = outputInt(1);
        outputInt = outputInt(2:end);
        if strcmp(outputStatus,'0')
            msgstruct.message = outputInt;
            msgstruct.identifier = 'TORSCHE:ganttlab:serverError';
            error(msgstruct.identifier, '%s', msgstruct.message);
        end
        ganttResponse = base64decode(outputInt);

    case 2,
        % call psganttconfig from server
        switch varargin{1}
            case 'config',
                key = varargin{2};

                values = {key};
                names =  {'key'};
                types =  {'int'};

                % Create the message, make the call, and convert the response into a variable.
                soapMessage = createSoapMessage( ...
                    'urn:psGanttService', ...
                    'psganttconfig', ...
                    values,names,types,'rpc');
                response = callSoapService( ...
                    cnf.serverurl, ...
                    'urn:psGanttService#psGanttService#psganttconfig', ...
                    soapMessage);
                outputInt = parseSoapResponse(response);
                try
                    ganttResponse = eval(outputInt);
                catch
                    error('TORSCHE:ganttlab:serverError','Invalid data type response.')
                end
        end
    otherwise,
        error('TORSCHE:ganttlab:syntax','Invalid number of input arguments.')
end

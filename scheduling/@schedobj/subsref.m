function varargout = subsref(schedobj,index)
%SUBSREF  SUBSREF property management in referencing operation.
%
%   SCHEDOBJ.property gets a value of the property.
%
%   This is equivalent to calling GET method with shorter syntax or calling
%   an object method.
%
%   See also SCHEDOBJ/GET.

% Author: Michal Kutil <kutilm@fel.cvut.cz>
% Author: Michal Sojka <sojkam1@fel.cvut.cz>
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


len = length(index);
Value = schedobj;
input_class = class(Value);
function_call = 0; %when true, function is called otherwise property is returned
more_outputs = 0; %when true, some called function return more than one value
i=1;
%for i=1:len
while i<=len
    try
        switch index(i).type
            case '.'
                if isstruct(Value)
                    Value = Value.(index(i).subs);
                else
                    % imatch = find(strcmpi(methods(Value,'-full'),index(i).subs));
                    % if ~isempty(imatch)
                    if ismethod(class(Value), index(i).subs)
                        try
                            if strcmp(index(i+1).type,'()')
                                narg = nargout([class(Value) '/' index(i).subs ]);
                                switch narg
                                    case {-2,-1,0}
                                        clear ans;
                                        eval([index(i).subs '( Value, index(i+1).subs{:});']);
                                        if exist('ans','var')
                                            Value = ans; %#ok<NOANS>
                                        end
                                        function_call=1;
                                    case 1
                                        eval(['Value = ' index(i).subs '( Value, index(i+1).subs{:});'])
                                        function_call=1;
                                    otherwise
                                        str = '[';
                                        for ii=1:narg
                                            str = [str 'varargout{' int2str(ii) '} ']; %#ok<AGROW>
                                        end
                                        str = [str ']']; %#ok<AGROW>
                                        eval(['' str ' = ' index(i).subs '( Value, index(i+1).subs{:});'])
                                        more_outputs=1; %more output values -- cannot continue
                                end
                                i=i+1;
                            end
                        catch

                            narg = nargout([class(Value) '/' index(i).subs ]);
                            switch narg
                                case {-1,0}
                                    clear ans;
                                    eval([index(i).subs '( Value);']);
                                    if exist('ans','var')
                                        Value = ans; %#ok<NOANS>
                                    end
                                    function_call = 1;
                                case 1
                                    eval(['Value = ' index(i).subs '( Value);'])
                                    function_call = 1;
                                otherwise
                                    str = '[';
                                    for ii=1:narg
                                        str = [str 'varargout{' int2str(ii) '} '];
                                    end
                                    str = [str ']'];
                                    eval(['' str ' = ' index(i).subs '( Value);'])
                                    more_outputs = 1;
                                    % return; %more output values -- cannot continue
                            end
                        end
                    else
                        Value = get(Value, index(i).subs);
                    end
                end
            case {'()','{}'}
                % {} are available only for UserParam
                if strcmp(index(i).type,'{}')
                    cellsub = {index.subs};
                    includeUserParam = false;
                    for icellsub = 1:i
                        if ischar(cellsub{icellsub}) && ~isempty(findstr(cellsub{icellsub}, 'UserParam'))
                            includeUserParam = true;
                            break;
                        end
                    end
                    if ~includeUserParam
                        error('TORSCHE:IncorrectIndexingMethod','Incorrect indexing method.');
                    end
                end

                if isa(Value,'taskset')
                    reindexing_index = index(i).subs{1};
                    tmp_tasks = get(Value,'tasks');
                    set(Value,'tasks',{tmp_tasks{reindexing_index}});
                    tmp_Prec = get(Value,'Prec');
                    remove_tasks = setdiff(1:length(tmp_Prec),reindexing_index);
                    for ii = 1:length(remove_tasks)
                        predecessors = find(tmp_Prec(:,remove_tasks(ii)));
                        successors =  find(tmp_Prec(remove_tasks(ii),:));
                        tmp_Prec(predecessors,successors) = 1; %#ok<FNDSB>
                    end
                    set(Value,'Prec',tmp_Prec(reindexing_index,reindexing_index));
                elseif iscell(Value)
                    Value = {Value{index(i).subs{:}}};
                    if length(Value) == 1
                        Value = Value{1};
                    end
                else
                    Value = Value(index(i).subs{:});
                end
            otherwise
                error('Unknown indexing method');
        end % switch S.
    catch
        rethrow(lasterror)
    end
    i=i+1;
end
if ~more_outputs
    varargout{1}=Value;
    if strcmp(class(Value),input_class) && function_call
        objectname = inputname(1);
        assignin('caller',objectname,Value);
    end
end

function T = hu (T, prob, m, varargin)
%HU is scheduling algorithm for P|in-tree,pj=1|Cmax problem
%(can be called on labeled taskset with problem P2|prec,pj=1|Cmax )
%
%Synopsis
%       TS = HU(T, prob, m)
%       TS = HU(T, prob, m, verbose)
%       TS = HU(T, prob, m, options)
%
%Description
%  Properties:
%   T:
%     - set of tasks, taskset object with precedence constrains
%   prob:
%     - P|in-tree,pj=1|Cmax
%     - P2|prec,pj=1|Cmax
%   m:
%     - processors
%   verbose:
%     - 0 - default, no information
%     - 1 - display scheduling information
%   options:
%     - global scheduling toolbox variables (SCHOPTIONSSET)
%
%See also COFFMANGRAHAM, SCHOPTIONSSET, ALGPCMAX, BRUCKER76.

% Author: J. Martinsky
% Originator: Michal Kutil <kutilm@fel.cvut.cz>
% Originator: Premysl Sucha <suchap@fel.cvut.cz>
% Project Responsible: Zdenek Hanzalek
% Department of Control Engineering
% FEE CTU in Prague, Czech Republic
% Copyright (c) 2004 - 2009 
% $Revision: 2895 $  $Date:: 2009-03-18 11:24:58 +0100 #$

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

if ~isa(T,'taskset')
    error('Taskset class must be taskset');
end
if ~(isa(m,'double')&m>0)
    error('Number of processors must be positive number.');
end
if ~isa(prob,'problem')
    error('Problem class must be problem.');
end
if ~((is(prob,'alpha','P') && is(prob,'betha','in-tree,pj=1') && is(prob,'gamma','Cmax')) | ...
     (is(prob,'alpha','P2') && is(prob,'betha','prec,pj=1') && is(prob,'gamma','Cmax')))
    error('This problem can''t be solved by Hu.');
elseif is(prob,'betha','prec') & m~=2
    error('Problem P2|prec,pj=1|Cmax can be solved only on 2 processors.');
end

%read precedence constrains
prec = T.prec;
n = length(prec);

if ~(size(prec,1)==size(prec,2))
    error('Precedence constrains must be square matrix.');
end;
if ~(n==count(T))
    error('Invalid precedence constrains!');
end
if sum(sum(T.prec))==0
    warning('Precedence constrains not specified.');
end
if sum(T.proctime==ones(1,n))~=n
    error('Processing time of tasks must be 1');
end

%verbose mode
verbose=0;
if nargin>3
    if isa(varargin{1},'struct')
        verbose=varargin{1}.verbose;
    elseif isa(varargin{1},'double')
        verbose=varargin{1};
    end
end

%init
processors = zeros(m,1);
start = zeros(1,n);
tlength = ones(1,n);
processor = zeros(1,n);
t=0;

%mark levels
if isa(T.UserParam,'double') & ~isnan(T.UserParam)
    levels = T.UserParam;
    problemnotation = 'P2|prec,pj=1|Cmax';    
else
    %select root
    root = find(sum(prec,2)==0);
    if length(root)~=1
        error('Not in-tree precedences');
    end
    levels = markintree(prec,root);
    problemnotation = 'P|in-tree,pj=1|Cmax';
end
%start algorithm
if verbose==1
    disp('~~~~~~~~ Hu algorithm ~~~~~~~~')
    disp('start')
    disp(['task  : ',num2str(1:n)]);
    disp(['levels: ',num2str(levels)]);
    disp(num2str(processor));
end
time = cputime;
while min(diag(prec))==0
    %create list of executable tasks
    list=find(sum(prec,1)==0);
    if verbose==1
        disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        disp(['time: ',int2str(t)]);
    end
    %add levels
    lvl=levels(list);
    [s,p]=sort(lvl,2,'descend');
    %sort list by levels
    list(p)=list;
    if verbose==1 disp(['executable tasks: ',num2str(list)]);
    end
    ll=length(list);
    %check list size
    if ll>m
        list=list(1:m);
        ll=m;
    end;
    %assign processors
    start(list)=t;
    processor(list)=1:ll;
    if verbose==1 disp(['processor: ',num2str(processor)]);
    end
    %mark assigned tasks
    prec(list(1,:),:)=0;
    d=diag(prec);
    d(list(1,:))=inf;
    prec=prec+diag(d);
    %increment time
    t=t+1;
end;
%add schedule results
add_schedule(T,'time',cputime - time);
add_schedule(T,['Hu`s algorithm for ' problemnotation ' problem'],start,tlength,processor);

function [markedtree]=markintree(prec,root)
% MARKINTREE mark branches on in-tree structure
%
%Synopsis
%   markedtree = MARKINTREE(prec, root)
%
%Description
%       prec   - precedence constrains
%       root   - in-tree root position
%
%See also HU.

if ~isa(prec,'double')|size(prec,1)~=size(prec,2)
    error('Precedence constrains must be square matrix!');
end;
if length(root)>1|~isa(root,'double')|root>length(prec)|root<1
    error('In-tree root must be positive double number of in-tree root task!');
end
%init output
markedtree=zeros(1,length(prec));
%find predecessors
pre=find(prec(:,root)==1);
%mark branches
for i=1:length(pre)
    % test if tree structure
    if markedtree(pre(i))~=0 error('Not in-tree precedences!');
    end
    markedtree=markintree(prec,pre(i))+markedtree;
end;
%increase branches mark by 1
marked=find(markedtree);
markedtree(marked)=markedtree(marked)+1;
%mark root 1
markedtree(root)=1;

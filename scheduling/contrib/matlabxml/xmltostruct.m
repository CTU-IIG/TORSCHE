%  struct= xml2struct(xmlfile,'validating',rncfile,'mixedContendEnabled',1)
%   
%

%---Validating xmlfile with rncfile -RELAX NG (compact syntax)
%for i=1:length(varargin)
%    if strcmp(varargin{i},'-validating')
%        rncfile=varargin{i+1};
%        break;
%    end
%end
%isValidating=any(strcmp(varargin,'-validating'));
%isValidatingFunction=exist('validrnc','file')~=0;
%if (isValidating & isValidatingFunction) 
%    isXmlValid=validrnc(xmlfile,rncfile);
%end     


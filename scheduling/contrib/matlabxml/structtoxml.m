%STRUCTTOXML convert struct to xml.
%    docNode = STRUCTTOXML(struct) returns matlab (java) xml docNode
%    converted from (xml)struct.
% 
%    (xml)struct can include folowing fields:
%      struct.tag         - xml tag name (char data type)
%      struct.attribut    - struct with attributs for tag
%      struct.comment     - comments in tag
%      struct.comment_pre - comments before tag
%      struct.data        - data inside the tag. Allowed data types are
%                           chars or cell with (xml)structs.
%
%      Attribut example
%        struct.attribut.name = 'Name';
%        struct.attribut.year = '1995';
%        ouput: <tag name="name" year="1995" >
%  
%     See also vartostruct

%   Author(s): M. Kutil
%   Copyright (c) 2005
%   $Revision: 2892 $  $Date: 2009-03-18 10:20:37 +0100 (st, 18 III 2009) $


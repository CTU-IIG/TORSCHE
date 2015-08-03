function g = toblue(g)
%
%    without parameters
%
    for i = 1:length(g.N)
        node = g.N(i);
        set_graphic_param(node,'Color',[0 0 1]);
        g.N(i) = node;
    end
    g.Name = [g.Name 'blue'];
    
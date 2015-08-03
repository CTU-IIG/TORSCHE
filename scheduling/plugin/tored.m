function g = tored(g)
    for i = 1:length(g.N)
        node = g.N(i);
        set_graphic_param(node,'Color',[1 0 0]);
        g.N(i) = node;
    end
    
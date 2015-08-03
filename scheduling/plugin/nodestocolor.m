function g = nodestocolor(g)
    if isa(g,'graph')
        color = uisetcolor('Graphedit - palette');
        if (length(color) ~= 1)
            for i = 1:length(g.N)
                node = g.N(i);
                set_graphic_param(node,'Color',color);
                g.N(i) = node;
            end
            g.Name = [g.Name ' - Color'];
        else
            g = [];
        end
    else
        g = [];
    end
    
function g = tocolor(g)
    if nargin == 1
        color = uisetcolor([1 1 1],'Graphedit - palette');
        if (length(color) ~= 1)
            for i = 1:length(g.N)
                node = g.N(i);
                set_graphic_param(node,'Color',color);
                g.N(i) = node;
            end
        else
            g = [];
        end
    end
    
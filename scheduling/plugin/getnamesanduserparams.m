function out = getnamesanduserparams(g)
    nodes = []; edges = [];
    for i = 1:length(g.N)
        nodes{i} = g.N{i}.Name;
    end
    for i = 1:length(g.E)
        edges{i} = g.E{i}.UserParam;
    end
    out = struct('Nodes',nodes,'Edges',edges);
    
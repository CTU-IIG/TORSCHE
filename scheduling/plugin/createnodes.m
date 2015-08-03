function g = createnodes(g,varargin)
	g = graph;
	for i = 1:round(varargin{1})
		n = node;
		n.Name = ['T_{' num2str(i) '}'];
		g.N(i) = n;
	end

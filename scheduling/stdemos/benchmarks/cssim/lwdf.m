function Y=lwdf(X)

%Arithmetic Units Declaration
struct('operator','+','number',2,'proctime',1,'latency',1);
struct('operator','*','number',1,'proctime',1,'latency',2);

struct('frequency',2000000);

%Variables Declaration
K = 10000;

alpha = 0.375;
%alpha = 0.7;


%I = num2cell(simout);
I = ones(1,K);

a = zeros(1,K);
b = zeros(1,K);
c = zeros(1,K);
d = zeros(1,K);
Y = zeros(1,K);


%Iterative Algorithm
for k=3:K
    a(k) = X(k) - c(k-2);
		b(k) = a(k) * alpha;
		c(k) = b(k) + X(k);
		d(k) = b(k) + c(k-2);
		Y(k) = X(k-1) + d(k);    
end


Y

			

function L=dsvf(I)

%Arithmetic Units Declaration
struct('operator','+','number',2,'proctime',1,'latency',2);
struct('operator','*','number',1,'proctime',1,'latency',2);

struct('frequency',220000);

%Variables Declaration
f = 50;
fs = 40000;
Q = 2;
K = 1000;

F1 = 0.0079;   %2*pi*f/fs  ||| ??? 2*sin(pi*f/fs)
Q1 = 0.5;           %1/Q;


%I = num2cell(simout);
I = ones(1,K);

L = zeros(1,K);
B = zeros(1,K);
H = zeros(1,K);
N = zeros(1,K);
FB = zeros(1,K);
QB = zeros(1,K);
IL = zeros(1,K);
FH = zeros(1,K);


%Iterative Algorithm
for k=2:K
    FB(k) = F1 * B(k-1);
    L(k)  = L(k-1) + FB(k);     %L = L + F1 * B
    QB(k) = Q1 * B(k-1);
    IL(k) = I(k) - L(k);
    H(k)  = IL(k) - QB(k);      %H = I - L -Q1*B
    FH(k) = F1 * H(k);
    B(k)  = FH(k) + B(k-1);     %B = F1 * H +B
    N(k)  = H(k) + L(k);        %N = H + L
end


L


function u = psd(e)


%Arithmetic Units Declaration
struct('operator','null','number',1,'proctime',1,'latency',1);
struct('operator','+','number',1,'proctime',1,'latency',9);
struct('operator','*','number',1,'proctime',1,'latency',2);
struct('operator','/','number',1,'proctime',1,'latency',2);
struct('operator','ifmin','number',1,'proctime',1,'latency',1);
struct('operator','ifmax','number',1,'proctime',1,'latency',1);

struct('frequency',48);

%Variables Declaration
K=10;                       
si1=0;
si2=0;
si3=0;
si4=0;
s1=0;
s2=0;
s3=0;
sd1=0;
sd2=0;
sd3=0;
KK=0.85;
ke=0;
T=0.5;
Ti=4.25;
Td=1.24;
umax=10;
umin=-10;
smin=-10;
smax=10;
c1=0.11765;     %T/Ti
c2=2.48;    %Td/T


%Iterative Algorithm
for k=2:K-1 
    ke(k)= e(k)*KK;    
    si3(k) = ifmax(si2(k-1),smax);    
    si4(k) = ifmin(si3(k),smin);    
    si1(k) = c1*ke(k);    
    si2(k) = si1(k)+si4(k); 
    sd2(k) = sd1(k-1);  
    sd1(k) = c2*ke(k);
    sd3(k) = sd1(k)-sd2(k);    
    s1(k) = ke(k)+si4(k);    
    s2(k) = s1(k)+sd3(k);    
    s3(k) = ifmax(s2(k),umax);    
    u(k) = ifmin(s3(k),umin);
end


%Subfunctions
function y=ifmin(a1,a2)
    if(a1<a2)
        y=a2;
    else
        y=a1;
    end
return

function y=ifmax(a1,a2)
    if(a1>a2)
        y=a2;
    else
        y=a1;
    end
return



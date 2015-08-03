function [sys,x0,str,ts] = visisfunctionbase2(t,x,u,flag,sampleTime,TS,period)
%Automatically generated S-Function

switch flag
    case 0
        %initialize
        [sys,x0,str,ts]=mdlInitializeSizes(t,x,u,sampleTime,period,TS);        
    case 2
        %Update discrete states
        sys=mdlUpdate(t+sampleTime,x,u,sampleTime,period,TS);
    case 3
        %Update discrete outputs
        sys=mdlOutputs(x);
	case 9
        %Terminate
        sys=mdlTerminate();
    otherwise
        error(['Unhandled flag ',num2str(flag)]);
end

%%
%Initialize
function [sys,x0,str,ts]=mdlInitializeSizes(t,x,u,sampleTime,period,TS)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 0;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [-1 0];

%%
%Update discrete states
function sys=mdlUpdate(t,x,u,sampleTime,period,TS)

sys = [];

%%
%Update discrete outputs
function sys=mdlOutputs(x)

sys = [];

%%
%Terminate
function sys=mdlTerminate()

sys = [];

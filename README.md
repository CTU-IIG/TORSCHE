#TORSCHE Scheduling Toolbox for Matlab#
is a freely available ([GNU GPL][l_gnu]) toolbox, mainly dedicated for the utilization and development of the scheduling algorithms. TORSCHE (Time Optimisation, Resources, SCHEduling) has been developed at the Czech Technical University in Prague, Faculty of Electrical Engineering, [Department of Control Engineering][l_dce]. 

![TORSCHE Example][i_example]

<b>Scheduling</b> is a very popular discipline which importance is growing even faster in recent years. However, there is no tool which can be used for a complex scheduling algorithms design and verification. Therefore, our main goal was to develop such tool as a freely available toolbox for the Matlab environment.

The current version of the toolbox covers following areas of scheduling: scheduling on monoprocessor/dedicated processors/parallel processors, cyclic scheduling and real-time scheduling. Furthermore, particular attention is dedicated to graphs and graph algorithms due to their important interconnection with scheduling theory. The toolbox offers transparent representation of scheduling/graph problems, various scheduling/graph algorithms, a useful graphical editor of graphs, an interface for Integer Linear Programming and an interface to TrueTime (MATLAB/Simulink based simulator of the temporal behaviour). The toolbox is supplemented by several examples of real applications.

The tool is written in the Matlab object oriented programming language and it is used in Matlab environment as a toolbox.

##Software Requirements##

TORSCHE Scheduling Toolbox for Matlab (0.4.0) currently supports MATLAB from version 6.5 (R13) to version 2014b. If you want to use the toolbox on different platforms than MS-Windows or Linux on PC compatible, some algorithms must be compiled by a C/C++ compiler. We recommend to use Microsoft Visual C/C++ 7.0 and higher under Windows or gcc under Linux.

##Installation##

Download the toolbox from github (clone git repository or Downnload ZIP) and copy/unpack Scheduling toolbox into the directory where Matlab toolboxes are installed (most often in <Matlab root>\toolbox on Windows systems and on Linux systems in <Matlab root>/toolbox). Run Matlab and add two new paths into directories with Scheduling toolbox and demos, e.g.:

    >> addpath(path,'c:\matlab\toolbox\scheduling')
    >> addpath(path,'c:\matlab\toolbox\scheduling\stdemos')

Several algorithms in the toolbox are implemented as Matlab MEX-files (compiled C/C++ files). Compiled MEX-files for various MS-Windows, Linux and MacOS systems are part of this distribution. If you use the toolbox on a different platform, please compile these algorithms using command *make* from \scheduling\contrib directory (in Matlab environment). Before that, please specify the compiler using command *mex -setup* from (also in Matlab environment). We suggest to use Microsoft Visual C/C++ or gcc compilers.

##Help##

To display a list of all available commands and functions please type

    >> help scheduling

To get help on any of the toolbox commands (e.g. task) type

    >> help task

To get help on overloaded commands, i.e. commands that do exist somewhere in Matlab path (e.g. plot) type

    >> help task/plot

Or alternatively type help plot and then select task/plot at the bottom line of the help text.

##Documentation##
A documentation of the TORSCHE Scheduling Toolbox in the form of the pdf file is a part of the repository ([documentation/main.pdf][l_doc]). Moreover, the online documentation is also available on [web pages][l_webpage] of the project.

[l_dce]: http://dce.fel.cvut.cz/en/
[l_doc]: documentation/main.pdf
[l_gnu]: LICENSE
[l_webpage]: https://rtime.felk.cvut.cz/scheduling-toolbox/
[i_example]: images/intro.gif

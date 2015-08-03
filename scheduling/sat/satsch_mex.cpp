/*
 *   satsch_mex.cpp
 *
 *  Mex file for SAT scheduler.
 *
 * Author: Michal Kutil <kutilm@fel.cvut.cz>
 * Originator: Michal Kutil <kutilm@fel.cvut.cz>
 * Originator: Premysl Sucha <suchap@fel.cvut.cz>
 * Project Responsible: Zdenek Hanzalek
 * Department of Control Engineering
 * FEE CTU in Prague, Czech Republic
 * Copyright (c) 2004 - 2009 
 * $Revision: 2897 $  $Date:: 2009-03-18 15:17:31 +0100 #$


 * This file is part of TORSCHE Scheduling Toolbox for Matlab.
 * TORSCHE Scheduling Toolbox for Matlab can be used, copied 
 * and modified under the next licenses
 *
 * - GPL - GNU General Public License
 *
 * - and other licenses added by project originators or responsible
 *
 * Code can be modified and re-distributed under any combination
 * of the above listed licenses. If a contributor does not agree
 * with some of the licenses, he/she can delete appropriate line.
 * If you delete all lines, you are not allowed to distribute 
 * source code and/or binaries utilizing code.
 *
 * --------------------------------------------------------------
 *                  GNU General Public License  
 *
 * TORSCHE Scheduling Toolbox for Matlab is free software;
 * you can redistribute it and/or modify it under the terms of the
 * GNU General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option)
 * any later version.
 * 
 * TORSCHE Scheduling Toolbox for Matlab is distributed in the hope
 * that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with TORSCHE Scheduling Toolbox for Matlab; if not, write
 * to the Free Software Foundation, Inc., 59 Temple Place,
 * Suite 330, Boston, MA 02111-1307 USA
 *
 */

// Header
#include "mex.h"
#include "string.h"
#include "../contrib/zchaff/SAT.h" // Zchaff solver
#include <vector>
#include <algorithm>
#include <vector>
#include "time.h"


// Macro to help debugging var: IF_DEBUG
#define IF_DEBUG_

#ifdef IF_DEBUG
#   define DBGmexPrintf  mexPrintf
#else
#   define DBGmexPrintf if (0) mexPrintf
#endif

#if _MSC_VER > 1020   // if VC++ version is > 4.2
   using namespace std;  // std c++ libs implemented in std
#endif

// Other macros
#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))
#define TOPOSITIV(a) (((a) > 0) ? (2*(a)) : (-2*(a)+1))

// Header for functions
int sat_sub2indaa (int task_i, int cas_i, int procesor, int *asap, int *alap, int procesoru);
void hook_refresh (SAT_Manager mng);

// Main MEX function
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    // Data import                                     
    // -----------
    
    // Variable for data from mex import
    const char **fnames;
    mxArray    *tmp,*tmpfromcell;
    int        ifield, jstruct, *classIDflags;
    int        NStructElems, nfields;
    
    // Check proper input and output
    if (nrhs != 1)
        mexErrMsgTxt("One input required.");
    else if (nlhs > 3)
        mexErrMsgTxt("Too many output arguments.");
    else if (!mxIsStruct(prhs[0]))
    mexErrMsgTxt("Input must be a structure.");

    // Get input arguments
    nfields = mxGetNumberOfFields(prhs[0]);
    NStructElems = mxGetNumberOfElements(prhs[0]);

    // Allocate memory  for storing classIDflags
    classIDflags = (int*)mxCalloc(nfields, sizeof(int));
 
    // Allocate memory  for storing pointers
    fnames = (const char**)mxCalloc(nfields, sizeof(*fnames));

    // Get field name pointers and data
    int pocet=0; // pocet tasku
    int pocet_hran=0;
    int *hranyod=NULL,*hranydo=NULL;
    int procesoru=0, procesor=0, procesor2=0 ; // pocet procesoru (K)
    int task_i, task_j, cas_i, cas_i2, cas_j;
    int *proctime=NULL;
    int *asap=NULL;
    int *alap=NULL;
    std::vector < std::vector <int> > clause;
    int promveformuli;
    int cnf_promenych = 0, cnf_formuli = 0;
    int **polenevrodine=NULL; //pole polí
    int pocetnevrodine;
    int ncell=0;

    for (ifield = 0; ifield < nfields; ifield++) {
        fnames[ifield] = mxGetFieldNameByNumber(prhs[0],ifield);
        DBGmexPrintf("Struct: %s -> ",fnames[ifield]);
        jstruct = 0;
        if (!strcmp(fnames[ifield],"count")) { // Number of tasks
            tmp = mxGetFieldByNumber(prhs[0],jstruct,ifield);
            pocet = (int)*(mxGetPr(tmp));
            DBGmexPrintf("%d \n",pocet);
        }else if (!strcmp(fnames[ifield],"K")) { // Processors number
            tmp = mxGetFieldByNumber(prhs[0],jstruct,ifield);
            procesoru = (int)*(mxGetPr(tmp));
            DBGmexPrintf("%d \n",procesoru);
        }else if (!strcmp(fnames[ifield],"ProcTime")) { // ProcTime
            tmp = mxGetFieldByNumber(prhs[0],jstruct,ifield);
            double *tmp_array = mxGetPr(tmp);
            proctime = new int [pocet];
            for (int i = 0; i<pocet; i++) {
                proctime[i]=(int)tmp_array[i];
                DBGmexPrintf("%d ",proctime[i]);
            }
            DBGmexPrintf("\n");
        }else if (!strcmp(fnames[ifield],"asap")) { // ASAP
            tmp = mxGetFieldByNumber(prhs[0],jstruct,ifield);
            double *tmp_array = mxGetPr(tmp);
            asap = new int [pocet];
            for (int i = 0; i<pocet; i++) {
                asap[i]=(int)tmp_array[i];
                DBGmexPrintf("%d ",asap[i]);
            }
            DBGmexPrintf("\n");
        }else if (!strcmp(fnames[ifield],"alap")) { // ALAP
            tmp = mxGetFieldByNumber(prhs[0],jstruct,ifield);
            double *tmp_array = mxGetPr(tmp);
            alap = new int [pocet];
            for (int i = 0; i<pocet; i++) {
                alap[i]=(int)tmp_array[i];
                DBGmexPrintf("%d ",alap[i]);
            }
            DBGmexPrintf("\n");
        }else if (!strcmp(fnames[ifield],"edges")) { // Edges
            tmp = mxGetFieldByNumber(prhs[0],jstruct,ifield);
            pocet_hran = mxGetM(tmp);
            DBGmexPrintf("Pocet hran: %d ",pocet_hran);
            double *edges = mxGetPr(tmp);
            hranyod = new int [pocet_hran];
            hranydo = new int [pocet_hran];
            for (int i=0;i<pocet_hran;i++) {
                hranyod[i] = (int)edges[i];
                hranydo[i] = (int)edges[i+pocet_hran];
                DBGmexPrintf("[%d x %d] ",hranyod[i], hranydo[i]);
            }
            DBGmexPrintf("\n");
        }else if (!strcmp(fnames[ifield],"nofam")) { // No in family
            tmp = mxGetFieldByNumber(prhs[0],jstruct,ifield);
            ncell = mxGetNumberOfElements(tmp);
            DBGmexPrintf("Pocet cells: %d ",ncell);
            polenevrodine = new int* [ncell];
            for (int icell=0;icell<ncell;icell++){
                tmpfromcell = mxGetCell(tmp,icell);
                int pocetnevrodine = mxGetN(tmpfromcell);
                polenevrodine[icell] = new int [pocetnevrodine+1];
                polenevrodine[icell][0] = pocetnevrodine;
                DBGmexPrintf(",%d {",polenevrodine[icell][0]);
                for (int i = 0; i < polenevrodine[icell][0]; i++) {
                    polenevrodine[icell][i+1] = (int)*(mxGetPr(tmpfromcell)+i);
                    DBGmexPrintf("%d ",polenevrodine[icell][i+1]);
                }
                DBGmexPrintf("}");
            }
            DBGmexPrintf("\n");
        }
    }
    // clean
    mxFree(classIDflags);
    mxFree(fnames);
    
    mexPrintf("Imported %d tasks and %d edges.\n",pocet,pocet_hran);
    DBGmexPrintf("\n");  
    
    // CNF creating
    // ------------
    
    mexPrintf("CNF creating: ");
    // Time measuring
    time_t t1, t2;
    t1 = time(NULL);

    // 1. condition
    {
        mexPrintf("1/4 ");
        for (task_i=1;task_i<=pocet;task_i++) {
            promveformuli = 0;
            clause.push_back(std::vector<int>());
            for(procesor = 1; procesor <= procesoru ; procesor++){
                for (cas_i=asap[task_i-1]; cas_i<=alap[task_i-1]; cas_i++){
                    clause[cnf_formuli].push_back(sat_sub2indaa (task_i, cas_i, procesor, asap, alap, procesoru));
                    promveformuli++;
                }
            }
            cnf_formuli++;
            /*
            mexPrintf("%d |",(clause[cnf_formuli-1]).size());
            for (int i = 0; i< (clause[cnf_formuli-1]).size(); i++) {
                mexPrintf("%d ",clause[cnf_formuli-1][i]);
            }
            mexPrintf("\n");
             */
        }
    }
    // 2. condition
    {
        int startmove;
        mexPrintf("2/4 ");
        for (task_i=1;task_i<=pocet;task_i++) {
            for(procesor = 1; procesor <= procesoru ; procesor++){
                for(procesor2 = 1; procesor2 <= procesoru ; procesor2++){
                    if (procesor > procesor2) startmove = 0; else startmove = 1;
                    for (cas_i=asap[task_i-1]; cas_i<=alap[task_i-1]; cas_i++)
                        for (cas_i2=cas_i+startmove; cas_i2<=alap[task_i-1]; cas_i2++) {
                            clause.push_back(std::vector<int>());
                            clause[cnf_formuli].push_back(-1*sat_sub2indaa (task_i, cas_i, procesor, asap, alap, procesoru));
                            clause[cnf_formuli].push_back(-1*sat_sub2indaa (task_i, cas_i2, procesor2, asap, alap, procesoru));
                            cnf_formuli++;
                            /*
                            mexPrintf("%d |",(clause[cnf_formuli-1]).size());
                            for (int i = 0; i< (clause[cnf_formuli-1]).size(); i++) {
                                mexPrintf("%d ",clause[cnf_formuli-1][i]);
                            }
                            mexPrintf("grp:%d\n", satgrp[0]);
                             */
                        }
                }
            }
        }
    }
    // 3. condition
    {
        mexPrintf("3/4 ");
        for (int edge = 1;edge<=pocet_hran;edge++) {
            for(procesor = 1; procesor <= procesoru ; procesor++){
                for(procesor2 = 1; procesor2 <= procesoru ; procesor2++){
                    for (cas_i=asap[hranyod[edge-1]-1]; cas_i<=alap[hranyod[edge-1]-1]; cas_i++)
                        for (cas_j=asap[hranydo[edge-1]-1]; cas_j<(cas_i + proctime[hranyod[edge-1]-1]); cas_j++) {
                            clause.push_back(std::vector<int>());
                            clause[cnf_formuli].push_back(-1*sat_sub2indaa (hranyod[edge-1], cas_i, procesor, asap, alap, procesoru));
                            clause[cnf_formuli].push_back(-1*sat_sub2indaa (hranydo[edge-1], cas_j, procesor2, asap, alap, procesoru));
                            cnf_formuli++;
                            /*
                            mexPrintf("%d |",(clause[cnf_formuli-1]).size());
                            for (int i = 0; i< (clause[cnf_formuli-1]).size(); i++) {
                                mexPrintf("%d ",clause[cnf_formuli-1][i]);
                            }
                            mexPrintf("grp:%d\n", satgrp[0]);
                             */
                        }
                }
            }
        }
    }
    // 4. condition
    {
        mexPrintf("4/4\n");
        for(procesor = 1; procesor <= procesoru ; procesor++){
            for (task_i=1;task_i<=pocet;task_i++) {
                pocetnevrodine = polenevrodine[task_i-1][0];
                for (int i = 1; i<=pocetnevrodine; i++){
                    task_j = polenevrodine[task_i-1][i];
                    for (cas_i = asap[task_i-1]; cas_i<=alap[task_i-1]; cas_i++) {
                        for (cas_j = max(cas_i, asap[task_j-1]); cas_j<=min((cas_i+proctime[task_i-1]-1), alap[task_j-1]);cas_j++) {
                            clause.push_back(std::vector<int>());
                            clause[cnf_formuli].push_back(-1*sat_sub2indaa (task_i, cas_i, procesor, asap, alap, procesoru));
                            clause[cnf_formuli].push_back(-1*sat_sub2indaa (task_j, cas_j, procesor, asap, alap, procesoru));
                            cnf_formuli++;
                            /*
                            mexPrintf("%d |",(clause[cnf_formuli-1]).size());
                            for (int i = 0; i< (clause[cnf_formuli-1]).size(); i++) {
                                mexPrintf("%d ",clause[cnf_formuli-1][i]);
                            }
                            mexPrintf("grp:%d\n", satgrp[0]);
                             */
                        }
                    }
                }
            }
        }
    }
    // number of variables in all clauses
    for (int i = 0; i < cnf_formuli; i++) cnf_promenych = max(cnf_promenych, *max_element(clause[i].begin(),clause[i].end()));

    //time
    t2 = time(NULL);

    mexPrintf("Generaded %d clauses with %d variables, during %f sec.\n",cnf_formuli,cnf_promenych,difftime(t1,t2));
   

    // clean
    delete proctime;
    delete asap;
    delete alap;
    delete hranyod;
    delete hranydo;
    for (int icell=0;icell<ncell;icell++){
        delete polenevrodine[icell];
    }
    delete polenevrodine;
    
    // SOLVER
    // ------

    // Zchaff
    SAT_Manager zchaffmng;
    zchaffmng = SAT_InitManager();
    SAT_SetNumVariables(zchaffmng,cnf_promenych);
    SAT_AddHookFun(zchaffmng,&hook_refresh,1000); // for refreshing to desktop
    // add clause
    for (int i = 0; i < cnf_formuli; i++) {
        int *formule_tmp = & clause[i][0];
        for (unsigned int j = 0; j < clause[i].size(); j++) {
            formule_tmp[j] = TOPOSITIV(formule_tmp[j]);
        }
        SAT_AddClause(zchaffmng, formule_tmp, clause[i].size());
    }
    
    mexPrintf("Solver running: ");
    int result = SAT_Solve(zchaffmng);
    
    // Out variables
    // satisfability
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    double *sat_out = mxGetPr(plhs[0]);
    // solution
    plhs[1] = mxCreateDoubleMatrix(1, cnf_promenych, mxREAL);
    double *solution_out = mxGetPr(plhs[1]);
    switch (result) {
        case SATISFIABLE:
            mexPrintf("Satisfable\n");
            *sat_out = 1;
            for (int i=1; i<=cnf_promenych; i++) solution_out[i-1] = SAT_GetVarAsgnment(zchaffmng, i);
            break;
        case UNSATISFIABLE:
            mexPrintf("UnSatisfable.\n");
            *sat_out = 0;
            break;
        case TIME_OUT:
            mexPrintf("TimeOut.\n");
            *sat_out=2;
            break;
        case MEM_OUT:
            mexPrintf("MemOut.\n");
            *sat_out=3;
            break;
            default:
                mexPrintf("Unknown exit.\n");
                break;
    }
    // other information - in matlab struct
    const char **paramsname;
    mxArray *soltime,*solmemory;
    paramsname=(const char **)mxCalloc(2,sizeof(*paramsname));
    paramsname[0]="time";
    paramsname[1]="memory";
    plhs[2]= mxCreateStructMatrix(1, 1, 2, paramsname);
    soltime = mxCreateDoubleMatrix(1, 1, mxREAL);
    solmemory = mxCreateDoubleMatrix(1, 1, mxREAL);
    
    *(mxGetPr(soltime))=SAT_GetElapsedCPUTime(zchaffmng);
    *(mxGetPr(solmemory)) = SAT_EstimateMemUsage(zchaffmng);
    
    mxSetField(plhs[2],0,paramsname[0],soltime);
    mxSetField(plhs[2],0,paramsname[1],solmemory);

    // clean    
    mxFree(paramsname);
    
/*    for (int i = 0; i < cnf_formuli; i++) {
        clause[i].erase(clause[i].begin(), clause[i].end());
    }
    clause.erase(clause.begin(), clause.end());*/
    for (int i = 0; i < cnf_formuli; i++) {
        clause[i].clear();
    }
    clause.clear();
    
    return;
}


// SUB functions
// -------------

// Index computing - for help search equivalent Matlab function
int sat_sub2indaa (int task_i, int cas_i, int procesor, int *asap, int *alap, int procesoru)
{
	int Jsum = 0;
	for (int i=1; i<task_i; i++) {
        Jsum += alap[i-1] - asap[i-1];
	}
	return procesoru*Jsum + (procesor-1)*(alap[task_i-1] - asap[task_i-1]) + cas_i - asap[task_i-1] + procesoru*(task_i-1) + procesor;
}

// Hook function for refresh
void hook_refresh (SAT_Manager mng)
{
    mexCallMATLAB(0,NULL,0,NULL,"pwd"); // for drawnow
    mexCallMATLAB(0,NULL,0,NULL,"drawnow");
}

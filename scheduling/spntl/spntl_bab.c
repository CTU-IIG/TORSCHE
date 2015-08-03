/*
 *SPNTL_BAB Compute schedule with Positive and Negative Time-Lags by Branch and Bound
 *
 *    startTime = SPNTL(p,m,W,CMAXINF,verbose) add schedule to set of tasks 
 *      p  - vector of processing time
 *      m  - vector of numbers of dedicated processors (starts from 0)
 *      W  - matrix of positive and negative time lags
 *      CMAXINF - an upperbound of Cmax
 *      verbose - verbose mode (0=silent,1=normal,2=verbose)
 *
 *    see also BAB.C, CANDIDATES.C

 * Author: Premysl Sucha <suchap@fel.cvut.cz>
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
 

#include "mex.h"
#include "spntl_bab.h"

int n,m;                /*number of tasks and processors*/
int p[N_MAX],machine[N_MAX];                /*vectors of processing time and number of corresponding dedicated processor*/
int W[N_MAX][N_MAX],Wpos[N_MAX][N_MAX];     /*Matrix of positive and negative time lags. Wpos represents "limited graph".*/
int F[N_MAX][N_MAX],WCmax[N_MAX][N_MAX];    /*Matrix of longest paths in the input graph.*/
int Schedule[N_MAX];                        /*Resulting schedule - vector of processing times*/
int ScheduleOrder[N_MAX];                   /*Order in schedule*/
int Cmax;                                   /*Value of objective function*/
int nodeCounter;        /*Counter of inspected nodes*/
int Tc[N_MAX];          /*Set of candidate tasks*/
int methodOption;       /*Options of bounding methods*/
int verboseMode;        /*Debug info mode*/
int CMAXINF;            /*Upper bound of Cmax*/


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  double *argp, *argm, *argW, *outS, *outTime;
  int mrows, ncols;
  char errMsg[100];
  int i,j,k;	                /*General index variable*/
  int partialCmax[M_MAX];	    /*Cmax on dedicated processors*/
  clock_t start, finish;        /*Measure of time*/
  double  duration;


  /******************************************************************************/	
  /* Check for proper number of arguments. */
  if (nrhs != 5) {
    mexErrMsgTxt("Three input parameters required.");
  } else if (nlhs > 2) {
    mexErrMsgTxt("Too many output arguments.");
  }
  
  /* Test input parameters. */
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);
  if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || !(mrows == 1)) {
    mexErrMsgTxt("Parameter 'p' must be a row vector.");
  }
  n=ncols;
  
  mrows = mxGetM(prhs[1]);
  ncols = mxGetN(prhs[1]);
  if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || !(ncols == n) || !(mrows == 1)) {
    sprintf(errMsg,"Parameter 'm' must be a row vector of %d elements.",n);
    mexErrMsgTxt(errMsg);
  }
  
  mrows = mxGetM(prhs[2]);
  ncols = mxGetN(prhs[2]);
  if (!mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || !(ncols == n) || !(mrows == n)) {
    sprintf(errMsg,"Parameter 'W' must be an %d-by-%d matrix.",n,n);
    mexErrMsgTxt(errMsg);
  }


  mrows = mxGetM(prhs[3]);
  ncols = mxGetN(prhs[3]);
  if (!mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || !(ncols == 1) || !(mrows == 1)) {
    sprintf(errMsg,"Parameter 'CmaxUpper' must be a noncomplex scalar double.");
    mexErrMsgTxt(errMsg);
  }
  
  mrows = mxGetM(prhs[4]);
  ncols = mxGetN(prhs[4]);
  if (!mxIsDouble(prhs[4]) || mxIsComplex(prhs[4]) || !(ncols == 1) || !(mrows == 1)) {
    sprintf(errMsg,"Parameter 'verbose' must be 0, 1 or 2.");
    mexErrMsgTxt(errMsg);
  }

  
  /* Create matrix for the return argument. */
  plhs[0] = mxCreateDoubleMatrix(1,n, mxREAL);
  plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL);
  
  /* Assign pointers to each input and output. */
  argp = mxGetPr(prhs[0]);
  argm = mxGetPr(prhs[1]);
  argW = mxGetPr(prhs[2]);
  if(nlhs >= 1) outS = mxGetPr(plhs[0]);
  else outS = NULL;
  if(nlhs == 2) outTime = mxGetPr(plhs[1]);
  else outTime = NULL;

  
  /* Convert input arguments to int */
  CMAXINF=(int)*mxGetPr(prhs[3]);
  if(CMAXINF<=0)
  {
    sprintf(errMsg,"Parameter 'CMAXINF' must be greater than zero.");
    mexErrMsgTxt(errMsg);
  }
  
  verboseMode=(int)*mxGetPr(prhs[4]);
  if(verboseMode<0 || verboseMode>2)
  {
    sprintf(errMsg,"Parameter 'verbose' must be 0, 1 or 2.");
    mexErrMsgTxt(errMsg);
  }
  methodOption=0x000f;      /*Enable all bounding methods.*/
  
  m=0;
  for(i=0;i<n;i++)
  {
	p[i]=(int)argp[i];
	machine[i]=(int)argm[i]-1;
	m=max(m,machine[i]);
    for(j=0;j<n;j++)
    {
    	W[i][j]=(int)argW[j*n+i];
    }
  }
  m++;
 
  
  /******************************************************************************/	
  /* Cmax optimalization by problem transformation to G' */

	Cmax=CMAXINF+1;

	if(methodOption&OPTIONS_CMAX)
	{
	    Cmax=Cmax+2;
		/*Ini WCmax and insert W*/
		for(i=0;i<n+2;i++)
		{
			for(j=0;j<n+2;j++)
			{
				if(i>0 && i<=n && j>0 && j<=n) WCmax[i][j]=W[i-1][j-1];
				else WCmax[i][j]=0;
			}
		}

		/*Calculate vectors u and v*/
		for(i=0;i<n;i++)
		{
			WCmax[0][i+1]=1;
			WCmax[i+1][n+1]=p[i];
			for(j=0;j<n;j++)
			{
				if(W[j][i]>0) WCmax[0][i+1]=0;
				if(W[i][j]>0) WCmax[i+1][n+1]=0;
			}
		}

		WCmax[n+1][0]=-Cmax+1;
	
		/*Correct vector of processing time*/
		for(i=n;i>0;i--)
		{
			p[i]=p[i-1];
			machine[i]=machine[i-1];
		}
		p[0]=1; p[n+1]=1;
		machine[0]=0; machine[n+1]=0;

		/*Copy WCmax to W*/
		n=n+2;
		for(i=0;i<n;i++) 
			for(j=0;j<n;j++) W[i][j]=WCmax[i][j];

	}


  /******************************************************************************/	
    /* Initialization of B&B subroutine. */
	start = clock();
	nodeCounter=0;

	for(i=0;i<n;i++)
	{
		Schedule[i]=-1;
		ScheduleOrder[i]=-1;
		Tc[i]=0;
	}

	for(i=0;i<m;i++) partialCmax[i]=0;

	for(i=0;i<n;i++)
		for(j=1;j<n;j++)
		{
			if(W[i][j]>=0) Wpos[i][j]=W[i][j];
			else Wpos[i][j]=0;

			F[i][j]=Wpos[i][j];
		}


	/* Calculate maxrix of longest path (Wpos) - Floyd's algorithm */
	for(k=0;k<n;k++)
		for(i=0;i<n;i++)
			for(j=0;j<n;j++)
			{
				if((F[i][j]<(F[i][k]+F[k][j])) && F[i][k]!=0 && F[k][j]!=0)
					F[i][j] = F[i][k] + F[k][j];
			}

	/* Find candidate tasks. */
	candidates(Schedule,Tc);

		
    /******************************************************************************/	
    /* Call the B&B subroutine. */
    
	bab(Schedule,ScheduleOrder,Tc,partialCmax,0,-1);

    /******************************************************************************/	
    /* Store return value */	
    
	finish = clock();
	if(Cmax==CMAXINF) Cmax=-1;

	if(verboseMode>=1)
	{
		if(methodOption&OPTIONS_CMAX) mexPrintf("\nCmax=CMAX-2=%d\n",Cmax-2);
		else mexPrintf("\nCmax=%d\n",Cmax);
	}
	duration = (double)(finish - start) / (double)CLOCKS_PER_SEC;
	if(verboseMode>=1) mexPrintf( "%1.3f seconds\n", duration );

  /* Store return value to Matlab variables */	
  
  if(methodOption&OPTIONS_CMAX) n=n-2;
  for(i=0;i<n;i++)
  {
	if(methodOption&OPTIONS_CMAX) Schedule[i]=Schedule[i+1]-1;
	if(nlhs >= 1)	outS[i]=Schedule[i];
	if(nlhs == 2) outTime[0]=duration;
  }
  
  
}

/* End of file. */

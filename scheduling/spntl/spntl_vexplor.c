/*
 *BAB Branch and Bound algorithm for schedule with Positive and Negative Time-Lags
 *
 *    see also SPNTL_BAB.C, CANDIDATES.C

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


#include "spntl_bab.h"
#include <memory.h>


#define NORMAL_RETURN	0
#define ONE_LEVEL_UP	1

#define SHIFTED			0
#define NON_FEASIBLE	1


void printVector(int *vector,int n);
int loopShifting(int *partialSchedule, int *partialScheduleOrder, int *newPartialCmax, int bEfrom, int bEto, int virtualTask);


int bab(int *partialSchedule,int *partialScheduleOrder,int *partialTc,int *partialCmax,int nScheduled, int lastScheduled)
{
	int newPartialSchedule[N_MAX];              /*new... - "son" of current vrtex in searching tree*/
	int newPartialScheduleOrder[N_MAX];
	int newPartialTc[N_MAX];
	int newPartialCmax[M_MAX];
	int sk;					    /*start time of Tk*/
	int estOfSj,innerSum;	    /*estimation of sj*/
	int i,j,k,l;			    /*Index*/
	int newBwe,backupOfEdge;	/*transformed edge and backup of old edge*/
	int status;					/*return status of loopShifting function*/
	int temp,copyOfI,copyOfJ;	/*temporal variables*/
	int partialScheduleCmax,oldPartialCmax;
	int branchCounter=0;


	/*Initialisation - copy "father" to "son"*/
	memcpy(newPartialSchedule,partialSchedule,sizeof(int)*n);
	memcpy(newPartialScheduleOrder,partialScheduleOrder,sizeof(int)*n);
	memcpy(newPartialTc,partialTc,sizeof(int)*n);
	memcpy(newPartialCmax,partialCmax,sizeof(int)*(m+1));



	/********************************************************************************/
	/* Test relative deadlines - BOUND */

	for(i=0;i<n;i++)
	for(j=0;j<n;j++)
	if(W[j][i]<0 && newPartialSchedule[i]!=-1)		/*Backward edge and Ti is already scheduled*/
	{
		/*******************************/
		/* Basic bounding */
		/*******************************/
		if(newPartialSchedule[j]!=-1)
		if((newPartialSchedule[j]-newPartialSchedule[i]+W[j][i])>0)
		{
			copyOfI=i; copyOfJ=j;
			if(loopShifting(newPartialSchedule,newPartialScheduleOrder,newPartialCmax,copyOfJ,copyOfI,-1)==NON_FEASIBLE)
				return(ONE_LEVEL_UP);		/*The partial solution is not feasible*/
		}

		/*******************************/
		/* Longest Path */
		/*******************************/
		if(newPartialSchedule[j]==-1 && methodOption&OPTIONS_LONGPATH) /* && 0)*/
		{
			if(F[lastScheduled][j]>0)
				estOfSj = F[lastScheduled][j] + newPartialSchedule[lastScheduled];	/*estimate sj*/
			else
				estOfSj = newPartialCmax[machine[j]];	/*estimate sj*/

			if((estOfSj-newPartialSchedule[i]+W[j][i])>0)
			{
							
				/* Calculate new backward edge */
				if(F[lastScheduled][j]>0)
					newBwe=F[lastScheduled][j]+W[j][i];
				else
				{
					if(machine[lastScheduled]==machine[j])
						newBwe=p[lastScheduled]+W[j][i];
					else
						newBwe=1;	/*A positive value*/
				}

				/*Calculate latenes for new BEW*/
				temp=partialSchedule[i] - partialSchedule[lastScheduled] + W[i][lastScheduled];

				if(newBwe<0) /* && lastScheduled!=i && temp>0)	It must be a backvard edge.*/
				{
					backupOfEdge=W[lastScheduled][i];
					W[lastScheduled][i]=newBwe;				

					/* Shifting of the schedule */
					/*temp=i;*/
					copyOfI=i; copyOfJ=j;
					status=loopShifting(newPartialSchedule,newPartialScheduleOrder,newPartialCmax,lastScheduled,copyOfI,-1);
					W[lastScheduled][i]=backupOfEdge;	/*undo changes in matrix*/

					/* Results of shifting */
					if(status==NON_FEASIBLE)
					{
						if(F[lastScheduled][j]>0)
							return(ONE_LEVEL_UP);		/*The partial solution is not feasible.*/
						else
							return(NORMAL_RETURN);		/*The partial solution is not feasible.*/
					}

				
				}
				else /* POKUS */
				if(newBwe>=0) /* && temp>0)*/
				{
					/*newPartialSchedule[i]+=(estOfSj-newPartialSchedule[i]+W[j][i]);*/
					newPartialSchedule[j]=estOfSj;

					/* Shifting of the schedule */
					copyOfI=i; copyOfJ=j;
					status=loopShifting(newPartialSchedule,newPartialScheduleOrder,newPartialCmax,lastScheduled,copyOfI,copyOfJ);
					newPartialSchedule[j]=-1;	/*undo changes vector of starting times*/

					/* Results of shifting */
					if(status==NON_FEASIBLE)
					{
						if(F[lastScheduled][j]>0)
							return(ONE_LEVEL_UP);		/*The partial solution is not feasible*/
						else
							return(NORMAL_RETURN);		/*The partial solution is not feasible*/
					}
				
				}
				

			}
		}
	

		/*******************************/
		/* Sum of processing time */
		/*******************************/
		if(newPartialSchedule[j]==-1 && machine[j]==machine[lastScheduled] && methodOption&OPTIONS_SUMOFP) /* && 0)*/
		{
			innerSum=0;
			for(l=0;l<n;l++)
			{
				if(F[l][j]>0 && newPartialSchedule[l]==-1 && machine[j]==machine[l])
					innerSum+=p[l];
			}

			estOfSj = newPartialCmax[machine[j]] + innerSum;	/*estimate sj*/

			if((estOfSj-newPartialSchedule[i]+W[j][i])>0)
			{
							
				/* Calculate new backward edge */
				/*newBwe=innerSum+p[lastScheduled]+W[j][i];*/

				if(machine[lastScheduled]==machine[j])
					newBwe=innerSum+p[lastScheduled]+W[j][i];
				else
					newBwe=1;	/*A positive value*/

				/*Calculate latenes for new BEW*/
				temp=partialSchedule[i] - partialSchedule[lastScheduled] + W[i][lastScheduled];

				if(newBwe<0) /* && lastScheduled!=i && temp>0)	It must be a backvard edge*/
				{
					backupOfEdge=W[lastScheduled][i];
					W[lastScheduled][i]=newBwe;					

					/* Shifting of the schedule */
					copyOfI=i; copyOfJ=j;
					status=loopShifting(newPartialSchedule,newPartialScheduleOrder,newPartialCmax,lastScheduled,copyOfI,-1);
					W[lastScheduled][i]=backupOfEdge;	/*undo changes in matrix*/

					/* Results of shifting */
					if(status==NON_FEASIBLE)
						return(NORMAL_RETURN);		/*The partial solution is not feasible*/
				
				}
				else /* POKUS */
				if(newBwe>=0) /* && temp>0)*/
				{
					/*newPartialSchedule[i]+=(estOfSj-newPartialSchedule[i]+W[j][i]);*/
					newPartialSchedule[j]=estOfSj;

					/* Shifting of the schedule */
					copyOfI=i; copyOfJ=j;
					status=loopShifting(newPartialSchedule,newPartialScheduleOrder,newPartialCmax,lastScheduled,copyOfI,copyOfJ);
					newPartialSchedule[j]=-1;	/*undo changes vector of starting times*/

					/* Results of shifting */
					if(status==NON_FEASIBLE)
						return(NORMAL_RETURN);		/*The partial solution is not feasible*/
				}
				

			}
		}



	}



	/********************************************************************************/

	/*Debug informations*/
	if(verboseMode==2)
	{
      mexPrintf(":");
	    printVector(newPartialSchedule,n);
	}
	nodeCounter++;


	/********************************************************************************/
	/* Test if the partial schedule is final solution */
	if(nScheduled==n)
	{
		partialScheduleCmax=0;
		for(i=0;i<m;i++)
			partialScheduleCmax=max(partialScheduleCmax,newPartialCmax[i]);

		if(partialScheduleCmax<Cmax)
		{
			/*Better solution have been found.*/
			memcpy(Schedule,newPartialSchedule,sizeof(int)*n);
			Cmax=partialScheduleCmax;
			if(methodOption&OPTIONS_CMAX) W[n-1][0]=-Cmax+2;
			if(verboseMode>=1)
			{
			    mexPrintf("(Cmax=%d):",Cmax);       /*Print debug info.*/
			    printVector(newPartialSchedule,n);
			}
		}
		return(NORMAL_RETURN);
	}


	/********************************************************************************/
	/* Scheduling of candidates - BRANCH */

	/* Branching - MONO+*/
	for(k=0;k<n;k++)
	{
		if(newPartialTc[k]==0) continue;	/*It is not a candidate task.*/

		/*Calculate sk*/
		sk=newPartialCmax[machine[k]];
		for(i=0;i<n;i++)
		{
			if(newPartialSchedule[i]!=-1 && Wpos[i][k]!=0)
					sk=max(sk,newPartialSchedule[i]+Wpos[i][k]);
		}

		newPartialSchedule[k]=sk;				/*Schedule task Tk*/
		newPartialScheduleOrder[nScheduled]=k;
		oldPartialCmax=newPartialCmax[machine[k]];
		newPartialCmax[machine[k]]=sk+p[k];

		/*Find new candidates.*/
		candidates(newPartialSchedule,newPartialTc);

		/*Branch now*/
		if(bab(newPartialSchedule,newPartialScheduleOrder,newPartialTc,newPartialCmax,1+nScheduled,k)==ONE_LEVEL_UP)
		{
			if(methodOption!=0)	return NORMAL_RETURN;
		}

		/*Go back (remove Tk from schedule)*/
		newPartialSchedule[k]=-1;				/*Unschedule Tk*/
		memcpy(newPartialTc,partialTc,sizeof(int)*n);
		newPartialCmax[machine[k]]=oldPartialCmax;		/*Mozna to neni dost bezpecne!!!*/
		branchCounter++;
	}

	return NORMAL_RETURN;

}





/************************************************************************************/
/************************************************************************************/
/* Complementray functions */
/************************************************************************************/
/************************************************************************************/


/************************************************************************************/
/* Print a vector to Matlab window */
void printVector(int *vector,int n)
{
	int i;

	for(i=0;i<n;i++)
		mexPrintf("%d,",vector[i]);
		
	mexPrintf("\n");
}


/************************************************************************************/
/* Loop shifting - Start time recalculation (anomaly) */


int loopShifting(int *partialSchedule, int *partialScheduleOrder, int *partialCmax, int bEfrom, int bEto, int virtualTask)
{
  int newPartialSchedule[N_MAX];
  int i,j,k,l,iPrev;
  int stratShifting = 0;
  int Lk;
  /*static int counter = 0;

  counter++;

  if(counter>8)
  {
	  mexPrintf("Error: max recursion was detected.\n");
	  return(NON_FEASIBLE);
  }*/

  memcpy(newPartialSchedule,partialSchedule,sizeof(int)*n);
  
  Lk = partialSchedule[bEfrom] - partialSchedule[bEto] + W[bEfrom][bEto];
  newPartialSchedule[bEto]+=Lk;
  
  /*mexPrintf(" %d -> %d, Lk=%d\n",bEfrom,bEto,Lk);
  mexPrintf("partialScheduleOrder:");
  printVector(partialScheduleOrder,n);
  mexPrintf("newPartialSchedule:");
  printVector(newPartialSchedule,n);*/

  iPrev = -1;
  
  for(k=0;k<n;k++)
  {
    i = partialScheduleOrder[k];
   	/*mexPrintf("\n i=%d (iPrev=%d): ",i,iPrev);*/
	if(i==bEto) stratShifting=1;
    if(stratShifting==0)
	{
	    iPrev = i;
		continue;
	}
    if(i==-1) break;
    
    if(iPrev != -1)
	  newPartialSchedule[i] = max(newPartialSchedule[i], newPartialSchedule[iPrev]+p[iPrev]);

    for(l=0;l<k;l++)
    {
      j = partialScheduleOrder[l];
	  /*mexPrintf(" j=%d",j);*/
      if(j==-1) break;
	  
	  if(W[j][i] != 0)
      {
        newPartialSchedule[i] = max(newPartialSchedule[i], newPartialSchedule[j]+W[j][i]);
          
        if(i != virtualTask)
          partialCmax[machine[i]] = max(partialCmax[machine[i]],newPartialSchedule[i]);
      }

      if(W[i][j]<0 && newPartialSchedule[i]+W[i][j]>newPartialSchedule[j] && i!=bEfrom && j!=bEto)
	  {
        /*mexPrintf("Recursion\n");*/
        if(NON_FEASIBLE == loopShifting(newPartialSchedule, partialScheduleOrder, partialCmax, i, j, virtualTask))
          return NON_FEASIBLE;		/*The task under the deadline was shifted to => non-feasible solution*/
		/*else*/
		/*  l=0;*/
	  }
    }  
    
    if(i==bEfrom) break;
    iPrev = i;
  }
  
  /*mexPrintf("Lk=%d\n",newPartialSchedule[bEfrom] - newPartialSchedule[bEto] + W[bEfrom][bEto]);
  mexPrintf("newPartialSchedule:");
  printVector(newPartialSchedule,n);*/

  /*counter--;
  if(counter==0) mexPrintf("\n");*/

  if(newPartialSchedule[bEfrom] - newPartialSchedule[bEto] + W[bEfrom][bEto] > 0)
    return NON_FEASIBLE;		/*The task under the deadline was shifted to => non-feasible solution*/
  else
  {
    memcpy(partialSchedule,newPartialSchedule,sizeof(int)*n);
    return SHIFTED;			/*Rescheduling was successful.*/
  }

}



/* End of file. */

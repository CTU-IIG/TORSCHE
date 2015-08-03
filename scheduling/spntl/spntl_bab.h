/*
 *SPNTL_BAB Header file for algorithm for schedule with Positive and Negative Time-Lags
 *
 *    see also SPNTL_BAB.C, BAB.C

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


#include <stdio.h>
#include <string.h>
#include <time.h>


#define N_MAX	100
#define M_MAX	10
/*#define CMAXINF	200*/


#define OPTIONS_LONGPATH	0x01
#define OPTIONS_SUMOFP		0x02
#define OPTIONS_CMAX		0x04


#define max(a, b)  (((a) > (b)) ? (a) : (b))
#define min(a, b)  (((a) < (b)) ? (a) : (b))

extern int n,m;
extern int p[N_MAX],machine[N_MAX];
extern int W[N_MAX][N_MAX];
extern int Wpos[N_MAX][N_MAX];
extern int F[N_MAX][N_MAX];
extern int Schedule[N_MAX];
extern int Cmax;
extern int nodeCounter;
extern int Tc[N_MAX];
extern int methodOption;
extern int verboseMode;

extern int CMAXINF;


void candidates(int *partialSchedule, int *partialTc);
int bab(int *partialSchedule,int *partialScheduleOrder,int *partialTc,int *partialCmax,int nScheduled, int lastScheduled);


/*End of file*/

/*===========================================================*\
|* Authors: Michael Burton, Jackson Lessnau, Jason Thompson  *|
|* Last Edited: 2/05/2019                                    *|
|* Purpose: This code is for Mini-Project 1 in ST446         *|
\*===========================================================*/
*Macro Variables for path to LDrive & SDrive, and seed for simulating data;
%let LDrive = L:\ST446\MP#1;
%let SDrive = S:\Documents\ST446\MP1;
%let Seed = 100;
%let summarystat = Mean; /*Valid Values include any statistics keyword that can be used in Summary/Means/Report procedure*/
%let GByProcessing = Distribution Reps Size;
%let GLegend = location = inside position = topleft;

/*++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Programmatically Change Working directroy *|
|* 2. Set up fileref to Params.txt              *|
|* 3. Set up libref to MP1 Folder on SDrive     *|
|* 4. Update Working Directory to use SDrive    *|
\*++++++++++++++++++++++++++++++++++++++++++++++*/
x "cd &LDrive";
filename file "params.txt";
libname MP1 "&SDrive";
x "cd &SDrive";

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Read in params.txt file                            *|
|* 2. Simulate Data for each observation in Sims dataset *|
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

data MP1.Sims;
    infile file dlm = '09'x firstobs = 2 missover;
    input Distribution $ Reps Size @;
    do until (Size eq .);
        call streaminit(&Seed);
        do sample = 1 to Reps;
            do ou = 1 to Size;
                x = rand(distribution);
                output;
            end;
        end;
        input Size @;
    end;
run;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Calculate the specified summary statistics using the notsorted option                      *|
|* 2. Calculate the min and max of the summary stat across all simulations for that distribution *|
|* 3. Save Max and Min in Macro Variable (this is in our second data step)                       *|
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

proc means data = MP1.sims &summarystat;
    by Distribution Reps Size Sample notsorted;
    /* The notsorted option defines a by group as a set of contiguous observations that have *\
    \* the same values for all BY Variables. (Proc Means By Statement SAS Help page)         */
    var x;
    output out = work.stat &summarystat = Summary_Statistic;
run;

proc means data = work.stat min max;
    by distribution notsorted;
    var summary_statistic;
    output out= work.minmax 
        min = minimum 
        max = maximum;
run;

/*Create Macro Variable*/
data _null_;
    set work.minmax;
    call symputx(cats(distribution,"min"), minimum);
    call symputx(cats(distribution,"max"), maximum);
run;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Close all output destinations                                           *|
|* 2. Specify Resolution, Width, and prefix for graphs                        *|
|* 3. Create titles utilizing the #ByValn keyword to pull the n by variable   *|
|* 4. Proc sgplot                                                             *|
|*      a. Group by variables specified in the GByProcessing macro variable   *|
|*      b. Plot Histogram of the summary statistic of interest                *|
|*      c. Overlay Normal Density plot                                        *|
|*      d. Setup Legend using options specified in the GLegend macro variable *|
\*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

ods _all_ close;
ods listing image_dpi = 300;
ods graphics on / width = 4in imagename = "histoNoMac";
options nobyline;

title "Histogram of Sampling Distribution of the &summarystat";
title2 'of the #ByVal1 Distribution using';
title3 '#ByVal2 replications of size #ByVal3';
proc sgplot data = work.stat;
    by &GByProcessing notsorted;
    histogram Summary_Statistic;
    density Summary_statistic / TYPE = Normal legendlabel = 'Empirical Normal';
    xaxis label = "Sample &summarystat";
    yaxis display = (nolabel);
    keylegend / &GLegend;
run;
title;
footnote;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* Create Six different Graphs by changing the macro variables *|
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

*1.;
%let dist = Cauchy;
%let reps = 25;
%let size = 2;

ods graphics on / width = 4in imagename = "&Dist.R&reps.N&size";
title "Histogram of Sampling Distribution of the &summarystat";
title2 "of the &dist Distribution using";
title3 "&reps replications of size &size";
footnote J = L H = 4pt "Across all simulations values ranged from &&&dist.min to &&&dist.max";
proc sgplot data = work.stat;
    by &GByProcessing;
    histogram Summary_Statistic;
    density Summary_statistic / TYPE = Normal legendlabel = 'Empirical Normal';
    where distribution = "&dist" and reps = &reps and size = &size;
    xaxis label = "Sample &summarystat"; 
    yaxis display = (nolabel);
    keylegend / &GLegend;
run;
title;  
footnote;

*2.;
%let dist = Cauchy;
%let reps = 25;
%let size = 30;
ods graphics on / width = 4in imagename = "&Dist.R&reps.N&size";
title "Histogram of Sampling Distribution of the &summarystat";
title2 "of the &dist Distribution using";
title3 "&reps replications of size &size";
footnote J = L H = 4pt "Across all simulations values ranged from &&&dist.min to &&&dist.max";
proc sgplot data = work.stat;
    by &GByProcessing;
    histogram Summary_Statistic;
    density Summary_statistic / TYPE = Normal legendlabel = 'Empirical Normal';
    where distribution = "&dist" and reps = &reps and size = &size;
    xaxis label = "Sample &summarystat"; 
    yaxis display = (nolabel);
    keylegend / &GLegend;
run;
title;  
footnote;

*3.;
%let dist = Cauchy;
%let reps = 25;
%let size = 100;
ods graphics on / width = 4in imagename = "&Dist.R&reps.N&size";
title "Histogram of Sampling Distribution of the &summarystat";
title2 "of the &dist Distribution using";
title3 "&reps replications of size &size";
footnote J = L H = 4pt "Across all simulations values ranged from &&&dist.min to &&&dist.max";
proc sgplot data = work.stat;
    by &GByProcessing;
    histogram Summary_Statistic;
    density Summary_statistic / TYPE = Normal legendlabel = 'Empirical Normal';
    where distribution = "&dist" and reps = &reps and size = &size;
    xaxis label = "Sample &summarystat"; 
    yaxis display = (nolabel);
    keylegend / &GLegend;
run;
title;  
footnote;

*4.;
%let dist = Normal;
%let reps = 25;
%let size = 2;
ods graphics on / width = 4in imagename = "&Dist.R&reps.N&size";
title "Histogram of Sampling Distribution of the &summarystat";
title2 "of the &dist Distribution using";
title3 "&reps replications of size &size";
footnote J = L H = 4pt "Across all simulations values ranged from &&&dist.min to &&&dist.max";
proc sgplot data = work.stat;
    by &GByProcessing;
    histogram Summary_Statistic;
    density Summary_statistic / TYPE = Normal legendlabel = 'Empirical Normal';
    where distribution = "&dist" and reps = &reps and size = &size;
    xaxis label = "Sample &summarystat"; 
    yaxis display = (nolabel);
    keylegend / &GLegend;
run;
title;  
footnote;

*5.;
%let dist = Normal;
%let reps = 25;
%let size = 30;
ods graphics on / width = 4in imagename = "&Dist.R&reps.N&size";
title "Histogram of Sampling Distribution of the &summarystat";
title2 "of the &dist Distribution using";
title3 "&reps replications of size &size";
footnote J = L H = 4pt "Across all simulations values ranged from &&&dist.min to &&&dist.max";
proc sgplot data = work.stat;
    by &GByProcessing;
    histogram Summary_Statistic;
    density Summary_statistic / TYPE = Normal legendlabel = 'Empirical Normal';
    where distribution = "&dist" and reps = &reps and size = &size;
    xaxis label = "Sample &summarystat"; 
    yaxis display = (nolabel);
    keylegend / &GLegend;
run;
title;  
footnote;

*6.;
%let dist = Normal;
%let reps = 25;
%let size = 100;
ods graphics on / width = 4in imagename = "&Dist.R&reps.N&size";
title "Histogram of Sampling Distribution of the &summarystat";
title2 "of the &dist Distribution using";
title3 "&reps replications of size &size";
footnote J = L H = 4pt "Across all simulations values ranged from &&&dist.min to &&&dist.max";
proc sgplot data = work.stat;
    by &GByProcessing;
    histogram Summary_Statistic;
    density Summary_statistic / TYPE = Normal legendlabel = 'Empirical Normal';
    where distribution = "&dist" and reps = &reps and size = &size;
    xaxis label = "Sample &summarystat"; 
    yaxis display = (nolabel);
    keylegend / &GLegend;
run;
title;  
footnote;

quit;

/*===========================================================*\
|* Authors: Joshua Buck, Michael Burton, Steven Chester      *|
|* Last Edited: 4/10/2019                                    *|
|* Purpose: This code is for Mini-Project 3 in ST446         *|
\*===========================================================*/

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Set path to Ldrive                                   *|
|* 2. Set path to ST446 MP#3 Folder                        *|
|* 3. Set path to your SDrive folder                       *|    
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

%let LDrive = L:\ST555;

%let ST446MP3 = L:\ST446\MP#3;

%let SDrive = S:\Documents\ST446\MP3;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Programmatically Change Working directroy                  *|
|* 2. Set up LDrive Library                                      *|
|* 3. Change directroy and set up library for class' MP#3 folder *|
|* 4. Update Working Directory to use your SDrive                *|
|* 5. Set up libref to MP3 Folder on your SDrive                 *|
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

x "cd &LDrive";

libname LDrive "";

x "cd &ST446MP3";

libname ST446MP3 "";

x "cd &SDrive";

libname MP3 "";

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. The Macro Program below produces an animation that explores what happens to the sampling distribution of a given summary statistic  as sample size increases                                                                               *|
|*                                                                                                                                                                                                                                               *|
|* 2. The Macro Parameters are as follows:                                                     >>>Allowable Values<<<                                 >>>Default Values<<<                                                                       *|
|*           dist: Name of the distribution............................................normal, cauchy                                               | null                                                                                       *|    
|*           seed: Seed for random sampling............................................any integer >= 0                                             | 0                                                                                          *|
|*         nsamps: Number of Samples...................................................any integer >= 0                                             | 10                                                                                         *| 
|*        minSamp: Minimum Sample Size.................................................positive integer < maxsamp                                   | null                                                                                       *|          
|*        maxSamp: Maximum Sample Size.................................................positive integer < minsamp                                   | null                                                                                       *|
|*       filename: Filename for animation..............................................Any valid filename                                           | null                                                                                       *|
|*      increment: Sample size increment...............................................any positive integer                                         | 1                                                                                          *|
|*           stat: Sample Statistic of interest........................................any summary statistic that means or univariate can calculate | mean                                                                                       *|                                                                                              
|*          gtype: Graph Type..........................................................EmpDist, Box                                                 | EmpDist                                                                                    *|                                                                                                                
|*       ksmooth1: Kernel Smoothing for normal dist....................................0 < value <= 100                                             | null                                                                                       *|
|*       ksmooth2: Kernel Smoothing for kernel dist....................................0 < value <= 100                                             | 10                                                                                         *|
|*        animfmt: Animation format....................................................GIF, SVG                                                     | GIF                                                                                        *|                                                           
|*         gwidth: Graphic Width.......................................................Number followed by units                                     | 8in                                                                                        *|
|*        gheight: Graphic Height......................................................Number followed by units                                     | 5.33in                                                                                     *|
|*       duration: Animation Duration..................................................Number of seconds per image                                  | 0.5                                                                                        *|
|*        looping: Do you want the animation to loop?..................................Yes, No                                                      | No                                                                                         *|                                                       
|*          inset: Inset...............................................................Yes, No                                                      | Yes                                                                                        *|                                                                 
|*      thickness: Density line thickness..............................................Any number greater than 0                                    | 1                                                                                          *|                                                                                                    
|*        dcolor1: Density line color for normal density...............................Any valid hex code                                           | 9999FF                                                                                  *|                                                                                          
|*        dcolor2: Density line color for kernel density...............................Any valid hex code                                           | CC6600                                                                                  *|
|*        dstyle1: Density line style for normal density...............................1,2,4,5,8,14,15,20,26,34,35,41,42                            | solid                                                                                      *|                                                                                                                                                         
|*        dstyle2: Density line style for kernel density...............................1,2,4,5,8,14,15,20,26,34,35,41,42                            | dashed                                                                                     *|
|*      Foot_text: Text to be displayed in the footnote................................Any string                                                   | Empirical density estimates are normal(solid, blue curve) and kernel(dashed, orange curve) *|                                                                                      
|*      Textsize1: Text size for inset title and axis labels...........................Valid size value                                             | 12pt                                                                                       *|                                                                                 
|*      Textsize2: Text size for inset and axis values.................................Valid size value                                             | 10pt                                                                                       *|
|*   antialiasmax: Maximum number of markers to be antialiased.........................Number                                                       | 5000                                                                                       *|                                                                                                            
|*         xrange: Number of standard deviations to graph..............................Any real number                                              | 3                                                                                          *|
|*                 on each side of the mean for the x-axis                                                                                                                                                                                       *|
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

%macro  CLTSIM(Dist = , 
               Seed = 0, 
               nsamps = 10, 
               MinSamp = , 
               MaxSamp = , 
               Filename = , 
               Increment = 1, 
               Stat = mean, 
               Gtype = EmpDist,
               Ksmooth1 = ,
               Ksmooth2 = 10,
               Animfmt = GIF,
               Gwidth = 8in, 
               Gheight = 5.33in, 
               Duration = 0.5, 
               Looping = No, 
               Inset = Yes, 
               Thickness = 1, 
               Dcolor1 = 9999FF, 
               Dcolor2 = CC6600,
               Dstyle1 = solid, 
               Dstyle2 = dashed,
               Foot_text = Empirical density estimates are normal (solid, blue curve) and kernel (dashed, orange curve) , 
               Textsize1 = 12pt, 
               Textsize2 = 10pt, 
               ANTIALIASMAX = 50000, 
               Xrange = 3);

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
|* 1. Check to make sure macro parameters specified by the user are in fact valid *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
data _NULL_;
  if upcase("&Dist") in ('NORMAL', 'CAUCHY') then distlogic = 1;
    else distlogic = 0;
  if upcase("&Stat") in ('NMISS' 'CSS' 'RANGE' 'CV' 'SKEWNESS' 'SKEW' 'KURTOSIS' 'KURT' 'STDDEV' 'STD' 'STDERR' 'MAX' 'SUM' 'MEAN' 
                          'SUMWGT' 'MIN' 'MODE' 'USS' 'N' 'VAR' 'MEDIAN' 'P50' 'Q3' 'P75' 'P1' 'P90' 'P5' 'P95' 'P10' 'P99' 
                          'Q1' 'P25' 'QRANGE' 'PROBT' 'T') then statlogic = 1;
    else statlogic = 0;
  if upcase("&Gtype") in ('EMPDIST', 'BOX') then gtypelogic = 1;
    else gtypelogic = 0;
  if upcase("&Animfmt") in ('GIF', 'SVG') then animfmtlogic = 1;
    else animfmtlogic = 0;
  if upcase("&Looping") in ('YES', 'Y', 'NO', 'N') then looplogic = 1;
    else looplogic = 0;
  if upcase("&Inset") in ('YES', 'Y', 'NO', 'N') then insetlogic = 1;
    else insetlogic = 0;
  if (upcase("&Dstyle1") in ('SOLID', 'DASHED')) and (upcase("&Dstyle2") in ('SOLID', 'DASHED')) then stylelogic = 1;
    else stylelogic = 0;
    call symputx('DistLogic', distlogic);
    call symputx('StatLogic', statlogic);
    call symputx('Gtypelogic', gtypelogic);
    call symputx('Animfmtlogic', animfmtlogic);
    call symputx('Looplogic', looplogic);
    call symputx('insetlogic', insetlogic);
    call symputx('stylelogic', stylelogic);
run;

%if not(&distlogic) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Distribution (Dist) must have value normal or cauchy' Dist = &Dist;
%end;

%if (&Seed < 0) or (&seed ne %sysfunc(int(&seed))) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Seed must be a positive integer' Seed = &seed;
%end;

%if (&nsamps le 0) or (&nsamps ne %sysfunc(int(&nsamps))) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Number of samples (nsamps) must be a positive integer' Nsamps = &Nsamps;
%end;
  %else %if (&nsamps gt 100) %then %do;
    %put 'QC_W' 'ARNING(CLTSIM): Number of Samples greater than 100. Program may take a while.' Nsamps = &Nsamps;
  %end;

%if (&MinSamp eq ) or (&MinSamp ne %sysfunc(int(&MinSamp))) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Minimum Sample Size (MinSamp) is a required numeric argument' MinSamp = &MinSamp;
%end;
  %else %if (&MinSamp < 0) or (&MinSamp > &MaxSamp) %then %do;
    %put 'QC_W' 'ARNING(CLTSIM): Minimum Sample size (MinSamp) must be less than Maximum Samples Size (MaxSamp)' MinSamp = &MinSamp MaxSamp = &MaxSamp;
  %end; 
    %else %if (&MinSamp > 100) %then %do;
      %put 'QC_W' 'ARNING(CLTSIM): Minimum sample size greater than 100 detected. Program may take a while.' MinSamp = &MinSamp; 
    %end;

%if (&MaxSamp eq ) or (&MaxSamp ne %sysfunc(int(&MaxSamp))) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Maximum Sample Size (MaxSamp) is a required numeric argument' MaxSamp = &MaxSamp;
%end;
  %else %if (&MaxSamp > 100) %then %do;
    %put 'QC_W' 'ARNING(CLTSIM): Maximum sample size greater than 100 detected. Program may take a while.' MaxSamp = &MaxSamp; 
  %end;

%if (&Filename eq ) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Filename required' Filename = &Filename;
%end;

%if (&increment ne %sysfunc(int(&increment))) or (&increment le 0) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Sample size increment (Increment) must be a positive integer' Increment = &Increment;
%end;

%if not(&Statlogic) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Sample Statistic (stat) must be valid summary statistics in Proc Means or Proc Univariate' Stat = &Stat;
%end;

%if not(&gtypelogic) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Graph type must be either the value EmpDist or Box' Gtype = &Gtype;
%end;
 
%if (&Ksmooth1 ne ) %then %do;
  %if (&Ksmooth1 lt 0) or (&Ksmooth1 gt 100) %then %do;
    %put 'QC_W' 'ARNING(CLTSIM): Kernel Smoothing parameter (ksmooth1) must be greater than 0 and less than or equal to 100' Ksmooth1 = &Ksmooth1;
  %end;
%end;

%if (&Ksmooth2 ne ) %then %do;
  %if (&Ksmooth2 lt 0) or (&Ksmooth2 gt 100) %then %do;
    %put 'QC_W' 'ARNING(CLTSIM): Kernel Smoothing parameter (ksmooth2) must be greater than 0 and less than or equal to 100' Ksmooth2 = &Ksmooth2;
  %end;
%end;

%if not(&animfmtlogic) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Animation Formation (animfmt) must be GIF or SVG' Animfmt = &Animfmt;
%end;

%if not(&looplogic) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Looping must be YES or NO' Looping = &Looping;
%end;

%if not(&insetlogic) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Inset must be Yes or No' Inset = &Inset;
%end;

%if (&Thickness le 0) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Density Line Thickness (Thickness) must be greater than 0' Thickness = &Thickness;
%end;

%if not(&stylelogic) %then %do;
  %put 'QC_W' 'ARNING(CLTSIM): Density Line Style 1 and 2 must have value solid or dashed' Dstyle1 = &Dstyle1 Dstyle2 = &Dstyle2;
%end;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
|* 1. Simulate the data based on the sample size parameters, and distribution parameters passed through the macro           *|
|* 2. Use proc means to create the within summary statistic of interest by sample size                                      *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

data simulated;
  call streaminit(&seed);
  do n = &MinSamp to &MaxSamp by &increment;
    do samp = 1 to &nsamps;
      do j = 1 to n;
        x = rand("&dist");
        output;
      end;
    end;
  end;
run;

proc means data = simulated &stat noprint;
  by n samp notsorted;
  /* The notsorted option defines a by group as a set of contiguous observations that have *\
  \* the same values for all BY Variables. (Proc Means By Statement SAS Help page)         */
  var x;
  output out = work.stat1 &stat = y;
run;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
|* 1. Use Proc Sql to create the mean, standard deviation, median, minimum, and maximum for our data grouped by sample size *|
|* 2. Join the the above statistics with our data from proc means which will be used to graph the sample statistics         *|
|*    distribution                                                                                                          *|
|* 3. Calculate the overall mean and standard deviation from all samples                                                    *|
|* 4. Create the Lower Bound and Higher Bound for our x-axis to be used later                                               *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
proc sql noprint;
  create table work.stat2 as
    select n, 
           min(y)  as Min format = BESTD6.2,
           mean(y) as Mean format = BESTD6.2,
           median(y) as Median format = BESTD6.2,
           max(y) as Max format = BESTD6.2, 
           std(y) as Std format = BESTD6.2
      from work.stat1
      group by n
      order by n;

  create table work.stat3 as
    select coalesce(a.n,b.n) as n label = 'Sample Size',
           a.Samp as Sample,
           a.y as y label = "Sample &stat",
           b.min as Min,
           b.mean as Mean,
           b.Median as Median,
           b.Max as Max,
           b.std as Std
      from work.stat1 as a inner join work.stat2 as b
        on a.n eq b.n
      order by a.n, Sample;

  create table work.axes as
    select mean(y) as Mean,
           std(y) as Std
      from work.stat1;

  select (mean - (&xrange * Std)) as Low,
         (mean + (&xrange * Std)) as High,
         Std
    into :Low, :High, :sd
    from work.axes;

quit;
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
|* 1. Close all output destinations                                         *|
|* 2. Reset Graphics Destination and specify necessary graphics information *|
|* 3. Set options for graphics that will be output                          *|
|* 4. Select Printer destination and specify dpi/ filename                  *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
ods _all_ close;

ods graphics / reset 
               imagefmt= &animfmt 
               width= &gwidth 
               height= &gheight 
               antialias = on 
               antialiasmax = &ANTIALIASMAX;

options nodate 
        nonumber 
        nobyline 
        animduration = &duration 
        animloop = %if (%upcase(&looping) eq YES) or (%upcase(&looping) eq Y) %then YES;/*fix*/
                     %else %if %upcase(&looping eq NO) or (%upcase(&looping) eq N) %then NO;
        noanimoverlay 
        printerpath = &animfmt 
        animation = start
        papersize = (&gwidth &gheight);  
 
ods printer dpi = 300 file = "&Filename..&animfmt";  

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
|* 1. Specify Title and subtitle for our animation                                        *|
|* 2. Use Proc SGPanel with by group processing to output each frame of our animation     *|
|*    > Group by sample size (this is what changes from frame to frame)                   *|
|*    > Use macro logic to determine what type of graph to output and associated styling  *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

title "Sampling Distribution of the Standard %sysfunc(Propcase(&Dist)) Distribution";
title2 "For Samples Sizes from &minSamp to &maxSamp";
proc sgpanel data = work.stat3 noautolegend;
  panelby n / rows = 1 columns = 1 uniscale = row;
  /*Emp Dist code block*/
  %if %upcase(&gtype) = EMPDIST %then %do;
    footnote justify = L height = 8pt "&Foot_text";
    histogram y; 
    density y / type = kernel %if (&ksmooth2 ne ) %then %do;
                                %if (%upcase(&Dist) eq CAUCHY) %then (c = &Ksmooth2);
                              %end;
                                %else %if (&ksmooth1 ne ) %then %do;
                                  %if (%upcase(&dist) eq NORMAL)%then (c = &Ksmooth1); 
                                %end;
                lineattrs = (color = "cx&dcolor2" 
                             thickness = &thickness
                             pattern = %if %upcase(&dstyle2) eq SOLID %then 1;
                                         %else %if %upcase(&dstyle2) eq DASHED %then 4;);
    density y / type = normal 
                lineattrs = (color = "cx&dcolor1" 
                             thickness = &thickness
                             pattern = %if %upcase(&dstyle1) eq SOLID %then 1;
                                         %else %if %upcase(&dstyle1) eq DASHED %then 4;);
    rowaxis values = (0 to 100 by 20) grid Label = "Empirical Density" LABELATTRS =(Size = &textsize1) VALUEATTRS = (Size = &textsize2);
  %end;
    /*Boxplot code block*/
    %else %if %upcase(&gtype) eq BOX %then %do;
      hbox y;
    %end;
  %if %upcase(&inset) eq YES or %upcase(&inset) eq Y %then inset Min Median Max Mean Std / position = TOPRIGHT OPAQUE
                                                                                           Title = 'Summary Stats'
                                                                                           TITLEATTRS=(Size = &textsize1)
                                                                                           TEXTATTRS=(Size = &textsize2);;
  colaxis values = (&Low to &High by &sd) Label = "Sample %sysfunc(propcase(&stat))" LABELATTRS = (Size = &textsize1) VALUEATTRS = (Size = &textsize2);
run;
title;
footnote;

options printerpath = &animfmt animation = stop;           
ods printer close;

%mend;

quit;

/*===========================================================*\
|* Authors: Michael Burton, Kevin Mathew, Michael Snow       *|
|* Last Edited: 3/01/2019                                    *|
|* Purpose: This code is for Mini-Project 2 in ST446         *|
\*===========================================================*/

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Set path to Ldrive                                   *|
|* 2. Set path to ST446 MP#2 Folder                        *|
|* 3. Set path to your SDrive folder                       *|
|* 4. Specify the name of the file that contains your data *|
|* 5. Specify the year your data is from                   *|          
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

%let LDrive = L:\ST555;

%let ST446MP2 = L:\ST446\MP#2;

%let SDrive = S:\Documents\ST446\MP2;

%let file = IPUMS 2005 Values.txt;

%let year = 2005;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Programmatically Change Working directroy                  *|
|* 2. Set up LDrive Library                                      *|
|* 3. Set up fileref to IPUMS 2005 Values.txt                    *|
|* 4. Change directroy and set up library for class' MP#2 folder *|
|* 5. Update Working Directory to use your SDrive                *|
|* 6. Set up libref to MP2 Folder on your SDrive                 *|
|* 7. Close all output destinations                              *|
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

x "cd &LDrive";

libname LDrive "";

filename amounts "&file";

x "cd &ST446MP2";

libname ST446MP2 "";

x "cd &SDrive";

libname MP2 "";

ods _all_ close;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Create a Macro Variable: Pairs to specify the pairs of data for each    *|
|*    household                                                               *|
|* 2. Read in the data set specified by the Amounts fileref specified earlier *|
|*     - Text is space delimited, but some observations are not seperated by  *|
|*       a delimiter so we also use column input                              *|
|*                                                                            *|
|*     - Create counter variable that will be used to create macro variables  *|
|*       that specify the number of pairs of data on each household           *|
|*                                                                            *|
|*     - Replace all values of $9,999,999 with a value of missing             *|
\*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

%let pairs = 3;

data MP2.Amounts;
    infile amounts dlm=' ' missover;
    input Serial @;
    input Category & $16. Value comma9. @;
    output;
    input Category & $16. @56 Value comma10. @;
    output;
    input Category 66-75 @77 Value comma9. @;
        if Value = 9999999 then Value = .;
    output;
run;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Transpose demographic dataset                           *|
|* 2. Join the Demographics dataset with our Amounts data set *|
\*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

proc transpose data = ldrive.demographics out=MP2.demoT(drop = _NAME_);
  by SERIAL;
  id source;
  var value;
run;

proc sql noprint;
  create table MP2.AllData as
    select D.*, 
           A.Category, 
           A.Value
      from MP2.demoT as D full join MP2.Amounts as A
      on D.SERIAL = A.Serial
	  order by state, metro, Ownership, SERIAL, Category
  ;
quit;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Create Macro Variable list for specifying the states to generate report for   *|
|*    - Note that the states must be delimited by a comma                           *|
|*    - If a states consist of multiple words they must be separated by underscores *|
|*        ex: Alabama, Alaska, New_York                                             *|
|* 2. Macro Variable that contains the states names for the footnote of the report  *|
|*     - We use the %sysfunc function to access datastep functions that convert     *|
|*       our states macro variable to a space delimited list with no underscores    *|
\*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

%let States = Alabama, Alaska;

%let foot_states = %sysfunc(dequote(%sysfunc(translate(%sysfunc(translate("&States", ' ',',')), ' ','_'))));

/*----------------------------------------------------------------------------------------*\
|* > Will be resolved in Proc Report where statement                                      *|
|* > Transforms macro variable list to be used in the in operator comparison              *|
|*   ~ Note we use %sysfunc to access multiple datastep functions                         *|
|*   ~ Use upcase so we don't need to worry about casing when comparing                   *|
|*   ~ Use Dequote function to unquote the list so we just have: state1,state2,...,staten *|
|*   ~ Use catq function to return a list of individual state names quoted and delimited  *|
|*     by spaces. ex: "State1" "State2" ... "Staten"                                      *|
|*   ~ Use translate function again to comma delimit the list above and transform all     *|
|*     underscores into space characters                                                  *|
|*   ~ Use In() function                                                                  *|
\*----------------------------------------------------------------------------------------*/

%let inlogic = %sysfunc(translate(%sysfunc(catq(A,%sysfunc(dequote(%sysfunc(upcase("&States")))))), ' ', '_'));

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Use ODS Statement to:                                                       *|
|*     - Specify file type, file name                                             *|
|*     - Specify output style                                                     *|                     
|* 2. Change options to not include date and change orientation to landscape      *|
|* 3. Specify Footnote and Title for report                                       *|
|* 4. Use Proc Report to create reports for specified states                      *|
\*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

ods pdf file = 'State-Level.pdf' style = Sapphire columns = 2;

options nodate orientation = landscape mprint mlogic symbolgen;

footnote J = L H=8pt "States included: &foot_states";
title 'State-Level Listing of Income and Mortgage-Related Values';
proc report data = MP2.Alldata nowd;
  column State Metro Ownership Serial Category Value;
  define State     / order 'State';
  define Metro     / order 'Metro Status';
  define Ownership / order 'Ownership Status';
  define serial    / order 'Household ID';
  define category  / display;
  define value     / display 'Amount' format = dollar10.;
  where upcase(state) in (&inlogic);
run;
title;
footnote;

ods pdf close;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Create macro variable to specify statistics we are interested in                          *|
|* 2. Use Proc SQL to create Macro Variables for Proc Template                                  *|
|* 3. Create a table work.graph which will be used in Proc SGRender to create our graph         *|
|* 4. Transpose the graph from part 2 to allow us to specify category in our template procedure *|
\*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

%let stat = Median;

proc sql noprint;
  select &stat(value), compress(Category) as category, min(value), max(value)
    into :&stat.1 - :&stat.&pairs, :category1 - :category&pairs, :min1 - :min&pairs, :max1 - :max&pairs
    from MP2.Alldata
    group by category
  ;
  create table work.graph as
    Select Serial, compress(category) as category, value
      from mp2.alldata
      order by serial
   ;
quit; 

proc transpose data = work.graph out=work.graphsTranspose(drop = _NAME_);
  by serial;
  id Category;
  var value;
run;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
|* 1. Below we use proc template to define a new graphstyle                                                                          *|
|* 2. The graph will be a 2 by 3 lattice where the graphs in the first row are histograms and the second row are horizontal boxplots *| 
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

proc template;
  define statgraph gtl.histoboxes;
    begingraph;
      entrytitle "Distributions of &category1, &category2, and &category3";
      entrytitle "Based on the &year Census";
      layout lattice / columns = 3 rows = 2
                       columnweights = (0.33 0.33 0.33)
                       rowweights = (.8 .2) 
                       columndatarange = union
                       rowdatarange = data;
        columnaxes;
          columnaxis;
          columnaxis;
          columnaxis;
        endcolumnaxes;
        rowaxes;
          rowaxis / display = (ticks tickvalues);
          rowaxis / display = none;
        endrowaxes;
        /* All the yaxis options use %sysfunc to properly case the statistics and include the value */
        layout overlay / yaxisopts=(label="%sysfunc(propcase(&stat)) value is &&&stat.1");
          histogram &category1 /;
        endlayout;
        layout overlay / yaxisopts=(label="%sysfunc(propcase(&stat)) value is &&&stat.2");
          histogram &category2;
        endlayout;
        layout overlay / yaxisopts=(label="%sysfunc(propcase(&stat)) value is &&&stat.3");
          histogram &category3;
        endlayout;
        layout overlay;
          boxplot y=&category1 / orient = horizontal;
        endlayout;
        layout overlay;
          boxplot y=&category2 / orient = horizontal;
        endlayout;
        layout overlay;
          boxplot y=&category3 / orient = horizontal;
        endlayout;
      endlayout;
    endgraph;
  end;
run;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
|* 1. Specify options for outputting our graph                                   *|
|* 2. Use the SGrender procedure for applying our template to our specified data *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ods listing style = listing image_dpi = 300;
ods graphics on / reset = index width = 6in height = 4.5in imagename = "histoboxes";
proc sgrender data = work.graphstranspose template = gtl.histoboxes;
run;

/* Make sure all output destinations are closed*/

ods _all_ close; 

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *\
|* Compares the contents of Dr. Duggins' and our Amounts data set *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

proc compare base = st446mp2.amounts
             compare = MP2.amounts
             out = MP2.DIFF1A
             outbase outcompare
             outdiff outnoequal
             method = absolute
             criterion = 1E-6
             noprint;
run;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *\
|*creates a data set of the descriptor portion of the amounts data set*|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

proc datasets library = MP2 nolist;
  contents data = amounts varnum;    
  ods output position  = MP2.amountsdesc;
quit;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *\
|* Compares the contents of Dr. Duggins' and our Amountsdesc (descriptor portion) data set *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

proc compare base = st446mp2.amountsdesc
             compare = MP2.amountsdesc
             out = MP2.DIFF2A
             outbase outcompare
             outdiff outnoequal
             method = absolute
             criterion = 1E-6
             noprint;
run;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *\
|* Compares the contents of Dr. Duggins' and our Alldata data set *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

proc compare base = st446mp2.alldata
             compare = MP2.alldata
             out = MP2.DIFF1B
             outbase outcompare
             outdiff outnoequal
             method = absolute
             criterion = 1E-6
             noprint;
run;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *\
|*creates a data set of the descriptor portion of the alldata data set*|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

proc datasets library = MP2 nolist;
  contents data = alldata varnum;    
  ods output position  = MP2.alldatadesc;
quit;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *\
|* Compares the contents of Dr. Duggins' and our Alldatadesc (descriptor portion) data set *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

proc compare base = st446mp2.alldatadesc
             compare = MP2.alldatadesc
             out = MP2.DIFF2B
             outbase outcompare
             outdiff outnoequal
             method = absolute
             criterion = 1E-6
             noprint;
run;

QUIT; /*GPP Include Quit Statement at end of program*/

/*==============================================================*\
|* Authors: Michael Burton, Cameron Evangelista, Jason Thompson *|
|* Last Edited: 4/25/2019                                       *|
|* Purpose: This code is for Mini-Project 4 in ST446            *|
|*  Furthermore, the goal of this project is to utilize the     *|
|*  HTTP Procedure to scrape data from a website of your        *|
|*  choice, in this case a website on Pokemon(fictional video   *|
|*  game creatures). After scraping the data the program will   *|
|*  wrangle it into a form suitable for an analysis.            *|
|*  In an effort to learn more about quantile regression the    *|
|*  the analysis will be a quantile regression analysis.        *|
|*                                                              *|
\*==============================================================*/

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Set path to Ldrive                                   *|
|* 2. Set path to ST446 MP#4 Folder                        *|
|* 3. Set path to your SDrive folder                       *|    
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

%let LDrive = L:\ST555;

%let ST446MP4 = L:\ST446\MP#4;

%let SDrive = S:\Documents\ST446\MP4;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Programmatically Change Working directory                  *|
|* 2. Set up LDrive Library                                      *|
|* 3. Change directory and set up library for class' MP#4 folder *|
|* 4. Update Working Directory to use your SDrive                *|
|* 5. Set up libref to MP4 Folder on your SDrive                 *|
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

x "cd &LDrive";

libname LDrive "";

x "cd &ST446MP4";

libname ST446MP4 "";

x "cd &SDrive";

libname MP4 "";

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Create a temporary file reference for output from proc http to be written    *|
|* 2. Use Proc http to grab html source code from https://www.serebii.net/pokedex/ *|
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
filename source temp;

proc http
  url = "https://www.serebii.net/pokedex/"
  out = source
  method = "get";
run;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Wrangle html code to produce data set conisting of Pokemon Name and number *|
|*    > Since we are only interested in the first generation of pokemon we will  *|
|*      only consider pokemon with a number less than or equal to 151            *|
|*    > We will create a macro variable with a prefix pokenum and suffix of the  *|
|*      pokemons number. These will be used when scraping the individual         *|
|*      pokemon's website                                                        *|
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

data work.pokedex (drop = line numname compress);
  length Numname Compress $30. Numchar $4.;
  label Numchar  = 'Number Character';
  infile source length = recLen lrecl = 32767;
  input line $varying32767. recLen;
  if find(line, '<option value="/pokedex') gt 0 then do;
    Numname = scan(strip(line),2,'<>');
    Numchar  = compress(numname,,'kd');
    compress = input(compress(numname,,'kd'),4.);
    Name = scan(numname, 2,' ');
  end;
  if compress gt 0 and compress le 151;
  call symputx(cats('pokenum',compress), numchar);
run;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. The Macro below webscrapes data on 1st generation pokemon stats across multiple webpages indexed by pokemon number.                             *|
|*    - Statistics Scraped: Hitpoints, Attack, Defense, Special, Speed                                                                                *|
|*                                                                                                                                                    *|
|* 2. The Macro Parameters are as follows:                                             >>>Default Values<<<     >>>Allowable Values<<<                *|
|*    Start: Number of first pokemon you want data on.....................................1                  | Any integer less than or equal to 151  *|
|*     Stop: Number of last pokemon you want data on......................................151                | Any integer less than or equal to 151  *|
|*    Sleep: Amount of time you want the webcrawler to wait before scraping another page..5                  | Any number                             *|
|*   Source: Tells SAS whether you want source statements written to the log..............NO                 | YES, Y, NO, N                          *|
\*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

%macro scrape(Start = 1, Stop = 151, Sleep = 5, Source = NO);

/*Check to make sure users input correct values into the macro parameters*/

%if &Start ge &Stop %then %do;
  %put QC_WARNING: Starting pokemon index must be less than ending pokemon index. Start = &start Stop = &stop;
%end;

%if (&Start ne %sysfunc(int(&Start))) OR (&Stop ne %sysfunc(int(&Stop))) %then %do;
  %put QC_WARNING: Start and Stop index for pokemon must be an integer value. Start = &Start Stop = &Stop;
%end;

%if &Source ne NO AND &Source ne N AND &Source ne YES AND &Source ne Y %then %do;
  %put QC_WARNING: Source must be one of the following values - YES, Y, NO, N. Source = &Source;
%end;

%if (%upcase(&source)  eq NO) OR (%upcase(&Source) eq N) %then options nosource nonotes;;

/*Create a empty table for each pokemon's stats to be added to */

proc sql;
  create table work.pokestats 
    (Number num Label = 'No.',
     Hp num label = 'Hitpoints',
     Atk num label = 'Attack', 
     Def num label = 'Defense', 
     Spc num label = 'Special', 
     Spd num label = 'Speed');
quit;
  
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Use a macro loop to grab the html code from each pokemon's website *|
|* 2. Wrangle data to extract the stats for each pokemon                 *|
|* 3. Insert data into the Pokestats table for later use                 *|
\*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

%do i = &start %to &stop;
  filename source temp;

  proc http 
    url = "https://serebii.net/pokedex/&&pokenum&i...shtml"
    out = source
    method = "get";
  run;
   
  data work.pokemon&i (drop = line hit att de spe sd);
    length Hp Atk Def Spc Spd Number 4. hit att de spe sd $300.;
    infile source length = recLen lrecl = 32767;
    input line $varying32767. recLen;
    
    if find(line, 'Hit Points') gt 0 then do;
      number = &i;
      hit = scan(strip(line),3,'<>');
      att = scan(strip(line),5,'<>');
	  de  = scan(strip(line),7,'<>');
	  spe = scan(strip(line),9,'<>');
	  sd  = scan(strip(line),11,'<>');
		
	  Hp  = input(scan(hit,1, ' '), 4.);
      Atk = input(scan(att,1, ' '), 4.);
	  Def = input(scan(de, 1, ' '), 4.);
	  Spc = input(scan(spe, 1,' '), 4.);
	  Spd = input(scan(sd, 1, ' '), 4.);
	  output;
	end;
  run;

  proc sql;
    insert into work.pokestats
    select Number,
           Hp,
	       Atk,
		   Def,
		   Spc,
		   Spd
      from work.pokemon&i;
  quit;

  /* Instruct sas to rest before scraping another webpage this ensures we do not overwhelm the websites server*/

  data _null_;
    call sleep(&sleep,1);
  run;
%end;

%if %upcase(&source)  eq NO  OR %upcase(&Source) eq N %then options source notes;;

%put Macro 'Scrape' has finished;

%mend;    

%scrape(start = 1, stop = 151, sleep = .1, source = NO)

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
|* Question(s) of interest:                                                    *|
|*   1. Is there a relationship between the HP and Attack stats of a pokemon?  *|
|*     > Does it change for each quantile                                      *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Perform Quantile regression for the 10th, 25th, 50th, 75th,       *| 
|*    and 90th quantile                                                 *|
|* 2. Request Parameter tests                                           *|
|* 3. Output Predicted values                                           *| 
|* 4. Output Diagnostic measures to a sas dataset                       *|
\*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

proc quantreg data = work.pokestats algorithm = simplex plots= all;
  model Hp = Atk  / Diagnostics Leverage quantile = 0.10 0.25 0.50 0.75 0.90;
  test Atk /wald lr qinteract;
  output out=outp pred=p / columnwise;
  output out=outD leverage=l MAHADIST=M Outlier=O Predicted=P Robdist=R Sresidual=S Residual=Re / columnwise;
run;

/*+++++++++++++++++++++++++++++++++++++++++++*\
|* 1. Reset ODS Graphics                     *|                            
|* 2. Recreate Histograms from proc quantreg *|
\*+++++++++++++++++++++++++++++++++++++++++++*/

ods graphics / reset;

options nobyline;

title 'Distribution of Residuals for Hp';
title2 'Quantile Level = #byval1';
proc sgplot data = work.outD;
  by Quantile;
  histogram S;
  density S / type = normal lineattrs = (pattern = 1);
  density S / type = Kernel lineattrs = (pattern = 4);
  keylegend / location = inside down = 2 position = TOPRIGHT;
  xaxis values = (-2 to 8 by 1) offsetmin = .05 offsetmax = .05 labelattrs = (size = 10pt);
run;
title;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
|* Results:                                                                                        *|
|*   From our quantile regression we found that Attack was statistically significant in predicting *|
|*   the Hitpoints for pokemon at the 10th, 25th, 50th, and 75th quantiles but not the 90th        *|
|*   percentile of pokemon.                                                                        *|
\*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

quit;

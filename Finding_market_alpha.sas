libname mylib "/home/dtiwari40/my_courses/jaellis50/Anomalies";
libname assign "/home/dtiwari40/sasuser.v94/hw_6";

proc sql;

   Create table stock60 as 
   Select * from mylib.crspm_small
   where 2014<=year(date)<=2018
   group by permno
   having count(*)>=60;
   
Quit;
   
proc sql;
create table factor as
select a.*, b.*, a.ret-b.rf as exret
from stock60 as a, mylib.factors_monthly as b
where a.date=b.dateff;
quit;

proc sort data=factor;
by permno;
run;

title "FamaFrench3 factor regression for Alpha";
proc reg data = factor plots=none noprint outest=regressed;
model exret = mktrf hml smb;
by permno;
quit;

data coefficients(rename=(Intercept=Alpha));
set regressed;
if _TYPE_="PARMS";
run;

proc sort data=mylib.MSENAMES out= MSENAMES;
by permno NAMEENDT;
run;

data most_recent_name;
set MSENAMES;
by permno NAMEENDT;
if last.permno=1;
run;

proc sql;

create table Merged as 
select a.*, b. COMNAM from coefficients a join most_recent_name b
on a.Permno=b.permno;
quit;

proc rank data=Merged out=rank DESCENDING;
   
   var Alpha;
   ranks que;
   
run;

data assign.top5(Keep= permno Alpha comnam que);
set rank;
if que<6;
format Alpha percentn10.2;
Label 
      Alpha="FF3-factor Monthly alpha"
      comnam="CompanyName"
      que="Rank for VAriable alpha"
run;

proc sort data=assign.top5;
by que ;
run;


proc sgplot data=assign.top5;
vbar que / response=Alpha;
run;

%let path=/home/&sysuserid/sasuser.v94/SAS Assignment-Manipulating the data;
libname mylib "&path";
run;


data rets;
set mylib.rets(Keep =ticker COMNAM DATE ret);
run;


data mylib.msft;
set rets;
where ticker='MSFT';
if date >= '01JUL2016'd;
run;


proc sort data=mylib.msft ;
by date ;
run;

data mylib.msft;
set mylib.msft;

retain cumret(1);
if ret ne . then cumret=cumret*(1+ret);
else cumret=cumret;

cumreturn=(cumret-1);

run;

data mylib.semifinal;
set mylib.msft;

if date = '29JUL2016'd;
format cumreturn percentn10.2;
run;

data mylib.final(Drop = RET cumret);
set mylib.semifinal;
myname="Deepak";
keep ticker COMNAM DATE cumreturn myname;
run;
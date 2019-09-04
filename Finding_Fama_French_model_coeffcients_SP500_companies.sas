%let path=/home/&sysuserid/sasuser.v94/basic_training;
libname my "&path";

Proc contents data=my.sp500_rets;
run;

data SP500;
set my.sp500_rets;

marketcap=price * shares;

exret=ret-rf;

format ret exret percentn10.2 marketcap comma18.;

run;


proc sort data=SP500;
by date;

run;


proc means data=SP500 noprint;
by date;
var ret;
output out=sp500_index mean=;
run;

data sp500_index;
set sp500_index;

retain cumret1(1);
if ret ne . then cumret1=cumret1*(1+ret);
else cumret1=cumret1;

format cumret1 dollars15.2;

label
cumret1="Cumulative Value of $1 invested in SP500 index";
;
run;



Title "Cumulative performance of SP500 Index";
proc sgplot data=sp500_index;
    series x=date y=cumret1;
    Xaxis type=time;
run;


proc sort data=SP500;
by date;
run;

proc rank data=SP500 out=SP500 ties=low groups=10;
   var marketcap;
   ranks size_decile;
   by date;
run;

proc sort data=SP500;
by size_decile;
run;

proc means data=SP500 noprint;
by size_decile;
var marketcap;
output out=marketcap_summary (drop=_type_) mean=median=min=max=/autoname autolabel;
run;

title "Summary Stats of Marketcap by Size Decile";

proc print data=marketcap_summary label;
run;

proc means data=SP500 noprint;
by size_decile;
var ret;
output out=ret_summary (drop=_type_) mean=median=min=max=/autoname autolabel;


title "Summary Stats_Return by Size Decile";

proc print data=ret_summary label;
run;




proc sort data=SP500;
by conm;
run;

proc reg data=SP500 noprint outest = regress_out edf tableout;
by conm;
model exret= mktrf hml smb;
run;

title "Summary of FF3 regression coefficients for SP500 firm";

proc means data=regress_out;
where _type_="PARMS";
var Intercept mktrf smb hml;
run;
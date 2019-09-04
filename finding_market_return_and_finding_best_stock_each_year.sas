%let path=/home/&sysuserid/sasuser.v94/basic_training;

*Use it to define our library;

libname mylib "&path";

data sp500;
set mylib.sp500_rets;
obs=_n_;
run;

proc sort data=sp500;
by  conm year;
run;


data firsts;
set sp500;
by conm;
if first.conm=1;
run; 

data test;
set sp500;
by conm;
lag_ret=lag(ret);
if first.conm then lag_ret=.;
run;

data temp;
set sp500;

by conm year;

if first.year then cumret1=1;

if ret ne . then cumret1=cumret1*(1+ret);
else cumret1=cumret1;

cumret=cumret1-1;
retain cumret1;
if last.year=1;
run;

proc sort data =temp out=tempsort;
by year;
run;

proc rank data=tempsort out=ranked DESCENDING;
   by year;
   var cumret;
   ranks Finish;
   
run;

data sp500_year_best(keep= conm cumret year);
set ranked;
if Finish=1;
format cumret percentn10.2;
run;

title "Top Performing Stock each year";
proc sgplot data=sp500_year_best;

vbar year / response=cumret datalabel=conm;
run;

data monthlyfactors;
set mylib.factors_monthly;
run;


proc sql;

create table  market_annual as
select year,


exp(sum(log(1+mktrf+rf)))-1 as annualmarketreturn format=percentn10.2

from monthlyfactors

group by year;

quit;


proc sql;

create table mylib.sp500_year_best_final as
select conm label="Company Name"  as CompanyName, a.year label="Year" as Year, a.cumret format=percentn10.2 label="AnnualStockReturn" as AnnualStockReturn, annualmarketreturn label="AnnualMarketReturn" as AnnualMarketReturn
from sp500_year_best a join market_annual b
on a.year=b.year;


quit;

Proc EXPORT data= mylib.sp500_year_best_final
     Outfile= "&path/finalexcel.xlsx"
     DBMS=xlsx Replace;
run;




/* MODEL 1: KEYWORD FREQUENCIES */

/* set up the dataset */
data junk_words;
	set sashelp.JunkMail;
	drop CapAvg CapLong CapTotal;
run;

/* basic data analysis */
proc means data=junk_words N Nmiss mean std min max;
run;

/* display number of junk and non-junk emails for the Training and Test sets */
proc freq data = junk_words;
	tables Class*Test;
run;

/* create a logistic regression model */
/* p-value < 0.05 means the word can indicate junk email */
proc logistic data=junk_words descending;
	where Test=0;	/*working with the Training set*/;
	model Class(event='1') = Make Address All _3D Our Over Remove Internet 'Order'n Mail Receive Will People Report Addresses Free Business Email You Credit Your Font _000 Money HP HPL George _650 Lab Labs Telnet _857 Data _415 _85 Technology _1999 Parts PM Direct CS Meeting Original Project RE Edu Table Conference Semicolon Paren Bracket Exclamation Dollar Pound;
	store junk_words_logistic;
run;

/* show that results make sense: Our is more common than Make in junk email */
proc sql;
	select sum(Our) as our, sum(Make) as make
	from junk_words
	where Class=1;
quit;

/* evaluate our model */
proc plm source=junk_words_logistic;
	score data=junk_words out=junk_words_scored predicted=p / ilink;
run;
data junk_words_scored;
	set junk_words_scored;
	if p > 0.5 then Predicted_Class = 1;
	else Predicted_Class = 0;
	keep Predicted_Class Class;
run;

/* create confusion matrix */
proc freq data=junk_words_scored;
    tables Class*Predicted_Class / crosslist;
run;


/* MODEL 2: CONSECUTIVE CAPITAL LETTERS */

/* set up the dataset */
data junk_capitals;
	set sashelp.JunkMail;
	drop CapLong CapTotal Make Address All _3D Our Over Remove Internet 'Order'n Mail Receive Will People Report Addresses Free Business Email You Credit Your Font _000 Money HP HPL George _650 Lab Labs Telnet _857 Data _415 _85 Technology _1999 Parts PM Direct CS Meeting Original Project RE Edu Table Conference Semicolon Paren Bracket Exclamation Dollar Pound;
run;

/* basic data analysis */
proc means data=junk_capitals N Nmiss mean std min max;
run;

/* display number of junk and non-junk emails for the Training and Test sets */
proc freq data = junk_capitals;
	tables Class*Test;
run;

/* create logistic regression model */
proc logistic data=junk_capitals descending;
	where Test=0;
	model Class(event='1') = CapAvg;
	store junk_capitals_logistic;
run;

/* evaluate our model */
proc plm source=junk_capitals_logistic;
	score data=junk_capitals out=junk_capitals_scored predicted=p / ilink;
run;
data junk_capitals_scored;
	set junk_capitals_scored;
	if p > 0.5 then Predicted_Class = 1;
	else Predicted_Class = 0;
	keep Predicted_Class Class;
run;

/* create confusion matrix */
proc freq data=junk_capitals_scored;
    tables Class*Predicted_Class / crosslist;
run;

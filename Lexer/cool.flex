/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <string.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 *  commnetCount is used in nested comments, 
 *  strLength is used to count the charaters in a string constant
 */

int commentCount=0, strLength=0;
%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>
ASSIGN          <-
LE              <=

/*
 * Start conditions here
 */

%x STRING
%x COMMENT_ONE_LINE
%x NESTED_COMMENT
%x NEGLECT_STRING

%%

 /*
  *  Whitespaces, do nothing except for \n
  */
\n { curr_lineno++;}
\t {}
\f {}
\r {}
\v {}

 /*
  *  One line Commnets: '--' is used!
  */
"--"                                       { BEGIN(COMMENT_ONE_LINE);;}
<COMMENT_ONE_LINE>.                        { }
<COMMENT_ONE_LINE>\n                       { BEGIN(INITIAL); curr_lineno++;}

 /*
  *  Nested comments: (*...*) and can be nested!
  */
"(*"                                       { commentCount=1; BEGIN(NESTED_COMMENT);}
<NESTED_COMMENT,INITIAL>"*)"               {
                                                commentCount--;
                                                if(commentCount==0)
                                                {
                                                    BEGIN(INITIAL);
                                                }
                                                else if(commentCount<0)
                                                {
                                                    cool_yylval.error_msg = "Unmatched *)";
                                                    return(ERROR);
                                                }
                                           }
<NESTED_COMMENT>"(*"                       { commentCount++;}
<NESTED_COMMENT><<EOF>>                    { cool_yylval.error_msg = "EOF in comment"; BEGIN(INITIAL); return ERROR;}
<NESTED_COMMENT>.                          { }
<NESTED_COMMENT>\n                         { curr_lineno++;}  


 /*
  *  The multiple-character operators.
  */
{DARROW}		                 { return(DARROW);}
{LE}                             { return(LE);}
{ASSIGN}                         { return(ASSIGN);}

 /*
  * Keywords: Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  * ?i: stands for insensitive
  */

(?i:class)          { return(CLASS);} 
(?i:else)           { return(ELSE);} 
(?i:fi)             { return(FI);} 
(?i:if)             { return(IF);} 
(?i:"in")           { return(IN);} 
(?i:inherits)       { return(INHERITS);} 
(?i:let)            { return(LET);} 
(?i:loop)           { return(LOOP);} 
(?i:pool)           { return(POOL);} 
(?i:then)           { return(THEN);} 
(?i:while)          { return(WHILE);} 
(?i:case)           { return(CASE);} 
(?i:esac)           { return(ESAC);} 
(?i:of)             { return(OF);} 
(?i:darrow)         { return(DARROW);} 
(?i:new)            { return(NEW);} 
(?i:isvoid)         { return(ISVOID);} 
(?i:not)            { return(NOT);} 
(?i:le)             { return(LE);} 
t+(?i:rue)          { cool_yylval.boolean=true; return(BOOL_CONST);}
f+(?i:alse)         { cool_yylval.boolean=false; return(BOOL_CONST);}

 /*
  *  Digits
  */
[0-9]+                                     { cool_yylval.symbol = inttable.add_string(yytext); return(INT_CONST);}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *  
  */

(\")                                       { BEGIN(STRING); strcpy(string_buf,""); string_buf_ptr=NULL; strLength=0; }
<STRING><<EOF>>                            { 
                                                cool_yylval.error_msg="EOF in string constant"; BEGIN(INITIAL); return(ERROR);
                                           }

 /*
  *  if string has \ at the end showing continuation from the next line
  */                        
<STRING>\\\n                               {
                                                strLength++;
                                                if(strLength>=MAX_STR_CONST)
                                                {
                                                    cool_yylval.error_msg="String constant too long"; 
                                                    BEGIN(NEGLECT_STRING);
                                                    return(ERROR);
                                                }
                                                else{
                                                curr_lineno++;
                                                strcat(string_buf, "\n");
                                                }
                                           }
 /*
  *  Second quote encountered
  */
<STRING>(\")                               {    BEGIN(INITIAL); 
                                                string_buf_ptr=string_buf;
                                                cool_yylval.symbol=stringtable.add_string(string_buf);
                                                return(STR_CONST);
                                           }
 /*
  *  String has null character
  */
<STRING>\0                                 {    
                                                cool_yylval.error_msg="String contains null charater";
                                                BEGIN(NEGLECT_STRING); 
                                                return(ERROR);
                                           }
 /*
  *  if string has user written: \n, \f, \t, \b, \", \', \\, \?
  *  add all of them as a single charater
  */
<STRING>\\[ntfb\"\'\\\?]                   {   
                                                strLength++;
                                                if(strLength>=MAX_STR_CONST)
                                                {
                                                    cool_yylval.error_msg="String constant too long"; 
                                                    BEGIN(NEGLECT_STRING);
                                                    return(ERROR);
                                                }
                                                else
                                                {
                                                    char c=yytext[1];;
                                                    switch(c)
                                                    {
                                                        case 'n': strcat(string_buf, "\n"); break;
                                                        case 't': strcat(string_buf, "\t"); break;
                                                        case 'f': strcat(string_buf, "\f"); break;
                                                        case 'b': strcat(string_buf, "\b"); break;
                                                        case '\'': strcat(string_buf, "'"); break;
                                                        case '"': strcat(string_buf, "\""); break;
                                                        case '?': strcat(string_buf, "?"); break;
                                                        case '\\': strcat(string_buf, "\\"); break;
                                                    }
                                                }
                                           }
 /*
  *  if string have \c, c can be any charater then ignore '\'
  */
<STRING>\\                                 {}
 /*
  *  String is not terminated and newline is encountered.
  */
<STRING>\n                                 {   curr_lineno++;
                                                cool_yylval.error_msg="Unmatched string constant";
                                                BEGIN(INITIAL); 
                                                return(ERROR);
                                           }
 /*
  * Valid characters of string.
  */
<STRING>.                                  { 
                                                strLength++; 
                                                if(strLength>=MAX_STR_CONST)
                                                {
                                                    cool_yylval.error_msg="String constant too long."; 
                                                    BEGIN(NEGLECT_STRING);
                                                    return(ERROR);
                                                }
                                                else {strcat(string_buf,yytext);}
                                           } 
 /*
  *  Invalid characters in string
  */                                           
<STRING><^.>                               { cool_yylval.error_msg="Invalid character"; BEGIN(NEGLECT_STRING); return(ERROR);} 
 /*
  *  If string is too long or have null charater, then neglect till " or \n
  */
<NEGLECT_STRING>\"                         { BEGIN(INITIAL);}                                
<NEGLECT_STRING>.                          { }
<NEGLECT_STRING>\n                         { curr_lineno++; BEGIN(INITIAL);}


 /*
  *  idetifiers
  */
_                                          {cool_yylval.error_msg="_"; return ERROR;}
[A-Z][a-zA-Z_0-9]*                         { cool_yylval.symbol=idtable.add_string(yytext); return(TYPEID);}
[a-zA-Z][a-zA-Z_0-9]*                      { cool_yylval.symbol=idtable.add_string(yytext); return(OBJECTID);}
 
 /*
  *  The single-character operators and invalid characters
  */
" "                                        { }
[\!\#\$\%\^\&\|\[\]\`\>\?\\]               { cool_yylval.error_msg=yytext; return(ERROR);}
[[:punct:]]                                { return(int(yytext[0]));}

[^.] { cool_yylval.error_msg="Invalid character"; return(ERROR);}
                                
%%

%code requires {
#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void *yyscan_t;
#endif
#include "conf.h"
}

%define api.prefix {confyy}

%{

#include "conf.h"
#include "conf.tab.h"
#include "conf.lex.h"

void confyyerror(YYLTYPE *yylloc, yyscan_t scanner, struct conf *conf, const char *str)
{
        fprintf(stderr,"error: %s at line %d col %d\n",str, yylloc->first_line, yylloc->first_column);
}

int confyywrap(yyscan_t scanner)
{
        return 1;
}

%}

%pure-parser
%lex-param {yyscan_t scanner}
%parse-param {yyscan_t scanner}
%parse-param {struct conf *conf}
%locations

%union {
  int i;
}

%token ENABLE DISABLE HASHIP HASHIPPORT SACKHASHMODE EQUALS SEMICOLON OPENBRACE CLOSEBRACE SYNPROXYCONF ERROR_TOK INT_LITERAL
%token SACKHASHSIZE RATEHASH SIZE TIMER_PERIOD_USEC TIMER_ADD INITIAL_TOKENS
%token CONNTABLESIZE TIMERHEAPSIZE

%type<i> sackhashval
%type<i> INT_LITERAL

%%

synproxyconf: SYNPROXYCONF EQUALS OPENBRACE conflist CLOSEBRACE SEMICOLON
;

sackhashval:
  ENABLE
{
  $$ = SACKMODE_ENABLE;
}
| DISABLE
{
  $$ = SACKMODE_DISABLE;
}
| HASHIP
{
  $$ = SACKMODE_HASHIP;
}
| HASHIPPORT
{
  $$ = SACKMODE_HASHIPPORT;
}
;

ratehashlist:
| ratehashlist ratehash_entry
;

conflist:
| conflist conflist_entry
;

conflist_entry:
SACKHASHMODE EQUALS sackhashval SEMICOLON
{
  conf->sackmode = $3;
}
| SACKHASHSIZE EQUALS INT_LITERAL SEMICOLON
{
  if ($3 <= 0)
  {
    fprintf(stderr, "invalid sackhash size: %d at line %d col %d\n",
            $3, @3.first_line, @3.first_column);
    YYABORT;
  }
  conf->sackhashsize = $3;
}
| CONNTABLESIZE EQUALS INT_LITERAL SEMICOLON
{
  if ($3 <= 0)
  {
    fprintf(stderr, "invalid conn table size: %d at line %d col %d\n",
            $3, @3.first_line, @3.first_column);
    YYABORT;
  }
  conf->conntablesize = $3;
}
| TIMERHEAPSIZE EQUALS INT_LITERAL SEMICOLON
{
  if ($3 <= 0)
  {
    fprintf(stderr, "invalid timer heap size: %d at line %d col %d\n",
            $3, @3.first_line, @3.first_column);
    YYABORT;
  }
  conf->timerheapsize = $3;
}
| RATEHASH EQUALS OPENBRACE ratehashlist CLOSEBRACE SEMICOLON
;

ratehash_entry:
SIZE EQUALS INT_LITERAL SEMICOLON
{
  if ($3 <= 0)
  {
    fprintf(stderr, "invalid ratehash size: %d at line %d col %d\n",
            $3, @3.first_line, @3.first_column);
    YYABORT;
  }
  conf->ratehash.size = $3;
}
| TIMER_PERIOD_USEC EQUALS INT_LITERAL SEMICOLON
{
  if ($3 <= 0)
  {
    fprintf(stderr, "invalid ratehash timer period: %d at line %d col %d\n",
            $3, @3.first_line, @3.first_column);
    YYABORT;
  }
  conf->ratehash.timer_period_usec = $3;
}
| TIMER_ADD EQUALS INT_LITERAL SEMICOLON
{
  if ($3 <= 0)
  {
    fprintf(stderr, "invalid ratehash timer addition: %d at line %d col %d\n",
            $3, @3.first_line, @3.first_column);
    YYABORT;
  }
  conf->ratehash.timer_add = $3;
}
| INITIAL_TOKENS EQUALS INT_LITERAL SEMICOLON
{
  if ($3 <= 0)
  {
    fprintf(stderr, "invalid ratehash initial tokens: %d at line %d col %d\n",
            $3, @3.first_line, @3.first_column);
    YYABORT;
  }
  conf->ratehash.initial_tokens = $3;
}
;
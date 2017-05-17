%{
#include <string.h>
#include <ctype.h>
#include "search_substring.h"

//char *RunName = "search_regex";
//char *Version = "("__DATE__")";
//char *Description = "";

#define TIME     "time"
#define DATE     "date"
#define CHANNEL  "channel"
#define DURATION "duration"
#define ETCTIME  "etctime"

vector<entity_struct> entities_in_lex;

entity_struct one_entity_in_lex;

int cur_pos_yylex = 0;
int is_whitespace = 1;

//int new_sentence = 1; /* ���� ������ �˸��� ���� */

%}

LETTER         [A-Za-z]
POSITIVE_DIGIT [1-9]
DIGIT          [0-9]
HANGUL_DIGIT          (�ϳ�|��|��|��|��|��|��|��|�ټ�|����|�ϰ�|����|��ȩ)
HANJA_DIGIT         (��|��|��|��|��|��|��|ĥ|��|��)
HANGUL_DIGIT2         (��|����|����|����|����|��|����|����|����|����)
HAN_RADIX        (��|��|õ|��|��|��)

HANJA_THOUSAND       {HANJA_DIGIT}?(õ)?{HANJA_DIGIT}?(��)?{HANJA_DIGIT}?(��)?{HANJA_DIGIT}?
ARABIC_THOUSAND      ({POSITIVE_DIGIT}{DIGIT}{DIGIT}{DIGIT})|({POSITIVE_DIGIT}{DIGIT}{DIGIT})|({POSITIVE_DIGIT}{DIGIT})|({POSITIVE_DIGIT})
HANJA_BIGNUM         {HANJA_THOUSAND}?(��[ ]?)?{HANJA_THOUSAND}?(��[ ]?)?{HANJA_THOUSAND}?(��[ ]?)?{HANJA_THOUSAND}?
ARABIC_BIGNUM        {ARABIC_THOUSAND}?(��[ ]?)?{ARABIC_THOUSAND}?(��[ ]?)?{ARABIC_THOUSAND}?(��[ ]?)?{ARABIC_THOUSAND}?

INTEGER_NUM    [0-9]+
FLOAT_NUM      -?[0-9]*\.[0-9]+
HYPHEN         \-
UNDERSCORE     \_
DOT            \.
DOUBLE_DOT     \.\.
COMMA          \,
COLON          \:
ALPHANUMERIC   [A-Za-z0-9.,+*()/$-]
WHITE_SPACE    [ \t\r]+
LPAREN         \(
RPAREN         \)

DAY_NUMBER    {POSITIVE_DIGIT}|[1-2]{DIGIT}|30|31
MONTH_NUMBER  {POSITIVE_DIGIT}|(10|11|12)
YEAR_NUMBER   ({POSITIVE_DIGIT}{DIGIT})|({POSITIVE_DIGIT}{DIGIT}{DIGIT}{DIGIT})

YEAR          {YEAR_NUMBER}��
MONTH 				{MONTH_NUMBER}��
DAY   				{DAY_NUMBER}��

YEAR_MONTH_DAY      {YEAR}[ ]?{MONTH}[ ]?{DAY}
YEAR_MONTH          {YEAR}[ ]?{MONTH}
MONTH_DAY           {MONTH}[ ]?{DAY}

TIME_NUMBER   ({DIGIT}|(0|1){DIGIT}|(20|21|22|23|24))|(��|��|��|��|�ټ�|����|�ϰ�|����|��ȩ|��|����|����)
MIN_NUMBER    ({POSITIVE_DIGIT}|[1-5]{DIGIT})|(({HANJA_DIGIT}��)?{HANJA_DIGIT}|({HANJA_DIGIT}��))

TIME          ({TIME_NUMBER}��)|((����|����)[ ]?{TIME_NUMBER}��)
MIN           ({MIN_NUMBER}��)|(��)
SEC           {MIN_NUMBER}��

TIME_MIN_SEC      {TIME}[ ]?{MIN}[ ]?{SEC}
TIME_MIN          {TIME}[ ]?{MIN}
MIN_SEC           {MIN}[ ]?{SEC}

TIME_BEFOREAFTER    ({TIME}|{TIME_MIN})[ ]?(����|����|����)

DURATION_TIME       (({YEAR_MONTH_DAY}|{MONTH_DAY}|{DAY})[ ])?{TIME}(����|[ ]?[\~\-])[ ]?(({YEAR_MONTH_DAY}|{MONTH_DAY}|{DAY})[ ])?{TIME}(����)?
DURATION_DAY        ({YEAR_MONTH_DAY}|{MONTH_DAY}|{DAY})(����|[ ]?[\~\-])[ ]?({YEAR_MONTH_DAY}|{MONTH_DAY}|{DAY})(����)?
DURATION_MONTH      ({YEAR_MONTH}|{MONTH})(����|[ ]?[\~\-])[ ]?({YEAR_MONTH}|{MONTH})(����)?
DURATION_YEAR       {YEAR}(����|[ ]?[\~\-])[ ]?{YEAR}(����)?

CHANNEL             {POSITIVE_DIGIT}{DIGIT}?{DIGIT}?��

%%

{HANJA_DIGIT} {
/*	if (is_whitespace) {
		fprintf(stdout, "<HANJA_DIGIT>%s</HANJA_DIGIT>\n", yytext);
		fprintf(stdout, "(������ġ, ����) = (%d, %d)\n", cur_pos_yylex, yyleng);	cur_pos_yylex += yyleng;
	}
	is_whitespace = 0;
	*/
}

{HANJA_BIGNUM}|{ARABIC_BIGNUM} {
/*	if (is_whitespace) {
		fprintf(stdout, "<NUMBER>%s</NUMBER>\n", yytext);
		fprintf(stdout, "(������ġ, ����) = (%d, %d)\n", cur_pos_yylex, yyleng);	cur_pos_yylex += yyleng;
	}
	is_whitespace = 0;
*/
}

{DURATION_TIME}|{DURATION_DAY}|{DURATION_MONTH}|{DURATION_YEAR} {
	if (is_whitespace) {
		strcpy(one_entity_in_lex.entity_name, yytext);
		strcpy(one_entity_in_lex.category, DURATION);  // �Ⱓ
		one_entity_in_lex.pos = cur_pos_yylex;
		
		entities_in_lex.push_back(one_entity_in_lex);
		cur_pos_yylex += yyleng;
	}	
	is_whitespace = 0;
}

{YEAR}|{MONTH}|{DAY}|{YEAR_MONTH_DAY}|{YEAR_MONTH}|{MONTH_DAY} {
	if (is_whitespace) {
		strcpy(one_entity_in_lex.entity_name, yytext);
		strcpy(one_entity_in_lex.category, DATE);  // ��¥
		one_entity_in_lex.pos = cur_pos_yylex;
		
		entities_in_lex.push_back(one_entity_in_lex);
		cur_pos_yylex += yyleng;
  }
  is_whitespace = 0;
}

{TIME}|{MIN}|{SEC}|{TIME_MIN_SEC}|{TIME_MIN}|{MIN_SEC} {
	if (is_whitespace) {
		strcpy(one_entity_in_lex.entity_name, yytext);
		strcpy(one_entity_in_lex.category, TIME);  // �ð�
		one_entity_in_lex.pos = cur_pos_yylex;
		
		entities_in_lex.push_back(one_entity_in_lex);
		cur_pos_yylex += yyleng;
	}
	is_whitespace = 0;
}

{TIME_BEFOREAFTER} {
	if (is_whitespace) {
		strcpy(one_entity_in_lex.entity_name, yytext);
		strcpy(one_entity_in_lex.category, ETCTIME);  // ��Ÿ�ð�
		one_entity_in_lex.pos = cur_pos_yylex;
		
		entities_in_lex.push_back(one_entity_in_lex);
		cur_pos_yylex += yyleng;
	}
	is_whitespace = 0;
}

{CHANNEL}/�� {
	if (is_whitespace) {
		strcpy(one_entity_in_lex.entity_name, yytext);
		strcpy(one_entity_in_lex.category, CHANNEL);  // ä��
		one_entity_in_lex.pos = cur_pos_yylex;
		
		entities_in_lex.push_back(one_entity_in_lex);
		cur_pos_yylex += yyleng;
  }
  is_whitespace = 0;
}

{WHITE_SPACE} {
	is_whitespace = 1;
	cur_pos_yylex += yyleng;
}

. {
  cur_pos_yylex += yyleng;
  is_whitespace = 0;
}

%%

/*****************************************************************************/
/* str�� �ӽ�ȭ�Ͽ� ������ �� */
/* �ӽ� ȭ�Ϸκ��� scan�ؼ� �۾��� �ϰ� */
/* ����� �ӽ�ȭ�Ͽ� ���� */
int mylex(char *str) {
  FILE *fp;
  
  fp = fopen("__temp_r_", "wt"); /* ȭ�� ���� */
  
  fprintf(fp, "%s", str); /* ȭ�Ͽ� ��� */
  
  fclose(fp); /* ȭ�� �ݱ� */
  
  /***************************************/
  yyin = fopen("__temp_r_", "rt");

  cur_pos_yylex = 0;
  is_whitespace = 1;
  entities_in_lex.clear(); // �ʱ�ȭ
  
  yylex();
  return 1;
}

/*****************************************************************************/
int yywrap() {
	if (yyin) fclose(yyin);
  return 1;
}

/*****************************************************************************/
#define MAIN_LEX
#ifdef MAIN_LEX
int main (int argc, char *argv[]) {
  char line[10000];

  while(fgets(line, 10000, stdin) != NULL) { /* ���� �б� */
    line[strlen(line)-1] = 0; /* ���� ���� ���� */
    
    mylex(line); /* ������ ���� �м� �� �±� ��ȯ */

  }
  remove("__temp_r_"); /* �ӽ� ȭ�� ���� */
}

#endif
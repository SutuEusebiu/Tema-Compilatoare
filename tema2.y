%{
	#include <stdio.h>
     #include <string.h>

	int yylex();
	int yyerror(const char *msg);

     int EsteCorecta = 0;
	char msg[500];

	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	     int hasValue;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	     int declaredValue(char* n);
	     void declaration(char* n); 
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }


	  int TVAR::declaredValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      if(tmp->hasValue == 1)
		return 1;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	 void TVAR::declaration(char* n)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		
		tmp->hasValue = 1;
	      }
	      tmp = tmp->next;
	    }
	  }


	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
		tmp->hasValue = 1;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;
%}


%union { char* sir; int val;}

%token TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_LEFT TOK_RIGHT TOK_DECLARE TOK_ERROR TOK_PROGRAM TOK_INTEGER TOK_READ TOK_WRITE TOK_FOR TOK_BEGIN TOK_END TOK_DIV TOK_DO TOK_TO TOK_ASSIGN


%token <val> TOK_NUMBER
%token <sir> TOK_IDVAR


%type <val> exp
%type <val> factor
%type <sir> idList
%type <val> term


%start prog

%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIVIDE

%%
prog : TOK_PROGRAM progName TOK_DECLARE decList TOK_BEGIN stmtList TOK_END TOK_ERROR {EsteCorecta = 1;};

progName: TOK_IDVAR;

decList: dec
    |
    decList ';' dec;

dec: idList ':' type;

type: TOK_INTEGER;

idList: TOK_IDVAR
    {
	if(ts != NULL)
	{
	  if(ts->exists($1) == 0)
	  {
	    ts->add($1);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	   
	  }
	}
	else
	{
	  ts = new TVAR();
	  ts->add($1);
	}
      }
    |
    idList ',' TOK_IDVAR

    {
	if(ts != NULL)
	{
	  if(ts->exists($3) == 0)
	  {
	    ts->add($3);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, $3);
	    yyerror(msg);
	   
	  }
	}
	else
	{
	  ts = new TVAR();
	  ts->add($3);
	}
      };

Rlist: TOK_IDVAR
{
	if(ts!=NULL)
		{
 			if( ts->exists($1)==0)
			{
				
	sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    
			}
			else
			{
			ts->declaration($1);
			}
			
		}
      }
    |
    idList ',' TOK_IDVAR

    {
	if(ts!=NULL)
		{
 			if( ts->exists($3)==0)
			{
				
	sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	    yyerror(msg);
	      
			}
			else
			{
			ts->declaration($3);
			}
			
		}
      };


Wlist: TOK_IDVAR
{
	if(ts!=NULL)
		{
 			if( ts->exists($1)==0)
			{
				
	sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    
			}
			else
			 if(ts->declaredValue($1)==-1)
			 {
	sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
			 }
	
		}
      }
    |
    idList ',' TOK_IDVAR

    {
	if(ts!=NULL)
		{
 			if( ts->exists($3)==0)
			{
				
	sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	    yyerror(msg);
	      
			}
			else
			 if(ts->declaredValue($1)==-1)
			 {
	sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
			 }
			
		}
      };

stmtList: stmt 
    |
    stmtList ';' stmt;

stmt: assign
    |
    read 
    |
    write 
    |
    for;

assign : TOK_IDVAR TOK_ASSIGN exp
      {
	if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
	    ts->setValue($1, $3);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  
	}
      }
    ;

exp : term
    |
    exp TOK_PLUS term { $$ = $1 + $3; }
    |
    exp TOK_MINUS term { $$ = $1 - $3; };

term: factor
    |
    term TOK_MULTIPLY factor { $$ = $1 * $3; }
    |
    term TOK_DIV factor 
	{ 
	  if($3 == 0) 
	  { 
	      sprintf(msg,"%d:%d Eroare semantica: Impartire la zero!", @1.first_line, @1.first_column);
	      yyerror(msg);
	     
	  } 
	  else { $$ = $1 / $3; } 
	}
    ;

factor:  TOK_IDVAR {
	$$=ts->getValue($1);

	if(ts != NULL)
	{
	  if(ts->exists($1) == 0)
	  {
	     sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	     yyerror(msg);
	  }
	  else
		if(ts->declaredValue($1)==-1)
		{
	sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
		}
	}
};
    |
    TOK_NUMBER
    |
    TOK_LEFT exp TOK_RIGHT {$$=$2;}
    ;

read: TOK_READ TOK_LEFT Rlist TOK_RIGHT
    ;

write: TOK_WRITE TOK_LEFT Wlist TOK_RIGHT
    ;

for: TOK_FOR indexExp TOK_DO body
    ;

indexExp: TOK_IDVAR TOK_ASSIGN exp TOK_TO exp
    ;

body: stmt
    |
    TOK_BEGIN stmtList TOK_END
    ;

%%

int main()
{
	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");		
	}
else
	

       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}

grammar CSED;


options {
  output = AST;              
  ASTLabelType = CommonTree;}

tokens {
  FUNC_DECL; 
  ARG_DECL;   
  BLOCK;
  VAR_DECL;
  CALL;
  ELIST;       
  EXPR; 
  FOR;
  WHILE;
  IF;
  CALLREF;
  ATTR;
  
}

compilationUnit
    :   (funDecl| varDecl)+
    ;

funDecl
    :   retType ID '(' argList? ')' block
        -> ^(FUNC_DECL retType ID argList? block)
    ;

retType
    : type
    | 'void'
    ;

argList
    :   type ID (',' type ID)* -> ^(ARG_DECL type ID)+
    ;

type:  'int'
    ;

block
    :   '{' stat* '}' -> ^(BLOCK stat*)
    ;


varDecl
    :   type ID ('=' expr)? ';' -> ^(VAR_DECL type ID expr?)
    ;



stat
    : ID '=' expr ';' -> ^(ATTR ID expr)
    | 'if' '(' expr ')' stat 'else' stat -> ^(IF expr stat stat)
//    | 'while' '(' expr ')' stat -> ^(WHILE expr stat)
    | 'while' '(' expr ')' block -> ^(WHILE expr block)
//    | 'for' '(' ID '=' expr '..' expr ')' stat -> ^(FOR ID expr expr stat)
    | 'for' '(' ID '=' expr '..' expr ')' block -> ^(FOR ID expr expr block)
    | '{' stat* '}' -> ^(BLOCK stat*)
    | expr ';'!
    | varDecl
    | ';'!                 
    ;






expr
    : logExpr -> ^(EXPR logExpr)
    ;

logExpr
    : relExpr (('&&' | '||')^ relExpr)*
    ;

relExpr
    : addExpr (('>' | '<' | '==' | '!=' | '>=' | '<=')^ addExpr)*
    ;

addExpr
    : multExpr (('+' | '-')^ multExpr)*
    ;

multExpr
    : primary (('*' | '/')^ primary)*
    ;


exprList
    : expr (',' expr)*
    |
    ;

name
    : ID ('.'^ ID)*
    ;

callOrRef
    : name ('(' exprList ')')? -> ^(CALLREF name exprList?)
    ;


primary
    : INT
    | 'true'
    | 'false'
    | 'null'
    | callOrRef
    | '(' expr ')'
    | CHAR
    | STRING
    ;




// --------o  especificacoes lexicas e tokens o------




ID  : ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
    ;

INT : '0'..'9'+
    ;

COMMENT
    :   '//' ~('\n'|'\r')* '\r'? '\n' {$channel=HIDDEN;}
    |   '/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
    ;

WS  :   ( ' '
        | '\t'
        | '\r'
        | '\n'
        ) {$channel=HIDDEN;}
    ;

STRING
    :  '"' ( ESC_SEQ | ~('\\'|'"') )* '"'
    ;


CHAR:  '\'' ( ESC_SEQ | ~('\''|'\\') ) '\''
    ;


fragment
HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;


fragment
ESC_SEQ
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   UNICODE_ESC
    |   OCTAL_ESC
    ;


fragment
OCTAL_ESC
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;



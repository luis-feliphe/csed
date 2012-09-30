grammar CSED;

options {
    output = AST;
}

tokens {
    PROG;
    EXPR;
    CALLREF;
    FUN;
    ATTR;
    IF;
    FOR;
    WHILE;
    BLOCK;
}
/*
@lexer::header {
package br.ufpb.iged.csed;
}

@header {
package br.ufpb.iged.csed;
}
*/

@members{SymbolTable symtab;}
compilationUnit[SymbolTable symtab]
@init{this.symtab = symtab;}
	: varDecl+
	;





//-------------------------------------------------------------------
//--- especificacoes sintaticas -------------------------------------
//-------------------------------------------------------------------

prog
    :  funDecl+  -> ^(PROG funDecl+)
    ;

funDecl
    : retType ID '(' argList ')' '{' stat* '}' -> ^(FUN ID retType argList stat*)
    ;

//@TODO ajustar na arvore
varDecl
    	:type ID ('=' expr)? ';' 
    	{
    	System.out.println("line "+$ID.getLine()+": def "+$ID.text);
	VariableSymbol vs = new VariableSymbol($ID.text, $type.tsym);
	symtab.define(vs);
	}	
	;


retType
    : type
    | 'void'
    ;

type returns [Type tsym]
@after{
    System.out.println("line "+$start.getLine() + ": ref to "+$tsym.getName());
    }
    : 'int' {$tsym = (Type) symtab.resolve("int");}
    ;

argList
    : arg (',' arg)*
    |
    ;

arg
    : type ID
    ;

stat
    : ID '=' expr ';' -> ^(ATTR ID expr)
    | 'if' '(' expr ')' stat 'else' stat -> ^(IF expr stat stat)
    | 'while' '(' expr ')' stat -> ^(WHILE expr stat)
    | 'for' '(' ID '=' expr '..' expr ')' stat -> ^(FOR ID expr expr stat)
    | '{' stat* '}' -> ^(BLOCK stat*)
    | expr ';'!
    | varDecl
    | ';'!                 // comando vazio
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

// ----------------------------------------------
// Sem sufixos para seleção usando . por enquanto
//suffixExpr
//    : primary ('.' ID)*
//    ;
// ----------------------------------------------

exprList
    : expr (',' expr)*
    |
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

name
    : ID ('.'^ ID)*
    ;

callOrRef
    : name ('(' exprList ')')? -> ^(CALLREF name exprList?)
    ;

//
//--- especificacoes lexicas para os tokens -------------------------
//

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

module Syntax

layout L = (" " | "\t" | "\r" | "\n")* ;
lexical NL = "\n" ;

keyword KW = "cond" | "do" | "data" | "elseif" | "end"
           | "for" | "from" | "then" | "function" | "else" | "if" | "in"
           | "iterator" | "sequence" | "struct" | "to" | "tuple" | "type"
           | "with" | "yielding" | "true" | "false" ;

lexical ID     = [a-z] [a-z0-9]* \ KW; 
lexical NUMBER = [0-9]+ ("." [0-9]+)? ;
lexical STRING = "\"" ![\"]*  "\""; 

start syntax Program = ModuleDecl* Block?;



syntax FunctionDef = ID "=" "function" "(" ParamList? ")" "do" NL Block "end" ID ;
syntax DataDef     = ID "=" "data" "with" IDList NL RepDef NL MethodList "end" ID ;
syntax ModuleDecl  = FunctionDef | DataDef;

syntax ParamList = ID ( "," ID )* ;
syntax IDList    = ID ( "," ID )* ;

syntax RepDef    = ID "=" "struct" "(" FieldList ")" ;
syntax FieldList = ID ( "," ID )* ;
syntax MethodList= FunctionDef ( NL FunctionDef )* ;


syntax Block = ( Statement NL )* ;

syntax Statement
  = ID ":" Type "=" Expr
  | ID ":" Type
  | ID "=" Expr
  | ID ( "," ID )+
  | IfExpr
  | CondExpr
  | ForStmt
  | Expr
  ;


syntax IfExpr  = "if" Expr "then" NL Block "else" NL Block "end" ;
syntax CondExpr= "cond" Expr "do" CondClause ( NL CondClause )* "end" ;
syntax CondClause = Expr "-\>" Expr ;

syntax ForStmt
  = "for" ID "from" Expr "to" Expr "do" NL Block "end"
  | "for" ID "in" Expr "do" NL Block "end"
  ;

syntax IteratorExpr = "iterator" "(" Expr ")" "yielding" "(" ID ")" ;


syntax Expr
  = Literal
  | ID
  | ID "(" ArgList? ")"
  | Expr "." ID //Si hay operacion de punto, debe ir entre parentesis
  | ID "$" "(" ArgList? ")"
  | "(" Expr ")"
  | ( "neg" | "-" ) Expr
  | Expr ( "+" | "-" | "*" | "/" | "%" | "**" | "\<" | "\>" | "\<=" | "\>=" | "\<\>" | "==" | "and" | "or" ) Expr
  | "(" Expr ( "," Expr )+ ")"
  | "[" ( Expr ( "," Expr )* )? "]"
  ;

syntax ArgList = Arg ( "," Arg )* ;
syntax Arg     = Expr | ID ":" Expr ;

syntax Literal = NUMBER | STRING | "true" | "false" ;

syntax Type
  = "Int"
  | "Bool"
  | "Char"
  | "String"
  | ID  
  | "Bool"
  ;

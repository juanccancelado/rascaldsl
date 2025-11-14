module AST

data Program       = program(list[ModuleDecl] ms);

data ModuleDecl    
  = moduleFunc(FunctionDef f)
  | moduleData(DataDef d);

data FunctionDef   
  = functionDef(str id, list[str] params, Block b);

data DataDef       
  = dataDef(str id, list[str] fields, list[FunctionDef] methods);

data Block         
  = block(list[Statement] ss);

data Statement     
  = assign(str id, Expr val)
  | exprStmt(Expr e)
  | ifStmt(Expr cond, Block thenB, Block elseB)
  | forRange(str id, Expr strt, Expr end, Block b)
  | forIn(str id, Expr iterable, Block b);

data Expr          
  = literal(Literal lit)
  | var(str id)
  | call(str id, list[Expr] args)
  | dollarCall(str id, list[Expr] args)
  | dot(Expr e, str field)
  | neg(Expr e)
  | binOp(Expr left, Op op, Expr right)
  | tupleExpr(list[Expr] elems)
  | listExpr(list[Expr] elems);

data Arg           
  = arg(Expr e) 
  | namedArg(str id, Expr e);

data Literal       
  = number(str n)
  | string(str s)
  | boolTrue()
  | boolFalse();

data Op            
  = add() | sub() | mul() | div() | md() | pow()
  | lt() | gt() | le() | ge() | eq() | ne()
  | and() | or();

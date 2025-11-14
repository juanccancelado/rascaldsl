module Generator

import IO;
import List;
import String;
import AST;
import Parser;
import String;


void main() {
  loc src = |project://rascaldsl/instance/spec1.rascal|;
  Program ast;

  try {
    ast = Parser::parseProgram(src);
  } 
  catch ParseError :  {
    println("Error al parsear: <pe>");
    return;
  }

  str outText = generator(ast);
  loc outLoc = |project://rascaldsl/instance/output/generator1.txt|;

  writeFile(outLoc, outText);

  try {
    
    ast = Parser::parseProgram(src);
  } catch ParseError : {
    println("No se pudo parsear el archivo " + toString(src) + ": <pe>");
    return;
  }

  str out = generator(ast);

  // imprime y escribe a archivo de salida
  println("=== Generador: salida ===");
  println(out);
 
  loc outLoc = |project://rascaldsl/instance/output/generator1.txt|;
  writeFile(outLoc, out);
  println("Generado: <outLoc>");
}


str generator(Program program) {
  // program(modules)
  program(mods) = program;
  list[str] parts = [
    "=== Resumen del programa ===",
    "Numero de declaraciones de modulo: <mods>"
  ];

  // detalles por módulo
  for (m <- mods) {
    parts += generateModuleDecl(m);
  }

  return parts;
}

str generateModuleDecl(ModuleDecl m) {
  switch (m) {
    case moduleFunc(functionDef(name, params, body)):
      return "Module: function " + name + "\n" +
             "  params: (" + strJoin(params, ", ") + ")\n" +
             "  body:\n" + indent(generateBlock(body), 4);

    case moduleData(dataDef(name, fields, methods)):
      {
        list[str] mm = [ generateFunctionDef(fd) | fd <- methods ];      
      return "Module: data " + name + "\n" +
             "  fields: (" + strJoin(fields, ", ") + ")\n" +
             "  methods:\n" + indent(strJoin(mm, "\n\n"), 4);
      }

    default:
      return "Module: (unknown)";
  }
}

str generateFunctionDef(FunctionDef f) {
  functionDef(fname, fparams, fbody) = f;
  return "function " + fname + "(" + strJoin(fparams, ", ") + ")\n" +
         indent(generateBlock(fbody), 2);
}

str generateBlock(Block b) {
  block(stmts) = b;
  if (stmts == 0) {
    return "(empty block)";
  }
  list[str] lines = [ generateStatement(s) | s <- stmts ];
  return strJoin(lines, "\n");
}

str generateStatement(Statement s) {
  switch (s) {
    case assign(name, val):
      return name + " = " + generateExpr(val) + ";";
    case exprStmt(e):
      return generateExpr(e) + ";";
    case ifStmt(cond, thenB, elseB):
      return "if " + generateExpr(cond) + " then\n" +
             indent(generateBlock(thenB), 2) + "\nelse\n" +
             indent(generateBlock(elseB), 2) + "\nend";
    case forRange(var, strt, end, body):
      return "for " + var + " from " + generateExpr(strt) + " to " + generateExpr(end) + " do\n" +
             indent(generateBlock(body), 2) + "\nend";
    case forIn(var, iterable, body):
      return "for " + var + " in " + generateExpr(iterable) + " do\n" +
             indent(generateBlock(body), 2) + "\nend";
    default:
      return "unknown statement";
  }
}


str generateExpr(Expr e) {
  switch (e) {
    case literal(Literal l):
      return generateLiteral(l);
    case var(name):
      return name;
    case call(func, args):
      return func + "(" + strJoin([ generateExpr(a) | a <- args ], ", ") + ")";
    case dollarCall(func, args):
      return func + "$(" + strJoin([ generateExpr(a) | a <- args ], ", ") + ")";
    case dot(left, field):
      return generateExpr(left) + "." + field;
    case neg(ex):
      return "-" + parenthesizeIfNeeded(ex);
    case binOp(left, op, right):
      return generateExpr(left) + " " + opToStr(op) + " " + generateExpr(right);
    case tupleExpr(elems):
      return "(" + strJoin([ generateExpr(x) | x <- elems ], ", ") + ")";
    case listExpr(elems):
      return "[" + strJoin([ generateExpr(x) | x <- elems ], ", ") + "]";
    default:
      return "unknown expr";
  }
}

str parenthesizeIfNeeded(Expr e) {
  
  switch (e) {
    case binOp(_, _, _):
      return "(" + generateExpr(e) + ")";
    default:
      return generateExpr(e);
  }
}

str generateLiteral(Literal l) {
  switch (l) {
    case number(n): return n;
    case string(s): return "\"" + replace(s, "\"", "\\\"") + "\"";
    case boolTrue(): return "true";
    case boolFalse(): return "false";
    default: return "<lit?>";
  }
}

str opToStr(Op op) {
  switch (op) {
    case add(): return "+";
    case sub(): return "-";
    case mul(): return "*";
    case div(): return "/";
    case md(): return "%";
    case pow(): return "**";
    case lt(): return "\<";
    case gt(): return "\>";
    case le(): return "\<=";
    case ge(): return "\>=";
    case eq(): return "==";
    case ne(): return "\<\>";
    case and(): return "and";
    case or(): return "or";
    default: return "<op?>";
  }
}

str indent(str s, int n) {
  list[str] lines = split(s, "\n");
  str pad = repeat(" ", n);
  return strJoin([ pad + l | l <- lines ], "\n");
}

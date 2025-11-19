module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Relation;

import Syntax;
import Checker;

PathConfig pcfg = getProjectPathConfig(|project://rascaldsl|);
Language aluLang = language(pcfg, "ALU", "alu", "Plugin", "contribs");

set[LanguageService] contribs() = {
    parser(start[Program] (str program, loc src) {
        return parse(#start[Program], program, src);
    }),

    summarizer(Summary(loc l, start[Program] p) {
        tm = modelFromTree(p);
        defs = getUseDef(tm);
        return summary(l,
            messages = { <m.at, m> | m <- getMessages(tm), !(m is info) },
            definitions = defs);
    })
};

void main() {
    registerLanguage(aluLang);
}

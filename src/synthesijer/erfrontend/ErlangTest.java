package synthesijer.erfrontend;

import java.util.*;
import java.io.*;
import java.nio.file.*;
import java.nio.charset.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;

public class ErlangTest{
    class Listener extends ErlangBaseListener{
	
	@Override
	public void exitRoot(@NotNull ErlangParser.RootContext ctx){
	    System.out.println("root");
	}

    }

    public void calc(String src){
	ErlangLexer lexer = new ErlangLexer(new ANTLRInputStream(src));
	ErlangParser parser = new ErlangParser(new CommonTokenStream(lexer));
	Listener listener = new Listener();
	parser.addParseListener(listener);
	parser.root();
    }

    public static void main(String... args) throws Exception{
	String src = String.join("\n", Files.readAllLines(Paths.get(args[0]), Charset.defaultCharset()));
	System.out.println(src);
	(new ErlangTest()).calc(src);
    }
}


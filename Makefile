all: src/synthesijer/erfrontend/ErlangTest.java
	@$(MAKE) -C src/grammer
	javac -cp lib/antlr-4.5-complete.jar:src -d bin src/synthesijer/erfrontend/ErlangTest.java

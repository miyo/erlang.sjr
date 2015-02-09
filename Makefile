all: Erlang.g4 ErlangTest.java
	java -jar ~/Downloads/antlr-4.5-complete.jar Erlang.g4
	javac -cp ~/Downloads/antlr-4.5-complete.jar:. ErlangTest.java

# parses the commandline plantuml to find the jar file:
cat $1 | grep -o '/[^"]*plantuml.jar'
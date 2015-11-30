#Compiler For COOL
##Online Course: [Stanford Lagunita' Compilers](https://lagunita.stanford.edu/courses/Engineering/Compilers/Fall2014/info)

### July 2015 - Present

This is my independent project done for personal interest. This is an assignment based coding project. 
My notes from the course are available on my [website](https://rneha725.wordpress.com/contents-for-compilers/). The stanford lagunita course is [here](https://lagunita.stanford.edu/courses/Engineering/CS143/Spring2014/about).

There are four assignments in the course for four phases of the COOL compiler:

1.  Scanner (Lexical Analyzer)
2.  Parser
3.  Semantic Analyzer
4.  Code Generator

This is [COOL Manual](http://theory.stanford.edu/~aiken/software/cool/cool-manual.pdf) used for assignments.

###1. Scanner<br>
####Complete.
In this phase regular expressions for each string that can be identified by the COOL language is written, additionally table or a buffer is prepared to store values of int or string constants.

_[flex](https://en.wikipedia.org/wiki/Flex_lexical_analyser_generator) is used to code the file._<br>
_Files programmed: [cool.flex](https://github.com/rneha725/cs143_COOL_Compiler/blob/master/Lexer/cool.flex) and [cool-lex.cc](https://github.com/rneha725/cs143_COOL_Compiler/blob/master/Lexer/cool-lex.cc)_

###2. Parser<br>
####Complete.
After scanning each string, structure is checked for a sentence, this work is done in this phase. 

_[yacc](https://en.wikipedia.org/wiki/Yacc) is used as the tool for code.<br>
File programmed: [cool.y](https://github.com/rneha725/cs143_COOL_Compiler/blob/master/Parser/cool.y)<br>
Helping file: [cool-tree_original.aps](https://github.com/rneha725/cs143_COOL_Compiler/blob/master/Parser/cool-tree_original.aps)<br>
Output file: [cool.output](https://github.com/rneha725/cs143_COOL_Compiler/blob/master/Parser/cool.output)_

###3. Semantic Analyzer<br>
___Working...___<br>
It checks whether the sentences are in required manner or not. 

_Files programmed: [semant.cc](https://github.com/rneha725/cs143_COOL_Compiler/blob/master/Semantic%20Analyzer/semant.cc), [semant.h](https://github.com/rneha725/cs143_COOL_Compiler/blob/master/Semantic%20Analyzer/semant.h), [cool-tree.h](https://github.com/rneha725/cs143_COOL_Compiler/blob/master/Semantic%20Analyzer/cool-tree.h)<br>
Helping File: [symtab.h](https://github.com/rneha725/cs143_COOL_Compiler/blob/master/Semantic%20Analyzer/symtab.h)_<br>


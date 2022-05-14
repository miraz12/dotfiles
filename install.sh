#!/bin/bash

codeblock=0
while read line; 
do 
	if [[ $line == *"END_SRC"* ]]; then
		codeblock=0
		continue
	fi
	if [[ $codeblock == 1 ]]; then
		echo $line;
	fi
	if [[ $line == *"BEGIN_SRC bash"*"install"* ]]; then
		codeblock=1
	fi
done < README.org


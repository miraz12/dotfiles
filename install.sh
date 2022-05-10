#!/bin/bash

codeblock=0
while read line; 
do 
	if [[ $line == *"END_SRC"* ]]; then
		codeblock=0
		continue
	fi
	if [[ $codeblock == 1 ]]; then
		$line; 
	fi
	if [[ $line == *"BEGIN_SRC bash"* ]]; then
		codeblock=1
	fi
done < README.org


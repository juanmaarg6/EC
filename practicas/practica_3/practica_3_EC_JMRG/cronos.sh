# !/bin/bash

for i in 0 g 1 2; do
	printf "__OPTIM%1c__%48s\n" $i "" | tr " " "="
	gcc popcount.c -o popcount -O$i -D TEST=0
	for j in $(seq 0 10); do
		echo $j; ./popcount
	done | pr -11 -l 22 -w 80
	rm popcount
done

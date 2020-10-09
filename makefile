all : lul.l lul.y
	clear
	flex -i lul.l
	bison lul.y
	gcc lul.tab.c -o compilador -lm
	./compilador
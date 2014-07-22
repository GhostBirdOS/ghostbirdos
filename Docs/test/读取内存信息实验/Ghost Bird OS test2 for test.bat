	@title Ghost Bird test

:make
	cls
	@echo Copyright 2013-2014 Ghost Bird OS Developer.All rights reserved. 
	@echo Ghost Bird OS test programme.

	::各个文件编译
	@nasm "Ghost Bird OS test2 for test.asm" -o "Ghost Bird OS test2 for test.img"
	
:_p
	@pause
	@goto make
PNG32	= assets/grey.png assets/blue.png assets/alien_tl.png assets/alien_tr.png assets/alien_bl.png assets/alien_br.png
INC32	= include/grey.inc include/blue.inc include/alien_tl.inc include/alien_tr.inc include/alien_bl.inc include/alien_br.inc

PNG16	= assets/redball.png assets/greenball.png assets/blueball.png assets/font/a.png assets/font/b.png assets/ship.png
INC16	= include/redball.inc include/greenball.inc include/blueball.inc include/a.inc  include/b.inc include/ship.inc

all: compiledspritedemo demo

$(INC32): $(PNG32)
	./scripts/png2asm.py -i $(PNG32) -o $(INC32) -sw 32 -sh 32 -ss

$(INC16): $(PNG16)
	./scripts/png2asm.py -i $(PNG16) -o $(INC16) -sw 16 -sh 16

compiledspritedemo:	compiledspritedemo.asm
	vasmarm_std compiledspritedemo.asm -a2 -m2 -opt-ldrpc -opt-adr -chklabels -nocase -L compiledspritedemo.lst -Fbin -o compiledspritedemo
	@mkdir ../arculator/hostfs/Demo > /dev/null 2>&1 || true
	cp compiledspritedemo ../arculator/hostfs/Demo/compiledspritedemo,ff8

demo:	demo.asm include/grey.inc include/blue.inc include/redball.inc include/greenball.inc include/blueball.inc include/a.inc
	vasmarm_std demo.asm -a2 -m2 -opt-ldrpc -opt-adr -L demo.lst -Fbin -o demo
	@mkdir ../arculator/hostfs/Demo > /dev/null 2>&1 || true
	cp demo ../arculator/hostfs/Demo/demo,ff8

#include/redball.inc:
#	./scripts/png2asm.py -i assets/redball.png -o include/redball.inc -sw 16 -sh 16

#include/greenball.inc:
#	./scripts/png2asm.py -i assets/greenball.png -o include/greenball.inc -sw 16 -sh 16

#include/blueball.inc:
#	./scripts/png2asm.py -i assets/blueball.png -o include/blueball.inc -sw 16 -sh 16

#include/a.inc: assets/font/a.png
#	./scripts/png2asm.py -i assets/font/a.png -o include/a.inc -sw 16 -sh 16

clean:
	-@rm -f compiledspritedemo
	-@rm -f demo
	-@rm -f *.lst
	-@rm -f include/*.inc
	-@rm -f ../arculator/hostfs/Demo/*
	-@rm -rf ../arculator/hostfs/Demo

#run-helloworld:
#	make HELOWRLD.TOS
#	hatari --confirm-quit 0 HELOWRLD.TOS

#run-bitmap:
#	make BITMAP.TOS
#	hatari  --confirm-quit 0 BITMAP.TOS
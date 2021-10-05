PNG32	= assets/grey.png assets/blue.png assets/alien_tl.png assets/alien_tr.png assets/alien_bl.png assets/alien_br.png
INC32	= include/grey.inc include/blue.inc include/alien_tl.inc include/alien_tr.inc include/alien_bl.inc include/alien_br.inc

PNG16	= assets/redball.png assets/greenball.png assets/blueball.png assets/font/a.png assets/font/b.png assets/ship.png
INC16	= include/redball.inc include/greenball.inc include/blueball.inc include/a.inc  include/b.inc include/ship.inc

all: demo

$(INC32): $(PNG32)
	./scripts/png2asm.py -i $(PNG32) -o $(INC32) -sw 32 -sh 32 -ss

$(INC16): $(PNG16)
	./scripts/png2asm.py -i $(PNG16) -o $(INC16) -sw 16 -sh 16

demo:	demo.asm include/grey.inc include/blue.inc include/redball.inc include/greenball.inc include/blueball.inc include/a.inc
	vasmarm_std demo.asm -a2 -m2 -opt-ldrpc -opt-adr -L demo.lst -Fbin -o demo

clean:
	-@rm -f demo
	-@rm -f *.lst
	-@rm -f include/*.inc
	-@rm -f ../arculator/hostfs/Demo/*
	-@rm -rf ../arculator/hostfs/Demo

deploy:
	make demo
	@mkdir ../arculator/hostfs/!Demo > /dev/null 2>&1 || true
	cp demo ../arculator/hostfs/!Demo/demo,ff8
	cp !Run ../arculator/hostfs/!Demo/!Run,feb

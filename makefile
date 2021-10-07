ARCULATOR = ../../sarah-walker-pcem/arculator

PNG32	= assets/grey.png assets/blue.png assets/alien_tl.png assets/alien_tr.png assets/alien_bl.png assets/alien_br.png
INC32	= include/grey.inc include/blue.inc include/alien_tl.inc include/alien_tr.inc include/alien_bl.inc include/alien_br.inc

PNG16	= assets/redball.png assets/greenball.png assets/blueball.png assets/font/a.png assets/font/b.png assets/ship.png
INC16	= include/redball.inc include/greenball.inc include/blueball.inc include/a.inc  include/b.inc include/ship.inc

all: !Demo/!RunImage,ff8

$(INC32): $(PNG32)
	./scripts/png2asm.py -i $(PNG32) -o $(INC32) -sw 32 -sh 32 -ss

$(INC16): $(PNG16)
	./scripts/png2asm.py -i $(PNG16) -o $(INC16) -sw 16 -sh 16

!Demo/!RunImage,ff8:	demo.asm include/grey.inc include/blue.inc include/redball.inc include/greenball.inc include/blueball.inc include/a.inc
	vasmarm_std demo.asm -a2 -m2 -opt-ldrpc -opt-adr -L demo.lst -Fbin -o !Demo/!RunImage,ff8

clean:
	-@rm -f demo
	-@rm -f *.lst
	-@rm -f include/*.inc
	-@rm -rf $(ARCULATOR)/hostfs/!Demo
	-@rm -rf $(ARCULATOR)/hostfs/!Boot,feb

deploy:
	-@make
	-@cp -r !Demo $(ARCULATOR)/hostfs/
	-@cp !Boot,feb $(ARCULATOR)/hostfs/

run-arculator-a3000:
	-@make deploy
	cd $(ARCULATOR)/; ./arculator A3000

run-arculator-a3010:
	-@make deploy
	-@cd $(ARCULATOR)/; ./arculator A3010

run-arculator-a5000:
	-@make deploy
	-@cd $(ARCULATOR)/; ./arculator A5000

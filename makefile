all: compiledspritedemo demo

compiledspritedemo: compiledspritedemo,ff8

demo: demo,ff8

compiledspritedemo,ff8:	compiledspritedemo.asm
	vasmarm_std compiledspritedemo.asm -a2 -m2 -opt-ldrpc -opt-adr -chklabels -nocase -L compiledspritedemo.lst -Fbin -o compiledspritedemo,ff8
	@mkdir ../arculator/hostfs/Demo > /dev/null 2>&1 || true
	cp compiledspritedemo,ff8 ../arculator/hostfs/Demo

demo,ff8:	demo.asm include/grey.inc include/blue.inc include/redball.inc include/greenball.inc include/blueball.inc include/a.inc
	vasmarm_std demo.asm -a2 -m2 -opt-ldrpc -opt-adr -chklabels -nocase -L demo.lst -Fbin -o demo,ff8
	@mkdir ../arculator/hostfs/Demo > /dev/null 2>&1 || true
	cp demo,ff8 ../arculator/hostfs/Demo

include/grey.inc:
	./scripts/png2asm.py -i assets/32x32grey.png -o include/grey.inc -sw 32 -sh 32 -ss

include/blue.inc:
	./scripts/png2asm.py -i assets/32x32blue.png -o include/blue.inc -sw 32 -sh 32 -ss

include/redball.inc:
	./scripts/png2asm.py -i assets/redball.png -o include/redball.inc -sw 16 -sh 16

include/greenball.inc:
	./scripts/png2asm.py -i assets/greenball.png -o include/greenball.inc -sw 16 -sh 16

include/blueball.inc:
	./scripts/png2asm.py -i assets/blueball.png -o include/blueball.inc -sw 16 -sh 16

include/a.inc:
	./scripts/png2asm.py -i assets/font/a.png -o include/a.inc -sw 16 -sh 16

clean:
	-@rm -f compiledspritedemo,ff8
	-@rm -f demo,ff8
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
PROJECT = ver

$(PROJECT).bin: $(PROJECT).asm bios.inc
	asm02 -l -L $(PROJECT).asm
	link02 -e $(PROJECT).prg -o $(PROJECT).bin

hex: $(PROJECT).prg
	cat $(PROJECT).prg | ../../tointel.pl > $(PROJECT).hex

bin: $(PROJECT).prg
	../../tobinary $(PROJECT).prg

package:
	asm02 -l -L $(PROJECT)
	cat $(PROJECT).prg | sed -f adjust.sed > x.prg
	rm $(PROJECT).prg
	mv x.prg $(PROJECT).prg

install: $(PROJECT).prg
	cp $(PROJECT).prg ../../..
	cd ../../.. ; ./run -R $(PROJECT).prg

clean:
	-rm $(PROJECT).prg
	-rm $(PROJECT).bin


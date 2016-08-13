FFLAGS = -O
CFLAGS = ${FFLAGS} -I$(NR)/NRC_includes
NRLIB = $(MY_BIN)

CAP  = cap cap_dir mtdcmp radpttn

SUBS = fft.o Complex.o radiats.o grid3d.o futterman.o sacio.o trap.o

all: $(CAP)

cap cap_dir: %:%.o $(SUBS) cap_sub.o
	$(LINK.f) -o $@ $^ -L$(SACHOME)/lib -lsac -lsacio -L$(NRLIB) -lnr

cap_dir.o: cap.c
	$(COMPILE.c) -DDIRECTIVITY -o $@ $<

mtdcmp: mtdcmp.o
	$(LINK.f) -o $@ $@.o

radpttn: radpttn.o radiats.o
	$(LINK.c) -o $@ $@.o radiats.o -lm

clean:
	rm -f $(CAP) *.o

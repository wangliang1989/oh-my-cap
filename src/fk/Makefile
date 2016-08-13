FC=gfortran -ffixed-line-length-none
optimize=-O
FFLAGS=$(optimize)
CFLAGS=$(optimize) -DSAC_LIB
SACLIB=-L$(SACHOME)/lib -lsac -lsacio

SUBS = fft.o Complex.o sacio.o
FKSUBS = fk.o kernel.o prop.o source.o bessel.o $(SUBS)

all: fk syn st_fk trav sachd

syn: syn.o ${SUBS} radiats.o futterman.o
	$(CC) -o $@ $^ ${SACLIB} -lm

fk: ${FKSUBS} haskell.o
	$(FC) -o $@ $^

st_fk: ${FKSUBS} st_haskell.o
	$(FC) -o $@ $^

sachd: sachd.o sacio.o
	$(CC) -o $@ $^ -lm

trav: trav.o tau_p.o
	$(FC) -o $@ trav.o tau_p.o

bessel.f: bessel.FF
	cpp -traditional-cpp $< > $@

clean:
	rm -f *.o bessel.f

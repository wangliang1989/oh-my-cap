GMT_INC=-I${GMT4HOME}/include
GMT_LIBS=-L${GMT4HOME}/lib -lgmt -lpsl -lgmtps -lnetcdf -lm
CFLAGS = -O ${GMT_INC}

pssac: pssac.o sacio.o
	$(CC) -o $@ $@.o sacio.o $(GMT_LIBS)
clean:
	rm -f *.o

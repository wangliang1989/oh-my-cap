CFLAGS = -O ${GMT_INC}

pssac: pssac.o sacio.o
	$(LINK.c) -o $@ $@.o sacio.o $(GMT_LIBS)

clean:
	rm -f pssac *.o

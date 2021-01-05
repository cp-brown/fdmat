# MATLAB root
MDIR = /usr/local/MATLAB/R2020b
# Linking with MATLAB
MINCL = -I$(MDIR)/extern/include -shared

# MKL root
#MKLROOT = /opt/intel/oneapi/mkl/2021.1.1

# Fortran compiler
F90 = gfortran
FLAGS = -Isrc -fPIC -cpp -O2 #-I"${MKLROOT}/include" -m64
#LINKLINE = -L${MKLROOT}/lib/intel64 -lmkl_rt -Wl,--no-as-needed -lpthread -lm -ldl

# Extension name
EXT = mexa64



all: distancematrixf.$(EXT)

global.o: ./src/global.f90
	$(F90) -o $@ -c $(FLAGS) $<

distancematrix.o: ./src/distancematrix.f90 global.o
	$(F90) -o $@ -c $(FLAGS) $<

interface.o: ./src/interface.f90 distancematrix.o global.o
	$(F90) -o $@ -c $(FLAGS) $(MINCL) $<

distancematrixf.$(EXT): interface.o distancematrix.o global.o
	$(F90) -o $@ $(FLAGS) $(MINCL) $^
	rm -f *.o *.mod

clean:
	rm -f *.o *.mod *.$(EXT)
# MATLAB root
MATDIR = /usr/local/MATLAB/R2020b
# Linking with MATLAB
MATINCL = -I$(MATDIR)/extern/include

# Locations of source code, object files, and module files
SRC = ./src
OBJS = ./objs
MODS = ./mods

# Fortran compiler
F90 = ifort
FLAGS = -warn errors -fpp -fpic -heap-arrays -nogen-interfaces -module $(MODS)

# Extension name
EXT = mexa64

# MKL stuff
MKLROOT = /opt/intel/oneapi/mkl/latest
MKLINCL = -I$(MKLROOT)/include/intel64/ilp64
MKLLINK = -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_ilp64.a ${MKLROOT}/lib/intel64/libmkl_intel_thread.a ${MKLROOT}/lib/intel64/libmkl_core.a -Wl,--end-group -liomp5 -lpthread -lm -ldl
BLAS95 = $(MKLROOT)/lib/intel64/libmkl_blas95_ilp64.a



all: standalone distancematrixf.$(EXT)

$(OBJS)/global.o: $(SRC)/global.f90
	$(F90) $(FLAGS) $< -o $@ -c

$(OBJS)/distancematrix.o: $(SRC)/distancematrix.f90 $(OBJS)/global.o
	$(F90) $(FLAGS) $(MKLINCL) $< -o $@ -c

$(OBJS)/interface.o: $(SRC)/interface.f90 $(OBJS)/distancematrix.o $(OBJS)/global.o
	$(F90) $(FLAGS) $(MATINCL) $< -o $@ -c

distancematrixf.$(EXT): $(OBJS)/interface.o $(OBJS)/distancematrix.o $(OBJS)/global.o
	$(F90) $(FLAGS) $(MATINCL) $(MKLINCL) $^ $(BLAS95) $(MKLLINK) -o $@ -shared

clean:
	rm -f $(OBJS)/*.o $(MODS)/*.mod *.$(EXT) standalone

$(OBJS)/standalone.o: $(SRC)/standalone.f90 $(OBJS)/distancematrix.o $(OBJS)/global.o
	$(F90) $(FLAGS) $< -o $@ -c

standalone: $(OBJS)/standalone.o $(OBJS)/distancematrix.o $(OBJS)/global.o
	$(F90) $(FLAGS) $(MKLINCL) $^ $(BLAS95) $(MKLLINK) -o $@
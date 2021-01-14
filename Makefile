# For linking with MATLAB
MATDIR = /usr/local/MATLAB/R2020b
MATINCL = -I$(MATDIR)/extern/include

# Locations of source code, object files, and module files
SRC = ./src
OBJS = ./objs
MODS = ./mods

# Fortran compiler
F90 = ifort
FLAGS = -i8 -warn errors -fpp -fpic -heap-arrays -nogen-interfaces -module $(MODS)

# Extension name
EXT = mexa64

# For linking with MKL and BLAS95
MKLROOT = /opt/intel/oneapi/mkl/latest
MKLINCL = -I$(MKLROOT)/include/intel64/ilp64
MKLLINK = -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_ilp64.a ${MKLROOT}/lib/intel64/libmkl_intel_thread.a ${MKLROOT}/lib/intel64/libmkl_core.a -Wl,--end-group -liomp5 -lpthread -lm -ldl
BLAS95 = $(MKLROOT)/lib/intel64/libmkl_blas95_ilp64.a



.PHONY: all clean
all: distancematrixf.$(EXT)

$(OBJS)/global.o: $(SRC)/global.f90
	$(F90) $(FLAGS) $< -o $@ -c

$(OBJS)/distancematrix_mod.o: $(SRC)/distancematrix_mod.f90 $(OBJS)/global.o
	$(F90) $(FLAGS) $(MKLINCL) $< -o $@ -c

$(OBJS)/distancematrix_sym.o: $(SRC)/distancematrix_sym.f90 $(OBJS)/distancematrix_mod.o
	$(F90) $(FLAGS) $< -o $@ -c

$(OBJS)/distancematrix_asym.o: $(SRC)/distancematrix_asym.f90 $(OBJS)/distancematrix_mod.o
	$(F90) $(FLAGS) $< -o $@ -c

$(OBJS)/interface.o: $(SRC)/interface.f90 $(OBJS)/distancematrix_mod.o $(OBJS)/global.o
	$(F90) $(FLAGS) $(MATINCL) $< -o $@ -c

distancematrixf.$(EXT): $(OBJS)/interface.o $(OBJS)/distancematrix_mod.o $(OBJS)/distancematrix_sym.o $(OBJS)/distancematrix_asym.o $(OBJS)/global.o
	$(F90) $(FLAGS) $(MATINCL) $(MKLINCL) $^ $(BLAS95) $(MKLLINK) -o $@ -shared

clean:
	rm -f $(OBJS)/*.o $(MODS)/*.mod $(MODS)/*.smod *.$(EXT) standalone

#$(OBJS)/standalone.o: $(SRC)/standalone.f90 $(OBJS)/distancematrix.o $(OBJS)/global.o
#	$(F90) $(FLAGS) $< -o $@ -c

#standalone: $(OBJS)/standalone.o $(OBJS)/distancematrix.o $(OBJS)/global.o
#	$(F90) $(FLAGS) $(MKLINCL) $^ $(BLAS95) $(MKLLINK) -o $@
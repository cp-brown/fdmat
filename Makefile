# MATLAB root
#MATDIR = /usr/local/MATLAB/R2020b
# Linking with MATLAB
#MATINCL = -I$(MDIR)/extern/include -shared

# Locations of source code, object files, and module files
SRC = ./src
OBJS = ./objs
MODS = ./mods

# Fortran compiler
#F90 = gfortran
#FLAGS = -I$(SRC) -fPIC -cpp -O2 -J$(MODS)
F90 = ifort
#FLAGS = -warn errors -fpp -fpic -module $(MODS) -heap-arrays
FLAGS = -warn errors -nogen-interfaces -module $(MODS)

# Extension name
EXT = mexa64

# MKL stuff
MKLROOT = /opt/intel/oneapi/mkl/latest
MKLINCL = -I$(MKLROOT)/include/intel64/lp64
OMP_LIB = -liomp5
MKLLINK = -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_lp64.a ${MKLROOT}/lib/intel64/libmkl_intel_thread.a ${MKLROOT}/lib/intel64/libmkl_core.a -Wl,--end-group $(OMP_LIB) -lpthread -ldl
BLAS95 = $(MKLROOT)/lib/intel64/libmkl_blas95_lp64.a



all: standalone #distancematrixf.$(EXT)

$(OBJS)/global.o: $(SRC)/global.f90
	$(F90) -o $@ -c $(FLAGS) $<

$(OBJS)/distancematrix.o: $(SRC)/distancematrix.f90 $(OBJS)/global.o
	$(F90) -o $@ -c $(FLAGS) $(MKLINCL) $<

#$(OBJS)/interface.o: $(SRC)/interface.f90 $(OBJS)/distancematrix.o $(OBJS)/global.o
#	$(F90) -o $@ -c $(FLAGS) $(MINCL) $<

#distancematrixf.$(EXT): $(OBJS)/interface.o $(OBJS)/distancematrix.o $(OBJS)/global.o
#	$(F90) -o $@ $(FLAGS) $(MINCL) $^

clean:
	rm -f $(OBJS)/*.o $(MODS)/*.mod *.$(EXT) standalone



$(OBJS)/standalone.o: $(SRC)/standalone.f90 $(OBJS)/distancematrix.o $(OBJS)/global.o
	$(F90) -o $@ -c $(FLAGS) $<

standalone: $(OBJS)/standalone.o $(OBJS)/distancematrix.o $(OBJS)/global.o
	$(F90) $(FLAGS) $(MKLINCL) $^ $(BLAS95) $(MKLLINK) -o $@
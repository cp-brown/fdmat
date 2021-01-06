# MATLAB root
MDIR = /usr/local/MATLAB/R2020b
# Linking with MATLAB
MINCL = -I$(MDIR)/extern/include -shared

# Locations of source code, object files, and module files
SRC = ./src
OBJS = ./objs
MODS = ./mods

# Fortran compiler
#F90 = gfortran
#FLAGS = -I$(SRC) -fPIC -cpp -O2 -J$(MODS)
F90 = ifort
FLAGS = -I$(SRC) -O2 -fpp -fpic -module $(MODS) -heap-arrays

# Extension name
EXT = mexa64



all: distancematrixf.$(EXT)

$(OBJS)/global.o: $(SRC)/global.f90
	$(F90) -o $@ -c $(FLAGS) $<

$(OBJS)/distancematrix.o: $(SRC)/distancematrix.f90 $(OBJS)/global.o
	$(F90) -o $@ -c $(FLAGS) $<

$(OBJS)/interface.o: $(SRC)/interface.f90 $(OBJS)/distancematrix.o $(OBJS)/global.o
	$(F90) -o $@ -c $(FLAGS) $(MINCL) $<

distancematrixf.$(EXT): $(OBJS)/interface.o $(OBJS)/distancematrix.o $(OBJS)/global.o
	$(F90) -o $@ $(FLAGS) $(MINCL) $^

clean:
	rm -f $(OBJS)/*.o $(MODS)/*.mod *.$(EXT) standalone



standalone: $(SRC)/standalone.f90 $(OBJS)/distancematrix.o $(OBJS)/global.o
	$(F90) -o $@ $(FLAGS) $^
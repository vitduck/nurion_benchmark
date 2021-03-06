# build environement
# adapt form xconfigure
# this version of elpa does not contain avx512 kernel

export FC=mpiifort
export FCFLAGS="-Ofast $CRAY_xAVX -align array64byte -heap-arrays 4096"

export CC=mpiicc 
export CFLAGS="-Ofast $CRAY_xAVX -fno-alias -ansi-alias"

export ELPA_VER="2018.11.001"
export PREFIX="$HOME/benchmark/lib/$COMPILER/$COMPILER_VER/$CRAY_CPU_TARGET/elpa/$ELPA_VER"

SCALAPACK_LDFLAGS="-L$MKLROOT/lib/intel64 -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential"
SCALAPACK_FCFLAGS="-L$MKLROOT/include" 

../configure --enable-avx512 --prefix=$PREFIX 

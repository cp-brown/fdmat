#include "fintrf.h"
subroutine mexFunction(nlhs, plhs, nrhs, prhs)

    use global
    use distancematrix_mod
    implicit none

  ! --- Declarations - I/O --- !

    ! number of input and output arguments, respectively
    integer :: nrhs, nlhs
    ! pointer to inputs and outputs, respectively
    mwPointer :: prhs(*), plhs(*)

  ! --- Declarations - local --- !

    ! Functions from MATLAB matrix API
    mwPointer :: mxGetDoubles
    mwPointer :: mxCreateDoubleMatrix
    integer :: mxIsNumeric
    mwPointer :: mxGetM, mxGetN

    ! Pointers to input/output mxArrays:
    mwPointer :: dsites_ptr, cntrs_ptr, dmat_ptr

    ! Array information:
    mwPointer :: m, n, d1, d2
    mwSize :: dsites_size, cntrs_size, dmat_size

    ! Arguments for computational routine:
    real(dp), allocatable :: dsites_input(:,:), cntrs_input(:,:), dmat_output(:,:)

  ! --- Input checking --- !

    ! Check for proper number of arguments.
    if(nrhs /= 2) then
        call mexErrMsgIdAndTxt('MATLAB:timestwo:nInput', &
            'Two inputs required')
    elseif(nlhs > 1) then
        call mexErrMsgIdAndTxt('MATLAB:timestwo:nOutput', &
            'Too many output arguments')
    endif

    ! Check that the input is a number.
    if(mxIsNumeric(prhs(1)) == 0 .or. mxIsNumeric(prhs(2)) == 0) then
        call mexErrMsgIdAndTxt('MATLAB:timestwo:NonNumeric', &
            'Inputs must be a numeric')
    endif

  ! --- Translate to Fortran data types --- !

    ! Get the sizes of the arrays
    m = mxGetM(prhs(1))
    d1 = mxGetN(prhs(1))
    d2 = mxGetM(prhs(2))
    n = mxGetN(prhs(2))
    dsites_size = m * d1
    cntrs_size = n * d2
    dmat_size = m * n

    ! Create Fortran arrays from the input arguments
    dsites_ptr = mxGetDoubles(prhs(1))
    cntrs_ptr = mxGetDoubles(prhs(2))
    allocate(dsites_input(m,d1), cntrs_input(d2,n))
    call mxCopyPtrToReal8(dsites_ptr, dsites_input, dsites_size)
    call mxCopyPtrToReal8(cntrs_ptr, cntrs_input, cntrs_size)

    ! Create matrix for the return argument.
    plhs(1) = mxCreateDoubleMatrix(m, n, 0)
    dmat_ptr = mxGetDoubles(plhs(1))

  ! --- Computation + translate back to MATLAB --- !

    ! Call the computational subroutine
    dmat_output = distancematrix(dsites_input, cntrs_input)

    ! Load the data into y_ptr, which is the output to MATLAB.
    call mxCopyReal8ToPtr(dmat_output, dmat_ptr, dmat_size)

    return

end subroutine mexFunction
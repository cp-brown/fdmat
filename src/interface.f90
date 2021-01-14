#include "fintrf.h"
subroutine mexFunction(nlhs, plhs, nrhs, prhs)

    use global
    use distancematrix_mod
    implicit none

  ! --- Declarations - I/O --- !

    ! number of input and output arguments, respectively
    integer*4 :: nrhs, nlhs
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
    integer :: error

  ! ---  --- !

    if (nlhs > 1) then
        call mexErrMsgIdAndTxt('MATLAB:distancematrixf:nOutput', &
            'Too many output arguments')
    end if

    select case (nrhs)
      case (1)

        m = mxGetM(prhs(1))
        d1 = mxGetN(prhs(1))
        dsites_size = m * d1

        dmat_size = m**2

        dsites_ptr = mxGetDoubles(prhs(1))
        allocate(dsites_input(m, d1))
        call mxCopyPtrToReal8(dsites_ptr, dsites_input, dsites_size)

        plhs(1) = mxCreateDoubleMatrix(m, m, 0)
        dmat_ptr = mxGetDoubles(plhs(1))

        call distancematrix_sym(dsites_input, dmat_output, error)

      case (2)

        m = mxGetM(prhs(1))
        d1 = mxGetN(prhs(1))
        dsites_size = m * d1

        n = mxGetM(prhs(2))
        d2 = mxGetN(prhs(2))
        cntrs_size = n * d2

        dmat_size = m * n

        dsites_ptr = mxGetDoubles(prhs(1))
        allocate(dsites_input(m, d1))
        call mxCopyPtrToReal8(dsites_ptr, dsites_input, dsites_size)

        cntrs_ptr = mxGetDoubles(prhs(2))
        allocate(cntrs_input(n, d2))
        call mxCopyPtrToReal8(cntrs_ptr, cntrs_input, cntrs_size)

        plhs(1) = mxCreateDoubleMatrix(m, n, 0)
        dmat_ptr = mxGetDoubles(plhs(1))

        call distancematrix(dsites_input, cntrs_input, dmat_output, error)

      case default
        call mexErrMsgIdAndTxt('MATLAB:distancematrixf:nInput', 'One or two inputs required')

    end select

    select case (error)
      case (0)
        call mxCopyReal8ToPtr(dmat_output, dmat_ptr, dmat_size)
        return
      case (1)
        call mexErrMsgIdAndTxt('MATLAB:distancematrixf', 'Data dimensions do not match')
    end select

end subroutine mexFunction
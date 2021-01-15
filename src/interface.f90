#include "fintrf.h"
subroutine mexFunction(nlhs, plhs, nrhs, prhs)

    use global, only: dp
    use distancematrix_mod, only: distancematrix_asym, distancematrix_sym
    implicit none

  ! ----------------------------------------------------------------------------
  ! Declarations - I/O
  ! ----------------------------------------------------------------------------

    ! number of input and output arguments, respectively
    integer*4 :: nrhs, nlhs

    ! pointer to inputs and outputs, respectively
    mwPointer :: prhs(*), plhs(*)

  ! ----------------------------------------------------------------------------
  ! Declarations - local
  ! ----------------------------------------------------------------------------

    ! Functions and subroutines imported from MATLAB matrix API
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
    real(dp), allocatable :: dsites(:,:), cntrs(:,:), dmat(:,:)
    integer :: error

  ! ----------------------------------------------------------------------------
  ! Execution
  ! ----------------------------------------------------------------------------

    ! Require 0 or 1 output arguments
    if (nlhs > 1) then
        call mexErrMsgIdAndTxt('MATLAB:distancematrixf:nOutput', &
            'Too many output arguments')
    end if

    ! Branch based on the number of inputs
    select case (nrhs)

      ! When there is one input, we translate one array and call the symmetric version
      case (1)

        ! dsites dimensions
        m = mxGetM(prhs(1))
        d1 = mxGetN(prhs(1))
        dsites_size = m * d1

        ! output size - will be needed later
        dmat_size = m**2

        ! translate dsites from MATLAB to Fortran
        dsites_ptr = mxGetDoubles(prhs(1))
        allocate(dsites(m, d1))
        call mxCopyPtrToReal8(dsites_ptr, dsites, dsites_size)

        ! computation
        call distancematrix_sym(dsites, dmat, error)

        ! allocate output in MATLAB
        plhs(1) = mxCreateDoubleMatrix(m, m, 0)

      ! Where there are two inputs, we translate two arrays and call the asymmetric version
      case (2)

        ! dsites dimensions
        m = mxGetM(prhs(1))
        d1 = mxGetN(prhs(1))
        dsites_size = m * d1

        ! cntrs dimensions
        n = mxGetM(prhs(2))
        d2 = mxGetN(prhs(2))
        cntrs_size = n * d2

        ! output size - will be needed later
        dmat_size = m * n

        ! translate dsites from MATLAB to Fortran
        dsites_ptr = mxGetDoubles(prhs(1))
        allocate(dsites(m, d1))
        call mxCopyPtrToReal8(dsites_ptr, dsites, dsites_size)

        ! translate cntrs from MATLAB to Fortran
        cntrs_ptr = mxGetDoubles(prhs(2))
        allocate(cntrs(n, d2))
        call mxCopyPtrToReal8(cntrs_ptr, cntrs, cntrs_size)

        ! computation
        call distancematrix_asym(dsites, cntrs, dmat, error)

        ! allocate output in MATLAB
        plhs(1) = mxCreateDoubleMatrix(m, n, 0)

      ! Invalid number of inputs
      case default
        call mexErrMsgIdAndTxt('MATLAB:distancematrixf:nInput', 'One or two inputs required')

    end select

    ! Branch based on error code from the computational routine
    select case (error)

      ! No errors - translate to MATLAB and exit
      case (0)
        dmat_ptr = mxGetDoubles(plhs(1))
        call mxCopyReal8ToPtr(dmat, dmat_ptr, dmat_size)
        return

      case (1)
        call mexErrMsgIdAndTxt('MATLAB:distancematrixf', 'Data dimensions do not match')

    end select

end subroutine mexFunction
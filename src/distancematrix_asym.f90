submodule (distancematrix_mod) distancematrix_mod_asym
implicit none

contains

module procedure distancematrix_asym

  ! ----------------------------------------------------------------------------
  ! Declarations of local variables
  ! ----------------------------------------------------------------------------

    ! Number of points in datasites and centers, respectively
    integer :: M, N

    ! Dimensionality of data
    integer :: d

    ! Temporary arrays to hold sums of squares
    real(dp), allocatable :: ss_dsites(:), ss_cntrs(:)

    ! Iterator
    integer :: k
    
  ! ----------------------------------------------------------------------------
  ! Setup
  ! ----------------------------------------------------------------------------

    ! Get sizes
    M = size(datasites, 1)
    N = size(centers, 1)
    d = size(datasites, 2)

    ! Quit with error if dimensions aren't compatible
    if (size(centers, 2) /= d) then
        error = 1
        return
    end if

    ! Allocate dmat
    if (allocated(dmat)) deallocate(dmat)
    allocate(dmat(M,N))
    
  ! ----------------------------------------------------------------------------
  ! Algorithm
  ! ----------------------------------------------------------------------------

    ! Initializes dmat as -2*datasites*centers
    call gemm(datasites, centers, dmat, 'n', 't', -2.0_dp)

    ! Add matrix of sums of squares
    allocate(ss_dsites(M), ss_cntrs(N))
    ss_dsites = sum(datasites**2.0_dp, 2)
    ss_cntrs = sum(centers**2.0_dp, 2)
    do k = 1, N
        dmat(:,k) = dmat(:,k) + ss_dsites(:) + ss_cntrs(k)
    end do
    deallocate(ss_dsites, ss_cntrs)

    ! Take square root of all elements to finish
    where (dmat < 0.0_dp)
        dmat = 0.0_dp
    end where
    dmat = dmat**0.5_dp

    ! Successful exit
    error = 0
    return

end procedure distancematrix_asym

end submodule distancematrix_mod_asym
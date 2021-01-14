submodule (distancematrix_mod) distancematrix_mod_sym
implicit none

contains

module procedure distancematrix_sym

  ! --- LOCAL DECLARATIONS --- !

    ! Number of points in datasites and centers, respectively
    integer :: M
    ! Dimensionality of data
    integer :: d
    ! Temporary arrays to hold sums of squares
    real(dp), allocatable :: ss_pts(:)
    ! Iterator
    integer :: k
    
  ! --- SETUP --- !

    ! Get sizes
    M = size(pts, 1)
    d = size(pts, 2)

    ! Allocate dmat
    if (allocated(dmat)) deallocate(dmat)
    allocate(dmat(M,M))
    
  ! --- ALGORITHM --- !

    ! Initializes dmat as -2*pts*pts^T
    call gemm(pts, pts, dmat, 'n', 't', -2.0_dp)

    ! Add matrix of sums of squares
    allocate(ss_pts(M))
    ss_pts = sum(pts**2.0_dp, 2)
    do k = 1, M
        dmat(:,k) = dmat(:,k) + ss_pts(:) + ss_pts(k)
    end do
    deallocate(ss_pts)

    ! Take square root of all elements to finish
    where (dmat < 0.0_dp)
        dmat = 0.0_dp
    end where
    dmat = dmat**0.5_dp

    ! Successful exit
    error = 0
    return

end procedure distancematrix_sym

end submodule distancematrix_mod_sym
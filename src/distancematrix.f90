module distancematrix_mod
use global
use blas95, only: gemm
implicit none
private
public distancematrix, distancematrix_sym

contains

subroutine distancematrix(datasites, centers, dmat, error)

  ! --- INPUT DECLARATIONS --- !

    ! Location of data: M x d matrix
    real(dp), intent(in) :: datasites(:,:)
    ! Evaluation points: N x d matrix
    real(dp), intent(in) :: centers(:,:)

  ! --- OUTPUT DECLARATIONS --- !

    ! The distance matrix: M x N
    real(dp), allocatable, intent(out) :: dmat(:,:)
    ! Error code
    integer, intent(out) :: error

  ! --- LOCAL DECLARATIONS --- !

    ! Number of points in datasites and centers, respectively
    integer :: M, N
    ! Dimensionality of data
    integer :: d
    ! Temporary arrays to hold sums of squares
    real(dp), allocatable :: ss_dsites(:), ss_cntrs(:)
    ! Iterator
    integer :: k
    
  ! --- SETUP --- !

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
    
  ! --- ALGORITHM --- !

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

end subroutine distancematrix

! A simplified version for the important special case when datasites == centers
subroutine distancematrix_sym(pts, dmat, error)

  ! --- INPUT DECLARATIONS --- !

    ! Location of data: M x d matrix
    real(dp), intent(in) :: pts(:,:)

  ! --- OUTPUT DECLARATIONS --- !

    ! The distance matrix: M x N
    real(dp), allocatable, intent(out) :: dmat(:,:)
    ! Error code
    integer, intent(out) :: error

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

end subroutine distancematrix_sym

end module distancematrix_mod
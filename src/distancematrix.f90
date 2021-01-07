module distancematrix_mod
use global
use blas95, only: gemm
implicit none
private
public distancematrix

contains

subroutine distancematrix(datasites, centers, dmat, error)

  ! --- INPUT DECLARATIONS --- !

    ! Location of data: M x d matrix
    real(dp), intent(in) :: datasites(:,:)
    ! Evaluation points: d x N matrix
    real(dp), intent(in) :: centers(:,:)

  ! --- OUTPUT DECLARATIONS --- !

    ! The distance matrix: M x N
    real(dp), allocatable, intent(out) :: dmat(:,:)
    ! Error code
    integer, intent(out) :: error

  ! --- LOCAL DECLARATIONS --- !

    ! Number of points in datasites and centers, respectively
    integer :: N, M
    ! Dimensionality of data
    integer :: d
    ! Temporary arrays to hold sums of squares
    real(dp), allocatable :: ss_dsites(:), ss_cntrs(:)
    ! Iterator
    integer :: k
    
  ! --- SETUP --- !

    ! Get sizes
    M = size(datasites, 1)
    N = size(centers, 2)
    d = size(datasites, 2)

    ! Quit with error if dimensions aren't compatible
    if (size(centers, 1) /= d) then
        write(*,*) 'dimensions do not match'
        error = 1
        return
    end if

    ! Allocate dmat
    if (allocated(dmat)) deallocate(dmat)
    allocate(dmat(M,N))
    
  ! --- ALGORITHM --- !

    ! Initializes dmat as -2*datasites*centers
    call gemm(datasites, centers, dmat, 'n', 'n', -2.0_dp)

    ! Add matrix of sums of squares
    allocate(ss_dsites(M), ss_cntrs(N))
    ss_dsites = sum(datasites**2.0_dp, 2)
    ss_cntrs = sum(centers**2.0_dp, 1)
    do k = 1, N
        dmat(:,k) = dmat(:,k) + ss_dsites(:) + ss_cntrs(k)
    end do
    deallocate(ss_dsites, ss_cntrs)

    ! Take square root of all elements to finish
    dmat = dmat**0.5_dp

    ! Successful exit
    error = 0
    return

end subroutine distancematrix

end module distancematrix_mod
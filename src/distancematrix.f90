module distancematrix_mod
use global
!use blas95
implicit none
private
public distancematrix

contains

function distancematrix(datasites, centers) result(dmat)

    real(dp), intent(in) :: datasites(:,:), centers(:,:)
    real(dp), allocatable :: dmat(:,:)

    integer :: N, M, d

    M = size(datasites, 1)
    N = size(centers, 2)
    d = size(datasites, 2)

    ! Make sure size(centers, 1) is also d
    if (size(centers, 1) /= d) stop "dimensions do not match"

    if (allocated(dmat)) deallocate(dmat)
    allocate(dmat(M,N))
    
    ! Algorithm
    dmat = spread(sum(datasites**2.0_dp, 2), 2, N) &
        + spread(sum(centers**2.0_dp, 1), 1, M) &
        - 2.0_dp * matmul(datasites, centers)
    dmat = dmat**0.5_dp

end function distancematrix

end module distancematrix_mod
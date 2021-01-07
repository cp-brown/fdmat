module distancematrix_mod
use global
use blas95
implicit none
private
public distancematrix

contains

function distancematrix(datasites, centers) result(dmat)

    real(dp), intent(in) :: datasites(:,:), centers(:,:)
    real(dp), allocatable :: dmat(:,:)

    integer :: N, M, d, k
    real(dp), allocatable :: ss_dsites(:), ss_cntrs(:)

    M = size(datasites, 1)
    N = size(centers, 2)
    d = size(datasites, 2)

    ! Make sure size(centers, 1) is also d
    if (size(centers, 1) /= d) stop "dimensions do not match"

    if (allocated(dmat)) deallocate(dmat)
    allocate(dmat(M,N))
    
    ! Algorithm
    call gemm(datasites, centers, dmat, 'n', 'n', -2.0_dp)
    allocate(ss_dsites(M), ss_cntrs(N))
    ss_dsites = sum(datasites**2.0_dp, 2)
    ss_cntrs = sum(centers**2.0_dp, 1)
    do k = 1, N
        dmat(:,k) = dmat(:,k) + ss_dsites(:) + ss_cntrs(k)
    end do
    deallocate(ss_dsites, ss_cntrs)
    dmat = dmat**0.5_dp

end function distancematrix

end module distancematrix_mod
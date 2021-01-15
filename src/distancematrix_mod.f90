module distancematrix_mod
use global, only: dp
use blas95, only: gemm
implicit none
private
public distancematrix_asym, distancematrix_sym

interface

module subroutine distancematrix_asym(datasites, centers, dmat, error)

  ! Inputs

    ! Location of data: M x d matrix
    real(dp), intent(in) :: datasites(:,:)

    ! Evaluation points: N x d matrix
    real(dp), intent(in) :: centers(:,:)

  ! Outputs

    ! The distance matrix: M x N
    real(dp), allocatable, intent(out) :: dmat(:,:)

    ! Error code
    integer, intent(out) :: error

end subroutine distancematrix_asym

! A simplified version for the important special case when datasites == centers
module subroutine distancematrix_sym(pts, dmat, error)

  ! Inputs

    ! Location of data: M x d matrix
    real(dp), intent(in) :: pts(:,:)

  ! Outputs

    ! The distance matrix: M x N
    real(dp), allocatable, intent(out) :: dmat(:,:)

    ! Error code
    integer, intent(out) :: error

end subroutine distancematrix_sym

end interface

end module distancematrix_mod
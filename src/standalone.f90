program standalone
use global
use distancematrix_mod
implicit none

interface
    subroutine write_matrix(a)
        use global
        implicit none
        real(dp) :: a(:,:)
    end subroutine write_matrix
end interface

real(dp) :: dsites(4,2), cntrs(2,3)
real(dp), allocatable :: dmat(:,:)

dsites = reshape([1.0_dp, 2.0_dp, 3.0_dp, 4.0_dp, 1.0_dp, 2.0_dp, 3.0_dp, 4.0_dp], [4,2])
cntrs = reshape([1.0_dp, 3.0_dp, 2.0_dp, 2.0_dp, 3.0_dp, 1.0_dp], [2,3])

call write_matrix(dsites)
write(*,*)
call write_matrix(cntrs)
write(*,*)

dmat = distancematrix(dsites, cntrs)

call write_matrix(dmat)

deallocate(dmat)

end program standalone

subroutine write_matrix(a)
    use global
    implicit none
    real(dp) :: a(:,:)
    integer :: i, j
    do i = 1, size(a,1)
        write(*,*) (a(i,j), j = 1, size(a,2))
    end do
end subroutine write_matrix
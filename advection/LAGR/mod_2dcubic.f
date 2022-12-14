c Module that contains the subroutines required for spatial 2D cubic interpolation

      module MOD_2Dcubic

      contains

c --------------------------------------------------------------------

c subroutine that calculates cubic polynomial coefficients based on interpolation point location
c using the snapshot of the streamfunction
c returns ii x jj variables that stores the coefficients for each block for
c the streamfunction defined along constant y values

      subroutine cubic_coeff_x(ii,jj,psi,a,b,c,d)


      implicit none

      integer ii,jj,i,j,n,ic(4)
      real*8 psi(ii,jj)
     &  ,a(ii,jj),b(ii,jj)
     & ,c(ii,jj),d(ii,jj)



        do i = 1,ii
        ! i denotes the grid point to the left of the interpolation point in x
        do j = 1,jj
        ! j denotes the grid point above the interpolation point in y

        ! determine the 4 data points used to calculate the cubic polynomial

            do n = 1,4
                if (i.eq.1) then
                  ic(n) = i - 2 + n + 1
                elseif (i.eq.ii-1.or.i.eq.ii) then
                  ic(n) = ii-1 - 2 + n - 1
                else
                  ic(n) = i - 2 + n
                endif
            enddo

c MODIFIED THIS
c            do n = 1,4
c                ic(n) = i - 2 + n
c		        if (ic(n) <= 0) then
c		        ic(n) = ii + ic(n)
c		        elseif (ic(n) > ii) then
c		        ic(n) = ic(n) - ii
c		        endif
c            enddo

            ! constructing coefficients for the 4 1-D polynomials defined on the grid lines
            ! j =jc(1), jc(2), jc(3), jc(4)

                a(i,j) = psi(ic(2),j)
                b(i,j)= -psi(ic(1),j)/3 - psi(ic(2),j)/2
     &            +psi(ic(3),j) - psi(ic(4),j)/6
                c(i,j) = psi(ic(1),j)/2 - psi(ic(2),j)
     &            + psi(ic(3),j)/2
                d(i,j) = -psi(ic(1),j)/6 + psi(ic(2),j)/2
     &            -psi(ic(3),j)/2 + psi(ic(4),j)/6



        enddo
        enddo
        end subroutine

c ---------------------------------------------------------------------------------------
c ---------------------------------------------------------------------------------------

c subroutine that takes the grid ii x jj, the snap shot streamfunction and the x coordinate of the
c interpolation point and returns the cubic polynomials approximated along x across the whole
c y direction in all possible locations of the y coordinate of the interpolation point
c takes a,b,c,d from the previous subroutine as input (it avoids having to continuously recalculate the coefficients)

        subroutine cubic_poly_x(ii,jj,x,y,a,b,c,d,psi_interp_x)

        implicit none

        integer ii,jj,i,j,xc,jc(4),yc
        real*8 x, psi_interp_x(4),ax,y
        real*8 a(ii,jj),b(ii,jj)
     & ,c(ii,jj),d(ii,jj)

        xc = int(x) + 1 ! determines the grid point to the left of the interpolation point

        if (int(x).eq.0) then
          ax = x - (int(x)+1)
        elseif (int(x).eq.ii-2) then         !int(x) is never ii?
          ax = x - (int(x)-1)
        else
        ax = x - int(x) !x-x_i
        endif

        yc = int(y) + 1

c MODIFIED THIS
c        xc = int(x) + 1 ! determines the grid point to the left of the interpolation point

c        ax = x - int(x) !x-x_i

c        yc = int(y) + 1

        do i = 1,4
            if (yc.eq.1) then
              jc(i) = yc - 2 + i + 1
            elseif (yc.eq.jj-1) then
              jc(i) = yc - 2 + i - 1
            else
              jc(i) = yc - 2 + i
            endif
        enddo

c MODIFIED THIS
c        do i = 1,4
c            if (jc(i)>jj) then
c            jc(i) = jc(i) - jj
c            endif
c            if(jc(i)<=0) then
c             jc(i) = jc(i) + jj
c            endif
c        enddo

        !print*, xc,jc


        do i = 1,4
            psi_interp_x(i) = a(xc,jc(i)) + b(xc,jc(i))*ax    !don't think this needs changing
     &       + c(xc,jc(i))*ax**2
     & + d(xc,jc(i))*ax**3
        enddo

        return

        end subroutine


c ----------------------------------------------------------------------------------------
c ----------------------------------------------------------------------------------------

c subroutine that takes the grid size, psi_x from previous subroutine and the x coordinate of the
c interpolation point and constructs the coefficients for the cubic polynomial
c that approximates the streamfunction on the line x.

        subroutine cubic_coeff_y(ii,jj,psi_x,alpha,beta,gamma,delta)

        implicit none

        integer ii,jj,i,j,n,jc(4)
        real*8 psi_x(4)
     &        ,alpha,beta,gamma,delta



            alpha = psi_x(2)

            beta = - psi_x(1)/3 - psi_x(2)/2 + psi_x(3)
     &            -psi_x(4)/6

            gamma = psi_x(1)/2 - psi_x(2) + psi_x(3)/2

            delta = - psi_x(1)/6 + psi_x(2)/2
     &             - psi_x(3)/2 + psi_x(4)/6



        return

        end subroutine

c --------------------------------------------------------------------------------------
c --------------------------------------------------------------------------------------

c subroutine that returns the value of psi approximated at the interpolation point (x,y) called psi_interp

        subroutine cubic_interp(ii,jj,psi_x,y,psi_interp)

        implicit none

        integer ii,jj,yc
        real*8 psi_x(4),x,y,psi_interp,ay
        real*8 alpha,beta,gamma,delta

c        ay = y - int(y)

        if (int(y).eq.0) then
          ay = y - (int(y)+1)
        elseif (int(y).eq.jj-2) then         !int(y) is never jj-1 (same as above)?
          ay = y - (int(y)-1)
        else
        ay = y - int(y)
        endif

        yc = int(y) + 1

        call cubic_coeff_y(ii,jj,psi_x,alpha,beta,gamma,delta)

        psi_interp = alpha + beta*ay + gamma*ay**2
     &    + delta*ay**3

        return

        end subroutine

c -----------------------------------------------------------------------------------------------
c -----------------------------------------------------------------------------------------------

c subroutine that returns the velocities given the coefficients

        subroutine vel(ii,jj,psi_x,a,b,c,d,x,y,u,v) !add a,b,c,d as input when incorporating in final code

        implicit none

        integer ii,jj,yc,xc,jc(4),i
        real*8 x,y,u,v,psi_x(4),ay,ax
        real*8 a(ii,jj),b(ii,jj)
     &        ,c(ii,jj),d(ii,jj)
        real*8 alpha,beta,gamma,delta
        real*8 d_alpha,d_beta,d_gamma,d_delta

        !call cubic_coeff_x(ii,jj,psi,a,b,c,d) ! put outside subroutine i.e in main function at beginning

        !call cubic_poly_x(ii,jj,psi,x,a,b,c,d,psi_x)


        call cubic_coeff_y(ii,jj,psi_x,alpha,beta,gamma,delta)



        yc = int(y) + 1

c        ay = y - int(y)
        if (int(y).eq.0) then
          ay = y - (int(y)+1)
        elseif (int(y).eq.jj-2) then         !int(y) is never jj-1 (same as above)?
          ay = y - (int(y)-1)
        else
          ay = y - int(y)
        endif

        xc = int(x) + 1

c        ax = x - int(x)
        if (int(x).eq.0) then
          ax = x - (int(x)+1)
        elseif (int(x).eq.ii-2) then         !int(x) is never ii-1?
          ax = x - (int(x)-1)
        else
        ax = x - int(x) !x-x_i
        endif

        do i = 1,4
            if (yc.eq.1) then
              jc(i) = yc - 2 + i + 1
            elseif (yc.eq.jj-1) then
              jc(i) = yc - 2 + i - 1
            else
              jc(i) = yc - 2 + i
            endif
        enddo

c MODIFIED THIS
c        do i = 1,4
c            jc(i) = yc - 2 + i
c            if (jc(i) <= 0) then
c            jc(i) = jj + jc(i)
c            elseif (jc(i) > jj) then
c            jc(i) = jc(i) - jj
c            endif
c        enddo




        u = -(beta + 2*gamma*ay + 3*delta*ay**2)

        d_alpha = b(xc,jc(2)) + 2*c(xc,jc(2))*ax + 3*d(xc,jc(2))*ax**2

        d_beta = (-b(xc,jc(1))/3 - b(xc,jc(2))/2
     &    + b(xc,jc(3))-b(xc,jc(4))/6)
     & + 2*(-c(xc,jc(1))/3 - c(xc,jc(2))/2
     & + c(xc,jc(3)) - c(xc,jc(4))/6)*ax
     & + 3*(-d(xc,jc(1))/3 - d(xc,jc(2))/2
     & + d(xc,jc(3)) - d(xc,jc(4))/6)*ax**2

        d_gamma = (b(xc,jc(1))/2 - b(xc,jc(2)) + b(xc,jc(3))/2)
     & + 2*(c(xc,jc(1))/2 - c(xc,jc(2)) + c(xc,jc(3))/2)*ax
     & + 3*(d(xc,jc(1))/2 - d(xc,jc(2)) + d(xc,jc(3))/2)*ax**2

        d_delta = (-b(xc,jc(1))/6 + b(xc,jc(2))/2
     &   - b(xc,jc(3))/2 + b(xc,jc(4))/6)
     & + 2*(-c(xc,jc(1))/6 + c(xc,jc(2))/2
     & - c(xc,jc(3))/2 + c(xc,jc(4))/6)*ax
     & + 3*(-d(xc,jc(1))/6 + d(xc,jc(2))/2
     & - d(xc,jc(3))/2 + d(xc,jc(4))/6)*ax**2


        v = (d_alpha + ay*d_beta + d_gamma*ay**2 + d_delta*ay**3)

        return

        end subroutine

      end module MOD_2Dcubic

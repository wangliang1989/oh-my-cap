      program mtdcmp
c Decompose a moment tensor into ISO, DC, and CLVD tensors,
c calculate their percentages as well as the ISO and CLVD parameters.
c
      implicit none
c
      character*120 line
      real*4 m0,mxx,mxy,mxz,myy,myz,mzz
      real*8 mt(3,3),d(3),v(3,3),miso(3,3),mdc(3,3),mclvd(3,3)
      real*8 dev,clvd,iso
c
50    write(0,*)'input M0,Mxx,Mxy,Mxz,Myy,Myz,Mzz. if the tensor is in sph. coord., use Mtt,-Mtp,Mrt,Mpp,-Mrp,Mrr'
      read(*, '(a120)', END=100) line
      read(line,*) m0,mxx,mxy,mxz,myy,myz,mzz
      mt(1,1)=m0*mxx
      mt(1,2)=m0*mxy
      mt(1,3)=m0*mxz
      mt(2,1)=mt(1,2)
      mt(2,2)=m0*myy
      mt(2,3)=m0*myz
      mt(3,1)=mt(1,3)
      mt(3,2)=mt(2,3)
      mt(3,3)=m0*mzz
c
      call decompose(mt,d,v,miso,mdc,mclvd,m0,dev,clvd,iso)
c
c
      goto 50

100   stop
      end


      subroutine decompose(mt,d,v,miso,mdc,mclvd,m0,dev,clvd,iso)
c
c ...... decompose moment tensor into various representations
c
c     input parameters -
c         mt - components of moment tensor (x=N,y=E,z=Donw)
c     
c     output parameters -
c         d       - eigenvalues
c         v       - principal eigenvectors
c         miso    - isotropic moment tensor
c         mdc     - double-couple moment tensor
c         mclvd   - compensated linear vector dipole moment tensor
c         m0      - scalar seismic moment
c         iso     - isotropic source strength (zeta)
c         dev     - deviatoric source strength (1-iso*iso)
c         clvd    - CLVD source strength (chi)
c  
      implicit none
      integer*4 i,j,nrot
      real*8 mt(3,3),d(3),v(3,3),miso(3,3),mdc(3,3),mclvd(3,3),a(3,3)
      real*8 a1a1(3,3),a2a2(3,3),a3a3(3,3)
      real*8 m0,dev,clvd,iso,trace,tr3,c
c
      m0 = 0.d0
      do i=1,3
         do j=1,3
            a(i,j)=mt(i,j)
            m0 = m0 + a(i,j)*a(i,j)
         enddo
      enddo
      m0 = sqrt(m0/2.d0)
c ISO
      trace = a(1,1)+a(2,2)+a(3,3)
      iso = trace/m0/dsqrt(6.d0)
      dev = 1.d0-iso*iso
      tr3 = trace/3.d0
      do i=1,3
         do j=1,3
            if(i.eq.j) then
              miso(i,j)=tr3
            else
              miso(i,j)=0.d0
            endif
         enddo
      enddo
c the deviatoric tensor
      do i=1,3
         a(i,i)=a(i,i)-tr3
      enddo
c decompose it into a double couple and a CLVD
      call jacobi(a,3,3,d,v,nrot)
      call eigsrt(d,v,3,3)
c DC
      c=0.5d0*(d(3)-d(1))
      call dyadic(v,3,3,c,3,3,a3a3)
      c=-c
      call dyadic(v,1,1,c,3,3,a1a1)
      call matsum(a3a3,a1a1,3,3,mdc)
c CLVD
      c=-0.5d0*d(2)
      call dyadic(v,3,3,c,3,3,a3a3)
      call dyadic(v,1,1,c,3,3,a1a1)
      call matsum(a3a3,a1a1,3,3,mclvd)
      c=d(2)
      call dyadic(v,2,2,c,3,3,a2a2)
      call matsum(mclvd,a2a2,3,3,mclvd)
      clvd = dsqrt(1.5d0/(d(1)*d(1)+d(2)*d(2)+d(3)*d(3)))*d(2)
c output
      call fps_gen(mt,d,v,miso,mdc,mclvd,m0,dev,clvd,iso)
      return
      end


      subroutine fps_gen(mt,d,v,miso,mdc,mclvd,m0,dev,clvd,iso)
c
c ...... generate printer plot rendition of lower hemisphere 
c        equal area projection
c
      implicit none
      integer iexpon,i,j,ix0,iy0,ixp,iyp,ixt,iyt
      real*4 r0,x0,y0,dx,dy,dd,del,aoi,theta,asclf,polar
      real*8 mt(3,3),d(3),v(3,3),miso(3,3),mdc(3,3),mclvd(3,3),m0,dev,clvd,iso
      real*8 plunge(3),azimuth(3),strike(2),dip(2),slip(2)
      real*8 pi,pi2,piOv2,r2d,arg,argmax
      parameter(pi=3.1415926535897932385,pi2=6.2831853071795864770,piOv2=1.5707963267948966192,r2d=57.295779513082320875)
      character*1 ach(39,72),aplus,aminus,apaxis,ataxis,ablank
      data aplus,aminus,apaxis,ataxis,ablank /'#','-','P','T',' '/
c
c
      argmax=dabs(mt(1,1))
      do i=1,3
         do j=1,3
            if(dabs(mt(i,j)).gt.argmax) argmax=dabs(mt(i,j))
         enddo
      enddo
      iexpon=0
   23 iexpon=iexpon+1
      arg=10.**(iexpon)
      if(arg.le.argmax) go to 23
      asclf=10.**(iexpon-1)
c
      write(*,'(1h ,a,i02,a)') 'Moment Tensor: Scale = 1.E',
     1                         iexpon-1, ' Dyne-cm'
      write(*,'(1h ,a)') '   Component    ALL     ISO      DC       CLVD     zeta      chi'
      write(*,'(1h ,6x,a,2x,6f9.3)')'Pct',100.,100*iso**2,100*dev*(1-clvd**2), 100*dev*clvd**2,iso,clvd
      write(*,'(1h ,6x,a,2x,4f9.3)')'Mxx',sngl(mt(1,1))/asclf,sngl(miso(1,1))/asclf,sngl(mdc(1,1))/asclf,sngl(mclvd(1,1))/asclf
      write(*,'(1h ,6x,a,2x,4f9.3)')'Mxy',sngl(mt(1,2))/asclf,sngl(miso(1,2))/asclf,sngl(mdc(1,2))/asclf,sngl(mclvd(1,2))/asclf
      write(*,'(1h ,6x,a,2x,4f9.3)')'Mxz',sngl(mt(1,3))/asclf,sngl(miso(1,3))/asclf,sngl(mdc(1,3))/asclf,sngl(mclvd(1,3))/asclf
      write(*,'(1h ,6x,a,2x,4f9.3)')'Myy',sngl(mt(2,2))/asclf,sngl(miso(2,2))/asclf,sngl(mdc(2,2))/asclf,sngl(mclvd(2,2))/asclf
      write(*,'(1h ,6x,a,2x,4f9.3)')'Myz',sngl(mt(2,3))/asclf,sngl(miso(2,3))/asclf,sngl(mdc(2,3))/asclf,sngl(mclvd(2,3))/asclf
      write(*,'(1h ,6x,a,2x,4f9.3)')'Mzz',sngl(mt(3,3))/asclf,sngl(miso(3,3))/asclf,sngl(mdc(3,3))/asclf,sngl(mclvd(3,3))/asclf
      write(*,'(1h ,a,1pe8.2,a)') '   Mo = ',m0,' Dyne-cm'
      write(*,'(1h ,a,f5.2)') '   Mw = ', (dlog10(m0)-16.1d0)/1.5d0
      write(*,'(1h )')
c
      call plaz(v,plunge,azimuth)
      write(*,'(1h ,a)')      'Principle Axes:'
      write(*,'(1h ,a)')      '   Axis    Value   Plunge   Azimuth'
      write(*,'(1h ,5x,"T",3x,f7.3,6x,i2,6x,i3)') d(3)/asclf,
     1          nint(plunge(3)*r2d),nint(azimuth(3)*r2d)
      write(*,'(1h ,5x,"N",3x,f7.3,6x,i2,6x,i3)') d(2)/asclf,
     1          nint(plunge(2)*r2d),nint(azimuth(2)*r2d)
      write(*,'(1h ,5x,"P",3x,f7.3,6x,i2,6x,i3)') d(1)/asclf,
     1          nint(plunge(1)*r2d),nint(azimuth(1)*r2d)
      write(*,'(1h )')
c
      call fpsol(v,strike,dip,slip) 
      write(*,'(1h ,a)') 'Best Fitting Double-Couple:'
      write(*,'(1h ,a)')      '   Plane   Strike   Rake   Dip'
      write(*,'(1h ,4x,"NP1",5x,i4,4x,i4,4x,i2)') nint(strike(1)*r2d),
     1          nint(slip(1)*r2d),nint(dip(1)*r2d)
      write(*,'(1h ,4x,"NP2",5x,i4,4x,i4,4x,i2)') nint(strike(2)*r2d),
     1          nint(slip(2)*r2d),nint(dip(2)*r2d)
      write(*,'(1h )')
c
c ...... construct lower hemisphere fps 
c
      r0=1.72
      x0=r0+0.250
      y0=r0+0.500
      ix0=12.*x0
      iy0=6.5*y0
      do 3 i=1,2*ix0
      do 2 j=1,2*iy0
      dx=real(i-ix0)/12.
      dy=-real(j-iy0)/6.5
      dd=dx*dx+dy*dy
      if(dd.gt.0.) then
        del=sqrt(dd)
      else
        del=0.
      endif
      if((dx.eq.0.).and.(dy.eq.0.)) then
        theta=0.
      else
        theta=atan2(dx,dy)
      endif
      if(del.gt.r0) then
        ach(j,i)=ablank
        go to 1
      endif
      if(del.ge.r0) then
        aoi=piOv2
      else
        aoi=piOv2*del/r0
      endif
      if(polar(mt,aoi,theta).gt.0.) then
        ach(j,i)=aplus
      else
        ach(j,i)=aminus
      endif
    1 continue
    2 continue
    3 continue
c
c ...... add P & T axis
c
      ixp=nint(r0*12.*(piOv2-plunge(1))*sin(azimuth(1))/piOv2+real(ix0))
      iyp=nint(-r0*6.5*(piOv2-plunge(1))*cos(azimuth(1))/piOv2+real(iy0))
      do 5 i=ixp-1,ixp+1
      do 4 j=iyp-1,iyp+1
      ach(j,i)=ablank
    4 continue
    5 continue
      ach(iyp,ixp)=apaxis
      ixt=nint(r0*12.*(piOv2-plunge(3))*sin(azimuth(3))/piOv2+real(ix0))
      iyt=nint(-r0*6.5*(piOv2-plunge(3))*cos(azimuth(3))/piOv2+real(iy0))
      do 7 i=ixt-1,ixt+1
      do 6 j=iyt-1,iyt+1
      ach(j,i)=ablank
    6 continue
    7 continue
      ach(iyt,ixt)=ataxis
c
c ...... add fps plot
c
      do 8 i=1,2*iy0-2
      write(*,'(1h ,72a1)') (ach(i,j),j=1,2*ix0)
    8 continue
c 
c ...... add projection info
c
      write(*,'(1h ,a)') '    Lower Hemisphere Equiangle Projection'
      write(*,'(1h )')
c
      return
      end

      real*4 function polar(mt,aoi,theta)
c
c ...... compute first motion polarity as a function of aoi & theta
c        for an arbitrary moment tensor
c
      implicit none
      real*8 mt(3,3)
      real*4 aoi,theta,fa,fb
c
      fa = cos(theta)*cos(theta)*mt(1,1) +
     1     2.*sin(theta)*cos(theta)*mt(1,2) +
     2     sin(theta)*sin(theta)*mt(2,2) -
     3     mt(3,3)
      fb = cos(theta)*mt(1,3) + sin(theta)*mt(2,3)
c
      polar = sin(aoi)*sin(aoi)*fa + 
     1        2.*sin(aoi)*cos(aoi)*fb +
     2        mt(3,3)
c
      return
      end


      subroutine fpsol(v,strike,dip,slip)
c
c ...... calculate strike, dip & slip of fault planes
c        from the P & T vectors
c
      implicit real*8 (a-h,o-z)
      implicit integer*4 (i-n)
      real*8 pi,pi2,piOv2
      parameter(pi=3.1415926535897932385,pi2=6.2831853071795864770,piOv2=1.5707963267948966192)
      real*8 v(3,3),p(3),t(3),strike(2),dip(2),slip(2)
      real*8 u(2,3),nu(2,3),lambda
      integer*4 idarg(2)
      con=1.d0/dsqrt(2.d0)
      do i=1,3
      p(i) = v(i,1)
      t(i) = v(i,3)
      u(1,i)=con*(t(i)+p(i))
      nu(1,i)=con*(t(i)-p(i))
      u(2,i)=con*(t(i)-p(i))
      nu(2,i)=con*(t(i)+p(i))
      enddo
      idarg(1)=0
      idarg(2)=0      
      do i=1,2
      dip(i)=dacos(-nu(i,3))
      if((nu(i,1).eq.0.d0).and.(nu(i,2).eq.0.d0)) then
        strike(i)=0.d0
      else
        strike(i)=datan2(-nu(i,1),nu(i,2))
      endif
      enddo
      do i=1,2
      sstr=dsin(strike(i))
      cstr=dcos(strike(i))
      sdip=dsin(dip(i))
      cdip=dcos(dip(i))
      if(dabs(sdip).gt.0.d0) then
        lambda=dasin(-u(i,3)/dsin(dip(i)))
      else
        arg1=1.d0
        arg2=u(i,3)
        arg=dsign(arg1,arg2)
        if(arg.lt.0.d0) then
          lambda=pi
        else
          lambda=0.d0
        endif
      endif
      slambda=dsin(lambda)
      cdsl=cdip*slambda
      if(dabs(sstr).gt.dabs(cstr)) then
        clambda=(u(i,2)+cdsl*cstr)/sstr
      else
        clambda=(u(i,1)-cdsl*sstr)/cstr
      endif
      if((slambda.eq.0.d0).and.(clambda.eq.0.d0)) then
        slip(i)=0.d0
      else
        slip(i)=datan2(slambda,clambda)
      endif
      if(dip(i).gt.piOv2) then
        dip(i)=pi-dip(i)
        strike(i)=strike(i)+pi
        slip(i)=pi2-slip(i)
      endif
      if(strike(i).lt.0.d0) strike(i)=strike(i)+pi2
      if(slip(i).ge.pi) slip(i)=slip(i)-pi2
      enddo
      return
      end


      subroutine plaz(v,plunge,azimuth)
c
c ...... calculate plunge & azimuth of eigenvectors
c        in radians
c
      implicit none
      integer i
      real*8 pi,pi2,piOv2
      parameter(pi=3.1415926535897932385,pi2=6.2831853071795864770,piOv2=1.5707963267948966192)
      real*8 v(3,3),plunge(3),azimuth(3),r
      do i=1,3
      if(v(3,i).lt.0.) then
	v(1,i)=-v(1,i)
	v(2,i)=-v(2,i)
	v(3,i)=-v(3,i)
      endif
      enddo
      do i=1,3
      if((v(2,i).eq.0.d0).and.(v(1,i).eq.0.d0)) then
        azimuth(i)=0.d0
      else
        azimuth(i)=datan2(v(2,i),v(1,i))
      endif
      if(azimuth(i).lt.0.) azimuth(i)=azimuth(i)+pi2
      r=dsqrt(v(1,i)*v(1,i)+v(2,i)*v(2,i))
      if((v(3,i).eq.0.d0).and.(r.eq.0.d0)) then
        plunge(i)=0.d0
      else
        plunge(i)=datan2(v(3,i),r)
      endif
      enddo
      return
      end


      subroutine dyadic(v,n1,n2,c,n,np,d)
c
c ...... calculate dyadic of eigenvectors v(i,n1)*v(j,n2)
c        scaled by c
c
      implicit none
      integer n1,n2,n,np,i,j
      real*8 v(np,np),d(np,np),c
      do i=1,n
      do j=1,n
      d(i,j)=v(i,n1)*v(j,n2)*c
      enddo
      enddo
      return
      end


      subroutine matsum(a,b,n,np,c)
c
c ...... calculate matrix sum c = a + b
c
      implicit none
      integer n, np,i,j
      real*8 a(np,np),b(np,np),c(np,np)
      do i=1,n
      do j=1,n
      c(i,j)=a(i,j)+b(i,j)
      enddo
      enddo
      return
      end


      subroutine jacobi(a,n,np,d,v,nrot)
c
c ...... Computes all eigenvalues and eigenvectors of a real 
c        symmetric matrix A, which is of size N by N, stored
c        in a physical np by np array.  On output, elements
c        of A above the diagonal are destroyed.  D returns
c        the eigenvalues of A in its first N elements.  V is
c        a matrix with the same logical and physical dimensions
c        as A whose columns contain, on output, the normalized
c        eigenvectors of A.  NROT returns the number of Jacobi
c        rotations which were required.
c
      implicit real*8 (a-h,o-z)
      implicit integer*4 (i-n)
      integer n,np,nrot,nmax,ip,i
      parameter (nmax=100)
      real*8 a(np,np),d(np),v(np,np),b(nmax),z(nmax)
      do 12 ip=1,n
        do 11 iq=1,n
          v(ip,iq)=0.d0
   11   continue
        v(ip,ip)=1.d0
   12 continue
      do 13 ip=1,n
        b(ip)=a(ip,ip)
        d(ip)=b(ip)
        z(ip)=0.d0
   13 continue
      nrot=0
      do 24 i=1,500
        sm=0.d0
        do 15 ip=1,n-1
          do 14 iq=ip+1,n
            sm=sm+dabs(a(ip,iq))
   14     continue
   15   continue
        if(sm.eq.0.d0) return
        if(i.lt.1) then
          thresh=0.2d0*sm/dble(n**2)
        else
          thresh=0.d0
        endif
        do 22 ip=1,n-1
          do 21 iq=ip+1,n
            g=100.d0*dabs(a(ip,iq))
            if((i.gt.4).and.(dabs(d(ip))+g.eq.dabs(d(ip)))
     1        .and.(dabs(d(iq))+g.eq.dabs(d(iq)))) then
              a(ip,iq)=0.d0
            elseif(dabs(a(ip,iq)).gt.thresh) then
              h=d(iq)-d(ip)
              if(dabs(h)+g.eq.dabs(h)) then
                t=a(ip,iq)/h
              else
                theta=0.5d0*h/a(ip,iq)
                t=1.d0/(dabs(theta)+dsqrt(1.d0+theta**2))
                if(theta.lt.0.d0) t=-t
              endif
              c=1.d0/dsqrt(1.d0+t**2)
              s=t*c
              tau=s/(1.d0+c)
              h=t*a(ip,iq)
              z(ip)=z(ip)-h
              z(iq)=z(iq)+h
              d(ip)=d(ip)-h
              d(iq)=d(iq)+h
              a(ip,iq)=0.d0
              do 16 j=1,ip-1
                g=a(j,ip)
                h=a(j,iq)
                a(j,ip)=g-s*(h+g*tau)
                a(j,iq)=h+s*(g-h*tau)
   16         continue
              do 17 j=ip+1,iq-1
                g=a(ip,j)
                h=a(j,iq)
                a(ip,j)=g-s*(h+g*tau)
                a(j,iq)=h+s*(g-h*tau)
   17         continue
              do 18 j=iq+1,n
                g=a(ip,j)
                h=a(iq,j)
                a(ip,j)=g-s*(h+g*tau)
                a(iq,j)=h+s*(g-h*tau)
   18         continue
              do 19 j=1,n
                g=v(j,ip)
                h=v(j,iq)
                v(j,ip)=g-s*(h+g*tau)
                v(j,iq)=h+s*(g-h*tau)
   19         continue
            nrot=nrot+1
            endif
   21     continue
   22   continue
        do 23 ip=1,n
          b(ip)=b(ip)+z(ip)
          d(ip)=b(ip)
          z(ip)=0.d0
   23   continue
   24 continue
      return
      end
      

      subroutine eigsrt(d,v,n,np)
c
c ...... Given the eigenvalues D and eigenvectors V as output from
c        JACOBI, this routine sorts the eigenvalues into increasing
c        order and rearranges the columns of V 
c        correspondingly.  The mothod is straight insertion.
c
      implicit none
      integer*4 i,j,k,n,np
      real*8 d(np),v(np,np),p
      do i=1,n-1
        k=i
        p=d(i)
        do j=i+1,n
          if(d(j).lt.p) then
            k=j
            p=d(j)
          endif
	enddo
        if(k.ne.i) then
          d(k)=d(i)
          d(i)=p
          do j=1,n
            p=v(j,i)
            v(j,i)=v(j,k)
            v(j,k)=p
	  enddo
        endif
      enddo
      return
      end

      SUBROUTINE H_PHYSICS(ABORT,err)
*--------------------------------------------------------
*-
*-   Purpose and Methods : Do final HMS physics analysis on HMS only part of
*-                            event.
*-                              
*-                                to decoded information 
*-
*-      Required Input BANKS     HMS_FOCAL_PLANE
*-                               HMS_TARGET
*-                               HMS_TRACK_TESTS
*-
*-      Output BANKS             HMS_PHYSICS_R4
*-                               HMS_PHYSICS_I4
*-
*-   Output: ABORT           - success or failure
*-         : err             - reason for failure, if any
*- 
*-   Created 19-JAN-1994   D. F. Geesaman
*-                           Dummy Shell routine
* $Log$
* Revision 1.18  1996/08/30 19:59:36  saw
* (JRA) Improved track length calculation.  Photon E calc. for (gamma,p)
*
* Revision 1.17  1996/04/30 12:46:06  saw
* (JRA) Add pathlength and rf calculations
*
* Revision 1.16  1996/01/24 15:58:38  saw
* (JRA) Change cpbeam/cebeam to gpbeam/gebeam
*
* Revision 1.15  1996/01/16 21:55:02  cdaq
* (JRA) Calculate q, W for electrons
*
* Revision 1.14  1995/10/09 20:22:15  cdaq
* (JRA) Add call to h_dump_cal, change upper to lower case
*
* Revision 1.13  1995/08/31 14:49:03  cdaq
* (JRA) Add projection to cerenkov mirror pos, fill hdc_sing_res array
*
* Revision 1.12  1995/07/19  20:53:26  cdaq
* (SAW) Declare sind and tand for f2c compatibility
*
* Revision 1.11  1995/05/22  19:39:15  cdaq
* (SAW) Split gen_data_data_structures into gen, hms, sos, and coin parts"
*
* Revision 1.10  1995/05/11  17:15:07  cdaq
* (SAW) Add additional kinematics variables
*
* Revision 1.9  1995/03/22  16:23:27  cdaq
* (SAW) Target track data is now slopes.
*
* Revision 1.8  1995/02/23  13:37:31  cdaq
* (SAW) Reformat and cleanup
*
* Revision 1.7  1995/02/10  18:44:47  cdaq
* (SAW) _tar values are now angles instead of slopes
*
* Revision 1.6  1995/02/02  13:05:40  cdaq
* (SAW) Moved best track selection code into H_SELECT_BEST_TRACK (new)
*
* Revision 1.5  1995/01/27  20:24:14  cdaq
* (JRA) Add some useful physics quantities
*
* Revision 1.4  1995/01/18  16:29:26  cdaq
* (SAW) Correct some trig and check for negative arg in elastic kin calculation
*
* Revision 1.3  1994/09/13  19:51:03  cdaq
* (JRA) Add HBETA_CHISQ
*
* Revision 1.2  1994/06/14  03:49:49  cdaq
* (DFG) Calculate physics quantities
*
* Revision 1.1  1994/02/19  06:16:08  cdaq
* Initial revision
*
*-
*-
*--------------------------------------------------------
      IMPLICIT NONE
      SAVE
*
      character*9 here
      parameter (here= 'H_PHYSICS')
*
      logical ABORT
      character*(*) err
      integer ierr
*
      include 'gen_data_structures.cmn'
      INCLUDE 'hms_data_structures.cmn'
      INCLUDE 'gen_routines.dec'
      INCLUDE 'gen_constants.par'
      INCLUDE 'gen_units.par'
      INCLUDE 'hms_physics_sing.cmn'
      INCLUDE 'hms_calorimeter.cmn'
      INCLUDE 'hms_scin_parms.cmn'
      INCLUDE 'hms_tracking.cmn'
      INCLUDE 'hms_cer_parms.cmn'
      INCLUDE 'hms_geometry.cmn'
      INCLUDE 'hms_id_histid.cmn'
      INCLUDE 'hms_track_histid.cmn'
      include 'gen_event_info.cmn'
      include 'hms_scin_tof.cmn'
*
*     local variables 
      integer*4 i,ip,ihit
      integer*4 itrkfp
      real*4 cosgamma,tandelphi,sinhphi,coshstheta,sinhstheta
      real*4 t1,ta,p3,t3,hminv2
      real*4 coshsthetaq
      real*4 sind,tand                  ! For f2c
      real*4 p_nonzero
      real*4 xdist,ydist,dist(12),res(12)
      real*4 tmp,W2
      real*4 denom
*
*--------------------------------------------------------
*
      ierr=0
      hphi_lab=0.0
      if(hsnum_fptrack.gt.0) then       ! Good track has been selected
        itrkfp=hsnum_fptrack
        hsp = hp_tar(hsnum_tartrack)
        hsenergy = sqrt(hsp*hsp+hpartmass*hpartmass)
*     Copy variables for ntuple so we can test on them
        hsdelta  = hdelta_tar(hsnum_tartrack)
        hsx_tar  = hx_tar(hsnum_tartrack)
        hsy_tar  = hy_tar(hsnum_tartrack)
        hsxp_tar  = hxp_tar(hsnum_tartrack) ! This is an angle (radians)
        hsyp_tar  = hyp_tar(hsnum_tartrack) ! This is an angle (radians)
        hsbeta   = hbeta(itrkfp)
        hsbeta_chisq = hbeta_chisq(itrkfp)
        hstime_at_fp   = htime_at_fp(itrkfp)

        hstrack_et   = htrack_et(itrkfp)
        hstrack_preshower_e   = htrack_preshower_e(itrkfp)
        p_nonzero = max(.0001,hsp)      !momentum (used to normalize calorim.)
        hscal_suma = hcal_e1/p_nonzero  !normalized cal. plane sums
        hscal_sumb = hcal_e2/p_nonzero
        hscal_sumc = hcal_e3/p_nonzero
        hscal_sumd = hcal_e4/p_nonzero
        hsprsum = hscal_suma
        hsshsum = hcal_et/p_nonzero
        hsprtrk = hstrack_preshower_e/p_nonzero
        hsshtrk = hstrack_et/p_nonzero

        hsx_sp1 = hx_sp1(itrkfp)
        hsy_sp1 = hy_sp1(itrkfp)
        hsxp_sp1= hxp_sp1(itrkfp)
        hsx_sp2 = hx_sp2(itrkfp)
        hsy_sp2 = hy_sp2(itrkfp)
        hsxp_sp2= hxp_sp2(itrkfp)

        do ihit=1,hnum_scin_hit(itrkfp)
          call hf1(hidscintimes,hscin_fptime(itrkfp,ihit),1.)
        enddo

        do ihit=1,hntrack_hits(itrkfp,1)
          call hf1(hidcuttdc,
     &       float(hdc_tdc(hntrack_hits(itrkfp,ihit+1))),1.)
        enddo

        hsx_fp   = hx_fp(itrkfp)
        hsy_fp   = hy_fp(itrkfp)
        hsxp_fp   = hxp_fp(itrkfp) ! This is a slope (dx/dz)
        hsyp_fp   = hyp_fp(itrkfp) ! This is a slope (dy/dz)
        hsx_dc1 = hsx_fp + hsxp_fp * hdc_1_zpos
        hsy_dc1 = hsy_fp + hsyp_fp * hdc_1_zpos
        hsx_dc2 = hsx_fp + hsxp_fp * hdc_2_zpos
        hsy_dc2 = hsy_fp + hsyp_fp * hdc_2_zpos
        hsx_s1 = hsx_fp + hsxp_fp * hscin_1x_zpos
        hsy_s1 = hsy_fp + hsyp_fp * hscin_1x_zpos
        hsx_cer = hsx_fp + hsxp_fp * hcer_mirror_zpos
        hsy_cer = hsy_fp + hsyp_fp * hcer_mirror_zpos
        hsx_s2 = hsx_fp + hsxp_fp * hscin_2x_zpos
        hsy_s2 = hsy_fp + hsyp_fp * hscin_2x_zpos
        hsx_cal = hsx_fp + hsxp_fp * hcal_1pr_zpos
        hsy_cal = hsy_fp + hsyp_fp * hcal_1pr_zpos

        hsbeta_p = hsp/max(hsenergy,.00001)
C old 'fit' value for pathlen correction
C        hspathlength = -1.47e-2*hsx_fp + 11.6*hsxp_fp - 36*hsxp_fp**2
C new 'modeled' value.
        hspathlength = 12.462*hsxp_fp + 0.1138*hsxp_fp*hsx_fp
     &                -0.0154*hsx_fp - 72.292*hsxp_fp**2
     &                -0.0000544*hsx_fp**2 - 116.52*hsyp_fp**2

        hspath_cor = hspathlength/hsbeta_p -
     &      hpathlength_central/speed_of_light*(1/max(.01,hsbeta_p) - 1)

        hsrftime = hmisc_dec_data(8,1)/9.46
     &           - (hstime_at_fp-hstart_time_center) - hspath_cor
        do ip=1,4
          hsscin_elem_hit(ip)=0
        enddo
        do i=1,hnum_scin_hit(itrkfp)
          ip=hscin_plane_num(hscin_hit(itrkfp,i))
          if (hsscin_elem_hit(ip).eq.0) then
            hsscin_elem_hit(ip)=hscin_counter_num(hscin_hit(
     $           itrkfp,i))
            hsdedx(ip)=hdedx(itrkfp,i)
          else                          ! more than 1 hit in plane
            hsscin_elem_hit(ip)=18
            hsdedx(ip)=sqrt(hsdedx(ip)*hdedx(itrkfp,i))
          endif
        enddo

        hsnum_scin_hit = hnum_scin_hit(itrkfp)
        hsnum_pmt_hit = hnum_pmt_hit(itrkfp)

        hschi2perdeg  = hchi2_fp(itrkfp)
     $       /float(hnfree_fp(itrkfp))
        hsnfree_fp = hnfree_fp(itrkfp)

        do ip = 1, hdc_num_planes
          hdc_sing_res(ip)=hdc_single_residual(itrkfp,ip)
          hsdc_track_coord(ip)=hdc_track_coord(itrkfp,ip)
        enddo

        if (hntrack_hits(itrkfp,1).eq.12 .and. hschi2perdeg.le.4) then
          xdist=hsx_dc1
          ydist=hsy_dc1
          do ip=1,12
            if (hdc_readout_x(ip)) then
              dist(ip) = ydist*hdc_readout_corr(ip)
            else                        !readout from top/bottom
              dist(ip) = xdist*hdc_readout_corr(ip)
            endif
            res(ip)=hdc_sing_res(ip)
            tmp = hdc_plane_wirecoord(itrkfp,ip)
     $           -hdc_plane_wirecenter(itrkfp,ip)
            if (tmp.eq.0) then          !drift dist = 0
              res(ip)=abs(res(ip))
            else
              res(ip)=res(ip) * (abs(tmp)/tmp) !convert +/- res to near/far res
            endif
          enddo
c           write(37,'(12f7.2,12f8.3,12f8.5)') (hsdc_track_coord(ip),ip=1,12),
c     &    (dist(ip),ip=1,12),(res(ip),ip=1,12)
        endif

        hstheta =htheta_lab*TT/180. - hsyp_tar
        HSP = hpcentral*(1 + hsdelta/100.)
        sinhstheta = sin(hstheta)
        coshstheta = cos(hstheta)
        tandelphi = hsxp_tar /
     &       ( sinhthetas - coshthetas*hsyp_tar)
        hsphi = hphi_lab + atan(tandelphi) ! hphi_lab MUST BE MULTIPLE OF
        sinhphi = sin(hsphi)            ! PI/2, OR ABOVE IS CRAP
        if(hpartmass .lt. 2*mass_electron) then ! Less than 1 MeV, HMS is elec
          if(gtarg_z(gtarg_num).gt.0.)then
            call total_eloss(1,.true.,gtarg_z(gtarg_num),
     $           gtarg_a(gtarg_num),gtarg_thick(gtarg_num),
     $           gtarg_dens(gtarg_num),
     $           hstheta,gtarg_theta,1.0,hseloss)
            hsenergy=hsenergy- hseloss
          else
            hseloss=0.
          endif
          hqx = -HSP*cos(HSxp_tar)*sinhstheta
          hqy = -HSP*sin(Hsxp_tar)
          hqz = gpbeam - HSP*cos(HSxp_tar)*coshstheta
          hqabs= sqrt(hqx**2+hqy**2+hqz**2)
          W2 = gtarg_mass(gtarg_num)**2 +
     $         2.*gtarg_mass(gtarg_num)*(gpbeam-hsp) - hqabs**2 +
     $         (gpbeam-hsp)**2
          if(W2.ge.0 ) then
            hinvmass = SQRT(W2)
          else
            hinvmass = 0.
          endif
        else
          if(gtarg_z(gtarg_num).gt.0.)then
            call total_eloss(1,.false.,gtarg_z(gtarg_num),
     $           gtarg_a(gtarg_num),
     $           gtarg_thick(gtarg_num),gtarg_dens(gtarg_num),
     $           hstheta,gtarg_theta,hsbeta,hseloss)
            hsenergy = hsenergy - hseloss
          else
            hseloss=0.
          endif
        endif
*     Calculate elastic scattering kinematics
        t1  = 2.*hphysicsa*gpbeam*coshstheta      
        ta  = 4*gpbeam**2*coshstheta**2 - hphysicsb**2
ccc   SAW 1/17/95.  Add the stuff after the or.
        if(ta.eq.0.0 .or. ( hphysicab2 + hphysicsm3b * ta).lt.0.0) then
          p3=0.       
        else
          t3  = ta-hphysicsb**2
          p3  = (T1 - sqrt( hphysicab2 + hphysicsm3b * ta)) / ta
        endif
*     This is the difference in the momentum obtained by tracking
*     and the momentum from elastic kinematics
        hselas_cor = hsp - P3
*     invariant mass of the remaining particles
        hminv2 =   ( (gebeam+gtarg_mass(gtarg_num)-hsenergy)**2
     &       - (gpbeam - hsp * coshstheta)**2
     &       - ( hsp * sinhstheta)**2  )       
        if(hminv2.ge.0 ) then
          hsminv = sqrt(hminv2)
        else
          hsminv = 0.
        endif                           ! end test on positive arg of SQRT
*     hszbeam is the intersection of the beam ray with the spectrometer
*     as measured along the z axis.
        if( sinhstheta .eq. 0.) then
          hszbeam = 0.
        else
          hszbeam = sinhphi * ( -hsy_tar + gbeam_y * coshstheta) /
     $         sinhstheta 
        endif                           ! end test on sinhstheta=0
*
*     More kinematics
*
        if(hsbeta.gt.0) then
          hsmass2 = (1/hsbeta**2 - 1)*hsp**2
        else
          hsmass2 = 1.0e10
        endif

        hst = (gebeam - hsenergy)**2
     $       - (gpbeam - hsp*coshstheta)**2 - (hsp*sinhstheta)**2
        hsu = (gtarg_mass(gtarg_num) - hsenergy)**2 - hsp**2
        if(hseloss.eq.0.)then
          hseloss = gebeam - hsenergy
        endif
        hsq3 = sqrt(gpbeam**2 + hsp**2 - 2*gpbeam*hsp*coshstheta)
        if(gpbeam.ne.0.and.hsq3.ne.0.)then
          coshsthetaq = (gpbeam**2 - gpbeam*hsp*coshstheta)/gpbeam/hsq3
        endif
        if(coshsthetaq.le.1.and.coshsthetaq.ge.-1.)then
          hsthetaq = acos(coshsthetaq)
        endif
        hsphiq = hsphi + tt
        hsbigq2 = -hst
        hsx = hsbigq2/(2*mass_nucleon*hseloss)
        hsy = hseloss/gebeam
        hsw2 = gtarg_mass(gtarg_num)**2 +
     $       2*gtarg_mass(gtarg_num)*hseloss - hsbigq2
        if(hsw2.ge.0.0) then
          hsw = sqrt(hsw2)
        else
          hsw = 0.0
        endif

*     Calculate photon energy in GeV (E89-012):
        denom = hphoto_mtarget - hsenergy + hsp*coshstheta
        if (abs(denom).le.1.e-10) then
           hsegamma = -1000.0
        else
           hsegamma = ( hsenergy * hphoto_mtarget
     &       - 0.5*(hphoto_mtarget**2 + hpartmass**2
     &       - hphoto_mrecoil**2) ) / denom
        endif

*     Photon energy (assuming D2 target, Proton or Deut. detected).
        denom = 1.87561 - sqrt(hsp**2 + 0.93827**2) + hsp*coshstheta
        hsegamma_p= ( sqrt(hsp**2+0.93827**2) * 1.87561
     &       - 0.5*(1.87561**2 + 0.93827**2 - 0.93957**2) )/denom

        denom = 1.87561 - sqrt(hsp**2 + 1.87561**2) + hsp*coshstheta
        hsegamma_d= ( sqrt(hsp**2+1.87561**2) * 1.87561
     &       - 0.5*(1.87561**2 + 1.87561**2 - 0.13497**2) )/denom

c------------------------------------------------------------------------

*
*     Write raw timing information for fitting.
        if(hdebugdumptof.ne.0) call h_dump_tof
        if(hdebugdumpcal.ne.0) call h_dump_cal
*
*     Calculate physics statistics and wire chamber efficencies.
        call h_physics_stat(ABORT,err)
        ABORT= ierr.ne.0 .or. ABORT
        IF(ABORT) THEN
          call G_add_path(here,err)
        ENDIF
      endif                             ! end test on zero tracks
      return
      end

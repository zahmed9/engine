      SUBROUTINE S_CAL(ABORT,err)
*--------------------------------------------------------
*-
*-   Purpose and Methods : Analyze Calorimeter information for each track 
*-
*-      Required Input BANKS     SOS_RAW_CAL
*-                               SOS_DECODED_CAL
*-                               SOS_FOCAL_PLANE
*-
*-      Output BANKS             SOS_TRACK_TESTS
*-
*-   Output: ABORT           - success or failure
*-         : err             - reason for failure, if any
*- 
*-   Created 19-JAN-1994   D. F. Geesaman
*-                           Dummy Shell routine
* $Log$
* Revision 1.8  1999/06/10 16:56:02  csa
* (JRA) Cosmetic changes
*
* Revision 1.7  1999/02/25 20:18:40  saw
* Vardan Tadevosyan shower code updates
*
* Revision 1.6  1999/02/03 21:13:44  saw
* Code for new Shower counter tubes
*
* Revision 1.5  1999/01/29 17:34:56  saw
* Add variables for second tubes on shower counter
*
* Revision 1.4  1995/05/22 19:45:31  cdaq
* (SAW) Split gen_data_data_structures into gen, hms, sos, and coin parts"
*
* Revision 1.3  1995/05/11  21:02:26  cdaq
* (JRA) Add call to s_tracks_cal
*
* Revision 1.2  1994/11/22  21:05:51  cdaq
* (SPB) Recopied from hms file and modified names for SOS
*
* Revision 1.1  1994/02/21  16:06:52  cdaq
* Initial revision
*-
*--------------------------------------------------------
      IMPLICIT NONE
      SAVE

      character*5 here
      parameter (here= 'S_CAL')

      logical ABORT
      character*(*) err

      integer*4 nt                      !Detector track number
      integer*4 nc                      !Calorimeter cluster number
      real*4    cor     !Correction factor for X,Y dependence ! Single PMT.
      real*4    cor_pos !Correction factor for X,Y dependence ! Pos
      real*4    cor_neg !Correction factor for X,Y dependence ! Neg
c      real*4    cor_two     !Correction factor for X,Y dependence ! POS+NEG
      real*4 s_correct_cal     !External function to compute "cor"
      real*4 s_correct_cal_pos !External function to compute "cor_pos"
      real*4 s_correct_cal_neg !External function to compute "cor_neg"
c      real*4 s_correct_cal_two !External function to compute "cor_two"

      include 'sos_data_structures.cmn'
      include 'sos_calorimeter.cmn'
*
*--------------------------------------------------------
*
      do nt=1, sntracks_fp
        strack_e1_pos(nt)=0.            !  Only pos_pmt for layer "A"
        strack_e1_neg(nt)=0.            !  Only_neg_pmt for layer "A"
        strack_e2_pos(nt)=0.            !  Only_pos_pmt for layer "B"  
        strack_e2_neg(nt)=0.            !  Only_neg_pmt for layer "B" 
        strack_e1(nt)=0.
        strack_e2(nt)=0.
        strack_e3(nt)=0.
        strack_e4(nt)=0.
        strack_et(nt)=0.
        strack_preshower_e(nt)=0.
      enddo

      call s_clusters_cal(abort,err)
      if(abort) then
        call g_add_path(here,err)
        return
      endif

      call s_tracks_cal(abort,err)
      if (abort) then
        call g_add_path(here,err)
        return
      endif
*
*     Return if there are no tracks found or none of the found tracks
*     matches a cluster in the calorimeter
*            
      if(sntracks_fp .le.0) go to 100   !Return
      if(sntracks_cal.le.0) go to 100   !Return

      do nt =1,sntracks_fp
        nc=scluster_track(nt)
        if(nc.gt.0) then
          cor    =s_correct_cal(strack_xc(nt),strack_yc(nt))     ! Single PMT
          cor_pos=s_correct_cal_pos(strack_xc(nt),strack_yc(nt)) ! Single pos PMT
          cor_neg=s_correct_cal_neg(strack_xc(nt),strack_yc(nt)) ! Single neg PMT
c          cor_two=s_correct_cal_two(strack_xc(nt),strack_yc(nt)) ! Pos + Neg

          snblocks_cal(nt)=scluster_size(nc)
*
*
**  "cor_two" also may be used for "strack_e1" and "strack_e2' as a mean correction 
*    factor when "POS_PMT" and "NEG_PMT" on use !
*
*                  If "POS_PMT" + "NEG_PMT" then 
*
*            strack_e1(nt)=cor_two*scluster_e1(nc)          !  For "POS_PMT"+"NEG_PMT"
*
           if(scal_num_neg_columns.ge.1) then
             strack_e1_pos(nt)=cor_pos*scluster_e1_pos(nc) !  For "A" layer "POS_PMT"    
             strack_e1_neg(nt)=cor_neg*scluster_e1_neg(nc) !  For "A" layer "NEG_PMT"
             strack_e1(nt)=(strack_e1_pos(nt)+strack_e1_neg(nt))/2 !  For "A" layer "POS"+"NEG_PMT"
           else
             strack_e1(nt)=cor_pos*scluster_e1(nc) !   IF ONLY "POS_PMT" in layer "A"                
           endif

           if(scal_num_neg_columns.ge.2) then
             strack_e2_pos(nt)=cor_pos*scluster_e2_pos(nc) !  For "B" layer "POS_PMT"    
             strack_e2_neg(nt)=cor_neg*scluster_e2_neg(nc) !  For "B" layer "NEG_PMT"
             strack_e2(nt)=(strack_e2_pos(nt)+strack_e2_neg(nt))/2 !  For "B" layer "POS"+"NEG_PMT"
           else
             strack_e2(nt)=cor_pos*scluster_e2(nc) !   IF ONLY "POS_PMT" in layer "B"
           endif

           if(scal_num_neg_columns.ge.3) then
             print *,"Extra tubes on more than two layers not supported"
           endif

           strack_e1(nt)=cor_pos*scluster_e1(nc)    !Just use old PMTs until code/fitting stuff is OK.
           strack_e2(nt)=cor_pos*scluster_e2(nc)    !Just use old PMTs until code/fitting stuff is OK.
           strack_e3(nt)=cor_pos*scluster_e3(nc)  
           strack_e4(nt)=cor_pos*scluster_e4(nc)

 
           strack_et(nt)=strack_e1(nt)+strack_e2(nt)+ strack_e3(nt)
     &          +strack_e4(nt) 
           if(scal_num_neg_columns.ge.1) then
             strack_preshower_e(nt)=cor_pos*scluster_e1(nc)+cor_neg
     &            *scluster_e1(nc) 
           else
             strack_preshower_e(nt)=cor_pos*scluster_e1(nc)  
           endif

        endif                           !End ... if nc > 0
      enddo                             !End loop over detetor tracks       

 100  continue
      if(sdbg_tests_cal.gt.0) call s_prt_cal_tests

      return
      end             

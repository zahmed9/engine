      SUBROUTINE H_CER_EFF(ABORT,errmsg)

*--------------------------------------------------------
*
*  Purpose and Methods : Analyze cerenkov information for the "best
*                        track" as selected in h_select_best_track
*  Required Input BANKS: hms_cer_parms
*                        HMS_DATA_STRUCTURES
* 
*                Output: ABORT           - success or failure
*                      : err             - reason for failure, if any
*
*
* author: Chris Cothran
* created: 5/25/95
* $Log$
* Revision 1.1  1995/08/31 14:54:09  cdaq
* Initial revision
*
*--------------------------------------------------------

      IMPLICIT NONE
*
      character*9 here
      parameter (here= 'H_CER_EFF')
*
      logical ABORT
      character*(*) errmsg
*
      include 'hms_data_structures.cmn'
      include 'hms_cer_parms.cmn'

      integer*4 nr
      real*4    mirror_x,mirror_y
*
* test for a good electron
*
      if (hntracks_fp .eq. 1
     &  .and. hschi2perdeg .gt. 0. 
     &  .and. hschi2perdeg .lt. hcer_chi2max
     &  .and. hsbeta .gt. hcer_beta_min
     &  .and. hsbeta .lt. hcer_beta_max
     &  .and. hstrack_et .gt. hcer_et_min
     &  .and. hstrack_et .lt. hcer_et_max) then
*
* find hit location "on" the mirror
*
        mirror_x = hsx_fp + hcer_mirror_zpos*hsxp_fp
        mirror_y = hsy_fp + hcer_mirror_zpos*hsyp_fp

        do nr = 1, hcer_num_regions
*
* hit must be inside the region in order to continue
*
          if (abs(hcer_region(nr,1)-mirror_x).lt.hcer_region(nr,5)
     >  .and. abs(hcer_region(nr,2)-mirror_y).lt.hcer_region(nr,6)
     >  .and. abs(hcer_region(nr,3)-hsxp_fp) .lt.hcer_region(nr,7)
     >  .and. abs(hcer_region(nr,4)-hsyp_fp) .lt.hcer_region(nr,8))
     >    then
*
* increment the 'should have fired' counters
*
            hcer_track_counter(nr) = hcer_track_counter(nr) + 1
*
* increment the 'did fire' counters
*
            if (HCER_NPE_SUM.gt.hcer_threshold) then
              hcer_fired_counter(nr) = hcer_fired_counter(nr) + 1
            endif
          endif
        enddo
      endif

      return
      end
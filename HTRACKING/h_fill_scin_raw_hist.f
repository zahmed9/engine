
      subroutine h_fill_scin_raw_hist(Abort,err)
*
*     routine to fill histograms with hms_raw_scin varibles
*     In the future ID numbers are stored in hms_histid
*
*     Author:	D. F. Geesaman
*     Date:     4 April 1994
*
*     Modified  9 April 1994     DFG
*                                Add CTP flag to turn on histogramming
*                                id's in hms_id_histid
* $Log$
* Revision 1.1  1994/04/13 20:08:03  cdaq
* Initial revision
*
*--------------------------------------------------------
       IMPLICIT NONE
*
       external thgetid
       integer*4 thgetid
       character*50 here
       parameter (here= 'h_fill_scin_raw_hist_')
*
       logical ABORT
       character*(*) err
       real*4  histval
       integer*4 plane,counter,ihit, offset(4),planeoff
       include 'gen_data_structures.cmn'
       include 'hms_scin_parms.cmn'
       include 'hms_id_histid.cmn'          
*
       SAVE
*--------------------------------------------------------
*
       ABORT= .FALSE.
       err= ' '
* Do we want to histogram raw scintillators
       if(hturnon_scin_raw_hist .ne. 0 ) then
*

       histval = HSCIN_TOT_HITS
       call hf1(hidscinrawtothits,histval,1.)
* Make sure there is at least 1 hit
        if(HSCIN_TOT_HITS .gt. 0 ) then
* Loop over all hits
         do ihit=1,HSCIN_TOT_HITS
           plane=HSCIN_PLANE_NUM(ihit)
           counter=HSCIN_COUNTER_NUM(ihit)
* Fill plane map                  
           histval = FLOAT(HSCIN_PLANE_NUM(ihit))
           call hf1(hidscinplane,histval,1.)
* Check for valid plane
           if(plane.gt.0 .and. plane .le. hnum_scin_planes) then
* Fill counter map
            histval = FLOAT(HSCIN_COUNTER_NUM(ihit))
            call hf1(hidscincounters(plane),histval,1.)
* Fill ADC and TDC histograms
            if((counter .gt. 0) .and. (counter.le.hscin_num_counters(plane)))
     &           then
              histval = FLOAT(HSCIN_ADC_POS(ihit))
              call hf1(hidscinposadc(plane,counter),histval,1.)
              histval = FLOAT(HSCIN_ADC_NEG(ihit))
              call hf1(hidscinnegadc(plane,counter),histval,1.)
              histval = FLOAT(HSCIN_TDC_POS(ihit))
              call hf1(hidscinpostdc(plane,counter),histval,1.)
              histval = FLOAT(HSCIN_TDC_NEG(ihit))
              call hf1(hidscinnegtdc(plane,counter),histval,1.)
            endif ! end test on valid counter number
           endif ! end test on valid plane number
         enddo   ! end loop over hits
        endif     ! end test on zero hits       
       endif     ! end test on histogramming flag
       RETURN
       END


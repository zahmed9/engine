      subroutine h_trans_misc(abort,errmsg)
*-------------------------------------------------------------------
* author: John Arrington
* created: 4/8/95
*
* h_trans_misc fills the hms_decoded_misc common block
*
* $Log$
* Revision 1.4  1996/01/16 21:36:43  cdaq
* (JRA) Misc. fixes.
*
* Revision 1.3  1995/07/20 14:26:00  cdaq
* (JRA) Add second index (TDC/ADC) to hmisc_dec_data
*
* Revision 1.2  1995/05/22  19:39:32  cdaq
* (SAW) Split gen_data_data_structures into gen, hms, sos, and coin parts"
*
* Revision 1.1  1995/04/12  03:59:32  cdaq
* Initial revision
*
*
*--------------------------------------------------------

      implicit none

      include 'hms_data_structures.cmn'
      include 'hms_scin_parms.cmn'
      include 'gen_event_info.cmn'

      logical abort
      character*1024 errmsg
      character*20 here
      parameter (here = 'h_trans_misc')

      integer*4 ihit

      save

      do ihit = 1 , 48
        hmisc_dec_data(ihit,1) = 0     ! Clear TDC's
        hmisc_dec_data(ihit,2) = -1     ! Clear ADC's
      enddo
      
      do ihit = 1 , hmisc_tot_hits
        hmisc_dec_data(hmisc_raw_addr2(ihit),hmisc_raw_addr1(ihit)) =
     $       hmisc_raw_data(ihit)
      enddo

c      write(99,*) gen_event_id_number,hmisc_dec_data(9,2),hmisc_dec_data(10,2),
c     &               hmisc_dec_data(11,2),hmisc_dec_data(12,2),
c     &               hmisc_dec_data(14,2),hmisc_dec_data(16,2)

      return
      end

      subroutine s_sv_Nt_keep(ABORT,err)
*----------------------------------------------------------------------
*
*     Purpose : Add entry to the SOS Sieve slit Ntuple
*
*     Output: ABORT      - success or failure
*           : err        - reason for failure, if any
*
*     Created: 1-Nov-1994  
* $Log$
* Revision 1.1  1995/08/11 16:23:12  cdaq
* Initial revision
*
*----------------------------------------------------------------------
      implicit none
      save
*
      character*13 here
      parameter (here='s_sv_nt_keep')
*
      logical ABORT
      character*(*) err
*
      INCLUDE 's_sieve_ntuple.cmn'
      INCLUDE 'gen_data_structures.cmn'
      INCLUDE 'sos_data_structures.cmn'
      INCLUDE 'gen_event_info.cmn'
*
      logical HEXIST                    !CERNLIB function
*
      integer m
*
*--------------------------------------------------------
      err= ' '
      ABORT = .FALSE.
*
      IF(.NOT.s_sieve_Ntuple_exists) RETURN !nothing to do
*
************************************************
      m= 0
*  
      m= m+1
      s_sieve_Ntuple_contents(m)= SSX_FP ! X focal plane position 
      m= m+1
      s_sieve_Ntuple_contents(m)= SSY_FP
      m= m+1
      s_sieve_Ntuple_contents(m)= SSXP_FP
      m= m+1
      s_sieve_Ntuple_contents(m)= SSYP_FP
      m= m+1
      s_sieve_Ntuple_contents(m)= SSDELTA
      m= m+1
      s_sieve_Ntuple_contents(m)= SSX_TAR
      m= m+1
      s_sieve_Ntuple_contents(m)= SSY_TAR
      m= m+1
      s_sieve_Ntuple_contents(m)= SSXP_TAR
      m= m+1
      s_sieve_Ntuple_contents(m)= SSYP_TAR
      m=m+1
      s_sieve_Ntuple_contents(m)= SCAL_ET


*
************************************************
*
*
      ABORT= .NOT.HEXIST(s_sieve_Ntuple_ID)
      IF(ABORT) THEN
        call G_build_note(':Ntuple ID#$ does not exist',
     &       '$',s_sieve_Ntuple_ID,' ',0.,' ',err)
        call G_add_path(here,err)
      ELSE
        call HFN(s_sieve_Ntuple_ID,s_sieve_Ntuple_contents)
      ENDIF
*
      RETURN
      END
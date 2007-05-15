      subroutine b_analyze_pedestal(ABORT,err)

      implicit none
      save

      character*18 here
      parameter(here='b_analyze_pedestal')

      logical ABORT
      character*(*) err

      include 'bigcal_data_structures.cmn'
      include 'bigcal_gain_parms.cmn'
      
      integer*4 ihit,jhit
      integer*4 irow,icol,icell
      
      
      
c     pedestals we need to analyze include protvino, rcs, and trigger
c     procedure is to loop over all hits and accumulate ped sums: 

      do ihit=1,BIGCAL_PROT_NHIT
         irow = BIGCAL_PROT_IY(ihit)
         icol = BIGCAL_PROT_IX(ihit)
         icell = icol + BIGCAL_PROT_NX*(irow-1)

         if(BIGCAL_PROT_ADC_RAW(ihit).le.bigcal_prot_ped_limit(icell))
     $        then
            bigcal_prot_ped_sum2(icell) = bigcal_prot_ped_sum2(icell) + 
     $           BIGCAL_PROT_ADC_RAW(ihit)*BIGCAL_PROT_ADC_RAW(ihit)
            bigcal_prot_ped_sum(icell) = bigcal_prot_ped_sum(icell) +
     $           BIGCAL_PROT_ADC_RAW(ihit)
            bigcal_prot_ped_num(icell) = bigcal_prot_ped_num(icell) + 1
            if(bigcal_prot_ped_num(icell).eq.nint(bigcal_prot_min_peds 
     $           /5.) ) then
               bigcal_prot_ped_limit(icell) = 100 + 
     $             bigcal_prot_ped_sum(icell)/bigcal_prot_ped_num(icell)
            endif
         endif
      enddo

      do ihit=1,BIGCAL_RCS_NHIT
         irow = BIGCAL_RCS_IY(ihit)
         icol = BIGCAL_RCS_IX(ihit)
         icell = icol + BIGCAL_RCS_NX*(irow-1)

         if(BIGCAL_RCS_ADC_RAW(ihit).le.bigcal_rcs_ped_limit(icell))
     $        then
            bigcal_rcs_ped_sum2(icell) = bigcal_rcs_ped_sum2(icell) + 
     $           BIGCAL_RCS_ADC_RAW(ihit)*BIGCAL_RCS_ADC_RAW(ihit)
            bigcal_rcs_ped_sum(icell) = bigcal_rcs_ped_sum(icell) +
     $           BIGCAL_RCS_ADC_RAW(ihit)
            bigcal_rcs_ped_num(icell) = bigcal_rcs_ped_num(icell) + 1
            if(bigcal_rcs_ped_num(icell).eq.nint(bigcal_rcs_min_peds 
     $           /5.) ) then
               bigcal_rcs_ped_limit(icell) = 100 + 
     $             bigcal_rcs_ped_sum(icell)/bigcal_rcs_ped_num(icell)
            endif
         endif
      enddo

      do ihit=1,BIGCAL_TRIG_NHIT
         irow = BIGCAL_TRIG_IGROUP(ihit)
         icol = BIGCAL_TRIG_IHALF(ihit)
         icell = irow + BIGCAL_LOGIC_GROUPS/2*(icol-1)

         if(BIGCAL_TRIG_ADC_RAW(ihit).le.bigcal_trig_ped_limit(icell))
     $        then
            bigcal_trig_ped_sum2(icell) = bigcal_trig_ped_sum2(icell) + 
     $           BIGCAL_TRIG_ADC_RAW(ihit)*BIGCAL_TRIG_ADC_RAW(ihit)
            bigcal_trig_ped_sum(icell) = bigcal_trig_ped_sum(icell) +
     $           BIGCAL_TRIG_ADC_RAW(ihit)
            bigcal_trig_ped_num(icell) = bigcal_trig_ped_num(icell) + 1
            if(bigcal_trig_ped_num(icell).eq.nint(bigcal_trig_min_peds 
     $           /5.) ) then
               bigcal_trig_ped_limit(icell) = 100 + 
     $             bigcal_trig_ped_sum(icell)/bigcal_trig_ped_num(icell)
            endif
         endif
      enddo
      
      return
      end

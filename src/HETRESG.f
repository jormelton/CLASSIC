      SUBROUTINE HETRESG (LITRMASS, SOILCMAS,      ICC,       IG,      
     1                         ILG,      IL1,      IL2,     TBAR,    
     2                       THLIQ,     SAND,      CLAY,   ZBOTW,   
     3                        FRAC,    ISNOW,
C    -------------- INPUTS ABOVE THIS LINE, OUTPUTS BELOW -------------
     4                      LITRES,   SOCRES)  
C
C               CANADIAN TERRESTRIAL ECOSYSTEM MODEL (CTEM) V1.0
C           HETEROTROPHIC RESPIRATION SUBTOUTINE FOR BARE FRACTION
C
C     11  APR. 2003 - THIS SUBROUTINE CALCULATES HETEROTROPHIC RESPIRATION
C     V. ARORA        OVER THE BARE SUBAREA OF A GRID CELL (I.E. GROUND ONLY
C                     AND SNOW OVER GROUND SUBAREAS).

C     CHANGE HISTORY:

C     J. MELTON 31 AUG 2012 - REMOVE ISNOW, IT IS NOT USED.
C     J. MELTON 23 AUG 2012 - BRING IN ISAND, CONVERTING SAND TO
C                             INT WAS MISSING SOME GRIDCELLS ASSIGNED
C                             TO BEDROCK IN CLASSB

C     ------
C     INPUTS 
C
C     LITRMASS  - LITTER MASS FOR THE 8 PFTs + BARE IN KG C/M2
C     SOILCMAS  - SOIL CARBON MASS FOR THE 8 PFTs + BARE IN KG C/M2
C     ICC       - NO. OF VEGETATION TYPES (CURRENTLY 8)
C     IG        - NO. OF SOIL LAYERS (CURRENTLY 3)
C     ILG       - NO. OF GRID CELLS IN LATITUDE CIRCLE
C     IL1,IL2   - IL1=1, IL2=ILG
C     TBAR      - SOIL TEMPERATURE, K
C     THLIQ     - LIQUID SOIL MOISTURE CONTENT IN 3 SOIL LAYERS
C     SAND      - PERCENTAGE SAND
C     CLAY      - PERCENTAGE CLAY
C     ZBOTW     - BOTTOM OF SOIL LAYERS
C     FRAC      - FRACTION OF GROUND (FG) OR SNOW OVER GROUND (FGS)
C     ISNOW     - INTEGER TELLING IF BARE FRACTION IS FG (0) or FGS (1)
C
C     OUTPUTS
C
C     LITRES    - LITTER RESPIRATION OVER THE GIVEN UNVEGETATED SUB-AREA
C                 IN uMOL CO2/M2.S
C     SOCRES    - SOIL C RESPIRATION OVER THE GIVEN UNVEGETATED SUB-AREA
C                 IN uMOL CO2/M2.S
C
      IMPLICIT NONE
C
C     ISNOW IS CHANGED TO ISNOW(ILG) IN CLASST OF CLASS VERSION HIGHER 
C     THAN 3.4 FOR COUPLING WITH CTEM
C
C      INTEGER ILG, ICC,IG,IL1,IL2,I,J,K,ISNOW(ILG),ISAND(ILG,IG)
      INTEGER ILG, ICC,IG,IL1,IL2,I,J,K,ISNOW,ISAND(ILG,IG) !JM TEST

      REAL                  LITRMASS(ILG,ICC+1),  SOILCMAS(ILG,ICC+1), 
     1           TBAR(ILG,IG),    THLIQ(ILG,IG),         SAND(ILG,IG), 
     2          ZBOTW(ILG,IG),      LITRES(ILG),          SOCRES(ILG),
     3           CLAY(ILG,IG),        FRAC(ILG)

      REAL      BSRATELT(1),        BSRATESC(1),                ZERO, 
     1              LITRQ10,           SOILCQ10,               
     2        LITRTEMP(ILG),      SOLCTEMP(ILG),             Q10FUNC,
     3       PSISAT(ILG,IG),     GRKSAT(ILG,IG),           B(ILG,IG),
     4        THPOR(ILG,IG),               BETA,
     5      FRACARB(ILG,IG),               A(1),             ZCARBON,
     6        TEMPQ10L(ILG),      SOCMOSCL(ILG),     SCMOTRM(ILG,IG),
     7        LTRMOSCL(ILG),        PSI(ILG,IG),       TEMPQ10S(ILG),
     8               FCOEFF,         TANHQ10(4)


C     ------------------------------------------------------------------
C                     CONSTANTS USED IN THE MODEL

C     LITTER RESPIRATION RATE AT 15 C IN KG C/KG C.YEAR
      DATA BSRATELT/0.5605/
C
C     SOIL C RESPIRATION RATES AT 15 C IN KG C/KG C.YEAR
      DATA BSRATESC/0.02258/
C
C     PARAMETERS OF THE HYPERBOLIC TAN Q10 FORMULATION
C
      DATA TANHQ10/0.56, 1.44, 0.075, 46.0/
C                     A     B      C     D
C     Q10 = A + B * TANH[ C (D-Temperature) ]
C     WHEN A = 2, B = 0, WE GET THE CONSTANT Q10 OF 2. IF B IS NON
C     ZERO THEN Q10 BECOMES TEMPERATURE DEPENDENT
C
C     ZERO
      DATA ZERO/1E-20/
C
C     A, PARAMETER DESCRIBING EXPONENTIAL SOIL CARBON PROFILE. USED FOR 
C     ESTIMATING TEMPERATURE OF THE CARBON POOL
      DATA A/4.0/
C
C     ---------------------------------------------------------------
C
C     INITIALIZE REQUIRED ARRAYS TO ZERO
C
      DO 100 K = 1, IG
        DO 100 I = IL1, IL2
          FRACARB(I,K)=0.0  ! FRACTION OF CARBON IN EACH SOIL LAYER
100   CONTINUE
C
      DO 110 I = IL1, IL2
        LITRTEMP(I)=0.0     ! LITTER TEMPERATURE
        SOLCTEMP(I)=0.0     ! SOIL CARBON POOL TEMPERATURE
        SOCMOSCL(I)=0.0     ! SOIL MOISTURE SCALAR FOR SOIL CARBON DECOMPOSITION
        LTRMOSCL(I)=0.0     ! SOIL MOISTURE SCALAR FOR LITTER DECOMPOSITION
        LITRES(I)=0.0       ! LITTER RESP. RATE 
        TEMPQ10L(I)=0.0     
        SOCRES(I)=0.0       ! SOIL C RESP. RATE 
        TEMPQ10S(I)=0.0    
110   CONTINUE
C
      DO 120 J = 1, IG
        DO 130 I = IL1, IL2
          PSISAT(I,J) = 0.0       ! SATURATION MATRIC POTENTIAL
          GRKSAT(I,J) = 0.0       ! SATURATION HYD. CONDUCTIVITY
          THPOR(I,J) = 0.0        ! POROSITY
          B(I,J) = 0.0            ! PARAMETER B OF CLAPP AND HORNBERGER
          ISAND(I,J)=NINT(SAND(I,J))
130     CONTINUE
120   CONTINUE
C
C     INITIALIZATION ENDS    
C
C     ------------------------------------------------------------------
C
C     ESTIMATE TEMPERATURE OF THE LITTER AND SOIL CARBON POOLS. 
C
C     OVER THE BARE FRACTION THERE IS NO LIVE ROOT. SO WE MAKE THE
C     SIMPLEST ASSUMPTION THAT LITTER TEMPERATURE IS SAME AS TEMPERATURE
C     OF THE TOP SOIL LAYER.
C     
      DO 210 I = IL1, IL2
        LITRTEMP(I)=TBAR(I,1)
210   CONTINUE
C
C     WE ESTIMATE THE TEMPERATURE OF THE SOIL C POOL ASSUMING THAT SOIL 
C     CARBON OVER THE BARE FRACTION IS DISTRIBUTED EXPONENTIALLY. NOTE
C     THAT BARE FRACTION MAY CONTAIN DEAD ROOTS FROM DIFFERENT PFTs ALL OF
C     WHICH MAY BE DISTRIBUTED DIFFERENTLY. FOR SIMPLICITY WE DO NOT
C     TRACK EACH PFT's DEAD ROOT BIOMASS AND ASSUME THAT DISTRIBUTION OF
C     SOIL CARBON OVER THE BARE FRACTION CAN BE DESCRIBED BY A SINGLE
C     PARAMETER.
C
      DO 240 I = IL1, IL2
C
        ZCARBON=3.0/A(1)                 ! 95% DEPTH
        IF(ZCARBON.LE.ZBOTW(I,1)) THEN
            FRACARB(I,1)=1.0             ! FRACTION OF CARBON IN
            FRACARB(I,2)=0.0             ! SOIL LAYERS
            FRACARB(I,3)=0.0
        ELSE
            FCOEFF=EXP(-A(1)*ZCARBON)
            FRACARB(I,1)=
     &        1.0-(EXP(-A(1)*ZBOTW(I,1))-FCOEFF)/(1.0-FCOEFF)
            IF(ZCARBON.LE.ZBOTW(I,2)) THEN
                FRACARB(I,2)=1.0-FRACARB(I,1)
                FRACARB(I,3)=0.0
            ELSE
                FRACARB(I,3)=
     &            (EXP(-A(1)*ZBOTW(I,2))-FCOEFF)/(1.0-FCOEFF)
                FRACARB(I,2)=1.0-FRACARB(I,1)-FRACARB(I,3)
            ENDIF
        ENDIF
C
        SOLCTEMP(I)=TBAR(I,1)*FRACARB(I,1) +
     &     TBAR(I,2)*FRACARB(I,2) +
     &     TBAR(I,3)*FRACARB(I,3)
        SOLCTEMP(I)=SOLCTEMP(I) /
     &     (FRACARB(I,1)+FRACARB(I,2)+FRACARB(I,3))
C
C
C       MAKE SURE WE DON'T USE TEMPERATURES OF 2nd AND 3rd SOIL LAYERS
C       IF THEY ARE SPECIFIED BEDROCK VIA SAND -3 FLAG
C
        IF(ISAND(I,3).EQ.-3)THEN ! THIRD LAYER BED ROCK
          SOLCTEMP(I)=TBAR(I,1)*FRACARB(I,1) +
     &       TBAR(I,2)*FRACARB(I,2) 
          SOLCTEMP(I)=SOLCTEMP(I) /
     &       (FRACARB(I,1)+FRACARB(I,2))
        ENDIF
        IF(ISAND(I,2).EQ.-3)THEN ! SECOND LAYER BED ROCK
          SOLCTEMP(I)=TBAR(I,1)
        ENDIF
C
240   CONTINUE     
C
C     FIND MOISTURE SCALAR FOR SOIL C DECOMPOSITION
C
C     THIS IS MODELLED AS FUNCTION OF LOGARITHM OF MATRIC POTENTIAL. 
C     WE FIND VALUES FOR ALL SOIL LAYERS, AND THEN FIND AN AVERAGE VALUE 
C     BASED ON FRACTION OF CARBON PRESENT IN EACH LAYER. 
C
      DO 260 J = 1, IG
        DO 270 I = IL1, IL2
C
          IF(ISAND(I,J).EQ.-3.OR.ISAND(I,J).EQ.-4)THEN
            SCMOTRM (I,J)=0.2
            PSI (I,J) = 10000.0 ! SET TO LARGE NUMBER SO THAT
C                               ! LTRMOSCL BECOMES 0.2
          ELSE ! I.E., SAND.NE.-3 OR -4
            PSISAT(I,J)= (10.0**(-0.0131*SAND(I,J)+1.88))/100.0
            B(I,J)     = 0.159*CLAY(I,J)+2.91
            THPOR(I,J) = (-0.126*SAND(I,J)+48.9)/100.0
            PSI(I,J)   = PSISAT(I,J)*(THLIQ(I,J)/THPOR(I,J))**(-B(I,J)) 
C   
            IF(PSI(I,J).GT.10000.0) THEN
              SCMOTRM(I,J)=0.2
            ELSE IF( PSI(I,J).LE.10000.0 .AND.  PSI(I,J).GT.6.0 ) THEN
              SCMOTRM(I,J)=1.0 - 0.8*
     &   ( (LOG10(PSI(I,J)) - LOG10(6.0))/(LOG10(10000.0)-LOG10(6.0)) )         
            ELSE IF( PSI(I,J).LE.6.0 .AND.  PSI(I,J).GE.4.0 ) THEN
              SCMOTRM(I,J)=1.0
            ELSE IF( PSI(I,J).LT.4.0.AND.PSI(I,J).GT.PSISAT(I,J) )THEN 
              SCMOTRM(I,J)=1.0 - 
     &          0.5*( (LOG10(4.0) - LOG10(PSI(I,J))) / 
     &         (LOG10(4.0)-LOG10(PSISAT(I,J))) )
            ELSE IF( PSI(I,J).LE.PSISAT(I,J) ) THEN
              SCMOTRM(I,J)=0.5
            ENDIF
          ENDIF ! IF SAND.EQ.-3 OR -4
C
          SCMOTRM(I,J)=MAX(0.0,MIN(SCMOTRM(I,J),1.0))
270     CONTINUE     
260   CONTINUE     
C
      DO 290 I = IL1, IL2
        SOCMOSCL(I) = SCMOTRM(I,1)*FRACARB(I,1) + 
     &     SCMOTRM(I,2)*FRACARB(I,2) +
     &     SCMOTRM(I,3)*FRACARB(I,3)
        SOCMOSCL(I) = SOCMOSCL(I) /
     &     (FRACARB(I,1)+FRACARB(I,2)+FRACARB(I,3))    
C
C       MAKE SURE WE DON'T USE SCMOTRM OF 2nd AND 3rd SOIL LAYERS
C       IF THEY ARE SPECIFIED BEDROCK VIA SAND -3 FLAG
C
        IF(ISAND(I,3).EQ.-3)THEN ! THIRD LAYER BED ROCK
          SOCMOSCL(I) = SCMOTRM(I,1)*FRACARB(I,1) +
     &                    SCMOTRM(I,2)*FRACARB(I,2)
          SOCMOSCL(I) = SOCMOSCL(I) /
     &     (FRACARB(I,1)+FRACARB(I,2))
        ENDIF
        IF(ISAND(I,2).EQ.-3)THEN ! SECOND LAYER BED ROCK
          SOCMOSCL(I) = SCMOTRM(I,1)
        ENDIF
C
        SOCMOSCL(I)=MAX(0.2,MIN(SOCMOSCL(I),1.0))
290   CONTINUE     
C
C     FIND MOISTURE SCALAR FOR LITTER DECOMPOSITION
C
C     THE DIFFERENCE BETWEEN MOISTURE SCALAR FOR LITTER AND SOIL C
C     IS THAT THE LITTER DECOMPOSITION IS NOT CONSTRAINED BY HIGH
C     SOIL MOISTURE (ASSUMING THAT LITTER IS ALWAYS EXPOSED TO AIR).
C     IN ADDITION, WE USE MOISTURE CONTENT OF THE TOP SOIL LAYER
C     AS A SURROGATE FOR LITTER MOISTURE CONTENT. SO WE USE ONLY 
C     PSI(I,1) CALCULATED IN LOOPS 260 AND 270 ABOVE.
C
      DO 300 I = IL1, IL2
        IF(PSI(I,1).GT.10000.0) THEN
          LTRMOSCL(I)=0.2
        ELSE IF( PSI(I,1).LE.10000.0 .AND.  PSI(I,1).GT.6.0 ) THEN
          LTRMOSCL(I)=1.0 - 0.8*
     &    ( (LOG10(PSI(I,1)) - LOG10(6.0))/(LOG10(10000.0)-LOG10(6.0)) )
        ELSE IF( PSI(I,1).LE.6.0 ) THEN
          LTRMOSCL(I)=1.0 
        ENDIF
        LTRMOSCL(I)=MAX(0.2,MIN(LTRMOSCL(I),1.0))
300   CONTINUE
C
C     USE TEMPERATURE OF THE LITTER AND SOIL C POOLS, AND THEIR SOIL
C     MOISTURE SCALARS TO FIND RESPIRATION RATES FROM THESE POOLS
C
      DO 330 I = IL1, IL2
      IF(FRAC(I).GT.ZERO)THEN
C
C       FIRST FIND THE Q10 RESPONSE FUNCTION TO SCALE BASE RESPIRATION
C       RATE FROM 15 C TO CURRENT TEMPERATURE, WE DO LITTER FIRST
C
        TEMPQ10L(I)=LITRTEMP(I)-273.16
        LITRQ10 = TANHQ10(1) + TANHQ10(2)*
     &            ( TANH( TANHQ10(3)*(TANHQ10(4)-TEMPQ10L(I))  ) )
C
        Q10FUNC = LITRQ10**(0.1*(LITRTEMP(I)-273.16-15.0))
        LITRES(I)= LTRMOSCL(I) * LITRMASS(I,ICC+1)*
     &    BSRATELT(1)*2.64*Q10FUNC ! 2.64 CONVERTS BSRATELT FROM KG C/KG C.YEAR
C                                  ! TO u-MOL CO2/KG C.S
C
C       RESPIRATION FROM SOIL C POOL
C
        TEMPQ10S(I)=SOLCTEMP(I)-273.16
        SOILCQ10= TANHQ10(1) + TANHQ10(2)*
     &            ( TANH( TANHQ10(3)*(TANHQ10(4)-TEMPQ10S(I))  ) )
C
        Q10FUNC = SOILCQ10**(0.1*(SOLCTEMP(I)-273.16-15.0))
        SOCRES(I)= SOCMOSCL(I)* SOILCMAS(I,ICC+1)*
     &    BSRATESC(1)*2.64*Q10FUNC ! 2.64 CONVERTS BSRATESC FROM KG C/KG C.YEAR
C                                  ! TO u-MOL CO2/KG C.S
C
      ENDIF
330   CONTINUE
C
      RETURN
      END


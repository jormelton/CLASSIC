      SUBROUTINE DISTURB (STEMMASS, ROOTMASS, GLEAFMAS, BLEAFMAS,
     1                       THLIQ,   WILTSM,  FIELDSM,    UWIND,
     2                       VWIND,  LIGHTNG,  FCANCMX, LITRMASS,     
     3                    PRBFRHUC, RMATCTEM, EXTNPROB, PFTAREAB,
     4                         IL1,      IL2,       IG,      ICC,      
     5                         ILG,     SORT, NOL2PFTS,       IC,
     6                    GRCLAREA,    THICE,   POPDIN, LUCEMCOM,
     7                      DOFIRE,
C    8 ------------------ INPUTS ABOVE THIS LINE ----------------------   
     9                    STEMLTDT, ROOTLTDT, GLFLTRDT, BLFLTRDT,
     A                    PFTAREAA, GLCAEMLS, RTCAEMLS, STCAEMLS,
     B                    BLCAEMLS, LTRCEMLS, BURNFRAC, PROBFIRE,
     C                    EMIT_CO2, EMIT_CO,  EMIT_CH4, EMIT_NMHC,
     D                    EMIT_H2,  EMIT_NOX, EMIT_N2O, EMIT_PM25,
     E                    EMIT_TPM, EMIT_TC,  EMIT_OC,  EMIT_BC)

C    B ------------------OUTPUTS ABOVE THIS LINE ----------------------
C
C               CANADIAN TERRESTRIAL ECOSYSTEM MODEL (CTEM) V1.0
C                           DISTURBANCE SUBROUTINE
C
C     09  MAY 2012  - ADDITION OF EMISSION FACTORS AND REVISING OF THE
C     J. MELTON       FIRE SCHEME


C     15  MAY 2003  - THIS SUBROUTINE CALCULATES THE LITTER GENERATED
C     V. ARORA        AND C EMISSIONS FROM LEAVES, STEM, AND ROOT 
C                     COMPONENTS DUE TO FIRE. C EMISSIONS FROM BURNED
C                     LITTER ARE ALSO ESTIMATED. AT PRESENT NO OTHER 
C                     FORM OF DISTURBANCE IS MODELLED.
C     INPUTS 
C
C     STEMMASS  - STEM MASS FOR EACH OF THE 9 CTEM PFTs, Kg C/M2
C     ROOTMASS  - ROOT MASS FOR EACH OF THE 9 CTEM PFTs, Kg C/M2
C     GLEAFMAS  - GREEN LEAF MASS FOR EACH OF THE 9 CTEM PFTs, Kg C/M2
C     BLEAFMAS  - BROWN LEAF MASS 
C     THLIQ     - LIQUID SOIL MOISTURE CONTENT
C     WILTSM    - WILTING POINT SOIL MOISTURE CONTENT
C     FIELDSM   - FIELD CAPACITY SOIL MOISTURE CONTENT
C     UWIND     - WIND SPEED, M/S
C     VWIND     - WIND SPEED, M/S
C     LIGHTNG   - TOTAL LIGHTNING, FLASHES/(KM^2.YEAR)
C                 IT IS ASSUMED THAT CLOUD TO GROUND LIGHTNING IS
C                 SOME FIXED FRACTION OF TOTAL LIGHTNING.
C     FCANCMX   - FRACTIONAL COVERAGES OF CTEM's 9 PFTs
C     LITRMASS  - LITTER MASS FOR EACH OF THE 9 PFTs
C     PRBFRHUC  - PROBABILITY OF FIRE DUE TO HUMAN CAUSES
C     RMATCTEM  - FRACTION OF ROOTS IN EACH SOIL LAYER FOR EACH PFT
C     EXTNPROB  - FIRE EXTINGUISHING PROBABILITY
C     PFTAREAB  - AREAS OF DIFFERENT PFTs IN A GRID CELL, BEFORE FIRE, KM^2
C     ICC       - NO. OF CTEM PLANT FUNCTION TYPES, CURRENTLY 9
C     IG        - NO. OF SOIL LAYERS (CURRENTLY 3)
C     ILG       - NO. OF GRID CELLS IN LATITUDE CIRCLE
C     IL1,IL2   - IL1=1, IL2=ILG
C     SORT      - INDEX FOR CORRESPONDENCE BETWEEN 9 PFTs AND SIZE 12 OF
C                 PARAMETERS VECTORS
C     NOL2PFTS  - NUMBER OF LEVEL 2 CTEM PFTs
C     IC        - NUMBER OF CLASS PFTs
C     GRCLAREA  - GCM GRID CELL AREA, KM^2
C     THICE     - FROZEN SOIL MOISTURE CONTENT OVER CANOPY FRACTION
C     POPDIN    - POPULATION DENSITY (PEOPLE / KM^2)
C     LUCEMCOM  - LAND USE CHANGE (LUC) RELATED COMBUSTION EMISSION LOSSES,
C                 u-MOL CO2/M2.SEC 
C     DOFIRE    - BOOLEAN, IF TRUE ALLOW FIRE, IF FALSE NO FIRE.
C
C     OUTPUTS
C
C     STEMLTDT  - STEM LITTER GENERATED DUE TO DISTURBANCE (Kg C/M2)
C     ROOTLTDT  - ROOT LITTER GENERATED DUE TO DISTURBANCE (Kg C/M2)
C     GLFLTRDT  - GREEN LEAF LITTER GENERATED DUE TO DISTURBANCE (Kg C/M2)
C     BLFLTRDT  - BROWN LEAF LITTER GENERATED DUE TO DISTURBANCE (Kg C/M2)
C     BURNAREA  - TOTAL AREA BURNED, KM^2
C     BURNFRAC  - TOTAL AREAL FRACTION BURNED, (%)
C     PROBFIRE  - PROBABILITY OF FIRE
C     PFTAREAA  - AREAS OF DIFFERENT PFTs IN A GRID CELL, AFTER FIRE, KM^2
C
C     NOTE THE FOLLOWING C BURNED WILL BE CONVERTED TO A TRACE GAS 
C     EMISSION OR AEROSOL ON THE BASIS OF EMISSION FACTORS.
C
C     GLCAEMLS  - GREEN LEAF CARBON EMISSION LOSSES, Kg C/M2
C     BLCAEMLS  - BROWN LEAF CARBON EMISSION LOSSES, Kg C/M2
C     RTCAEMLS  - ROOT CARBON EMISSION LOSSES, Kg C/M2
C     STCAEMLS  - STEM CARBON EMISSION LOSSES, Kg C/M2
C     LTRCEMLS  - LITTER CARBON EMISSION LOSSES, Kg C/M2

C     EMISSION FACTORS FOR TRACE GASES AND AEROSOLS. UNITS ARE
C     g OF COMPOUND EMITTED PER Kg OF DRY ORGANIC MATTER.
C     VALUES ARE TAKEN FROM LI ET AL. 2012 BIOGEOSCI 
C     EMIF_CO2  - CARBON DIOXIDE
C     EMIF_CO   - CARBON MONOXIDE
C     EMIF_CH4  - METHANE
C     EMIF_NMHC - NON-METHANE HYDROCARBONS
C     EMIF_H2   - HYDROGEN GAS
C     EMIF_NOX  - NITROGEN OXIDES
C     EMIF_N2O  - NITROUS OXIDE
C     EMIF_PM25 - PARTICULATE MATTER LESS THAN 2.5 uM IN DIAMETER
C     EMIF_TPM  - TOTAL PARTICULATE MATTER
C     EMIF_TC   - TOTAL CARBON
C     EMIF_OC   - ORGANIC CARBON
C     EMIF_BC   - BLACK CARBON

C     EMITTED COMPOUNDS FROM BIOMASS BURNING IN g OF COMPOUND
C     EMIT_CO2  - CARBON DIOXIDE
C     EMIT_CO   - CARBON MONOXIDE
C     EMIT_CH4  - METHANE
C     EMIT_NMHC - NON-METHANE HYDROCARBONS
C     EMIT_H2   - HYDROGEN GAS
C     EMIT_NOX  - NITROGEN OXIDES
C     EMIT_N2O  - NITROUS OXIDE
C     EMIT_PM25 - PARTICULATE MATTER LESS THAN 2.5 uM IN DIAMETER
C     EMIT_TPM  - TOTAL PARTICULATE MATTER
C     EMIT_TC   - TOTAL CARBON
C     EMIT_OC   - ORGANIC CARBON
C     EMIT_BC   - BLACK CARBON

C     TOT_EMIT  - SUM OF ALL POOLS TO BE CONVERTED TO EMISSIONS/AEROSOLS (g C/M2)
C     TOT_EMIT_DOM - TOT_EMIT CONVERTED TO Kg DOM / M2

C     HB_INTERM - INTERM CALCULATION
C     HBRATIO   - HEAD TO BACK RATIO OF ELLIPSE


C
      IMPLICIT NONE
C
      INTEGER    ILG,     ICC,      IL1,        IL2,      I,      J,    
     1             K,      IG,    ISEED,  FIRE(ILG),     KK,      M,
     2            K1,      K2,        N,         IC
C
      PARAMETER (KK=12)  ! PRODUCT OF CLASS PFTs AND L2MAX
C
      INTEGER       SORT(ICC),      NOL2PFTS(IC)

      LOGICAL DOFIRE
C
      REAL  STEMMASS(ILG,ICC), ROOTMASS(ILG,ICC), GLEAFMAS(ILG,ICC),
     1      BLEAFMAS(ILG,ICC),     THLIQ(ILG,IG),    WILTSM(ILG,IG),
     2        FIELDSM(ILG,IG),        UWIND(ILG),        VWIND(ILG),
     3       FCANCMX(ILG,ICC),      LIGHTNG(ILG),LITRMASS(ILG,ICC+1),
     4          PRBFRHUC(ILG),     EXTNPROB(ILG), PFTAREAB(ILG,ICC),
     5   RMATCTEM(ILG,ICC,IG),     THICE(ILG,IG),            POPDIN,
     6          LUCEMCOM(ILG)
C
      REAL  STEMLTDT(ILG,ICC), ROOTLTDT(ILG,ICC), GLFLTRDT(ILG,ICC),
     1          BURNAREA(ILG), PFTAREAA(ILG,ICC), GLCAEMLS(ILG,ICC),
     2      RTCAEMLS(ILG,ICC), STCAEMLS(ILG,ICC), LTRCEMLS(ILG,ICC),
     3      BLFLTRDT(ILG,ICC), BLCAEMLS(ILG,ICC),     BURNFRAC(ILG),
     4          EMIT_CO2(ILG),      EMIT_CO(ILG),     EMIT_CH4(ILG),
     5         EMIT_NMHC(ILG),      EMIT_H2(ILG),     EMIT_NOX(ILG),
     6          EMIT_N2O(ILG),    EMIT_PM25(ILG),     EMIT_TPM(ILG),
     7           EMIT_TC(ILG),      EMIT_OC(ILG),      EMIT_BC(ILG)
C
      REAL        BMASTHRS(2),                                ZERO,
     1               EXTNMOIS,          LWRLTHRS,         HGRLTHRS,
     2               PARMLGHT,          PARBLGHT,            ALPHA,
     3                     F0,           MAXSPRD,      FRCO2LF(KK),
     4            FRLTRLF(KK),      FRCO2STM(KK),     FRLTRSTM(KK),
     5            FRCO2RT(KK),       FRLTRRT(KK),     FRLTRBRN(KK),
     6                  C2DOM,
     7           EMIF_CO2(KK),       EMIF_CO(KK),     EMIF_CH4(KK),
     8          EMIF_NMHC(KK),       EMIF_H2(KK),     EMIF_NOX(KK),
     9           EMIF_N2O(KK),     EMIF_PM25(KK),     EMIF_TPM(KK),
     A            EMIF_TC(KK),       EMIF_OC(KK),      EMIF_BC(KK)
C
      REAL   BIOMASS(ILG,ICC),        BTERM(ILG), DRGTSTRS(ILG,ICC),
     1       BETADRGT(ILG,IG),     AVGDRYNS(ILG),        FCSUM(ILG),
     2          AVGBMASS(ILG),        MTERM(ILG),     C2GLGTNG(ILG),
     3          BETALGHT(ILG),            Y(ILG),              YMIN,
     4                   YMAX,             SLOPE,        LTERM(ILG),
     5          PROBFIRE(ILG),             CTIME,            RANDOM,
     6                   TEMP,     BETMSPRD(ILG),       SMFUNC(ILG),
     7              WIND(ILG),      WNDFUNC(ILG),     SPRDRATE(ILG),
     8           LBRATIO(ILG),     ARBN1DAY(ILG),     AREAMULT(ILG),
     9       BURNVEG(ILG,ICC),      VEGAREA(ILG),     GRCLAREA(ILG),
     A                REPAREA,          TOT_EMIT,      TOT_EMIT_DOM

      REAL          HB_INTERM,      HBRATIO(ILG),       POPDTHRSHLD,
     1                 FDEN_M
C
C     ------------------------------------------------------------------
C                     CONSTANTS USED IN THE MODEL
C     NOTE THE STRUCTURE OF VECTORS WHICH CLEARLY SHOWS THE CLASS
C     PFTs (ALONG ROWS) AND CTEM SUB-PFTs (ALONG COLUMNS)
C
C     NEEDLE LEAF |  EVG       DCD       ---
C     BROAD LEAF  |  EVG   DCD-CLD   DCD-DRY
C     CROPS       |   C3        C4       ---
C     GRASSES     |   C3        C4       ---
C
C     MIN. AND MAX. VEGETATION BIOMASS THRESHOLDS TO INITIATE FIRE, KG C/M^2
      DATA BMASTHRS/0.20, 1.0/
C
      REAL, PARAMETER :: PI=3.1415926535898d0
C
C     EXTINCTION MOISTURE CONTENT FOR ESTIMATING FIRE LIKELINESS DUE
C     TO SOIL MOISTURE
C      DATA EXTNMOIS/0.30/
      DATA EXTNMOIS/0.35/
C
C     LOWER CLOUD-TO-GROUND LIGHTNING THRESHOLD FOR FIRE LIKELIHOOD
C     FLASHES/KM^2.YEAR
      DATA LWRLTHRS/0.25/
C
C     HIGHER CLOUD-TO-GROUND LIGHTNING THRESHOLD FOR FIRE LIKELIHOOD
C     FLASHES/KM^2.YEAR
      DATA HGRLTHRS/10.0/
C
C     PARAMETER M (MEAN) AND B OF LOGISTIC DISTRIBUTION USED FOR 
C     ESTIMATING FIRE LIKELIHOOD DUE TO LIGHTNING
      DATA PARMLGHT/0.4/
      DATA PARBLGHT/0.1/
C
C     PARAMETER ALPHA AND F0 USED FOR ESTIMATING WIND FUNCTION FOR
C     FIRE SPREAD RATE
      DATA ALPHA/8.16326E-04/

C     FLAG TESTING: 
C     THE FIRE SPREAD RATE IN THE ABSENCE OF WIND, NOW A DERIVED 
C     QUANTITY FROM THE FORMULATION OF THE WIND SPEED FIRE SPREAD
C     RATE SCALAR
      DATA F0/0.1/
C      DATA F0/0.05/

C
C     MAX. FIRE SPREAD RATE, KM/HR
      DATA MAXSPRD/0.45/
C
C     FRACTION OF LEAF BIOMASS CONVERTED TO GASES DUE TO COMBUSTION
      DATA FRCO2LF/0.70, 0.70, 0.00,
     &             0.70, 0.70, 0.70,
     &             0.00, 0.00, 0.00,
     &             0.80, 0.80, 0.00/
C
C     FRACTION OF LEAF BIOMASS BECOMING LITTER AFTER COMBUSTION
      DATA FRLTRLF/0.20, 0.20, 0.00,
     &             0.20, 0.20, 0.20,
     &             0.00, 0.00, 0.00,
     &             0.10, 0.10, 0.00/
C
C     FRACTION OF STEM BIOMASS CONVERTED TO GASES DUE TO COMBUSTION
      DATA FRCO2STM/0.20, 0.20, 0.00,
     &              0.20, 0.10, 0.10,
     &              0.00, 0.00, 0.00,
     &              0.00, 0.00, 0.00/
C
C     FRACTION OF STEM BIOMASS BECOMING LITTER AFTER COMBUSTION
      DATA FRLTRSTM/0.60, 0.60, 0.00,
     &              0.60, 0.40, 0.40,
     &              0.00, 0.00, 0.00,
     &              0.00, 0.00, 0.00/
C
C     FRACTION OF ROOT BIOMASS CONVERTED TO GASES DUE TO COMBUSTION
      DATA FRCO2RT/0.0, 0.0, 0.0,
     &             0.0, 0.0, 0.0, 
     &             0.0, 0.0, 0.0, 
     &             0.0, 0.0, 0.0/
C
C     FRACTION OF ROOT BIOMASS BECOMING LITTER AFTER COMBUSTION
      DATA FRLTRRT/0.10, 0.10, 0.00,
     &             0.10, 0.10, 0.10,
     &             0.00, 0.00, 0.00,
     &             0.25, 0.25, 0.00/
C
C     FRACTION OF LITTER BURNED DURING FIRE AND EMITTED AS GASES
      DATA FRLTRBRN/0.50, 0.50, 0.00,
     &              0.60, 0.60, 0.60,
     &              0.00, 0.00, 0.00,
     &              0.70, 0.70, 0.00/
C
C     ========================

C     EMISSIONS FACTORS BY CHEMICAL SPECIES
C     
C     VALUES ARE FROM ANDREAE 2011 AS DESCRIBED IN LI ET AL. 2012
C     BIOGEOSCI.

C     PFT-SPECIFIC EMISSION FACTORS FOR CO2 
      DATA EMIF_CO2/1576.0, 1576.0,   0.00,
     &              1604.0, 1576.0, 1654.0,
     &              1576.0, 1654.0,   0.00,
     &              1576.0, 1654.0,   0.00/

C     PFT-SPECIFIC EMISSION FACTORS FOR CO 
      DATA EMIF_CO /106.0, 106.0, 0.00,
     &              103.0, 106.0, 64.0,
     &              106.0,  64.0, 0.00,
     &              106.0,  64.0, 0.00/

C     PFT-SPECIFIC EMISSION FACTORS FOR CH4 
      DATA EMIF_CH4/ 4.8, 4.8, 0.0,
     &               5.8, 4.8, 2.4,
     &               4.8, 2.4, 0.0,
     &               4.8, 2.4, 0.0/

C     PFT-SPECIFIC EMISSION FACTORS FOR NMHC
      DATA EMIF_NMHC/ 5.7, 5.7, 0.0,
     &                6.4, 5.7, 3.7,
     &                5.7, 3.7, 0.0,
     &                5.7, 3.7, 0.0/

C     PFT-SPECIFIC EMISSION FACTORS FOR H2
      DATA EMIF_H2/ 1.80, 1.80, 0.00,
     &              2.54, 1.80, 0.98,
     &              1.80, 0.98, 0.00,
     &              1.80, 0.98, 0.00/

C     PFT-SPECIFIC EMISSION FACTORS FOR NOX
      DATA EMIF_NOX/3.24, 3.24, 0.00,
     &              2.90, 3.24, 2.49,
     &              3.24, 2.49, 0.00,
     &              3.24, 2.49, 0.00/

C     PFT-SPECIFIC EMISSION FACTORS FOR N2O 
      DATA EMIF_N2O/0.26, 0.26, 0.00,
     &              0.23, 0.26, 0.20,
     &              0.26, 0.20, 0.00,
     &              0.26, 0.20, 0.00/

C     EMISSION FACTORS FOR AEROSOLS

C     PFT-SPECIFIC EMISSION FACTORS FOR PM2.5
C     (PARTICLES LESS THAN 2.5 MICROMETERS IN 
C      DIAMETER)
      DATA EMIF_PM25/12.7, 12.7, 0.0,
     &               10.5, 12.7, 5.2,
     &               12.7,  5.2, 0.0,
     &               12.7,  5.2, 0.0/

C     PFT-SPECIFIC EMISSION FACTORS FOR TPM 
C     (TOTAL PARTICULATE MATTER)
      DATA EMIF_TPM/17.6, 17.6, 0.0,
     &              14.7, 17.6, 8.5,
     &              17.6,  8.5, 0.0,
     &              17.6,  8.5, 0.0/

C     PFT-SPECIFIC EMISSION FACTORS FOR TC
C     (TOTAL CARBON)
      DATA EMIF_TC/ 8.3, 8.3, 0.0,
     &              7.2, 8.3, 3.4,
     &              8.3, 3.4, 0.0,
     &              8.3, 3.4, 0.0/

C     PFT-SPECIFIC EMISSION FACTORS FOR OC 
C     (ORGANIC CARBON)
      DATA EMIF_OC/ 9.1, 9.1, 0.0,
     &              6.7, 9.1, 3.2,
     &              9.1, 3.2, 0.0,
     &              9.1, 3.2, 0.0/

C     PFT-SPECIFIC EMISSION FACTORS FOR BC
C     (BLACK CARBON)
      DATA EMIF_BC/ 0.56, 0.56, 0.00,
     &              0.56, 0.56, 0.47,
     &              0.56, 0.47, 0.00,
     &              0.56, 0.47, 0.00/

C     CONVERSION FACTOR FROM CARBON TO DRY ORGANIC MATTER
C     VALUE IS FROM LI ET AL. 2012 BIOGEOSCI
      DATA C2DOM/450.0/ ! gC / Kg DRY ORGANIC MATTER

C     ========================

C     TYPICAL AREA REPRESENTING CTEM's FIRE PARAMETERIZATION
      DATA REPAREA/1000.0/ ! KM^2
C
C     THRESHOLD OF POPULATION DENSITY (people/km^2) [Kloster et al., BioGeoSci. 2010]
      DATA POPDTHRSHLD/300./

C     ZERO
      DATA ZERO/1E-20/
C
C     ---------------------------------------------------------------
C
      IF(ICC.NE.9)                            CALL XIT('DISTURB',-1)
C
C     INITIALIZE REQUIRED ARRAYS TO ZERO
C
      DO 140 J = 1,ICC
        DO 150 I = IL1, IL2
          STEMLTDT(I,J)=0.0     !STEM LITTER DUE TO DISTURBANCE
          ROOTLTDT(I,J)=0.0     !ROOT LITTER DUE TO DISTURBANCE
          GLFLTRDT(I,J)=0.0     !GREEN LEAF LITTER DUE TO DISTURBANCE
          BLFLTRDT(I,J)=0.0     !BROWN LEAF LITTER DUE TO DISTURBANCE
          BIOMASS(I,J)=0.0      !TOTAL BIOMASS FOR FIRE PURPOSES
          DRGTSTRS(I,J)=0.0     !SOIL DRYNESS FACTOR FOR PFTs
          BURNVEG(I,J)=0.0      !BURN AREA FOR EACH PFT
          PFTAREAA(I,J)=0.0     !PFT AREA AFTER FIRE
          GLCAEMLS(I,J)=0.0     !GREEN LEAF CARBON FIRE EMISSIONS
          BLCAEMLS(I,J)=0.0     !BROWN LEAF CARBON FIRE EMISSIONS
          STCAEMLS(I,J)=0.0     !STEM CARBON FIRE EMISSIONS
          RTCAEMLS(I,J)=0.0     !ROOT CARBON FIRE EMISSIONS
          LTRCEMLS(I,J)=0.0     !LITTER CARBON FIRE EMISSIONS
150     CONTINUE                  
140   CONTINUE
C
      DO 160 K = 1,IG
        DO 170 I = IL1, IL2
          BETADRGT(I,K)=0.0     !DRYNESS TERM FOR SOIL LAYERS
170     CONTINUE                  
160   CONTINUE
C
      DO 180 I = IL1, IL2
        AVGBMASS(I)=0.0         !AVG. VEG. BIOMASS OVER THE VEG. FRACTION 
C                               !OF GRID CELL
        AVGDRYNS(I)=0.0         !AVG. DRYNESS OVER THE VEGETATED FRACTION
        FCSUM(I)=0.0            !TOTAL VEGETATED FRACTION
        BTERM(I)=0.0            !BIOMASS FIRE PROBABILITY TERM
        MTERM(I)=0.0            !MOISTURE FIRE PROBABILITY TERM
        C2GLGTNG(I)=0.0         !CLOUD-TO-GROUND LIGHTNING
        BETALGHT(I)=0.0         !0-1 LIGHTNING TERM
        Y(I)=0.0                !LOGISTIC DIST. FOR FIRE PROB. DUE TO LIGHTNING
        LTERM(I)=0.0            !LIGHTNING FIRE PROBABILITY TERM
        PROBFIRE(I)=0.0         !PROBABILITY OF FIRE
        FIRE(I)=0               !FIRE, 1 MEANS YES, 0 MEANS NO
        BURNAREA(I)=0.0         !TOTAL AREA BURNED DUE TO FIRE
        BURNFRAC(I)=0.0         !TOTAL AREAL FRACTION BURNED DUE TO FIRE
        BETMSPRD(I)=0.0         !BETA MOISTURE FOR CALCULATING FIRE SPREAD RATE
        SMFUNC(I)=0.0           !SOIL MOISTURE FUNCTION USED FOR FIRE SPREAD RATE
        WIND(I)=0.0             !WIND SPEED IN KM/HR
        WNDFUNC(I)=0.0          !WIND FUNCTION FOR FIRE SPREAD RATE
        SPRDRATE(I)=0.0         !FIRE SPREAD RATE
        LBRATIO(I)=0.0          !LENGTH TO BREADTH RATIO OF FIRE
        ARBN1DAY(I)=0.0         !AREA BURNED IN 1 DAY, KM^2
        AREAMULT(I)=0.0         !MULTIPLIER TO FIND AREA BURNED
        VEGAREA(I)=0.0          !TOTAL VEGETATED AREA IN A GRID CELL

        EMIT_CO2(I) = 0.0
        EMIT_CO(I) = 0.0
        EMIT_CH4(I) = 0.0
        EMIT_NMHC(I) = 0.0
        EMIT_H2(I) = 0.0
        EMIT_NOX(I) = 0.0
        EMIT_N2O(I) = 0.0
        EMIT_PM25(I) = 0.0
        EMIT_TPM(I) = 0.0
        EMIT_TC(I) = 0.0
        EMIT_OC(I) = 0.0
        EMIT_BC(I) = 0.0

180   CONTINUE

C     IF NOT SIMULATING FIRE, LEAVE THE SUBROUTINE NOW.
      IF (.NOT. DOFIRE) GOTO 600

C
      DO 190 I = IL1, IL2
        IF(EXTNPROB(I).LE.ZERO) THEN
          WRITE(6,*)'FIRE EXTINGUISHING PROB. (',I,'= ',EXTNPROB(I)
          WRITE(6,*)'PLEASE USE AN APPROPRIATE VALUE OF THIS PARAMATER'
          WRITE(6,*)'ELSE THE WHOLE GRID CELL WILL BURN DOWN LEADING TO'
          WRITE(6,*)'NUMERICAL PROBLEMS.'
          CALL XIT('DISTURB',-2)
        ENDIF
190   CONTINUE
C
C     INITIALIZATION ENDS    
C
C     ------------------------------------------------------------------
C
C     FIND THE PROBABILITY OF FIRE AS A PRODUCT OF THREE FUNCTIONS
C     WITH DEPENDENCE ON TOTAL BIOMASS, SOIL MOISTURE, AND LIGHTNING 
C
C     1. DEPENDENCE ON TOTAL BIOMASS
C
      DO 200 J = 1, ICC
        DO 210 I = IL1, IL2
C         ROOT BIOMASS IS NOT USED TO INITIATE FIRE. FOR EXAMPLE IF
C         THE LAST FIRE BURNED ALL GRASS LEAVES, AND SOME OF THE ROOTS
C         WERE LEFT, ITS UNLIKELY THESE ROOTS COULD CATCH FIRE. 
          BIOMASS(I,J)=GLEAFMAS(I,J)+BLEAFMAS(I,J)+STEMMASS(I,J)+
     &                 LITRMASS(I,J)
210     CONTINUE
200   CONTINUE
C
C     FIND AVERAGE BIOMASS OVER THE VEGETATED FRACTION
C
      DO 220 J = 1, ICC
        DO 230 I = IL1, IL2
          AVGBMASS(I) = AVGBMASS(I)+BIOMASS(I,J)*FCANCMX(I,J)
230     CONTINUE
220   CONTINUE 
C
      DO 250 I = IL1, IL2
        FCSUM(I)=FCANCMX(I,1)+FCANCMX(I,2)+FCANCMX(I,3)+FCANCMX(I,4)+  
     &           FCANCMX(I,5)+FCANCMX(I,6)+FCANCMX(I,7)+FCANCMX(I,8)+
     &           FCANCMX(I,9)

        IF(FCSUM(I).GT.ZERO)THEN
          AVGBMASS(I)=AVGBMASS(I)/FCSUM(I)
        ELSE
          AVGBMASS(I)=0.0
        ENDIF
C
        IF(AVGBMASS(I).GE.BMASTHRS(2))THEN
          BTERM(I)=1.0
        ELSE IF(AVGBMASS(I).LT.BMASTHRS(2).AND.
     &    AVGBMASS(I).GT.BMASTHRS(1))THEN
          BTERM(I)=(AVGBMASS(I)-BMASTHRS(1))/(BMASTHRS(2)-BMASTHRS(1))     
        ELSE IF(AVGBMASS(I).LE.BMASTHRS(1))THEN
          BTERM(I)=0.0  !NO FIRE IF BIOMASS BELOW THE LOWER THRESHOLD
        ENDIF
        BTERM(I)=MAX(0.0, MIN(BTERM(I),1.0))
250   CONTINUE 
C
C     2. DEPENDENCE ON SOIL MOISTURE
C
C     THIS IS CALCULATED IN A WAY SUCH THAT MORE DRY THE ROOT ZONE
C     OF A PFT TYPE IS, AND MORE FRACTIONAL AREA IS COVERED WITH THAT
C     PFT, THE MORE LIKELY IT IS THAT FIRE WILL GET STARTED. THAT IS
C     THE DRYNESS FACTOR IS WEIGHTED BY FRACTION OF ROOTS IN SOIL
C     LAYERS, AS WELL AS ACCORDING TO THE FRACTIONAL COVERAGE OF 
C     DIFFERENT PFTs. THE ASSUMPTION HERE IS THAT IF THERE IS LESS 
C     MOISTURE IN ROOT ZONE, THEN IT IS MORE LIKELY THE VEGETATION 
C     WILL BE DRY AND THUS THE LIKELINESS OF FIRE IS MORE.
C
C     FIRST FIND THE DRYNESS FACTOR FOR EACH SOIL LAYER.
C
      DO 300 J = 1, IG
        DO 310 I = IL1, IL2
C
          IF((THLIQ(I,J)+THICE(I,J)).LE.WILTSM(I,J)) THEN
            BETADRGT(I,J)=0.0
          ELSE IF((THLIQ(I,J)+THICE(I,J)).GT.WILTSM(I,J).AND.
     &      (THLIQ(I,J)+THICE(I,J)).LT.FIELDSM(I,J))THEN
            BETADRGT(I,J)=(THLIQ(I,J)+THICE(I,J)-WILTSM(I,J))
            BETADRGT(I,J)=BETADRGT(I,J)/(FIELDSM(I,J)-WILTSM(I,J))   
          ELSE
            BETADRGT(I,J)=1.0
          ENDIF
          BETADRGT(I,J)=MAX(0.0, MIN(BETADRGT(I,J),1.0))
C
310     CONTINUE
300   CONTINUE
C
C     NOW FIND WEIGHTED VALUE OF THIS DRYNESS FACTOR AVERAGED OVER 
C     THE ROOTING DEPTH, FOR EACH PFT
C
      DO 320 J = 1, ICC
        DO 330 I = IL1, IL2
         DRGTSTRS(I,J) =  (BETADRGT(I,1))*RMATCTEM(I,J,1) +
     &                    (BETADRGT(I,2))*RMATCTEM(I,J,2) +
     &                    (BETADRGT(I,3))*RMATCTEM(I,J,3)
         DRGTSTRS(I,J) = DRGTSTRS(I,J) /
     &    (RMATCTEM(I,J,1)+RMATCTEM(I,J,2)+RMATCTEM(I,J,3))
         DRGTSTRS(I,J)=MAX(0.0, MIN(DRGTSTRS(I,J),1.0))
330     CONTINUE
320   CONTINUE
C
C     NEXT FIND THIS DRYNESS FACTOR AVERAGED OVER THE VEGETATED FRACTION
C
      DO 350 J = 1, ICC
        DO 360 I = IL1, IL2
          AVGDRYNS(I) = AVGDRYNS(I)+DRGTSTRS(I,J)*FCANCMX(I,J)
360     CONTINUE
350   CONTINUE 
C
      DO 370 I = IL1, IL2
        IF(FCSUM(I).GT.ZERO)THEN
          AVGDRYNS(I)=AVGDRYNS(I)/FCSUM(I)
        ELSE
          AVGDRYNS(I)=0.0
        ENDIF
370   CONTINUE 
C
C     USE AVERAGE ROOT ZONE VEGETATION DRYNESS TO FIND LIKELIHOOD OF
C     FIRE DUE TO MOISTURE. 
C
      DO 380 I = IL1, IL2
        IF(FCSUM(I).GT.ZERO)THEN
C          MTERM(I)=EXP( -1.0*PI*(AVGDRYNS(I)/EXTNMOIS)**2 )
          MTERM(I)=1.0-TANH((1.75*AVGDRYNS(I)/EXTNMOIS)**2)
        ELSE
          MTERM(I)=0.0   !NO FIRE LIKELIHOOD DUE TO MOISTURE IF NO VEGETATION
        ENDIF
        MTERM(I)=MAX(0.0, MIN(MTERM(I),1.0))
380   CONTINUE
C
C     3. DEPENDENCE ON LIGHTNING
C
C     DEPENDENCE ON LIGHTNING IS MODELLED IN A SIMPLE WAY WHICH IMPLIES THAT
C     A LARGE NO. OF LIGHTNING FLASHES ARE MORE LIKELY TO CAUSE FIRE THAN
C     FEW LIGHTNING FLASHES.
C
      DO 400 I = IL1, IL2
        C2GLGTNG(I)=0.25*LIGHTNG(I)   
        IF( C2GLGTNG(I).LE.LWRLTHRS) THEN
           BETALGHT(I)=0.0
        ELSE IF ( C2GLGTNG(I).GT.LWRLTHRS.AND.
     &  C2GLGTNG(I).LT.HGRLTHRS) THEN 
           BETALGHT(I)=(C2GLGTNG(I)-LWRLTHRS)/(HGRLTHRS-LWRLTHRS)
        ELSE IF (C2GLGTNG(I).GE.HGRLTHRS) THEN
           BETALGHT(I)=1.0
        ENDIF
        Y(I)=1.0/( 1.0+EXP((PARMLGHT-BETALGHT(I))/PARBLGHT) )
        YMIN=1.0/( 1.0+EXP((PARMLGHT-0.0)/PARBLGHT) )
        YMAX=1.0/( 1.0+EXP((PARMLGHT-1.0)/PARBLGHT) )
        SLOPE=ABS(0.0-YMIN)+ABS(1.0-YMAX)
        TEMP=Y(I)+(0.0-YMIN)+BETALGHT(I)*SLOPE

C     FLAG TESTING:
C     DETERMINE THE PROBABILITY OF FIRE DUE TO HUMAN CAUSES
C     THIS IS BASED UPON THE POPULATION DENSITY FROM THE .POPD
C     READ-IN FILE
        PRBFRHUC(I)=MIN(1.0,(POPDIN/POPDTHRSHLD)**0.43)

        LTERM(I)=TEMP+(1.0-TEMP)*PRBFRHUC(I)
        LTERM(I)=MAX(0.0, MIN(LTERM(I),1.0))

400   CONTINUE
C
C     MULTIPLY THE BTERM, MTERM, AND THE LTERM TO FIND PROBABILITY OF
C     FIRE. ALSO GENERATE A RANDOM NUMBER TO SEE IF WE ARE GOING TO
C     START A FIRE OR NOT.
C
      DO 420 I = IL1, IL2
        PROBFIRE(I)=BTERM(I)*MTERM(I)*LTERM(I)
C       DON'T NEED THE RANDOM THING BECAUSE PROB. FIRE DETERMINES BURN
C       AREA ANYWAY.
        FIRE(I)=1
420   CONTINUE
C
C     IF FIRE IS TO BE STARTED THEN ESTIMATE BURN AREA AND LITTER GENERATED
C     BY THE FIRE, ELSE DO NOTHING.

      DO 430 I = IL1, IL2
        IF(FIRE(I).EQ.1)THEN
C
C         FIND SPREAD RATE AS A FUNCTION OF WIND SPEED AND SOIL MOISTURE IN THE
C         ROOT ZONE (AS FOUND ABOVE) WHICH WE USE AS A SURROGATE FOR MOISTURE
C         CONTENT OF VEGETATION.
          IF( AVGDRYNS(I).GT.EXTNMOIS )THEN
            BETMSPRD(I)= 1.0   
          ELSE
            BETMSPRD(I)= AVGDRYNS(I)/EXTNMOIS   
          ENDIF
          SMFUNC(I)=(1.0-BETMSPRD(I))**2.0
          WIND(I)=SQRT(UWIND(I)**2.0 + VWIND(I)**2.0)
          WIND(I)=WIND(I)*3.60     ! CHANGE M/S TO KM/HR

C         LENGTH TO BREADTH RATIO OF FIRE
C         FLAG TESTING: NOTE, LI ET AL. USE A VALUE OF -0.06
          LBRATIO(I)=1.0+10.0*(1.0-EXP(-0.017*WIND(I)))

C         FLAG TESTING:
C         CALCULATE THE HEAD TO BACK RATIO OF THE FIRE
          HB_INTERM = (LBRATIO(I)**2 - 1.0)**0.5
          HBRATIO(I) = (LBRATIO(I) + HB_INTERM)/(LBRATIO(I) - HB_INTERM)

C         FLAG TESTING:
C         FOLLOWING LI ET AL. 2012 THIS FUNCTION HAS BEEN DERIVED
C         FROM THE FIRE RATE SPREAD PERPENDICULAR TO THE WIND 
C         DIRECTION, IN THE DOWNWIND DIRECTION, THE HEAD TO BACK
C         RATIO AND THE LENGTH TO BREADTH RATIO. F0 IS ALSO NOW
C         A DERIVED QUANTITY (0.05)
          WNDFUNC(I)=1.0 - ( (1.0-F0)*EXP(-1.0*ALPHA*WIND(I)**2) )
C          WNDFUNC(I)= (2.0 * LBRATIO(I)) / (1.0 + 1.0 
C     &                     / HBRATIO(I)) * F0 

          SPRDRATE(I)=MAXSPRD* SMFUNC(I)* WNDFUNC(I)
C
C         AREA BURNED IN 1 DAY, KM^2
C         THE ASSUMED RATIO OF THE HEAD TO BACK RATIO WAS 5.0 IN 
C         ARORA AND BOER 2005 JGR, THIS VALUE CAN BE CALCULATED
C         AS WAS POINTED OUT IN LI ET AL. 2012 BIOGEOSCI. WE 
C         ADOPT THE CALCULATED VERSION BELOW
C         FLAG TESTING:
          ARBN1DAY(I)=(PI*0.36*24*24*SPRDRATE(I)**2)/LBRATIO(I)
C          ARBN1DAY(I)=(PI*24*24*SPRDRATE(I)**2)/(4.0 * LBRATIO(I)) * 
C     &                 (1.0 + 1.0 / HBRATIO(I))**2

C
C         BASED ON FIRE EXTINGUISHING PROBABILITY WE ESTIMATE THE NUMBER 
C         WHICH NEEDS TO BE MULTIPLIED WITH ARBN1DAY TO ESTIMATE AVERAGE 
C         AREA BURNED

C         FLAG TESTING:
C         FIRE EXTINCTION IS BASED UPON POPULATION DENSITY
           EXTNPROB(I)=MAX(0.0,0.9-EXP(-0.025*POPDIN))
           EXTNPROB(I)=0.5+EXTNPROB(I)/2.0

          AREAMULT(I)=((1.0-EXTNPROB(I))*(2.0-EXTNPROB(I)))/
     &      EXTNPROB(I)**2                   
C
C         AREA BURNED, KM^2
          BURNAREA(I)=ARBN1DAY(I)*AREAMULT(I)

C         FLAG TESTING:
C         SOME REGIONS CAN HAVE MULTIPLE FIRES IN OUR REPRESENTATIVE 
C         AREA, TO ACCOMODATE THIS WE HAVE A FIRE DENSITY MULTIPLIER
C         IN MOST REGIONS THIS IS UNITY. IN REGIONS WITH HIGH FIRE
C         DENSITY THIS BECOMES DEPENDENT UPON THE AMOUNT OF GRASS IN 
C         THE GRIDCELL, THE LOGIC IS THAT GRASSLANDS MORE RAPIDLY
C         RESPOND TO DRYING CONDITIONS, RAPIDLY REFRESH THE C STOCKS
C         AND DO NOT HAVE LONG LASTING, SMOULDERING FIRES
C         SHOULD THIS BE PER MOSIAC OR PER GRIDCELL?? I THINK PER
C         GRIDCELL BUT THIS WOULD MAKE THE MOSIACS ALL HIGHER...
C         PROBLEM?

          BURNAREA(I)=BURNAREA(I)*(GRCLAREA(I)/REPAREA)*PROBFIRE(I) 

          BURNFRAC(I)=100.*BURNAREA(I)/GRCLAREA(I)
        ENDIF
430   CONTINUE
C
C     MAKE SURE AREA BURNED IS NOT GREATER THAN THE VEGETATED AREA. 
C     DISTRIBUTE BURNED AREA EQUALLY AMONGST PFTs PRESENT IN THE GRID CELL.
C 
      DO 460 I = IL1, IL2
        VEGAREA(I)=PFTAREAB(I,1)+PFTAREAB(I,2)+PFTAREAB(I,3)+
     &             PFTAREAB(I,4)+PFTAREAB(I,5)+PFTAREAB(I,6)+
     &             PFTAREAB(I,7)+PFTAREAB(I,8)+PFTAREAB(I,9)  
        IF(BURNAREA(I).GT.VEGAREA(I)) THEN
          BURNAREA(I)=VEGAREA(I)
          BURNFRAC(I)=100.*BURNAREA(I)/GRCLAREA(I)
        ENDIF
460   CONTINUE
C
      K1=0
      DO 470 J = 1, IC
       IF(J.EQ.1) THEN
         K1 = K1 + 1
       ELSE
         K1 = K1 + NOL2PFTS(J-1)
       ENDIF
       K2 = K1 + NOL2PFTS(J) - 1
       DO 475 M = K1, K2
        DO 480 I = IL1, IL2
          IF(VEGAREA(I).GT.ZERO)THEN
            BURNVEG(I,M)= (BURNAREA(I)*PFTAREAB(I,M)/VEGAREA(I))
            IF(J.EQ.3)THEN  !CROPS NOT ALLOWED TO BURN
              BURNVEG(I,M)= 0.0
            ENDIF
          ELSE
            BURNVEG(I,M)= 0.0
          ENDIF
          PFTAREAA(I,M)=PFTAREAB(I,M)-BURNVEG(I,M)
480     CONTINUE
475    CONTINUE 
470   CONTINUE 
C
      DO 490 I = IL1, IL2
       BURNAREA(I)=BURNVEG(I,1)+BURNVEG(I,2)+BURNVEG(I,3)+BURNVEG(I,4)+  
     &             BURNVEG(I,5)+BURNVEG(I,6)+BURNVEG(I,7)+BURNVEG(I,8)+  
     &             BURNVEG(I,9)
       BURNFRAC(I)=100.*BURNAREA(I)/GRCLAREA(I)
490   CONTINUE
C
C     CHECK THAT THE SUM OF FRACTION OF LEAVES, STEM, AND ROOT 
C     THAT NEEDS TO BE BURNED AND CONVERTED INTO CO2, AND FRACTION THAT 
C     NEEDS TO BECOME LITTER DOESN'T EXCEED ONE.
C
      DO 500 J = 1, ICC
        N = SORT(J)
        IF( (FRCO2LF(N)+FRLTRLF(N)).GT.1.0 )    CALL XIT('DISTURB',-3)
        IF( (FRCO2STM(N)+FRLTRSTM(N)).GT.1.0 )  CALL XIT('DISTURB',-4)
        IF( (FRCO2RT(N)+FRLTRRT(N)).GT.1.0 )    CALL XIT('DISTURB',-5)
        IF(  FRLTRBRN(N).GT.1.0 )               CALL XIT('DISTURB',-6)
500   CONTINUE
C
C     AND FINALLY ESTIMATE AMOUNT OF LITTER GENERATED FROM EACH PFT, AND
C     EACH VEGETATION COMPONENT (LEAVES, STEM, AND ROOT) BASED ON THEIR
C     RESISTANCE TO COMBUSTION. WE ALSO ESTIMATE CO2 EMISSIONS FROM EACH
C     OF THESE COMPONENTS. NOTE THAT THE LITTER WHICH IS GENERATED DUE 
C     TO DISTURBANCE IS UNIFORMLY DISTRIBUTED OVER THE ENTIRE AREA OF 
C     A GIVEN PFT, AND THIS ESSENTIALLY THINS THE VEGETATION BIOMASS. 
C     AT THIS STAGE WE DO NOT MAKE THE BURN AREA BARE, AND THEREFORE
C     FIRE DOESN'T CHANGE THE FRACTIONAL COVERAGE OF PFTs.  
C

      DO 520 J = 1, ICC
        N = SORT(J)
        DO 530 I = IL1, IL2
C
          IF(PFTAREAB(I,J).GT.ZERO)THEN
            GLFLTRDT(I,J)=FRLTRLF(N) *GLEAFMAS(I,J)*
     &       (BURNVEG(I,J)/PFTAREAB(I,J))
C
            BLFLTRDT(I,J)=FRLTRLF(N) *BLEAFMAS(I,J)*
     &       (BURNVEG(I,J)/PFTAREAB(I,J))
C
            STEMLTDT(I,J)=FRLTRSTM(N)*STEMMASS(I,J)*
     &       (BURNVEG(I,J)/PFTAREAB(I,J))
C
            ROOTLTDT(I,J)=FRLTRRT(N) *ROOTMASS(I,J)*
     &       (BURNVEG(I,J)/PFTAREAB(I,J))
C
            GLCAEMLS(I,J)=FRCO2LF(N) *GLEAFMAS(I,J)*
     &       (BURNVEG(I,J)/PFTAREAB(I,J))
C
            BLCAEMLS(I,J)=FRCO2LF(N) *BLEAFMAS(I,J)*
     &       (BURNVEG(I,J)/PFTAREAB(I,J))
C
            STCAEMLS(I,J)=FRCO2STM(N)*STEMMASS(I,J)*
     &       (BURNVEG(I,J)/PFTAREAB(I,J))
C
            RTCAEMLS(I,J)=FRCO2RT(N) *ROOTMASS(I,J)*
     &       (BURNVEG(I,J)/PFTAREAB(I,J))
C
            LTRCEMLS(I,J)=FRLTRBRN(N)*LITRMASS(I,J)*
     &       (BURNVEG(I,J)/PFTAREAB(I,J))

C          CALCULATE THE EMISSIONS OF TRACE GASES AND AEROSOLS BASED UPON HOW
C          MUCH PLANT MATTER WAS BURNT

C          SUM ALL POOLS THAT WILL BE CONVERTED TO EMISSIONS/AEROSOLS (g C/M2)
           TOT_EMIT = (GLCAEMLS(I,J) + BLCAEMLS(I,J) + RTCAEMLS(I,J)
     &            + STCAEMLS(I,J) + LTRCEMLS(I,J)) * 1000.0

C          ADD IN THE EMISSIONS DUE TO LUC FIRES (DEFORESTATION)
C          THE LUC EMISSIONS ARE CONVERTED FROM umol CO2 m-2 s-1
C          TO g C m-2 (day-1) BEFORE ADDING TO TOT_EMIT
           TOT_EMIT = TOT_EMIT + (LUCEMCOM(I) / 963.62 * 1000.0)

C          CONVERT BURNT PLANT MATTER FROM CARBON TO DRY ORGANIC MATTER USING 
C          A CONVERSION FACTOR, ASSUME ALL PARTS OF THE PLANT HAS THE SAME
C          RATIO OF CARBON TO DRY ORGANIC MATTER. UNITS: Kg DOM / M2
           TOT_EMIT_DOM = TOT_EMIT / C2DOM

C          CONVERT THE DOM TO EMISSIONS/AEROSOLS USING EMISSIONS FACTORS
C          UNITS: g COMPOUND / M2

           EMIT_CO2(I) = EMIT_CO2(I) + EMIF_CO2(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)
           EMIT_CO(I) = EMIT_CO(I) + EMIF_CO(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)
           EMIT_CH4(I) = EMIT_CH4(I) + EMIF_CH4(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)
           EMIT_NMHC(I) = EMIT_NMHC(I) + EMIF_NMHC(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)
           EMIT_H2(I) = EMIT_H2(I) + EMIF_H2(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)
           EMIT_NOX(I) = EMIT_NOX(I) + EMIF_NOX(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)
           EMIT_N2O(I) = EMIT_N2O(I) + EMIF_N2O(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)
           EMIT_PM25(I) = EMIT_PM25(I) + EMIF_PM25(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)
           EMIT_TPM(I) = EMIT_TPM(I) + EMIF_TPM(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)
           EMIT_TC(I) = EMIT_TC(I) + EMIF_TC(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)
           EMIT_OC(I) = EMIT_OC(I) + EMIF_OC(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)
           EMIT_BC(I) = EMIT_BC(I) + EMIF_BC(J) * 
     &                   TOT_EMIT_DOM * FCANCMX(I,J)

C          ELSE

C            GLFLTRDT(I,J)=0.0
C            BLFLTRDT(I,J)=0.0
C            STEMLTDT(I,J)=0.0
C            ROOTLTDT(I,J)=0.0
C            GLCAEMLS(I,J)=0.0
C            BLCAEMLS(I,J)=0.0
C            STCAEMLS(I,J)=0.0
C            RTCAEMLS(I,J)=0.0
C            LTRCEMLS(I,J)=0.0

          ENDIF
C
530     CONTINUE
520   CONTINUE
C
600   CONTINUE

      RETURN
      END


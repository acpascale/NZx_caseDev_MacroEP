##   [x].r  - port of pier availabilities to Macro input for 8760 or 288 hours
##
##   Created:        18 Dec 2025 (for NZI)
##   Last updated:   28 Apr 2026  ... adjusted for self consumption
##   Last updated:   30 Apr 2026  ... removed self consumption
##
##   ToDo: 
##      1.

#-----0.ADMIN - Include libraries and other important-----------
setwd( "~/GitHub/NZx_caseDev_MacroEP/electricity_fiveZ_8736_2p_nziShadow_dev/viz_compare_info/PIERumi/" )

###--A. Clean

###--B.Load Library for country manipulations
suppressMessages ( library ( "reshape2"     , lib.loc=.libPaths() ) )      # melt, dcast

###--C.Dirs and Variables

period <- 8760  
scenar <- "8_REF_Unconstr"
tag    <- "5period_vreAdj"
##utilization factor data source: https://zenodo.org/records/18043483
datIN  <- paste ( "source/supply_" , scenar , "/" , sep = "" )
datOUT <- paste ( "../../system/availability/" , sep = "" )

###defs
dhm        <- c ( 1  , 25 , 49 , 73 , 97 , 121 , 145 , 169 , 193 , 217 , 241 , 265 )
dayMon     <- c ( 30 , 31 , 30 , 31 , 31 , 30  , 31  , 30  , 31  , 31  , 28  , 31  )
hrsmon     <- c ( 720  , 744  ,  720  , 744 , 744 , 720  , 744  , 720 , 744 , 744 , 672  , 744 )
years      <- c ( 2023 , 2024 , 2025 , 2029 , 2034 , 2039 )   
#regions    <- c ( "NR" , "NER" , "ER" , "WR" , "SR" )
etechA      <- c (  "EG_WINDON" , "EG_SOLARGM" , "EG_SOLARRF" , "EG_WINDOFF" )
etechB      <- c (  "EG_SH" , "EG_LH" , "EG_BIOMASS" , "EG_COAL"  ) 
etechC      <- c (  "EG_CCGT"   , "EG_OCGT"    , "EG_PHWR"    , "EG_SMR" )
#ftech      <- c ( "RF_MS" , "RF_HSD" , "RF_ATF" , "RF_LPG"  , "RF_OTHERPP"  , "RF_PETCOKE" , "GH_ELECTROLYSIS" )


#-----END 0.ADMIN---------------

#-----1.HACK to use PIER availabilities--------------------

###data  
DAT              <- read.csv ( paste ( datIN , "ECT_Max_CUF.csv" , sep = "" )  , header=TRUE , stringsAsFactors = FALSE , fileEncoding = "UTF-8-BOM" )
SC               <- read.csv ( paste ( datIN , "ECT_OperationalInfo.csv" , sep = "" )  , header=TRUE , stringsAsFactors = FALSE , fileEncoding = "UTF-8-BOM" )
SC               <- SC[,-c(3,5,6)]

h <-1
for ( h in 1:length ( years ) ) {
  ###process techs with hourly availability (VRE)
  TEM              <- subset ( DAT , DAT$EnergyConvTech %in% etechA & DAT$InstYear %in% c ( years[h] , "ALL" ) , select = c ( "EnergyConvTech" , "InstYear" , "SubGeography1" , "Season" , "DaySlice" , "MaxUF"))
  ##get self consumption and adjust availability
  DATa             <- merge ( TEM , SC , by = c ( "EnergyConvTech" , "InstYear" ) , all.x = TRUE ) 
  DATa$MaxUF       <- ifelse ( is.na ( DATa$SelfCons ) , DATa$MaxUF , ifelse ( DATa$MaxUF <= DATa$SelfCons , 0 , DATa$MaxUF - DATa$SelfCons ) )
  DATah            <- dcast ( DATa , Season + DaySlice ~ EnergyConvTech + InstYear +SubGeography1 , value.var = "MaxUF" , fun.aggregate = sum )
  rm ( TEM )
  
  if ( period == 8760 ) {
    #j<-1
    for ( j in 1: length ( unique ( DATah$Season ) ) ) { 
      SEM  <- subset ( DATah  , DATah$Season == unique ( DATah$Season )[j] )
      SEMP <- data.frame ( do.call ( rbind, replicate ( dayMon[j] , SEM , simplify = FALSE ) ) ) 
      if ( j == 1 ) { YEARa = SEMP }
      if ( j > 1  ) { YEARa = rbind ( YEARa , SEMP ) }
    }
    YEARa <- YEARa [,-(1)]
    names ( YEARa )[1] <- "TimeIndex"
    YEARa$TimeIndex <- seq ( from = 1 , to = 8760 , by = 1 )
    rm ( DATa , DATah , j , SEM , SEMP )
  }
  if ( period == 288 ) {
    YEARa <- DATah
    YEARa <- YEARa [,-(1)]
    names ( YEARa )[1] <- "TimeIndex"
    YEARa$TimeIndex <- seq ( from = 1 , to = 288 , by = 1 )
    rm ( DATa , DATah  )
  }
  
  ###process techs with monthly availability (add in annual capacity factor constraint until figure out how to model in Macro)
  TEM              <- subset ( DAT , DAT$EnergyConvTech %in% etechB , select = c ( "EnergyConvTech" , "SubGeography1" , "Season" , "DaySlice" , "MaxUF"))
  SCb              <- subset ( SC , SC$EnergyConvTech %in% etechB & SC$InstYear %in% c ( years[h] ) )
  ##get self consumption and adjust availability
  DATb             <- merge ( TEM , SCb , by = c ( "EnergyConvTech" ) , all.x = TRUE , all.y = TRUE ) 
  DATb$MaxUF       <- ifelse ( is.na ( DATb$SelfCons) , DATb$MaxUF , DATb$MaxUF ) #ifelse ( DATb$MaxUF <= DATb$SelfCons , 0 , DATb$MaxUF - DATb$SelfCons ) )
  DATbh            <- dcast ( DATb , Season ~ EnergyConvTech + InstYear +SubGeography1 , value.var = "MaxUF" , fun.aggregate = sum )
  rm ( TEM )
  
  ####--Coal adjustment for annual capacity factor--workaround (ECT_EfficiencyCostMaxAnnualUF.csv) ... this is a workaround and results in stated MaxAnnualUF, but needs more consideration, 
  DATbh[3] <- lapply ( DATbh[3] , function ( x )  ifelse ( x > 0.95 , 0.95 , x ) )
  
  if ( period == 8760 ) {
    #j<-1
    for ( j in 1: length ( unique ( DATbh$Season ) ) ) { 
      SEM  <- subset ( DATbh  , DATbh$Season == unique ( DATbh$Season )[j] )
      SEMP <- data.frame ( do.call ( rbind, replicate ( hrsmon[j] , SEM , simplify = FALSE ) ) ) 
      if ( j == 1 ) { YEARb = SEMP }
      if ( j > 1  ) { YEARb = rbind ( YEARb , SEMP ) }
    }
    YEARb <- YEARb [,-(1)]
    YEAR  <- cbind ( YEARa , YEARb )
    rm ( DATb , DATbh , j , SEM , SEMP , YEARa , YEARb )
  }
  if ( period == 288 ) {
    #j<-1
    for ( j in 1: length ( unique ( DATbh$Season ) ) ) { 
      SEM  <- subset ( DATbh  , DATbh$Season == unique ( DATbh$Season )[j] )
      SEMP <- data.frame ( do.call ( rbind, replicate ( 24 , SEM , simplify = FALSE ) ) ) 
      if ( j == 1 ) { YEARb = SEMP }
      if ( j > 1  ) { YEARb = rbind ( YEARb , SEMP ) }
    }
    YEARb <- YEARb [,-(1)]
    YEAR  <- cbind ( YEARa , YEARb )
    rm ( DATb , DATbh , j , SEM , SEMP , YEARa , YEARb )
  }
  
  ###process techs with annual availability
  TEM             <- subset ( DAT , DAT$EnergyConvTech %in% etechC , select = c ( "EnergyConvTech" , "SubGeography1" , "Season" , "DaySlice" , "MaxUF"))
  SCc              <- subset ( SC , SC$EnergyConvTech %in% etechC & SC$InstYear %in% c ( years[h] ) )
  ##get self consumption and adjust availability
  DATc             <- merge ( TEM , SCc , by = c ( "EnergyConvTech"  ) , all.x = TRUE , all.y = TRUE ) 
  DATc$MaxUF       <- ifelse ( is.na ( DATc$SelfCons) , DATc$MaxUF , DATc$MaxUF ) # ifelse ( DATc$MaxUF <= DATc$SelfCons , 0 , DATc$MaxUF - DATc$SelfCons ) )
  DATch            <- dcast ( DATc , Season ~ EnergyConvTech + InstYear +SubGeography1 , value.var = "MaxUF" , fun.aggregate = sum )
  rm ( TEM )
  ####--tech adjustment for annual capacity factor--workaround (ECT_EfficiencyCostMaxAnnualUF.csv). again a workaround, but results in stated MaxAnnualUF
  DATch[2]  <- lapply ( DATch[2] , function ( x )  x * 0.85 ) #CCGT
  DATch[3]  <- lapply ( DATch[3] , function ( x )  x * 0.85 ) #OCGT
  DATch[4]  <- lapply ( DATch[4] , function ( x )  x * 0.709166667 ) #PHWR
  DATch[5]  <- lapply ( DATch[5] , function ( x )  x * 0.709166667 ) #SMR
  
  if ( period == 8760 ) {
    #j<-1
    for ( j in 1: length ( unique ( DATch$Season ) ) ) { 
      SEM  <- subset ( DATch  , DATch$Season == unique ( DATch$Season )[j] )
      SEMP <- data.frame ( do.call ( rbind, replicate ( 8760 , SEM , simplify = FALSE ) ) ) 
      if ( j == 1 ) { YEARc = SEMP }
      if ( j > 1  ) { YEARc = rbind ( YEARc , SEMP ) }
    }
    YEARc <- YEARc [,-(1)]
    YEAR  <- cbind ( YEAR , YEARc )
    rm ( DATc , DATch , j , SEM , SEMP , YEARc )
  }
  if ( period == 288 ) {
    #j<-1
    for ( j in 1: length ( unique ( DATch$Season ) ) ) { 
      SEM  <- subset ( DATch  , DATch$Season == unique ( DATch$Season )[j] )
      SEMP <- data.frame ( do.call ( rbind, replicate ( 288 , SEM , simplify = FALSE ) ) ) 
      if ( j == 1 ) { YEARc = SEMP }
      if ( j > 1  ) { YEARc = rbind ( YEARc , SEMP ) }
    }
    YEARc <- YEARc [,-(1)]
    YEAR  <- cbind ( YEAR , YEARc )
    rm ( DATc , DATch , j , SEM , SEMP , YEARc )
  }
  
  write.csv ( YEAR , file = paste ( datOUT , years[h] , ".csv" , sep = ""  ) , row.names = FALSE )
}
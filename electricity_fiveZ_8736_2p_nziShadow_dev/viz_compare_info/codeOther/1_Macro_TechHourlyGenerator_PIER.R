##   [x].r  - port of pier availabilities to Macro input 8760
##
##   Created:        18 Dec 2025 (for NZI)
##   Last updated:   28 Apr 2026  ... adjusted for self consumption
##
##   ToDo: 
##      1. If Macro load slow, then simplify in technologies where self-consumption doesn't change over entire model period

#-----0.ADMIN - Include libraries and other important-----------

###--A. Clean

###--B.Load Library for country manipulations
suppressMessages ( library ( "reshape2"     , lib.loc=.libPaths() ) )      # melt, dcast

###--C.Dirs and Variables

period <- 8760

#-----END 0.ADMIN---------------

#-----1.HACK to use PIER availabilities--------------------
  
##utilization factor data source: https://zenodo.org/records/18043483

tag    <- "5period"
datIN  <- "~/GitHub/NZx_caseDev_MacroEP/electricity_fiveZ_8736_2p_nziShadow_dev/viz_compare_info/codeOther/source/"
datOUT <- ""

###defs
dhm        <- c ( 1  , 25 , 49 , 73 , 97 , 121 , 145 , 169 , 193 , 217 , 241 , 265 )
dayMon     <- c ( 30 , 31 , 30 , 31 , 31 , 30  , 31  , 30  , 31  , 31  , 28  , 31  )
hrsmon     <- c ( 730  , 730  ,  730  , 730 , 730 , 730  , 730  , 730 , 730 , 730 , 730  , 730 )
years      <- c ( 2023 , 2024 , 2025 , 2029 , 2034 , 2039 )   
#regions    <- c ( "NR" , "NER" , "ER" , "WR" , "SR" )
etechA      <- c (  "EG_WINDON" , "EG_SOLARGM" , "EG_SOLARRF" , "EG_WINDOFF" )
etechB      <- c (  "EG_SH" , "EG_LH" , "EG_BIOMASS" , "EG_COAL"  ) 
etechC      <- c (  "EG_CCGT"   , "EG_OCGT"    , "EG_PHWR"    , "EG_SMR" )
#ftech      <- c ( "RF_MS" , "RF_HSD" , "RF_ATF" , "RF_LPG"  , "RF_OTHERPP"  , "RF_PETCOKE" , "GH_ELECTROLYSIS" )

###data  
DAT              <- read.csv ( paste ( datIN , "ECT_Max_CUF.csv" , sep = "" )  , header=TRUE , stringsAsFactors = FALSE , fileEncoding = "UTF-8-BOM" )
SC               <- read.csv ( paste ( datIN , "ECT_OperationalInfo.csv" , sep = "" )  , header=TRUE , stringsAsFactors = FALSE , fileEncoding = "UTF-8-BOM" )
SC               <- SC[,-c(3,5,6)]

###process techs with hourly availability (VRE)
TEM              <- subset ( DAT , DAT$EnergyConvTech %in% etechA & DAT$InstYear %in% c ( years , "ALL" ) , select = c ( "EnergyConvTech" , "InstYear" , "SubGeography1" , "Season" , "DaySlice" , "MaxUF"))
##get self consumption and adjust availability
DATa             <- merge ( TEM , SC , by = c ( "EnergyConvTech" , "InstYear" ) , all.x = TRUE ) 
DATa$MaxUF       <- ifelse ( is.na ( DATa$SelfCons) , DATa$MaxUF , DATa$MaxUF * ( 1 - DATa$SelfCons ) )
DATah            <- dcast ( DATa , Season + DaySlice ~ EnergyConvTech + InstYear +SubGeography1 , value.var = "MaxUF" , fun.aggregate = sum )
rm ( TEM )

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

###process techs with monthly availability (add in annual capacity factor constraint until figure out how to model in Macro)
TEM              <- subset ( DAT , DAT$EnergyConvTech %in% etechB , select = c ( "EnergyConvTech" , "SubGeography1" , "Season" , "DaySlice" , "MaxUF"))
SCb              <- subset ( SC , SC$EnergyConvTech %in% etechB & SC$InstYear %in% c ( years ) )
##get self consumption and adjust availability
DATb             <- merge ( TEM , SCb , by = c ( "EnergyConvTech" ) , all.x = TRUE , all.y = TRUE ) 
DATb$MaxUF       <- ifelse ( is.na ( DATb$SelfCons) , DATb$MaxUF , DATb$MaxUF * ( 1 - DATb$SelfCons ) )
DATbh            <- dcast ( DATb , Season ~ EnergyConvTech + InstYear +SubGeography1 , value.var = "MaxUF" , fun.aggregate = sum )
rm ( TEM )

####--Coal adjustment for annual capacity factor--workaround (ECT_EfficiencyCostMaxAnnualUF.csv)
DATbh[8:13] <- lapply ( DATbh[8:13] , function ( x )  x * 0.85 )

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

###process techs with annual availability
TEM             <- subset ( DAT , DAT$EnergyConvTech %in% etechC , select = c ( "EnergyConvTech" , "SubGeography1" , "Season" , "DaySlice" , "MaxUF"))
SCc              <- subset ( SC , SC$EnergyConvTech %in% etechC & SC$InstYear %in% c ( years ) )
##get self consumption and adjust availability
DATc             <- merge ( TEM , SCc , by = c ( "EnergyConvTech"  ) , all.x = TRUE , all.y = TRUE ) 
DATc$MaxUF       <- ifelse ( is.na ( DATc$SelfCons) , DATc$MaxUF , DATc$MaxUF * ( 1 - DATc$SelfCons ) )
DATch            <- dcast ( DATc , Season ~ EnergyConvTech + InstYear +SubGeography1 , value.var = "MaxUF" , fun.aggregate = sum )
rm ( TEM )
####--tech adjustment for annual capacity factor--workaround (ECT_EfficiencyCostMaxAnnualUF.csv)
DATch[2:7]  <- lapply ( DATch[2:7]    , function ( x )  x * 0.85 ) #CCGT
DATch[8:13] <- lapply ( DATch[8:13]   , function ( x )  x * 0.85 ) #OCGT
DATch[14:19] <- lapply ( DATch[14:19] , function ( x )  x * 0.709166667 ) #PHWR
DATch[20:25] <- lapply ( DATch[20:25] , function ( x )  x * 0.709166667 ) #SMR

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

write.csv ( YEAR , file = paste ( datOUT , "availability_PIER8760_" , tag , ".csv" , sep = ""  ) , row.names = FALSE )
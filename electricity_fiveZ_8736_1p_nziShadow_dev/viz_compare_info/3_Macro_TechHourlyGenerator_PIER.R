##   [x].r  - port of pier availabilities to Macro input 8760
##
##   Created:        18 Dec 2025 (for NZI)
##   Last updated:   18 Dec 2025 
##
##   ToDo: 
##

#-----0.ADMIN - Include libraries and other important-----------

###--A. Clean

###--B.Load Library for country manipulations
suppressMessages ( library ( "reshape2"     , lib.loc=.libPaths() ) )      # melt, dcast

###--C.Dirs and Variables

processType <- 1  # 1 = PIER ; 2 = hydro only from Subhadip

period <- 8760

#-----END 0.ADMIN---------------

#-----1.HACK to use PIER availabilities--------------------
  
##utilization factor data source: https://zenodo.org/records/18043483

tag    <- "5Period" ##used in naming of output file
datIN  <- "X://WORK//d1_PROJECTS//p2025_NZI//d0_2code/"
datOUT <- ""

###defs
dhm        <- c ( 1  , 25 , 49 , 73 , 97 , 121 , 145 , 169 , 193 , 217 , 241 , 265 )
dayMon     <- c ( 30 , 31 , 30 , 31 , 31 , 30  , 31  , 30  , 31  , 31  , 28  , 31  )
hrsmon     <- c ( 730  , 730  ,  730  , 730 , 730 , 730  , 730  , 730 , 730 , 730 , 730  , 730 )
years      <- c ( 2023 , 2024 , 2025 , 2029 , 2034 , 2039 )   ##specifies years to be processed from PIER and part of output
#regions    <- c ( "NR" , "NER" , "ER" , "WR" , "SR" )
etechA      <- c (  "EG_WINDON" , "EG_SOLARGM" , "EG_SOLARRF" , "EG_WINDOFF" )
etechB      <- c (  "EG_SH" , "EG_LH" , "EG_BIOMASS" , "EG_COAL"  ) 
etechC      <- c (  "EG_CCGT"   , "EG_OCGT"    , "EG_PHWR"    , "EG_SMR" )
#ftech      <- c ( "RF_MS" , "RF_HSD" , "RF_ATF" , "RF_LPG"  , "RF_OTHERPP"  , "RF_PETCOKE" , "GH_ELECTROLYSIS" )

###data  
DAT              <- read.csv ( paste ( datIN , "../d0_1source/PIER/" , "ECT_Max_CUF.csv" , sep = "" )  , header=TRUE , stringsAsFactors = FALSE , fileEncoding = "UTF-8-BOM" )

###process techs with hourly availability (VRE)
DATa             <- subset ( DAT , DAT$EnergyConvTech %in% etechA & DAT$InstYear %in% c ( years , "ALL" ) , select = c ( "EnergyConvTech" , "InstYear" , "SubGeography1" , "Season" , "DaySlice" , "MaxUF"))
DATah            <- dcast ( DATa , Season + DaySlice ~ EnergyConvTech + InstYear +SubGeography1 , value.var = "MaxUF" , fun.aggregate = sum )

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
DATb             <- subset ( DAT , DAT$EnergyConvTech %in% etechB , select = c ( "EnergyConvTech" , "InstYear" , "SubGeography1" , "Season" , "DaySlice" , "MaxUF"))
DATbh            <- dcast ( DATb , Season ~ EnergyConvTech + InstYear +SubGeography1 , value.var = "MaxUF" , fun.aggregate = sum )
####--Coal adjustment for annual capacity factor--workaround (ECT_EfficiencyCostMaxAnnualUF.csv)
DATbh$EG_COAL_ALL_ALL <- DATbh$EG_COAL_ALL_ALL * 0.85

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
DATc             <- subset ( DAT , DAT$EnergyConvTech %in% etechC , select = c ( "EnergyConvTech" , "InstYear" , "SubGeography1" , "Season" , "DaySlice" , "MaxUF"))
DATch            <- dcast ( DATc , Season ~ EnergyConvTech + InstYear +SubGeography1 , value.var = "MaxUF" , fun.aggregate = sum )
####--tech adjustment for annual capacity factor--workaround (ECT_EfficiencyCostMaxAnnualUF.csv)
DATch$EG_CCGT_ALL_ALL <- DATch$EG_CCGT_ALL_ALL * 0.85
DATch$EG_OCGT_ALL_ALL <- DATch$EG_OCGT_ALL_ALL * 0.85
DATch$EG_PHWR_ALL_ALL <- DATch$EG_PHWR_ALL_ALL * 0.709166667
DATch$EG_SMR_ALL_ALL  <- DATch$EG_SMR_ALL_ALL  * 0.709166667

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


if (processType == 2 ) {
  #-----2.HACK to use a 12 month reference file from Subhadip--------------------
  
  ##hydro data source: https://www.sciencedirect.com/science/article/pii/S1364032123008122
  hrsmon     <- c ( 730  , 730  ,  730  , 730 , 730 , 730  , 730  , 730 , 730 , 730 , 730  , 730 )
  cuf        <- c ( 0.21 , 0.19 ,  0.22 , 0.3 , 0.4 , 0.45 , 0.55 , 0.6 , 0.5 , 0.4 , 0.25 , 0.2 )
  regions    <- c ( "NR" , "NER" , "ER" , "WR" , "SR" )
  
  TEM             <- data.frame ( matrix( 0,8760 , 6  ) )
  names ( TEM )   <- c ( "Time_Index" ,  "NR_hydro" , "NER_hydro" , "ER_hydro" , "WR_hydro" , "SR_hydro" )
  TEM$Time_Index  <- seq (  from = 1 , to = 8760 , by = 1 )
  TEM$NR_hydro    <- c ( rep ( cuf[1] , hrsmon[1] ) , rep ( cuf[2] , hrsmon[2] ) , rep ( cuf[3] , hrsmon[3] ) , rep ( cuf[4]  , hrsmon[4]  ) , rep ( cuf[5]  , hrsmon[5]  ) , rep ( cuf[6]  , hrsmon[6]  ) ,
                         rep ( cuf[7] , hrsmon[7] ) , rep ( cuf[8] , hrsmon[8] ) , rep ( cuf[9] , hrsmon[3] ) , rep ( cuf[10] , hrsmon[10] ) , rep ( cuf[11] , hrsmon[11] ) , rep ( cuf[12] , hrsmon[12] ) )
  TEM$NER_hydro   <- TEM$NR_hydro 
  TEM$ER_hydro    <- TEM$NR_hydro 
  TEM$WR_hydro    <- TEM$NR_hydro 
  TEM$SR_hydro    <- TEM$NR_hydro 
  
  write.csv ( TEM  , "availability.csv"  , row.names = FALSE , na = ""  )
  
  #-----END 2.HACK--------------------
}
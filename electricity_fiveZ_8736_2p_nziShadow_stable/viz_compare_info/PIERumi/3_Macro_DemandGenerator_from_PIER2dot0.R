## NZI_xxx.R  - script built to translate PIER2.0 demand outoputs into MACRO inputs for model building and verification
##  It appears that PEG outputs are in GWH and MACRO inputs are in MWH
##
## Created:       13 August 2025 (ACP)
## Last updated:  13 August 2025, ACP
## Last Updated:  08 May 2026 -- use individual files, place into system folder
##
##
## Problems - workarounds
##  0. 
##  1.


##---0.ADMIN - Clean slate, load libraries, define functions and global variables, set output conditions

##--A.Clean All for a clean slate

setwd( "~/GitHub/NZx_caseDev_MacroEP/electricity_fiveZ_8736_2p_nziShadow_dev/viz_compare_info/PIERumi/" )

##--B.Load Libraries
suppressMessages ( library ( "openxlsx"      , lib.loc=.libPaths() ) )    # excel worksheet functions
suppressMessages ( library ( "reshape2"      , lib.loc=.libPaths() ) )    # melt and dcast functions

##--C.Define Global variables

##location of PIER/RUMI demand output files by energy carrier
period  <- 8760
scenar  <- "4_REF"
ploc    <- paste ( "source/demand_EnergyCarrier_" , scenar , "/" , sep = ""  )
ploc288 <- paste ( "source/demand" , period , "_" , scenar , "/" , "EndUseDemandEnergy.csv" , sep = ""  )
out <- paste ( "../../system/demand/" , sep = "" )

##time defs
years      <- c ( 2024 , 2025 , 2029 , 2034 , 2039 )   
dayMon <- c ( 30 , 31 , 30 , 31 , 31 , 30 , 31 , 30, 31 , 31 , 28 , 31 )
#leap   <- seq ( from = 2024 , to = 2080 , by = 4 ) # not yet integrated

##energy defs
#twh_pj <- 3.6  ##terawatt hours to petajoule


##--D.Geospatial definitions

##--E.Configure, plot, printing and output

##--F.Function definitions (if any)

##--Z. Clean

##---END 0


##----1.HACK A - load electricity EC data in TWh, convert to PJ,  aggregate to Regions from states, and save regional versions of PIER files

if ( period == 8760) {
  files                <- data.frame ( name = list.files (  path = paste ( ploc ,  sep = ""  ) ) )
  #files$DataPack.file  <- gsub ( "_" , "" , substr ( files$name , 12 , 15 ) )
  #files                <- subset ( files , files$DataPack.file %in% ABS$DataPack.file )
  
  ### handle electricity separately as it is hourly rather than yearly as rest of EC are in PIER2.0
  #### generate file structure and order
  TE                  <- read.csv ( paste ( ploc , files$name[which ( files == "ELECTRICITY_Demand.csv" )] , sep = "" ) , header = TRUE , stringsAsFactors = FALSE )
  TE$EnergyDemand     <- TE$EnergyDemand * 1e3  ##from GW to MW
  TEM                 <- aggregate ( EnergyDemand ~ Year + Season + DaySlice + SubGeography1 , data = TE , FUN = sum )
  TEM                 <- TEM[order( TEM$SubGeography1 , TEM$Year , TEM$Season , TEM$DaySlice ) , ]
  TEMP                <- dcast ( TEM , Year + Season + DaySlice ~ SubGeography1  , value.var = "EnergyDemand" )
  names ( TEMP )[4:8] <- sapply ( names ( TEMP[4:8] ) , function ( x ) paste ( "elec_demand_" , x , sep = "" ) ) 
  rm ( TE, TEM )
  #### fill out into yearly demand in 8760 format and save years separately as csvs for macro input
  #i <- 1
  #j <- 1
  for ( i in 1:( length ( years ) ) ) {
   SE  <- subset ( TEMP  , TEMP$Year == years[i] )
   for ( j in 1: length ( unique ( SE$Season ) ) ) { 
     SEM <- subset ( SE  , SE$Season == unique ( SE$Season )[j] )
     SEMP <- data.frame ( do.call ( rbind, replicate ( dayMon[j] , SEM , simplify = FALSE ) ) ) 
     if ( j == 1 ) { YEAR = SEMP }
     if ( j > 1  ) { YEAR = rbind ( YEAR , SEMP ) }
   }
   YEARm <- YEAR [,-(1:3)]
   write.csv ( YEARm , file = paste ( out , years[i] , ".csv" , sep = ""  ) , row.names = FALSE )
  }
  rm ( i , j , SE , SEM , SEMP )
}
if ( period == 288) {
  ### handle electricity separately as it is hourly rather than yearly as rest of EC are in PIER2.0
  #### generate file structure and order
  TE                  <- read.csv ( paste ( ploc288 , sep = "" ) , header = TRUE , stringsAsFactors = FALSE )
  #TE                  <- subset ( TE , Year == 2024 & EnergyCarrier == "ELECTRICITY" )
  TE                  <- subset ( TE , EnergyCarrier == "ELECTRICITY" )
  TE$EnergyDemand     <- TE$EndUseDemandEnergy * 1e3  ##from GWh to MWh
  TEM                 <- aggregate ( EnergyDemand ~ Year + Season + DaySlice + SubGeography1 , data = TE , FUN = sum )
  TEM                 <- TEM[order( TEM$SubGeography1 , TEM$Year , TEM$Season , TEM$DaySlice ) , ]
  TEMP                <- dcast ( TEM , Year + Season + DaySlice ~ SubGeography1  , value.var = "EnergyDemand" )
  names ( TEMP )[4:8] <- sapply ( names ( TEMP[4:8] ) , function ( x ) paste ( "elec_demand_" , x , sep = "" ) ) 
  rm ( TE, TEM )
  #### fill out into yearly demand in 8760 format and save years separately as csvs for macro input
  i <- 1
  #j <- 1
  for ( i in 1:( length ( years ) ) ) {
    SE  <- subset ( TEMP  , TEMP$Year == years[i] )
    YEARm <- SE [,-(1:3)]
    write.csv ( YEARm , file = paste ( out , years[i] , ".csv" , sep = ""  ) , row.names = FALSE )
  }
  rm ( i , SE , TEMP   )
}

##create demand file for specified period run
##for ( k in 1:( length ( years ) ) ) {
##  TE                  <- read.csv ( paste ( out , years[k] , ".csv" , sep = ""  ) , header = TRUE , stringsAsFactors = FALSE )
##  names ( TE )        <- sapply ( names ( TE ) , function ( x ) paste ( x , "_p20_" , years[k] , sep = "" ) ) 
##  if ( k == 1 ) { TEM = TE }
##  if ( k > 1  ) { TEM = cbind ( TEM , TE ) }             
##}
##write.csv ( TEM , file = paste ( out , "demand_" , period , "_" , length ( years ) ,  "period.csv" , sep = ""  ) , row.names = FALSE )

##rm ( k , TE , TEM )

#### remove electricity from files to be processed
files <- data.frame( files[-(which ( files == "ELECTRICITY_Demand.csv" )),] )

##----END 1

##----2.HACK B - load next most granular EC data, aggregate to Regions from states, and save regional versions of PIER files

##----END 2

##----3.HACK C - load next most granular EC data, aggregate to Regions from states, and save regional versions of PIER files

##----END 3
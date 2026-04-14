##   PIER_costs_aggregate.r  - 
##
##   Created:       31 March 2026
##   Last updated:  31 March 2026
##
##   ToDo:
##        0. !

#-----0.ADMIN - Include libraries and other important-----------

setwd("C://Users//apascale//OneDrive - Princeton University//Documents//GitHub//NZx_caseDev_MacroEP//electricity_fiveZ_8736_1p_nziShadow//viz_compare_info//")

##--A. Clean
# 1.Remove only selected variables if wanted, otherwise remove all, Create basic plot, assign output to a variable and then remove variable
rm(list = setdiff ( ls() , "") )
plot(1.1)
hide<-dev.off()
rm(hide)

##--B.Load Library for country manipulations
suppressMessages ( library ( "reshape2"     , lib.loc=.libPaths() ) )      # melt, dcast
#suppressMessages ( library ( "ggplot2"      , lib.loc=.libPaths() ) )      # geom_col

##--C. Global var

#dir settings
pierD     <- "X://WORK//d1_PROJECTS//p2025_NZI//d0_5pier//PIER20_latest_Feb2026//Scenarios//8_REF_Unconstr//Supply//Output_pier20//Run-Outputs//"
csvaIN     <- c ( "CostOfCarrier"         , "CostOfStorage"         , "ECTFixedCost"       )
csvaLab    <- c ( "AnnualCarrierCost.csv" , "AnnualStorageCost.csv" , "AnnualECTCost.csv"  )
csvbIN     <- c ( "ECTransitCost" , "ECTInputVarCost" )
csvbLab    <- c ( "carrierTransit", "technologyVariable" )
csvcIN     <- c ( "AnnualCost"  )
csvcLab    <- c ( "AnnualCost.csv" )

dayMon <- c ( 30 , 31 , 30 , 31 , 31 , 30 , 31 , 30, 31 , 31 , 28 , 31 )

lev    <- "level2"



#-----END 0.ADMIN---------------


#-----1.HACK--------------------
  
##read in relevant cost outputs from PIER
#i <- 6
for ( i in 1:( length ( csvaIN ) ) ) {
  DAT              <- read.csv ( paste ( pierD , csvaIN[i] , ".csv" , sep = "" )  , header=TRUE , stringsAsFactors = FALSE , fileEncoding = "UTF-8-BOM" )
  names ( DAT )    <- c ( "type" , "year" , "cost" )
  DAT$category     <- csvaLab[i]
  if ( i == 1 ) { COST <- DAT }
  if ( i >  1 ) { COST <- rbind ( COST , DAT ) }
}
rm ( i , DAT )

##read in transit costs
#DAT   <- read.csv ( paste ( pierD , csvbIN , ".csv" , sep = "" )  , header=TRUE , stringsAsFactors = FALSE , fileEncoding = "UTF-8-BOM" )
#DATa  <- subset ( DAT ,  DAT$Season == "" )
#DATb  <- subset ( DAT , !DAT$Season == "" )
###annual files
#DATah <- dcast ( DATa , EnergyCarrier ~ Year , value.var = "ECTransitCost" , fun.aggregate = sum )
#DAT   <- melt ( DATah , id.vars = 1 , measure.vars = 2:19 , variable.name = "year" , value.name = "cost" )
#names ( DAT )    <- c ( "type" , "year" , "cost" )
#DAT$category     <- csvbLab
#COST <- rbind ( COST , DAT )
#rm ( DAT , DATa , DATah )
###hourly file
#DATb$days <- dayMon[as.numeric ( gsub ("S|S0|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|Jan|Feb|Mar", "" , DATb$Season ) )]
#DATb$cost <- DATb$ECTransitCost * DATb$days
#DATbh <- dcast ( DATb , EnergyCarrier ~ Year , value.var = "cost" , fun.aggregate = sum )
#DAT   <- melt ( DATbh , id.vars = 1 , measure.vars = 2:19 , variable.name = "year" , value.name = "cost" )
#names ( DAT )    <- c ( "type" , "year" , "cost" )
#DAT$category     <- csvbLab
#COST <- rbind ( COST , DAT )
#rm ( DAT , DATb , DATbh )

##read in total costs for checking internally
DAT   <- read.csv ( paste ( pierD , csvcIN , ".csv" , sep = "" )  , header=TRUE , stringsAsFactors = FALSE , fileEncoding = "UTF-8-BOM" )
DAT$type <- "all"
DAT      <- DAT[, c(3,1,2)]
names ( DAT )    <- c ( "type" , "year" , "cost" )
DAT$category     <- csvcLab
COST <- rbind ( COST , DAT )
rm ( DAT )


write.csv ( COST  , paste ( "1_PIER_8RefUnconstr_costs_" , lev , ".csv" , sep = "" ) , row.names = FALSE , na = "" )

rm ( COST )


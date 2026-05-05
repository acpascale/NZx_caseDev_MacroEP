##   Macro_plots.r  - 
##
##   Created:       20 February 2022 (ggplot2 template from NZAu)
##   Updated:       24 March 2026 to make plots from Macro outputs
##   Updated:       05 May 2026 to expand to multiple periods (individual)
##
##   ToDo:
##        0. Merge with prior code for plotting of multiple periods

#-----0.ADMIN - Include libraries and other important-----------

setwd("~/GitHub/NZx_caseDev_MacroEP/")

##--A. Clean
#1.Remove only selected variables if wanted, otherwise remove all, Create basic plot, assign output to a variable and then remove variable
rm(list = setdiff ( ls() , "") )
plot(1.1)
hide<-dev.off()
rm(hide)

##--B.Load Library for country manipulations
suppressMessages ( library ( "reshape2"     , lib.loc=.libPaths() ) )      # melt, dcast
suppressMessages ( library ( "ggplot2"      , lib.loc=.libPaths() ) )      # geom_col

##--C. Global var
case    <- "electricity_fiveZ_8736_2p_nziShadow_dev"
run     <- "results_2p_20260505"
outhrs  <- 8736
periods <- 2

#plot types
primEdg    <- c ( "fuel" , "wind" , "GM" , "RT" , "discharge" )
primary    <- c ( "coal" , "diesel" , "NG" , "nuclear" , "biomass" , "wind" , "solar"  , "conventional_hydroelectric" )
elecEdg    <- c ( "wind" , "GM" , "RT" , "discharge" , "elec" )

#https://r-graph-gallery.com/ggplot2-color.html
Ttype      <- c ( "hydroelectric" , "hydroelectric_small" , "nuclear_PHWR" , "nuclear_SMR" , "biomass" , "coal" , "NG_CCGT" , "NG_OCGT" , "onshore_wind" , "offshore_wind" , "solar_GM" , "solar_RT" )
Ctype      <- c ( "NG_OCGT" , "NG_CCGT" , "biomass" , "coal" , "nuclear_PHWR" , "nuclear_SMR" )
Etype      <- c ( "battery" , "pumpedhydro" , "hydroelectric" , "hydroelectric_small" , "nuclear_PHWR" , "nuclear_SMR" , "biomass" , "coal" , "NG_CCGT" , "NG_OCGT" , "onshore_wind" , "offshore_wind" , "solar_GM" , "solar_RT" )
Ttype_colMap  <- c ( "solar_RT" = "orange1" , "solar_GM" = "orange3" , "offshore_wind" = "blue" , "onshore_wind" = "blue3" , "coal" = "grey" , "NG_OCGT" = "green" , "NG_CCGT" = "green4" , 
                  "biomass" = "red4" , "nuclear_SMR" = "yellow1" , "nuclear_PHWR" = "yellow3" , "hydroelectric_small" = "purple2" , "hydroelectric" = "purple4" , "pumpedhydro" = "lightblue1" , "battery" = "brown" )

#hours to weeks -- India Financial Year starts in April and ends in March
dayMon     <- c ( 30 , 31 , 30 , 31 , 31 , 30 , 31 , 30, 31 , 31 , 28 , 31 )
h2w        <- data.frame( time = seq ( from = 1 , to = 8760 , by = 1 ) , week = c( rep ( 1:52 , each = 7*24 ) , rep ( 52 , 24 ) ) )

#spatial
regions    <- c ( "NR"     , "NER"        , "WR"     , "ER"   , "SR"      )
regCol     <- c ( "NR" = "green4" , "NER" = "lightblue1" , "WR"= "purple" , "ER" = "blue" , "SR" = "yellow3" )

#plot settings
wdth          <- 1920
hgth          <- 1080

#-----END 0.ADMIN---------------


#-----1.HACK--------------------

##loop for individual periods
k <- 1 ##debug
for ( k in 1:periods ) {
  
  ##combined plot - with export
  FLO               <- read.csv ( paste ( case , "/results/" , run , "/results_period_" , k , "/flows.csv"    , sep = "" )            , header=TRUE , stringsAsFactors = FALSE , fileEncoding = "UTF-8-BOM" )
  CAP               <- read.csv ( paste ( case , "/results/" , run , "/results_period_" , k , "/capacity.csv" , sep = "" )            , header=TRUE , stringsAsFactors = FALSE , fileEncoding = "UTF-8-BOM" )
  FIN               <- read.csv ( paste ( case , "/results/" , run , "/results_period_" , k , "/undiscounted_costs.csv" , sep = "" )  , header=TRUE , stringsAsFactors = FALSE , fileEncoding = "UTF-8-BOM" )
  
  
  #---PLOT1&2 Natrional Hourly and weekly Primary Energy for 8760 results from Flow.csv---
  #order and apply plotting thresholds
  FLOt     <- subset ( FLO , grepl ( paste ( primary , collapse = '|' ) , FLO$component_id ) & grepl ( paste ( primEdg , collapse = '|' ) , FLO$component_id ) )
  FLOp     <- merge ( FLOt , h2w , by = "time" , all.x = TRUE )
  #unique (FLOp$commodity)
  rm ( FLOt  ) 
  
  #assign colors to plot
  FLOp$resource <- gsub ( "^[^_]*_|conventional_|_legacy" , "" , FLOp$resource_id )
  #FLOp$col      <- sapply ( FLOp$resource , function (x) Ttype_col[ which ( Ttype == x ) ] )
  FLOp$val      <- ifelse ( FLOp$resource %in% Ctype , - FLOp$value / 1e3 , FLOp$value / 1e3  ) 
  #debug
  
  # vertical barplot -hourly
  HOR   <- dcast ( FLOp , resource ~ time  , value.var = "val" , sum )
  HOUR  <- melt ( HOR , id.vars = 1 , measure.vars = 2:8737 , variable.name = "time" , value.name = "val" , factorsAsStrings = FALSE )
  HOUR$time <- as.numeric( HOUR$time )
    
  p <- ggplot ( HOUR , aes(time , val , fill = factor( resource , levels = rev ( Ttype ) ) ) ) +
    geom_col( ) +
    ggtitle( bquote ( "Primary Energy (national, hourly) [flow.csv]" ) ) + 
    xlab ( "hour of year") + # for the x axis label
    ylab ( "GWh") +
    scale_y_continuous ( breaks = seq ( 0 , 550 , by = 50 ) )  +
    scale_x_continuous ( breaks = seq ( 0 , 8736 , by = 672 ) , expand = c(0, 0) )  +
    scale_fill_manual( values = Ttype_colMap ) +
    guides (fill=guide_legend(nrow=2,byrow=TRUE) ) +
    theme_bw () +
    theme ( 
      plot.title = element_text( size = 10 ) ,
      legend.position = "bottom" ,
      axis.title.x=element_text( size = 6 ) ,
      axis.title.y=element_text( size = 6 ) ,
      axis.text = element_text ( size = 6 ) ,
      legend.title=element_blank() ,
      legend.text=element_text( size = 6) ,
      legend.key.size = unit ( 0.3 , "cm" )
    )
  #p
  ggsave ( paste (  case , "/viz_compare_info/rplots/p"  , k , "_", "nationalPrimaryEnergy" , "_hour" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
  write.csv ( HOR  , paste ( case , "/viz_compare_info/rplots/p"  , k , "_", "nationalPrimaryEnergy" , "_hour_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )
  
  # vertical barplot - weekly 
  WEK   <- dcast ( FLOp , resource ~ week  , value.var = "val" , sum )
  WEEK  <- melt ( WEK , id.vars = 1 , measure.vars = 2:53 , variable.name = "week" , value.name = "val" , factorsAsStrings = FALSE )
  
  p <- ggplot ( WEEK , aes(week , val / 1e3 , fill = factor( resource , levels = rev ( Ttype ) ) ) ) +
    geom_col( ) +
    ggtitle( bquote ( "Primary Energy (national, weekly) [flow.csv]" ) ) + 
    xlab( "week of year") + # for the x axis label
    ylab( "TWh") +
    scale_y_continuous ( breaks = seq ( 0 , 110 , by = 5 ) )  +
    scale_fill_manual( values = Ttype_colMap ) +
    guides (fill=guide_legend(nrow=2,byrow=TRUE) ) +
    theme_bw () +
    theme ( 
      plot.title = element_text( size = 10 )  ,
      legend.position = "bottom" ,
      axis.title.x=element_text( size = 6 ) ,
      axis.title.y=element_text( size = 6 ) ,
      axis.text = element_text ( size = 6 ) ,
      legend.title=element_blank() ,
      legend.text=element_text( size = 6) ,
      legend.key.size = unit ( 0.3 , "cm" )
    )
  #p
  ggsave    ( paste (  case , "/viz_compare_info/rplots/p"  , k , "_", "nationalPrimaryEnergy" , "_week" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
  write.csv ( WEK  , paste ( case , "/viz_compare_info/rplots/p"  , k , "_", "nationalPrimaryEnergy" , "_week_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )
  rm ( p , WEK , WEEK , HOR , HOUR, FLOp )
  
  
  
  #---PLOT3&4 Natrional Hourly and weekly Electricity for 8760 results from Flow.csv---
  FLOt <- subset ( FLO , grepl ( "elec" , FLO$node_out ) & !grepl( "transmission" , FLO$component_id ) & grepl ( paste ( elecEdg , collapse = '|' ) , FLO$component_id ) & !grepl ( "inflow" , FLO$component_id )  )
  FLOe     <- merge ( FLOt , h2w , by = "time" , all.x = TRUE )
  #unique (FLOe$commodity)
  rm ( FLOt ) 
  
  #assign colors to plot
  FLOe$resource <- gsub ( "^[^_]*_|conventional_|_legacy" , "" , FLOe$resource_id )
  #unique ( FLOe$resource )
  #FLOe$col      <- sapply ( FLOe$resource , function (x) ETtype_col[ which ( Etype == x ) ] )
  FLOe$val      <- FLOe$value / 1e3  
  FLOe$reg      <- gsub ( "^[^_]*_" , "" , FLOe$node_out )
  #debug
  
  
  # vertical barplot -hourly
  HOR   <- dcast ( FLOe , resource ~ time  , value.var = "val" , sum )
  HOUR  <- melt ( HOR , id.vars = 1 , measure.vars = 2:8737 , variable.name = "time" , value.name = "val" , factorsAsStrings = FALSE )
  HOUR$time <- as.numeric( HOUR$time )
  
  p <- ggplot ( HOUR , aes(time , val , fill = factor( resource , levels = rev ( Ttype ) ) ) ) +
    geom_col( ) +
    ggtitle( bquote ( "Electricity (national, hourly) [flow.csv]" ) ) + 
    xlab ( "hour of year") + # for the x axis label
    ylab ( "GWh") +
    scale_y_continuous ( breaks = seq ( 0 , 300 , by = 25 ) , expand = c(0, 0) )  +
    scale_x_continuous ( breaks = seq ( 0 , 8736 , by = 672 ) , expand = c(0, 0) )  +
    scale_fill_manual( values = Ttype_colMap ) +
    guides (fill=guide_legend(nrow=2,byrow=TRUE) ) +
    theme_bw () +
    theme ( 
      plot.title = element_text( size = 10 ) ,
      legend.position = "bottom" ,
      axis.title.x=element_text( size = 6 ) ,
      axis.title.y=element_text( size = 6 ) ,
      axis.text = element_text ( size = 6 ) ,
      legend.title=element_blank() ,
      legend.text=element_text( size = 6) ,
      legend.key.size = unit ( 0.3 , "cm" )
    )
  #p
  ggsave ( paste (  case , "/viz_compare_info/rplots/p"  , k , "_", "nationalElectricity" , "_hour" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
  write.csv ( HOR  , paste ( case , "/viz_compare_info/rplots/p"  , k , "_", "nationalElectricity" , "_hour_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )
  
  # vertical barplot - weekly by type
  WEK   <- dcast ( FLOe , resource ~ week  , value.var = "val" , sum )
  WEEK  <- melt ( WEK , id.vars = 1 , measure.vars = 2:53 , variable.name = "week" , value.name = "val" , factorsAsStrings = FALSE )
  
  p <- ggplot ( WEEK , aes(week , val / 1e3 , fill = factor( resource , levels = rev ( Ttype ) ) ) ) +
    geom_col( ) +
    ggtitle( bquote ( "Electricity (national, weekly) [flow.csv]" ) ) + 
    xlab( "week of year") + # for the x axis label
    ylab( "TWh") +
    scale_y_continuous ( breaks = seq ( 0 , 50 , by = 5 ) , expand = c(0, 0) )  +
    scale_fill_manual( values = Ttype_colMap ) +
    guides (fill=guide_legend(nrow=2,byrow=TRUE) ) +
    theme_bw () +
    theme ( 
      plot.title = element_text( size = 10 )  ,
      legend.position = "bottom" ,
      axis.title.x=element_text( size = 6 ) ,
      axis.title.y=element_text( size = 6 ) ,
      axis.text = element_text ( size = 6 ) ,
      legend.title=element_blank() ,
      legend.text=element_text( size = 6) ,
      legend.key.size = unit ( 0.3 , "cm" )
    )
  #p
  ggsave    ( paste (  case , "/viz_compare_info/rplots/p"  , k , "_", "nationalElectricity" , "_type_week" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
  write.csv ( WEK  , paste ( case , "/viz_compare_info/rplots/p"  , k , "_", "nationalElectricity" , "_type_week_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )
  
  # vertical barplot - weekly - by region 
  WEK   <- dcast ( FLOe , reg ~ week  , value.var = "val" , sum )
  WEEK  <- melt ( WEK , id.vars = 1:1 , measure.vars = 2:53 , variable.name = "week" , value.name = "val" , factorsAsStrings = FALSE )
  
  p <- ggplot ( WEEK , aes(week , val / 1e3 , fill = factor( reg , levels = rev ( regions ) ) ) ) +
    geom_col( ) +
    ggtitle( bquote ( "Electricity (national, weekly, by region) [flow.csv]" ) ) + 
    xlab( "week of year") + # for the x axis label
    ylab( "TWh") +
    scale_y_continuous ( breaks = seq ( 0 , 50 , by = 5 ) , expand = c(0, 0) )  +
    scale_fill_manual( values = regCol ) +
    guides (fill=guide_legend(nrow=2,byrow=TRUE) ) +
    theme_bw () +
    theme ( 
      plot.title = element_text( size = 10 )  ,
      legend.position = "bottom" ,
      axis.title.x=element_text( size = 6 ) ,
      axis.title.y=element_text( size = 6 ) ,
      axis.text = element_text ( size = 6 ) ,
      legend.title=element_blank() ,
      legend.text=element_text( size = 6) ,
      legend.key.size = unit ( 0.3 , "cm" )
    )
  #p
  ggsave    ( paste (  case , "/viz_compare_info/rplots/p"  , k , "_", "nationalElectricity" , "_region_week" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
  write.csv ( WEK  , paste ( case , "/viz_compare_info/rplots/p"  , k , "_", "nationalElectricity" , "_region_week_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )
  
  
  rm ( p , WEK , WEEK , HOR , HOUR  )
}

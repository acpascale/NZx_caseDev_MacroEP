##   Macro_plots.r  - 
##
##   Created:       20 February 2022 (ggplot2 template from NZAu)
##   Updated:       24 March 2026 to make plots from Macro outputs
##   Updated:       05 May 2026 to expand to multiple periods (individual)
##   Updated:       06/07 May 2026 merged with prior code for combined plotting of period - focused on flows.csv as capacity and cost files are small enough tobe done easily in excel 
##
##   ToDo:
##        0.

#-----0.ADMIN - Include libraries and other important-----------

#change this directory to your own
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
case    <- "electricity_fiveZ_8736_2p_nziShadow_dev"  ##name of Macro case folder
run     <- "results_2p_20260505"                      ##name of folder/subfolder with the period-wise Macro results to be plotted 
outhrs  <- 8736                                       ##hours covered in those results
periods <- 2                                          ##periods to be plotted --as these increase, plots will need adjusting to make sure all periods + legend fit

assets <- c ( "flows" ) ##  "capacity" , "undiscounted_costs_by_type"    -- fo each added will need to add additional plot code

#plot types
primEdg    <- c ( "fuel" , "wind" , "GM" , "RT" , "discharge" )
primary    <- c ( "coal" , "diesel" , "NG" , "nuclear" , "biomass" , "wind" , "solar"  , "conventional_hydroelectric" )
elecEdg    <- c ( "wind" , "GM" , "RT" , "discharge" , "elec" )

#https://r-graph-gallery.com/ggplot2-color.html
Ttype        <- c ( "hydroelectric" , "hydroelectric_small" , "nuclear_PHWR" , "nuclear_SMR" , "biomass" , "coal" , "NG_CCGT" , "NG_OCGT" , "onshore_wind" , "offshore_wind" , "solar_GM" , "solar_RT" )
Ctype        <- c ( "NG_OCGT" , "NG_CCGT" , "biomass" , "coal" , "nuclear_PHWR" , "nuclear_SMR" )
Etype        <- c ( "battery" , "pumpedhydro" , "hydroelectric" , "hydroelectric_small" , "nuclear_PHWR" , "nuclear_SMR" , "biomass" , "coal" , "NG_CCGT" , "NG_OCGT" , "onshore_wind" , "offshore_wind" , "solar_GM" , "solar_RT" )
type_colMap  <- c ( "solar_RT" = "orange1" , "solar_GM" = "orange3" , "offshore_wind" = "lightblue3" , "onshore_wind" = "lightblue4" , "coal" = "grey" , "NG_OCGT" = "green" , "NG_CCGT" = "green4" , 
                  "biomass" = "red4" , "nuclear_SMR" = "yellow1" , "nuclear_PHWR" = "yellow3" , "hydroelectric_small" = "purple1" , "hydroelectric" = "purple2" , "pumpedhydro" = "lightblue1" , "battery" = "brown" )

#hours to weeks -- India Financial Year starts in April and ends in March
dayMon     <- c ( 30 , 31 , 30 , 31 , 31 , 30 , 31 , 30, 31 , 31 , 28 , 31 )
h2w        <- data.frame( time = seq ( from = 1 , to = 8760 , by = 1 ) , week = c( rep ( 1:52 , each = 7*24 ) , rep ( 52 , 24 ) ) )

#spatial
regions    <- c ( "NR"     , "NER"        , "WR"     , "ER"   , "SR"      )
regCol     <- c ( "NR" = "green4" , "NER" = "lightblue1" , "WR"= "purple" , "ER" = "blue" , "SR" = "yellow3" )

#plot aspect ratio set for widescreen pptx sides
wdth          <- 1920
hgth          <- 1080

#-----END 0.ADMIN---------------


#-----1.HACK--------------------
##create output folder -- change to preffered location.. I have inside results folder
dir.create ( file.path ( paste ( case , "/results/" , run , "/" , "results_visualization" , sep = "" ) ) , showWarnings = FALSE ) 


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
    ggtitle( bquote ( "Period"~.(k)*": Primary energy (national, hourly) [flow.csv]" ) ) + 
    xlab ( "hour of year") + # for the x axis label
    ylab ( "GWh") +
    scale_y_continuous ( limits = c ( 0 , NA ) , breaks = seq ( 0 , 1000 , by = 50 ) , expand = c ( 0 , 0 ) )  +
    scale_x_continuous ( breaks = seq ( 0 , 8736 , by = 672 ) , expand = c ( 0 , 0 ) )  +
    scale_fill_manual( values = type_colMap ) +
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
  ggsave ( paste (  case , "/results/" , run , "/" , "results_visualization" , "/p"  , k , "_", "nationalPrimaryEnergy" , "_hour" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
  write.csv ( HOR  , paste ( case , "/results/" , run , "/" , "results_visualization" , "/p"  , k , "_", "nationalPrimaryEnergy" , "_hour_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )
  
  # vertical barplot - weekly 
  WEK   <- dcast ( FLOp , resource ~ week  , value.var = "val" , sum )
  WEEK  <- melt ( WEK , id.vars = 1 , measure.vars = 2:53 , variable.name = "week" , value.name = "val" , factorsAsStrings = FALSE )
  
  p <- ggplot ( WEEK , aes(week , val / 1e3 , fill = factor( resource , levels = rev ( Ttype ) ) ) ) +
    geom_col( ) +
    ggtitle( bquote ( "Period"~.(k)*": Primary Energy (national, weekly) [flow.csv]" ) ) + 
    xlab( "week of year") + # for the x axis label
    ylab( "TWh") +
    scale_y_continuous ( limits = c ( 0 , NA ) , breaks = seq ( 0 , 1000 , by = 5 ) , expand = c ( 0 , 0 ) )  +
    scale_fill_manual( values = type_colMap ) +
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
  ggsave    ( paste (  case , "/results/" , run , "/" , "results_visualization" , "/p"  , k , "_", "nationalPrimaryEnergy" , "_week" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
  write.csv ( WEK  , paste ( case , "/results/" , run , "/" , "results_visualization" , "/p"  , k , "_", "nationalPrimaryEnergy" , "_week_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )
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
    ggtitle( bquote ( "Period"~.(k)*": Electricity (national, hourly) [flow.csv]" ) ) + 
    xlab ( "hour of year") + # for the x axis label
    ylab ( "GWh") +
    scale_y_continuous ( limits = c ( 0 , NA ) , breaks = seq ( 0 , 300 , by = 25 ) , expand = c ( 0 , 0 ) )  +
    scale_x_continuous ( breaks = seq ( 0 , 8736 , by = 672 ) , expand = c ( 0 , 0 ) )  +
    scale_fill_manual( values = type_colMap ) +
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
  ggsave ( paste (  case , "/results/" , run , "/" , "results_visualization" , "/p"  , k , "_", "nationalElectricity" , "_hour" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
  write.csv ( HOR  , paste ( case , "/results/" , run , "/" , "results_visualization" , "/p"  , k , "_", "nationalElectricity" , "_hour_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )
  
  # vertical barplot - weekly by type
  WEK   <- dcast ( FLOe , resource ~ week  , value.var = "val" , sum )
  WEEK  <- melt ( WEK , id.vars = 1 , measure.vars = 2:53 , variable.name = "week" , value.name = "val" , factorsAsStrings = FALSE )
  
  p <- ggplot ( WEEK , aes(week , val / 1e3 , fill = factor( resource , levels = rev ( Ttype ) ) ) ) +
    geom_col( ) +
    ggtitle( bquote ( "Period"~.(k)*": Electricity (national, weekly) [flow.csv]" ) ) + 
    xlab( "week of year") + # for the x axis label
    ylab( "TWh") +
    scale_y_continuous ( limits = c ( 0 , NA ) , breaks = seq ( 0 , 50 , by = 5 ) , expand = c ( 0 , 0 ) )  +
    scale_fill_manual( values = type_colMap ) +
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
  ggsave    ( paste (  case , "/results/" , run , "/" , "results_visualization" , "/p"  , k , "_", "nationalElectricity" , "_type_week" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
  write.csv ( WEK  , paste ( case , "/results/" , run , "/" , "results_visualization" , "/p"  , k , "_", "nationalElectricity" , "_type_week_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )
  
  # vertical barplot - weekly - by region 
  WEK   <- dcast ( FLOe , reg ~ week  , value.var = "val" , sum )
  WEEK  <- melt ( WEK , id.vars = 1:1 , measure.vars = 2:53 , variable.name = "week" , value.name = "val" , factorsAsStrings = FALSE )
  
  p <- ggplot ( WEEK , aes(week , val / 1e3 , fill = factor( reg , levels = rev ( regions ) ) ) ) +
    geom_col( ) +
    ggtitle( bquote ( "Period"~.(k)*": Electricity (national, weekly, by region) [flow.csv]" ) ) + 
    xlab( "week of year") + # for the x axis label
    ylab( "TWh") +
    scale_y_continuous ( limits = c ( 0 , NA ) , breaks = seq ( 0 , 50 , by = 5 ) , expand = c ( 0 , 0 ) )  +
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
  ggsave    ( paste (  case , "/results/" , run , "/" , "results_visualization" , "/p"  , k , "_", "nationalElectricity" , "_region_week" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
  write.csv ( WEK  , paste ( case , "/results/" , run , "/" , "results_visualization" , "/p"  , k , "_", "nationalElectricity" , "_region_week_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )
  
  
  rm ( p , WEK , WEEK , HOR , HOUR  )
}

##code for the combining of period outputs for multi-period plotting

files                <- data.frame ( name = list.files (  path = paste ( case ,  "/results/" , run ,  sep = ""  ) , recursive = TRUE ) )

#i<-1
for ( i in 1:( length ( assets ) ) ) {
  toAgg                <- subset ( files , grepl ( paste ( assets[i] , ".csv" , sep = "" ) , files$name ) )
  
  j <- 1
  for ( j in 1:( nrow ( toAgg ) ) ) {
    TE                  <- read.csv ( paste ( case , "/results/" , run , "/" , toAgg$name[j] , sep = "" ) , header = TRUE , stringsAsFactors = FALSE )
    TE$period           <- j
    if ( j == 1 ) { AGG = TE }
    if ( j > 1  ) { AGG = rbind ( AGG , TE ) }
  }
  
  write.csv ( AGG , file = paste ( case , "/results/" , run , "/results_visualization/" , assets[i] , "_periods" , j ,  ".csv" , sep = ""  ) , row.names = FALSE )
  rm ( j , TE , toAgg )
}
rm ( i , files )

##flow in memory as AGG, flow plots first 
###primary energy for generation,vertical barplot - period-wise
FLOp <- subset ( AGG , grepl ( paste ( primary , collapse = '|' ) , AGG$component_id ) & grepl ( paste ( primEdg , collapse = '|' ) , AGG$component_id ) )
FLOp$resource <- gsub ( "^[^_]*_|conventional_|_legacy" , "" , FLOp$resource_id )
FLOp$val      <- ifelse ( FLOp$resource %in% Ctype , - FLOp$value / 1e6 , FLOp$value / 1e6  )

GE      <- dcast ( FLOp , resource ~ period  , value.var = "val" , sum )
GEN     <- melt ( GE , id.vars = 1 , measure.vars = 2:(1+periods) , variable.name = "period" , value.name = "val" , factorsAsStrings = FALSE )
GEN$val <- sapply ( GEN$val , function (x) ifelse ( x < 3 , NA , x ) )

p <- ggplot ( GEN , aes(period , val , fill = factor( resource , levels = rev ( Ttype ) ) , label = round ( val , 0 ) ) ) +
  geom_col( width = 0.5 ) +
  #coord_flip() +  ##horizontal bars
  #coord_polar(theta = "y") +  ##pie plots
  ggtitle( bquote ( "Primary Energy for electricity generation by type, national [flow.csv]" ) ) + 
  xlab ( "period") + # for the x axis label
  ylab ( "GWh") +
  scale_y_continuous ( limits = c ( 0 , NA ) , breaks = seq ( 0 , 4500 , by = 500 ) , expand = c ( 0 , 0 ) )  +
  #scale_x_continuous ( breaks = seq ( 0 , 8736 , by = 672 ) , expand = c(0, 0) )  +
  scale_fill_manual( values = type_colMap ) +
  guides ( fill = guide_legend ( ncol = 2 , byrow = TRUE ) ) +
  geom_text( position = position_stack(vjust = 0.5) , size = 1.4 , check_overlap = TRUE , fontface= "bold" , colour = "grey1"  ) +
  theme_bw () +
  theme ( 
    plot.title = element_text( size = 10 ) ,
    legend.position = "right" ,
    axis.title.x=element_text( size = 6 ) ,
    axis.title.y=element_text( size = 6 ) ,
    axis.text = element_text ( size = 6 ) ,
    legend.title=element_blank() ,
    legend.text=element_text( size = 6) ,
    legend.key.size = unit ( 0.3 , "cm" )
  )
#p
ggsave ( paste (  case , "/results/" , run , "/" , "results_visualization" , "/Allp" , "_" , "nationalPrimaryEnergy" , "_period" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
write.csv ( GEN  , paste ( case , "/results/" , run , "/" , "results_visualization" , "/Allp"  , "_" , "nationalPrimaryEnergy" , "_period_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )


###generation plot,vertical barplot - period-wise
FLOp <- subset ( AGG , grepl ( "elec" , AGG$node_out ) & !grepl( "transmission" , AGG$component_id ) & grepl ( paste ( elecEdg , collapse = '|' ) , AGG$component_id ) & !grepl ( "inflow" , AGG$component_id )  )
FLOp$resource <- gsub ( "^[^_]*_|conventional_|_legacy" , "" , FLOp$resource_id )
FLOp$val      <- FLOp$value / 1e6  

GE       <- dcast ( FLOp , resource ~ period  , value.var = "val" , sum )
GEN      <- melt ( GE , id.vars = 1 , measure.vars = 2:(1+periods) , variable.name = "period" , value.name = "val" , factorsAsStrings = FALSE )
GEN$val  <- sapply ( GEN$val , function (x) ifelse ( x < 3 , NA , x ) ) 

p <- ggplot ( GEN , aes(period , val , fill = factor( resource , levels = rev ( Etype ) ) , label = round ( val , 0 ) ) ) +
  geom_col( width = 0.5 ) +
  #coord_flip() +  ##horizontal bars
  #coord_polar(theta = "y") +  ##pie plots
  ggtitle( bquote ( "Electricity generation by type, national [flow.csv]" ) ) + 
  xlab ( "period") + # for the x axis label
  ylab ( "GWh") +
  scale_y_continuous ( limits = c ( 0 , NA ) , breaks = seq ( 0 , 2000 , by = 200 ) , expand = c ( 0 , 0 ) )  +
  #scale_x_continuous ( breaks = seq ( 0 , 8736 , by = 672 ) , expand = c(0, 0) )  +
  scale_fill_manual( values = type_colMap ) +
  guides ( fill = guide_legend ( ncol = 2 , byrow = TRUE ) ) +
  geom_text( position = position_stack(vjust = 0.5) , size = 1.4  , fontface= "bold" , colour = "grey1"  ) +
  theme_bw () +
  theme ( 
    plot.title = element_text( size = 10 ) ,
    legend.position = "right" ,
    axis.title.x=element_text( size = 6 ) ,
    axis.title.y=element_text( size = 6 ) ,
    axis.text = element_text ( size = 6 ) ,
    legend.title=element_blank() ,
    legend.text=element_text( size = 6) ,
    legend.key.size = unit ( 0.3 , "cm" )
  )
#p
ggsave ( paste (  case , "/results/" , run , "/" , "results_visualization" , "/Allp" , "_" , "nationalElectricity" , "_period" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
write.csv ( GEN  , paste ( case , "/results/" , run , "/" , "results_visualization" , "/Allp"  , "_" , "nationalElectricity" , "_period_gwh" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )


###CO2 to air plot,vertical barplot - period-wise
FLOp <- subset ( AGG , grepl ( "co2_sink" , AGG$node_out )  )
FLOp$resource <- gsub ( "^[^_]*_|conventional_|_legacy" , "" , FLOp$resource_id )
FLOp$val      <- FLOp$value /1e6 ##co2 in tonnes , now million tonnes

GE       <- dcast ( FLOp , resource ~ period  , value.var = "val" , sum )
GEN      <- melt ( GE , id.vars = 1 , measure.vars = 2:(1+periods) , variable.name = "period" , value.name = "val" , factorsAsStrings = FALSE )
GEN$val  <- sapply ( GEN$val , function (x) ifelse ( x < .01 , NA , x ) ) 

p <- ggplot ( GEN , aes(period , val , fill = factor( resource , levels = rev ( Etype ) ) , label = round ( val , 0 ) ) ) +
  geom_col( width = 0.5 ) +
  #coord_flip() +  ##horizontal bars
  #coord_polar(theta = "y") +  ##pie plots
  ggtitle( bquote ( "CO2 emissions to air by type, national [flow.csv]" ) ) + 
  xlab ( "period") + # for the x axis label
  ylab ( "million tonnes CO2") +
  scale_y_continuous ( limits = c ( 0 , NA ) , breaks = seq ( 0 , 2000 , by = 100 ) , expand = c ( 0 , 0 ) )  +
  #scale_x_continuous ( breaks = seq ( 0 , 8736 , by = 672 ) , expand = c(0, 0) )  +
  scale_fill_manual( values = type_colMap ) +
  guides ( fill = guide_legend ( ncol = 2 , byrow = TRUE ) ) +
  geom_text( position = position_stack(vjust = 0.5) , size = 1.4  , fontface= "bold" , colour = "grey1"  ) +
  theme_bw () +
  theme ( 
    plot.title = element_text( size = 10 ) ,
    legend.position = "right" ,
    axis.title.x=element_text( size = 6 ) ,
    axis.title.y=element_text( size = 6 ) ,
    axis.text = element_text ( size = 6 ) ,
    legend.title=element_blank() ,
    legend.text=element_text( size = 6) ,
    legend.key.size = unit ( 0.3 , "cm" )
  )
#p
ggsave ( paste (  case , "/results/" , run , "/" , "results_visualization" , "/Allp" , "_" , "CO2_to_air" , "_period" , "_" , run , ".png" , sep = "" ) , p , width = wdth , height = hgth , units = "px" )
write.csv ( GEN  , paste ( case , "/results/" , run , "/" , "results_visualization" , "/Allp"  , "_" , "CO2_to_air" , "_period_mt" , "_" , run , ".csv" , sep = "" ) , row.names = FALSE , na = "" )
library(shiny); library(ggplot2)
library(plotly); library(mongolite)
library(reshape); library(lubridate)
library(knitr); library(stringr)
library(dplyr)


#options(shiny.host = '192.168.1.122')
#options(shiny.port = 1313)

# setwd("~/R/Shiny/workshop_shiny/App8/App8")

DMI <- readRDS("Data/DMI.rds")
MESA <- readRDS("Data/MESA.rds")
DF <- readRDS("Data/dbase.RDS") %>% 
    select(key,values,timestamp)
DF$values <- DF$values[,c(65:66, 68:131)]

x <- c("mic0","mic1","mic2","mic3","mic4","mic5","mic6","mic7","mic8","mic9","mic10",
       "mic11","mic12","mic13","mic14","mic15","mic16","mic17","mic18","mic19","mic20",
       "mic21","mic22","mic23","mic24","mic25","mic26","mic27","mic28","mic29","mic30",
       "mic31","accel0","accel1","accel2","accel3","accel4","accel5","accel6","accel7",
       "accel8","accel9","accel10","accel11","accel12","accel13","accel14","accel15",
       "accel16","accel17","accel18","accel19","accel20","accel21","accel22","accel23",
       "accel24","accel25","accel26","accel27","accel28","accel29","accel30","accel31")

shinyServer(function(input, output){
    
    #m <- mongo(url = "mongodb://si:tisapolines@192.168.1.119:27017/polin", 
    #           collection = "measurements")
    name <- reactive({paste0(as.character(input$dmi), ".pdf")})
    
    re0 <- reactive({
        KEY <- as.character(DMI[as.numeric(input$dmi),1])
        dat <- as_datetime(input$date, tz = "America/Santiago")
        dat2 <- ymd_hms(paste(input$date2,"23:00:00"), tz="America/Santiago")
        DF %>% filter(key == sprintf("/wsn1/%s", KEY)) %>% 
            filter(timestamp >= dat & timestamp <= dat2) %>% 
            mutate(key = input$dmi)
    })
    
    re1 <- reactive({as.character(DMI[as.numeric(input$dmi),1])})
    re2 <- reactive({dim(re0()$values)[1]})
    re3 <- reactive({(sum(complete.cases(re0()$values))*100)/re2()})
    re4 <- reactive({mean(re0()$values$batt_percentage, na.rm = TRUE)})
    
    re5 <- reactive({
        MESA %>% group_by(POSICION) %>% filter(POSICION == input$n) %>% {. ->> val}
        val <- as.data.frame(val)[,-1]
        val.long <- melt(val, measure = c(1:64))
        return(val.long)
    })
    
    re6 <- reactive({
        df2 <- aggregate(re0()$values[match(x,names(re0()$values))], 
                         list(re0()$key), mean, na.rm = T)
        long <- melt(df2, id = "Group.1", measure = c(2:65))
        long %>% slice(match(x, variable))
    })
    
    re7 <- reactive({
        tim <- mean(as.numeric(int_diff(re0()$timestamp)))
        round(seconds_to_period(tim))
    })
    
    fig <- reactive({
        plot_ly(x=re5()$variable, y=re5()$value, 
                type = 'box', alpha= 0.3, color = ~re5()$variable) %>% 
            add_trace(x=re6()$variable, y=re6()$value, 
                      name = re6()$Group.1, type = 'scatter', 
                      mode = 'markers+lines', line = list(width = 1), alpha = 1, 
                      color = I("red"), opacity = 1, 
                      name = input$dmi)
    })
    
    output$plot <- renderPlotly(fig())
    
    output$outvalue0 <- renderPrint({re1()})
    output$outvalue1 <- renderPrint({re2()})
    output$outvalue2 <- renderPrint({re3()})
    output$outvalue3 <- renderPrint({re4()})
    output$outvalue4 <- renderPrint({re7()})
    output$outvalue5 <- renderDataTable(re0()$values)
    
    output$report <- downloadHandler(
        filename = renderText({name()}),
        content = function(file) {
            
            tempReport <- file.path(tempdir(), "report.Rmd")
            file.copy("input.Rmd", tempReport, overwrite = TRUE)
            
            params <- list(n = input$dmi, key = re1(), num = re2(),
                           por = re3(), bat = re4(), tpo = re7(), 
                           fg = re5(), fg2 = re6(), dt1 = input$date , 
                           dt2 = input$date2, pos = input$n)
            
            rmarkdown::render(tempReport, output_file = file,
                              params = params,
                              envir = new.env(parent = globalenv())
            )
        }
    )
    
})

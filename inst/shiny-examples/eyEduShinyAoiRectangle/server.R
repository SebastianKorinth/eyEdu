
server <- function(input, output) {
  
############################################################################### 
# sets up reactive dataframe
  values <- reactiveValues()
  values$aoi.table <- data.frame(x.left = numeric(),
                                 y.top = numeric(),
                                 x.right = numeric(),
                                 y.bottom = numeric(),
                                 aoi.label = character())

###############################################################################    
# renders plot: set up to dimension 0 to 1 with 0,0 representing the lower left 
# corner of the plot brush.values are therfore adjusted to xy.coordinates using
# the actual image dimensions with the upper left corner representing 0,0  
  
    output$plot.image <- renderPlot({ 
    
    background.image <- readPNG(paste(raw.data.path,"images/", input$image.list, sep = ""))
    plot(0:1,0:1, type='n',axes = F, ann=FALSE)
    rasterImage(background.image, 0, 0, 1, 1)
    rect(xleft = 0, xright = 1, ytop = 1, ybottom = 0, 
         border = "black", lty= 1, lwd = 1)
 
    for (aoi.counter in 1:nrow(values$aoi.table)){

       rect(xleft = values$aoi.table$x.left[aoi.counter]/dim.x,
            ytop =  (dim.y - values$aoi.table$y.top[aoi.counter])/dim.y, 
            xright =  values$aoi.table$x.right[aoi.counter]/dim.x,
            ybottom = (dim.y - values$aoi.table$y.bottom[aoi.counter])/dim.y,
            border="black", lty=1,lwd=1)
    }
 
    }) 
  
###############################################################################
# renders live update  
    output$live.update<- renderText({live.update.text(input$plot.brush)})
    
###############################################################################    
# function that provides data for the preview text window 
    live.update.text <- function(brush.value) {
      if(is.null(brush.value)) return(NA)
      x.left <-  round(brush.value$xmin*dim.x, 0) 
      y.top <-  dim.y - round(brush.value$ymax * dim.y, 0)
      x.right <-  round(brush.value$xmax*dim.x, 0) 
      y.bottom <-  dim.y - round(brush.value$ymin * dim.y, 0)
      aoi.label.val <- input$aoi.label
      paste("upper left corner(x,y): ",
            x.left, ", ",
            y.top,
            "; lower right corner(x,y): ",
            x.right,", ",
            y.bottom, "; AoI label: ",
            aoi.label.val,
            sep = "")
    }     

  # function x.up coordinates for table
  x.up.coordinates <- function(brush.value) {
    if(is.null(brush.value)) return(NA)
    round(brush.value$xmin*dim.x, 0)
    }
  # function y.up coordinates for table
  y.up.coordinates <- function(brush.value) {
    if(is.null(brush.value)) return(NA)
    dim.y - round(brush.value$ymax * dim.y, 0)
  }
  # function x.low coordinates for table
  x.low.coordinates <- function(brush.value) {
    if(is.null(brush.value)) return(NA)
    round(brush.value$xmax*dim.x, 0) 
  }
  # function y.low coordinates for table
  y.low.coordinates <- function(brush.value) {
    if(is.null(brush.value)) return(NA)
    dim.y - round(brush.value$ymin * dim.y, 0)
  }

###############################################################################    
# adds new row to reactive dataframe upon clicking 
    observeEvent(input$add.line, {
      
     line.to.add <- data.frame(
       x.left = as.integer(x.up.coordinates(input$plot.brush)),
       y.top = as.integer(y.up.coordinates(input$plot.brush)),
       x.right = as.integer(x.low.coordinates(input$plot.brush)),
       y.bottom = as.integer(y.low.coordinates(input$plot.brush)),
       aoi.label = input$aoi.label)

      # add row to the data.frame
      values$aoi.table <- rbind(values$aoi.table, line.to.add)

    })
    

###############################################################################    
# renders a table showing the content of the growing data frame to
     output$aoi.table <- renderTable({
        values$aoi.table
      })

    
###############################################################################    
# saves the data frame upon botton press into a text file; aoi. index is added
# and the data frame is cleared   
    observeEvent(input$save.aoi.file, {
      values$aoi.table$aoi.index <- row.names(values$aoi.table)
      values$aoi.table$line.aoi.index <- NA
      values$aoi.table$line.number <- NA
      values$aoi.table$image.name <- input$image.list
      file.name.var <- gsub(".png", ".txt",input$image.list)
      write.table(values$aoi.table,
                  file = paste(raw.data.path, "aoiFiles/", file.name.var, sep = ""),
                  quote = F,
                  row.names = F)
      values$aoi.table <- data.frame(x.left = numeric(),
                                     y.top = numeric(),
                                     x.right = numeric(),
                                     y.bottom = numeric(),
                                     aoi.label = character())
    })

###############################################################################    
# resets data frame upon botton press
   observeEvent(input$reset.aoi.file, {
   values$aoi.table <- values$aoi.table[0,]

  })
    

}

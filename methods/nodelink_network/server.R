library(shiny)
library(igraph)
library(networkD3)

plot.net <- function(net, labels = 1, size = 1) {
  net.D3 <- igraph_to_networkD3(net)
  net.D3$links$value <- get.edge.attribute(net)$weight
  net.D3$nodes$group <- labels
  net.D3$nodes$size <- size
  forceNetwork(Links = net.D3$links,
               Nodes = net.D3$nodes,
               Source = "source",
               Target = "target",
               Value = "value",
               NodeID = "name",
               Nodesize = "size",
               Group = "group",
               
               fontSize = 30,    
               linkColour = "black",    
               charge = -250,     
               opacity = 0.9,
               legend = T,    
               arrows = T,    
               bounded = F,    
               zoom = T    
  )
}

function(input, output) {
  net <- reactive({
    book_names = c("austen_2", 
                   "austen_4", 
                   "dickens_1", 
                   "dickens_4",
                   "shakespeare_1",
                   "shakespeare_5",
                   "twain_1",
                   "twain_4")
    
    book_fullnames = c("Jane Austen, Emma",
                       "Jane Austen, Pride and Prejudice",
                       "Charles Dickens, A Christmas Carol",
                       "Charles Dickens, Oliver Twist",
                       "William Shakespeare, Hamlet",
                       "William Shakespeare, Romeo and Juliet",
                       "Mark Twain, Adventures of Huckleberry Finn",
                       "Mark Twain, The Adventures of Tom Sawyer")
    filePath <- paste0("./dataset/", book_names[book_fullnames == input$selectDataset] , ".txt")
    word_list = read.table("./dataset/functionwords_list.txt", head=FALSE)
    word_list <- as.matrix(word_list)
    
    book = read.table(filePath, head=FALSE)
    colnames(book) = word_list
    row.names(book) = word_list
    load("dws_mask.R")    # run disword.Rmd to get this object
    book <- book[dws_mask, dws_mask]
    diag(book) <- 0
    book <- 8*book/max(book)
    book <- as.matrix(book)
    idx <- (rowSums(book) != 0) | (colSums(book) != 0)
    book <- book[idx, idx]
    book_g <- graph_from_adjacency_matrix(book, mode = "directed", weight = T)
    list(book, book_g)
  })
  
  output$network <- renderForceNetwork(plot.net(net()[[2]], size = 5 * (rowSums(net()[[1]]) + colSums(net()[[1]]))))
}


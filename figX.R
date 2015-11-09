nResponses = 103

library(extrafont)



# multiplot ---------------------------------------------------------------

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

poll = read.csv('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/googlepoll.csv', header = FALSE)

poll = t(poll) %>% 
  na.omit() 

percent = function(x, ndigits = 1) {
  paste0(sprintf("%.f", round(x*100, ndigits)), "%")
}


df = data.frame(tissue = poll) %>% 
  group_by(tissue) %>% 
  summarise(nObs = n()) %>% 
  mutate(pct = percent(nObs / nResponses)) %>% 
  arrange(desc(nObs)) %>% 
  filter(nObs > 1,
         tissue %in% c('soleus', 'gastrocnemius', 'EDL',
                       'tibialisanterior', 'diaphragm', 'plantaris',
                       'quadriceps',  'extraocularmuscles', 'FDB', 'hamstrings',
                       'masseter', 'tongue')) %>% 
  mutate(citations = c(5,5,4,4.5, 5,4,5,4,3.5,4,3.5,4),
         maleMice = c(2,1,2,1,2,2,1,0,2,0,2,2)) %>% 
  arrange(desc(nObs))

df$tissue = factor(df$tissue,
                   levels = rev(df$tissue))


theme_xGrid<- function() {
  theme(title = element_text(size = 16, color = grey90K, 
                             family = 'Segoe UI'),
        axis.line = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x = element_text(size = 16, color = grey60K, family = 'Segoe UI Light'),
        axis.title.x = element_text(size = 18, color = grey60K, family = 'Segoe UI Semilight'),
        axis.text.y = element_text(size = 16, color = grey60K, family = 'Segoe UI Light'),
        axis.title.y = element_blank(), 
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position="none",
        panel.background = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_line(size = 0.1, colour = grey60K),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.border = element_blank(),
        plot.margin = rep(unit(0, units = 'points'),4),
        panel.background = element_blank(), 
        strip.text = element_text(size=13, face = 'bold'),
        strip.background = element_blank()
  )
}

grey60K = "#808285"
grey90K="#414042"

x1 = ggplot(df, aes(x = tissue, y = nObs, label = pct)) +
  geom_bar(fill = 'dodger blue', alpha = 0.4, stat = 'identity') +
  geom_text(colour = 'dodger blue', hjust = 1.3, 
            family = 'Segoe UI', size = 5) +
  theme_xGrid() +
  coord_flip(ylim = c(0, nResponses)) +
  ggtitle('Skeletal tissues were selected based on input from > 100 experts') +
  ylab('Number of respondents in an online poll')


x2 = ggplot(df, aes(x = tissue, y = citations, label = 10^citations)) +
  geom_bar(fill = '#b2182b', alpha = 0.3, stat = 'identity') +
  geom_text(colour = '#b2182b', hjust = 1.3, 
            family = 'Segoe UI', size = 5) +
  theme_xGrid() +
  coord_flip() +
  ggtitle('Skeletal tissues were selected based on input from > 100 experts') +
  ylab('Number of PubMed citations')

x3 = ggplot(df, aes(x = tissue, y = 1, fill = factor(maleMice))) +
  geom_tile(colour = 'white', size = 1.5) +
  theme_xGrid() +
  coord_flip() +
  scale_fill_grey(start = 1, end  = 0.5) +
  ggtitle('Skeletal tissues were selected based on input from > 100 experts') +
  ylab('male mice')

multiplot(x1, x2, x3, cols = 3)

ggsave('~/Dropbox/Muscle Transcriptome Atlas/muscle_poll1.pdf', 
       plot = x1, width = 6, height = 5)

ggsave('~/Dropbox/Muscle Transcriptome Atlas/muscle_poll2.pdf', 
       plot = x2, width = 6, height = 5)

ggsave('~/Dropbox/Muscle Transcriptome Atlas/muscle_poll3.pdf', 
       plot = x3, width = 3.5, height = 5)

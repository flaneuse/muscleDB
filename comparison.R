# Find range of the data.
expr = x %>% select(contains('_mean'))

high = max(expr)

for (i in 1:27){
  
  i=25
n=data.frame('expr'=as.numeric(t(x[i,8:15])))

maxN = max(n)

# n= n %>% mutate(expr1 = n/maxN)

# n %>% ggvis(x=~c(1:8), y=~expr/maxN) %>% 
#   layer_bars(fill:="dodgerblue") %>%
#   scale_numeric("y", domain = c(0, 1)) %>%
#                   hide_axis("y") %>%
#                   hide_axis("x")


p25=ggplot(data=n, aes(x=1:8, y=expr)) + 
#   geom_bar(stat="identity", width=1, fill="slateblue") +
  geom_line(size=3)+
theme_minimal() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        axis.ticks = element_blank(), axis.text.x = element_blank(),
 axis.text.y = element_blank(), axis.title.x = element_blank(), 
 axis.title.y= element_blank())
  #                   formatPlot()
#   scale_numeric("y", domain = c(0, high)
                )
}
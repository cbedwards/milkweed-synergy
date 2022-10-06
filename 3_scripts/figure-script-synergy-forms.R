## qualitative plot, for simplicity scale 0 to 10, plot 1 to 9

## setup --------
library(here)
library(ggplot2)
library(cowplot)
theme.mine=theme_classic()+
  theme(plot.title = element_text(face="bold", size=34),
        text=element_text(size=rel(6.5)),
        legend.text = element_text(size=24),
        legend.key.width = unit(1,'cm'),
        legend.key.height = unit(2, "cm"),
        legend.title = element_text(size=22),
        axis.title = element_text(size = 28),
        axis.title.x = element_text(margin = margin(t = .2, unit = "in")),
        axis.title.y = element_text(margin = margin(r = .2, unit = "in")))

## Functions for repeatability
g_capita = function(df, df.pt){
  ggplot(df, aes(x=x, y=y))+
    geom_path(size=1.5)+
    geom_point(data = df.pt,
               size=7, col="lightgray")+
    geom_point(data = df.pt,
               size=5, col=df.pt$col)+
    xlab("")+
    ylab("")+
    scale_x_continuous(breaks = x.pt, labels=investnames)+
    scale_y_continuous(breaks = c(1,9), labels=c("low","high"),
                       limits = c(0,10))+
    theme.mine
  
}
g_def = function(y.pt){
  df.def = as.data.frame(expand.grid(invest = x,scen = 1:3))
  df.def$capita = y.pt[df.def$scen]
  df.def$name = investnames[df.def$scen]
  df.def$name = factor(df.def$name, levels=investnames)
  df.def$def = df.def$capita*df.def$invest
  df.def$def = df.def$def/max(df.def$def)*10
  ggplot(df.def, aes(x=invest, y = def, group_by(name)))+
    geom_path(aes(col = name, linetype = name),
              size=1.5)+
    theme.mine+
    xlab("")+
    ylab("")+
    labs(color = "Investment\nin trait Y", linetype = "Investment\nin trait Y")+
    scale_x_continuous(breaks = x.pt, labels=investnames)+
    scale_y_continuous(breaks = c(1,9), labels=c("low","high"),
                       limits = c(0,10))+
    scale_color_manual(values = colseq)
}


## define list for storing figures
glist = list()

## color scheme
colseq = c("#29579d", "#8aaccf", "#97ef99")

## naming scheme
investnames = c("low", "moderate", "high")


## our plotting X points
y.plot = x.plot = seq(0,2, by = .001)
y.pt = x.pt = c(0:2)


## per-capita investment, no synergy------

ben_nosyn = function(x.invest,y.invest,
                     a=1,
                     b=.3,
                     c = .6){
  a + b * x.invest + c * y.invest
}

ben_bilin = function(x.invest,y.invest,
                     a=1,
                     b=.3,
                     c = .6,
                     d=1){
  a + b * x.invest + c * y.invest + d * x.invest * y.invest 
}

ben_dmr = function(x.invest,y.invest,
                   a=1,
                   b=.3,
                   c = .6,
                   d=1,
                   h = 20,
                   mid=1,
                   g=.1){
  fx = (x.invest)/(x.invest+g)
  fy = 1/(1+exp(-h * (y.invest-mid)))
  a + b * x.invest + c * y.invest + d * fx * fy
  # a + b * x.invest + c * y.invest + d * fxy
}

g_x = function(df.x, ben.name){
  df.x$y.pt = factor(df.x$y.invest)
  ggplot(df.x, aes(x=x.invest, y = get(ben.name), color = y.pt, linetype = y.pt))+
    geom_path(size = 1.5)+
    theme.mine+
    xlab("")+
    ylab("")+
    labs(color = "Investment\nin trait Y", linetype = "Investment\nin trait Y")+
    scale_color_manual(values = colseq)
}

g_y = function(df.y, ben.name){
  df.y$x.pt = factor(df.y$x.invest)
  ggplot(df.y, aes(x=y.invest, y = get(ben.name), color = x.pt, linetype = x.pt))+
    geom_path(size = 1.5)+
    theme.mine+
    xlab("")+
    ylab("")+
    labs(color = "Investment\nin trait X", linetype = "Investment\nin trait X")+
    scale_color_manual(values = colseq)
}

df.x = as.data.frame(expand.grid(x.invest = x.plot, y.invest = y.pt))
df.x$benefit.no = ben_nosyn(df.x$x.invest, df.x$y.invest)
df.x$benefit.bilin = ben_bilin(df.x$x.invest, df.x$y.invest)
df.x$benefit.dmr = ben_dmr(df.x$x.invest, df.x$y.invest)

df.y = as.data.frame(expand.grid(x.invest = x.pt, y.invest = y.plot))
df.y$benefit.no = ben_nosyn(df.y$x.invest, df.y$y.invest)
df.y$benefit.bilin = ben_bilin(df.y$x.invest, df.y$y.invest)

df.y$benefit.dmr = ben_dmr(df.y$x.invest, df.y$y.invest, b=.1, c=.1, d=2, g = .1, h=2)
df.x$benefit.dmr = ben_dmr(df.x$x.invest, df.x$y.invest, b=.1, c=.1, d=2, g = .1, h=2)
(g_x(df.x, "benefit.dmr") | g_y(df.y, "benefit.dmr")) 

g.full = (g_x(df.x, "benefit.no") | g_y(df.y, "benefit.no"))/
  (g_x(df.x, "benefit.bilin") | g_y(df.y, "benefit.bilin"))/
  (g_x(df.x, "benefit.dmr") | g_y(df.y, "benefit.dmr")) 

ggsave(here("5_figs/finals/conceptual-diagram.pdf"),
       g.full, 
       height = 20, width = 17)

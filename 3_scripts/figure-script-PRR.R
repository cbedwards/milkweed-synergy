## UPDATE: POINTS ARE NOT BLUE, APPROPRIATE SEGMENT IS


# library(randomForest)
library(here)
# 
tiff(here("5_figs/finals/prr-example.tiff"), width=8, height=10,
     units='in', res = 300)

## linear model -----

# x11()
par(mfrow=c(2,1), oma = c(2,4.5,0,0))
par(mar=c(3,2,2,6.5))
seed.rand = sample(1:10000,1)
## 939 looks like a good demonstration
seed.rand = 939
set.seed(seed.rand)
n=50
dat = data.frame(x = (0.1+0.8*runif(n))*10)
dat$y = 3 * dat$x + rnorm(n)*10 + 20

{plot(dat$x,dat$y, pch=19, xlim=c(0,10), 
      xlab = "", ylab = "",
      cex.lab=1.6, cex.main=1.6, cex.axis=1.4)
   mtext("growth\n(or other continuous response)",
         side = 2, outer=F, cex = 1.6, line=3)
   title("(a)", adj=0, line=.5, cex.main = 1.6)
   out = lm(dat$y ~ dat$x)
   ## add fitted line, with blue in the middle
   ## below the minimum x
   abline(out, lty = 3)
   dat$yhat = predict(out)
   points(dat$x,dat$yhat, col='blue',cex=1.3,lwd=2)
   
   
   par(xpd = T)
   var.x = 11
   segments(x0 = var.x, y0 = min(dat$y), y1 = max(dat$y))
   segments(x0 =var.x -.1, x1 = var.x+.1, y0=range(dat$y))
   text(x = var.x-.3, y = mean(range(dat$y)),
        labels = "Observed Response Range",
        srt = 90,
        cex=1.4)
   text(x = var.x + .15, y = max(dat$y),
        labels = round(max(dat$y), 2),
        adj = 0, 
        cex = 1.2)
   
   text(x = var.x + .15, y = min(dat$y),
        labels = round(min(dat$y), 2),
        adj = 0, 
        cex = 1.2)
   
   
   prr.x = 11.5
   segments(x0 = prr.x, y0 = min(dat$yhat), y1 = max(dat$yhat), col='blue')
   segments(x0 =prr.x -.1, x1 = prr.x+.1, y0=range(dat$yhat), col='blue')
   text(x = prr.x + .2,
        y = mean(range(dat$yhat)),
        labels = "PRR",
        srt= 90,
        cex = 1.4,
        col = 'blue')
   
   text(x = prr.x + .15, y = max(dat$yhat)+.5,
        labels = round(max(dat$yhat), 2),
        adj = 0, 
        cex = 1.4, col = "blue")
   
   text(x = prr.x + .15, y = min(dat$yhat)-.5,
        labels = round(min(dat$yhat), 2),
        adj = 0, 
        cex = 1.4, col = "blue")
   par(xpd = F)
   # print(seed.rand)
}

## Survival, glm -------

# let's assume survival is linearly related to X
# X ranges from 0 to 10
# So let's have p(surv) range from 90% at x = 0 to
# 40% at x = 10

dat$surv = (runif(nrow(dat)) < (.9 - dat$x/20))

out = glm(surv ~ x, family='binomial', data = dat)
dat$surv.hat = predict(out, type='response')
dat.pred = data.frame(x = seq(0,10, by =.01))
dat.pred$y = predict(out, dat.pred, type='response')
# Survival\n(or other binary response)
# predictor
plot(dat$x, dat$surv, pch=19,
     xlim=c(0,10),
     cex.lab=1.6, cex.main=1.6, cex.axis=1.4,
     ylab = "",
     xlab = "")
mtext("survival\n(or other binary response)",
      side = 2, outer=F, cex = 1.6, line=3)
mtext("trait",
      side = 1, outer=F, cex = 1.6, line=3)
title("(b)", adj=0, line=.5, cex.main = 1.6)
points(dat.pred$x, dat.pred$y, type='l', lty=3)
points(x = dat$x, y = dat$surv.hat, col='blue', cex=1.3, lwd=2)

par(xpd = T)
# var.x = 11
segments(x0 = var.x, y0 = min(dat$surv), y1 = max(dat$surv))
segments(x0 =var.x -.1, x1 = var.x+.1, y0=range(dat$surv))
text(x = var.x-.3, y = mean(range(dat$surv)),
     labels = "Observed Response Range",
     srt = 90,
     cex=1.4)
text(x = var.x + .15, y = max(dat$surv),
     labels = round(max(dat$surv), 2),
     adj = 0, 
     cex = 1.4)

text(x = var.x + .15, y = min(dat$surv),
     labels = round(min(dat$surv), 2),
     adj = 0, 
     cex = 1.4)


# prr.x = 10.8
segments(x0 = prr.x, y0 = min(dat$surv.hat), y1 = max(dat$surv.hat), col='blue')
segments(x0 =prr.x -.1, x1 = prr.x+.1, y0=range(dat$surv.hat), col='blue')
text(x = prr.x + .2,
     y = mean(range(dat$surv.hat)),
     labels = "PRR",
     srt= 90,
     cex = 1.4,
     col = 'blue')

text(x = prr.x + .15, y = max(dat$surv.hat)+.021,
     labels = round(max(dat$surv.hat), 2),
     adj = 0, 
     cex = 1.4, col = "blue")

text(x = prr.x + .15, y = min(dat$surv.hat)-.021,
     labels = round(min(dat$surv.hat), 2),
     adj = 0, 
     cex = 1.4, col = "blue")
par(xpd = F)


dev.off()


## load packages
require(randomForest)
require(prodlim)
require(mvtnorm)
require(car)
library(boot)
require(tidyr)


kdem = function(X, # points to evaluate
                Y, # observed data points
                s #bandwidth scalar
){
  ## multivariate kernel density estimator
  ##   Modified from code provided by Giles Hooker
  ## Make a list to store difference matrices
  X=as.matrix(X)
  Y=as.matrix(Y)
  p=ncol(X)
  Xnorm=(X^2) %*% rep(1/p, p)
  Ynorm=(Y^2) %*% rep(1/p, p)
  Dist=matrix(Xnorm, nrow(Y), nrow(X), byrow=TRUE) +
    matrix(Ynorm, nrow(Y), nrow(X), byrow=FALSE) -
    2*(Y%*%t(X))/p
  Kmatx = t(dnorm(Dist,sd=s))
  wt=Kmatx%*%rep(1/nrow(Y),nrow(Y))
  
  return( wt )
}


kdem.cv = function(Y, #observed data points
                   s #bandwidth
){
  ## Calculate log likelihood of kernel
  ##   Modified from code provided by Giles Hooker
  
  # First we'll calculate the kernels everywhere
  p=ncol(Y)
  Y=as.matrix(Y)
  Ynorm=(Y^2) %*% rep(1/p, p)
  Dist=matrix(Ynorm, nrow(Y), nrow(Y), byrow=TRUE) +
    matrix(Ynorm, nrow(Y), nrow(Y), byrow=FALSE) -
    2*(Y%*%t(Y))/p
  Kmatx = dnorm(Dist,sd=s)
  # Deleting the diagonal will remove X_i from influencing
  # its own density
  
  Kmatx = Kmatx - diag(diag(Kmatx))
  
  # Now get f^(-i)(X_i)  (remember to use n-1)
  
  fvec = Kmatx%*%rep(1/(nrow(Y)-1),nrow(Y))
  
  # and return sum of logs
  
  return( sum(log(fvec)) )
}


kdem.cv_wrapper=function(s, Y){return(-kdem.cv(Y,s))}
#wrapper function to give optimizer when calculating best kernel density bandwidth


mk_sample = function(x.sc, #scaled actual data poitns
                     x.samp, #sample grid we want to generate weights for
                     opt){ #output of optim for finding best kernel bandwidth
  ## Generate weights for sample values
  ## from actual (scaled) data x.sc, for sample data x.samp, using
  ## optim output from optimizing kernel bandwith 
  wts=kdem(Y=x.sc, X=x.samp, s=opt$minimum)
  return(wts)
}


#####################################################
## Function to run random forest interaction analyses.
## This is the meat of our approach.
## This function takes our actual data, the traits of interest, 
##    the number of grid points to evaluate, and a few fitting details
##    (is this classification or response, how many trees do we use)
##    and returns (a) a summary of fitting each interaction ($summary) and 
##    (b) a list with data points for making plots ($plotdat)

rf_int=function(x, #matrix of observed x values, columns labeled by trait.
                x.pl, #matrix of just plant trait values -- used for predictions
                y, #vector of observed y values
                gridnum,# number of gridpoints per direction
                trait.int,  #traits of interest for interaction - e.g. ignore daysout, 
                #   because we don't care about its interaction.
                type="prob", #allows code to switch for continuous vs binomial response,
                #  This needs to be "prob" for survival and "response" for growth rate
                ntree=1000 #number of trees for the random forest
                
){
  # create results storage dataframe
  res.df=NULL
  #make list to store the grids of data used for plotting 
  # (to make my own plots by hand after)
  plotdat=list() 
  yhat.ls = list()
  #scale our x
  x.sc=apply(x,2, function(x){(x-min(x))/diff(range(x))})
  # scale our plant x
  x.pl.sc = apply(x.pl,2, function(x){(x-min(x))/diff(range(x))}) 
  ## for PRR we're trying to calculate the 
  ## calculate the optimal bandwidth term for kernels - 
  ##   can re-use in each iteration
  opt=optimise(interval=c(.0001, 1), f=kdem.cv_wrapper, Y=x.pl.sc)
  ## fit our random forest
  fit.rf=randomForest(x=x.sc, y=y, ntree = ntree)
  ## make grid of sampling data for testing
  samp.grid = expand.grid(seq(0,1,  length = gridnum),seq(0,1, length = gridnum))
  # Create baseline dataframe of traits (without grid). 
  #   (this is just a trick to make it easy to fill in the non-focal trait values
  x.samp.base = x.pl.sc[rep(1:nrow(x.pl.sc),
                            each = nrow(samp.grid)),]
  ## create a dataframe for rapid calculation of PRR
  x.sc.PRR = x.pl.sc[rep(1:nrow(x.pl.sc),
                         times = nrow(x.pl.sc)),]
  for(i.trait in 1:(length(trait.int)-1)){
    #grab trait 1
    trait.i = trait.int[i.trait]
    for(j.trait in (i.trait+1):length(trait.int)){
      #grab trait 2
      trait.j = trait.int[j.trait]
      
      ## PRR BIT
      ## basically want to create n copies of each plant, where the focal traits are kept the same
      ## and the other traits are the values of observed plants.
      ## Note the use of times with a vector. We want nrow(x.sc) entries for each of our nrow(x.sc) plants
      x.pred = x.sc.PRR
      x.pred[,trait.i] = rep(x.pl.sc[,trait.i], times = rep(nrow(x.pl.sc), nrow(x.pl.sc)))
      x.pred[,trait.j] = rep(x.pl.sc[,trait.j], times = rep(nrow(x.pl.sc), nrow(x.pl.sc)))
      y.pred = predict(fit.rf, newdata=x.pred, type=type)
      x.pred.pl = rep(as.character(1:nrow(x.pl.sc)),
                                   times = rep(nrow(x.pl.sc), nrow(x.pl.sc))
      )
      if(type == "prob"){
        #we want probability of true
        y.pred=y.pred[,2]
      }
      dat.calc = data.frame(y.pred, plantnum = x.pred.pl)
      yhat = dat.calc %>% 
        group_by(plantnum) %>% 
        summarise(yhat = mean(y.pred))
      yhat = yhat$yhat
      
      ## GRID BIT
      ## set up data
      ##   Start with filling in what all the traits would be
      ##   if we weren't making our grid of focal traits
      x.pred = x.samp.base
      ## add in our grid of focal traits, repeated per plant
      x.pred[,c(trait.i, trait.j)] = rep(1, nrow(x.pl.sc)) %x% as.matrix(samp.grid)
      ## calculate our weights
      wts = mk_sample(x.pl.sc, x.pred, opt=opt)
      ## Per Giles Hooker  rather than just using the KDE values, you might want
      ##   to normalize by dividing by the sum of KDE values for each plant.  
      ##   That will prevent an outlying plant from getting really low weight 
      ##   just because there are no others near it.
      wts = wts/rep(
        apply(matrix( wts, nrow(x.pl.sc),nrow(samp.grid),byrow=TRUE), 1, mean),
        1,
        each=nrow(samp.grid) )
      ## predict y with our fitted model, using our new hypothetical plants
      y.pred = predict(fit.rf, newdata=x.pred, type=type)
      
      ## set up formula for our ANOVA
      int.cur=paste0(trait.i,":",trait.j)
      print(int.cur)
      #Note: the actual goal here is to fit additive effects *perfectly*, so
      #  that all non-additive variation is non-additive variation
      #  For this reason, we want the interaction between plant ID and trait value
      f.cur=formula(paste0("y.pred.reg ~ plantID*",trait.i, " + plantID*",trait.j))
      ## create our sample x data for anova-ing
      ## It needs to have just the two focal traits and plant ID
      ## And those all need to be factors
      x.anov = cbind(x.pred[,c(trait.i,trait.j)],
                     plantID = rep(1:nrow(x.pl.sc),each = nrow(samp.grid))
      )
      x.anov = as.data.frame(apply(x.anov, 2, as.factor))
      ## if classification problem, predictions are a 1-col dataframe,
      ##  and we need them to be a vector
      ##  Additionally, want to be working with response on a logit scale
      ##  in that case.
      
      y.pred.reg = y.pred
      if(type=="prob"){
        y.pred=y.pred[,2]
        y.pred.reg = logit(y.pred)
        }
      ## add predictions to our anova dataframe
      x.anov = cbind(x.anov, y.pred.reg = y.pred.reg)
      # calculate anova
      out.cur=Anova(lm(f.cur, 
                       data=x.anov, 
                       weights=wts),
                    type=3, singular.ok = TRUE)
      #Now we calculate the mean response for each trait pair
      #  Note that this keeps growth response in growth rate per day
      res.means = x.anov
      names(res.means)[1:2] = c("t1", "t2") 
      res.means = res.means %>%
        group_by(t1, t2) %>%
        summarise(y.pred = mean(y.pred.reg))
      #if it's a probability, convert back to probability scale using plogis
      if(type == "prob"){
        res.means$y.pred = plogis(res.means$y.pred)
      }
      res.df=rbind(res.df,
                   data.frame(name = int.cur,
                              SS.par1 = out.cur$`Sum Sq`[rownames(out.cur)==trait.i],
                              SS.par2 = out.cur$`Sum Sq`[rownames(out.cur)==trait.j],
                              SS.int = tail(out.cur$`Sum Sq`,1),
                              SS.tot = sum(out.cur$`Sum Sq`[-1]),
                              response.min = min(yhat),
                              response.max = max(yhat)
                   )
      )
      
      ## a bit more cleanup to make savable plot data
      ## Note:t1 and t2 are currently CHARACTERS of numbers
      res.means$t1 = as.numeric(res.means$t1)
      res.means$t2 = as.numeric(res.means$t2)
      
      #make data frame of scaled plant traits
      dat.temp = as.data.frame(x.pl.sc)
      names(dat.temp)[names(dat.temp)==trait.i] = "t1"
      names(dat.temp)[names(dat.temp)==trait.j] = "t2"
      
      #save plotting data
      plotdat = append(plotdat,
                       list(list(t1 = trait.i,
                                 t2 = trait.j,
                                 grid = res.means,
                                 vals = dat.temp
                       )
                       )
      )
      names(plotdat)[length(plotdat)]=paste0(trait.i,"x",trait.j)
      yhat.ls[[paste0(trait.i,"x",trait.j)]] = yhat
      # extract results, stitch to data frame
    }
  }
  return(list(summary=res.df, 
              plotdat=plotdat,
              yhats = yhat.ls))
}

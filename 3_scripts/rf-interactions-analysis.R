library(here)
library(tidyverse)
library(openxlsx)

## based on methods of Hooker 2007.
##
## A relatively detailed explanation of the methods are provided in the supplements.
## Several complications arise, and our code addresses them.
## 
## 1) As mentioned in the supplements text, when applying ANOVA to the random forest predictions,
##    we must weight our anova based on how far the predicted points (based on hypothetical plants)
##    are from actual data points that the Random Forest model was fit to.
##    To do this, we use a multivariate kernel density estimator, and choose the 
##    bandwidth scalar that maximizes likelihood.
## 2) Unlike working with the regression models, for the Random Forest models we first scale our variables
##    such that the standard deviation is 1 (as with the regression models) *and*
##    the smallest value is zero (unlike the regression models). This vastly simplifies
##    calculations of the kernel density, and helps avoid any potential numerical oddities. We did not
##    carry this out with the regression models because it can complicate interpretation
##    of the interaction coefficients (but for Random Forests, there are no coefficients,
##    so this isn't a downside we have to worry about)
## 3) The ANOVA approach outlined in the supplements is equivalent to overfitting the
##    the model, and attributing the residual sum of squares to the interaction effect.
##    This is simpler numerically, so we do this. 
## 
## 
## I find that with 100,000 trees, repeated Random Forest runs with 10x10 grids differ from each other 
##   by at most ~10%.  
##   Comparing 5x5 vs 10x10 grids (w/100,000 trees), results appear to differ by as much as 80%. 
##   For this reason, we use 10x10 grids, 100,000 trees.
##   (Giles Hooker has strongly advocated for not creating too fine a grid, as 
##   the piecewise constant nature of the response surface of Random Forests mean
##   results can get weird/misleading when we zoom in too much.)
##   
## In terms of actual implementation:
##   - The current script calls a function script, reads in each data file and runs analysis 
##     for that data set, and then saves the resulting data. The code is written 
##     to be fairly flexible, such that it will only test interactions between
##     specified traits (but this means you must specify traits. 
##     Because analyzing each data set can be particularly time consuming, the
##     script is written to allow you to turn on all calculations with calc=TRUE,
##     or you can manually replace "calc" in any given if statement to be TRUE or FALSE
##     File reading and saving is structured based on our file directory, but can easily 
##     be tweaked for other needs.
##   - the rf-interactions-fun file (current version: rf-interactions-fun-4.R contains
##     the functions that perform all the work. These are as follows:
##       * kdem(): a kernel density estimator (for generating weights for weighted ANOVA)
##         that takes the points to be estimated (X, e.g. the simulated points),
##         the original data points (Y), and a bandwidth scalar (s).
##       * kdem.cv(): This calculates the log likelihood of the kernel, assuming
##         multivariate normal likelihood functions. 
##       * kdem.cv_wrapper(): this is a wrapper function to make kdem.cv play nicely
##         with optim()
##       * mk_sample(): this is a wrapper fuction to call kdem on the actual data,
##         using the optimized bandwidth scalar
##       * rf_int(): This is the workhorse function that does most of the heavy lifting
##         It takes 
##           a matrix of observed trait values, with columns labeled to identify
##             the traits (x); 
##           a vector of observed herbivore responses (y); 
##           an integer for the size of the grid to use (gridnum) for generating
##             simulated data - this species the number of points per side of the grid.
##             Running the analysis can be quite slow depending on the size of the original data,
##             the number of traits of interest, and the type of regression (survival data
##             takes longer). For simple tests ("is this code working with my data?"),
##             you will probably want to use a smaller value (I use gridnum = 5).
##           a vector of characters identifying the traits (matching columns of x) to calculate the 
##             interactions of (trait.int) (This allows you to include traits whose interaction you
##             do not want to test interactions of);
##           a character designating the type of response variable you are using (type)
##             This should be "prob" for survival data, and "response" for growth data
##             The designation is important for specifying the right type of prediction
##             to make;
##           an integer for the number of trees to use per random forest (ntree).
##             The default here is small to make test runs fast.
##         The general structure of the code is to prepare the data and selewct the 
##         appropraite bandwidth scalar, and then look through all pairwise trait combinations,
##         applying the step-by-step algorithm outlined in the main text. It is possible
##         to parallelize these loops, but the limiting factor can be RAM rather than
##         processor speed, depending on the size of the data and the grid size.
##         This function outputs a list of results
##           `$summary` is a data frame with a row per trait interaction, and includes 
##              the trait interaction (`name`);
##              the sum of squares associated with the main effect of trait 1 
##                (`SS.par1`) ["par" being abbreviation of "parent trait";
##              as SS.par2 but for trait 2 (`SS.par2`);
##              the sum of squares associated with the interaction (`SS.int`);
##              the total sum of squares (`SS. tot`)
##              the minimum across the average predicted herbivore response for 
##                each grid cell (`response.min`)
##              As response.min, but the maximum (`response.max`)
##              (note that our results use SS.int/SS.tot, and response.min/max)
##            `$plotdat` is a list of lists of lists, one per trait pair. 
##              The trait-pair level lists includes
##               The name of each trait in the pair (`trait.i` and `trait.j`)
##               A data frame of the average trait values for each grid cell (`grid`)
##                 (this is used for plotting, and is the same set of data that 
##                 response.min and response.max are calculated from)
##               A data frame of *all* data points used to calculate the ANOVA () 
##                 (e.g. all predicted herbivore responses, and the values of trait1 
##                 and trait2 for those predictions.

source(here("3_scripts",  "rf-interactions-funs.R"))
calc=TRUE #run all calculations?
set.seed(1)


## Data preparation: initial masses


### Clivicolis growth -----


if(calc){
  type="response" #regression
  ## read in data
  dat = read.csv(here("2_data_wrangling","clivicolis2016-growth.csv"))
  ## find average for each plant
  
  #our response, y, is the daily growth weight (log(weight)/daysout) variable
  #remove NA columns
  dat=na.omit(dat)
  
  # select the specific x columns for the model fit
  x=dat %>%
    select(trich, tough, lat, c8.4, c10.2, c.pca) 
  #identify traits to test interaction on (skip the daysout term).
  trait.int = c("trich","tough","lat","c8.4","c10.2","c.pca")
  x.pl = dat %>% 
    group_by(plantNum) %>% 
    filter(row_number()==1) %>% 
    ungroup() %>% 
    select(trich, tough, lat, c8.4, c10.2, c.pca)
  
  
  #x needs to be a matrix, y needs to be a vector
  x = as.matrix(x)
  y = dat$lgw
  res = rf_int(x = x,
               x.pl = x.pl,
               y = y, 
               gridnum = 10,
               trait.int = trait.int,
               type="response",
               ntree = 100000)
  ## save
  saveRDS(res$summary,
          file=here("4_res",  "rf-int-clivg-fin-indiv.RDS"))
  saveRDS(res$plotdat,
          file=here("4_res",  "rf-plotdat/rf-plotdat-clivg-indiv.RDS"))
  
}

### Clivicolis survival -----
if(calc){
  dat = read.csv(here("2_data_wrangling","clivicolis2016-survival.csv"))
  dat=na.omit(dat)
  
  y = as.factor(as.logical(dat$surv))
  x = dat %>%
    select(trich, tough, lat, c8.4, c10.2, c.pca)
  trait.int = c("trich","tough","lat","c8.4","c10.2","c.pca")
  
  x.pl = dat %>% 
    group_by(plantNum) %>% 
    filter(row_number()==1) %>% 
    ungroup() %>% 
    select(trich, tough, lat, c8.4, c10.2, c.pca) 
  
  ## run all the things
  x = as.matrix(x)
  res = rf_int(x=x,
               x.pl = x.pl,
               y = y, 
               gridnum = 10,
               trait.int = trait.int,
               type="prob",
               ntree = 100000)
  ## save
  saveRDS(res$summary,
          file=here("4_res",  "rf-int-clivs-fin-indiv.RDS"))
  saveRDS(res$plotdat,
          file=here("4_res",  "rf-plotdat/rf-plotdat-clivs-indiv.RDS"))
}


### Monarch growth ----------


if(calc){
  type="response"
  dat = read.csv(here("2_data_wrangling","monarch2015-full.csv"))
  dat=na.omit(dat)
  dat$perc.notN=100-dat$perc.N
  dat$inv.sla = 1/dat$sla
  y=dat$lgw
  x=dat %>%
    select(lat1, inv.sla, tough, trich, c.10.5, c.18.6, c.pca, perc.notN, perc.C)
  
  x.pl=dat %>%
    group_by(plantNum) %>% 
    filter(row_number()==1) %>% 
    ungroup() %>% 
    select(lat1, inv.sla, tough, trich, c.10.5, c.18.6, c.pca, perc.notN, perc.C)
  
 

  
  
  ## run all the things
  trait.int = c("lat1", "inv.sla", "tough","trich","c.10.5","c.18.6","c.pca","perc.notN","perc.C")
  ## run all the things
  x = as.matrix(x)
  res = rf_int(x, 
               x.pl,
               y, 
               gridnum = 10,
               trait.int = trait.int,
               type="response",
               ntree = 100000)
  saveRDS(res$summary,
          file=here("4_res",  "rf-int-monag-fin-indiv.RDS"))
  saveRDS(res$plotdat,
          file=here("4_res",  "rf-plotdat/rf-plotdat-monag-indiv.RDS"))
  
}

### Monarch survival ----------

if(calc){
  dat = read.csv(here("2_data_wrangling","monarch2015-full.csv"))
  dat$surv = as.factor(!is.na(dat$lgw))
  #note rescaling: changing `sla` to 1/sla, and `perc.N` to 100-perc.N
  dat$perc.notN=100-dat$perc.N
  dat$inv.sla = 1/dat$sla
  dat = dat %>%
    select(plantNum, lat1, inv.sla, tough, trich, c.10.5, c.18.6, c.pca, perc.notN, perc.C, surv)
  dat=na.omit(dat)
  

  
  y=dat$surv
  x=dat %>%
    select(lat1, inv.sla, tough, trich, c.10.5, c.18.6, c.pca, perc.notN, perc.C)
  x.pl=dat %>%
    group_by(plantNum) %>% 
    filter(row_number()==1) %>% 
    ungroup() %>% 
    select(lat1, inv.sla, tough, trich, c.10.5, c.18.6, c.pca, perc.notN, perc.C)
  ## run all the things
  trait.int = c("lat1", "inv.sla", "tough","trich","c.10.5","c.18.6","c.pca","perc.notN","perc.C")
  ## run all the things
  x = as.matrix(x)
  res = rf_int(x, 
               x.pl,
               y, 
               gridnum = 10,
               trait.int = trait.int,
               type="prob",
               ntree = 100000)
  saveRDS(res$summary,
          file=here("4_res",  "rf-int-monas-fin-indiv.RDS"))
  saveRDS(res$plotdat,
          file=here("4_res",  "rf-plotdat/rf-plotdat-monas-indiv.RDS"))
}


## Null distribution calculations -----------

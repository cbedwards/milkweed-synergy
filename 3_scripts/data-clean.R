## Data cleaning -- taking the raw data files and integrating them
## NOTE: for simplicity/cleanliness, I upload the integrated data and not the various separate files.
## So this script won't run "out of the box", but documents the steps taken in producing the cleaned data files
##   which are available in `2_data_wrangling`

rm(list = ls())

## libraries
library(here)
library(tidyverse)
library(openxlsx)


#####################################################
## monarchs 2015

# 1. Initial latex (*lat1*)
# This was measured on the leaf opposite the focal leaf, using the standard Agrawal lab method.
# 2. Initial cardenolides (*stand.\**, *card.tot*)
# I collected the leaf opposite the focal leaf, analyzed this using the standard HPLC methods of the Agrawal lab. I found 5 peaks that were clearly cardenolides and were extremely common among the samples.
# 3. Initial toughness (*tough1*, *tough2*, *toughmean*)
# This was measured using a penetrometer once on either side of the leaf opposite the focal leaf, at the widest part of the leaf, avoiding the major leaf ribs. I later averaged the two toughness measures.
# 4. Initial trichome density (*vert.transect*,*horiz.trans*,*transect*)
# This was measured by taking a hole punch on the leaf opposite the focal one, as near to the tip of the leaf as possible, and avoiding the midrib. I then photographed the hole punch on Bob Reed's microscope, and counted hairs by hand in ImageJ (FIJI) using two different methods. The first was to count all hairs in the top right quadrant. That proved extremely slow, so I instead switched to another technique that has been used in the Agrawal lab - drawing a vertical and a horizontal transect through the middle of the hole punch, and counting all hairs that touched the transects. This proved far faster, and had a high correlation with the quadrant method. However, it seems inherently sensitive to hair orientation and length.
# 5. Initial Specific Leaf Area (*disk_weight*)
# After photographing the hole-punches, I dried and weighed them. As the area is standardized across all plants (31.67 mm^2), and I took 1/disk_weight to be a proxy for specific Specific Leaf Area (SLA). 
# 6. Initial Carbon and Nitrogen content (*Weight..mg*, *N2.Amp*, *perc.N*, *CO2.Amp*, *perc.C*)
# Using the COIL facilities, I obtained the nitrogen and carbon concentrations in each of my leaf samples (which may be a metric of nutritional quality).
# 7. Final Latex (*lat2*)
# As with the initial latex measure, except that I took this at the end of the experiment. *Collin to Collin* Check which leaf I used.
# 8. Final cardenolides (*stand.\*.fin*, *card.tot.fin*)
# Same methods and peaks as with initial cardenolides, but using the focal leaf at the end of the experiment.

raw=dat.full=read.table(here("1_raw_data", "sum 2015/dat-full.csv"),sep=",", header = TRUE)
#disk weights in dat.full are scaled; we need to have raw data.
disc.weigh=read.csv(file=here("1_raw_data", "sum 2015/disc_weigh_sum_b_2015.csv"), header=TRUE)
dat.full=dat.full[,-which(names(dat.full)=="disk_weight")]
sla.df=disc.weigh[,1:2]
sla.df=cbind(sla.df, sla=31.67/sla.df$disk_weight) #mm^2/g
##that's in mm^2 / g, standard is m^2/kg
## that means we need to multiply by (1/1000^2)/(1/1000); divide by 1000
sla.df$sla = sla.df$sla/1000
dat.full=merge(dat.full, sla.df[,c(1,3)])

# Checking reliability of transect counts vs the old quadrat method
temp=dat.full[,c("old.count","transect")] %>%
  drop_na()
cor(temp)
# we see high correlation - the new method works!

#remove old.count, which was there for methods diagnostics, "*var" measures (they are just the variance of the two measures in this data frame), and the netlog measure.
dat.full=dat.full %>%
  select(-old.count, -ends_with("var"), -netlog, -X, -lat.mean) %>%
  rename(leaf.sample.weight=Weight..mg.,
         date.out=catOutDate,
         date.in=catInDate)

## several of our columns include scaling. Let's re-create them without scaling
dat.full$transect=apply(dat.full[,c("vert.transect","horiz.trans")], 1, mean)
dat.full$toughmean=apply(dat.full[,c("tough1","tough2")], 1, mean)

## handle data that had commas in it when it was read in
temp=dat.full$CO2.Amp
temp=as.character(temp)
temp=as.numeric(gsub(",","",temp))
dat.full$CO2.Amp=temp

temp=dat.full$N2.Amp
temp=as.character(temp)
temp=as.numeric(gsub(",","",temp))
dat.full$N2.Amp=dat.full$N2.Amp=temp


## Dealing with correlated cardenolides
## Note that we have chosen to use the initial, rather than final, cardenolides, so we only worry about columns without ".fin"

cor(dat.full[,c("stand.10.5",
                "stand.17.4",
                "stand.17.7",
                "stand.18.4",
                "stand.18.6")])

## we see a high correlation of the cardenolides 17.4, 17.7, and 18.4. Let's represent that suite of cardenolides using a single PCA axis.

stand.pca=prcomp(dat.full[,c("stand.17.4", "stand.17.7","stand.18.4")],
                 center=FALSE,
                 scale.=FALSE)
summary(stand.pca)

## We see that the first PC captures 94% of the variation in our data. So we will use PC1 as our measure of this cardenolide suite.

dat.full = dat.full %>% #add this pca
  mutate(stand.pca=-stand.pca$x[,1]/sd(stand.pca$x[,1]))

## finally, we add the log weight for dealing with growth

dat.full=cbind(lgw=log(dat.full$weight), #lgw = log weight
               dat.full)

## for clarity, let's replace "stand" with "card" in our labels

names(dat.full)=gsub("stand","c",names(dat.full))

## renaming for consistency:

dat.full = dat.full %>%
  rename(trich=transect,
         tough=toughmean)


## cutting intermediate measures: transects, tough1 and tough2

dat.full = dat.full %>% 
  select(-tough1, -tough2, -horiz.trans, -vert.transect)


## write csvs
write.csv(dat.full, file=here("2_data_wrangling","monarch2015-full.csv"), row.names=FALSE)

cat(c("Cleaned data from Edwards' field work in 2015, putting monarch caterpillars on wild A. asclepiadis plants, and measuring their weight ~7 days later",
      "",
      "lgw: log of final caterpillar weight",
      "plantNum: identifier for individual plants (2 caterpillars put on each plant)",
      "lat1: latex measure at beginning of experiment",
      "lat2: latex measure at end of experiment",
      "date.out: day caterpillars were placed on plants",
      "weight: caterpillar weight at end of experiment",
      "date.in: day caterpillar was weighed. Note: this varied between 6 and 7 days later depending on weather",
      "tough: mean of the two toughness measures",
      "init.weigh: average caterpillar weight before being placed on the plants",
      "daysout: number days caterpillar was out. Note weather conditions caused this to be either 6 or 7 days",
      "c.X: cardenolide measure from HPLC for peak at time X at beginning of experiment",
      "c.X.fin: cardenolide measure from HPLC for peak at time X at the end of the experiment",
      "card.tot, card.tot.fin: sum of cardenolides at beginning or end of experiments. Not expected to be very informative, given variation in cardenolide efficacy.",
      "leaf.sample.weight: weight of sample used by COIL to measure C and N",
      "N2.Amp: COIL measure of N2",
      "perc.N: percent Nitrogen (dry weight) measured by COIL",
      "CO2.Amp: COIL measure of carbon",
      "perc.C: %C (dry weight) measured by COIL",
      "vert.transect: one of the two measures of trichome density (hairs crossing the vertical transect)",
      "c2n: carbon to nitrogen ratio",
      "sla: specific leaf area (units??)",
      "card.pca: PCA axis representing the peaks 17.4, 17.7, 18.4 at the beginning of the experiment (those peaks are correlated, and this captures 94% of the variation)",
      as.character(Sys.time()),
      "from data-clean.R"),
    sep="\n",
    file=here("2_data_wrangling", "monarch2015-full-METADATA.txt")
)

#############################################################
## Clivicolis 2016  -- from "inference-clivicolis-dat2-1.Rmd"
## clear workspace
rm(list = ls())
load(file=here("1_raw_data","sum 2016/HPLC/2016-clivicolis-final.Rdata"), env=e<-new.env())
dat.cards=e$res
names(dat.cards)=c("plant","c8.4","c10.2","c10.5","c10.7", "c18.1")
#10.5 lacks sufficient plants to be useable
dat.cards=dat.cards[,-which(names(dat.cards)=="c10.5")]

main.c=read.csv(here("1_raw_data","sum 2016/cleaned_growdat.csv"))
main.c=main.c[,-1]
grow=main.c[,c("plant","larvae")]
grow$lgw=log(grow$larvae)
names(grow)[2]="weight"

trich=read.xlsx(here("1_raw_data","sum 2016/new transcribe/trichs_2016.xlsx"))
trich=trich[,c("plant","trich")]

grow=merge(grow,trich, all.x=TRUE)

tough=read.xlsx(here("1_raw_data","sum 2016/new transcribe/preliminary_toughness.xlsx"))
grow=merge(grow,tough[,c("plant","tough")], all.x=TRUE)

latex=read.xlsx(here("1_raw_data","sum 2016/new transcribe/latex_post-exper_latex.xlsx"))
latex$lat[latex$status=="broken"]=NA
# head(latex)
latex=latex[,c("plant","lat")]
grow=merge(grow,latex, all.x=TRUE)

#cardenolides

grow=merge(grow,dat.cards, all.x=TRUE)

## have decided that plant 94, which was bent at 80 degrees near base, was probably compromised. Dropping this sample.

grow=grow[!(grow$plant==94),]

## We note that c10.7 and c18.1 are highly correlated (especially when excluding one outlier with ~0 c10.7, so let's do another pca



pca=prcomp(grow[,c("c10.7", "c18.1")],
                 center=FALSE,
                 scale.=FALSE)
summary(pca)

## We see that the first PC captures 98% of the variation in our data. So we will use PC1 as our measure of this cardenolide suite.

grow = grow %>% #add this pca
  mutate(c.pca=-pca$x[,1]/sd(pca$x[,1]))


####################
## survival
raw.surv=read.xlsx(here("1_raw_data","sum 2016/new transcribe/survival.xlsx"))
raw.surv=as.data.frame(raw.surv)
names(raw.surv)[4:5]=c("date.in","date.out")
raw.surv$date.in=convertToDate(raw.surv$date.in)
raw.surv$date.out=convertToDate(raw.surv$date.out)
raw.surv$daysout=as.numeric(raw.surv$date.in-raw.surv$date.out)

## add dates to grow
grow=merge(grow,raw.surv[,c("plant","date.in","date.out","daysout")])

#expand to binary response
temp.surv=raw.surv[rep(row.names(raw.surv),raw.surv$survivors),c(1,4,5)]
temp.surv=cbind(temp.surv, surv=1)
temp.die=raw.surv[rep(row.names(raw.surv),raw.surv$placed- raw.surv$survivors),c(1,4,5)]
temp.die=cbind(temp.die, surv=0)
surv=rbind(temp.surv,temp.die)
surv=surv[order(surv$plant),]
surv=surv[,c("plant","surv","date.in","date.out")]
surv=merge(surv,raw.surv[,c("plant","daysout")])

pl.resp=unique(surv$plant)
pl.resp[!(pl.resp %in% dat.cards$plant)]
surv=merge(surv,dat.cards, all.x=TRUE)


pl.resp[!(pl.resp %in% tough$plant)]
surv=merge(surv,tough[,c("plant","tough")], all.x=TRUE)

trich=trich[,c("plant","trich")]
pl.resp[!(pl.resp %in% trich$plant)]
surv=merge(surv,trich, all.x=TRUE)

latex$lat[latex$status=="broken"]=NA
# head(latex)
latex=latex[,c("plant","lat")]
pl.resp[!(pl.resp %in% latex$plant)]
surv=merge(surv,latex, all.x=TRUE)

dim(surv)

## again handling the correlated predictors

pca=prcomp(surv[,c("c10.7", "c18.1")],
           center=FALSE,
           scale.=FALSE)
summary(pca)

## We see that the first PC captures 98% of the variation in our data. So we will use PC1 as our measure of this cardenolide suite.

surv = surv %>% #add this pca
  mutate(c.pca=-pca$x[,1]/sd(pca$x[,1]))



## renaming for consistency

grow = grow %>%
  rename(plantNum=plant)

####################
## write csvs
# growth
write.csv(grow, file=here("2_data_wrangling","clivicolis2016-growth.csv"), row.names=FALSE)

cat(c("Cleaned data from Edwards' field work in 2016, putting ~5 clivicolis larvae on wild A. asclepiadis plants, and measuring their weight ~7 days later",
      "Entries for larvae that survived",
      "",
      "plantNum: identifier for individual plants (~5 larvae put on each plant)",
      "weight: larvae weight at end of experiment",
      "lgw: log of final larvae weight",
      "trich: mean trichome density across the two transects - this is the measure to be used to represent trichomes",
      "tough: mean of the two toughness measures",
      "lat: latex measure at end of experiment",
      "c.X: cardenolide measure from HPLC for peak at time X at beginning of experiment",
      "date.in: day larvae were collected and weighed. Note: this varied between 7 and 8 days later depending on weather",
      "dat.out: day larvae was placed out on plants",
      "daysout: number days larvae was out. Note weather conditions caused this to be either 7 or 8 days",
      as.character(Sys.time()),
      "from data-clean.R"),
    sep="\n",
    file=here("2_data_wrangling", "clivicolis2016-growth-METADATA.txt")
)

# Survival

surv = surv %>%
  rename(plantNum=plant)


write.csv(surv, file=here("2_data_wrangling","clivicolis2016-survival.csv"), row.names=FALSE)


cat(c("Cleaned data from Edwards' field work in 2016, putting ~5 clivicolis larvae on wild A. asclepiadis plants, and measuring their weight ~7 days later",
      "Survival data",
      "",
      "plantNum: identifier for individual plants (~5 larvae put on each plant)",
      "surv: did this larvae survive",
      "date.in: day larvae were collected and weighed. Note: this varied between 7 and 8 days later depending on weather",
      "dat.out: day larvae was placed out on plants",
      "daysout: number days larvae was out. Note weather conditions caused this to be either 7 or 8 days",
      "c.X: cardenolide measure from HPLC for peak at time X at beginning of experiment",
      "tough: mean of the two toughness measures",
      "trich: mean trichome density across the two transects - this is the measure to be used to represent trichomes",
      "lat: latex measure at end of experiment",
      as.character(Sys.time()),
      "from data-clean.R"),
    sep="\n",
    file=here("2_data_wrangling", "clivicolis2016-survival-METADATA.txt")
)
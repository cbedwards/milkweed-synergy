Directory for data and analysis of "Plant defense synergies and antagonisms affect performance of specialist herbivores of common milkweed." 

See the associated publication for an overview of the data and methods. Here we provide data on common milkweed defense traits and the performance of two herbivores (monarch butterfly larvae and swamp milkweed beetle larvae) on those plants. The code and results used to carry out analysis and plotting for the associated publication, as well as a detailed tutorial for implementing the novel statistical approach we present in our publication.

Scripts were last run in R version 4.0.4, and the main analysis is in an Rmarkdown files (.Rmd). For those unfamiliar with the file format, it allows the combination of R code with document formatting using the Markdown language; there are considerable resources available online to introduce you to the use of Rmarkdown. Rmarkdown files are most easily viewed and edited in the free IDE Rstudio. Note that all code here is intended for use in an "R Project", an organizational tool associated with Rstudio; the .Rproj file in the main directory enables this. This allows the code to run out of the box on any computer, regardless of where the main directory is placed on your local hard drive.

Quick Guide: cleaned raw data lives in `2_data_wrangling`, most analysis was done in `3_scripts/analysis_main.0.Rmd` (which generates an html with the same name, which contains all key results, as well as generating most figures), and random forest regression was carried out in `3_scripts/rf-interactions-analysis-6.R`, which relies on functions defined in `3_scripts/rf-interactions-funs-4.R`. The PRR example figure (Figure 1 in the main text) was generated from `3_scripts/figure-script-PRR.R`.

Note that compiling the analysis Rmarkdown script takes considerable time to run (~30 minutes on my machine), and running the random forest analyses takes multiple hours at the sampling density used for publication. Some of the figures in 5_figs/ are included in the main text, and we have run into copyright complaints in the past for including "published" figures in online repositories. For this reason, we document the figures in our file structure below, but users will need to run `3_scripts/analysis_main.0.Rmd` and `3_scripts/figure-script-PRR.R` to (re)generate them.

=================================================

A clean run of the entire project starting with the cleaned data can be run in R (from within the project) with

source("3_scripts/rf-interactions-analysis.R")
library(rmarkdown)
render("3_scripts/analysis_main.Rmd")
source("3_scripts/figure-script-PRR.R")

with the understanding that (a) the appropriate packages will need to be loaded, and (b) the first script -- which runs the random forest analysis -- may take hours to days depending on your computer.

=================================================

File structure:
    covar_exper_clean.Rproj: R project associated with this directory
    README.txt: this file
+---1_raw_data: Home to the raw data. As this involved numerous files, and documentation / explanation was messy, we instead simply present the compiled data files in 2_data_wrangling and the cleaning script, 3_scripts/data-clean.R 
+---2_data_wrangling: cleaned data and corresponding metadata. These are the files used in the analyses scripts. Note that early iterations of this project used "clivicolis" rather than "beetle" to identify the data and analysis of the 2016 L. clivicolis experiment.
|       clivicolis2016-growth-METADATA.txt: metadata
|       clivicolis2016-growth.csv:  Data from 2016 experiments of Labidomera clivicolis, looking at growth (so only plants with 1+ survivors)
|       clivicolis2016-survival-METADATA.txt: metadata
|       clivicolis2016-survival.csv:  Data from 2016 experiments of Labidomera clivicolis, looking at survival (so data for all measured plants)
|       monarch2015-full-METADATA.txt:  metadata
|       monarch2015-full.csv:  Data from 2015 experiments of Danaus plexippus (there were no plants without survivors, so no separation of data like there is with clivicolis)
|       
+---3_scripts
|       analysis_main.html: (not included in upload, will be created when analysis_main.Rmd compiles). Output of main analysis file, `analysis_main.Rmd`
|       analysis_main.Rmd:  Main analysis file, carrying out all work except (A) the random forest fitting and prediction process, and (B) data cleaning.
|       data-clean.R:  Script for generating the cleaned data in 2_data_wrangling from the raw data.
|       figure-script-PRR.R: Script for generating Figure 2, which demonstrates the new "Predictable Response Range" (PRR) metric.
|       figure-script-synergy-forms.R: Script for generating Figure 1, which illustrates different forms of synergy.
|       rf-interactions-analysis.R:  Script to carry out random forest analysis, calling functions from `rf-interactions-funs.R`. Heavily annotated to provide context and encourage reuse/adaptation.
|       rf-interactions-funs.R: functions used in rf-interactions-analysis.R
|       
+---4_res:  Files of results of analyses: .xlsx files include summarized data from the analyses carried out in `analysis_main.Rmd`, useful for producing tables. Random forest analyses from `rf-interactions-analysis.R` is saved as RDS form; files in the main folder provide summary information for analyses in `analysis_main.Rmd`, while files in `rf-plotdat` contain a list of data points, used in making plots. Note the naming scheme uses "cliv" for the 2016 data L. clivicolis data (in the manuscript, this is presented as "Beetle"), "mona" for the 2015 D. plexippus data (in the manuscript, this is presented as "monarch"); suffixes s and g correspond to survival and growth, respectively.
|   |   context-dependence-all.csv: context dependence in aggregated form, used for Table 2 in main text
|   |   context-dependence.csv: context dependence in long-form, including the switching point. As a reminder, the switching point is based on scaled values, so represents when the "focal trait" changes from being beneficial to harmful to herbivores (or vice versa) measured in standard deviations of the "context trait". The "effect at mean" column shows the effect of increasing the focal trait when the context trait is at its mean. For example, for monarch growth, increases in cardenolide 10.5 from its mean lead to increased predicted monarch growth
|   |   regression-results-exploratory.xlsx: results of the regression analysis for bilinear synergies and antagonisms. `all analysis` tabs shows all results in long-form, `summary` tab shows those analysis with P value of 0.1 or less (used for Table 1), `meta data` explains column names for the individual dataset tabs (`summary` and `all analysis` use the same naming conventions as Table 1).
|   |   results-correspondence.xlsx: comparing the results of regression analysis with the results of random forest analysis for the same data set / trait pairs. As described in the main text, we don't expect these to give the same results; this file allows us to compare and contrast. `all` tab contains every comparison; `significant regressions` tab is the same contents as the `all` tab but filtered for P<=0.1 in the regression analysis; `notable random forests` subsets `all` to %PRV of 5 or greater in the Random Forest analysis; `meta data` tab contains documentation.
|   |   rf-int-clivg-fin-indiv.RDS: the `rf-int-...` files contain the results of random forest analysis for the various data sets and responses (s for survival, g for growth), calculated in `3_scripts/rf-interactions-analysis.R`. These are loaded into and used in `scripts/analysis_main.Rmd`
|   |   rf-int-clivs-fin-indiv.RDS
|   |   rf-int-monag-fin-indiv.RDS
|   |   rf-int-monas-fin-indiv.RDS
|   |   RF-results-exploratory.xlsx: results of random forest analysis. Same organization as `regression-results-exploratory.xlsx` -- see above for details. 
|   |   
|   \---rf-plotdat: contains Rdata files needed to plot the results of random forest analysis. These are generated/calculated in `3_scripts/rf-interactions-analysis.R`, and used for plotting in `3_scripts/analysis_main.Rmd`.
|           rf-plotdat-clivg-indiv.RDS
|           rf-plotdat-clivs-indiv.RDS
|           rf-plotdat-monag-indiv.RDS
|           rf-plotdat-monas-indiv.RDS
|           rf-plotdat-mw500g-indiv.RDS
|           rf-plotdat-mw500s-indiv.RDS
|           
\---5_figs: folder for all plot, including diagnostics and final figures. These figures are NOT included in the upload for copyright reasons, but can be (re)generated by running `3_scripts/analysis_main.Rmd`, `3_scripts/figure-script-PRR.R`, and `3_scripts/figure-script-synergy-forms.R`. Figures were sometimes generated with functions that automatically generate a meta-data files with the same name and extension "_meta.txt"; ggplot figures were sometimes saved in both a graphics file form (e.g. ".tiff") and as an rdata file (".RMD") for easy loading into other scripts. 
Files in the root `5_figs` folder are correlation plots used in identifying trait correlations, including those that were strong enough to warrant using PCA to collapse them. Correlation plots used in publication (Figure S1) are in the `5_figs/finals` folder.
    |   corrplot-cliv16-growth.jpg
    |   corrplot-cliv16-growth_meta.txt
    |   corrplot-cliv16-surv.jpg
    |   corrplot-cliv16-surv_meta.txt
    |   corrplot-mon15-analysis.jpg
    |   corrplot-mon15-analysis_meta.txt
    |   corrplot-mon15-card.jpg
    |   corrplot-mon15-card_meta.txt
    |   corrplot-mon15-phys.jpg
    |   corrplot-mon15-phys_meta.txt
    |   
    +---finals: Figures used in final publication
    |       corrplot-fin-Cliv16S.jpg: for manuscript figure S1
    |       corrplot-fin-Cliv16S_meta.txt
    |       corrplot-fin-Mon15.jpg: for manuscript figure S1
    |       corrplot-fin-Mon15_meta.txt
    |       fig 4 - rf fits.tiff: for manuscript figure 4
    |       fig1.tiff: for manuscript figure 3
    |       fig1_meta.txt
    |       fig3.tiff: for manuscript figure 2
    |       fig3_meta.txt
    |       prr-example.tiff: Figure 1 of manuscript. Note that this is generated in "3_script/figure-script-PRR.R"
    |       supp-rf-all.pdf: Random forest fits and stats for all trait pairs; manuscript figure S2.
    |       
    +---regression biplots: biplots as manuscript figure 3 but for, all trait pairs of all datasets. Organized by data set.
    |   +---cliv16 growth
    |   |       c.pca-c10.2.RMD
    |   |       c.pca-c10.2.tiff
    |   |       c.pca-c8.4.RMD
    |   |       c.pca-c8.4.tiff
    |   |       c10.2-c8.4.RMD
    |   |       c10.2-c8.4.tiff
    |   |       lat-c.pca.RMD
    |   |       lat-c.pca.tiff
    |   |       lat-c10.2.RMD
    |   |       lat-c10.2.tiff
    |   |       lat-c8.4.RMD
    |   |       lat-c8.4.tiff
    |   |       lat-tough.RMD
    |   |       lat-tough.tiff
    |   |       lat-trich.RMD
    |   |       lat-trich.tiff
    |   |       tough-c.pca.RMD
    |   |       tough-c.pca.tiff
    |   |       tough-c10.2.RMD
    |   |       tough-c10.2.tiff
    |   |       tough-c8.4.RMD
    |   |       tough-c8.4.tiff
    |   |       trich-c.pca.RMD
    |   |       trich-c.pca.tiff
    |   |       trich-c10.2.RMD
    |   |       trich-c10.2.tiff
    |   |       trich-c8.4.RMD
    |   |       trich-c8.4.tiff
    |   |       trich-tough.RMD
    |   |       trich-tough.tiff
    |   |       
    |   +---cliv16 survival
    |   |       c.pca-c10.2.RMD
    |   |       c.pca-c10.2.tiff
    |   |       c.pca-c8.4.RMD
    |   |       c.pca-c8.4.tiff
    |   |       c10.2-c8.4.RMD
    |   |       c10.2-c8.4.tiff
    |   |       lat-c.pca.RMD
    |   |       lat-c.pca.tiff
    |   |       lat-c10.2.RMD
    |   |       lat-c10.2.tiff
    |   |       lat-c8.4.RMD
    |   |       lat-c8.4.tiff
    |   |       lat-tough.RMD
    |   |       lat-tough.tiff
    |   |       lat-trich.RMD
    |   |       lat-trich.tiff
    |   |       tough-c.pca.RMD
    |   |       tough-c.pca.tiff
    |   |       tough-c10.2.RMD
    |   |       tough-c10.2.tiff
    |   |       tough-c8.4.RMD
    |   |       tough-c8.4.tiff
    |   |       trich-c.pca.RMD
    |   |       trich-c.pca.tiff
    |   |       trich-c10.2.RMD
    |   |       trich-c10.2.tiff
    |   |       trich-c8.4.RMD
    |   |       trich-c8.4.tiff
    |   |       trich-tough.RMD
    |   |       trich-tough.tiff
    |   |       
    |   +---mon15 growth
    |   |       c.10.5-inv.sla.RMD
    |   |       c.10.5-inv.sla.tiff
    |   |       c.18.6-c.10.5.RMD
    |   |       c.18.6-c.10.5.tiff
    |   |       c.18.6-inv.sla.RMD
    |   |       c.18.6-inv.sla.tiff
    |   |       c.pca-c.10.5.RMD
    |   |       c.pca-c.10.5.tiff
    |   |       c.pca-c.18.6.RMD
    |   |       c.pca-c.18.6.tiff
    |   |       c.pca-inv.sla.RMD
    |   |       c.pca-inv.sla.tiff
    |   |       c.pca-lat1.RMD
    |   |       c.pca-lat1.tiff
    |   |       c.pca-perc.C.RMD
    |   |       c.pca-perc.C.tiff
    |   |       c.pca-perc.notN.RMD
    |   |       c.pca-perc.notN.tiff
    |   |       c.pca-tough.RMD
    |   |       c.pca-tough.tiff
    |   |       c.pca-trich.RMD
    |   |       c.pca-trich.tiff
    |   |       lat1-c.10.5.RMD
    |   |       lat1-c.10.5.tiff
    |   |       lat1-c.18.6.RMD
    |   |       lat1-c.18.6.tiff
    |   |       lat1-inv.sla.RMD
    |   |       lat1-inv.sla.tiff
    |   |       lat1-perc.C.RMD
    |   |       lat1-perc.C.tiff
    |   |       lat1-perc.notN.RMD
    |   |       lat1-perc.notN.tiff
    |   |       perc.C-c.10.5.RMD
    |   |       perc.C-c.10.5.tiff
    |   |       perc.C-c.18.6.RMD
    |   |       perc.C-c.18.6.tiff
    |   |       perc.C-inv.sla.RMD
    |   |       perc.C-inv.sla.tiff
    |   |       perc.C-perc.notN.RMD
    |   |       perc.C-perc.notN.tiff
    |   |       perc.notN-c.10.5.RMD
    |   |       perc.notN-c.10.5.tiff
    |   |       perc.notN-c.18.6.RMD
    |   |       perc.notN-c.18.6.tiff
    |   |       perc.notN-inv.sla.RMD
    |   |       perc.notN-inv.sla.tiff
    |   |       tough-c.10.5.RMD
    |   |       tough-c.10.5.tiff
    |   |       tough-c.18.6.RMD
    |   |       tough-c.18.6.tiff
    |   |       tough-inv.sla.RMD
    |   |       tough-inv.sla.tiff
    |   |       tough-lat1.RMD
    |   |       tough-lat1.tiff
    |   |       tough-perc.C.RMD
    |   |       tough-perc.C.tiff
    |   |       tough-perc.notN.RMD
    |   |       tough-perc.notN.tiff
    |   |       tough-trich.RMD
    |   |       tough-trich.tiff
    |   |       trich-c.10.5.RMD
    |   |       trich-c.10.5.tiff
    |   |       trich-c.18.6.RMD
    |   |       trich-c.18.6.tiff
    |   |       trich-inv.sla.RMD
    |   |       trich-inv.sla.tiff
    |   |       trich-lat1.RMD
    |   |       trich-lat1.tiff
    |   |       trich-perc.C.RMD
    |   |       trich-perc.C.tiff
    |   |       trich-perc.notN.RMD
    |   |       trich-perc.notN.tiff
    |   |       
    |   \---mon15 survival
    |           c.10.5-inv.sla.RMD
    |           c.10.5-inv.sla.tiff
    |           c.18.6-c.10.5.RMD
    |           c.18.6-c.10.5.tiff
    |           c.18.6-inv.sla.RMD
    |           c.18.6-inv.sla.tiff
    |           c.pca-c.10.5.RMD
    |           c.pca-c.10.5.tiff
    |           c.pca-c.18.6.RMD
    |           c.pca-c.18.6.tiff
    |           c.pca-inv.sla.RMD
    |           c.pca-inv.sla.tiff
    |           c.pca-lat1.RMD
    |           c.pca-lat1.tiff
    |           c.pca-perc.C.RMD
    |           c.pca-perc.C.tiff
    |           c.pca-perc.notN.RMD
    |           c.pca-perc.notN.tiff
    |           c.pca-tough.RMD
    |           c.pca-tough.tiff
    |           c.pca-trich.RMD
    |           c.pca-trich.tiff
    |           lat1-c.10.5.RMD
    |           lat1-c.10.5.tiff
    |           lat1-c.18.6.RMD
    |           lat1-c.18.6.tiff
    |           lat1-inv.sla.RMD
    |           lat1-inv.sla.tiff
    |           lat1-perc.C.RMD
    |           lat1-perc.C.tiff
    |           lat1-perc.notN.RMD
    |           lat1-perc.notN.tiff
    |           perc.C-c.10.5.RMD
    |           perc.C-c.10.5.tiff
    |           perc.C-c.18.6.RMD
    |           perc.C-c.18.6.tiff
    |           perc.C-inv.sla.RMD
    |           perc.C-inv.sla.tiff
    |           perc.C-perc.notN.RMD
    |           perc.C-perc.notN.tiff
    |           perc.notN-c.10.5.RMD
    |           perc.notN-c.10.5.tiff
    |           perc.notN-c.18.6.RMD
    |           perc.notN-c.18.6.tiff
    |           perc.notN-inv.sla.RMD
    |           perc.notN-inv.sla.tiff
    |           tough-c.10.5.RMD
    |           tough-c.10.5.tiff
    |           tough-c.18.6.RMD
    |           tough-c.18.6.tiff
    |           tough-inv.sla.RMD
    |           tough-inv.sla.tiff
    |           tough-lat1.RMD
    |           tough-lat1.tiff
    |           tough-perc.C.RMD
    |           tough-perc.C.tiff
    |           tough-perc.notN.RMD
    |           tough-perc.notN.tiff
    |           tough-trich.RMD
    |           tough-trich.tiff
    |           trich-c.10.5.RMD
    |           trich-c.10.5.tiff
    |           trich-c.18.6.RMD
    |           trich-c.18.6.tiff
    |           trich-inv.sla.RMD
    |           trich-inv.sla.tiff
    |           trich-lat1.RMD
    |           trich-lat1.tiff
    |           trich-perc.C.RMD
    |           trich-perc.C.tiff
    |           trich-perc.notN.RMD
    |           trich-perc.notN.tiff
    |           
    \---rf biplots: Plots from Random Forest analysis for all traits pairs of all data sets. Generated in `3_scripts/analysis_main.Rmd`. Used in manuscript figures 4, S2.
            cliv16g-c10.2xc.pca-all.RDS
            cliv16g-c10.2xc.pca.tiff
            cliv16g-c8.4xc.pca-all.RDS
            cliv16g-c8.4xc.pca.tiff
            cliv16g-c8.4xc10.2-all.RDS
            cliv16g-c8.4xc10.2.tiff
            cliv16g-latxc.pca-all.RDS
            cliv16g-latxc.pca.tiff
            cliv16g-latxc10.2-all.RDS
            cliv16g-latxc10.2.tiff
            cliv16g-latxc8.4-all.RDS
            cliv16g-latxc8.4.tiff
            cliv16g-readyfig-c10.2xc.pca-all.RDS
            cliv16g-readyfig-c8.4xc.pca-all.RDS
            cliv16g-readyfig-c8.4xc10.2-all.RDS
            cliv16g-readyfig-latxc.pca-all.RDS
            cliv16g-readyfig-latxc10.2-all.RDS
            cliv16g-readyfig-latxc8.4-all.RDS
            cliv16g-readyfig-toughxc.pca-all.RDS
            cliv16g-readyfig-toughxc10.2-all.RDS
            cliv16g-readyfig-toughxc8.4-all.RDS
            cliv16g-readyfig-toughxlat-all.RDS
            cliv16g-readyfig-trichxc.pca-all.RDS
            cliv16g-readyfig-trichxc10.2-all.RDS
            cliv16g-readyfig-trichxc8.4-all.RDS
            cliv16g-readyfig-trichxlat-all.RDS
            cliv16g-readyfig-trichxtough-all.RDS
            cliv16g-toughxc.pca-all.RDS
            cliv16g-toughxc.pca.tiff
            cliv16g-toughxc10.2-all.RDS
            cliv16g-toughxc10.2.tiff
            cliv16g-toughxc8.4-all.RDS
            cliv16g-toughxc8.4.tiff
            cliv16g-toughxlat-all.RDS
            cliv16g-toughxlat.tiff
            cliv16g-trichxc.pca-all.RDS
            cliv16g-trichxc.pca.tiff
            cliv16g-trichxc10.2-all.RDS
            cliv16g-trichxc10.2.tiff
            cliv16g-trichxc8.4-all.RDS
            cliv16g-trichxc8.4.tiff
            cliv16g-trichxlat-all.RDS
            cliv16g-trichxlat.tiff
            cliv16g-trichxtough-all.RDS
            cliv16g-trichxtough.tiff
            cliv16s-c10.2xc.pca-all.RDS
            cliv16s-c10.2xc.pca.tiff
            cliv16s-c8.4xc.pca-all.RDS
            cliv16s-c8.4xc.pca.tiff
            cliv16s-c8.4xc10.2-all.RDS
            cliv16s-c8.4xc10.2.tiff
            cliv16s-latxc.pca-all.RDS
            cliv16s-latxc.pca.tiff
            cliv16s-latxc10.2-all.RDS
            cliv16s-latxc10.2.tiff
            cliv16s-latxc8.4-all.RDS
            cliv16s-latxc8.4.tiff
            cliv16s-readyfig-c10.2xc.pca-all.RDS
            cliv16s-readyfig-c8.4xc.pca-all.RDS
            cliv16s-readyfig-c8.4xc10.2-all.RDS
            cliv16s-readyfig-latxc.pca-all.RDS
            cliv16s-readyfig-latxc10.2-all.RDS
            cliv16s-readyfig-latxc8.4-all.RDS
            cliv16s-readyfig-toughxc.pca-all.RDS
            cliv16s-readyfig-toughxc10.2-all.RDS
            cliv16s-readyfig-toughxc8.4-all.RDS
            cliv16s-readyfig-toughxlat-all.RDS
            cliv16s-readyfig-trichxc.pca-all.RDS
            cliv16s-readyfig-trichxc10.2-all.RDS
            cliv16s-readyfig-trichxc8.4-all.RDS
            cliv16s-readyfig-trichxlat-all.RDS
            cliv16s-readyfig-trichxtough-all.RDS
            cliv16s-toughxc.pca-all.RDS
            cliv16s-toughxc.pca.tiff
            cliv16s-toughxc10.2-all.RDS
            cliv16s-toughxc10.2.tiff
            cliv16s-toughxc8.4-all.RDS
            cliv16s-toughxc8.4.tiff
            cliv16s-toughxlat-all.RDS
            cliv16s-toughxlat.tiff
            cliv16s-trichxc.pca-all.RDS
            cliv16s-trichxc.pca.tiff
            cliv16s-trichxc10.2-all.RDS
            cliv16s-trichxc10.2.tiff
            cliv16s-trichxc8.4-all.RDS
            cliv16s-trichxc8.4.tiff
            cliv16s-trichxlat-all.RDS
            cliv16s-trichxlat.tiff
            cliv16s-trichxtough-all.RDS
            cliv16s-trichxtough.tiff
            mon15g-c.10.5xc.18.6-all.RDS
            mon15g-c.10.5xc.18.6.tiff
            mon15g-c.10.5xc.pca-all.RDS
            mon15g-c.10.5xc.pca.tiff
            mon15g-c.10.5xperc.C-all.RDS
            mon15g-c.10.5xperc.C.tiff
            mon15g-c.10.5xperc.notN-all.RDS
            mon15g-c.10.5xperc.notN.tiff
            mon15g-c.18.6xc.pca-all.RDS
            mon15g-c.18.6xc.pca.tiff
            mon15g-c.18.6xperc.C-all.RDS
            mon15g-c.18.6xperc.C.tiff
            mon15g-c.18.6xperc.notN-all.RDS
            mon15g-c.18.6xperc.notN.tiff
            mon15g-c.pcaxperc.C-all.RDS
            mon15g-c.pcaxperc.C.tiff
            mon15g-c.pcaxperc.notN-all.RDS
            mon15g-c.pcaxperc.notN.tiff
            mon15g-inv.slaxc.10.5-all.RDS
            mon15g-inv.slaxc.10.5.tiff
            mon15g-inv.slaxc.18.6-all.RDS
            mon15g-inv.slaxc.18.6.tiff
            mon15g-inv.slaxc.pca-all.RDS
            mon15g-inv.slaxc.pca.tiff
            mon15g-inv.slaxperc.C-all.RDS
            mon15g-inv.slaxperc.C.tiff
            mon15g-inv.slaxperc.notN-all.RDS
            mon15g-inv.slaxperc.notN.tiff
            mon15g-inv.slaxtough-all.RDS
            mon15g-inv.slaxtough.tiff
            mon15g-inv.slaxtrich-all.RDS
            mon15g-inv.slaxtrich.tiff
            mon15g-lat1xc.10.5-all.RDS
            mon15g-lat1xc.10.5.tiff
            mon15g-lat1xc.18.6-all.RDS
            mon15g-lat1xc.18.6.tiff
            mon15g-lat1xc.pca-all.RDS
            mon15g-lat1xc.pca.tiff
            mon15g-lat1xinv.sla-all.RDS
            mon15g-lat1xinv.sla.tiff
            mon15g-lat1xperc.C-all.RDS
            mon15g-lat1xperc.C.tiff
            mon15g-lat1xperc.notN-all.RDS
            mon15g-lat1xperc.notN.tiff
            mon15g-lat1xtough-all.RDS
            mon15g-lat1xtough.tiff
            mon15g-lat1xtrich-all.RDS
            mon15g-lat1xtrich.tiff
            mon15g-perc.notNxperc.C-all.RDS
            mon15g-perc.notNxperc.C.tiff
            mon15g-readyfig-c.10.5xc.18.6-all.RDS
            mon15g-readyfig-c.10.5xc.pca-all.RDS
            mon15g-readyfig-c.10.5xperc.C-all.RDS
            mon15g-readyfig-c.10.5xperc.notN-all.RDS
            mon15g-readyfig-c.18.6xc.pca-all.RDS
            mon15g-readyfig-c.18.6xperc.C-all.RDS
            mon15g-readyfig-c.18.6xperc.notN-all.RDS
            mon15g-readyfig-c.pcaxperc.C-all.RDS
            mon15g-readyfig-c.pcaxperc.notN-all.RDS
            mon15g-readyfig-inv.slaxc.10.5-all.RDS
            mon15g-readyfig-inv.slaxc.18.6-all.RDS
            mon15g-readyfig-inv.slaxc.pca-all.RDS
            mon15g-readyfig-inv.slaxperc.C-all.RDS
            mon15g-readyfig-inv.slaxperc.notN-all.RDS
            mon15g-readyfig-inv.slaxtough-all.RDS
            mon15g-readyfig-inv.slaxtrich-all.RDS
            mon15g-readyfig-lat1xc.10.5-all.RDS
            mon15g-readyfig-lat1xc.18.6-all.RDS
            mon15g-readyfig-lat1xc.pca-all.RDS
            mon15g-readyfig-lat1xinv.sla-all.RDS
            mon15g-readyfig-lat1xperc.C-all.RDS
            mon15g-readyfig-lat1xperc.notN-all.RDS
            mon15g-readyfig-lat1xtough-all.RDS
            mon15g-readyfig-lat1xtrich-all.RDS
            mon15g-readyfig-perc.notNxperc.C-all.RDS
            mon15g-readyfig-toughxc.10.5-all.RDS
            mon15g-readyfig-toughxc.18.6-all.RDS
            mon15g-readyfig-toughxc.pca-all.RDS
            mon15g-readyfig-toughxperc.C-all.RDS
            mon15g-readyfig-toughxperc.notN-all.RDS
            mon15g-readyfig-toughxtrich-all.RDS
            mon15g-readyfig-trichxc.10.5-all.RDS
            mon15g-readyfig-trichxc.18.6-all.RDS
            mon15g-readyfig-trichxc.pca-all.RDS
            mon15g-readyfig-trichxperc.C-all.RDS
            mon15g-readyfig-trichxperc.notN-all.RDS
            mon15g-toughxc.10.5-all.RDS
            mon15g-toughxc.10.5.tiff
            mon15g-toughxc.18.6-all.RDS
            mon15g-toughxc.18.6.tiff
            mon15g-toughxc.pca-all.RDS
            mon15g-toughxc.pca.tiff
            mon15g-toughxperc.C-all.RDS
            mon15g-toughxperc.C.tiff
            mon15g-toughxperc.notN-all.RDS
            mon15g-toughxperc.notN.tiff
            mon15g-toughxtrich-all.RDS
            mon15g-toughxtrich.tiff
            mon15g-trichxc.10.5-all.RDS
            mon15g-trichxc.10.5.tiff
            mon15g-trichxc.18.6-all.RDS
            mon15g-trichxc.18.6.tiff
            mon15g-trichxc.pca-all.RDS
            mon15g-trichxc.pca.tiff
            mon15g-trichxperc.C-all.RDS
            mon15g-trichxperc.C.tiff
            mon15g-trichxperc.notN-all.RDS
            mon15g-trichxperc.notN.tiff
            mon15s-c.10.5xc.18.6-all.RDS
            mon15s-c.10.5xc.18.6.tiff
            mon15s-c.10.5xc.pca-all.RDS
            mon15s-c.10.5xc.pca.tiff
            mon15s-c.10.5xperc.C-all.RDS
            mon15s-c.10.5xperc.C.tiff
            mon15s-c.10.5xperc.notN-all.RDS
            mon15s-c.10.5xperc.notN.tiff
            mon15s-c.18.6xc.pca-all.RDS
            mon15s-c.18.6xc.pca.tiff
            mon15s-c.18.6xperc.C-all.RDS
            mon15s-c.18.6xperc.C.tiff
            mon15s-c.18.6xperc.notN-all.RDS
            mon15s-c.18.6xperc.notN.tiff
            mon15s-c.pcaxperc.C-all.RDS
            mon15s-c.pcaxperc.C.tiff
            mon15s-c.pcaxperc.notN-all.RDS
            mon15s-c.pcaxperc.notN.tiff
            mon15s-inv.slaxc.10.5-all.RDS
            mon15s-inv.slaxc.10.5.tiff
            mon15s-inv.slaxc.18.6-all.RDS
            mon15s-inv.slaxc.18.6.tiff
            mon15s-inv.slaxc.pca-all.RDS
            mon15s-inv.slaxc.pca.tiff
            mon15s-inv.slaxperc.C-all.RDS
            mon15s-inv.slaxperc.C.tiff
            mon15s-inv.slaxperc.notN-all.RDS
            mon15s-inv.slaxperc.notN.tiff
            mon15s-inv.slaxtough-all.RDS
            mon15s-inv.slaxtough.tiff
            mon15s-inv.slaxtrich-all.RDS
            mon15s-inv.slaxtrich.tiff
            mon15s-lat1xc.10.5-all.RDS
            mon15s-lat1xc.10.5.tiff
            mon15s-lat1xc.18.6-all.RDS
            mon15s-lat1xc.18.6.tiff
            mon15s-lat1xc.pca-all.RDS
            mon15s-lat1xc.pca.tiff
            mon15s-lat1xinv.sla-all.RDS
            mon15s-lat1xinv.sla.tiff
            mon15s-lat1xperc.C-all.RDS
            mon15s-lat1xperc.C.tiff
            mon15s-lat1xperc.notN-all.RDS
            mon15s-lat1xperc.notN.tiff
            mon15s-lat1xtough-all.RDS
            mon15s-lat1xtough.tiff
            mon15s-lat1xtrich-all.RDS
            mon15s-lat1xtrich.tiff
            mon15s-perc.notNxperc.C-all.RDS
            mon15s-perc.notNxperc.C.tiff
            mon15s-readyfig-c.10.5xc.18.6-all.RDS
            mon15s-readyfig-c.10.5xc.pca-all.RDS
            mon15s-readyfig-c.10.5xperc.C-all.RDS
            mon15s-readyfig-c.10.5xperc.notN-all.RDS
            mon15s-readyfig-c.18.6xc.pca-all.RDS
            mon15s-readyfig-c.18.6xperc.C-all.RDS
            mon15s-readyfig-c.18.6xperc.notN-all.RDS
            mon15s-readyfig-c.pcaxperc.C-all.RDS
            mon15s-readyfig-c.pcaxperc.notN-all.RDS
            mon15s-readyfig-inv.slaxc.10.5-all.RDS
            mon15s-readyfig-inv.slaxc.18.6-all.RDS
            mon15s-readyfig-inv.slaxc.pca-all.RDS
            mon15s-readyfig-inv.slaxperc.C-all.RDS
            mon15s-readyfig-inv.slaxperc.notN-all.RDS
            mon15s-readyfig-inv.slaxtough-all.RDS
            mon15s-readyfig-inv.slaxtrich-all.RDS
            mon15s-readyfig-lat1xc.10.5-all.RDS
            mon15s-readyfig-lat1xc.18.6-all.RDS
            mon15s-readyfig-lat1xc.pca-all.RDS
            mon15s-readyfig-lat1xinv.sla-all.RDS
            mon15s-readyfig-lat1xperc.C-all.RDS
            mon15s-readyfig-lat1xperc.notN-all.RDS
            mon15s-readyfig-lat1xtough-all.RDS
            mon15s-readyfig-lat1xtrich-all.RDS
            mon15s-readyfig-perc.notNxperc.C-all.RDS
            mon15s-readyfig-toughxc.10.5-all.RDS
            mon15s-readyfig-toughxc.18.6-all.RDS
            mon15s-readyfig-toughxc.pca-all.RDS
            mon15s-readyfig-toughxperc.C-all.RDS
            mon15s-readyfig-toughxperc.notN-all.RDS
            mon15s-readyfig-toughxtrich-all.RDS
            mon15s-readyfig-trichxc.10.5-all.RDS
            mon15s-readyfig-trichxc.18.6-all.RDS
            mon15s-readyfig-trichxc.pca-all.RDS
            mon15s-readyfig-trichxperc.C-all.RDS
            mon15s-readyfig-trichxperc.notN-all.RDS
            mon15s-toughxc.10.5-all.RDS
            mon15s-toughxc.10.5.tiff
            mon15s-toughxc.18.6-all.RDS
            mon15s-toughxc.18.6.tiff
            mon15s-toughxc.pca-all.RDS
            mon15s-toughxc.pca.tiff
            mon15s-toughxperc.C-all.RDS
            mon15s-toughxperc.C.tiff
            mon15s-toughxperc.notN-all.RDS
            mon15s-toughxperc.notN.tiff
            mon15s-toughxtrich-all.RDS
            mon15s-toughxtrich.tiff
            mon15s-trichxc.10.5-all.RDS
            mon15s-trichxc.10.5.tiff
            mon15s-trichxc.18.6-all.RDS
            mon15s-trichxc.18.6.tiff
            mon15s-trichxc.pca-all.RDS
            mon15s-trichxc.pca.tiff
            mon15s-trichxperc.C-all.RDS
            mon15s-trichxperc.C.tiff
            mon15s-trichxperc.notN-all.RDS
            mon15s-trichxperc.notN.tiff
            readyfigs-list-all.RDS
            

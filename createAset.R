# California Hospital Scores
# Author: Gary Chung
# Create Analysis Dataset
# Source: CHHS Website at chhs.data.ca.gov
# ========================================

# Required Packages
# -----------------
require(dplyr)
require(pacman)

# Import data from CHHS
# ---------------------
p_load(RSocrata)
# Dataset 1
# California Hospital Inpatient Mortality Rates and Quality Ratings, 2012-2013
mortq <- read.socrata("https://chhs.data.ca.gov/resource/rpkf-ugbp.csv", 
                      app_token="ZMR5ynqHns9pJXIrVESvzW9kP")
# Dataset 2
# Ischemic Stroke 30-Day Mortality and 30-Day Readmission Rates and Ratings for 
# California Hospitals, 2011 - 2012
stroke <- read.socrata("https://chhs.data.ca.gov/resource/6yg2-gk2b.csv")

# Save for later access
save(mortq, stroke, file="Data/sourceData.Rdata")


# Join Stroke data to Mortality data
# ----------------------------------
# First manipulate stroke dataset
hold <- stroke %>% filter(!is.na(OSHPDID)) %>% 
  mutate(Procedure.Condition=paste("Stroke", Measure),
         Num.Events=X..of.Deaths.Readmissions,
         Num.Cases=X..of.Cases,
         Latitude=as.numeric(matrix(unlist(strsplit(Location.1, "[(,)]")), 
                                    ncol=3, byrow=T)[, 2]),
         Longitude=as.numeric(matrix(unlist(strsplit(Location.1, "[(,)]")), 
                                     ncol=3, byrow=T)[, 3])) %>%
  select(County, Hospital, OSHPDID, Procedure.Condition, Risk.Adjusted.Rate,
         Num.Events, Num.Cases, Latitude, Longitude)

# Next manipulate mortality dataset
hold2 <- mortq %>% group_by(OSHPDID, County, Hospital, Latitude, Longitude, 
                            Procedure.Condition) %>%
  summarise(Risk.Adjusted.Rate=mean(Risk.Adjusted.Mortality.Rate, na.rm=T),
            Num.Events=sum(X..of.Deaths, na.rm=T),
            Num.Cases=sum(X..of.Cases, na.rm=T))

# Combine
aSet <- rbind.data.frame(hold, hold2) %>% filter(!is.na(Risk.Adjusted.Rate))

# Create an aggregated measure of Risk Adjusted Rate
# To do this, each Procedure-Condition needs to be centered and scaled
# Borrowing a Quality-of-Life scoring concept, I'll center to 50 with a
# standard deviation of 35
# ---------------------------------------------------------------------
ctsc <- by(aSet, aSet$Procedure.Condition, 
           function(x) cbind(Procedure.Condition=x$Procedure.Condition[1],
                             Center=attr(scale(x$Risk.Adjusted.Rate), 
                                         "scaled:center"),
                             Scale=attr(scale(x$Risk.Adjusted.Rate), 
                                        "scaled:scale")))
ctsc <- do.call(rbind.data.frame, ctsc)
ctsc$Center <- as.numeric(as.character(ctsc$Center))
ctsc$Scale <- as.numeric(as.character(ctsc$Scale))
aSet <- merge(aSet, ctsc, all.x=T)
aSet$Rate.Norm <- with(aSet, ((Risk.Adjusted.Rate - Center) / Scale) * 35 + 50)

# Create a weighted average of the normalized Risk Adjusted Rate across all
# Procedure-Conditions. The weighting factor is the Number of Cases.
aSet.all <- aSet %>% group_by(OSHPDID, County, Hospital, Latitude, Longitude) %>%
  summarise(Rate.Norm=weighted.mean(Rate.Norm, Num.Cases),
            Num.Events=sum(Num.Events),
            Num.Cases=sum(Num.Cases))
aSet.all$Procedure.Condition <- "All"

# Fine-tune the scores to allow for intuitive map display
# -------------------------------------------------------
# Invert the normalized rate to approximate a 0-100 scale
aSet.all$Rate.Norm <- 100 - aSet.all$Rate.Norm

# Convert the normalized rate into a color-scale friendly scale
aSet.all$Color.Rate <- with(aSet.all, 
                            ifelse(Rate.Norm < 100 - max(aSet.all$Rate.Norm), 
                                   100-max(aSet.all$Rate.Norm), Rate.Norm))

# Create a conversion for radius of the circle
aSet.all$circle.radius <- 10 * sqrt(aSet.all$Num.Cases)

# Save the analysis dataset
# -------------------------
save(aSet.all, file="Data/aSet.Rdata")
# setwd("/Users/elw/Dropbox/eMacs/projects/aaymca/scripts");source('gistfile2.r')
library(knitr)
library(data.table)
library(ggplot2)
 
setwd('/Users/elw/Dropbox/eMacs/projects/aaymca/YMCA-DATA')
d <- read.delim('/Users/elw/Dropbox/eMacs/projects/aaymca/YMCA-DATA/Original Data - Cleaned.txt', header=F, stringsAsFactors=F)
colnames(d) <- c("mem_number_hash","MIN_FAMILY","CHI_DATE","EXP_DATE","MTP_MTY_PERIOD","MTP_MTY_TYP","MTP_PPL_DESCRIP","MST_MEM_STATE")

## not sure if this is the right thing to do
## sometimes a valid looking member has one entry without
## MTP_MTY_PERIOD, which is his/her earliest entry
# d <- d[!is.na(d$MTP_MTY_PERIOD),] # some sort of weirdness here
 
d <- data.table(d) # for much awesomeness
 
# clean up dates
d[,CHI_DATE:=as.Date(CHI_DATE, format='%m/%d/%Y %H:%M:%S')]
d[,EXP_DATE:=as.Date(EXP_DATE, format='%m/%d/%y')]
d[,MTP_MTY_PERIOD:=as.numeric(strtrim(d$MTP_MTY_PERIOD,4))]
# n <- length(x)
# sort(x,partial=n-1)[n-1]
 
# figure out dummy dates and such
# tmp <- d[,list(minCD=min(CHI_DATE), maxCD=max(CHI_DATE), minED=min(EXP_DATE), maxED=max(EXP_DATE),minMTY=min(MTP_MTY_PERIOD)),by=mem_number_hash]
# maxMinDates <- d[,list(secondSmallestCD=sort(CHI_DATE, partial=length(CHI_DATE)-1)[length(CHI_DATE)-1],minCD=min(CHI_DATE), maxCD=max(CHI_DATE), minED=min(EXP_DATE), maxED=max(EXP_DATE)),by=mem_number_hash]

nthSmallest <- function(vec, n=2){
 # sort(vec, partial=length(vec)-n+1)[length(vec)-n+1]
 # sort(vec, partial=length(vec)-(n-1),decreasing=T)[length(vec)-(n-1)]
 sort(vec)[n]
}

hasNEntry <- function(vec,n=1){
	return (sum(vec,na.rm=T)==n);
}

stateDate <- function(date_vec, state_vec,state){
	sd=c(Inf);
	if(!identical(state_vec[state_vec==state],character(0))){
		sd=date_vec[state_vec[state_vec==state]];
	}
	return(sd);
}

maxMinDates <- d[,list(secondSmallestCD=nthSmallest(CHI_DATE,2),minCD=min(CHI_DATE), maxCD=max(CHI_DATE), 
	minED=min(EXP_DATE), maxED=max(EXP_DATE),minMTY=min(MTP_MTY_PERIOD,na.rm=T),
	hasOneNew=hasNEntry(MST_MEM_STATE=="New",1),hasOneExp=hasNEntry(MST_MEM_STATE=="Expired")),by=mem_number_hash]

browser();
# require at least one date
maxMinDates <- maxMinDates[!is.na(maxMinDates$minCD),];

# only look at ids with at least two dated (CD) entries
maxMinDates <- maxMinDates[!is.na(maxMinDates$secondSmallestCD),];

# remove minCd from Y2k
maxMinDates <- maxMinDates[minCD!='2000-01-01',]# d <- d[!is.na(d$MTP_MTY_PERIOD),] # some sort of weirdness here

# require only a single 'new' entry and single 'exp' entry
## if removed, can take earilest newCD and latest expCD
maxMinDates <- maxMinDates[hasOneNew==TRUE,];
maxMinDates <- maxMinDates[hasOneExp==TRUE,];


# Consider only minMTY >= 2005
cur_name='minMTY'
set(maxMinDates, which(is.infinite(maxMinDates[[cur_name]])), j = cur_name,value =NA);
maxMinDates <- maxMinDates[minMTY>=2005,]


# histograms
hist=qplot(minCD, data=maxMinDates, geom="histogram",xlim=c(as.Date('1985/1/1'),as.Date('2014/1/1')),binwidth=365)
ggsave(hist,file="../slides/figures/latest/h_min_chi_dates.pdf")

hist=qplot(secondSmallestCD, data=maxMinDates, geom="histogram",xlim=c(as.Date('1985/1/1'),as.Date('2014/1/1')),binwidth=365)
ggsave(hist,file="../slides/figures/latest/h_scnd_min_chi_dates.pdf")

# plot.new()
qplot(mem_number_hash,minCD,data=maxMinDates,ylim=c(as.Date('1985/1/1'),as.Date('2014/1/1')));
ggsave(file="../slides/figures/latest/mem_id_vs_min_cd.pdf")

# plot.new()
qplot(mem_number_hash,secondSmallestCD,data=maxMinDates,ylim=c(as.Date('1985/1/1'),as.Date('2014/1/1')));
ggsave(file="../slides/figures/latest/mem_id_vs_scnd_min_cd.pdf")

# plot.new()
qplot(mem_number_hash,minMTY,data=maxMinDates)
ggsave(file="../slides/figures/latest/mem_id_vs_min_mty.pdf")

# plot.new()
qplot(minMTY,minCD,data=maxMinDates,ylim=c(as.Date('1985/1/1'),as.Date('2014/1/1')));
ggsave(file="../slides/figures/latest/min_mty_vs_min_cd.pdf")

# plot.new()
# qplot(minMTY,secondSmallestCD,data=maxMinDates)
qplot(minMTY,secondSmallestCD,data=maxMinDates,ylim=c(as.Date('1985/1/1'),as.Date('2014/1/1')));
ggsave(file="../slides/figures/latest/min_mty_vs_scnd_min_cd.pdf")

# plot.new()
# qplot(minMTY,(as.numeric(secondSmallestCD)-as.numeric(minCD))/365,data=maxMinDates)
qplot(minMTY,(as.numeric(secondSmallestCD)-as.numeric(minCD))/365,data=maxMinDates[!is.na(maxMinDates$secondSmallestCD)])
ggsave(file="../slides/figures/latest/min_mty_vs_delta_cd.pdf")

# plot.new()
# qplot(mem_number_hash,(as.numeric(secondSmallestCD)-as.numeric(minCD))/365,data=maxMinDates)
qplot(mem_number_hash,(as.numeric(secondSmallestCD)-as.numeric(minCD))/365,data=maxMinDates[!is.na(maxMinDates$secondSmallestCD)])
ggsave(file="../slides/figures/latest/mem_id_vs_delta_cd.pdf")

# 
# hist(tmp$maxCD, "years")
# hist(tmp$minED, "years")
# hist(tmp$maxED, "years")
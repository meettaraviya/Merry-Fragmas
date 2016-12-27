options(stringsAsFactors = FALSE)
rawData = read.csv("interest rates.csv")
startDate = "1/1/2006"
endDate = "12/31/2015"
numDaysToPredict = 366

i = grep(paste("^",startDate,sep=""),rawData$Date)
j = grep(paste("^",endDate,sep=""),rawData$Date)
usedData = as.data.frame(sapply(rawData[-1], function(x) as.numeric(x[i:j])))

pcaResult= prcomp(usedData)
numPrComp = 21

shocks = matrix(rnorm(numDaysToPredict*numPrComp),numDaysToPredict,numPrComp)%*%diag(pcaResult$sdev[1:numPrComp])

drifts = matrix(0,numPrComp,numDaysToPredict)
dt = 1/365
for(k in 1:numPrComp){
  driftSum = 0
  factorSqSum = 0
  for(m in 1:numDaysToPredict){
    factorSqSum = factorSqSum + shocks[m,k]^2
    drifts[k,m] = 0.5*dt*factorSqSum-driftSum
    driftSum = driftSum + drifts[k,m]
  }
}

totalDrifts = colSums(drifts)

lastKnownRates = as.list(usedData[1,seq(7,126,4)])
lastKnownRates = matrix(as.matrix(lastKnownRates))

initYields = matrix(NA, numDaysToPredict,1)
initYields[7,1]=lastKnownRates[[1]]
initYields[14,1]=lastKnownRates[[2]]
initYields[30,1]=lastKnownRates[[3]]
initYields[61,1]=lastKnownRates[[4]]
for(k in 1:120){
  if(round(365*k/4)>numDaysToPredict) break
  initYields[round(365*k/4)]=lastKnownRates[[4+k]]
}
for(k in 1:6){
  initYields[k,1]= ((k-7)*lastKnownRates[[2]]+(14-k)*lastKnownRates[[1]])/7
}
require(zoo)
library(zoo)
initYields = na.approx(initYields)

spotRates = matrix(0,numDaysToPredict,1)
spotRates[1,1] = initYields[1]

for(m in 2:numDaysToPredict){
  for(k in 1:(numDaysToPredict+1-m)){
    forwardRates[m,k] = forwardRates[m-1,k+1]+totalDrifts[k+1]*dt+totalDelta[k+1,m]*dt
  }
  spotRates[m,1] = forwardRates[m-1,1]+totalDrifts[m-1]*dt+totalDelta[1,m-1]*dt
}





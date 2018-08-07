function [outputStruct] = processSpikeTrainProperties(inputStruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Description:
% for given cell spike properties/times, advances to next processing stage of 
%  spike train properties (AC, XC with other trains, ISI distribution, firing rate over time, etc.)
%Input:
%
%
%Output:
%
%
%Author: Tibin John, tibintj@umich.edu
%Project directory name: /nfs/turbo/lsa-ojahmed/tibin/segmentedCycleSVDandSpikesProject/scratch 
%Created on 2018-08-02
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
disp('inside processSpikeTrainProperties')

tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baseDir='/Users/tibinjohn/fluxCode/august4_2018/';

%spikeTrainBinSize=1e-3;
spikeTrainBinSize=100e-3;
%maxLagTime=20e-3;
maxLagTime=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%extract input variables from struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cellStr=inputStruct.cellStr;
ptDir=inputStruct.ptDir;
sessionNum=inputStruct.sessionNum;
timeLimits=inputStruct.timeLimits;
stateName=inputStruct.stateName;



%ch=inputStruct.ch;
%chStr=getChStr(ch);

%cellPropDir=sprintf('/nfs/turbo/lsa-ojahmed/tibin/processedHumanData/%s/sessionID-%d/cellProperties-MatFiles',ptDir,sessionNum);
cellPropDir=fullfile(baseDir,sprintf('processedHumanData/%s/sessionID-%d/cellProperties-MatFiles',ptDir,sessionNum));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load cell properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cellPropFile=getRegexFilePath(cellPropDir,sprintf('%s_cell_prop*mat',cellStr))
cellProps=load(cellPropFile);



	cellTypeStr='Intermediate';
	if(cellProps.isInterneuronCell==0)
		cellTypeStr='RS';
	elseif(cellProps.isInterneuronCell==1)
		cellTypeStr='FS';
	end

	 spikeTimes=cellProps.spikeTimes;

	if(exist('timeLimits'))
		spikeTimes=spikeTimes(spikeTimes>timeLimits(1) & spikeTimes<timeLimits(2));
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute output variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
avgFiringRate=length(spikeTimes)/(timeLimits(2)-timeLimits(1));
%^^error if one of time boundaries is Inf?

firingRateBinWidth=1;
firingRateTimeAxis=timeLimits(1):firingRateBinWidth:timeLimits(2);
[firingRate1secBins,~]=histcounts(spikeTimes,firingRateTimeAxis);

ISIs=diff(spikeTimes);


spikeTrainFs=1/spikeTrainBinSize;
spikeTrain=rasterize(spikeTimes,spikeTrainFs);

%maxLagTime=50e-3;
%maxLag=maxLagTime*spikeTrainFs;
%ac=xcorr(spikeTrain,maxLag);
%lagTimeAxis=-maxLagTime:spikeTrainBinSize:maxLagTime;

%figure
otherCellPropFiles=getRegexFilePaths(cellPropDir,sprintf('*_cell_prop*mat'));

	figure(12)
        ha1=tight_subplot(10,10,[.01 .01],[.05 .07],[.04 .04]);

for i=1:length(otherCellPropFiles)
	currCellPropFile=otherCellPropFiles{i}
	currCellProps=load(currCellPropFile);
	currFileName=getFileNameFromPath(currCellPropFile);
	currChStr=currFileName(1:2);
	currCh=str2num(currChStr);

	distSpikeTimes=currCellProps.spikeTimes;
     if(exist('timeLimits'))
		distSpikeTimes=distSpikeTimes(distSpikeTimes>timeLimits(1) & distSpikeTimes<timeLimits(2));
     end
    currFiringRate=length(distSpikeTimes)/(timeLimits(2)-timeLimits(1));
	if(length(distSpikeTimes)<30)
       continue 
    end
    distSpikeTrain=rasterize(distSpikeTimes,spikeTrainFs);
	
	maxLag=maxLagTime*spikeTrainFs;
	xc=xcorr(spikeTrain,distSpikeTrain,maxLag);
	lagTimeAxis=-maxLagTime:spikeTrainBinSize:maxLagTime;

	xc=xc*(geomean([currFiringRate avgFiringRate])/max(xc));
    
	 [plotRow,plotCol]=getChSpatialRowCol(ptDir,currCh);

	linearPos=sub2ind([10 10],plotCol,plotRow);
	 axes(ha1(linearPos))
     [~,zeroIdx]=min(abs(lagTimeAxis));
         %xcNoZero=xc([1:(zeroIdx-1) (zeroIdx+1):end]);
        xc(zeroIdx)=0;
	 plot(lagTimeAxis*1e3,xc,'k*','MarkerSize',2)
         hold on
         plot(lagTimeAxis*1e3,xc,'-')
         
         
         %ylim([min(xc) max(xcNoMax)])
         %ylim([0 max(xcNoZero)*1.2])
        ylim([0 Inf])
                if(plotRow==10)
                         xlabel('Time (ms)')
                 else
                         removeXLabels
                 end
 
                 if(plotCol==1)
                         ylabel('Spike rate (Hz)')
                 end
	 title(sprintf('Channel %d',currCh))	
end
        saveStr=sprintf('%s-Session%d_%s_Cell%s_%s_Spike_Train_Cross_Correlations_Vs_Space',ptDir,sessionNum,stateName,cellStr,cellTypeStr);
	maxFig
        uberTitle(removeUnderscores(saveStr))
        setFontTo(7)

saveas(gcf,[saveStr '.tif'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%store output variables in struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputStruct.avgFiringRate=avgFiringRate;
outputStruct.ISIs=ISIs;
outputStruct.firingRate1secBins=firingRate1secBins;
outputStruct.firingRateTimeAxis=firingRateTimeAxis;
outputStruct.stateName=stateName;
outputStruct.ptDir=ptDir;
outputStruct.sessionNum=sessionNum;
outputStruct.spikeTrainFs=spikeTrainFs;
outputStruct.spikeTrain=spikeTrain;
outputStruct.cellTypeStr=cellTypeStr;
save([saveStr '.mat'],'outputStruct')

toc

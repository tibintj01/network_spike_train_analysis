function [] = freqPowerDistRatePhasePlot(ptDir,sessionNum,stateName,cellStr)

	freqPowerDistRatePhaseFile=sprintf('/Users/tibinjohn/fluxCode/august4_2018/processedHumanData/%s/sessionID-%d/dist%sStructs/Cell%sDistantCycleSpikeStats.mat',ptDir,sessionNum,stateName,cellStr)

	disp('loading frequency-power-rate-phase info file...')
	tic
	freqPowerDistRatePhaseData=load(freqPowerDistRatePhaseFile);
	toc

	phaseBinCenters=freqPowerDistRatePhaseData.distantPhaseStats.f01ch01.phaseBinCenters;
	numPhaseBins=length(phaseBinCenters);
    
    
        numAmpBins=59;
	maxPrctile=97.5;
        ampPrctileBins=((1:numAmpBins)-1)*maxPrctile/numAmpBins;

	freqCenters=freqPowerDistRatePhaseData.freqCenters;
	%numFreqBands=length(freqCenters);
    numFreqBands=50;


	%chStr=cellStr(1:2);
	%chStr='02'
	chStr='03'
	chStr='01'
	close all	
    
    %tight_subplot(Nh, Nw, gap, marg_h, marg_w)
        figure(11)
	%ha1=tight_subplot(10,10,[.01 .03],[.1 .01],[.01 .01]);
	ha1=tight_subplot(10,10,[.01 .01],[.05 .07],[.04 .04]);
        figure(12)
	ha2=tight_subplot(10,10,[.01 .01],[.05 .07],[.04 .04]);
   
	
 
    
	for ch=1:96
		disp('plotting freq-phase-spike count matrix from data...')
		
		    freqPhaseHistMatrix=NaN(numPhaseBins,numFreqBands);
		    freqAmpRateMatrix=NaN(numAmpBins,numFreqBands);
			
		chStr=getChStr(ch)

		[plotRow,plotCol]=getChSpatialRowCol(ptDir,ch);

		linearPos=sub2ind([10 10],plotCol,plotRow);
	
		tic

		for fNum=1:numFreqBands
			fStr=getChStr(fNum);

			try		
	
			currFreqChSpikeStats=freqPowerDistRatePhaseData.distantPhaseStats.(sprintf('f%sch%s',fStr,chStr));
			catch ME
				disp(ME)
				continue
			end		
	
			inferredSpikeRate=currFreqChSpikeStats.pSpikeGivenZ;	
			freqCenters(fNum)=mean(currFreqChSpikeStats.fpass);
		    
			%freqPhaseHistMatrix(:,fNum)=currFreqChSpikeStats.firstPhaseHist;
			freqPhaseHistMatrix(:,fNum)=currFreqChSpikeStats.allPhaseHist;
			freqAmpRateMatrix(:,fNum)=inferredSpikeRate;
		end

		%figure
		%polarPcolor(log10(freqCenters(:))',phaseBinCenters(:)',freqPhaseHistMatrix)
		figH=figure(11)
		axes(ha1(linearPos))
		omarPcolor(phaseBinCenters(:)',freqCenters(:)',freqPhaseHistMatrix',figH)
		set(gca,'yscale','log')
		grid off
		colormap jet
		cb=colorbar

		title(sprintf('Channel %d',ch))
		
		
		if(plotCol==10)
			ylabel(cb,'All spike count')
		end
		if(plotRow==10)
			xlabel('Phase (degrees)')
                else
			removeXLabels
		end
		
		if(plotCol==1)
			ylabel('LFP freq. (Hz)')
		end
		toc


		figH2=figure(12)
                axes(ha2(linearPos))
                omarPcolor(ampPrctileBins(:)',freqCenters(:)',freqAmpRateMatrix',figH2)
		grid off
                set(gca,'yscale','log')
                colormap jet
                cb=colorbar

                title(sprintf('Channel %d',ch))
                
                
                if(plotCol==10)
                        ylabel(cb,'Spike rate (Hz)')
                end
                if(plotRow==10)
                        xlabel('Amp. Perc.')
                else
			removeXLabels
		end
                
                if(plotCol==1)
                        ylabel('LFP freq. (Hz)')
                end
                toc

	end

	saveStrPhase=sprintf('%s-Session%d_%s_Cell%s_Phase_Vs_Freq_and_Space',ptDir,sessionNum,stateName,cellStr);
	saveStrRate=sprintf('%s-Session%d_%s_Cell%s_Rate_Vs_Freq_and_Space',ptDir,sessionNum,stateName,cellStr);
	
	figure(11)
	maxFig
	uberTitle(removeUnderscores(saveStrPhase))
	setFontTo(7)

	saveas(gcf,[saveStrPhase '.tif'])	
	figure(12)
	maxFig
	uberTitle(removeUnderscores(saveStrRate))
	setFontTo(7)
	saveas(gcf,[saveStrRate '.tif'])	


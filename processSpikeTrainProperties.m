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

disp('starting')
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%extract input variables from struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cellStr=inputStruct.cellStr;
ptDir=inputStruct.ptDir;
sessionNum=inputStruct.sessionNum;
ch=inputStruct.ch;
timeLimits=inputStruct.timeLimits;
stateName=inputStruct.stateName;


chStr=getChStr(ch);



cellPropDir=sprintf('/nfs/turbo/lsa-ojahmed/tibin/processedHumanData/%s/sessionID-%d/cellProperties-MatFiles',ptDir,sessionNum);

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%store output variables in struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
toc

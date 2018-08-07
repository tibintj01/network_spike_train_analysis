ptDir='MG49';
sessionNum=3;

for ch=1:96
	for cellNum=1:4
		for wakeBool=0:1
			if(wakeBool)
				stateName='Wake';
				timeLimits=[0 10000];
			else
				stateName='Sleep';
				timeLimits=[10000 16000];
			end
			chStr=getChStr(ch);
			cellStr=[chStr num2letter(cellNum)];

			try
				inputStruct.cellStr=cellStr;
				inputStruct.ptDir=ptDir;
				inputStruct.sessionNum=sessionNum;
				inputStruct.timeLimits=timeLimits;
				inputStruct.stateName=stateName;

				[outputStruct] = processSpikeTrainProperties(inputStruct);
				%fds
			catch ME
				disp(ME.message)
				error('stop')
			end
		end
	end
end



#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function regression_analysis_microhomeostasis(mean_quiescet_bout_duration, Motion_bout_duration, sem)
	wave mean_quiescet_bout_duration, Motion_bout_duration, sem
	wave mean_quiescet_bout_duration_CH,mean_quiescet_bout_duration_CL,mean_quiescet_bout_duration_PH,mean_quiescet_bout_duration_PL
	wave w_statslinearregression
	wave regression1
	
	StatsLinearRegression /T=1/Q  mean_quiescet_bout_duration
	Duplicate/O mean_quiescet_bout_duration regression1
	regression1 = w_statslinearregression[0][1] + w_statslinearregression[0][2] * x
	Display/K=1 mean_quiescet_bout_duration,regression1 vs Motion_bout_duration
	StatsLinearCorrelationTest  mean_quiescet_bout_duration,Motion_bout_duration
	StatsLinearRegression /T=1/Q/BCIW/BPIW  mean_quiescet_bout_duration
	AppendToGraph/B=newaxis mean_quiescet_bout_duration_CH
	AppendToGraph/B=newaxis mean_quiescet_bout_duration_CL
	ModifyGraph rgb(mean_quiescet_bout_duration_CH)=(19675,39321,1),rgb(mean_quiescet_bout_duration_CL)=(19675,39321,1)
	ModifyGraph rgb(mean_quiescet_bout_duration)=(39321,1,1),rgb(regression1)=(0,0,0);DelayUpdate
	ErrorBars mean_quiescet_bout_duration Y,wave=(sem,sem)
	ModifyGraph fSize(bottom)=18,axThick(bottom)=1.2
	ModifyGraph fSize=18,axThick=1.2
	ModifyGraph width=510.236,height={Aspect,1}
	ModifyGraph noLabel(newaxis)=2
	Modifygraph axThick(newaxis)=0
	Label left "Mean quiescent duration (sec)"
	Label bottom "Motion bout duration (sec)"
	ModifyGraph width=283.465
	
end

extends Control

func changePrompt(inspect: bool, jobId: int):
	if(!inspect):
		showJobPanel(jobId)
		$NinePatchRect/CancelPrompt.show()
		$NinePatchRect/InspectPrompt.hide()
	else:
		hideJobPanel()
		$NinePatchRect/CancelPrompt.hide()
		$NinePatchRect/InspectPrompt.show()

func showInspect(inspect: bool):
	if inspect:
		$NinePatchRect/InspectPrompt.show()
	else:
		$NinePatchRect/InspectPrompt.hide()

func showJobPanel(jobId: int):
	#fetch job data using jobId and fill it up and then
	$Panel.show()
	
func hideJobPanel():
	$Panel.hide()

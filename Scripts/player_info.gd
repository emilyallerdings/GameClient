extends HBoxContainer

func setID(id):
	$ID.text = str(id)
	
func setName(pname):
	$NAME.text = pname
	
func setReady(ready):
	$CheckBox.button_pressed = ready

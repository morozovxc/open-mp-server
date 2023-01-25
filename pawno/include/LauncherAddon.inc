native SetLauncherStatus(playerid, bool:status);
native GetLauncherStatus(playerid);
/*--------[Custom Skins Models]--------*/
forward GetLauncherSkinModel(current_model);
public GetLauncherSkinModel(current_model)
{
	new model = -1;
	switch(current_model)
	{
	    case 312: model = 296;
	    case 313: model = 230;
	    case 908: model = 200;
	}
	return model;
}
/*--------[Custom Vehicles Models]--------*/
forward GetLauncherVehicleModel(current_model);
public GetLauncherVehicleModel(current_model)
{
	new model = -1;
	switch(current_model)
	{
	    case 15071: model = 562;
	}
	return model;
}
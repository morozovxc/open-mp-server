#include <a_samp>
#include <filemanager>

#define CATALOG "./movies"

main()
{

    new dir:dHandle = dir_open(CATALOG);
	new item[40], type;

	while(dir_list(dHandle, item, type))
	{
	    if(type == FM_FILE) printf("%s is a file", item);
	    else if(type == FM_DIR) printf("%s is a directory", item);
	}

	dir_close(dHandle);
}

/*
native dir:dir_open(directory[]);
native dir_close(dir:handle);
native dir_list(dir:handle, storage[], &type, length = sizeof(storage));
*/

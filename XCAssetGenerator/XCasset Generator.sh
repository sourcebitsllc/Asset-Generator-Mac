#!/bin/bash
#set -x

# TODO: sanitize the inputs.
sourcePath="$1";
destinationPath="$2";
shouldGenerate1x=$3;

TEMPDIR=".XCAssetTemp"
TEMPFULLPATH="$sourcePath$TEMPDIR"

# TODO: generate1x flow logic. Some leftovers still here. 

deleteTempDirectory() {

	if [ -d "$TEMPFULLPATH" ] ; then   # do we need full path? or is TEMPDIR enough? + Make sure permission are clean.
		rm -rf "$TEMPFULLPATH";
	fi	
}

setupTempDirectory() {
	
    # If temp directory exists, delete it and its contents.
	deleteTempDirectory;

	# Create temp directory.
	mkdir -m 777 "$TEMPFULLPATH"; ## TODO: Find better permissions
	
	# Find all PNGs in directory and copy them into temp.
	find "$sourcePath" -name "*.png" -print0 | while read -d $'\0' -r i ; do
	
		name=`basename "$i"`;
		relativePath=${i#$sourcePath/};

		# If name is not the relativePath, then its in a folder.
		if [[ "$relativePath" != "$name" ]] ; then

			folderPath=${i%$name};
			folderName=${folderPath#$sourcePath/};

			if [[ ! -d "$TEMPFULLPATH"/"$folderName" ]] ; then
				mkdir -p -m 777 "$TEMPFULLPATH"/"$folderName";
			fi
			cp -rf "$i" "$TEMPFULLPATH"/"$folderName"; 
		else
			cp "$i" "$TEMPFULLPATH";
		fi
	done
}


createAppIcon() {
	
	find "$TEMPFULLPATH" -name "AppIcon*.png" -print0 | while read -d $'\0' -r i ; do 

		# a=`basename "$i"`;
		# imagePath=${i%$a};
		
		imagePath=`dirname "$i"`;
        if [[ ! -d "$imagePath/AppIcon.appiconset" ]] ; then
			mkdir "$imagePath/AppIcon.appiconset";
			mv "$i" "$imagePath/AppIcon.appiconset";
		else
			mv "$i" "$imagePath/AppIcon.appiconset";
		fi
        
	done


	# First, find all non-@2x AppIcon pngs. Keep in mind AppIcon~*.png cases.
	# find "$TEMPFULLPATH" -name "AppIcon*.png" ! -name "AppIcon*@2x*.png" -print0 | while read -d $'\0' -r i ; do
		
	# 	a=`basename "$i"`;
	# 	imagePath=${i%$a};
	# 	dirname="AppIcon.appiconset";

	# 	if [[ ! -d "$imagePath/$dirname" ]] ; then
	# 		mkdir "$imagePath/$dirname";
	# 	fi
 #        mv "$i" "$imagePath/$dirname";
	# done
	
	# find "$TEMPFULLPATH" -name "AppIcon*@2x*.png" -print0 | while read -d $'\0' -r i ; do
	
	# 	a=`basename "$i"`;
	# 	imagePath=${i%$a};		
	# 	dirname="AppIcon.appiconset";

	# 	if [[ ! -d "$imagePath/$dirname" ]] ; then
			
	# 		mkdir "$imagePath/$dirname";
	# 		mv "$i" "$imagePath/$dirname";
	# 		# if [[ $shouldGenerate1x == 1 ]] ; then
	# 		# 	generate1x "$TEMPFULLPATH/$dirname/$a";
	# 		# fi
	# 	else
	# 		mv "$i" "$imagePath/$dirname";
	# 	fi
		
	# done
}

createLaunchImage() {
	

	find "$TEMPFULLPATH" -name "LaunchImage*.png" -print0 | while read -d $'\0' -r i ; do 

		a=`basename "$i"`;
		imagePath=${i%$a};
		# dirname=$"LaunchImage.launchimage";
			
        if [[ ! -d "$imagePath/LaunchImage.launchimage" ]] ; then
			mkdir "$imagePath/LaunchImage.launchimage";
			mv "$i" "$imagePath/LaunchImage.launchimage";
		else
			mv "$i" "$imagePath/LaunchImage.launchimage";
		fi
        
	done



	# First, find all non-@2x LaunchImages 

	# find "$TEMPFULLPATH" -name "LaunchImage*.png" ! -name "LaunchImage*@2x*.png" -print0 | while read -d $'\0' -r i ; do

	# 	a=`basename "$i"`;
	# 	imagePath=${i%$a};
	# 	dirname=$"LaunchImage.launchimage";
		
	# 	if [[ ! -d "$imagePath/$dirname" ]] ; then
	# 		mkdir "$imagePath/$dirname";
	# 	fi
 #        mv "$i" "$imagePath/$dirname";
        
	# done
	
	# # Next, look for the @2x launch image
	# find "$TEMPFULLPATH" -name "LaunchImage*@2x*.png" -print0 | while read -d $'\0' -r i ; do	
		
	# 	a=`basename "$i"`;
	# 	imagePath=${i%$a};
	# 	dirname="LaunchImage.launchimage";

	# 	if [[ ! -d "$imagePath/$dirname" ]] ; then
	# 		mkdir "$imagePath/$dirname";
	# 		mv "$i" "$imagePath/$dirname";
			
	# 		# if [[ $shouldGenerate1x == 1 ]] ; then
	# 		# 	generate1x "$TEMPFULLPATH/$dirname/$a";
	# 		# fi
	# 	else
	# 		mv "$i" "$imagePath/$dirname";
	# 	fi
        
	# done
}


createImagesets() {
	
	find "$TEMPFULLPATH" -name "*.png" ! -name "LaunchImage*" ! -name "AppIcon*" -print0 | while read -d $'\0' -r i ; do 
		
		a=`basename "$i"`;
		imagePath=${i%$a};
		
		if [[ "$a" != *@2x*.png ]]  ; then
			dirname=${a%~ip*};	# remove the idiom identifier (~iphone + ~ipad) for the dirname
			dirname=${dirname%.png}".imageset";
		else ## [[ "$a" == *@2x*.png ]]
			dirname=${a%@2x*.png};
			dirname=${dirname%~ip*}".imageset"; # remove the idiom identifier (~iphone + ~ipad) for the dirname 
		fi
		
        if [[ ! -d "$imagePath/$dirname" ]] ; then
			mkdir "$imagePath/$dirname";
			mv "$i" "$imagePath/$dirname";
		else
			mv "$i" "$imagePath/$dirname";
		fi
        
	done

	# First, find all non-@2x pngs which aren't Appicons or LaunchImages. TODO: Filter out @2x.
	# find "$TEMPFULLPATH" -name "*.png" ! -name "LaunchImage*" ! -name "AppIcon*" -print0 | while read -d $'\0' -r i ; do 

	# 	a=`basename "$i"`;
	# 	imagePath=${i%$a};

 #        if [[ "$a" == *.png ]] && [[ "$a" != *@2x*.png ]]  ; then
	# 		dirname=${a%~ip*};	# remove the idiom identifier (~iphone + ~ipad) for the dirname
	# 		dirname=${dirname%.png}".imageset";
 			
 # 			if [[ ! -d "$imagePath/$dirname" ]] ; then
	# 			mkdir "$imagePath/$dirname";
	# 		fi

 #            mv "$i" "$imagePath/$dirname";
 #        fi
	# done
	



	# ## Next, look for @2x, and if the imageset directory doesnt exist, that means this png doesnt have an accompanying 1x.
	# find "$TEMPFULLPATH" -name "*@2x*.png" ! -name "LaunchImage*" ! -name "AppIcon*" -print0 | while read -d $'\0' -r i ; do 	## search only the root directory (dont traverse)

	# 	a=`basename "$i"`;
	# 	imagePath=${i%$a};

	# 	# if [[ "$a" == *@2x*.png ]] ; then
	# 		dirname=${a%@2x*.png};
	# 		dirname=${dirname%~ip*}".imageset"; # remove the idiom identifier (~iphone + ~ipad) for the dirname

	# 		if [[ ! -d "$imagePath/$dirname" ]] ; then
	# 			mkdir "$imagePath/$dirname";
	# 			mv "$i" "$imagePath/$dirname";
				
	# 			# if [[ $shouldGenerate1x == 1 ]] ; then
	# 			# 	generate1x "$TEMPFULLPATH/$dirname/$a";
	# 			# fi
	# 		else
	# 			mv "$i" "$imagePath/$dirname";
	# 		fi
		
	#     # fi
 #    done

}


# generate1x() {

# 	d="$1";	
# 	# Make a copy of the file.
# 	a=${d/@2x/};
# 	cp "$d" "$a";

# 	# Get the images' dimensions, half them, then create new image with new dimensions.
# 	width=`sips -g pixelWidth "$a" | tail -n1 | cut -d' ' -f4`;
#     height=`sips -g pixelHeight "$a" | tail -n1 | cut -d' ' -f4`;
#     width=$(expr $width / 2);
#     height=$(expr $height / 2);
#     #name=`basename "$d"`;
    
#     sips -z $height $width "$a";
# }

# Takes file (basename) as argument. 
create_json_content() {

	JSONFile="$1"/Contents.json; 

	# Initialize the JSON with the proper "stuffing".
	echo "{
  \"images\" : [" >> "$JSONFile";

	find "$1"/* -name "*.png" -prune -print0 | while read -d $'\0' -r imagePath ; do
 	
 		imageName=`basename "$imagePath"`;
		orientation="invalid";
		subtype="invalid";

		# Determine scale
		scale="1x";
		if [[ "$imageName" == *@2x* ]] ; then
			scale="2x";
		fi

		# Determine idiom
		idiom=$"universal";

		if [[ "$imageName" == *~iphone* ]] ; then
			idiom="iphone";
		else if [[ "$imageName" == *~ipad* ]] ; then
				idiom="ipad";
			 fi
		fi

		if [[ "$imageName" == AppIcon*.png ]] ; then
			width=`sips -g pixelWidth "$imagePath" | tail -n1 | cut -d' ' -f4`;
			if [[ $width == "60" ]] ; then   # invalid size for iOS7. Heads up.
				idiom="iphone";
				scale="1x";
				size="60x60";
			else if [[ $width == "120" ]] ; then
				idiom="iphone";
				scale="2x";
				size="60x60";
				fi
			fi 

			if [[ $width == "76" ]] ; then
				idiom="ipad";
				scale="1x";
				size="76x76";
			else if [[ $width == "152" ]] ; then
				idiom="ipad";
				scale="2x";
				size="76x76";
				fi
			fi
		fi
		

		# 640 x 1136 pixels = sub-type = "R4"
		if [[ "$imageName" == LaunchImage*.png ]] ; then
			width=`sips -g pixelWidth "$imagePath" | tail -n1 | cut -d' ' -f4`;

			if [[ $width == "320" ]] ; then
				idiom="iphone";
				scale="1x";
				orientation="portrait";
			else if [[ $width == "640" ]] ; then
				 idiom="iphone";
				 scale="2x";
				 orientation="portrait";

	 			 height=`sips -g pixelHeight "$imagePath" | tail -n1 | cut -d' ' -f4`;
				 if [[ $height == "1136" ]] ; then
					# 640 x 1136 pixels = sub-type: R4
					subtype="retina4";
				 fi
				fi
			fi 

			if [[ $width == "768" ]] ; then
				idiom="ipad";
				scale="1x";
				orientation="portrait";
			else if [[ $width == "1536" ]] ; then
				idiom="ipad";
				scale="2x";
				orientation="portrait";
				size="768x1024";
				fi
			fi

			if [[ $width == "1024" ]] ; then
				idiom="ipad";
				scale="1x";
				orientation="landscape";
			else if [[ $width == "2048" ]] ; then
				idiom="ipad";
				scale="2x";
				orientation="landscape";
				fi
			fi
		
		fi

		# Calculate minimum-system-version
		echo "    {
      \"idiom\" : \"$idiom\",
      \"scale\" : \"$scale\",";

      if [[ "$imageName" == LaunchImage*.png ]] ; then
	      echo "      \"orientation\" : \"$orientation\",
	  \"extent\" : \"full-screen\",
      \"minimum-system-version\" : \"7.0\",";

      	if [[ "$subtype" != invalid ]] ; then
      		echo "      \"subtype\" : \"$subtype\",";
      	fi

	  fi
	  if [[ "$imageName" == AppIcon*.png ]] ; then
		 echo "      \"size\" : \"$size\",";
	  fi
      
      echo "      \"filename\" : \"$imageName\"
    },";

	done >> "$JSONFile";
	
	# Delete the last line of the file to remove the trailing ",".
	# sed -i '' '$!P;$!D;$d' "$JSONFile";

	# Add the final chunk to the JSON 
 	echo "  ],
  \"info\" : {
    \"version\" : 1,
    \"author\" : \"xcode\"
  }
}" >> "$JSONFile";

}

# -c, Compare files by Checksum.
# --size-only, Compare files by size. (lulwut)
# -z, Compress during tranfser.
# -a, archive mode.
# -v, Verbose mode.
# -h, Human-readable.
# -u, skip files that are newer on the receiver.
# --inplace,
# --sparse,
# -W, copy files whole (w/o delta-xfer algorithm)
# rsync -czvhra "$a" "$destinationPath"/"$folderName";


integrateToDestination() {

	find "$TEMPFULLPATH" \( -name "*.png" \) -print0 | while read -d $'\0' -r a ; do
		name=`basename "$a"`;
		folderPath=${a%$name};
		folderName=${folderPath#$TEMPFULLPATH/};

		if [[ ! -d "$destinationPath"/"$folderName" ]] ; then
			mkdir -p -m 777 "$destinationPath"/"$folderName";
		fi
		cp -rf "$a" "$destinationPath"/"$folderName";  # TODO: -r or -rf? double check
	done

	find "$TEMPFULLPATH" \( -name "*.json" \) -print0 | while read -d $'\0' -r a ; do
		name=`basename "$a"`;
		folderPath=${a%$name};
		folderName=${folderPath#$TEMPFULLPATH/};

		if [[ ! -d "$destinationPath"/"$folderName" ]] ; then
			mkdir -p -m 777 "$destinationPath"/"$folderName";
		fi

		if cmp "$destinationPath"/"$folderName"/"$name" "$a" ; then
			echo "same";
		else
			echo "not"
			if [[ -f "$destinationPath"/"$folderName"/"$name" ]] ; then
				echo "But exists";
				rsync -ca --append "$a" "$destinationPath"/"$folderName";
			else
				echo "doesnt even exist";
				cp -rf "$a" "$destinationPath"/"$folderName";
			fi
			
		fi
	done


	# find "$TEMPFULLPATH" \( -name "*.imageset" -o -name "*.appiconset" -o -name "*.launchimage" \) -print0 | while read -d $'\0' -r i ; do

	# 	name=`basename "$i"`;
	# 	folderPath=${i%$name};
	# 	folderName=${folderPath#$TEMPFULLPATH/};
		
	# 	if [[ ! -d "$destinationPath"/"$folderName" ]] ; then
	# 		mkdir -p -m 777 "$destinationPath"/"$folderName";
	# 	fi
	# 	# cp -rf "$i" "$destinationPath"/"$folderName";  # TODO: -r or -rf? double check
	# 	# echo "****** Send"
	# 	# rsync -cvhra "$i" "$destinationPath"/"$folderName";
	# 	# echo "****** End"
	# 	rsync -cru "$i" "$destinationPath"/"$folderName";

	# done
}


## Entry Point. ##
##################

#TODO: Add all the proper flow control here.
echo "1: Setting Up Temp";
time { 
setupTempDirectory 
};

echo "2: Creating AppIcon";
time {
createAppIcon;
}

echo "3: Creating LaunchImages";
time { 
createLaunchImage 
};

echo "4: Creating Imagesets";
time { 
createImagesets 
};

# At this point, every file in the directory should've been processed.
echo "5: Creating JSON";
time {
find "$TEMPFULLPATH" \( -name "*.imageset" -o -name "*.appiconset" -o -name "*.launchimage" \) -print0 | while read -d $'\0' -r i ; do
	create_json_content "$i";
done
};

echo "6: Integrate to Destination";
# Move the final files to the proper destination.
time {
	integrateToDestination;
};

# Cull the temp directory after finishing.
echo "7: Delete Temp";
time {
deleteTempDirectory;
}


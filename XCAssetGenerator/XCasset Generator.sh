#!/bin/bash

createImagesets() {
    for d in *; do
        if [ -d $d ] ; then
            (cd $d; createImagesets)
        fi
        if [ -f $d ] ; then
            a=${d%@2x.*};
            dirname=$a".imageset";
            mkdir $dirname;
            mv $d $dirname;
        fi
    done
}

duplicateFiles() {
    for d in *; do
        if [ -d $d ] ; then
            (cd $d; duplicateFiles)
        fi
        if [ -f $d ] ; then
            a=${d%@2x.*};
            a=$a".png";
            cp $d $a;
        fi
    done
}

resize_non2xfiles() {
for d in *; do
    if [ -d $d ] ; then
        (cd $d; resize_non2xfiles)
    fi
    if [ -f $d ] ; then
        if [ $d == "${d/@2x.png/}" ] ; then
            width=`sips -g pixelWidth $d | tail -n1 | cut -d' ' -f4`;
            height=`sips -g pixelHeight $d | tail -n1 | cut -d' ' -f4`;
            name=`basename "$d"`;
            width=$(expr $width / 2);
            height=$(expr $height / 2);
            sips -z $height $width $d;
        fi
    fi
done
}

create_content_json() {
for d in *; do
    if [ -d $d ] ; then
        (cd $d; create_content_json)
        if [ $d !=  "${d/.imageset/}" ]; then
            filename0=${d%.*};
            filename1=$filename0".png";
            filename2=$filename0"@2x.png";
            echo "{\"images\":[{\"idiom\":\"universal\",\"scale\":\"1x\",\"filename\":\"$filename1\"},{\"idiom\":\"universal\",\"scale\":\"2x\",\"filename\":\"$filename2\"}],\"info\":{\"version\":1,\"author\":\"xcode\"}}" >> $d/Contents.json
        fi
    fi
done
}

synctorepo() {
    mysource=${PWD}"/";
    destination="/Users/Piotr/Code/SAM/SAM/Images.xcassets/";
    chmod -R a+rwx "$mysource"
    rsync -avhu --delete --size-only --exclude "*appiconset" --exclude "*launchimage" "$mysource" "$destination";
}

createImagesets;
duplicateFiles;
resize_non2xfiles;
create_content_json;
synctorepo;
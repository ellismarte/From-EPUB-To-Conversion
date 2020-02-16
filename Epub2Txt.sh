#!/bin/bash

# read parameters from input
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -i|--in)
    SOURCE="$2"
    shift
    ;;
    -o|--out)
    TARGET="$2"
    shift
    ;;
    -p)
    PANDOC="$2"
    shift
    ;;
    -t)
    TEMPDIR="$2"
    shift
    ;;
    *)
esac
shift # past argument or value
done
ROOT_DIR=$(pwd)
filename=$(basename "$TARGET")
TARGETEXTENSION="${filename##*.}"
TARGETFILENAME="${filename%.*}"
TEMPDIR="${TEMPDIR}"
PANDOC="${PANDOC:-"pandoc"}"
TEXTFOLDER=$TEMPDIR"/"$TARGETFILENAME
CHAPTER_DIR=$TEXTFOLDER"/Chapters"

printf '%s\n'
echo INITIAL VARIABLES
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo SOURCE === $SOURCE
echo TARGET === $TARGET
echo TARGET EXTENSION === $TARGETEXTENSION
echo TARGET FILENAME === $TARGETFILENAME
echo PANDOC EXECUTABLE === $PANDOC
echo TEMP DIR === $TEMPDIR
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
printf '%s\n'

echo '-------'CREATE TEMP DIR
if [ ! -d $TEMPDIR ]; then
  mkdir -p $TEMPDIR;
fi
echo '-------'DONE
printf '%s\n'

echo '-------'CREATE TEXT DIR
if [ ! -d $TEXTFOLDER"/Chapters" ]; then
  mkdir -p $TEXTFOLDER"/Chapters";
fi
echo '-------'DONE
printf '%s\n'

echo '-------'RUN PANDOC
$PANDOC -s --from epub --to plain -o $TEXTFOLDER"/COMPLETE_"$TARGETFILENAME.txt $SOURCE
echo '-------'DONE
printf '%s\n'

echo '-------'COPY EPUB TO TEMP
cp $SOURCE $TEMPDIR"/"source.epub
echo '-------'DONE
printf '%s\n'

echo '-------'UNZIP SOURCE EPUB
cd $TEMPDIR
unzip ./source.epub
echo '-------'DONE
printf '%s\n'

echo '-------'RUN PANDOC FOR EACH CHAPTER

ROOT_OF_TEMP=$(pwd)
CHAPTER_DIR="$ROOT_OF_TEMP/$TARGETFILENAME/Chapters"
cd "./OEBPS/"
OEBPS_DIR=$(pwd)

for chapterhtml in *.html; do
    # chapter name without html ending
    chaptername=$(echo $chapterhtml | cut -f 1 -d '.')
    echo $OEBPS_DIR
    $PANDOC -s -r html "$OEBPS_DIR/$chapterhtml" -o "$CHAPTER_DIR/$chaptername.txt"
done
echo '-------'DONE
printf '%s\n'

echo '-------'CREATE ZIP
cd $ROOT_DIR
mv $TEXTFOLDER "./converted"
echo '-------'DONE
printf '%s\n'

echo '-------'DELETE TEMP DIR
rm -rf $TEMPDIR
echo '-------'DONE
printf '%s\n'
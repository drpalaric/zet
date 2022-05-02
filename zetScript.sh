#!/bin/bash

############################################################
# Help                                                     #
############################################################

x.help()
{
  # Display Help
  echo "This is the Zettelkästen script I use to generate Zettel."
  echo "Syntax: zet [-g|h|p]"
  echo "options:"
  echo "g     Generate a new Zettel" # should have its own directory 
  echo "h     Display this help"
  echo "p     Push Zettel to Github"
  echo "l     List all the Zettle in the /zet directory" # show filename and first few characters
  echo "r     Read a Zettel"
  echo "d     Delete a Zettel" # should be able to remove a Zettel by filename
  echo "s     Search for a Zettel" # should be a regex search inside all the Zettel
  echo "o     Open/View a Zettel" # should be able to select a Zettel to open
  echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################


ZETDIR="$HOME/code/zet/"

x.push_zet() {
  # Commit to git
  cd $ZETDIR
  git add .
  git commit -m "added new zet"  
  git push origin -u master 
}

x.gen_zet() {
  # Generate a new Zettel
  local today=$(date +%Y%m%d)
  local randnum=$(date +%s)
  mkdir -p "$ZETDIR/$today$randnum" && cd "$_" && touch "README.md"
  vim README.md
}

x.open_zet() {
  # Open a Zettel
  select zet in $(basename $ZETDIR*); do
    if [ -n $zet ]; then
      cd $zet && vim README.md
      break
    fi
  done
}

x.delete_zet()  {
  # Delete a Zettel
  echo "Which nasty little Zettel do you want to get rid of?"
  select zet in $(basename $ZETDIR*); do
    if [ -n $zet ]; then
      rm -r $zet
      echo "Removed a nasty little Zettel named $(basename $zet)"
      break
    fi
  done
}

x.list_zet() { 
# List all the Zettel in the /zet directory
 stat -f "%Sm %N" $ZETDIR* 
#  | basename -s md | sort -rn
}

x.read_tags() {
  # read tags from all files
  for f in $ZETDIR*; do
    echo $(basename $f):$(awk '/Tags/{y=1;next}y' $f) | column -t -s ":"
  done
}

x.read_file_contents() {
  # read a file before editing
  # check if we're in a directory, if not, then read the README.md file
  # if you're in a directory, then read the README.md file in that directory
  select zet in $ZETDIR*; do
    if [ -n $zet ]; then
      if [ -d $zet ]; then
        cd $zet && cat README.md
      else
        cat $zet
      fi
    fi
  done
}

x.search_zet() {
  # Search for a Zettel
  search_term=$1
  echo $(grep -ril --color=always  "$search_term" $ZETDIR*)
}

# Add the options
while getopts ":hcgplrsotd" option; do 
  case $option in
    h)
      x.help
      exit 0
      ;;
    c)
      # copy?
      exit 0
      ;;
    g)
      x.gen_zet
      exit 0
      ;;
    p)
      echo "Pushing Zettel to Github"
      x.push_zet
      exit 0
      ;;
    l)
      x.list_zet
      exit 0
      ;;
    r)
      x.read_file_contents
      exit 0
      ;;   
    d)
      x.delete_zet
      exit 0
      ;;
    s)
      x.search_zet $2
      exit 0
      ;;
    o)
      x.open_zet
      exit 0
      ;;
    t) 
      echo "Reading tags from all Zettels"
      echo ------------
      x.read_tags
      exit 0
      ;;
    \?)
      echo "Unknown option: $option"
      exit 1
      ;;
  esac
done

############################################################
############################################################
#                                                          #
# Installed util-linux for some extra features             #
#                                                          #
############################################################
############################################################
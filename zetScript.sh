#!/bin/bash

############################################################
# Help                                                     #
############################################################

function display_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
    echo "  -h        Show help"
    echo "  -c        Copy (functionality not implemented)"
    echo "  -e        List environment variables"
    echo "  -g        Generate Zettel"
    echo "  -p        Push Zettel to GitHub"
    echo "  -l        List Zettels"
    echo "  -r        Read file contents"
    echo "  -d        Delete Zettel"
    echo "  -s <arg>  Search Zettel"
    echo "  -o        Open Zettel"
    echo "  -t        Read tags from all Zettels"
    echo "  --st      Search tags"
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################


ZETDIR="$HOME/Projects/zet/"

function main() {
    local OPTIND option

    while getopts ":hcegplrs:o:td" option; do
        case $option in
            h)
                display_help
                exit 0
                ;;
            c)
                # Placeholder for copy functionality
                exit 0
                ;;
            e)
                list_env
                exit 0
                ;;
            g)
                gen_zet
                exit 0
                ;;
            p)
                push_zet
                exit 0
                ;;
            l)
                list_zet
                exit 0
                ;;
            r)
                read_file_contents
                exit 0
                ;;
            d)
                delete_zet
                exit 0
                ;;
            s)
                search_zet "$OPTARG"
                exit 0
                ;;
            o)
                open_zet
                exit 0
                ;;
            t)
                read_tags
                exit 0
                ;;
            \?)
                echo "Unknown option: -$OPTARG" >&2
                display_help >&2
                exit 1
                ;;
        esac
    done

    shift $((OPTIND -1))

    # Handle long options manually after getopts processing if needed.
    for arg in "$@"; do
        case $arg in
            --st)
                search_tags
                exit 0
                ;;
            *)
                echo "Unknown option: $arg" >&2
                display_help >&2
                exit 1
                ;;
        esac
    done

}

function push_zet() {
  # Commit to git
  cd $ZETDIR
  git add .
  git commit -m "added new zet"  
  git push origin -u main 
}

function gen_zet() {
  # Generate a new Zettel
  local today=$(date +%Y%m%d)
  local randnum=$(date +%s)
  mkdir -p "$ZETDIR/$today$randnum" && cd "$_" && touch "README.md"
  vim README.md
}

function open_zet() {
  # Open a Zettel
  select zet in $(basename $ZETDIR*); do
    if [ -n "$zet" ]; then
      cd $zet && vim README.md
      break
    fi
  done
}

function delete_zet()  {
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

function list_zet() { 
# List all the Zettel in the /zet directory
  stat -f "%Sm %N" $ZETDIR* | ls -F | grep '/$'
}

function list_repo() {
  # List the environment variables like the Github account and repo to select
  git remote -v | awk '{print $2}' | awk -F'[:/]' '{print $2}' 
    repo_name=$(basename "$repo_url")
    echo "Git Repo: $repo_name"
  env | grep -i 'pwd'
}

function read_tags() {
  TEMP_FILE=$(mktemp)
  # read tags from all files
  find . -type f -name "*.md" | while read -r FILE; do
    grep -o '\#[a-zA-Z0-9_]\+' "$FILE" >> "$TEMP_FILE"
  done

  sort "$TEMP_FILE" | uniq -c | sort -nr > "$TEMP_FILE.sorted"

  echo "Hashtags found:"
  cat "$TEMP_FILE.sorted"

  rm "$TEMP_FILE"
}

function search_tags() {
  echo "Enter the tag you'd like to search for:"
  read TAG
  echo "Directories containing #$TAG:"
  find . -type f -name "*.md" | while read -r FILE; do
    if grep -q "\#$TAG" "$FILE"; then
      direname "$FILE"
    fi
  done | sort | uniq
}

function read_file_contents() {
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

function search_zet() {
  # Search for a Zettel
  search_term=$1
  echo $(grep -ril --color=always  "$search_term" $ZETDIR*)
}

############################################################
############################################################
#                                                          #
# Installed util-linux for some extra features             #
#                                                          #
############################################################
############################################################
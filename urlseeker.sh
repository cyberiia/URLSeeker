#!/bin/bash

# Tool for Web Content Enumeration
# Developed by Cyberia

printf "\x1B[34m\
         _             _           
 _ _ ___| |___ ___ ___| |_ ___ ___ 
| | |  _| |_ -| -_| -_| '_| -_|  _|
|___|_| |_|___|___|___|_,_|___|_|  
   Tool for Web Content Scanning   
        github.com/cyberiia        
\x1B[0m\n"

# Defining functions
help() {
    printf "\x1B[34m[*]\x1B[0m \x1B[1;37mUsage: urlseeker [Options] [<Wordlist_File>] <URL_Base>\x1B[0m\n"
    printf "\x1B[34m[*]\x1B[0m URLSeeker is a Web Content Scanner. It searches for (existing/hidden) subdomains or directories on web servers, inspecting the HTTP response status codes.\n\n"
    printf "  -w\tSpecify your own wordlist\n"
	printf "  -a\tSpecify the user agent\n"
    printf "  -v\tShow also 404 [Not Found] webpages\n"
	printf "  -h\tDisplay this help message\n\n"
	exit
}

info(){
	printf "\x1B[34m[*]\x1B[0m Start time: \x1B[1;37m$(date "+%F %X")\x1B[0m\n" # Start time
	printf "\x1B[34m[*]\x1B[0m Searching for $TYPE on: \x1B[1;37m$URL\x1B[0m\n" # Website info
	printf "\x1B[34m[*]\x1B[0m Wordlist file: \x1B[1;37m$WD\x1B[0m \x1B[34m[$(wc -l < $WD) lines]\x1B[0m\n\n" # Wordlist info
}

results() {
    local URL="$1"
    local STATUS="$2"
    local LOCATION="$3"

    # Searching for the location header if any
	if [ "$LOCATION" ]; then
        printf "\x1B[33m[*] [$STATUS]\x1B[0m \x1B[1;37m$URL\x1B[0m redirects to: \x1B[1;37m$LOCATION\x1B[0m\n"

	# Checking whether the status code matches the $ACCEPTED variable
    elif [[ "$ACCEPTED" == *"$STATUS"* ]]; then
		printf "\x1B[32m[+] [$STATUS]\x1B[0m $URL\n"

	# Show 404 webpages
    elif [ "$VERBOSE" ]; then
        printf "\x1B[31m[-] [$STATUS]\x1B[0m $URL\n"
    fi
}

while getopts ":w:a:vrh" OPT; do
	case "$OPT" in
		w) 
			if [ -f "$OPTARG" ]; then
				WD="$OPTARG"           # Custom wordlist
				sed -i $'s/\r//' "$WD" # Clean carriage returns
			else
				printf "\x1B[31m[-]\x1B[0m Wordlist file doesn't exist. Using the default wordlist.\n"
			fi
		;;
		a) UA="$OPTARG" ;;   # User agent
		v) VERBOSE=true ;;   # Verbose mode
		h) help ;;
		:) [ "$OPTARG" == "w" ] && printf "\x1B[31m[-]\x1B[0m Custom wordlist not specified.\n" || printf "\x1B[31m[-]\x1B[0m User agent not specified.\n" ;;
	   \?) printf "\x1B[31m[-]\x1B[0m Invalid option: '$OPTARG'\n" && help ;;
	esac
done

# Defining variables
ACCEPTED="200 301 302 401 403" # HTTP status codes
shift $((OPTIND -1))
URL="$1"

# Input validation
if [ -z "$URL" ]; then
    printf "\x1B[31m[-]\x1B[0m URL cannot be empty.\n" && help

elif [[ ! "$URL" =~ ^(http|https):// ]]; then # Setting HTTP as default protocol if none is specified
	URL="http://$URL"
fi

# Separating the protocol from the URL
PROTOCOL="${URL%%:*}"
DOMAIN="${URL#*://}"
URLCLEAN="${DOMAIN//urlseeker/}"

case "$DOMAIN" in
	urlseeker.*)
		[ -z "$WD" ] && WD="wordlists/subdomains.txt"  # Default subdomains wordlist
		TYPE="subdomains"
	;;
	*urlseeker*)
		[ -z "$WD" ] && WD="wordlists/directories.txt" # Default directories wordlist
    	TYPE="directories"
	;;
	*) printf "\x1B[31m[-]\x1B[0m The keyword 'urlseeker' must be positioned in the URL.\n" && help ;;
esac

# Adding options to the curl command
ARGS=(-Iso /dev/null -w '%{http_code} %{redirect_url}')
[ "$UA" ] && ARGS+=(-A "$UA") # Add user agent if any
info

# Searching for subdomains/directories
while IFS= read -r word; do

	if [ "$TYPE" == "subdomains" ]; then
		URL="$PROTOCOL://$word$URLCLEAN" # Reassembling the URL to search for subdomains

	elif [ "$TYPE" == "directories" ]; then
		URL="$PROTOCOL://$URLCLEAN$word" # Reassembling the URL to search for directories
	fi

	# Setting up the curl request with the necessary arguments
	OUTPUT=$(curl "${ARGS[@]}" "$URL")
	read -r STATUS LOCATION <<< "$OUTPUT"
	results "$URL" "$STATUS" "$LOCATION"

done < "$WD"
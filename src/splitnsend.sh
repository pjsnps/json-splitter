#!/bin/bash

#Usage: ./upload_json.sh <BD URL> <API TOKEN> <JSON FILE>
# 2009291405Z pjalajas@synopsys.com  YWE2MTZmOGQtZGM4MC00NTYyLWJhZTYtM2ExNzYwMjM2MmM0OmNhZjQyNTI1LTJmMGYtNDdkNy1hODY4LTI0MjhkOTNlMWY1Ng== sup-pjalajas-2.dc1.lan    add a couple of cats to quiet curl.

BD_HUB_URL=$1
BD_HUB_TOKEN=$2
JSON_PATH=$3

echo "Split n Send dry-run splitter"

#Authentication
echo "Authenticating with Black Duck"
curl --header "Content-Type:application/json" --insecure -X POST --header "Authorization: token $BD_HUB_TOKEN" -i "https://$BD_HUB_URL/api/tokens/authenticate" -o token | cat
wait
access_token=$(cat token | grep bearerToken | awk -F ',' '{print $1}' | awk -F ':' '{print $2}' | tr -d '"')
rm token
#Set path and json to scan
path=$(pwd)
orig="$path/$JSON_PATH"  # need to copy huge json to current dir
#Split the scan
echo "Splitting the original dry-run"
python3 split_scan_graph_json.py $orig > /dev/null
wait
echo "Done splitting"
#Read and upload - do not delete original
echo "Reading through generated files"

#slow it way down for huge scans...
#ORIGINAL:  for file in "$path"/*.json; do [ "$file" == "$orig" ] && (echo "Archiving original Dry-Run: $file" && mv $JSON_PATH Archive/$JSON_PATH) || (echo "Uploading $file to Black Duck" && curl --header "Content-Type:application/vnd.blackducksoftware.bdio+json" --insecure  -X POST --header "Authorization: Bearer $access_token" -i "https://$BD_HUB_URL/api/scan/data/" -d @$file > /dev/null && rm $file); done
for file in "$path"/*.json; 
  do [ "$file" == "$orig" ] \
    && (echo "Archiving original Dry-Run: $file" && mv $JSON_PATH Archive/$JSON_PATH) \
    || (echo "Uploading $file to Black Duck" \
      && curl --header "Content-Type:application/vnd.blackducksoftware.bdio+json" --insecure  -X POST --header "Authorization: Bearer $access_token" -i "https://$BD_HUB_URL/api/scan/data/" -d @$file | cat > /dev/null \
      && rm $file) 
    wait # pj
  done

wait
echo "Process complete"

#!/usr/bin/env bash

# uncomment to debug
# set -x
set -e
set -o pipefail

if [ -f '.env' ]; then source '.env'; fi

grab_page() {
  # https://superuser.com/questions/590099/can-i-make-curl-fail-with-an-exitcode-different-than-0-if-the-http-status-code-i
  # $1 -- url
  # $2 -- file to save to
  STATUSCODE=$(curl --silent --output $2 --write-out "%{http_code}"  -H "Cookie: autologin=${autologin};" $1)
  if test $STATUSCODE -ne 200; then
    echo "curl failed"
    exit 1
  fi
}

mkdir -p data

cat migrate.jq_ > data/migrate.jq

grab_page https://i.doit.im/api/resources_init data/resources.json
# generate
# +(if .context == "e1c2b3f0-4081-11e4-8894-51e3df408535" then "&tags=Computer" else "" end)
jq '.resources.contexts[]|.uuid+.name' data/resources.json | sed -E 's/.(.{36})(.*)./+(if .context == "\1"  then "\&tags=\2" else "" end)/g' >> data/migrate.jq
# generate
# +(if .project == "f013151f-7c19-4e30-8d96-48ca600566cb" then "&forParentName=benefits" else "" end)
jq '.resources.projects[]|.uuid+.name' data/resources.json | sed -E 's/.(.{36})(.*)./+(if .project == "\1"  then "\&forParentName=\2" else "" end)/g' >> data/migrate.jq

echo "MANUALLY CREATE THESE PROJECTS (without quotes)"
jq '.resources.projects[]|.name' data/resources.json
echo "Press any key when done"
read -n 1 -s -r -p "Press any key to continue"


touch data/move.txt
rm data/move.txt

echo
echo "Downloading data..."

for section in today tomorrow next scheduled waiting inbox someday
do
  echo ${section}
  grab_page "https://i.doit.im/api/tasks/${section}" data/${section}.json
  # This can be added to slow down digestion
  #| sed -e "s/$/ \&\& sleep 1 /g"
  jq -f ./data/migrate.jq --argjson today `date '+%s'`000 data/${section}.json | sed -e "s/^/open /g"  >> data/move.txt
done

echo "Importing...."
. data/move.txt
echo "All done. Wait the 2Do app to swallow the data"

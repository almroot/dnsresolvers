#!/bin/bash

# scrape public dns resolvers
rm -f resolvers-temp.txt
wget -O resolvers-temp.txt http://public-dns.info/nameservers.txt

# fail on error
if [[ $? -ne 0 ]]; then
  echo "wget failed..."
  exit 1
fi

# declare known false positives
FALSE_POSITIVES=(
	"^198.105..+\.11$"
)
FALSE_POSITIVES_DOMAINS=(
	"vpncloud.example.com"
)

# append old resolvers to the same test bed
cat resolvers.txt>>resolvers-temp.txt

# remove duplicates
cat resolvers-temp.txt | sort | uniq > resolvers-swap.txt
mv resolvers-swap.txt resolvers-temp.txt
rm -f resolvers.swap.txt

# sanity check
REAL=`dig +short example.com @8.8.8.8`

# iterate over all servers in the file
while read SERVER; do
  RESULT=`dig +time=1 +tries=1 +short example.com @$SERVER`
  if [[ $REAL == $RESULT ]]
  then

    # sanity check the resolver against the blacklist of known bad ones
    for fp in "${FALSE_POSITIVES[@]}"; do
      MATCH=`echo $SERVER | grep -P "${fp}"`
      if [[ $MATCH != "" ]]; then
        echo "Aborting $SERVER: Blacklisted address ${fp}"
        break
      fi
    done
    if [[ $MATCH != "" ]]; then
      continue
    fi

    # sanity check that the resolver doesnt return invalid data
    for fp in "${FALSE_POSITIVES_DOMAINS[@]}"; do
      MATCH=`dig +time=1 +tries=1 +short ${fp} @$SERVER`
      if [[ $MATCH != "" ]]; then
        echo "Aborting $SERVER: Resolved invalid against ${fp}"
        break
      fi
    done
    if [[ $MATCH != "" ]]; then
      continue
    fi

    # if the resolver is legit, then print it out
    echo $SERVER >> resolvers-swap.txt
    echo "Discovered $SERVER"
  fi
done <resolvers-temp.txt

# overwrite the old resolvers with the new sanity checked ones
cat resolvers-swap.txt>resolvers.txt

# clean up
rm resolvers-swap.txt

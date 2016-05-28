#!/bin/bash

url="https://www.reddit.com/r/$1/comments.json"

time=$(date +%s)
rawInputFile="/tmp/$time-comments.json"
filteredInputFile="/tmp/$time-filtered-comments.json"
wget -q -O $rawInputFile $url

source last-check.sh

jq "[.data.children[].data | select(.created_utc>$lastCheck)]" $rawInputFile > $filteredInputFile

echo "lastCheck=$time" > last-check.sh

length=$(jq '. | length' $filteredInputFile)

	echo $filteredInputFile
for x in $(seq 0 $(($length - 1))); do
	noP=$(jq ".[$x].body" $filteredInputFile | ./count-paren.sh)
	emoticonResp=$(jq ".[$x].body" $filteredInputFile | grep -o '\\\?:\?(\\\?' | sed 's/[()]//g' | tr -d '\n')
	echo "$noP"
	if [ $noP -gt 0 ]; then
		./post-comment.sh \
			"$(jq -r ".[$x].name" $filteredInputFile)" \
"$emoticonResp$(printf ')%.0s' $(seq 1 $noP))

---
This is an autogenerated response. [source](https://github.com/hugonikanor/reddit-parenthesis-bot) | /u/HugoNikanor" \
		&& echo "posted" \
		|| echo "failed"
	fi
done

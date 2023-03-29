test-example-graphql:
	curl --request POST \
    --header 'content-type: application/json' \
    --url http://localhost:9001 \
    --data '{"query":"query Query {\n  greet(name: \"Sami\")\n}","variables":{}}' \
	-s \
	| jq .data.greet
psql -d DB_NAME -c "SELECT json_agg(row_to_json(t)) ::text  FROM (SELECT id, \"createdAt\", \"userId\", \"userHost\", \"channelId\",cw,text FROM note LIMIT 10000) t" > notes_tmp

sed -i '1d;2d;x;$d;' notes_tmp

jq 'map(.createdAt |= (strptime("%Y-%m-%dT%H:%M:%S%Z") | mktime | . * 1000 + (. / 1000000 | floor)))' notes_tmp > notes.json

curl -X POST 'http://localhost:7700/indexes/notes/documents' --data @notes.json -H 'Content-Type: application/json' -H "Authorization: Bearer APIKEY"

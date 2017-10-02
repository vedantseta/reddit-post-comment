config=$(echo `cat config.json`);
username=$(echo $config | json user.name);
password=$(echo $config | json user.password);
secretToken=$(echo $config | json user.secret_key);

globalComment=$(echo $config | json reddit.global.comment);
globalTitle=$(echo $config | json reddit.global.title);
globalLink=$(echo $config | json reddit.global.link);
subReddits=$(echo $config | json reddit.sub_reddits);

data="grant_type=password&username=$username&password=$password";
access_token_response=$(curl -X POST -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36" -d $data --user $secretToken https://www.reddit.com/api/v1/access_token);
access_token=$(echo $access_token_response | json access_token);
echo $access_token;


echo $subReddits | 
json -gMa name comment title |
awk -v globalLink=$globalLink '{print "api_type=json&extension=json&sendreplies=true&resubmit=true&kind=link&sr="$1"&title="$2"&url="globalLink""}' |
awk '{print $0 }' |
curl https://oauth.reddit.com/api/submit -H "Authorization: bearer $access_token" -A "BlogBot/0.1 by Vedant" -d `awk '{print $0}'` |
awk '{print $0}' | 
json json.data.name | 
awk -v globalComment=$globalComment '{print "parent="$0"&text="globalComment""}'| 
curl https://oauth.reddit.com/api/comment -H "Authorization: bearer $access_token" -A "BlogBot/0.1 by Vedant" -d `awk '{print $0}'` |
awk '{print $0}';


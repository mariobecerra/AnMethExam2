import requests
import json

t_url = 'https://stream.twitter.com/1.1/statuses/sample.json'
t_headers = {'Authorization': 'OAuth oauth_consumer_key="GPI5CNx6tabl6J1M24lQJmCkU", oauth_nonce="1eab2a78603f25f98c2747f65982326b", oauth_signature="BxP8pTCLV4QIGNV652LGPgTHSpI%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1429915961", oauth_token="86753315-rldhPYu5C17xEzoVMADKNyefqgw1teg0VduH14TVi", oauth_version="1.0"'}


def pp(o):
    """
    A helper function to pretty-print Python objects as JSON
    """
    print json.dumps(o, indent=1)


req = requests.get(t_url, headers=t_headers, stream=True)	

#Prints User ID and Tweet
i=0
for line in req.iter_lines():
    # filter out keep-alive new lines
    i=i+1
    if line:
    	if 'text' in json.loads(line):
    		print 'Tweet Number: ' + str(i)
 	    	print 'User: ' + json.loads(line)['user']['screen_name']
 	    	print 'Tweet: ' + json.loads(line)['text']
 	    	print ''
  	
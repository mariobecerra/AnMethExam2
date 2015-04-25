import requests
import json

t_url = 'https://stream.twitter.com/1.1/statuses/sample.json'
t_headers = {'Authorization': 'OAuth oauth_consumer_key="GPI5CNx6tabl6J1M24lQJmCkU", oauth_nonce="989a7b9ff302b49dda62cdcfc0a0e383", oauth_signature="FblJ%2BwSsaTcoJ2pLyi6dGZxIun0%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1429921828", oauth_token="86753315-rldhPYu5C17xEzoVMADKNyefqgw1teg0VduH14TVi", oauth_version="1.0"'}


def pp(o):
    """
    A helper function to pretty-print Python objects as JSON
    """
    print json.dumps(o, indent=1)


req = requests.get(t_url, headers=t_headers, stream=True)	

# i=0
# for line in req.iter_lines():
#     #i=i+1
#     try:
#         d = json.loads(line)
#     # filter out keep-alive new lines
#         if 'place' in d and d['place'] != None:
#             if d['place']['country'] == 'Mexico':
#                 i=i+1
#                 print pp(json.loads(line))
#                 print 'i='+str(i)
#                 print '\n \n \n \n'
#     except Exception, e:
#         print str(e)+'\n\n'
                

# i=0
# for line in req.iter_lines():
#     i=i+1
#     d = json.loads(line)
#     # filter out keep-alive new lines
#     if 'place' in d:
#         s = d['place']
#         if s['country']=='Mexico':
#             print pp(json.loads(line))
#             print 'i='+str(i)
#             print '\n \n \n \n'

i=0
for line in req.iter_lines():
    # filter out keep-alive new lines
    if line:
        i=i+1
        print pp(json.loads(line))
      	
# Python Standard Library imports
import argparse
import datetime
import json
import sys
import time

# Third-party library imports
from dotenv import dotenv_values
import pandas as pd
import requests

parser = argparse.ArgumentParser('Retrieve breach data from HIBP via API')
parser.add_argument('-b',
                    '--breach-name',
                    type=str,
                    required=False,
                    help='Get data for specific breach name')
parser.add_argument('-v',
                    '--verbose',
                    action="store_true",
                    default=False,
                    required=False,
                    help='Verbose mode')
parser.add_argument('-w',
                    '--write-data',
                    action="store_true",
                    default=False,
                    required=False,
                    help='Write data from Team Dynamix user lookup to a file')
args = parser.parse_args()

hibp_api_header = {'hibp-api-key':'','User-Agent':'HIBP lookup tool (your_email_goes_here)'}
hibp_base_api_url = 'https://haveibeenpwned.com/api/v3'

def get_environment():
    try:
        config = dotenv_values('.env')
    except Exception as e:
        log_action(f'Error loading config file: {e}')
        log_action('Exiting')
        sys.exit(1)
    else:
        hibp_api_header['hibp-api-key'] = config['HIBP_API_KEY']
    return config

def log_action(message):
    print(f'[*] {datetime.datetime.utcnow()} {message}')

def hibp_get_latest_breach():
    hibp_service = 'latestbreach'
    url = '/'.join([hibp_base_api_url,hibp_service])
    response = requests.get(url,headers=hibp_api_header)
    return response.json()

def hibp_get_named_breach(breach_name):
    hibp_service = 'breach'
    url = '/'.join([hibp_base_api_url,hibp_service,breach_name])
    response = requests.get(url,headers=hibp_api_header)
    return response.json()

def hibp_get_breach_data(breach_name):   
    hibp_service = 'breacheddomain'
    url = '/'.join([hibp_base_api_url,hibp_service,breach_name])
    response = requests.get(url,headers=hibp_api_header)
    return response.json()

def hibp_evaluate_breach_data(domain,breach_name,emails):    
    breached_emails = []
    for alias in emails.keys():
        if breach_name in emails[alias]:
            breached_emails.append(''.join([alias,'@',domain]))
            log_action(f'Email address {alias}@{domain} found')
    if len(breached_emails) == 0:
        log_action(f'No emails from {domain} found in {breach_name} data')
    return breached_emails

def get_tdx_api_token(config):
    http_headers = {'Content-Type': 'application/json; charset=utf-8'}
    auth_data = {'username':'infosec-api', 'password':''}
    auth_data['password'] = config['TDX_API_USER_PW']
    try:
        #auth_data['password'] = getpass.getpass('Please enter the password for the TDX API user: ')
        response = requests.post('https://' + 'your_tenant_name' + '.teamdynamix.com/TDWebApi/api/auth/login', headers=http_headers, json=auth_data)
        if response.status_code != 200:
            raise Exception(f'HTTP response {response.status_code} when trying to acquire TDX API token')
        token = response.text
    except Exception as e:
        log_action(f'Error: {e}')
        sys.exit('Exiting due to failure to get API token.')
    return token

def get_tdx_user_info(token, user_list):
    df_lookup_results = pd.DataFrame(columns=['Full Name','Username','ID','Email','Alt Email','Campus','Title','Role','Status'])
    log_action('Retrieving user information from TDX')
    base_url = 'https://' + 'your_tenant_name' + '.teamdynamix.com/TDWebApi/'
    auth_token = ''.join(['Bearer ', token])
    request_header = {'Authorization': auth_token, 'Content-Type': 'application/json; charset=utf-8'}
    for current_user in user_list:
        search_uri = f'api/people/lookup?searchText={current_user}&maxResults=50'
        response = requests.get(f'{base_url}{search_uri}', headers=request_header)
        log_action(f'{len(response.json())} result(s) found for search of {current_user}')
        if (len(response.json()) > 0):
            for search_result in response.json():
                returned_email = search_result['PrimaryEmail'].lower()
                if current_user == returned_email:
                    current_uid = search_result['UID']
                    people_uri = f'api/people/{current_uid}'
                    response = requests.get(f'{base_url}{people_uri}', headers=request_header)
                    if args.verbose:
                        display_summary(response.json())
                    this_account = [response.json()['FullName'],response.json()['AuthenticationUserName'],response.json()['ExternalID'],response.json()['PrimaryEmail'],response.json()['AlternateEmail'],response.json()['Company'],response.json()['Title'],response.json()['Attributes'][0]['ValueText'],response.json()['Attributes'][1]['ValueText']]
                    df_current_account = pd.DataFrame([this_account], columns=['Full Name','Username','ID','Email','Alt Email','Campus','Title','Role','Status'])
                    df_lookup_results = pd.concat([df_lookup_results,df_current_account], axis=0, ignore_index=True)
                    break
        else:
            log_action(f'No matches found for {current_user}')
        if len(user_list) > 1:
            time.sleep(2.0)
    return df_lookup_results

def write_data_to_file(user_name, user_json):
    with open(f'{user_name}.json','w') as out:
        json.dump(user_json,out)
    log_action(f'Info saved to file {user_name}.json.')

def display_summary(user_json):
    green = '\033[92m'
    reset = '\033[0m'
    print(f'{green}', end='')
    print(f"[***] Full Name: {user_json['FullName']}")
    print(f"[***] Username: {user_json['AuthenticationUserName']}")
    print(f"[***] ID: {user_json['ExternalID']}")
    print(f"[***] Email: {user_json['PrimaryEmail']}")
    print(f"[***] Alternate Email: {user_json['AlternateEmail']}")
    print(f"[***] Campus: {user_json['Company']}")
    print(f"[***] Title: {user_json['Title']}")
    print(f"[***] Role: {user_json['Attributes'][0]['ValueText']}")
    print(f"[***] Identity Status: {user_json['Attributes'][1]['ValueText']}")
    print(f'{reset}', end='')

# Startup
start_time = time.time()
log_action('Script started')
config = get_environment()
if args.breach_name:
    log_action(f"Searching for breach data related to {args.breach_name}")
    breach = hibp_get_named_breach(args.breach_name)
else:
    log_action(f"Retrieving data for latest breach")
    breach = hibp_get_latest_breach()    
breach_name = breach['Name']
breach_domain = breach['Domain']
breach_added_date = breach['AddedDate']
log_action(f"Found breach {breach_name} affecting domain {breach_domain} added on {breach_added_date}")
pwned_emails = []
for domain in ['your_domain','your_other_domain']:
    log_action(f"Searching for {domain} email addresses in {breach_name} breach data")
    all_emails = hibp_get_breach_data(domain)
    found = hibp_evaluate_breach_data(domain,breach_name,all_emails)
    pwned_emails += found
# Get token and perform lookup(s)
tdx_token = get_tdx_api_token(config)
df_results = get_tdx_user_info(tdx_token,pwned_emails)
if args.write_data:
    df_results.to_csv(f'HIBP_{breach_name}_results.csv', index=False)
log_action(f'Script complete in {time.time() - start_time:.2f} seconds')

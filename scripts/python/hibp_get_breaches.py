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

parser = argparse.ArgumentParser('Retrieve breach info from HIBP via API')
parser.add_argument('-n',
                    '--number',
                    type=str,
                    required=False,
                    help='Number of recent breaches to return')
parser.add_argument('-v',
                    '--verbose',
                    action="store_true",
                    default=False,
                    required=False,
                    help='Verbose mode')
args = parser.parse_args()

hibp_api_header = {'hibp-api-key':'','User-Agent':'ERAU HIBP lookup tool (infosec@erau.edu)'}
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

def hibp_get_all_breaches():   
    hibp_service = 'breaches'
    url = '/'.join([hibp_base_api_url,hibp_service])
    response = requests.get(url,headers=hibp_api_header)
    return response.json()

def sort_breaches(breaches_json):
    sorted_breaches_dict = sorted(breaches_json, key=lambda x: x['AddedDate'])
    return sorted_breaches_dict

def display_summary(breach_json):
    green = '\033[92m'
    reset = '\033[0m'
    print(f'{green}', end='')    
    print(f"[*] Breach Name: {breach_json['Name']}\tDomain: {breach_json['Domain']}\tDate Added: {breach_json['AddedDate']}\tBreach Date: {breach_json['BreachDate']}")
    if (args.verbose):
        print(f"[*] Records: {breach_json['PwnCount']}")
        print(f"[***] Description: {breach_json['Description']}")
    print(f'{reset}', end='')
    
# Startup
start_time = time.time()
log_action('Script started')
config = get_environment()
if args.number:
    log_action(f"Searching for most recent {args.number} breaches from HIBP")
else:
    log_action(f"Retrieving all breaches from HIBP")
breaches_json = hibp_get_all_breaches()
sorted_dict = sort_breaches(breaches_json)
for breach in sorted_dict:
    display_summary(breach)
log_action(f'Script complete in {time.time() - start_time:.2f} seconds')
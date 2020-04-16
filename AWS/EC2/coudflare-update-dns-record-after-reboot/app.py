import os
import json
import logging
import requests
import CloudFlare
from dotenv import load_dotenv

def get_ec2_ip():
    return requests.get("http://169.254.169.254/latest/meta-data/public-ipv4").content


class Cloudflare():
    def __init__(self, cf_token, zone_id, dns_records):
        self.cf = CloudFlare.CloudFlare(token=cf_token)
        self.zone_id = zone_id
        self.dns_records = dns_records
        logging.basicConfig(filename="update_dns.log", level=logging.INFO)
    
    def get_records(self):
        response = self.cf.zones.dns_records.get(self.zone_id)
        return([x['id'] for x in response])

    def create_records(self):
        for record in self.dns_records:
            response = self.cf.zones.dns_records.post(self.zone_id, data=record)
            logging.info(response)

    def delete_records(self):
        records = self.get_records()
        for record_id in records:
            response = self.cf.zones.dns_records.delete(self.zone_id, record_id)
            logging.info(response)

def main():
    load_dotenv()
    if os.path.exists("update_dns.log"):
        os.remove("update_dns.log")

    dns_records = [
        {'name': '@', 'type': 'A', 'content': get_ec2_ip(), 'proxied': True}
    ]
    
    try:
        flare = Cloudflare(os.getenv("CF_TOKEN"),os.getenv("ZONE_ID"), dns_records)
        flare.delete_records()
        flare.create_records()
    except Exception as e:
        logging.info(e)

if __name__ == "__main__":
    main()

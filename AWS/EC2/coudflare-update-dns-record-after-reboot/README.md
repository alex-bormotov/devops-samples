# The script update A record in CloudFlare when EC2 instance was rebooted

> clone it

```bash
sudo apt install python-pip
```

```bash
pip install -r requirements.txt
```

> create .env file and put there Cloudflare zone id and api token

```bash
echo 'CF_TOKEN="your zone id"' >> .env
```

```bash
echo 'ZONE_ID="your api token"' >> .env
```

```bash
crontab -e
```

> add to the end of file

```bash
@reboot /usr/bin/python3 /home/ubuntu/coudflare-update-dns-record-after-reboot/app.py
```

> check it

```bash
crontab -l
```

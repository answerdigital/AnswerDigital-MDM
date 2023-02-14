from playwright.sync_api import Page
import requests
import json
import os
import boto3

ec2_client = boto3.client('ec2')
instance_name = 'mdm-app'

response = ec2_client.describe_instances(
    Filters=[
        {
            'Name': 'tag:Name',
            'Values': [instance_name]
        }
    ]
)

public_ip = response['Reservations'][0]['Instances'][0]['PublicIpAddress']
url = os.getenv('MDM_INSTANCE_BASE_URL', public_ip)


def test_login(page: Page):
    page.goto(url)
    page.locator("#mdm--navbar-desktop").get_by_role("button", name="Log in").click()
    page.get_by_label("Email *").click()
    page.get_by_placeholder("Enter your email").fill("admin@maurodatamapper.com")
    page.get_by_label("Password *").click()
    page.get_by_placeholder("Enter your password").fill("password")
    page.get_by_role("button", name="Log in").click()


def test_check_configuration(snapshot):
    s = requests.Session()
    endpoint = f"{url}api/authentication/login"
    payload = json.dumps({
        "username": "admin@maurodatamapper.com",
        "password": "password"
    })
    headers = {
        'Content-Type': 'application/json'
    }
    s.request("POST", endpoint, headers=headers, data=payload)
    endpoint = f"{url}api/admin/modules"
    response = s.request("GET", endpoint, headers=headers, data={})
    snapshot.assert_match(json.loads(response.text), 'plugin_response')
    endpoint = f"{url}api/admin/properties"
    response = s.request("GET", endpoint, headers=headers, data={})
    snapshot.assert_match(load_json_remove_id(response.text), 'properties_response')


def load_json_remove_id(json_string):
    obj = json.loads(json_string)
    remove_id(obj)
    return obj


def remove_id(obj):
    if isinstance(obj, dict):
        for key in list(obj.keys()):
            if key == 'id':
                obj.pop(key)
            else:
                remove_id(obj[key])
    elif isinstance(obj, list):
        for item in obj:
            remove_id(item)

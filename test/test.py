# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
from playwright.sync_api import Page, expect
import requests
import json


def test_login(page: Page):
    page.goto("http://localhost:8082/")
    page.locator("#mdm--navbar-desktop").get_by_role("button", name="Log in").click()
    page.get_by_placeholder("Enter your email").click()
    page.get_by_placeholder("Enter your email").fill("admin@maurodatamapper.com")
    page.get_by_placeholder("Enter your password").click()
    page.get_by_placeholder("Enter your password").fill("password")
    page.get_by_role("button", name="Log in").click()


def test_check_configuration(snapshot):
    s = requests.Session()
    url = "http://localhost:8082/api/authentication/login"
    payload = json.dumps({
        "username": "admin@maurodatamapper.com",
        "password": "password"
    })
    headers = {
        'Content-Type': 'application/json'
    }
    s.request("POST", url, headers=headers, data=payload)
    url = "http://localhost:8082/api/admin/modules"
    payload = {}
    response = s.request("GET", url, headers=headers, data=payload)
    snapshot.assert_match(response.text, 'plugin_response')
    url = "http://localhost:8082/api/admin/properties"
    response = s.request("GET", url, headers=headers, data=payload)
    snapshot.assert_match(response.text, 'properties_response')

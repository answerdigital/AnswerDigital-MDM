# Installation Script

Simple Framework to validate a basic installation of an MDM application

`pip install -r requirements.txt`

You will need the required playwright binaries in order to run the login script.

`playwright install`

Then to execute the tests

`pytest test.py`

And to run the test with a visible browser

`pytest --headed test.py`

These tests also use a snapshotting tool, to update the snapshot delete the existing one or use the inbuild --snapshot-update
command to force the test to update the snapshot with whatever is returned from the MDM service.
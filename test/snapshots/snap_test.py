# -*- coding: utf-8 -*-
# snapshottest: v1 - https://goo.gl/zC4yUc
from __future__ import unicode_literals

from snapshottest import Snapshot


snapshots = Snapshot()

snapshots['test_check_configuration plugin_response'] = '[{"name":"mdm.common","version":"5.2.0"},{"name":"mdm.core","version":"5.2.0"},{"name":"mdm.pluginAuthenticationApiKey","version":"5.2.0"},{"name":"mdm.pluginAuthenticationBasic","version":"5.2.0"},{"name":"mdm.pluginDataflow","version":"5.2.0"},{"name":"mdm.pluginDatamodel","version":"5.2.0"},{"name":"mdm.pluginFederation","version":"5.2.0"},{"name":"mdm.pluginProfile","version":"5.2.0"},{"name":"mdm.pluginReferencedata","version":"5.2.0"},{"name":"mdm.pluginTerminology","version":"5.2.0"},{"name":"mdm.security","version":"5.2.0"},{"name":"grails.assetPipeline","version":"3.4.6"},{"name":"grails.cache","version":"4.0.3"},{"name":"grails.codecs","version":"5.1.9"},{"name":"grails.controllers","version":"5.1.9"},{"name":"grails.controllersAsync","version":"SNAPSHOT"},{"name":"grails.converters","version":"5.1.9"},{"name":"grails.core","version":"5.1.9"},{"name":"grails.dataSource","version":"5.1.9"},{"name":"grails.domainClass","version":"5.1.9"},{"name":"grails.eventBus","version":"SNAPSHOT"},{"name":"grails.groovyPages","version":"5.1.0"},{"name":"grails.hibernate","version":"7.2.2"},{"name":"grails.hibernateSearch","version":"3.0.0-SNAPSHOT"},{"name":"grails.i18n","version":"5.1.9"},{"name":"grails.interceptors","version":"5.1.9"},{"name":"grails.jsonView","version":"unspecified"},{"name":"grails.markupView","version":"unspecified"},{"name":"grails.mimeTypes","version":"5.1.9"},{"name":"grails.restResponder","version":"5.1.9"},{"name":"grails.services","version":"5.1.9"},{"name":"grails.urlMappings","version":"5.1.9"},{"name":"java.base","version":"17.0.3"},{"name":"java.compiler","version":"17.0.3"},{"name":"java.datatransfer","version":"17.0.3"},{"name":"java.desktop","version":"17.0.3"},{"name":"java.instrument","version":"17.0.3"},{"name":"java.logging","version":"17.0.3"},{"name":"java.management","version":"17.0.3"},{"name":"java.management.rmi","version":"17.0.3"},{"name":"java.naming","version":"17.0.3"},{"name":"java.net.http","version":"17.0.3"},{"name":"java.prefs","version":"17.0.3"},{"name":"java.rmi","version":"17.0.3"},{"name":"java.scripting","version":"17.0.3"},{"name":"java.security.jgss","version":"17.0.3"},{"name":"java.security.sasl","version":"17.0.3"},{"name":"java.smartcardio","version":"17.0.3"},{"name":"java.sql","version":"17.0.3"},{"name":"java.sql.rowset","version":"17.0.3"},{"name":"java.transaction.xa","version":"17.0.3"},{"name":"java.xml","version":"17.0.3"},{"name":"java.xml.crypto","version":"17.0.3"},{"name":"jdk.accessibility","version":"17.0.3"},{"name":"jdk.charsets","version":"17.0.3"},{"name":"jdk.crypto.cryptoki","version":"17.0.3"},{"name":"jdk.crypto.ec","version":"17.0.3"},{"name":"jdk.dynalink","version":"17.0.3"},{"name":"jdk.httpserver","version":"17.0.3"},{"name":"jdk.jfr","version":"17.0.3"},{"name":"jdk.jsobject","version":"17.0.3"},{"name":"jdk.localedata","version":"17.0.3"},{"name":"jdk.management","version":"17.0.3"},{"name":"jdk.management.jfr","version":"17.0.3"},{"name":"jdk.naming.dns","version":"17.0.3"},{"name":"jdk.naming.rmi","version":"17.0.3"},{"name":"jdk.net","version":"17.0.3"},{"name":"jdk.nio.mapmode","version":"17.0.3"},{"name":"jdk.sctp","version":"17.0.3"},{"name":"jdk.security.auth","version":"17.0.3"},{"name":"jdk.security.jgss","version":"17.0.3"},{"name":"jdk.unsupported","version":"17.0.3"},{"name":"jdk.xml.dom","version":"17.0.3"},{"name":"jdk.zipfs","version":"17.0.3"}]'

snapshots['test_check_configuration properties_response'] = {
    'count': 19,
    'items': [
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.invite_edit.body',
            'lastUpdated': '2021-10-04T13:23:12.029Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': '''Dear ${firstName},
You have been invited to edit the model '${itemLabel}' in the Mauro Data Mapper at ${catalogueUrl}

Your username / email address is: ${emailAddress}
Your password is: ${tempPassword}
 and you will be asked to update this when you first log on.
Kind regards, the Mauro Data Mapper folks.

(This is an automated mail).'''
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.admin_register.body',
            'lastUpdated': '2021-10-04T13:23:12.075Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': '''Dear ${firstName},
You have been given access to the Mauro Data Mapper at ${catalogueUrl} 

Your username / email address is: ${emailAddress} 
Your password is: ${tempPassword} 
and you will be asked to update this when you first log on.

Kind regards, the Mauro Data Mapper folks. 

(This is an automated mail).'''
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.admin_register.subject',
            'lastUpdated': '2021-10-04T13:23:12.076Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': 'Mauro Data Mapper Registration'
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.self_register.subject',
            'lastUpdated': '2021-10-04T13:23:12.076Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': 'Mauro Data Mapper Registration'
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.forgotten_password.subject',
            'lastUpdated': '2021-10-04T13:23:12.077Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': 'Mauro Data Mapper Forgotten Password'
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.invite_edit.subject',
            'lastUpdated': '2021-10-04T13:23:12.078Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': 'Mauro Data Mapper Invitation'
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.invite_view.subject',
            'lastUpdated': '2021-10-04T13:23:12.08Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': 'Mauro Data Mapper Invitation'
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.from.name',
            'lastUpdated': '2021-10-04T13:23:12.084Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': 'Mauro Data Mapper'
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.admin_confirm_registration.body',
            'lastUpdated': '2021-10-04T13:23:12.081Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': '''Dear ${firstName},
Your registration for the Mauro Data Mapper at ${catalogueUrl} has been confirmed.

Your username / email address is: ${emailAddress} 
You chose a password on registration, but can reset it from the login page.

Kind regards, the Mauro Data Mapper folks.

(This is an automated mail).'''
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.self_register.body',
            'lastUpdated': '2021-10-04T13:23:12.083Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': '''Dear ${firstName},
You have self-registered for the Mauro Data Mapper at ${catalogueUrl}

Your username / email address is: ${emailAddress}
Your registration is marked as pending: you'll be sent another email when your request has been confirmed by an administrator. 
Kind regards, the Mauro Data Mapper folks.

(This is an automated mail).'''
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.password_reset.body',
            'lastUpdated': '2021-10-04T13:23:12.083Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': '''Dear ${firstName},
Your password has been reset for the Mauro Data Mapper at ${catalogueUrl}.

Your new temporary password is: ${tempPassword} 
and you will be asked to update this when you next log on.

Kind regards, the Mauro Data Mapper folks.

(This is an automated mail).'''
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.admin_confirm_registration.subject',
            'lastUpdated': '2021-10-04T13:23:12.085Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': 'Mauro Data Mapper Registration - Confirmation'
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.forgotten_password.body',
            'lastUpdated': '2021-10-04T13:23:12.085Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': '''Dear ${firstName},
A request has been made to reset the password for the Mauro Data Mapper at ${catalogueUrl}.
If you did not make this request please ignore this email.

Please use the following link to reset your password ${passwordResetLink}.
Kind regards, the Mauro Data Mapper folks.

(This is an automated mail).'''
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.password_reset.subject',
            'lastUpdated': '2021-10-04T13:23:12.086Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': 'Mauro Data Mapper Password Reset'
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.invite_view.body',
            'lastUpdated': '2021-10-04T13:23:12.086Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': '''Dear ${firstName},
You have been invited to view the item '${itemLabel}' in the Mauro Data Mapper at ${catalogueUrl}

Your username / email address is: ${emailAddress}
Your password is: ${tempPassword}
 and you will be asked to update this when you first log on.
Kind regards, the Mauro Data Mapper folks.

(This is an automated mail).'''
        },
        {
            'category': 'Email',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'email.from.address',
            'lastUpdated': '2021-10-04T13:23:12.205Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': 'username@gmail.com'
        },
        {
            'category': 'profile',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'datatype.date.formats',
            'lastUpdated': '2023-02-01T15:03:33.84Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': 'dd/MM/yyyy,dd-MM-yyyy,MM/dd/yyyy,MM-dd-yyyy,yyyy/MM/dd,yyyy-MM-dd'
        },
        {
            'category': 'profile',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'datatype.datetime.formats',
            'lastUpdated': '2023-02-01T15:03:33.879Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': "dd/MM/yyyy'T'HH:mm:ss,dd-MM-yyyy'T'HH:mm:ss"
        },
        {
            'category': 'profile',
            'createdBy': 'bootstrap.user@maurodatamapper.com',
            'key': 'datatype.time.formats',
            'lastUpdated': '2023-02-01T15:03:33.904Z',
            'lastUpdatedBy': 'bootstrap.user@maurodatamapper.com',
            'publiclyVisible': False,
            'value': 'HH:mm:ss,HH:mm'
        }
    ]
}

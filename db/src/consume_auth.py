#!/usr/bin/env python3
import os, sys, json
from datetime import date, datetime
from dotenv import load_dotenv; load_dotenv()
from ez import ez_consume
from database import auth, users


def default(value):
    """
    Convert date/times to strings. Fixes 'datetime not JSON serializable'.
    """
    if isinstance(value, date) or isinstance(value, datetime):
        return value.isoformat()


def callback(ch, method, props, body):
    """
    Auth callback that is called when an auth attempt occurs.
    """
    try:
        data = json.loads(body)
    except Exception as e:
        return  # Malformed JSON

    if not data:
        return

    action = data.get('action')
    token = data.get('token')
    result = { 'success': False }

    # Received get_user attempt
    if action == 'get_user':
        if data.get('token'):
            result = users.get_by_token(data.get('token'))
        else:
            result['message'] = 'INVALID_TOKEN'

    # Received login attempt
    elif action == 'login':
        result = auth.login(
            username_or_email=data.get('username') or data.get('email'),
            password=data.get('password')
        )

    # Received registration attempt
    elif action == 'register':
        result = auth.register(
            username=data.get('username'),
            email=data.get('email'),
            password=data.get('password'),
            first_name=data.get('first_name'),
            last_name=data.get('last_name')
        )

    else:
        result['message'] = 'UNKNOWN_ACTION'
        ez_log('LOG', result['message'], f'For token: {token}')


    return json.dumps(result, default=default)


if __name__ == '__main__':
    ez_consume('AUTH', 'auth-queue-rpc', callback)

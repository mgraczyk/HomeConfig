#!/usr/bin/env python3
import os
import requests
import threading
import time
import json
from pprint import pprint

_ETHERSCAN_TOKEN = 'FPYV7UY7BZCY2YIBY7R5V4H29Q99HUXMI1'


class RateLimiter(object):
    def __init__(self, min_call_period_seconds):
        self._min_call_period_seconds = min_call_period_seconds
        self._next_can_call_time = 0
        self._lock = threading.Lock()

    def wait(self):
        with self._lock:
            now = time.time()
            if now < self._next_can_call_time:
                time.sleep(self._next_can_call_time - now)
            self._next_can_call_time = now + self._min_call_period_seconds


class TooLongError(Exception):
    pass


_ETHERSCAN_LIMITER = RateLimiter(0.1)


def get_transactions(address, start_block=None, end_block=None):
    url = 'http://api.etherscan.io/api?module=account&action=txlist&address={}&sort=asc'.format(
        address)
    if start_block is not None:
        url += '&startblock={}'.format(start_block)
    if end_block is not None:
        url += '&endblock={}'.format(end_block)

    url += '&apikey={}'.format(_ETHERSCAN_TOKEN)

    _ETHERSCAN_LIMITER.wait()
    r = requests.get(url)
    r.raise_for_status()
    response = r.json()
    if 'result' not in response or not response['result']:
        if 'message' not in response:
            print(response)
            return []
        elif 'Query Timeout' in response['message']:
            raise TooLongError
        else:
            return []
    else:
        return response['result']


def write_all_outputs(f):
    address = '0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8'.lower()
    N = 100
    if os.path.exists('checkpoint'):
        with open('checkpoint') as cf:
            start_block = int(cf.read())
    else:
        start_block = 0
    max_end_block = 7000000
    end_block = start_block + 1
    while True:
        pprint((start_block, end_block))
        with open('checkpoint', 'w') as cf:
            cf.write(str(start_block))

        try:
            all_txns = get_transactions(address, start_block, end_block)
        except TooLongError:
            end_block = start_block + int((end_block - start_block) / 2. + 0.5)
            continue
        else:
            if len(all_txns) < 500:
                end_block = max(start_block,
                                min(1 + start_block + 2 * (end_block - start_block),
                                    max_end_block))
            if not all_txns:
                continue

        out_txns = [{
            'to': t['to'],
            'hash': t['hash']
        } for t in all_txns if t['from'] == address]
        start_block = max(int(t['blockNumber']) for t in all_txns) + 1
        f.write(''.join(json.dumps(t, separators=(',', ':')) + '\n' for t in out_txns))
        f.flush()


def main():
    with open('outputs.json', 'a') as f:
        write_all_outputs(f)


if __name__ == '__main__':
    main()

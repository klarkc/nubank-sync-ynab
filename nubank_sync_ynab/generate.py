import os
import base64
from colorama import init, Fore
from pynubank import Nubank, NuException
from pynubank.cli import generate_random_id, log
from pynubank.utils.certificate_generator import CertificateGenerator

TMP_PATH = os.getenv('TMP_PATH') or '/tmp/nubank_sync_ynab'

def tmp_path(file):
    return TMP_PATH + '/' + file

def missing(file):
    return not os.path.isfile(tmp_path(file))

def input_log(msg):
    log('') #remove color
    return input(msg)

def ask(what):
    content = input_log('[>] Please provide ' + what + ': ')
    with open(tmp_path(what), 'w') as token_file:
        token_file.write(content)
        log(f'{Fore.YELLOW}' + what + ' stored')

def ask_password(for_what):
    return input_log('[>] Please provide ' + for_what + ' password: ')

def get_cpf():
    with open(tmp_path('nubank_cpf'), 'r') as file:
        return file.read()

def gen_token(password):
    log('Storing token')
    nu = Nubank()
    cpf = get_cpf()
    refresh_token = nu.authenticate_with_cert(cpf, password, tmp_path('cert.p12'))
    with open(tmp_path('token'), 'w') as token_file:
        token_file.write(refresh_token)
        log(f'{Fore.YELLOW}Token stored')

def gen_cert(password):
    device_id = generate_random_id()
    log(f'Generated random id: {device_id}')
    cpf = get_cpf()
    generator = CertificateGenerator(cpf, password, device_id)
    log('Requesting e-mail code')
    try:
        email = generator.request_code()
    except NuException:
        log(f'{Fore.RED}Failed to request code. Check your credentials!', Fore.RED)
        return
    log(f'Email sent to {Fore.LIGHTBLACK_EX}{email}{Fore.LIGHTBLUE_EX}')
    code = input_log('[>] Type the code received by email: ')
    cert1, cert2 = generator.exchange_certs(code)
    log('Storing certificate')
    with open(tmp_path('cert.p12'), 'wb') as cert_file:
        cert_file.write(cert1.export())
        log(f'{Fore.YELLOW}Certificate P12 stored')
    with open(tmp_path('cert'), 'wb') as cert_file:
        cert_content = base64.b64encode(cert1.export())
        cert_file.write(cert_content)
        log(f'{Fore.YELLOW}Certificate stored')
    log(f'{Fore.GREEN}Certificates generated successfully.')

if __name__ == '__main__':
    init()
    if missing('nubank_cpf'):
        ask('nubank_cpf')
    if missing('nubank_card_account'):
        ask('nubank_card_account')
    if missing('nubank_nuconta_account'):
        ask('nubank_nuconta_account')
    if missing('ynab_email'):
        ask('ynab_email')
    if missing('ynab_pass'):
        ask('ynab_pass')
    if missing('ymab_budget'):
        ask('ymab_budget')

    password = ask_password('Nubank')
    if missing('cert.p12') or missing('cert'):
        gen_cert(password)
    gen_token(password)
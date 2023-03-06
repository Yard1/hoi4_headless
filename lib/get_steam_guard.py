import argparse
import email
import email.generator
import email.policy
import io
import poplib
import re
import sys
import time
from datetime import datetime

SUBJECT = "Your Steam account: Access from new computer"
REGEX = re.compile(r"Here is the Steam Guard code.*[\n\s\r]*([A-Z\d]{5})")


def get_steam_guard_email(
    address: str,
    user: str,
    password: str,
    timestamp_from: int,
    timeout_s: float = 300,
    ssl: bool = True,
    port: int = 995,
) -> str:
    steam_guard_email = None
    start_time = time.monotonic()
    while not steam_guard_email and time.monotonic() < start_time + timeout_s:
        # connect to server
        print(f"Connecting to server {address} as user '{user}'...", file=sys.stderr)
        if ssl:
            server_cls = poplib.POP3_SSL
        else:
            server_cls = poplib.POP3
        server = server_cls(address, port=port)

        # login
        server.user(user)
        server.pass_(password)
        print(f"Connected to server {address} as user '{user}'", file=sys.stderr)

        print(f"Querying server...", file=sys.stderr)
        indices = [i for i in range(1, len(server.list()[1]) + 1)][-3:]
        messages = [
            "\n".join([x.decode("utf-8") for x in server.retr(i)[1]]) for i in indices
        ]
        for msg in messages:
            msg = email.message_from_string(msg, policy=email.policy.default)
            subject = msg["Subject"]
            date_sent = datetime.strptime(str(msg["Date"]), "%a, %d %b %Y %H:%M:%S %z")
            if date_sent.timestamp() >= timestamp_from and SUBJECT in subject:
                print(f"Found a steam guard email sent at {date_sent}", file=sys.stderr)
                buffer = io.StringIO()
                generator = email.generator.Generator(buffer)
                generator.flatten(msg)
                steam_guard_email = buffer.getvalue()
                break
        server.quit()
        if not steam_guard_email:
            time.sleep(10)
    if not steam_guard_email:
        raise RuntimeError(
            "Didn't obtain a new steam guard email in the specified timeout."
        )
    return steam_guard_email


def get_steam_guard_code_from_email(email_content: str) -> str:
    code = REGEX.search(email_content)
    if not code:
        raise ValueError("Couldn't find the steam guard code in the email")
    return code.group(1)


def main(args: argparse.Namespace) -> str:
    email = get_steam_guard_email(
        args.address,
        args.user,
        args.password,
        args.timestamp_from,
        timeout_s=args.timeout,
        ssl=not args.no_ssl,
        port=args.port,
    )
    return get_steam_guard_code_from_email(email)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("address", help="Address of the pop3 server", type=str)
    parser.add_argument("user", help="User to authenticate the pop3 server", type=str)
    parser.add_argument(
        "password",
        help="Password to authenticate the pop3 server",
        type=str,
    )
    parser.add_argument(
        "timestamp_from",
        help="UNIX epoch timestamp in seconds after which the steam guard email should come",
        type=float,
    )
    parser.add_argument(
        "--timeout",
        help="Timeout for obtaining the email",
        type=float,
        required=False,
        default=300,
    )
    parser.add_argument(
        "--no-ssl",
        help="Don't use SSL for pop3 connection",
        action="store_true",
        required=False,
    )
    parser.add_argument(
        "--port",
        help="Port for pop3 connection",
        type=int,
        required=False,
        default=995,
    )

    args = parser.parse_args()
    print(main(args))

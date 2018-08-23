# Zimbra Clean Outgoing Spam Queue

This script works by scanning the logs for excesive user logins
This behavior is usually associated with an account that was compromised
and it's being used to send spam or other unauthorized email

The script requieres a minimum number of logins to be set as the threshold,
then it will check every login in the last log file and output every user
who exceeded this number, asking if you want to block the account
and clear the mail queue for the user account.


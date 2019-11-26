#!/bin/bash

# Connect automatically to Raspberry Pi server with the users own account
USERNAME=$(id -un)

ssh $USERNAME@[REDACTED]

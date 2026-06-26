#!/bin/bash

tofu output -raw ansible-inventory | jq || tofu output -raw ansible-inventory
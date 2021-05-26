#!/bin/bash

grep -iE $2.*$3 $1_Dealer_schedule | awk -F' ' '{print $5, $6}'




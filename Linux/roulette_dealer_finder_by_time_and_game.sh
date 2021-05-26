#!/bin/bash

echo BlackJack Dealer Roulette Dealer Texas Dealer > Dealer
grep -iE $2.*$3 $1_Dealer_schedule | awk  -F' ' '{print $3, $4, $5, $6, $7, $8}' >> Dealer
awk -vdel=$4 '(NR==1){for(i=1;i<=NF;i++)if($(i)==del)colno=i;}{print$(colno), $(colno+1)}' Dealer | head -2 | tail -1
rm Dealer

#!/bin/bash

# PCOfficina AutoTools
# Sistema di automazione per check-up macchine
# https://github.com/
#
# The MIT License (MIT)
#
# Copyright (c) 2019 PCOfficina
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#
# Variabili d'ambiente
#

cmdline=./fake_cl	# /proc/cmdline File argomenti riga di comando GRUB
version="0.3"	# Versione dello script

$(cat $cmdline | grep "REMOTE_IP")	# IP del boot server
$(cat $cmdline | grep "WORK_NAME")	# Nome della lavorazione

WORK_NAME="pco-001"

#
# Utilita'
#

# Stampa un errore critico 
function crit { 
	echo -e "\a\e[1;31m*\e[0m" $1
}

# Stampa un'informazione
function info {
	echo -e "\e[1;32m#\e[0m" $1
}

# Stampa un avviso non critico
function warn {
	echo -e "\a\e[1;33m!\e[0m" $1
}

# Stampa una richiesta di intervento
function attn {
	echo -e "\e[1;34m?\e[0m" $1
}

#
# Entry point
#

clear
echo -e "PCOfficina AutoTools $version\t\tRilasciato sotto licenza MIT\n"
info "Inizio lavorazione:\t$(date)"

info "Codice macchina:\t$WORK_NAME"

# Controlla la connessione a internet
if [ -z "$(ping -c 1 www.google.com | grep "1 rec")" ]; then
	echo
	crit "Mi serve internet..."
	crit "Errore di lavorazione!"
	exit
fi

# Installa 'inxi' se non e' disponibile
if [ -z $(which inxi) ]; then
	echo
	warn "Mi serve inxi..." >&2
	apt-get install inxi > /dev/null
fi

# Installa 'smartmontools' se non e' disponibile
if [ -z $(which smartctl) ]; then
	echo
	warn "Mi serve smartmontools..." >&2
	apt-get install smartmontools > /dev/null
fi	

# Stampa la configurazione di sistema
echo
info "Configurazione hardware:\n"
inxi -short

# Controlla i parametri SMART dei dischi
echo
info "Parametri SMART:\n"
declare -a disk_ary
disk_ary+=(/dev/sd?)
sudo smartctl --attributes /dev/sda | grep -Ei 'reallocated_s|power_cyc' | awk '{print $2 " " $10}'

# Esegue badblocks
echo
info "Eseguo un controllo distruttivo dei dischi:\n"
# badblocks -xyzw /dev/sda

# Termina il programma
echo
info "Fine lavorazione:\t$(date)"
exit

## EOF ##
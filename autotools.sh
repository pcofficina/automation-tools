#!/bin/bash

# PCOfficina AutoTools
# Sistema di automazione per check-up macchine
# https://github.com/pcofficina

#
# Variabili d'ambiente
#

### TODO: prendere le variabili dalla riga di comando 

version="0.51"	# Versione dello script
deps=(inxi smartmontools)	# Dipendenze dello script
disks=(/dev/sd?) # Dischi della macchina

WORK_NAME="pco-7357"

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
echo -e "PCOfficina AutoTools $version\t\tRilasciato sotto licenza XYZ"
echo -e "Bash versione ${BASH_VERSION}\n"


if [[ $UID != 0 ]]; then
	# TODO: Auto-sudo
    crit "Lo script deve essere eseguito con sudo!"
    exit 1
fi

info "Inizio lavorazione:\t$(date)"

info "Codice macchina:\t$WORK_NAME"

# Controlla la connessione a internet
if [ -z "$(ping -c 1 www.google.com | grep "1 rec")" ]; then
	echo
	crit "Mi serve internet..."
	crit "Errore di lavorazione!"
	exit
fi

# Installa le dipendenze
for dep in "${deps[@]}"
do 
	if [ -z $(which $dep) ]; then
		echo
		warn "Mi serve $dep..." >&2
		apt-get --yes --force-yes install $dep > /dev/null
	fi
done

# Stampa la configurazione di sistema
echo
info "Configurazione hardware:\n"
inxi -ABCdMn

# Controlla i parametri SMART dei dischi
echo
info "Parametri SMART:\n"
for disk in "${disks[@]}"
do 
	# TODO: Stabilire se sto passando su una chiavetta!
	smartctl --attributes $disk | grep -Ei 'reallocated_s|power_cyc' | awk '{print $2 " " $10}'
done

# Esegue badblocks
echo
info "Eseguo un controllo distruttivo dei dischi:\n"
# badblocks -xyzw /dev/sda

# Termina il programma
echo
info "Fine lavorazione:\t$(date)"
exit

## EOF ##
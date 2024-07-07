# GOAL 1: ottieni i 20 file più modificati

git log --name-only --pretty="format:" |                                             # stampa il log dei commit mostrando solo i nomi dei file modificati 
sed '/^\s*$/d' |                                                                     # elimina le righe vuote o contenenti solo spazi bianchi
sort |                                                                               # ordina alfabeticamente (per permettere l'uso di uniq successivamente)
uniq -c |                                                                            # unisce le righe uguali e conta le occorrenze
sort -nr |                                                                           # ordina per numero di occorrenze in ordine decrescente
head -n 20 |                                                                         # restituisce solo le prime 20 righe

# GOAL 2: per ogni file, ottieni i contributori unici 

while read count filename;                                                           # esegui un ciclo sulle righe del risultato precedente             
    do 
        contributors=$(git log --format="%an" -- "$filename" | sort -u);             # ottieni i contributori unici di ciascun file 
        echo -e "$count $filename \n[\n$contributors\n]\n\n";                        # stampa il risultato finale
done > output.txt                                                                    # salva il risultato in un file di testo

# NOTA: eseguire questo script nella cartella del repository git di interesse, da piattaforma Linux o Mac OS







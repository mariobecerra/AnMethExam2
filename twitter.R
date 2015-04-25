#install the necessary packages
install.packages("ROAuth")
install.packages("twitteR")
install.packages("wordcloud")
install.packages("tm")

#Paqueterias necesarias para que corra

library("ROAuth")
library("twitteR")
library("wordcloud")
library("tm")
library("httr")
 
#necessary file for Windows
#download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")
 
 setup_twitter_oauth('5VppZIQSG1u4H1qPmcPoGu5i6', '1KLRAOrqyBQlkaJMZNjcUmf9Cmo707RdpUD6dSi7ClYtJE5Gv7', '355476819-klLsCMgCzvKeOhbKE4IQ7L0mUOSByWfF3bsw4evg','UQ5L60X3ydnqg4sDLU9JMQA7UF8Wqo1yZzUXKDpLKYM0f')
 
 
#Despues de conectarse
twitts <- searchTwitter("#Birdman", n=4000)
length(twitts)
twitts_text <- sapply(twitts, function(x) x$getText())
twitts_uni <- unique(twitts_text)
length(twitts_uni)

#twitts_text_corpus <- Corpus(VectorSource(twitts_text)) 
#clean up
# r_stats_text_corpus <- tm_map(twitts_text_corpus, removePunctuation)
# r_stats_text_corpus <- tm_map(twitts_text_corpus, function(x)removeWords(x,stopwords()))
# wordcloud(r_stats_text_corpus)
 
#Para guardar los datos  
res <- lapply(seq_along( twitts_uni), function(i){
    write(gsub("\n"," ", twitts_uni[i] ), file ='superB.dat',append=T) })
 
 
 ------------------------------------------------------------------------------
 ------------------------------------------------------------------------------
 #Analisis de datos
 # twitts_uni
tejas <- function(texto, k){
     if(nchar(texto) < k ){
         stop('Documento demasiado corto')
     } 
     else{
         tejas.1 <- lapply(1:(nchar(texto) - k +1), function(i){
             substr(texto, start = i, stop = i + k -1)
         })
     }
     unique(Reduce('c', tejas.1))
}
 
archivo <- 'superB.dat'
archivo_salida <- 'shingles_gg.txt'
con <- file(archivo,'r')
con_out <- file(archivo_salida, 'w')
linea <- readLines(con, 1)
doc_no <- 1
lista_tweets <- list()

while(length(linea) > 0){
    lista_tweets[doc_no] <- linea 
    if(nchar(linea) < 6){
            # se puede usar str_pad de stringr pero generalmente es más lento
            linea <- paste0(linea, paste0(rep(' ',6-nchar(linea)), collapse=""), collapse="")
    }
    #calcular tejas
    tejas.1 <- tejas(linea, 6)
    #escribir tejas
    for(teja in tejas.1){
        write(as.character(c(teja, doc_no)), file=con_out,  append=T, ncolumns = 2, sep=" ")
    }  
    #leer nuevo documento
    linea <- readLines(con, 1)
    doc_no <- doc_no + 1
}
 
close(con)
close(con_out)

#Hacerle sort al documento 
# sort shingles_gg.txt > shingles_gg_ord.txt 
 
library("stringr")
set.seed(2805)
hash.lista <- lapply(1:200, function(i){
    primo <- 857142
    a <- sample(1:(primo-1), 1)
    b <- sample(1:(primo-1), 1)
    function(x){
		#El segundo modulo es el numero de tejas
        (((a*(x-1) + b) %% primo) %% 346493) + 1
    }
}) 

minhash_2 <- function(archivo, no_documentos, hash.lista){
    con <- file(archivo,'r')
    linea <- readLines(con, 1)
    teja_no <- 1
    teja_actual <- substr(linea, 1, 6)
    
    n_hashes <- length(hash.lista)
    sig <- matrix(rep(Inf, no_documentos*n_hashes), ncol = no_documentos)
	nurow <- dim(sig)[1]
    hash_renglon <- sapply(hash.lista, function(h) h(1))

    while(length(linea) > 0){
        documento <- as.integer(str_trim(substr(linea, 8, 11)))
        ## actualizar la matriz de firmas 
        ## sig <- update_mat(sig, documento, hash_renglon, no_documentos, n_hashes)
		for(i in 1:nurow){
			if(hash_renglon[i] < sig[i,documento]){
				sig[i,documento] = hash_renglon[i]
			}
		}
		## ##
        linea <- readLines(con, 1)
        teja <- substr(linea, 1, 6) 
        if(length(teja)>0){
            if(teja != teja_actual){
                if(teja_no %% 10000 ==0){
                    print(teja_no)
                }
            teja_no <- teja_no + 1
            teja_actual <- teja
            hash_renglon <- sapply(hash.lista, function(h) h(teja_no))
            }
        }
    }
    close(con)
    sig
}
 
firmas <- minhash_2(archivo ='shingles_gg_ord.txt', no_documentos=3335, hash.lista)
save(firmas, file='firmas.Rdata') 
load('firmas.Rdata')
dim(firmas)

#Lo final analisis
analisa_tweet <- function (firmas,doc.ind, umbral){
doc.1.firma <- firmas[,doc.ind]
sim_est <- apply(firmas, 2, function(x){mean(x==doc.1.firma)})
docs.sim <- which(sim_est>= umbral)
docs.sim
}

todos <- list()
for(i in 1:3335){
	similares <- analisa_tweet(firmas, i , 0.2)
	todos[i]<- list(lista_tweets[similares])
}

#similares <- analisa_tweet(firmas, 1000 , 0.1)
#lista_tweets[similares]

#Para LSH
#Para 1:20, 10, codigos = 134, para 1_40, 5, codigos 260

mat.split <- split(data.frame((firmas)), rep(1:40, each=5))
mat.hashed <- sapply(mat.split, function(mat){
    apply(mat, 2, function(x){   sum(x) })
})
dim(mat.hashed)
head(mat.hashed)

mat.hashed <- data.frame(mat.hashed)
mat.hashed$doc_no <- 1:nrow(mat.hashed)
tab.1 <- table(mat.hashed[,1])
codigos <- as.integer(names(tab.1[tab.1 >= 2]))
length(codigos)

candidatos <- lapply(1:20, function(i){
    tab.1 <- table(mat.hashed[,i])
    codigos <- as.integer(names(tab.1[tab.1 >= 2]))
    salida <- lapply(codigos, function(cod){ 
        mat.hashed$doc_no[mat.hashed[,i] == cod]
    })
   Reduce('cbind',lapply(salida, function(x){combn(x,2)}))
})
candidatos.tot <- t(Reduce('cbind',candidatos))
head(candidatos.tot)

candidatos.tot.2 <- unique(candidatos.tot)
dim(candidatos.tot.2)

sim.jaccard <- function(a, b){
    length(intersect(a, b)) / length(union(a, b))
}

sims.cand <- apply(candidatos.tot.2, 1, function(x){
    #print(x)
    tej.1 <- tejas(lista_tweets[[x[1]]],6)
    tej.2 <- tejas(lista_tweets[[x[2]]], 6)
    sim.jaccard(tej.1, tej.2)
})
salida <- cbind(candidatos.tot.2, sims.cand)
salida <- salida[order(salida[,1]),]

salida.alta <- salida[salida[,3]> 0.10,]
head(salida.alta)

lista_tweets[c(45,47)]
lista_tweets[salida[salida[,1]==1677,2]]

#B = 20, r = 10
save(salida.alta, file='salidaAlta_2.Rdata') 